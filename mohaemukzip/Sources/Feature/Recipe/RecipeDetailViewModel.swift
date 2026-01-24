//
//MARK: - 중요 !!! RecipeViewModel > RecipeListView 를 위한 뷰모델, RecipeDetailViewModel > RecipeDetailView를 위한 뷰모델 두개 분리 ! but
//MARK: - 두 viewModel이 같은 모델 사용함 ~~~~~~~

//  RecipeDetailViewModel.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/23/26.
//

import Foundation
import Combine

//
//  RecipeDetailViewModel.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/23/26.
//

import Foundation

@MainActor
final class RecipeDetailViewModel: ObservableObject {

    // MARK: - Published

    @Published private(set) var recipe: RecipeVideo?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Init

    init(recipe: RecipeVideo? = nil) {
        self.recipe = recipe
    }

    // MARK: - Public

    /// 상세 화면 진입 시 호출
    /// - Parameters:
    ///   - recipeId: Path variable
    ///   - base: 목록에서 가져온 기본 정보(선택). 없으면 최소 정보로 구성
    func load(recipeId: Int, base: RecipeVideo? = nil) {
        isLoading = true
        errorMessage = nil

        // TODO: API 연동 전까지는 더미 데이터로 상세 필드 채우기
        // 이후에는 RecipeDetailService에서 GET /recipes/{recipeId} 호출 -> DTO -> RecipeVideo 매핑
        let detail = makeDummyDetailVideo(recipeId: recipeId, base: base)

        recipe = detail
        isLoading = false
    }

    /// 북마크 토글 (상세 화면)
    func toggleBookmark() {
        guard var current = recipe else { return }
        current.isBookmarked.toggle()
        recipe = current

        // TODO: 북마크 API가 있으면 여기에서 호출
    }

    // MARK: - Dummy Builder

    private func makeDummyDetailVideo(recipeId: Int, base: RecipeVideo?) -> RecipeVideo {
        let ingredients: [RecipeIngredient] = [
            RecipeIngredient(id: 3, name: "돼지고기", amount: 400.0, unit: "g", hasIngredient: true),
            RecipeIngredient(id: 7, name: "양배추", amount: 1.0, unit: "개", hasIngredient: false),
            RecipeIngredient(id: 9, name: "양파", amount: 0.5, unit: "개", hasIngredient: true),
            RecipeIngredient(id: 11, name: "고추장", amount: 2.0, unit: "큰술", hasIngredient: true)
        ]

        let steps: [RecipeStep] = [
            RecipeStep(stepNumber: 1, title: "고기와 기본 재료 준비하기", description: "돼지고기와 채소를 손질합니다.", videoTime: 304),
            RecipeStep(stepNumber: 2, title: "팬에 고기 볶기", description: "달군 팬에 고기를 볶습니다.", videoTime: 443),
            RecipeStep(stepNumber: 3, title: "양념 넣고 볶기", description: "양념을 넣고 1~2분 더 볶습니다.", videoTime: 650)
        ]

        // base가 있으면 목록에서 내려온 값(영상 길이, 난이도, 북마크 등)을 최대한 재사용
        return RecipeVideo(
            id: base?.id ?? recipeId,
            title: base?.title ?? "레시피 상세",
            videoUrl: base?.videoUrl, // 상세 API에서는 값이 들어올 수 있음
            videoId: base?.videoId ?? "sHpMVI8wQuk",
            channelId: base?.channelId,
            videoDuration: base?.videoDuration,
            channelName: base?.channelName ?? "채널명",
            viewCount: base?.viewCount ?? 0,
            cookingTimeMinutes: base?.cookingTimeMinutes ?? 15,
            difficulty: base?.difficulty,
            level: 3.0, // 상세 API의 level(Double) 예시
            ratingCount: 0,
            ingredients: ingredients,
            steps: steps,
            summaryExists: true,
            cuisine: base?.cuisine ?? .korean,
            koreanSubCategory: base?.koreanSubCategory,
            chineseSubCategory: base?.chineseSubCategory,
            japaneseSubCategory: base?.japaneseSubCategory,
            westernSubCategory: base?.westernSubCategory,
            southeastAsianSubCategory: base?.southeastAsianSubCategory,
            isBookmarked: base?.isBookmarked ?? false,
            channelProfileImageUrl: "https://picsum.photos/200"
        )
    }
}
