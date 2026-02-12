import Foundation
import Moya
import Alamofire


/// 레시피 관련 API
/// 네트워크 요청 → DTO 디코딩 → 앱 모델 변환 역할 수행
/// 목록 / 상세 / 요약 / 북마크 / 요리 완료 API 포함

final class RecipeService {

    /// 앱 전역에서 공유되는 단일 인스턴스
    static let shared = RecipeService()

    /// RecipeEndpoints 전용 Moya Provider
    private let provider: MoyaProvider<RecipeEndpoints>

    /// RecipeService 초기화
    /// 공통 NetworkManager Provider 사용
    init(provider: MoyaProvider<RecipeEndpoints>? = nil) {
        self.provider = provider ?? NetworkManager.shared.makeProvider(for: RecipeEndpoints.self)
    }

    // MARK: - Public APIs

    /// 카테고리 기준 레시피 목록 조회
    /// 서버 응답 DTO를 RecipeVideo 모델 배열로 변환
    /// categoryId 기반으로 cuisine / subCategory 매핑
    func fetchRecipes(
        categoryId: Int,
        page: Int? = nil,
        size: Int? = nil
    ) async throws -> [RecipeVideo] {
        let response = try await request(
            RecipeEndpoints.searchRecipes(categoryId: categoryId, page: page, size: size),
            as: RecipeResponseDTO.SearchRecipesResponse.self
        )

        let category = mapCategory(categoryId: categoryId)

        return response.recipeList.map {
            mapRecipeSummaryToModel($0, category: category)
        }
    }

    /// 레시피 상세 정보 조회
    /// 상세 API 응답을 RecipeVideo 모델로 변환
    /// 목록에서 전달된 categoryId가 있으면 카테고리 보정
    func fetchRecipeDetail(
        recipeId: Int,
        categoryId: Int? = nil
    ) async throws -> RecipeVideo {
        let response = try await request(
            RecipeEndpoints.recipeDetail(recipeId: recipeId),
            as: RecipeResponseDTO.RecipeDetailResponse.self
        )

        let category = mapCategory(categoryId: categoryId)
        return mapRecipeDetailToModel(response, category: category)
    }

    /// 요약 레시피 생성 요청
    /// - Note: 실패를 성공처럼 처리하지 않는다. (중복 호출/더미 스텝 주입 원인)
    ///         실패 시 (false, 0)을 반환하고, 상위(ViewModel)에서 UI 상태(요약 생성 중/실패)를 처리한다.
    func generateSummary(
        recipeId: Int
    ) async -> (summaryExists: Bool, stepCount: Int) {
        do {
            let response = try await request(
                RecipeEndpoints.recipeSummary(recipeId: recipeId),
                as: RecipeResponseDTO.RecipeSummaryGenerateResponse.self
            )
            return (response.summaryExists, response.stepCount)
        } catch {
            #if DEBUG
            print("[RecipeService] SUMMARY GENERATE ❌ recipeId=\(recipeId) error=\(error)")
            #endif
            return (false, 0)
        }
    }

    /// 레시피 북마크 상태 토글
    /// 서버 기준 토글 결과 반환
    func toggleBookmark(recipeId: Int) async throws -> Bool {
        let response = try await request(
            RecipeEndpoints.toggleBookmark(recipeId: recipeId),
            as: RecipeResponseDTO.BookmarkToggleResponse.self
        )
        return response.isBookmarked
    }

    /// 요리 완료 처리 및 평점 등록
    /// rating 값은 1~5 범위로 보정 후 전송
    func completeRecipe(
        recipeId: Int,
        rating: Int
    ) async throws -> RecipeResponseDTO.CompleteRecipeResponse {
        let safeRating = max(1, min(5, rating))
        let target = RecipeEndpoints.completeRecipe(recipeId: recipeId, rating: safeRating)

        #if DEBUG
        print("[RecipeService] COMPLETE ▶️ recipeId=\(recipeId) rating=\(safeRating)")
        #endif

        do {
            let response = try await request(
                target,
                as: RecipeResponseDTO.CompleteRecipeResponse.self
            )

            #if DEBUG
            print("[RecipeService] COMPLETE ✅ recipeId=\(recipeId) rating=\(safeRating) cookingRecordId=\(response.cookingRecordId) reward=\(response.rewardScore) leveledUp=\(response.leveledUp)")
            #endif

            return response
        } catch {
            #if DEBUG
            print("[RecipeService] COMPLETE ❌ recipeId=\(recipeId) rating=\(safeRating) error=\(error)")
            #endif
            throw error
        }
    }

