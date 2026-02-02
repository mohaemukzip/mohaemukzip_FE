//
//  ProfileEndpoints.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/2/26.
//

import Foundation
import Moya
import Alamofire
import KeychainSwift


enum ProfileEndpoints {
    /// 마이 페이지 조회
    case getMyPage

    /// 최근 본 레시피 목록 조회
    case getRecentlyViewedRecipes

    /// 저장(북마크)된 레시피 목록 조회 (page query)
    case getBookmarkedRecipes(page: Int)

    /// 프로필 이미지 업로드 URL 발급
    case postProfileUploadURL(dto: ProfileRequestDTO.IssueUploadURLRequest)

    /// 프로필(닉네임/프로필 이미지) 수정
    case patchProfile(dto: ProfileRequestDTO.UpdateProfileRequest)
}

extension ProfileEndpoints: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("잘못된 baseURL입니다.")
        }
        return url
    }

    var path: String {
        switch self {
        case .getMyPage:
            return "/members/me/mypage"
        case .getRecentlyViewedRecipes:
            return "/members/me/recently-viewed"
        case .getBookmarkedRecipes:
            // NOTE: 서버에서 경로가 다르면 여기만 바꾸면 됩니다.
            return "/members/me/bookmarks"
        case .postProfileUploadURL:
            return "/s3/profile/upload-url"
        case .patchProfile:
            return "/members/me/profile"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMyPage, .getRecentlyViewedRecipes, .getBookmarkedRecipes:
            return .get
        case .postProfileUploadURL:
            return .post
        case .patchProfile:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .getMyPage, .getRecentlyViewedRecipes:
            return .requestPlain

        case let .getBookmarkedRecipes(page):
            return .requestParameters(
                parameters: ["page": page],
                encoding: URLEncoding.queryString
            )

        case let .postProfileUploadURL(dto):
            return .requestJSONEncodable(dto)

        case let .patchProfile(dto):
            return .requestJSONEncodable(dto)
        }
    }

    var headers: [String: String]? {
        guard let accessToken = KeychainSwift().get("serverAccessToken") else {
            return ["Content-Type": "application/json"]
        }
        return [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
    }

    var sampleData: Data {
        return Data()
    }
}
