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
    var searchText: String = ""
    var filteredSuggestion: [String] = []
    
    let suggestionDummy = ["김밥", "김치찌개", "김김김", "두바이쫀득쿠키", "두쫀붕", "허니콤보"]
    
    func performSearch() {
        if searchText.isEmpty {
            filteredSuggestion = []
        } else {
            filteredSuggestion = suggestionDummy.filter { $0.contains(searchText) }
        }
    }
}
