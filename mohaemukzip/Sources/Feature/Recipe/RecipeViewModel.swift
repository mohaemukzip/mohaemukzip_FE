// MARK: - RecipeVideoViewModel
// 레시피 목록 화면(RecipeListView)을 위한 전용 ViewModel
// API 연동 후에는 카테고리 선택 -> 목록 조회 -> 북마크 토글까지 이 ViewModel에서 담당한다.

import Foundation
import Combine

// MARK: - RecipeVideoViewModel

final class RecipeVideoViewModel: ObservableObject {

    // MARK: - Dependencies

    /// 레시피 API 호출 및 DTO -> 모델 변환을 담당하는 서비스
    private let service: RecipeService

    // MARK: - 카테고리 선택 상태 (View -> ViewModel)

    /// 선택된 상위 음식 카테고리 (한식 / 중식 / 일식 / 양식 / 동남아)
    @Published var selectedCuisine: CuisineCategory? = nil

    /// 선택된 하위 카테고리
    /// 상위 카테고리에 따라 하나의 값만 사용됨
    @Published var selectedKoreanSubCategory: KoreanSubCategory? = nil
    @Published var selectedChineseSubCategory: ChineseSubCategory? = nil
    @Published var selectedJapaneseSubCategory: JapaneseSubCategory? = nil
    @Published var selectedWesternSubCategory: WesternSubCategory? = nil
    @Published var selectedSoutheastAsianSubCategory: SoutheastAsianSubCategory? = nil

    // MARK: - 화면 상태

    /// 목록 화면에 표시할 레시피 목록
    @Published private(set) var videos: [RecipeVideo] = []

    /// API 호출 로딩 상태
    @Published private(set) var isLoading: Bool = false

    /// 에러 메시지 (Toast/Alert 용)
    @Published private(set) var errorMessage: String? = nil

    // MARK: - Init

    /// 서비스 주입용 init
    /// - Note:
    ///   - Swift 6에서는 기본 파라미터로 `RecipeService()`를 생성하면
    ///     nonisolated 컨텍스트에서 MainActor init을 호출하는 경고/에러가 발생할 수 있다.
    init(service: RecipeService) {
        self.service = service
    }

    /// 기본 생성용 init
    /// - Note:
    ///   - RecipeService() 생성은 MainActor에서만 수행한다.
    convenience init() {
        self.init(service: RecipeService())
    }

    // MARK: - Computed

    /// 선택된 상위 + 하위 카테고리를 기준으로 필터링된 영상 목록
    /// - Note:
    ///   - API 연동 후에는 서버에서 categoryId 기준으로 목록을 받아오기 때문에
    ///     보통 videos 자체가 이미 해당 카테고리 결과가 된다.
    ///   - 기존 UI가 이 프로퍼티에 의존하고 있다면 유지한다.
    var filteredVideos: [RecipeVideo] {
        // 서버에서 categoryId로 이미 필터링된 목록을 내려주므로,
        // 하위 카테고리가 선택된 경우에는 videos를 그대로 노출한다.
        // (API 매핑에서 cuisine/subCategory 필드가 비어있어도 UI가 비지 않도록)
        guard let selectedCuisine else { return [] }

        switch selectedCuisine {
        case .korean:
            return selectedKoreanSubCategory == nil ? [] : videos
        case .chinese:
            return selectedChineseSubCategory == nil ? [] : videos
        case .japanese:
            return selectedJapaneseSubCategory == nil ? [] : videos
        case .western:
            return selectedWesternSubCategory == nil ? [] : videos
        case .southeastAsian:
            return selectedSoutheastAsianSubCategory == nil ? [] : videos
        }
    }

    // MARK: - 카테고리 선택 처리 (View -> ViewModel)

    @MainActor
    /// 상위 카테고리 선택 시 호출
    /// 하위 카테고리는 모두 초기화된다.
    func selectCuisine(_ cuisine: CuisineCategory) {
        selectedCuisine = cuisine

        // 상위 선택 시 하위는 초기화
        selectedKoreanSubCategory = nil
        selectedChineseSubCategory = nil
        selectedJapaneseSubCategory = nil
        selectedWesternSubCategory = nil
        selectedSoutheastAsianSubCategory = nil

        // 상위만 선택된 상태에서는 목록을 비워둔다.
        videos = []
    }

    @MainActor
    /// 한식 하위 카테고리 선택
    func selectKoreanSubCategory(_ subCategory: KoreanSubCategory) {
        selectedCuisine = .korean
        selectedKoreanSubCategory = subCategory
        Task { await fetchRecipesForSelectedCategory() }
    }

    @MainActor
    /// 중식 하위 카테고리 선택
    func selectChineseSubCategory(_ subCategory: ChineseSubCategory) {
        selectedCuisine = .chinese
        selectedChineseSubCategory = subCategory
        Task { await fetchRecipesForSelectedCategory() }
    }

