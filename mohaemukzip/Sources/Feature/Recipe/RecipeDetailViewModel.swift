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

    private let service: RecipeService

    /// 서비스 주입용 init
    /// - Note:
    ///   - Swift 6에서는 기본 파라미터로 `RecipeService()`를 생성하면
    ///     nonisolated 컨텍스트에서 MainActor init을 호출하는 에러가 날 수 있다.
    init(
        recipe: RecipeVideo? = nil,
        service: RecipeService
    ) {
        self.recipe = recipe
        self.service = service
    }

    /// 기본 생성용 init
    /// - Note:
    ///   - RecipeService() 생성은 MainActor에서만 수행한다.
    @MainActor
    convenience init(recipe: RecipeVideo? = nil) {
        self.init(recipe: recipe, service: RecipeService())
    }

    // MARK: - 외부에서 호출하는 기능

    /// 상세 화면 진입 시 호출
    /// - recipeId: 상세 조회할 레시피 ID (Path Variable)
    /// - base: 목록 화면에서 전달받은 기본 레시피 정보 (선택)
    ///         없을 경우 최소 정보만으로 더미 데이터 구성
    func load(recipeId: Int, base: RecipeVideo? = nil) {
        isLoading = true
        errorMessage = nil

        // 목록에서 전달된 base가 있으면, 네트워크 로딩 동안 화면에 먼저 보여준다.
        if let base {
            recipe = base
        }

        Task {
            do {
                let categoryId = categoryId(from: base)
                var detail = try await service.fetchRecipeDetail(
                    recipeId: recipeId,
                    categoryId: categoryId
                )

                // summary API가 미구현/500/빈 바디일 수 있어 별도로 확인한다.
                // 실패 시에는 고정 더미 스텝 규칙을 적용한다.
                let summary = await service.generateSummary(recipeId: recipeId)

                if summary.summaryExists {
                    // 상세 API에서 steps가 비어있으면 fallback steps를 주입한다.
                    if detail.steps == nil || detail.steps?.isEmpty == true {
                        detail = RecipeVideo(
                            id: detail.id,
                            title: detail.title,
                            videoUrl: detail.videoUrl,
                            videoId: detail.videoId,
                            channelId: detail.channelId,
                            videoDuration: detail.videoDuration,
                            channelName: detail.channelName,
                            viewCount: detail.viewCount,
                            cookingTimeMinutes: detail.cookingTimeMinutes,
                            difficulty: detail.difficulty,
                            level: detail.level,
                            ratingCount: detail.ratingCount,
                            ingredients: detail.ingredients,
                            steps: makeFallbackSummarySteps(),
                            summaryExists: true,
                            cuisine: detail.cuisine,
                            koreanSubCategory: detail.koreanSubCategory,
                            chineseSubCategory: detail.chineseSubCategory,
                            japaneseSubCategory: detail.japaneseSubCategory,
                            westernSubCategory: detail.westernSubCategory,
                            southeastAsianSubCategory: detail.southeastAsianSubCategory,
                            isBookmarked: detail.isBookmarked,
                            channelProfileImageUrl: detail.channelProfileImageUrl
                        )
                    }
                }

                self.recipe = detail
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = "레시피 상세를 불러오지 못했습니다."
            }
        }
    }

    /// 상세 화면에서 북마크 버튼 클릭 시 호출
    /// - Note: 서버에 북마크 토글 요청을 보낸다.
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
                let serverState = try await service.toggleBookmark(recipeId: recipeId)
                self.updateBookmarkState(serverState)
                self.isBookmarkUpdating = false
            } catch {
                // 실패 시 이전 북마크 상태로 되돌림
                self.updateBookmarkState(previousState)
                self.isBookmarkUpdating = false
                self.errorMessage = "북마크 처리에 실패했습니다. 네트워크 상태를 확인해주세요."
            }
        }
    }

    /// 현재 recipe의 북마크 상태만 안전하게 갱신
    private func updateBookmarkState(_ isBookmarked: Bool) {
        guard var current = recipe else { return }
        current.isBookmarked = isBookmarked
        recipe = current
    }

    // MARK: - CategoryId Mapping

    /// 상세 API에는 categoryId가 없어서, 목록에서 전달된 base를 기준으로 categoryId를 복원한다.
    private func categoryId(from base: RecipeVideo?) -> Int? {
        guard let base else { return nil }

        switch base.cuisine {
        case .korean:
            guard let sub = base.koreanSubCategory else { return nil }
            switch sub {
            case .soupStew: return 1
            case .rice: return 2
            case .noodle: return 3
            case .stirFry: return 4
            case .braised: return 5
            case .pancake: return 6
            case .grill: return 7
            case .mixed: return 8
            case .sideDish: return 9
            case .kimchi: return 10
            }

        case .chinese:
            guard let sub = base.chineseSubCategory else { return nil }
            switch sub {
            case .noodle: return 11
            case .friedRice: return 12
            case .riceBowl: return 13
            case .stirFry: return 14
            case .deepFried: return 15
            case .soup: return 16
            case .mara: return 17
            case .meat: return 18
            case .seafood: return 19
            case .dumpling: return 20
            }

        case .japanese:
            guard let sub = base.japaneseSubCategory else { return nil }
            switch sub {
            case .riceBowl: return 21
            case .noodle: return 22
            case .soup: return 23
            case .stirFry: return 24
            case .braised: return 25
            case .deepFried: return 26
            case .grill: return 27
            case .lunchBox: return 28
            case .seafood: return 29
            case .egg: return 30
            }

        case .western:
            guard let sub = base.westernSubCategory else { return nil }
            switch sub {
            case .pasta: return 31
            case .risotto: return 32
            case .stirFry: return 33
            case .steak: return 34
            case .oven: return 35
            case .salad: return 36
            case .soup: return 37
            case .brunch: return 38
            case .pizza: return 39
            case .cheese: return 40
            }

        case .southeastAsian:
            guard let sub = base.southeastAsianSubCategory else { return nil }
            switch sub {
            case .rice: return 41
            case .riceNoodle: return 42
            case .noodle: return 43
            case .soup: return 44
            case .stirFry: return 45
            case .deepFried: return 46
            case .curry: return 47
            case .meat: return 48
            case .seafood: return 49
            case .salad: return 50
            }
        }
    }

    // MARK: - Summary Fallback

    /// 요약 생성 API가 실패했을 때 사용할 고정 스텝 더미 데이터
    /// - Rule:
    ///   - summaryExists = true
    ///   - stepCount = 4 고정
    ///   - title/description = "서버에서 아직 개발중 ㅠㅠ 화이팅 "
    ///   - timestamp = 1:00, 1:30, 2:00, 2:30
    private func makeFallbackSummarySteps() -> [RecipeStep] {
        let title = "서버에서 아직 개발중 ㅠㅠ 화이팅 "
        let description = "서버에서 아직 개발중 ㅠㅠ 화이팅 "

        // 1:00, 1:30, 2:00, 2:30
        let times: [Int] = [60, 90, 120, 150]

        return times.enumerated().map { index, seconds in
            RecipeStep(
                stepNumber: index + 1,
                title: title,
                description: description,
                videoTime: seconds
            )
        }
    }
}
