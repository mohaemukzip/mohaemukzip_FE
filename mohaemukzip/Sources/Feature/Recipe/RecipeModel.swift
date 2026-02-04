import Foundation
import SwiftUI

// MARK: - RecipeModel
// 레시피 도메인에서 사용하는 핵심 모델 정의 파일
// 목록 화면과 상세 화면에서 공통으로 사용하는 타입들을 모아둠

// MARK: - 음식 종류 (상위 카테고리)
// 홈/목록 화면에서 사용하는 상위 음식 카테고리
enum CuisineCategory: String, CaseIterable, Identifiable {
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case western = "양식"
    case southeastAsian = "동남아"

    /// SwiftUI에서 ForEach 식별을 위해 rawValue를 id로 사용
    var id: String { rawValue }
}

// MARK: - 한식 하위 카테고리
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

    /// SwiftUI에서 ForEach 식별을 위해 rawValue를 id로 사용
    var id: String { rawValue }
}

// MARK: - 중식 하위 카테고리
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

    /// SwiftUI에서 ForEach 식별을 위해 rawValue를 id로 사용
    var id: String { rawValue }
}

// MARK: - 일식 하위 카테고리
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

    /// SwiftUI에서 ForEach 식별을 위해 rawValue를 id로 사용
    var id: String { rawValue }
}

// MARK: - 양식 하위 카테고리
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

    /// SwiftUI에서 ForEach 식별을 위해 rawValue를 id로 사용
    var id: String { rawValue }
}

// MARK: - 동남아 하위 카테고리
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

    /// SwiftUI에서 ForEach 식별을 위해 rawValue를 id로 사용
    var id: String { rawValue }
}

// MARK: - Recipe Detail Sub Models

struct RecipeIngredient: Identifiable, Equatable, Hashable {

    let id: Int              // 서버에서 내려오는 ingredientId
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
    /// 해당 조리 단계가 시작되는 영상 시점 (초 단위, server: videoTime)
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

    // MARK: - 식별 정보
    /// 목록 API에서는 id, 상세 API에서는 recipeId로 내려오지만
    /// 앱 내부에서는 id 하나로 통합해서 사용함
    let id: Int

    // MARK: - 기본 정보
    let title: String

    // MARK: - 영상 정보
    /// 상세 API에서 제공되는 유튜브 전체 URL
    /// 목록 API에서는 내려오지 않을 수 있음
    let videoUrl: String?
    /// 유튜브 영상 ID (목록/상세 API 공통)
    let videoId: String
    /// 유튜브 채널 ID
    /// 목록 API에서는 제공되지만, 상세 API에서는 없을 수 있음
    let channelId: String?
    /// 영상 재생 시간 문자열 (예: "13:10")
    /// 목록 API에서만 제공될 수 있음
    let videoDuration: String?

    // MARK: - 채널 / 조회수 정보
    /// 채널명
    /// 목록 API와 상세 API의 필드명이 다를 수 있음
    let channelName: String
    /// 조회수
    /// 서버에서는 views 또는 viewCount로 내려올 수 있음
    let viewCount: Int

    // MARK: - 요리 정보
    /// 요리 소요 시간 (분 단위)
    let cookingTimeMinutes: Int

    // MARK: - 난이도 / 평점 정보
    /// 목록 API 기준 레시피 난이도 (1~5)
    /// 서버 구현에 따라 0~5로 내려올 수도 있음
    let difficulty: Int?
    /// 상세 API 기준 레시피 난이도 (Double)
    /// UI 표시 시 정수 별점으로 변환해서 사용함
    let level: Double?
    /// 해당 레시피에 대한 평가 개수
    let ratingCount: Int?

    // MARK: - 상세 정보
    /// 레시피 재료 목록 (상세 화면 전용)
    let ingredients: [RecipeIngredient]?
    /// 조리 단계 목록 (상세 화면 전용)
    let steps: [RecipeStep]?
    /// 요약 레시피 제공 여부
    let summaryExists: Bool?

    // MARK: - 카테고리 정보 (프론트 기준 정의)
    /// 서버 값과 1:1 매칭되지 않을 수 있으며, 앱 내부 분류 기준으로 사용함
    let cuisine: CuisineCategory
    let koreanSubCategory: KoreanSubCategory?
    let chineseSubCategory: ChineseSubCategory?
    let japaneseSubCategory: JapaneseSubCategory?
    let westernSubCategory: WesternSubCategory?
    let southeastAsianSubCategory: SoutheastAsianSubCategory?
    
    


    // MARK: - UI 상태값
    /// 북마크 여부
    /// 목록 API에서는 제공되며, 상세 API에서는 없을 수 있어 기본값 false 처리
    var isBookmarked: Bool
    
    /// 채널 프로필 이미지 URL
    let channelProfileImageUrl: String?

    // MARK: - UI 편의 계산 프로퍼티

    /// UI에서 사용할 난이도 별점 값
    /// 목록 난이도를 우선 사용하고, 없으면 상세 난이도(level)로 계산
    var displayDifficultyStars: Int {
        if let difficulty {
            return max(0, min(5, difficulty))
        }
        if let level {
            return max(0, min(5, Int(level.rounded())))
        }
        return 0
    }

    /// 재료 배열이 nil일 경우를 대비한 안전한 접근용 프로퍼티
    var displayIngredients: [RecipeIngredient] {
        ingredients ?? []
    }

    /// 조리 단계 배열이 nil일 경우를 대비한 안전한 접근용 프로퍼티
    var displaySteps: [RecipeStep] {
        steps ?? []
    }

    /// 요약 레시피 제공 여부를 안전하게 판단하기 위한 프로퍼티
    var hasSummary: Bool {
        summaryExists ?? false
    }

    // MARK: - 초기화
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

