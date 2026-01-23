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
                channelName: "한식연구소",
                viewCount: 120_000,
                thumbnailImageName: "thumbnail1",
                videoId: "VgPuT73v5iY",
                videoDuration: "10:23",
                cookingTimeMinutes: 20,
                difficulty: 2,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 4,
                title: "초간단 고석현 김치찌개",
                channelName: "고석현",
                viewCount: 54_000,
                thumbnailImageName: "",
                videoId: "tDlw8yMg9NY",
                videoDuration: "09:15",
                cookingTimeMinutes: 25,
                difficulty: 1,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 5,
                title: "고석현 존맛 된찌",
                channelName: "고석현",
                viewCount: 88_000,
                thumbnailImageName: "",
                videoId: "J4vEoFVcguw",
                videoDuration: "11:40",
                cookingTimeMinutes: 30,
                difficulty: 2,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 2,
                title: "마라탕 만들기",
                channelName: "중식장인",
                viewCount: 98_000,
                thumbnailImageName: "thumbnail2",
                videoId: "EEc7AwJKAuc",
                videoDuration: "12:05",
                cookingTimeMinutes: 30,
                difficulty: 3,
                cuisine: .chinese,
                koreanSubCategory: nil,
                chineseSubCategory: .mara,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 6,
                title: "고석현표 마라탕",
                channelName: "고석현",
                viewCount: 102_000,
                thumbnailImageName: "",
                videoId: "sHpMVI8wQuk",
                videoDuration: "13:10",
                cookingTimeMinutes: 35,
                difficulty: 3,
                cuisine: .chinese,
                koreanSubCategory: nil,
                chineseSubCategory: .mara,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 3,
                title: "연어 덮밥",
                channelName: "일식요리",
                viewCount: 76_000,
                thumbnailImageName: "thumbnail3",
                videoId: "evLCCdDt0AA",
                videoDuration: "08:41",
                cookingTimeMinutes: 15,
                difficulty: 2,
                cuisine: .japanese,
                koreanSubCategory: nil,
                chineseSubCategory: nil,
                japaneseSubCategory: .riceBowl,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
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