    // MARK: - Mapping Helpers
    /// 서버 categoryId 및 DTO를 앱 내부 모델로 변환하는 헬퍼

    /// categoryId를 앱 내부 카테고리 구조로 변환
    /// 상위 cuisine + 해당 하위 카테고리 매핑
    /// categoryId가 없으면 기본값 반환
    private func mapCategory(
        categoryId: Int?
    ) -> MappedCategory {
        guard let categoryId else {
            return MappedCategory(
                cuisine: .korean,
                korean: nil,
                chinese: nil,
                japanese: nil,
                western: nil,
                southeastAsian: nil
            )
        }

        switch categoryId {
        // 한식 1~10
        case 1: return .init(cuisine: .korean, korean: .soupStew)
        case 2: return .init(cuisine: .korean, korean: .rice)
        case 3: return .init(cuisine: .korean, korean: .noodle)
        case 4: return .init(cuisine: .korean, korean: .stirFry)
        case 5: return .init(cuisine: .korean, korean: .braised)
        case 6: return .init(cuisine: .korean, korean: .pancake)
        case 7: return .init(cuisine: .korean, korean: .grill)
        case 8: return .init(cuisine: .korean, korean: .mixed)
        case 9: return .init(cuisine: .korean, korean: .sideDish)
        case 10: return .init(cuisine: .korean, korean: .kimchi)

        // 중식 11~20
        case 11: return .init(cuisine: .chinese, chinese: .noodle)
        case 12: return .init(cuisine: .chinese, chinese: .friedRice)
        case 13: return .init(cuisine: .chinese, chinese: .riceBowl)
        case 14: return .init(cuisine: .chinese, chinese: .stirFry)
        case 15: return .init(cuisine: .chinese, chinese: .deepFried)
        case 16: return .init(cuisine: .chinese, chinese: .soup)
        case 17: return .init(cuisine: .chinese, chinese: .mara)
        case 18: return .init(cuisine: .chinese, chinese: .meat)
        case 19: return .init(cuisine: .chinese, chinese: .seafood)
        case 20: return .init(cuisine: .chinese, chinese: .dumpling)

        // 일식 21~30
        case 21: return .init(cuisine: .japanese, japanese: .riceBowl)
        case 22: return .init(cuisine: .japanese, japanese: .noodle)
        case 23: return .init(cuisine: .japanese, japanese: .soup)
        case 24: return .init(cuisine: .japanese, japanese: .stirFry)
        case 25: return .init(cuisine: .japanese, japanese: .braised)
        case 26: return .init(cuisine: .japanese, japanese: .deepFried)
        case 27: return .init(cuisine: .japanese, japanese: .grill)
        case 28: return .init(cuisine: .japanese, japanese: .lunchBox)
        case 29: return .init(cuisine: .japanese, japanese: .seafood)
        case 30: return .init(cuisine: .japanese, japanese: .egg)

        // 양식 31~40
        case 31: return .init(cuisine: .western, western: .pasta)
        case 32: return .init(cuisine: .western, western: .risotto)
        case 33: return .init(cuisine: .western, western: .stirFry)
        case 34: return .init(cuisine: .western, western: .steak)
        case 35: return .init(cuisine: .western, western: .oven)
        case 36: return .init(cuisine: .western, western: .salad)
        case 37: return .init(cuisine: .western, western: .soup)
        case 38: return .init(cuisine: .western, western: .brunch)
        case 39: return .init(cuisine: .western, western: .pizza)
        case 40: return .init(cuisine: .western, western: .cheese)

        // 동남아 41~50
        case 41: return .init(cuisine: .southeastAsian, southeastAsian: .rice)
        case 42: return .init(cuisine: .southeastAsian, southeastAsian: .riceNoodle)
        case 43: return .init(cuisine: .southeastAsian, southeastAsian: .noodle)
        case 44: return .init(cuisine: .southeastAsian, southeastAsian: .soup)
        case 45: return .init(cuisine: .southeastAsian, southeastAsian: .stirFry)
        case 46: return .init(cuisine: .southeastAsian, southeastAsian: .deepFried)
        case 47: return .init(cuisine: .southeastAsian, southeastAsian: .curry)
        case 48: return .init(cuisine: .southeastAsian, southeastAsian: .meat)
        case 49: return .init(cuisine: .southeastAsian, southeastAsian: .seafood)
        case 50: return .init(cuisine: .southeastAsian, southeastAsian: .salad)

        default:
            return MappedCategory(
                cuisine: .korean,
                korean: nil,
                chinese: nil,
                japanese: nil,
                western: nil,
                southeastAsian: nil
            )
        }
    }

