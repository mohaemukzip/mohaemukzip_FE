import Foundation
import Combine

// MARK: - RecipeVideoViewModel

final class RecipeVideoViewModel: ObservableObject {

    // MARK: Selection State (View → ViewModel)

    /// 선택된 상위 카테고리 (한식 / 중식 / 일식 / 양식 / 동남아)
    @Published var selectedCuisine: CuisineCategory? = nil

    /// 선택된 하위 카테고리들 (상위 카테고리에 따라 하나만 사용됨)
    @Published var selectedKoreanSubCategory: KoreanSubCategory? = nil
    @Published var selectedChineseSubCategory: ChineseSubCategory? = nil
    @Published var selectedJapaneseSubCategory: JapaneseSubCategory? = nil
    @Published var selectedWesternSubCategory: WesternSubCategory? = nil
    @Published var selectedSoutheastAsianSubCategory: SoutheastAsianSubCategory? = nil

    // MARK: Data Source

    /// 전체 레시피 영상 목록 (추후 API 응답으로 교체)
    @Published private(set) var videos: [RecipeVideo] = []

    // MARK: Computed - Filtered Result

    /// 상위 카테고리 + 하위 카테고리 기준으로 필터링된 영상 목록
    /// - Note:
    ///   1) 상위 카테고리가 선택되지 않으면([])
    ///   2) 상위만 선택되고 하위가 선택되지 않아도([])
    ///   3) 상위 + 하위가 모두 선택되면 해당 조건으로 필터링
    var filteredVideos: [RecipeVideo] {
        guard let selectedCuisine else { return [] }

        switch selectedCuisine {
        case .korean:
            guard let selectedKoreanSubCategory else { return [] }
            return videos.filter {
                $0.cuisine == .korean && $0.koreanSubCategory == selectedKoreanSubCategory
            }

        case .chinese:
            guard let selectedChineseSubCategory else { return [] }
            return videos.filter {
                $0.cuisine == .chinese && $0.chineseSubCategory == selectedChineseSubCategory
            }

        case .japanese:
            guard let selectedJapaneseSubCategory else { return [] }
            return videos.filter {
                $0.cuisine == .japanese && $0.japaneseSubCategory == selectedJapaneseSubCategory
            }

        case .western:
            guard let selectedWesternSubCategory else { return [] }
            return videos.filter {
                $0.cuisine == .western && $0.westernSubCategory == selectedWesternSubCategory
            }

        case .southeastAsian:
            guard let selectedSoutheastAsianSubCategory else { return [] }
            return videos.filter {
                $0.cuisine == .southeastAsian && $0.southeastAsianSubCategory == selectedSoutheastAsianSubCategory
            }
        }
    }

    // MARK: Init



    /// ✅ 기본 진입: 아무 버튼도 선택되지 않은 상태
    init() {
        self.selectedCuisine = nil
        self.selectedKoreanSubCategory = nil
        self.selectedChineseSubCategory = nil
        self.selectedJapaneseSubCategory = nil
        self.selectedWesternSubCategory = nil
        self.selectedSoutheastAsianSubCategory = nil

        loadDummyData()
    }

    /// 기존 호출부 호환용: category가 들어와도 '기본 선택 없음' 정책 유지
    init(category: CuisineCategory) {
        self.selectedCuisine = nil
        self.selectedKoreanSubCategory = nil
        self.selectedChineseSubCategory = nil
        self.selectedJapaneseSubCategory = nil
        self.selectedWesternSubCategory = nil
        self.selectedSoutheastAsianSubCategory = nil

        loadDummyData()
    }

    // MARK: Category Selection (View → VM API)

    /// 상위 카테고리 선택 시 호출
    func selectCuisine(_ cuisine: CuisineCategory) {
        selectedCuisine = cuisine

        // 상위 선택 단계: 하위는 아직 선택하지 않은 상태로 초기화
        selectedKoreanSubCategory = nil
        selectedChineseSubCategory = nil
        selectedJapaneseSubCategory = nil
        selectedWesternSubCategory = nil
        selectedSoutheastAsianSubCategory = nil
    }

    /// 한식 하위 카테고리 선택
    func selectKoreanSubCategory(_ subCategory: KoreanSubCategory) {
        selectedCuisine = .korean
        selectedKoreanSubCategory = subCategory
    }

    /// 중식 하위 카테고리 선택
    func selectChineseSubCategory(_ subCategory: ChineseSubCategory) {
        selectedCuisine = .chinese
        selectedChineseSubCategory = subCategory
    }

    /// 일식 하위 카테고리 선택
    func selectJapaneseSubCategory(_ subCategory: JapaneseSubCategory) {
        selectedCuisine = .japanese
        selectedJapaneseSubCategory = subCategory
    }

    /// 양식 하위 카테고리 선택
    func selectWesternSubCategory(_ subCategory: WesternSubCategory) {
        selectedCuisine = .western
        selectedWesternSubCategory = subCategory
    }

