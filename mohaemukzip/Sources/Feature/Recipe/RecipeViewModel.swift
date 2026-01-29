// MARK: - RecipeVideoViewModel
// 레시피 목록 화면(RecipeListView)을 위한 전용 ViewModel
// 상세 화면용 ViewModel과 분리되어 있지만, 동일한 RecipeVideo 모델을 공유함

import Foundation
import Combine

// MARK: - RecipeVideoViewModel

final class RecipeVideoViewModel: ObservableObject {

    // MARK: - 카테고리 선택 상태 (View → ViewModel)
    // 사용자가 선택한 상위 / 하위 카테고리를 관리함

    /// 선택된 상위 음식 카테고리 (한식 / 중식 / 일식 / 양식 / 동남아)
    @Published var selectedCuisine: CuisineCategory? = nil

    /// 선택된 하위 카테고리
    /// 상위 카테고리에 따라 하나의 값만 사용됨
    @Published var selectedKoreanSubCategory: KoreanSubCategory? = nil
    @Published var selectedChineseSubCategory: ChineseSubCategory? = nil
    @Published var selectedJapaneseSubCategory: JapaneseSubCategory? = nil
    @Published var selectedWesternSubCategory: WesternSubCategory? = nil
    @Published var selectedSoutheastAsianSubCategory: SoutheastAsianSubCategory? = nil

    // MARK: - 데이터 소스

    /// 전체 레시피 영상 목록
    /// API 연동 전까지는 더미 데이터를 사용함
    @Published private(set) var videos: [RecipeVideo] = []

    // MARK: - 필터링된 결과 (Computed)

    /// 선택된 상위 + 하위 카테고리를 기준으로 필터링된 영상 목록
    /// - 동작 규칙:
    ///   1) 상위 카테고리가 선택되지 않으면 빈 배열 반환
    ///   2) 상위만 선택되고 하위가 선택되지 않아도 빈 배열 반환
    ///   3) 상위와 하위가 모두 선택된 경우에만 결과 반환
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

    // MARK: - 상세 화면용 더미 데이터 생성