    /// 목록 응답 DTO를 RecipeVideo 모델로 변환
    /// 상세 정보는 비워두고 목록 표시용 필드만 채움
    private func mapRecipeSummaryToModel(
        _ dto: RecipeResponseDTO.RecipeSummary,
        category: MappedCategory
    ) -> RecipeVideo {
        RecipeVideo(
            id: dto.id,
            title: dto.title,
            videoUrl: nil,
            videoId: dto.videoId,
            channelId: dto.channelId,
            videoDuration: dto.videoDuration,
            channelName: dto.channelName,
            viewCount: dto.viewCount,
            cookingTimeMinutes: dto.cookingTimeMinutes,
            difficulty: dto.difficulty.map { Int($0.rounded()) },
            level: nil,
            ratingCount: nil,
            ingredients: nil,
            steps: nil,
            summaryExists: nil,
            cuisine: category.cuisine,
            koreanSubCategory: category.korean,
            chineseSubCategory: category.chinese,
            japaneseSubCategory: category.japanese,
            westernSubCategory: category.western,
            southeastAsianSubCategory: category.southeastAsian,
            isBookmarked: dto.isBookmarked,
            channelProfileImageUrl: dto.channelProfileImageUrl
        )
    }

    /// 상세 응답 DTO를 RecipeVideo 모델로 변환
    /// 재료 / 스텝 / 요약 여부까지 포함
    private func mapRecipeDetailToModel(
        _ dto: RecipeResponseDTO.RecipeDetailResponse,
        category: MappedCategory
    ) -> RecipeVideo {

        let ingredients: [RecipeIngredient] = dto.ingredients.map {
            RecipeIngredient(
                id: $0.ingredientId,
                name: $0.name,
                amount: $0.amount,
                unit: $0.unit,
                hasIngredient: $0.hasIngredient
            )
        }

        let steps: [RecipeStep] = dto.steps.map {
            RecipeStep(
                stepNumber: $0.stepNumber,
                title: $0.title,
                description: $0.description,
                videoTime: parseVideoTimeToSeconds($0.videoTime)
            )
        }

        return RecipeVideo(
            id: dto.recipeId,
            title: dto.title,
            videoUrl: dto.videoUrl,
            videoId: dto.videoId,
            channelId: dto.channelId,
            videoDuration: dto.videoDuration,
            channelName: dto.channel,
            viewCount: dto.views,
            cookingTimeMinutes: dto.cookingTimeMinutes,
            difficulty: Int(dto.difficulty.rounded()),
            level: nil,
            ratingCount: dto.ratingCount,
            ingredients: ingredients,
            steps: steps,
            summaryExists: dto.summaryExists,
            cuisine: category.cuisine,
            koreanSubCategory: category.korean,
            chineseSubCategory: category.chinese,
            japaneseSubCategory: category.japanese,
            westernSubCategory: category.western,
            southeastAsianSubCategory: category.southeastAsian,
            isBookmarked: dto.isBookmarked,
            channelProfileImageUrl: dto.channelProfileImageUrl
        )
    }

    /// (Legacy) 과거 요약 실패 시 더미 스텝을 만들던 헬퍼
    /// 현재 정책: 더미 스텝을 주입하지 않고, 요약 생성 완료 후 상세 재조회로 steps를 채운다.
    func makeFallbackSteps(stepCount: Int = 6) -> [RecipeStep] {
        let count = max(1, stepCount)

        // 모든 레시피에 동일하게 적용되는 기본 패턴
        // videoTime은 0, 30, 60, ... 형태로 증가시킨다.
        return (1...count).map { idx in
            RecipeStep(
                stepNumber: idx,
                title: "Step \(idx)",
                description: "요리 단계 \(idx) 설명입니다.",
                videoTime: (idx - 1) * 30
            )
        }
    }

    /// 영상 타임스탬프 문자열을 초 단위 Int로 변환
    /// mm:ss / hh:mm:ss / ss 형식 대응
    private func parseVideoTimeToSeconds(_ raw: String) -> Int {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // 숫자만 오는 경우
        if let seconds = Int(trimmed) {
            return max(0, seconds)
        }

        // mm:ss / hh:mm:ss 형태 대응
        let parts = trimmed.split(separator: ":").map { String($0) }
        guard !parts.isEmpty else {
            return 0
        }

        var seconds = 0
        for part in parts {
            seconds *= 60
            seconds += Int(part) ?? 0
        }
        return max(0, seconds)
    }