    /// 동남아 하위 카테고리 선택
    func selectSoutheastAsianSubCategory(_ subCategory: SoutheastAsianSubCategory) {
        selectedCuisine = .southeastAsian
        selectedSoutheastAsianSubCategory = subCategory
    }

    // MARK: Dummy Data (API 연동 전 임시 데이터)

    private func loadDummyData() {
        videos = [
            RecipeVideo(
                id: 1,
                title: "김민우 헬창",
                videoUrl: "",
                videoId: "VgPuT73v5iY",
                channelName: "한식연구소",
                viewCount: 120_000,
                cookingTimeMinutes: 20,
                level: 2.0,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 1, name: "돼지고기", amount: 400.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 2, name: "양파", amount: 0.5, unit: "개", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "재료 준비", description: "고기와 채소를 손질합니다.", videoTime: 120),
                    RecipeStep(stepNumber: 2, title: "볶기", description: "팬에 고기를 볶습니다.", videoTime: 300)
                ],
                summaryExists: true,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 4,
                title: "초간단 고석현 김치찌개",
                videoUrl: "",
                videoId: "tDlw8yMg9NY",
                channelName: "고석현",
                viewCount: 54_000,
                cookingTimeMinutes: 25,
                level: 1.0,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 3, name: "김치", amount: 300.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 4, name: "두부", amount: 1.0, unit: "모", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "육수 준비", description: "물에 재료를 넣고 끓입니다.", videoTime: 180),
                    RecipeStep(stepNumber: 2, title: "마무리", description: "간을 맞추고 마무리합니다.", videoTime: 420)
                ],
                summaryExists: false,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 5,
                title: "고석현 존맛 된찌",
                videoUrl: "",
                videoId: "J4vEoFVcguw",
                channelName: "고석현",
                viewCount: 88_000,
                cookingTimeMinutes: 30,
                level: 2.0,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 5, name: "된장", amount: 2.0, unit: "큰술", hasIngredient: true),
                    RecipeIngredient(id: 6, name: "애호박", amount: 0.5, unit: "개", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "재료 넣기", description: "냄비에 재료를 넣습니다.", videoTime: 150),
                    RecipeStep(stepNumber: 2, title: "끓이기", description: "중불로 끓입니다.", videoTime: 360)
                ],
                summaryExists: true,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 2,
                title: "마라탕 만들기",
                videoUrl: "",
                videoId: "EEc7AwJKAuc",
                channelName: "중식장인",
                viewCount: 98_000,
                cookingTimeMinutes: 30,
                level: 3.0,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 7, name: "마라소스", amount: 1.0, unit: "팩", hasIngredient: true),
                    RecipeIngredient(id: 8, name: "푸주", amount: 100.0, unit: "g", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "육수 끓이기", description: "육수에 마라소스를 풀어 끓입니다.", videoTime: 240),
                    RecipeStep(stepNumber: 2, title: "재료 넣기", description: "준비한 재료를 넣고 익힙니다.", videoTime: 480)
                ],
                summaryExists: true,
                cuisine: .chinese,
                chineseSubCategory: .mara,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 6,
                title: "고석현표 마라탕",
                videoUrl: "",
                videoId: "sHpMVI8wQuk",
                channelName: "고석현",
                viewCount: 102_000,
                cookingTimeMinutes: 35,
                level: 3.0,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 9, name: "마라소스", amount: 1.0, unit: "팩", hasIngredient: true),
                    RecipeIngredient(id: 10, name: "청경채", amount: 2.0, unit: "포기", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "소스 풀기", description: "끓는 물에 마라소스를 풉니다.", videoTime: 210),
                    RecipeStep(stepNumber: 2, title: "완성", description: "재료를 넣고 익힌 뒤 마무리합니다.", videoTime: 510)
                ],
                summaryExists: false,
                cuisine: .chinese,
                chineseSubCategory: .mara,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 3,
                title: "연어 덮밥",
                videoUrl: "",
                videoId: "evLCCdDt0AA",
                channelName: "일식요리",
                viewCount: 76_000,
                cookingTimeMinutes: 15,
                level: 2.0,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 11, name: "연어", amount: 200.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 12, name: "밥", amount: 1.0, unit: "공기", hasIngredient: true)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "밥 준비", description: "따뜻한 밥을 준비합니다.", videoTime: 60),
                    RecipeStep(stepNumber: 2, title: "토핑 올리기", description: "연어를 썰어 밥 위에 올립니다.", videoTime: 240)
                ],
                summaryExists: true,
                cuisine: .japanese,
                japaneseSubCategory: .riceBowl,
                isBookmarked: false
            )
        ]
    }

    // MARK: Bookmark (북마크 기능)

    func toggleBookmark(videoId: Int) {
        guard let index = videos.firstIndex(where: { $0.id == videoId }) else { return }
        videos[index].isBookmarked.toggle()
    }
}
