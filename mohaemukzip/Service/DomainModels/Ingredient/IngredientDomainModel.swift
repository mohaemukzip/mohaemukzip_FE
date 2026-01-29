//
//  IngredientDomainModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/29/26.
//

import Foundation

enum Category: String, CaseIterable {
    case all = "ALL"
    case dairy = "PROCESSED_DAIRY"
    case meatEgg = "MEAT_EGG"
    case grainNut = "GRAIN_NUT"
    case fruit = "FRUIT"
    case noodle = "NOODLE"
    case breadRiceCake = "BREAD_CAKE"
    case beverage = "BEVERAGE"
    case vegetable = "VEGETABLE"
    case seafood = "SEAFOOD"
    case seasoning = "SEASONING"
    case snack = "SNACK"
    case etc = "ETC"
    
    var forDisplay: String {
        switch self {
        case .all: return "전체"
        case .dairy: return "가공/유제품"
        case .meatEgg: return "육류/계란"
        case .grainNut: return "곡물/견과류"
        case .fruit: return "과일"
        case .noodle: return "면"
        case .breadRiceCake: return "빵/떡"
        case .beverage: return "음료"
        case .vegetable: return "채소"
        case .seafood: return "해산물"
        case .seasoning: return "조미료/양념"
        case .snack: return "간식"
        case .etc: return "기타"
        }
    }
}

struct IngredientForAddition: Identifiable {
    let id: Int
    let name: String
    let category: Category
    let unit: String
    let weight: Int
}
