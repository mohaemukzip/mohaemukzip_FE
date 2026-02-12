import Foundation
import Moya
import Alamofire
import KeychainSwift



enum RecipeEndpoints {

    /// 세부 카테고리별 레시피 목록 조회
    /// - Parameters:
    ///   - categoryId: 서버에서 정의한 세부 카테고리 ID
    ///   - page: (선택) 페이지 인덱스
    ///   - size: (선택) 페이지 사이즈
    /// -
   
    case searchRecipes(
        categoryId: Int,
        page: Int? = nil,
        size: Int? = nil
    )

    /// 레시피 상세 조회
    /// - Parameter recipeId: 상세 화면에서 사용할 레시피 ID
    case recipeDetail(recipeId: Int)

    /// 요약 레시피 생성 요청
    /// - Parameter recipeId: 요약을 생성할 레시피 ID
    /// - Note:
    ///   - 서버가 아직 미구현이거나 500/빈 바디로 내려올 수 있다.
    ///   - 서비스/뷰모델에서 실패 시 더미 스텝을 주입하는 fallback 로직 ( 아직구현 안돼서 !) 
    case recipeSummary(recipeId: Int)

    /// 북마크 토글
    /// - Parameter recipeId: 북마크 상태를 변경할 레시피 ID
    /// - Note:
    ///   - 서버는 토글 결과로 isBookmarked를 내려준다.
    case toggleBookmark(recipeId: Int)

    /// 요리 완료 처리 + 평점 등록
    /// - Parameters:
    ///   - recipeId: 완료 처리할 레시피 ID
    ///   - rating: 사용자가 선택한 별점(1~5)
    /// - Note:
    ///   - query parameter로 rating을 전달한다.
    case completeRecipe(recipeId: Int, rating: Int)
}

// MARK: - TargetType
extension RecipeEndpoints: TargetType {

    // MARK: Base URL
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("잘못된 baseURL입니다.")
        }
        return url
    }

    // MARK: Path
    var path: String {
        switch self {
        case .searchRecipes:
            return "/search/recipes"
        case .recipeDetail(let recipeId):
            return "/recipes/\(recipeId)"
        case .recipeSummary(let recipeId):
            return "/recipes/\(recipeId)/summary"
        case .toggleBookmark(let recipeId):
            return "/recipes/\(recipeId)/bookmark"
        case .completeRecipe(let recipeId, _):
            return "/recipes/\(recipeId)/complete"
        }
    }

    // MARK: HTTP Method
    var method: Moya.Method {
        switch self {
        case .searchRecipes, .recipeDetail:
            return .get
        case .recipeSummary, .toggleBookmark, .completeRecipe:
            return .post
        }
    }

    // MARK: Task (Parameters / Body)
    var task: Task {
        switch self {
        case .searchRecipes(let categoryId, let page, let size):
            var params: [String: Any] = [
                "categoryId": categoryId
            ]
            if let page {
                params["page"] = page
            }
            if let size {
                params["size"] = size
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .recipeDetail:
            return .requestPlain

        case .recipeSummary:
            // 바디 없이 호출
            return .requestPlain

        case .toggleBookmark:
            // 바디 없이 호출
            return .requestPlain

        case .completeRecipe(_, let rating):
            return .requestParameters(
                parameters: ["rating": rating],
                encoding: URLEncoding.queryString
            )
        }
    }

    // MARK: Headers
    var headers: [String: String]? {
        let contentTypeHeader: [String: String] = ["Content-Type": "application/json"]

        // 1) Keychain에 저장된 Access Token 우선 사용
        if let accessToken = KeychainSwift().get("serverAccessToken")?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !accessToken.isEmpty {

            #if DEBUG
            print("[RecipeEndpoints] ✅ Using Keychain token")
            #endif

            return contentTypeHeader.merging(["Authorization": "Bearer \(accessToken)"]) { $1 }
        }

        // 2) 개발 편의용 fallback (DEBUG에서만 Config.accessTK 사용)
        #if DEBUG
        let fallback = Config.accessTK.trimmingCharacters(in: .whitespacesAndNewlines)

        // 치환 실패하면 보통 '$(ACCESS_TOKEN)' 형태의 문자열이 그대로 남는다.
        if fallback.contains("$(") {
            print("[RecipeEndpoints] ❌ ACCESS_TOKEN substitution failed: \(fallback)")
        } else if !fallback.isEmpty {
            print("[RecipeEndpoints] ⚠️ Keychain token not found. Using Config.accessTK for DEBUG.")
            return contentTypeHeader.merging(["Authorization": "Bearer \(fallback)"]) { $1 }
        } else {
            print("[RecipeEndpoints] ❌ Config.accessTK is empty. Check Info.plist/xcconfig injection.")
        }
        #endif

        // 3) 로그인 전/토큰 없음: Content-Type만 유지
        return contentTypeHeader
    }

    // MARK: Sample Data
    var sampleData: Data {
        // Unit Test용 샘플데이터
        return Data()
    }
}
