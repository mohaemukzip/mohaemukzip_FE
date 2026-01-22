//
//  IngredientSearchViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/21/26.
//

import SwiftUI
import Combine

class IngredientSearchViewModel: ObservableObject {
    @Published var selectedCategory: IngredientCategory = .all
    @Published var allIngredients: [IngredientSearchModel] = [IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "면"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "두바이", amount: "1기본량(100g)", category: "빵/떡"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "커피", amount: "1기본량(100g)", category: "음료"),
                                                              IngredientSearchModel(name: "대파", amount: "채소", category: "채소"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
                                                              IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품")]
    
    var filteredIngredients: [IngredientSearchModel] {
        if (selectedCategory == .all) {
            return allIngredients
        } else {
            return allIngredients.filter { $0.category == selectedCategory.rawValue }
        }
    }
}
