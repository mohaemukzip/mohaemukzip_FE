//
//  ProfileViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import Foundation
import Combine

// MARK: - ProfileViewModel

/// 마이페이지(프로필) 화면용 ViewModel
/// - NOTE: Service(API) 결과(DTO)를 ProfileModel(Domain Model)로 변환해서 View에 제공합니다.
/// - IMPORTANT: 네트워크 콜백 스레드는 보장되지 않으므로, UI 상태 변경은 main thread에서 처리합니다.

final class ProfileViewModel: ObservableObject {

    // MARK: - Published (View State)

    /// 마이페이지 화면 데이터
    @Published var myPage: ProfileMyPageModel = .empty

    /// 닉네임만 수정할 때도 기존 이미지가 유지되도록 key를 캐시
    @Published private(set) var cachedProfileImageKey: String = ""

    /// 로딩 상태
    @Published var isLoading: Bool = false

    /// 에러 메시지(간단 표시용)
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies

    private let profileService: ProfileService

    // MARK: - Init

    init(profileService: ProfileService = .shared) {
        self.profileService = profileService
    }

    // MARK: - Computed (Preview)

    /// 최근 조회 레시피 미리보기(최대 3개)
    var recentlyViewedPreview: [ProfileRecipeCard] {
        Array(myPage.activity.recentlyViewed.prefix(3))
    }

    /// 저장한 레시피 미리보기(최대 3개)
    var bookmarkedPreview: [ProfileRecipeCard] {
        Array(myPage.activity.bookmarked.prefix(3))
    }

    // MARK: - Functions

