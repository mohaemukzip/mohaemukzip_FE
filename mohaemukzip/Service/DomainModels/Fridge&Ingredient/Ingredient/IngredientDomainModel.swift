import Foundation

enum Category: String, CaseIterable, Equatable {
    case all = "전체"
    case dairy = "가공/유제품"
    case meatEgg = "육류/계란"
    case grainNut = "곡물/견과류"
    case fruit = "과일"
    case noodle = "면"
    case breadRiceCake = "빵/떡"
    case beverage = "음료"
    case vegetable = "채소"
    case seafood = "해산물"
    case seasoning = "조미료/양념"
    case snack = "간식"
    case etc = "기타"
    
    var forApi: String {
        switch self {
        case .all:
            return ""
        case .dairy:
            return "PROCESSED_DAIRY"
        case .meatEgg:
            return "MEAT_EGG"
        case .grainNut:
            return "GRAIN_NUT"
        case .fruit:
            return "FRUIT"
        case .noodle:
            return "NOODLE"
        case .breadRiceCake:
            return "BREAD_CAKE"
        case .beverage:
            return "BEVERAGE"
        case .vegetable:
            return "VEGETABLE"
        case .seafood:
            return "SEAFOOD"
        case .seasoning:
            return "SEASONING"
        case .snack:
            return "SNACK"
        case .etc:
            return "ETC"
        }
    }
}

struct IngredientForAddition: Identifiable {
    let id: Int
    let name: String
    let category: Category
    let unit: String
    let amount: Double
    var isSaved: Bool
}

struct RecentSearchIngredient: Identifiable {
    let id: Int
    let keyword: String
}

struct SavedIngredient: Identifiable {
    let id: Int
    let name: String
    let category: Category
    let unit: String
    let amount: Double
    let isSaved: Bool
}