    /// 목록 화면에서 선택한 레시피로 상세 화면을 구성하기 위한 더미 데이터 생성
    /// API 연동 전까지 임시로 사용하며, 추후 상세 API 응답으로 대체 예정
    func makeDummyDetailVideo(recipeId: Int) -> RecipeVideo {
        // 목록 더미 데이터 중 동일한 레시피를 찾아 기본 정보로 사용
        let base = videos.first(where: { $0.id == recipeId })

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
            isBookmarked: base?.isBookmarked ?? false
        )
    }

    // MARK: - 초기화

    /// 기본 진입 시 사용
    /// 상위 / 하위 카테고리가 모두 선택되지 않은 초기 상태
    init() {
        self.selectedCuisine = nil
        self.selectedKoreanSubCategory = nil
        self.selectedChineseSubCategory = nil
        self.selectedJapaneseSubCategory = nil
        self.selectedWesternSubCategory = nil
        self.selectedSoutheastAsianSubCategory = nil

        loadDummyData()
    }

    /// 기존 호출부 호환을 위한 초기화
    /// category 값이 들어와도 기본 정책은 "선택 없음" 상태를 유지함
    init(category: CuisineCategory) {
        self.selectedCuisine = nil
        self.selectedKoreanSubCategory = nil
        self.selectedChineseSubCategory = nil
        self.selectedJapaneseSubCategory = nil
        self.selectedWesternSubCategory = nil
        self.selectedSoutheastAsianSubCategory = nil

        loadDummyData()
    }

    // MARK: - 카테고리 선택 처리 (View → ViewModel)

    /// 상위 카테고리 선택 시 호출
    /// 하위 카테고리는 모두 초기화됨
    func selectCuisine(_ cuisine: CuisineCategory) {
        selectedCuisine = cuisine

        // 상위 선택 시 하위는 초기화
        selectedKoreanSubCategory = nil
        selectedChineseSubCategory = nil
        selectedJapaneseSubCategory = nil
        selectedWesternSubCategory = nil
        selectedSoutheastAsianSubCategory = nil
    }

    /// 해당 상위 카테고리의 하위 카테고리 선택 시 호출
    /// 상위 카테고리도 함께 설정됨
    func selectKoreanSubCategory(_ subCategory: KoreanSubCategory) {
        selectedCuisine = .korean
        selectedKoreanSubCategory = subCategory
    }

    /// 해당 상위 카테고리의 하위 카테고리 선택 시 호출
    /// 상위 카테고리도 함께 설정됨
    func selectChineseSubCategory(_ subCategory: ChineseSubCategory) {
        selectedCuisine = .chinese
        selectedChineseSubCategory = subCategory
    }

    /// 해당 상위 카테고리의 하위 카테고리 선택 시 호출
    /// 상위 카테고리도 함께 설정됨
    func selectJapaneseSubCategory(_ subCategory: JapaneseSubCategory) {
        selectedCuisine = .japanese
        selectedJapaneseSubCategory = subCategory
    }

    /// 해당 상위 카테고리의 하위 카테고리 선택 시 호출
    /// 상위 카테고리도 함께 설정됨
    func selectWesternSubCategory(_ subCategory: WesternSubCategory) {
        selectedCuisine = .western
        selectedWesternSubCategory = subCategory
    }

    /// 해당 상위 카테고리의 하위 카테고리 선택 시 호출
    /// 상위 카테고리도 함께 설정됨
    func selectSoutheastAsianSubCategory(_ subCategory: SoutheastAsianSubCategory) {
        selectedCuisine = .southeastAsian
        selectedSoutheastAsianSubCategory = subCategory
    }

    // MARK: - 더미 데이터 로드 (API 연동 전)

    /// 목록 화면에 표시할 더미 레시피 데이터 로드
    /// API 연동 시 이 메서드는 제거될 예정
    private func loadDummyData() {
        videos = [
            // 한식
            RecipeVideo(
                id: 12,
                title: "초간단 제육볶음 레시피",
                videoUrl: "https://www.youtube.com/watch?v=sHpMVI8wQuk",
                videoId: "sHpMVI8wQuk",
                channelId: nil,
                videoDuration: "12:05",
                channelName: "고석현",
                viewCount: 1_250_000,
                cookingTimeMinutes: 15,
                difficulty: nil,
                level: 3.0,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 3, name: "돼지고기", amount: 400.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 7, name: "양배추", amount: 1.0, unit: "개", hasIngredient: false),
                    RecipeIngredient(id: 9, name: "양파", amount: 0.5, unit: "개", hasIngredient: true)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "고기와 기본 재료 준비하기", description: "돼지고기와 채소를 손질합니다.", videoTime: 304),
                    RecipeStep(stepNumber: 2, title: "팬에 고기 볶기", description: "달군 팬에 고기를 볶습니다.", videoTime: 443),
                    RecipeStep(stepNumber: 3, title: "양념 넣고 볶기", description: "양념을 넣고 1~2분 더 볶습니다.", videoTime: 650)
                ],
                summaryExists: true,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: true,
                channelProfileImageUrl: "https://picsum.photos/seed/goseokhyun/200"
            )
        ,
            RecipeVideo(
                id: 4,
                title: "초간단 고석현 김치찌개",
                videoUrl: nil,
                videoId: "tDlw8yMg9NY",
                channelId: "UC_KOREAN_002",
                videoDuration: "12:05",
                channelName: "고석현",
                viewCount: 54_000,
                cookingTimeMinutes: 25,
                difficulty: 1,
                level: nil,
                ratingCount: nil,
                ingredients: nil,
                steps: nil,
                summaryExists: nil,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                isBookmarked: false,
                channelProfileImageUrl: "https://picsum.photos/200"
            ),
            RecipeVideo(
                id: 5,
                title: "고석현 존맛 된찌",
                videoUrl: nil,
                videoId: "J4vEoFVcguw",
                channelId: "UC_KOREAN_002",
                videoDuration: "09:44",
                channelName: "고석현",
                viewCount: 88_000,
                cookingTimeMinutes: 30,
                difficulty: 2,
                level: nil,
                ratingCount: nil,
                ingredients: nil,
                steps: nil,
                summaryExists: nil,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                isBookmarked: false,
                channelProfileImageUrl: "https://picsum.photos/200"
            ),

            // 중식
            RecipeVideo(
                id: 2,
                title: "마라탕 만들기",
                videoUrl: nil,
                videoId: "EEc7AwJKAuc",
                channelId: "UC_CHINESE_001",
                videoDuration: "13:10",
                channelName: "중식장인",
                viewCount: 98_000,
                cookingTimeMinutes: 30,
                difficulty: 3,
                level: nil,
                ratingCount: nil,
                ingredients: nil,
                steps: nil,
                summaryExists: nil,
                cuisine: .chinese,
                chineseSubCategory: .mara,
                isBookmarked: false,
                channelProfileImageUrl: "https://picsum.photos/200"
            ),
            RecipeVideo(
                id: 6,
                title: "고석현표 마라탕",
                videoUrl: nil,
                videoId: "sHpMVI8wQuk",
                channelId: "UC_CHINESE_002",
                videoDuration: "11:58",
                channelName: "고석현",
                viewCount: 102_000,
                cookingTimeMinutes: 35,
                difficulty: 3,
                level: nil,
                ratingCount: nil,
                ingredients: nil,
                steps: nil,
                summaryExists: nil,
                cuisine: .chinese,
                chineseSubCategory: .mara,
                isBookmarked: false,
                channelProfileImageUrl: "https://picsum.photos/200"
            ),

            // 일식
            RecipeVideo(
                id: 3,
                title: "연어 덮밥",
                videoUrl: nil,
                videoId: "evLCCdDt0AA",
                channelId: "UC_JAPANESE_001",
                videoDuration: "08:31",
                channelName: "일식요리",
                viewCount: 76_000,
                cookingTimeMinutes: 15,
                difficulty: 2,
                level: nil,
                ratingCount: nil,
                ingredients: nil,
                steps: nil,
                summaryExists: nil,
                cuisine: .japanese,
                japaneseSubCategory: .riceBowl,
                isBookmarked: false,
                channelProfileImageUrl: "https://picsum.photos/200"
            )
        ]
    }

    // MARK: - 북마크 처리 (UI 전용)

    /// 목록 화면에서 북마크 버튼 클릭 시 호출
    /// 현재는 UI 상태만 토글하며, API 연동 시 서버 요청으로 교체 예정
    func toggleBookmark(videoId: Int) {
        guard let index = videos.firstIndex(where: { $0.id == videoId }) else { return }
        videos[index].isBookmarked.toggle()
    }
}
