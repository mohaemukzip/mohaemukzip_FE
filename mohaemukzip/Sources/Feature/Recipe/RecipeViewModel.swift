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
            RecipeStep(stepNumber: 1, title: "고기와 기본 재료 준비하기", description: "영상 시청한지 1분 경과되었습니다. .", videoTime: 100),
            RecipeStep(stepNumber: 2, title: "팬에 고기 볶기", description: "영상 시청한지 2분 5초 경과되었습니다.", videoTime: 205),
            RecipeStep(stepNumber: 3, title: "양념 넣고 볶기", description: "영상 시청한지 3분 경과되었습니다.. ", videoTime: 300)
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
            // 한식 > 국/찌개 (시연용: 목록 API 기반 더미)
            RecipeVideo(
                id: 12,
                title: "세상에서 가장 쉬운 솥밥 만드는 법(feat.전복) l 전복냄비밥",
                videoUrl: "https://www.youtube.com/watch?v=hg31ssLQWUk",
                videoId: "hg31ssLQWUk",
                channelId: "UCyn-K7rZLXjGl7VXGweIlcA",
                videoDuration: "9:38",
                channelName: "백종원 PAIK JONG WON",
                viewCount: 298_576,
                cookingTimeMinutes: 30,
                difficulty: 5,
                level: nil,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 14, name: "버터", amount: 1.0, unit: "g", hasIngredient:true),
                    RecipeIngredient(id: 70, name: "깨", amount: 1.0, unit: "g", hasIngredient: false),
                    RecipeIngredient(id: 84, name: "쌀밥", amount: 400.0, unit: "g", hasIngredient: false),
                    RecipeIngredient(id: 175, name: "대파", amount: 1.0, unit: "줄기", hasIngredient: true),
                    RecipeIngredient(id: 204, name: "양파", amount: 0.2, unit: "개", hasIngredient: true),
                    RecipeIngredient(id: 212, name: "청양고추", amount: 2.0, unit: "개", hasIngredient: false),
                    RecipeIngredient(id: 250, name: "전복", amount: 2.0, unit: "개", hasIngredient: false),
                    RecipeIngredient(id: 269, name: "다진마늘", amount: 0.5, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 286, name: "설탕", amount: 0.5, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 291, name: "식용유", amount: 2.0, unit: "mL", hasIngredient: false),
                    RecipeIngredient(id: 302, name: "진간장", amount: 5.0, unit: "mL", hasIngredient: false),
                    RecipeIngredient(id: 303, name: "참기름", amount: 2.0, unit: "mL", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "요약 API가 500 에러 떠서 임의로 작성함 ", description: "영상 시청한지 1분 경과되었습니다.", videoTime: 100),
                    RecipeStep(stepNumber: 2, title: "요약 API가 500 에러 떠서 임의로 작성함", description: "영상 시청한지 2분 경과되었습니다.", videoTime: 200),
                    RecipeStep(stepNumber: 3, title: "피곤하다", description: "영상 시청한지 3분 52초 경과되었습니다.", videoTime: 352)
                ],
                summaryExists: true,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false,
                channelProfileImageUrl: "https://yt3.ggpht.com/tVvGKye5hDl70LaxrUsJBfm-rE9RES7bJDxSrjyO-vQDVb5EUJvUJefjUJ0dp-ixLIkrDYVX4A=s800-c-k-c0x00ffffff-no-rj"
            ),
            RecipeVideo(
                id: 13,
                title: "5분 안에 만드는 초간단 비빔밥 만들기! (Feat. 전자레인지)",
                videoUrl: "https://www.youtube.com/watch?v=Jq2SwKMw8vI",
                videoId: "Jq2SwKMw8vI",
                channelId: "UCyn-K7rZLXjGl7VXGweIlcA",
                videoDuration: "06:06",
                channelName: "백종원 PAIK JONG WON",
                viewCount: 584_728,
                cookingTimeMinutes: 5,
                difficulty: 2,
                level: nil,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 34, name: "계란", amount: 1.0, unit: "개", hasIngredient: true),
                    RecipeIngredient(id: 70, name: "깨", amount: 0.5, unit: "g", hasIngredient: false),
                    RecipeIngredient(id: 84, name: "쌀밥", amount: 200.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 174, name: "당근", amount: 0.5, unit: "개", hasIngredient: false),
                    RecipeIngredient(id: 180, name: "무", amount: 0.5, unit: "개", hasIngredient: true),
                    RecipeIngredient(id: 200, name: "애호박", amount: 0.5, unit: "개", hasIngredient: false),
                    RecipeIngredient(id: 214, name: "콩나물", amount: 0.5, unit: "g", hasIngredient: false),
                    RecipeIngredient(id: 218, name: "표고버섯", amount: 1.0, unit: "봉", hasIngredient: true),
                    RecipeIngredient(id: 227, name: "김", amount: 0.5, unit: "조각", hasIngredient: false),
                    RecipeIngredient(id: 260, name: "고추장", amount: 1.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 262, name: "국간장", amount: 1.0, unit: "mL", hasIngredient: true),
                    RecipeIngredient(id: 291, name: "식용유", amount: 1.0, unit: "mL", hasIngredient: false),
                    RecipeIngredient(id: 303, name: "참기름", amount: 1.0, unit: "mL", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "요약 API가  에러 떠서 임의로 작성함 ", description: "영상 시청한지 1분 경과되었습니다~~~", videoTime: 100),
                    RecipeStep(stepNumber: 2, title: "요약 API가  에러 떠서 임의로 작성함", description: "영상 시청한지 2분 경과되었습니다~~~", videoTime: 200),
                    RecipeStep(stepNumber: 3, title: "피곤하다", description: "영상 시청한지 3분 52초 경과되었습니다~", videoTime: 352)
                ],
                summaryExists: true,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false,
                channelProfileImageUrl: "https://yt3.ggpht.com/tVvGKye5hDl70LaxrUsJBfm-rE9RES7bJDxSrjyO-vQDVb5EUJvUJefjUJ0dp-ixLIkrDYVX4A=s800-c-k-c0x00ffffff-no-rj"
            ),
            RecipeVideo(
                id: 14,
                title: "소갈비찜 부럽지 않다! 비주얼까지 완벽한 돼지갈비찜",
                videoUrl: "https://www.youtube.com/watch?v=WT9tCViPddU",
                videoId: "WT9tCViPddU",
                channelId: "UCyn-K7rZLXjGl7VXGweIlcA",
                videoDuration: "10:07",
                channelName: "백종원 PAIK JONG WON",
                viewCount: 1_557_976,
                cookingTimeMinutes: 45,
                difficulty: 5,
                level: nil,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 174, name: "당근", amount: 65.0, unit: "개", hasIngredient: true),
                    RecipeIngredient(id: 175, name: "대파", amount: 1.0, unit: "줄기", hasIngredient: false),
                    RecipeIngredient(id: 180, name: "무", amount: 100.0, unit: "개", hasIngredient: true),
                    RecipeIngredient(id: 192, name: "생강", amount: 5.0, unit: "g", hasIngredient: false),
                    RecipeIngredient(id: 204, name: "양파", amount: 1.0, unit: "개", hasIngredient: false),
                    RecipeIngredient(id: 212, name: "청양고추", amount: 3.0, unit: "개", hasIngredient: true),
                    RecipeIngredient(id: 269, name: "다진마늘", amount: 30.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 276, name: "맛술", amount: 50.0, unit: "mL", hasIngredient: false),
                    RecipeIngredient(id: 286, name: "설탕", amount: 50.0, unit: "g", hasIngredient: false),
                    RecipeIngredient(id: 302, name: "진간장", amount: 80.0, unit: "mL", hasIngredient: true),
                    RecipeIngredient(id: 303, name: "참기름", amount: 14.0, unit: "mL", hasIngredient: true),
                    RecipeIngredient(id: 309, name: "카라멜시럽", amount: 2.0, unit: "mL", hasIngredient: true),
                    RecipeIngredient(id: 318, name: "후추", amount: 0.5, unit: "g", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "요약 API가 500 에러 떠서 임의로 작성함 ", description: "영상 시청한지 1분 경과되었습니다.", videoTime: 100),
                    RecipeStep(stepNumber: 2, title: "요약 API가 500 에러 떠서 임의로 작성함", description: "영상 시청한지 2분 경과되었습니다.", videoTime: 200),
                    RecipeStep(stepNumber: 3, title: "피곤하다", description: "영상 시청한지 3분 52초 경과되었습니다.", videoTime: 352)
                ],
                summaryExists: false,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false,
                channelProfileImageUrl: "https://yt3.ggpht.com/tVvGKye5hDl70LaxrUsJBfm-rE9RES7bJDxSrjyO-vQDVb5EUJvUJefjUJ0dp-ixLIkrDYVX4A=s800-c-k-c0x00ffffff-no-rj"
            ),
            RecipeVideo(
                id: 15,
                title: "감자와 두부있으면 이렇게 만들어 보세요~!! 맛도, 영양도 최고! 후라이팬 레시피!",
                videoUrl: "https://www.youtube.com/watch?v=kLT591PuXB4",
                videoId: "kLT591PuXB4",
                channelId: "UCB4JlWU3Vcev5pkyIdeBMRw",
                videoDuration: "03:15",
                channelName: "메리니즈부엌Meliniskitchen",
                viewCount: 4_668_682,
                cookingTimeMinutes: 20,
                difficulty: 2,
                level: nil,
                ratingCount: 0,
                ingredients: [
                    RecipeIngredient(id: 12, name: "모짜렐라치즈", amount: 1.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 67, name: "감자전분", amount: 2.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 72, name: "두부", amount: 200.0, unit: "모", hasIngredient: false),
                    RecipeIngredient(id: 165, name: "감자", amount: 2.0, unit: "개", hasIngredient: false),
                    RecipeIngredient(id: 287, name: "소금", amount: 0.33, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 318, name: "후추", amount: 1.0, unit: "g", hasIngredient: false)
                ],
                steps: [],
                summaryExists: true,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false,
                channelProfileImageUrl: "https://yt3.ggpht.com/ytc/AIdro_nDpOZ7ffn-0xtVU0savPUArskVwxA8oTXXPmD95pnkF2w=s800-c-k-c0x00ffffff-no-rj"
            ),
            RecipeVideo(
                id: 9,
                title: "달걀로 만두를 어떻게 만들지??",
                videoUrl: "https://www.youtube.com/watch?v=5-a5CPASYBc",
                videoId: "5-a5CPASYBc",
                channelId: "UCyn-K7rZLXjGl7VXGweIlcA",
                videoDuration: "09:06",
                channelName: "백종원 PAIK JONG WON",
                viewCount: 406_501,
                cookingTimeMinutes: 20,
                difficulty: 3,
                level: 4,
                ratingCount: nil,
                ingredients: [
                    RecipeIngredient(id: 12, name: "모짜렐라치즈", amount: 1.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 67, name: "감자전분", amount: 2.0, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 72, name: "두부", amount: 200.0, unit: "모", hasIngredient: false),
                    RecipeIngredient(id: 165, name: "감자", amount: 2.0, unit: "개", hasIngredient: false),
                    RecipeIngredient(id: 287, name: "소금", amount: 0.33, unit: "g", hasIngredient: true),
                    RecipeIngredient(id: 318, name: "후추", amount: 1.0, unit: "g", hasIngredient: false)
                ],
                steps: [
                    RecipeStep(stepNumber: 1, title: "요약 API가 500 에러 떠서 임의로 작성함 ", description: "영상 시청한지 1분 경과되었습니다.", videoTime: 100),
                    RecipeStep(stepNumber: 2, title: "요약 API가 500 에러 떠서 임의로 작성함", description: "영상 시청한지 2분 경과되었습니다.", videoTime: 200),
                    RecipeStep(stepNumber: 3, title: "피곤하다", description: "영상 시청한지 3분 52초 경과되었습니다.", videoTime: 352)
                ],
                summaryExists: true,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false,
                channelProfileImageUrl: "https://yt3.ggpht.com/tVvGKye5hDl70LaxrUsJBfm-rE9RES7bJDxSrjyO-vQDVb5EUJvUJefjUJ0dp-ixLIkrDYVX4A=s800-c-k-c0x00ffffff-no-rj"
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
