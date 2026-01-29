//
//  IngredientSearchModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/21/26.
//

import SwiftUI

enum IngredientCategory: String, CaseIterable {
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
}

struct IngredientSearchModel: Identifiable {
    let id: Int
    let name: String
    let amount: String
    let category: String
    var isSaved: Bool = false
}
