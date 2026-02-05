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
    
    // MARK: 추천검색어
    var suggestions: [SearchKeyword] = []
    var isLastSuggestion: Bool = false
    var pageNumForSuggestion: Int = 0
    
    // MARK: 레시피비디오
    var searchedVideos: [RecipeVideo] = []
    var selectedDishId: Int?
    var isLastVideo: Bool = false
    var pageNumForVideo: Int = 0
    
    func resetAndSearch() async {
        self.suggestions = []
        self.pageNumForSuggestion = 0
        self.isLastSuggestion = false
        
        await searchNextPage()
    }
    
    func searchNextPage() async {
        if !isLastSuggestion {
            do {
                let (newItems, isLast) = try await service.getSearchText(keyword: searchText, page: pageNumForSuggestion)
                
                self.suggestions.append(contentsOf: newItems)
                self.isLastSuggestion = isLast
                self.pageNumForSuggestion += 1
            } catch {
                print("추천어를 불러올 수 없습니다: \(error)")
            }
        }
    }
    
    func resetAndGetSearchedVideos() async {
        self.searchedVideos = []
        self.pageNumForVideo = 0
        self.isLastVideo = false
        
        await getNextSearchedVideos()
    }
    
    func getNextSearchedVideos() async {
        if !isLastVideo {
            do {
                let (newItems, isLast) = try await service.getResultForKeyword(dishId: self.selectedDishId ?? 1, page: self.pageNumForVideo)
                
                self.searchedVideos.append(contentsOf: newItems)
                self.isLastVideo = isLast
                self.pageNumForVideo += 1
            } catch {
                print("검색된 레시피 목록을 불러올 수 없습니다: \(error)")
            }
        }
    }
}
