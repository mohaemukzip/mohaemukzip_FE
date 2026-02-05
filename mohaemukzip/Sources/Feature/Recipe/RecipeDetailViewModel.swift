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

    /// 요리 완료(평점 등록) 요청 중복 방지를 위한 처리 상태
    @Published private(set) var isCompletingCooking: Bool = false

    /// 요리 완료 성공 시, 화면 dismiss 트리거 (View에서 onChange로 감지)
    @Published var shouldDismissAfterComplete: Bool = false

    /// 마지막으로 전송한 별점(디버깅/필요 시 UI 표시용)
    @Published private(set) var lastSubmittedRating: Int?

    /// 요리 완료 결과(점수/레벨업 등) - 필요 시 UI에서 사용
    @Published private(set) var completeResult: RecipeResponseDTO.CompleteRecipeResponse?

    /// 요리 완료 응답의 레벨(소수)을 UI에서 쓰기 좋은 형태로 변환한 값
    /// - Note: 서버는 recipeLevel을 소수로 내려줄 수 있다(예: 3.666...).
    ///         UI에서는 반올림한 정수 레벨을 사용한다.
    var roundedRecipeLevel: Int? {
        guard let level = completeResult?.recipeLevel else { return nil }
        return Int(level.rounded())
    }

    /// 필요 시 소수 1자리까지 표현하는 레벨(예: 3.7)
    var recipeLevelOneDecimal: Double? {
        guard let level = completeResult?.recipeLevel else { return nil }
        return (level * 10).rounded() / 10
    }

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
        shouldDismissAfterComplete = false
        lastSubmittedRating = nil
        completeResult = nil

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
                // 실패 시에는 고정 더미 스텝 규칙(4개)을 적용한다.
                let summary = await service.generateSummary(recipeId: recipeId)
                let summaryExists = summary.summaryExists

                if summaryExists {
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

                // 서버 summaryExists를 모델에 반영 (steps가 이미 존재하더라도 표시 여부는 summaryExists를 따른다)
                if detail.summaryExists != summaryExists {
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
                        steps: detail.steps,
                        summaryExists: summaryExists,
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

                self.recipe = detail
                #if DEBUG
                print("[RecipeDetailVM] ✅ load success | recipeId=\(recipeId) title=\(detail.title) ingredients=\(detail.ingredients?.count ?? 0) steps=\(detail.steps?.count ?? 0) summaryExists=\(detail.summaryExists ?? false)")
                #endif
                self.isLoading = false
            } catch {
                #if DEBUG
                print("[RecipeDetailVM] ❌ load fail | recipeId=\(recipeId) error=\(error)")
                #endif
                self.isLoading = false
                self.errorMessage = "레시피 상세를 불러오지 못했습니다."
            }
        }
    }

    /// 상세 화면에서 북마크 버튼 클릭 시 호출
    /// - Note:
    ///   - 목록 화면과 동일하게 서버 응답 기준으로만 상태를 갱신한다.
    ///   - optimistic update를 제거하여 UI/상태 불일치를 방지한다.
    func toggleBookmark() {
        guard let current = recipe else {
            #if DEBUG
            print("[RecipeDetailVM] ❌ toggleBookmark ignored | recipe is nil")
            #endif
            return
        }

        // 중복 요청 방지 (리스트와 동일한 수준의 최소 제어)
        guard !isBookmarkUpdating else {
            #if DEBUG
            print("[RecipeDetailVM] ⚠️ toggleBookmark ignored | already updating")
            #endif
            return
        }

        let recipeId = current.id
        isBookmarkUpdating = true

        Task {
            do {
                let serverState = try await service.toggleBookmark(recipeId: recipeId)

                // 서버 응답 기준으로만 상태 반영
                self.updateBookmarkState(serverState)
                self.isBookmarkUpdating = false

                #if DEBUG
                print("[RecipeDetailVM] ✅ bookmark toggled | recipeId=\(recipeId) isBookmarked=\(serverState)")
                #endif
            } catch {
                self.isBookmarkUpdating = false
                self.errorMessage = "북마크 처리에 실패했습니다. 네트워크 상태를 확인해주세요."

                #if DEBUG
                print("[RecipeDetailVM] ❌ bookmark toggle fail | recipeId=\(recipeId) error=\(error)")
                #endif
            }
        }
    }

    /// 요리 완료(평점 등록) 버튼 클릭 시 호출
    /// - Parameters:
    ///   - rating: 사용자가 선택한 별점(1~5)
    /// - Note:
    ///   - 성공 시 completeResult에 서버 결과를 저장한다.
    func completeCooking(rating: Int) {
        guard !isCompletingCooking else { return }
        guard let current = recipe else { return }

        // 별점 범위 안전 처리
        let safeRating = max(1, min(5, rating))
        lastSubmittedRating = safeRating

        isCompletingCooking = true
        errorMessage = nil
        completeResult = nil

        Task {
            do {
                let result = try await service.completeRecipe(recipeId: current.id, rating: safeRating)
                self.completeResult = result
                self.isCompletingCooking = false
                self.shouldDismissAfterComplete = true

                #if DEBUG
                print("[RecipeDetailVM] ✅ complete success | recipeId=\(current.id) rating=\(safeRating) reward=\(result.rewardScore) leveledUp=\(result.leveledUp)")
                #endif
            } catch {
                self.isCompletingCooking = false
                self.shouldDismissAfterComplete = false
                self.errorMessage = "요리 완료 처리에 실패했습니다. 네트워크 상태를 확인해주세요."

                #if DEBUG
                print("[RecipeDetailVM] ❌ complete fail | recipeId=\(current.id) rating=\(safeRating) error=\(error)")
                #endif
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
        case .none:
            return nil
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
