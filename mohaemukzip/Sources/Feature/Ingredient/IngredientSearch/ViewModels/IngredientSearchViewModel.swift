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
    @Published var searchText: String = ""
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
    @Published var recentSearchText: [IngredientDetailSearchModel] = [IngredientDetailSearchModel(name: "대파"),
                                                                  IngredientDetailSearchModel(name: "소파"),
                                                                  IngredientDetailSearchModel(name: "중파")]
    
    var filteredIngredients: [IngredientSearchModel] {
        
        // 카테고리 필터링
        let categoryFiltered = allIngredients.filter { ingredient in
            selectedCategory == .all || ingredient.category == selectedCategory.rawValue
        }
        
        // 검색어 필터링
        if (searchText.isEmpty) {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { ingredient in
                ingredient.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var savedIngredient: [IngredientSearchModel] {
        return allIngredients.filter { ingredient in
            ingredient.isSaved
        }
    }
    
    func toggleIsSaved(for id: UUID) {
        if let index = allIngredients.firstIndex(where: {$0.id == id}) {
            allIngredients[index].isSaved.toggle()
        }
    }
}
