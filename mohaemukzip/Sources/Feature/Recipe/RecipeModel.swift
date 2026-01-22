import Foundation
import SwiftUI

// MARK: - 음식 종류 (상위 카테고리 버튼)
enum CuisineCategory: String, CaseIterable, Identifiable {
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case western = "양식"
    case southeastAsian = "동남아"

    var id: String { rawValue }
}

// MARK: - Korean SubCategory (한식)
enum KoreanSubCategory: String, CaseIterable, Identifiable {
    case soupStew = "국·찌개"
    case rice = "밥요리"
    case noodle = "국수"
    case stirFry = "볶음"
    case braised = "조림"
    case pancake = "전·부침"
    case grill = "구이"
    case mixed = "비빔·무침"
    case sideDish = "반찬"
    case kimchi = "김치 요리"

    var id: String { rawValue }
}

// MARK: - Chinese SubCategory (중식)
enum ChineseSubCategory: String, CaseIterable, Identifiable {
    case noodle = "면요리"
    case friedRice = "볶음밥"
    case riceBowl = "덮밥"
    case stirFry = "볶음"
    case deepFried = "튀김"
    case soup = "국물 요리"
    case mara = "마라 요리"
    case meat = "고기 요리"
    case seafood = "해물 요리"
    case dumpling = "만두 요리"

    var id: String { rawValue }
}

// MARK: - Japanese SubCategory (일식)
enum JapaneseSubCategory: String, CaseIterable, Identifiable {
    case riceBowl = "덮밥"
    case noodle = "면요리"
    case soup = "국물"
    case stirFry = "볶음"
    case braised = "조림"
    case deepFried = "튀김"
    case grill = "구이"
    case lunchBox = "도시락"
    case seafood = "해물 요리"
    case egg = "계란 요리"

    var id: String { rawValue }
}

// MARK: - Western SubCategory (양식)
enum WesternSubCategory: String, CaseIterable, Identifiable {
    case pasta = "파스타"
    case risotto = "리조또"
    case stirFry = "볶음"
    case steak = "스테이크"
    case oven = "오븐 요리"
    case salad = "샐러드"
    case soup = "수프"
    case brunch = "브런치"
    case pizza = "피자"
    case cheese = "치즈 요리"

    var id: String { rawValue }
}

// MARK: - Southeast Asian SubCategory (동남아)
enum SoutheastAsianSubCategory: String, CaseIterable, Identifiable {
    case rice = "밥요리"
    case riceNoodle = "쌀국수"
    case noodle = "면요리"
    case soup = "국물"
    case stirFry = "볶음"
    case deepFried = "튀김"
    case curry = "커리 요리"
    case meat = "고기 요리"
    case seafood = "해물 요리"
    case salad = "샐러드"

    var id: String { rawValue }
}

// MARK: - Recipe Video Model (영상 모델)
struct RecipeVideo: Identifiable {
    let id: Int
    let title: String
    let channelName: String
    let viewCount: Int
    let thumbnailImageName: String
    let videoId: String

    // ✅ New: 영상/요리 메타
    /// 영상 재생 시간 (예: "10:23")
    let videoDuration: String
    /// 요리 소요 시간 (분)
    let cookingTimeMinutes: Int
    /// 난이도 (1~5)
    let difficulty: Int

    // Category
    let cuisine: CuisineCategory
    let koreanSubCategory: KoreanSubCategory?
    let chineseSubCategory: ChineseSubCategory?
    let japaneseSubCategory: JapaneseSubCategory?
    let westernSubCategory: WesternSubCategory?
    let southeastAsianSubCategory: SoutheastAsianSubCategory?

    var isBookmarked: Bool

   //기본 변수들.
    init(
        id: Int,
        title: String,
        channelName: String,
        viewCount: Int,
        thumbnailImageName: String,
        videoId: String,
        videoDuration: String = "",
        cookingTimeMinutes: Int = 0,
        difficulty: Int = 1,
        cuisine: CuisineCategory,
        koreanSubCategory: KoreanSubCategory?,
        chineseSubCategory: ChineseSubCategory?,
        japaneseSubCategory: JapaneseSubCategory?,
        westernSubCategory: WesternSubCategory?,
        southeastAsianSubCategory: SoutheastAsianSubCategory?,
        isBookmarked: Bool
    ) {
        self.id = id
        self.title = title
        self.channelName = channelName
        self.viewCount = viewCount
        self.thumbnailImageName = thumbnailImageName
        self.videoId = videoId
        self.videoDuration = videoDuration
        self.cookingTimeMinutes = cookingTimeMinutes
        self.difficulty = difficulty
        self.cuisine = cuisine
        self.koreanSubCategory = koreanSubCategory
        self.chineseSubCategory = chineseSubCategory
        self.japaneseSubCategory = japaneseSubCategory
        self.westernSubCategory = westernSubCategory
        self.southeastAsianSubCategory = southeastAsianSubCategory
        self.isBookmarked = isBookmarked
    }
}
