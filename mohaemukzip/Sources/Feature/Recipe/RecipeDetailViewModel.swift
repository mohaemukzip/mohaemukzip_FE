//
// MARK: - RecipeDetailViewModel
// 레시피 상세 화면(RecipeDetailView)을 위한 전용 ViewModel
// 목록 화면용 ViewModel과 분리되어 있지만, 동일한 RecipeVideo 모델을 사용함

//  RecipeDetailViewModel.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/23/26.
//

import Foundation
import Combine

// MARK: - 북마크 처리 서비스 정의

/// 레시피 북마크 상태를 서버에 반영하기 위한 인터페이스
/// 서버에서는 최종 북마크 상태(true/false)를 반환해야 함
protocol RecipeBookmarkServicing {
    func setBookmark(recipeId: Int, isBookmarked: Bool) async throws -> Bool
}

/// 실제 API 연동 전까지 사용하는 더미 북마크 서비스
/// 항상 전달받은 상태 그대로 반환함
struct RecipeBookmarkServiceStub: RecipeBookmarkServicing {
    func setBookmark(recipeId: Int, isBookmarked: Bool) async throws -> Bool {
        // TODO: Replace with real network request
        return isBookmarked
    }
}


@MainActor
final class RecipeDetailViewModel: ObservableObject {

    // MARK: - 상태 값 (View에서 구독)

    /// 현재 상세 화면에서 보여줄 레시피 데이터
    @Published private(set) var recipe: RecipeVideo?
    /// 상세 정보 로딩 여부
    @Published private(set) var isLoading: Bool = false
    /// 에러 발생 시 사용자에게 보여줄 메시지
    @Published private(set) var errorMessage: String?
    /// 북마크 요청 중복 방지를 위한 처리 상태
    @Published private(set) var isBookmarkUpdating: Bool = false

    // MARK: - 초기화

    private let bookmarkService: RecipeBookmarkServicing

    init(
        recipe: RecipeVideo? = nil,
        bookmarkService: RecipeBookmarkServicing = RecipeBookmarkServiceStub()
    ) {
        self.recipe = recipe
        self.bookmarkService = bookmarkService
    }

    // MARK: - 외부에서 호출하는 기능

    /// 상세 화면 진입 시 호출
    /// - recipeId: 상세 조회할 레시피 ID (Path Variable)
    /// - base: 목록 화면에서 전달받은 기본 레시피 정보 (선택)
    ///         없을 경우 최소 정보만으로 더미 데이터 구성
    func load(recipeId: Int, base: RecipeVideo? = nil) {
        isLoading = true
        errorMessage = nil

        // TODO: API 연동 전까지는 더미 데이터로 상세 화면 구성
        // 이후에는 GET /recipes/{recipeId} 호출 → DTO 매핑 로직으로 교체 예정
        let detail = makeDummyDetailVideo(recipeId: recipeId, base: base)

        recipe = detail
        isLoading = false
    }

    /// 상세 화면에서 북마크 버튼 클릭 시 호출
    /// - Note: 현재는 더미 서비스가 즉시 성공을 반환함
    ///         API 연동 시 bookmarkService 구현체만 교체하면 됨
    func toggleBookmark() {
        guard !isBookmarkUpdating else { return }
        guard let current = recipe else { return }

        let recipeId = current.id
        let previousState = current.isBookmarked
        let optimisticState = !previousState

        // 서버 응답을 기다리지 않고 UI를 먼저 갱신 (Optimistic Update)
        updateBookmarkState(optimisticState)
        isBookmarkUpdating = true

        Task {
            do {
                let serverState = try await bookmarkService.setBookmark(
                    recipeId: recipeId,
                    isBookmarked: optimisticState
                )
                await MainActor.run {
                    self.updateBookmarkState(serverState)
                    self.isBookmarkUpdating = false
                }
            } catch {
                await MainActor.run {
                    // 실패 시 이전 북마크 상태로 되돌림
                    self.updateBookmarkState(previousState)
                    self.isBookmarkUpdating = false
                    self.errorMessage = "북마크 처리에 실패했습니다. 네트워크 상태를 확인해주세요."
                }
            }
        }
    }

    /// 현재 recipe의 북마크 상태만 안전하게 갱신
    private func updateBookmarkState(_ isBookmarked: Bool) {
        guard var current = recipe else { return }
        current.isBookmarked = isBookmarked
        recipe = current
    }

    // MARK: - 더미 상세 데이터 생성

    /// API 연동 전까지 상세 화면을 구성하기 위한 더미 레시피 생성
    /// 목록 화면에서 전달받은 base 데이터가 있으면 최대한 재사용함
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

        // base 값이 있으면 목록에서 내려온 데이터(영상 길이, 난이도, 북마크 등)를 우선 사용
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
