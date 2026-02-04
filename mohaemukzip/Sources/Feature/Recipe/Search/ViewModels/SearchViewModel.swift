//
//  SearchViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import Foundation
import Combine

@Observable
class SearchViewModel {
    let service = SearchService()
    var searchText: String = ""
    var filteredSuggestion: [String] = []
    
    var suggestions: [SearchKeyword] = []
    var pageNum: Int = 0
    var isLast: Bool = false
    
    let suggestionDummy = ["김밥", "김치찌개", "김김김", "두바이쫀득쿠키", "두쫀붕", "허니콤보"]
    
    func performSearch() {
        if searchText.isEmpty {
            filteredSuggestion = []
        } else {
            filteredSuggestion = suggestionDummy.filter { $0.contains(searchText) }
        }
    }
    
    func resetAndSearch() async {
        self.suggestions = []
        self.pageNum = 0
        self.isLast = false
        self.searchText = ""
        
        await searchNextPage()
    }
    
    func searchNextPage() async {
        if !isLast && suggestions.isEmpty {
            do {
                let (newItems, isLast) = try await service.getSearchText(keyword: searchText, page: pageNum)
                
                self.suggestions.append(contentsOf: newItems)
                self.isLast = isLast
                self.pageNum += 1
            } catch {
                print("추천어를 불러올 수 없습니다: \(error)")
            }
        }
    }
}
