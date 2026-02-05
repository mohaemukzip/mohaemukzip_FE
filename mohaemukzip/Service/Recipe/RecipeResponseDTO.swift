//
//  RecipeResponseDTO.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/4/26.
//

import Foundation

// MARK: - RecipeResponseDTO
// 레시피 도메인에서 사용하는 Response DTO 모음
//
// 서버 응답(JSON)을 그대로 매핑하기 위한 전용 구조체들이다.
// ViewModel이나 View에서는 이 DTO를 직접 사용하지 않고,
// Service 계층에서 RecipeModel로 변환해서 사용한다.
//
// 서버 필드명과 앱 내부 모델 필드명이 다른 경우가 많기 때문에
// 가능한 한 서버 명세에 맞게 그대로 정의한다.

enum RecipeResponseDTO {

    // MARK: - Common Wrapper
    /// 레시피 API 공통 응답 래퍼
    struct BaseResponse<T: Decodable>: Decodable {
        let isSuccess: Bool
        let code: String
        let message: String
        let result: T
    }

    // MARK: - Search Recipes
    /// 세부 카테고리별 레시피 목록 조회 응답
    /// GET /search/recipes
    struct SearchRecipesResponse: Decodable {

        /// 레시피 목록
        /// 서버 응답 키: recipeList
        let recipeList: [RecipeSummary]

        /// 페이지 정보
        let listSize: Int
        let totalPage: Int
        let totalElements: Int
        let isFirst: Bool
        let isLast: Bool
    }

    /// 목록 화면에서 사용하는 레시피 요약 정보
    struct RecipeSummary: Decodable {

        /// 레시피 ID
        /// 서버 응답 키: id
        let id: Int

        /// 레시피 제목
        let title: String

        /// 썸네일 이미지 URL
        /// - NOTE: 목록 API에서는 내려오지 않을 수 있어 optional 처리
        let imageUrl: String?

        /// 채널명
        /// 서버 응답 키: channelName
        let channelName: String

        /// 조회수
        /// 서버 응답 키: viewCount
        let viewCount: Int

        /// 유튜브 영상 ID
        let videoId: String

        /// 채널 ID
        let channelId: String?

        /// 영상 재생 시간 문자열 (예: "09:38")
        let videoDuration: String?

        /// 요리 소요 시간 (분 단위)
        let cookingTimeMinutes: Int

        /// 난이도
        /// 서버 응답 키: difficulty (Double)
        let difficulty: Double?

        /// 북마크 여부
        let isBookmarked: Bool

        /// 채널 프로필 이미지 URL
        /// - NOTE: 목록 API에서는 내려오지 않을 수 있어 optional 처리
        let channelProfileImageUrl: String?
    }

    // MARK: - Recipe Detail
    /// 레시피 상세 조회 응답
    /// GET /recipes/{recipeId}
    struct RecipeDetailResponse: Decodable {

        let recipeId: Int
        let title: String
        let imageUrl: String?
        let videoUrl: String?
        let channel: String
        let channelId: String?
        let cookingTimeMinutes: Int
        let videoDuration: String?
        let views: Int
        let videoId: String
        let difficulty: Double
        let ratingCount: Int
        let channelProfileImageUrl: String?
        let isBookmarked: Bool

        /// 재료 목록
        let ingredients: [IngredientResponse]

        /// 요약 레시피 존재 여부
        let summaryExists: Bool

        /// 조리 단계 목록
        let steps: [StepResponse]
    }

    struct IngredientResponse: Decodable {
        let ingredientId: Int
        let name: String
        let amount: Double
        let unit: String
        let hasIngredient: Bool
    }

    struct StepResponse: Decodable {
        let stepNumber: Int
        let title: String
        let description: String

        /// 해당 조리 단계가 시작되는 영상 시점
        /// 서버 명세상 String으로 내려오기 때문에 String으로 받는다.
        let videoTime: String
    }

    // MARK: - Bookmark Toggle
    /// 북마크 토글 응답
    /// POST /recipes/{recipeId}/bookmark
    struct BookmarkToggleResponse: Decodable {
        let isBookmarked: Bool
        let message: String
    }

    // MARK: - Recipe Summary
    /// 요약 레시피 생성 응답
    /// POST /recipes/{recipeId}/summary
    struct RecipeSummaryGenerateResponse: Decodable {
        let summaryExists: Bool
        let stepCount: Int
    }

    // MARK: - Complete Recipe
    /// 요리 완료 처리 응답
    /// POST /recipes/{recipeId}/complete
    struct CompleteRecipeResponse: Decodable {
        let cookingRecordId: Int
        let recipeId: Int
        let rating: Int
        let recipeLevel: Double
        let ratingCount: Int
        let rewardScore: Int
        let leveledUp: Bool
    }
}
