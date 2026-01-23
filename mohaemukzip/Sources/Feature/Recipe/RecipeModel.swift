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

struct RecipeIngredient: Identifiable, Equatable {

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

struct RecipeStep: Identifiable, Equatable {

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
struct RecipeVideo: Identifiable {

    // MARK: Identity
    let id: Int // server: recipeId

    // MARK: Basic
    let title: String

    // MARK: Video
    /// Full YouTube URL (server: videoUrl). If your server later removes it, you can keep it empty in dummy.
    let videoUrl: String
    /// YouTube video id (server: videoId)
    let videoId: String
    /// Channel name (server: channel)
    let channelName: String
    /// Views (server: views)
    let viewCount: Int

    // MARK: Cooking
    /// Cooking time minutes (server: cookingTime)
    let cookingTimeMinutes: Int

    // MARK: Difficulty / Rating
    /// Difficulty / level (server: level) - backend uses Double
    let level: Double
    /// Rating count (server: ratingCount)
    let ratingCount: Int

    // MARK: Detail
    /// Ingredients list (server: ingredients)
    let ingredients: [RecipeIngredient]
    /// Steps list (server: steps)
    let steps: [RecipeStep]
    /// Summary exists flag (server: summaryExists)
    let summaryExists: Bool

    // MARK: Categories (Front-defined)
    let cuisine: CuisineCategory
    let koreanSubCategory: KoreanSubCategory?
    let chineseSubCategory: ChineseSubCategory?
    let japaneseSubCategory: JapaneseSubCategory?
    let westernSubCategory: WesternSubCategory?
    let southeastAsianSubCategory: SoutheastAsianSubCategory?

    // MARK: UI State
    var isBookmarked: Bool

    // MARK: Init
    init(
        id: Int,
        title: String,
        videoUrl: String = "",
        videoId: String,
        channelName: String,
        viewCount: Int,
        cookingTimeMinutes: Int,
        level: Double = 0.0,
        ratingCount: Int = 0,
        ingredients: [RecipeIngredient] = [],
        steps: [RecipeStep] = [],
        summaryExists: Bool = false,
        cuisine: CuisineCategory,
        koreanSubCategory: KoreanSubCategory? = nil,
        chineseSubCategory: ChineseSubCategory? = nil,
        japaneseSubCategory: JapaneseSubCategory? = nil,
        westernSubCategory: WesternSubCategory? = nil,
        southeastAsianSubCategory: SoutheastAsianSubCategory? = nil,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.videoUrl = videoUrl
        self.videoId = videoId
        self.channelName = channelName
        self.viewCount = viewCount
        self.cookingTimeMinutes = cookingTimeMinutes
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
    }
}
