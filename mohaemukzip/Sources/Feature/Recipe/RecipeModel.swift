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

// MARK: - Recipe Detail Sub Models

struct RecipeIngredient: Identifiable, Equatable, Hashable {

    let id: Int              // server: ingredientId
    let name: String
    let amount: Double
    let unit: String
    let hasIngredient: Bool

    init(
        id: Int,
        name: String,
        amount: Double,
        unit: String,
        hasIngredient: Bool
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.hasIngredient = hasIngredient
    }
}

struct RecipeStep: Identifiable, Equatable, Hashable {

    var id: Int { stepNumber }

    let stepNumber: Int
    let title: String
    let description: String
    /// seconds (server: videoTime)
    let videoTime: Int

    init(
        stepNumber: Int,
        title: String,
        description: String,
        videoTime: Int
    ) {
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
        self.videoTime = videoTime
    }
}

// MARK: - Recipe Model (목록 + 상세 공용)
struct RecipeVideo: Identifiable, Hashable {

    // MARK: Identity
    /// List API uses `id`, Detail API uses `recipeId`.
    let id: Int

    // MARK: Basic
    let title: String

    // MARK: Video
    /// Detail API: full YouTube URL (`videoUrl`). May be absent in list.
    let videoUrl: String?
    /// Both APIs: YouTube video id (`videoId`).
    let videoId: String
    /// List API: channelId. Detail API may not provide it.
    let channelId: String?
    /// List API: video runtime string (e.g., "13:10"). Detail API may not provide it.
    let videoDuration: String?

    // MARK: Channel / Views
    /// List API: `channelName`, Detail API: `channel`.
    let channelName: String
    /// List API: `viewCount`, Detail API: `views`.
    let viewCount: Int

    // MARK: Cooking
    /// List API: `cookingTimeMinutes`, Detail API: `cookingTime`.
    let cookingTimeMinutes: Int

    // MARK: Difficulty / Rating
    /// List API: `difficulty` (Int 0~5 or 1~5 depending on your backend).
    let difficulty: Int?
    /// Detail API: `level` (Double).
    let level: Double?
    /// Detail API: rating count.
    let ratingCount: Int?

    // MARK: Detail
    let ingredients: [RecipeIngredient]?
    let steps: [RecipeStep]?
    let summaryExists: Bool?

    // MARK: Categories (Front-defined)
    let cuisine: CuisineCategory
    let koreanSubCategory: KoreanSubCategory?
    let chineseSubCategory: ChineseSubCategory?
    let japaneseSubCategory: JapaneseSubCategory?
    let westernSubCategory: WesternSubCategory?
    let southeastAsianSubCategory: SoutheastAsianSubCategory?
    
    


    // MARK: UI State
    /// List API provides it. Detail API may omit it; default to false.
    var isBookmarked: Bool
    
    //채널 프사
    let channelProfileImageUrl: String?

    // MARK: Computed (UI convenience)

    /// Prefer list `difficulty`, else derive from detail `level`.
    var displayDifficultyStars: Int {
        if let difficulty {
            return max(0, min(5, difficulty))
        }
        if let level {
            return max(0, min(5, Int(level.rounded())))
        }
        return 0
    }

    /// Safe arrays for UI.
    var displayIngredients: [RecipeIngredient] {
        ingredients ?? []
    }

    var displaySteps: [RecipeStep] {
        steps ?? []
    }

    var hasSummary: Bool {
        summaryExists ?? false
    }

    // MARK: Init
    init(
        id: Int,
        title: String,
        videoUrl: String? = nil,
        videoId: String,
        channelId: String? = nil,
        videoDuration: String? = nil,
        channelName: String,
        viewCount: Int,
        cookingTimeMinutes: Int,
        difficulty: Int? = nil,
        level: Double? = nil,
        ratingCount: Int? = nil,
        ingredients: [RecipeIngredient]? = nil,
        steps: [RecipeStep]? = nil,
        summaryExists: Bool? = nil,
        cuisine: CuisineCategory,
        koreanSubCategory: KoreanSubCategory? = nil,
        chineseSubCategory: ChineseSubCategory? = nil,
        japaneseSubCategory: JapaneseSubCategory? = nil,
        westernSubCategory: WesternSubCategory? = nil,
        southeastAsianSubCategory: SoutheastAsianSubCategory? = nil,
        isBookmarked: Bool = false,
        channelProfileImageUrl: String? = nil
    ) {
        self.id = id
        self.title = title
        self.videoUrl = videoUrl
        self.videoId = videoId
        self.channelId = channelId
        self.videoDuration = videoDuration
        self.channelName = channelName
        self.viewCount = viewCount
        self.cookingTimeMinutes = cookingTimeMinutes
        self.difficulty = difficulty
        self.level = level
        self.ratingCount = ratingCount
        self.ingredients = ingredients
        self.steps = steps
        self.summaryExists = summaryExists
        self.cuisine = cuisine
        self.koreanSubCategory = koreanSubCategory
        self.chineseSubCategory = chineseSubCategory
        self.japaneseSubCategory = japaneseSubCategory
        self.westernSubCategory = westernSubCategory
        self.southeastAsianSubCategory = southeastAsianSubCategory
        self.isBookmarked = isBookmarked
        self.channelProfileImageUrl = channelProfileImageUrl
        
    }
}