    @MainActor
    /// 일식 하위 카테고리 선택
    func selectJapaneseSubCategory(_ subCategory: JapaneseSubCategory) {
        selectedCuisine = .japanese
        selectedJapaneseSubCategory = subCategory
        Task { await fetchRecipesForSelectedCategory() }
    }

    @MainActor
    /// 양식 하위 카테고리 선택
    func selectWesternSubCategory(_ subCategory: WesternSubCategory) {
        selectedCuisine = .western
        selectedWesternSubCategory = subCategory
        Task { await fetchRecipesForSelectedCategory() }
    }

    @MainActor
    /// 동남아 하위 카테고리 선택
    func selectSoutheastAsianSubCategory(_ subCategory: SoutheastAsianSubCategory) {
        selectedCuisine = .southeastAsian
        selectedSoutheastAsianSubCategory = subCategory
        Task { await fetchRecipesForSelectedCategory() }
    }

    // MARK: - API

    @MainActor
    /// 현재 선택된 (상위+하위) 카테고리에 맞는 categoryId로 목록을 조회한다.
    /// - Note:
    ///   - 상위/하위가 모두 선택되어야만 호출된다.
    func fetchRecipesForSelectedCategory() async {
        guard let categoryId = currentCategoryId() else {
            videos = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.fetchRecipes(categoryId: categoryId)
            videos = result
        } catch {
            videos = []
            errorMessage = "레시피 목록을 불러오지 못했습니다."
        }

        isLoading = false
    }

    @MainActor
    /// 목록 화면에서 북마크 버튼 클릭 시 호출
    /// - Note:
    ///   - 서버 토글 결과(isBookmarked)를 받아 UI 상태를 동기화한다.
    func toggleBookmark(recipeId: Int) {
        Task {
            do {
                let isBookmarked = try await service.toggleBookmark(recipeId: recipeId)
                if let index = videos.firstIndex(where: { $0.id == recipeId }) {
                    videos[index].isBookmarked = isBookmarked
                }
            } catch {
                errorMessage = "북마크 변경에 실패했습니다."
            }
        }
    }

    @MainActor
    /// 상세 화면으로 이동하기 전에 사용할 데이터 준비
    /// - Note:
    ///   - 상세 API는 steps/summaryExists를 내려주지만,
    ///     요약 생성 API(/summary)가 500/빈 바디로 실패할 수 있으므로 fallback을 적용한다.
    ///   - fallback 규칙
    ///     - summaryExists = true
    ///     - stepCount = 4
    ///     - title/description = "서버에서 아직 개발중 ㅠㅠ 화이팅 "
    ///     - timestamp = 1:00, 1:30, 2:00, 2:30
    func prepareDetailVideo(recipeId: Int) async -> RecipeVideo? {
        let categoryId = currentCategoryId()

        do {
            var detail = try await service.fetchRecipeDetail(recipeId: recipeId, categoryId: categoryId)

            // 요약 생성 API는 서버가 미구현일 수 있어 별도로 한 번 더 확인한다.
            let summary = await service.generateSummary(recipeId: recipeId)

            // summary API가 실패하면 service.generateSummary가 (true, 6) fallback을 반환하도록 구성돼 있지만,
            // 이 화면의 규칙은 stepCount=4 고정이므로 여기서 한 번 더 덮어쓴다.
            if summary.summaryExists {
                let fixedSteps = makeFallbackSummarySteps()

                // 상세 API 응답에 steps가 비어있거나(summary API가 실패한 케이스)
                // 혹은 서버가 아직 steps를 안 내려주는 케이스를 대비해서 fallback을 주입한다.
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
                        steps: fixedSteps,
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

            return detail
        } catch {
            errorMessage = "레시피 상세를 불러오지 못했습니다."
            return nil
        }
    }

    // MARK: - CategoryId Mapping

    /// 현재 선택된 하위 카테고리를 categoryId로 변환
    /// - Note:
    ///   - 서버의 categoryId 명세에 맞게 하드코딩 매핑한다.
    private func currentCategoryId() -> Int? {
        guard let selectedCuisine else { return nil }

        switch selectedCuisine {
        case .korean:
            guard let selectedKoreanSubCategory else { return nil }
            switch selectedKoreanSubCategory {
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
            guard let selectedChineseSubCategory else { return nil }
            switch selectedChineseSubCategory {
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
            guard let selectedJapaneseSubCategory else { return nil }
            switch selectedJapaneseSubCategory {
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
            guard let selectedWesternSubCategory else { return nil }
            switch selectedWesternSubCategory {
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
            guard let selectedSoutheastAsianSubCategory else { return nil }
            switch selectedSoutheastAsianSubCategory {
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
