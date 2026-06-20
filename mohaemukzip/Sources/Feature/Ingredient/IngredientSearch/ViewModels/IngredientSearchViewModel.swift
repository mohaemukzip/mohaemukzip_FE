import SwiftUI
import Combine

@Observable
class IngredientSearchViewModel: ObservableObject {
    var service = IngredientService()
    var viewId: UUID?
    
    var selectedCategory: Category
    var searchText: String = ""
    
    var allIngredients: [IngredientForAddition] = []
    var pageNum: Int = -1
    var isLast: Bool
    var isLoading: Bool
    
    var savedIngredients: [IngredientForAddition] {
            allIngredients.filter { $0.isSaved }
        }
    
    var recentSearchTexts: [RecentSearchIngredient] = []
    
    var selectedIngredientForAddition: IngredientForAddition?
    
    init() {
        self.selectedCategory = .all
        self.isLast = false
        self.isLoading = false
    }
    
    var filteredIngredients: [IngredientForAddition] {
        // 카테고리 필터링
        let categoryFiltered = allIngredients.filter { ingredient in
            selectedCategory == .all || ingredient.category.rawValue == selectedCategory.rawValue
        }
        
        // 검색어 필터링
        if (searchText.isEmpty) {
            return categoryFiltered
        } else {
            
            // MARK: searchText에서 공백 제거
            let processedSearchText = searchText.replacingOccurrences(of: " ", with: "")
            
            return categoryFiltered.filter { ingredient in
                // MARK: 검색된 재료 이름에서도 공백 제거
                let processedName = ingredient.name.replacingOccurrences(of: " ", with: "")
                
                return processedName.localizedCaseInsensitiveContains(processedSearchText)
            }
        }
    }
    
    var savedIngredient: [IngredientForAddition] {
        return allIngredients.filter { ingredient in
            ingredient.isSaved
        }
    }
    
    func resetAndFetchIngredients() async {
        pageNum = 0
        isLast = false
        allIngredients = []
        await fetchNextPage()
    }
    
    func fetchNextPage() async {
        guard !isLoading && !isLast else { return }
        
        isLoading = true
        do {
            let (newItems, page, isLast) = try await service.getIngredients(query: self.searchText,
                                                                            category: self.selectedCategory.forApi,
                                                                            page: self.pageNum)
            
            let uniqueNewItem = newItems.filter { newItem in
                !allIngredients.contains(where: { $0.id == newItem.id} )
            }
            
            self.allIngredients.append(contentsOf: uniqueNewItem)
            self.pageNum = page + 1
            self.isLast = isLast
        } catch {
            print("재료 목록 조회 불가: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchSavedList() async {
        do {
            let savedLists = try await service.getSaved()
            for newItem in savedLists {
                if let index = allIngredients.firstIndex(where: { $0.id == newItem.id }) {
                    allIngredients[index].isSaved = true
                } else {
                    allIngredients.append(newItem)
                }
            }
        } catch {
            print("즐겨찾기 목록 가져올 수 없음: \(error)")
        }
    }
    
    func toggleSaved(id: Int) async {
        do {
            try await service.addSaved(id: id)
            if let index = allIngredients.firstIndex(where: {$0.id == id}) {
                allIngredients[index].isSaved.toggle()
            }
        } catch {
            print("즐겨찾기 목록 수정할 수 없음: \(error)")
        }
    }
    
    func getRecent() async {
        do {
            self.recentSearchTexts = try await service.getRecent()
        } catch {
            print("최근 검색어 목록 조회할 수 없음: \(error)")
        }
    }
    
    func deleteRecent(name: String) async {
        do {
            try await service.deleteRecent(name: name)
        } catch {
            print("최근 검색어 삭제할 수 없음: \(error)")
        }
    }
    
    func ingredientRequest(name: String) async {
        do {
            try await service.ingredientRequest(name: name)
        } catch {
            print("재료 추가 요청할 수 없음: \(error)")
        }
    }
    
    func getRecommendedDate(id: Int) async -> Date? {
        do {
            let dateString = try await service.getRecommendedDate(id: id)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            return formatter.date(from: dateString)
        } catch {
            print("추천 소비기한 받아올 수 없음: \(error)")
            return nil
        }
    }
    
    // 저장 기능 함수
    func toggleIsSaved(for id: Int) {
        if let index = allIngredients.firstIndex(where: {$0.id == id}) {
            allIngredients[index].isSaved.toggle()
        }
    }
    
    // 최근 검색어 삭제 함수
    func deleteRecentSearch(for id: Int) {
        withAnimation(.spring()) {
            recentSearchTexts.removeAll { $0.id == id }
        }
    }
    
    // 최근 검색어를 검색창으로 올리는 함수
    func tapRecentSearch(for id: Int) {
        if let tappedItem = recentSearchTexts.first(where: {$0.id == id}) {
            self.searchText = tappedItem.keyword
        }
    }
    
}