    /// 마이페이지 최초 진입/리프레시 시 호출
    func fetchMyPage() {
        // 중복 호출 방지(원하면 제거 가능)
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[ProfileViewModel] ✅ fetchMyPage START")

        profileService.getMyPage { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(dto):
                let model = ProfileMyPageModel.from(dto: dto)

                DispatchQueue.main.async {
                    self.myPage = model
                    let key = self.extractProfileImageKey(from: model.profile.profileImageUrl)
                    if !key.isEmpty {
                        self.cachedProfileImageKey = key
                    }
                    self.isLoading = false
                }

                print("[ProfileViewModel] ✅ fetchMyPage SUCCESS | nickname=\(model.profile.nickname), level=\(model.profile.level), remainingScore=\(model.pointInfo.remainingScore)")
                print("[ProfileViewModel] ✅ recentlyViewed=\(model.activity.recentlyViewed.count), bookmarked=\(model.activity.bookmarked.count)")

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[ProfileViewModel] ❌ fetchMyPage FAIL | error=\(error)")
            }
        }
    }

    /// 뷰에서 pull-to-refresh 같은 갱신 동작이 필요할 때 사용
    func refresh() {
        print("[ProfileViewModel] 🔄 refresh")
        fetchMyPage()
    }

    /// 프로필 이미지 변경 (발급 → PUT → PATCH) 플로우 실행
    /// - Parameters:
    ///   - imageData: 선택한 이미지 데이터(png 권장)
    ///   - nickname: 현재/변경 닉네임
    func changeProfileImage(imageData: Data, nickname: String) {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[ProfileViewModel] ✅ changeProfileImage START")

        profileService.changeProfileImage(imageData: imageData, nickname: nickname) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.isLoading = false
                }

                print("[ProfileViewModel] ✅ changeProfileImage SUCCESS")

                // 변경 성공 후 최신 정보 재조회
                self.fetchMyPage()

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[ProfileViewModel] ❌ changeProfileImage FAIL | error=\(error)")
            }
        }
    }
    // MARK: - Profile Update (nickname / image / both)

    /// 닉네임만 변경, 이미지(키)만 변경, 둘 다 변경을 모두 처리하는 단일 엔트리
    /// - Parameters:
    ///   - nickname: 변경할 닉네임 (nil이면 닉네임은 유지)
    ///   - imageData: 변경할 이미지 데이터 (nil이면 이미지는 유지)
    func updateProfile(
        nickname: String?,
        imageData: Data?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        let currentNickname = myPage.profile.nickname
        let trimmedNickname = nickname?.trimmingCharacters(in: .whitespacesAndNewlines)
        let nicknameChanged = (trimmedNickname != nil && trimmedNickname != currentNickname)

        // 1) 이미지 변경 없음 → 닉네임만 변경이면 nickname만 PATCH
        if imageData == nil {
            guard nicknameChanged, let newNickname = trimmedNickname, !newNickname.isEmpty else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                print("[ProfileViewModel] ⚠️ updateProfile(NICKNAME) SKIP | no changes")
                completion(.success(()))
                return
            }

            print("[ProfileViewModel] ✅ updateProfile(NICKNAME) START | nickname=\(newNickname)")

            profileService.patchNickname(newNickname) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.myPage.profile.nickname = newNickname
                    }

                    print("[ProfileViewModel] ✅ updateProfile(NICKNAME) SUCCESS")
                    self.fetchMyPage()
                    completion(.success(()))

                case let .failure(error):
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                    }

                    print("[ProfileViewModel] ❌ updateProfile(NICKNAME) FAIL | error=\(error)")
                    completion(.failure(error))
                }
            }

            return
        }

        // 2) 이미지 변경 있음 → presigned 발급 → PUT → PATCH
        let uploadData = imageData!
        let fileName = "profile_\(UUID().uuidString).png"
        let contentType = "image/png"

        let issueDTO = ProfileRequestDTO.IssueUploadURLRequest(
            fileName: fileName,
            contentType: contentType
        )

        print("[ProfileViewModel] ✅ updateProfile(IMAGE) START | nickname=\(trimmedNickname ?? ""), bytes=\(uploadData.count)")

        profileService.postProfileUploadURL(dto: issueDTO) { [weak self] issueResult in
            guard let self else { return }

            switch issueResult {
            case let .success(presigned):
                print("[ProfileViewModel] ✅ postProfileUploadURL SUCCESS | key=\(presigned.key)")

                self.profileService.uploadProfileImage(
                    to: presigned.presignedUrl,
                    imageData: uploadData,
                    contentType: contentType
                ) { uploadResult in
                    switch uploadResult {
                    case .success:
                        print("[ProfileViewModel] ✅ uploadProfileImage SUCCESS")

                        let nicknameToSend: String? = {
                            let t = trimmedNickname
                            guard let t, !t.isEmpty, t != currentNickname else { return nil }
                            return t
                        }()

                        // 이미지 키는 항상 전송, 닉네임은 변경된 경우에만 전송
                        let patchDTO = ProfileRequestDTO.UpdateProfileRequest(
                            profileImageKey: presigned.key,
                            nickname: nicknameToSend
                        )

                        self.profileService.patchProfile(dto: patchDTO) { [weak self] patchResult in
                            guard let self else { return }

                            switch patchResult {
                            case .success:
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                    if let nicknameToSend {
                                        self.myPage.profile.nickname = nicknameToSend
                                    }
                                    self.cachedProfileImageKey = presigned.key
                                }

                                print("[ProfileViewModel] ✅ updateProfile(IMAGE) SUCCESS | key=\(presigned.key)")
                                self.fetchMyPage()
                                completion(.success(()))

                            case let .failure(error):
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                    self.errorMessage = error.localizedDescription
                                }

                                print("[ProfileViewModel] ❌ updateProfile(IMAGE) PATCH FAIL | error=\(error)")
                                completion(.failure(error))
                            }
                        }

                    case let .failure(error):
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.errorMessage = error.localizedDescription
                        }

                        print("[ProfileViewModel] ❌ uploadProfileImage FAIL | error=\(error)")
                        completion(.failure(error))
                    }
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[ProfileViewModel] ❌ postProfileUploadURL FAIL | error=\(error)")
                completion(.failure(error))
            }
        }
    }

    /// 닉네임만 변경 (편의 메서드)
    func updateNickname(to newNickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
        updateProfile(nickname: newNickname, imageData: nil, completion: completion)
    }

    /// profileImageUrl에서 key(profiles/uuid.png) 추출
    private func extractProfileImageKey(from profileImageUrl: String) -> String {
        let trimmed = profileImageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        // 이미 key 형태로 내려오는 경우
        if trimmed.hasPrefix("profiles/") {
            return trimmed
        }

        guard let url = URL(string: trimmed) else {
            return ""
        }

        let path = url.path
        let cleaned = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 프리뷰에서만 쓰는 유틸
    func setNicknameForPreview(_ nickname: String) {
        myPage.profile.nickname = nickname
    }
}
