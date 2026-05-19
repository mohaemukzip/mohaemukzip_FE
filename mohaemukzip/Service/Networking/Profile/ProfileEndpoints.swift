import Foundation
import Moya
import Alamofire
//import KeychainSwift


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

    // 헤더 한번 수정. 임시용.
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
        
        /*
         let contentTypeHeader: [String: String] = ["Content-Type": "application/json"]

        // 1) Keychain 토큰 우선
        if let accessToken = KeychainSwift().get("serverAccessToken")?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !accessToken.isEmpty {

            #if DEBUG
            print("[ProfileEndpoints] ✅ Using Keychain token")
            #endif

            return contentTypeHeader.merging(["Authorization": "Bearer \(accessToken)"]) { $1 }
        }

        // 2) 개발 편의: Config(accessTK) fallback
        #if DEBUG
        let fallback = Config.accessTK.trimmingCharacters(in: .whitespacesAndNewlines)

        // 치환 실패하면 보통 '$(ACCESS_TOKEN)' 문자열이 그대로 남음
        if fallback.contains("$(") {
            print("[ProfileEndpoints] ❌ ACCESS_TOKEN substitution failed: \(fallback)")
        } else if !fallback.isEmpty {
            print("[ProfileEndpoints] ⚠️ Keychain token not found. Using Config.accessTK for DEBUG.")
            return contentTypeHeader.merging(["Authorization": "Bearer \(fallback)"]) { $1 }
        } else {
            print("[ProfileEndpoints] ❌ Config.accessTK is empty. Check Info.plist/xcconfig injection.")
        }
        #endif

        // 3) 로그인 전
        return contentTypeHeader
         */
    }

    var sampleData: Data {
        return Data()
    }
}
