//
//  RecipeService.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/4/26.
//

import Foundation
import Moya
import Alamofire

// MARK: - RecipeService
// 레시피 API 호출 + DTO -> RecipeModel 변환(매핑)을 담당한다.
//
// 역할
// 1) Moya Provider를 통해 RecipeEndpoints 요청을 수행한다.
// 2) 서버 JSON을 ResponseDTO로 디코딩한다.
// 3) 화면에서 사용하는 RecipeModel(RecipeVideo 등)로 변환한다.
// 4) 서버가 미구현/오류로 내려오는 summary API는 실패 시 더미 스텝 fallback 데이터를 만든다.

final class RecipeService {

    static let shared = RecipeService()

    // MARK: - Provider
    private let provider: MoyaProvider<RecipeEndpoints>

    /// - NOTE: ProfileService와 동일하게 프로젝트 공통 Provider 생성 로직을 사용한다.
    ///         (NetworkManager.shared.makeProvider + Response.mapResult)
    init(provider: MoyaProvider<RecipeEndpoints>? = nil) {
        self.provider = provider ?? NetworkManager.shared.makeProvider(for: RecipeEndpoints.self)
    }

    // MARK: - Public APIs

    /// 세부 카테고리별 레시피 목록 조회
    /// - Note:
    ///   - categoryId로 상위/하위 카테고리를 판별해서 RecipeModel의 cuisine/subCategory를 채운다.
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

    /// 레시피 상세 조회
    /// - Parameters:
    ///   - recipeId: 상세 레시피 ID
    ///   - categoryId: 목록에서 진입할 때 알고 있는 categoryId (없으면 nil)
    /// - Note:
    ///   - 상세 응답에는 카테고리 정보가 없기 때문에, categoryId를 받을 수 있으면 모델의 카테고리도 채운다.
    ///   - categoryId가 없다면 cuisine/subCategory는 기본값(.korean)으로 둔다.
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
    /// - Returns:
    ///   - summaryExists: 서버가 요약 레시피를 제공하는지 여부
    ///   - stepCount: 생성된/예상 스텝 개수
    /// - Note:
    ///   - 서버가 미구현/오류/빈 바디일 수 있으므로 실패하면 fallback 값을 반환한다.
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
            // 서버 미구현/오류 fallback
            return (true, 6)
        }
    }

    /// 북마크 토글
    /// - Returns: 토글 이후 서버 기준 북마크 상태
    func toggleBookmark(recipeId: Int) async throws -> Bool {
        let response = try await request(
            RecipeEndpoints.toggleBookmark(recipeId: recipeId),
            as: RecipeResponseDTO.BookmarkToggleResponse.self
        )
        return response.isBookmarked
    }

    /// 요리 완료 처리 + 평점 등록
    /// - Returns: 요리 완료 결과(점수/레벨업 등)
    func completeRecipe(
        recipeId: Int,
        rating: Int
    ) async throws -> RecipeResponseDTO.CompleteRecipeResponse {
        let response = try await request(
            RecipeEndpoints.completeRecipe(recipeId: recipeId, rating: rating),
            as: RecipeResponseDTO.CompleteRecipeResponse.self
        )
        return response
    }

    // MARK: - Mapping Helpers

    /// categoryId -> (상위 cuisine + 해당되는 하위 카테고리) 변환
    /// - Note:
    ///   - 서버는 categoryId만 내려주므로, 앱 내부 모델에 필요한 Enum으로 변환한다.
    ///   - categoryId가 nil이면 기본값(.korean, nil...)을 반환한다.
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

    /// 목록 DTO -> 모델 변환
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

    /// 상세 DTO -> 모델 변환
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
            difficulty: dto.difficulty,
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

    /// 요약 API 실패 시 사용할 더미 스텝 생성
    /// - Parameters:
    ///   - stepCount: 스텝 개수
    /// - Returns: RecipeStep 배열
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

    /// "mm:ss" 또는 "ss" 형태로 오는 videoTime을 초(Int)로 변환
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

    /// Moya request를 async/await 형태로 감싼다.
    /// - NOTE: ProfileService와 동일하게 `Response.mapResult(_:)`로 디코딩한다.
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

    #if DEBUG
    private func debugLogRequest(_ target: RecipeEndpoints) {
        let method = target.method.rawValue
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
        print("[RecipeService] REQUEST \(method) \(url)")

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
        let method = target.method.rawValue
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
        print("[RecipeService] RESPONSE \(method) \(url) status=\(response.statusCode) bytes=\(response.data.count)")

        if let bodyString = String(data: response.data, encoding: .utf8), !bodyString.isEmpty {
            // 너무 길면 앞부분만
            let prefix = String(bodyString.prefix(1200))
            print("[RecipeService] BODY(prefix): \(prefix)")
        }
    }

    private func debugLogDecodingError(_ target: RecipeEndpoints, response: Response, error: Error) {
        let method = target.method.rawValue
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
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

extension RecipeService {

    /// categoryId 변환 결과를 한 번에 들고 다니기 위한 컨테이너
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

    enum RecipeServiceError: Error {
        case decodingFailed(Error)
    }
}
