//
//  ProfileServices.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/2/26.
//

import Foundation
import Moya

/// Profile / MyPage 관련 Service
/// - NOTE: 현재 프로젝트의 `NetworkManager.shared.makeProvider(for:)` + `Response.mapResult(_:)` 패턴을 그대로 사용합니다.

final class ProfileService {

    static let shared = ProfileService()

    // MARK: - Provider
    private let provider: MoyaProvider<ProfileEndpoints>

    init(provider: MoyaProvider<ProfileEndpoints>? = nil) {
        self.provider = provider ?? NetworkManager.shared.makeProvider(for: ProfileEndpoints.self)
    }

    // MARK: - Private Request Helper

    private func request<T: Decodable>(
        target: ProfileEndpoints,
        decodingType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let decoded = try response.mapResult(decodingType)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - API

    /// 마이페이지 조회
    /// GET /members/me/mypage
    func getMyPage(completion: @escaping (Result<ProfileResponseDTO.MyPage, Error>) -> Void) {
        request(target: .getMyPage, decodingType: ProfileResponseDTO.MyPage.self, completion: completion)
    }

    /// 최근 본 레시피 목록 조회
    /// GET /members/me/recently-viewed
    func getRecentlyViewedRecipes(completion: @escaping (Result<[ProfileResponseDTO.RecipeCard], Error>) -> Void) {
        request(target: .getRecentlyViewedRecipes, decodingType: [ProfileResponseDTO.RecipeCard].self, completion: completion)
    }

    /// 저장(북마크)된 레시피 목록 조회 (페이지네이션)
    /// GET /members/me/bookmarked?page=
    func getBookmarkedRecipes(page: Int, completion: @escaping (Result<ProfileResponseDTO.BookmarkedRecipePage, Error>) -> Void) {
        request(target: .getBookmarkedRecipes(page: page), decodingType: ProfileResponseDTO.BookmarkedRecipePage.self, completion: completion)
    }

    /// 프로필 이미지 업로드 URL 발급
    /// POST /s3/profile/upload-url
    func postProfileUploadURL(
        dto: ProfileRequestDTO.IssueUploadURLRequest,
        completion: @escaping (Result<ProfileResponseDTO.PresignedUpload, Error>) -> Void
    ) {
        request(target: .postProfileUploadURL(dto: dto), decodingType: ProfileResponseDTO.PresignedUpload.self, completion: completion)
    }

    /// 프로필 수정 (닉네임/프로필 이미지 키)
    /// PATCH /members/me/profile
    func patchProfile(
        dto: ProfileRequestDTO.UpdateProfileRequest,
        completion: @escaping (Result<ProfileResponseDTO.EmptyResult, Error>) -> Void
    ) {
        request(target: .patchProfile(dto: dto), decodingType: ProfileResponseDTO.EmptyResult.self, completion: completion)
    }
    // MARK: - Presigned Upload (URLSession)

    /// presignedUrl로 프로필 이미지를 PUT 업로드합니다.
    /// - IMPORTANT: presignedUrl은 S3 직행 URL이므로 "Authorization" 헤더를 넣으면 안됩니다.
    /// - Parameters:
    ///   - presignedUrl: 서버에서 발급받은 presignedUrl
    ///   - imageData: 업로드할 이미지 바이너리
    ///   - contentType: 예) "image/png"
    func uploadProfileImage(
        to presignedUrl: String,
        imageData: Data,
        contentType: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: presignedUrl) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(
                    domain: "ProfileService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "presignedUrl이 올바르지 않습니다."]
                )))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(
                        domain: "ProfileService",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "유효한 HTTP 응답이 아닙니다."]
                    )))
                }
                return
            }

            // S3 presigned PUT은 보통 200 또는 204로 성공합니다.
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
                return
            }

            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            DispatchQueue.main.async {
                completion(.failure(NSError(
                    domain: "ProfileService",
                    code: httpResponse.statusCode,
                    userInfo: [
                        NSLocalizedDescriptionKey: "프로필 이미지 업로드 실패 (status: \(httpResponse.statusCode))",
                        "body": bodyString
                    ]
                )))
            }
        }.resume()
    }

    // MARK: - 프로필 이미지 변경 플로우 (발급 → PUT → PATCH)

    /// 프로필 이미지 변경 전체 플로우
    /// 1) 업로드 URL 발급 (key, presignedUrl)
    /// 2) presignedUrl로 이미지 PUT 업로드 (토큰 없이)
    /// 3) 서버에 프로필 수정 PATCH (profileImageKey=key, nickname)
    func changeProfileImage(
        imageData: Data,
        nickname: String,
        completion: @escaping (Result<ProfileResponseDTO.EmptyResult, Error>) -> Void
    ) {
        // S3 업로드 파일명은 중복 방지를 위해 uuid 사용
        let fileName = "profile_\(UUID().uuidString).png"
        let contentType = "image/png"

        let issueDTO = ProfileRequestDTO.IssueUploadURLRequest(
            fileName: fileName,
            contentType: contentType
        )

        // 1) 업로드 URL 발급
        postProfileUploadURL(dto: issueDTO) { [weak self] result in
            guard let self else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(
                        domain: "ProfileService",
                        code: -999,
                        userInfo: [NSLocalizedDescriptionKey: "ProfileService가 해제되었습니다."]
                    )))
                }
                return
            }

            switch result {
            case let .success(presigned):
                // 2) presignedUrl로 PUT 업로드
                self.uploadProfileImage(
                    to: presigned.presignedUrl,
                    imageData: imageData,
                    contentType: contentType
                ) { uploadResult in
                    switch uploadResult {
                    case .success:
                        // 3) 업로드 성공 시 key로 PATCH
                        let patchDTO = ProfileRequestDTO.UpdateProfileRequest(
                            profileImageKey: presigned.key,
                            nickname: nickname
                        )

                        self.patchProfile(dto: patchDTO) { patchResult in
                            DispatchQueue.main.async {
                                completion(patchResult)
                            }
                        }

                    case let .failure(error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