    // MARK: - Request Helpers
    /// Moya 요청을 async/await 형태로 래핑
    /// 공통 BaseResponse 디코딩 로직 사용

    /// 공통 네트워크 요청 처리 함수
    /// Moya Response를 Decodable 타입으로 변환
    private func request<T: Decodable>(
        _ target: RecipeEndpoints,
        as type: T.Type
    ) async throws -> T {
        #if DEBUG
        debugLogRequest(target)
        #endif

        let response = try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        #if DEBUG
        debugLogResponse(target, response: response)
        #endif

        do {
            // 공통 BaseResponse(result) 매핑 로직 사용
            return try response.mapResult(T.self)
        } catch {
            #if DEBUG
            debugLogDecodingError(target, response: response, error: error)
            #endif
            throw RecipeServiceError.decodingFailed(error)
        }
    }

    // MARK: - Debug Logs
    /// DEBUG 환경에서만 네트워크 요청/응답 로그 출력

#if DEBUG
    private func debugLogRequest(_ target: RecipeEndpoints) {
        let method = target.method.rawValue
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
        print("[RecipeService] REQUEST \(method) \(url)")

        if let headers = target.headers {
            let masked = headers.mapValues { value -> String in
                if value.lowercased().contains("bearer ") {
                    return "Bearer \(value.dropFirst(min(value.count, 18)))..."
                }
                return value
            }
            print("[RecipeService] HEADERS: \(masked)")
        }

        switch target.task {
        case .requestParameters(let parameters, _):
            print("[RecipeService] PARAMS: \(parameters)")
        case .requestJSONEncodable(let encodable):
            print("[RecipeService] BODY: \(encodable)")
        default:
            break
        }
    }

    private func debugLogResponse(_ target: RecipeEndpoints, response: Response) {
        let method = response.request?.httpMethod ?? target.method.rawValue
        let actualUrl = response.request?.url?.absoluteString
        let fallbackUrl = target.baseURL.appendingPathComponent(target.path).absoluteString
        let url = actualUrl ?? fallbackUrl

        print("[RecipeService] RESPONSE \(method) \(url) status=\(response.statusCode) bytes=\(response.data.count)")

        if let bodyString = String(data: response.data, encoding: .utf8), !bodyString.isEmpty {
            // 너무 길면 앞부분만
            let prefix = String(bodyString.prefix(1200))
            print("[RecipeService] BODY(prefix): \(prefix)")
        }
    }

    private func debugLogDecodingError(_ target: RecipeEndpoints, response: Response, error: Error) {
        let method = response.request?.httpMethod ?? target.method.rawValue
        let actualUrl = response.request?.url?.absoluteString
        let fallbackUrl = target.baseURL.appendingPathComponent(target.path).absoluteString
        let url = actualUrl ?? fallbackUrl

        print("[RecipeService] DECODE FAIL \(method) \(url) status=\(response.statusCode)")
        print("[RecipeService] ERROR: \(error)")

        if let bodyString = String(data: response.data, encoding: .utf8), !bodyString.isEmpty {
            let prefix = String(bodyString.prefix(2000))
            print("[RecipeService] RAW(prefix): \(prefix)")
        }
    }
#endif
}

// MARK: - Supporting Types
/// RecipeService 내부에서 사용하는 보조 타입 정의

extension RecipeService {

    /// categoryId 변환 결과를 묶어 전달하기 위한 컨테이너
    /// 상위 cuisine + 하위 카테고리 Enum 조합
    struct MappedCategory {
        let cuisine: CuisineCategory
        let korean: KoreanSubCategory?
        let chinese: ChineseSubCategory?
        let japanese: JapaneseSubCategory?
        let western: WesternSubCategory?
        let southeastAsian: SoutheastAsianSubCategory?

        init(
            cuisine: CuisineCategory,
            korean: KoreanSubCategory? = nil,
            chinese: ChineseSubCategory? = nil,
            japanese: JapaneseSubCategory? = nil,
            western: WesternSubCategory? = nil,
            southeastAsian: SoutheastAsianSubCategory? = nil
        ) {
            self.cuisine = cuisine
            self.korean = korean
            self.chinese = chinese
            self.japanese = japanese
            self.western = western
            self.southeastAsian = southeastAsian
        }
    }

    /// RecipeService 전용 에러 타입
    enum RecipeServiceError: Error {
        case decodingFailed(Error)
    }
}
