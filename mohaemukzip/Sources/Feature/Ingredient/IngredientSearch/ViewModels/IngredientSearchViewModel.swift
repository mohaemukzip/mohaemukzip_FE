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
    @Published var selectedIngredientForAddition: IngredientSearchModel?
    
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
    
    // 저장 기능 함수
    func toggleIsSaved(for id: UUID) {
        if let index = allIngredients.firstIndex(where: {$0.id == id}) {
            allIngredients[index].isSaved.toggle()
        }
    }
    
    // 최근 검색어 삭제 함수
    func deleteRecentSearch(for id: UUID) {
        withAnimation(.spring()) {
            recentSearchText.removeAll { $0.id == id }
        }
    }
    
    // 최근 검색어를 검색창으로 올리는 함수
    func tapRecentSearch(for id: UUID) {
        if let tappedItem = recentSearchText.first(where: {$0.id == id}) {
            self.searchText = tappedItem.name
        }
    }
    
    // 검색창에서 검색 시 최근 검색어에 추가하는 함수
    func addRecentSearch() {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedSearch.isEmpty && !recentSearchText.contains(where: {$0.name == trimmedSearch}) {
            withAnimation {
                recentSearchText.insert(IngredientDetailSearchModel(name: trimmedSearch), at: 0)
            }
            
            if recentSearchText.count > 10 {
                recentSearchText.removeLast()
            }
        }
    }
    
    // 재료 추가 요청 함수
    func sendRequest(name: String) {
        print("서버에 \(name) 재료 요청 전송")
    }
}
