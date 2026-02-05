//
//  BookmarkedRecipesViewModel.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/3/26.
//

import Foundation
import Combine

final class BookmarkedRecipesViewModel: ObservableObject {

    @Published private(set) var items: [ProfileRecipeCard] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @Published private(set) var togglingIds: Set<Int> = []

    private var currentPage: Int = 0
    private var isLast: Bool = false

    func fetchFirstPage() {
        currentPage = 0
        isLast = false
        items = []
        fetchPage(page: 0)
    }

    func loadNextIfNeeded(currentItem: ProfileRecipeCard) {
        guard !isLoading, !isLast else { return }
        guard let last = items.last else { return }

        if last.id == currentItem.id {
            fetchPage(page: currentPage + 1)
        }
    }

    func toggleBookmark(recipeId: Int) {
        guard !togglingIds.contains(recipeId) else { return }
        guard let index = items.firstIndex(where: { $0.id == recipeId }) else { return }

        // 이 화면은 "저장된 북마크" 목록이므로, 탭하면 즉시 목록에서 제거
        let removedItem = items.remove(at: index)
        togglingIds.insert(recipeId)

        Task { [weak self] in
            guard let self else { return }

            do {
                // 서버 토글 API는 toggle이므로, 여기서는 "해제" 의도를 가지고 호출
                // 응답값(isBookmarked)은 서버 기준 최종 상태
                _ = try await RecipeService.shared.toggleBookmark(recipeId: recipeId)

                await MainActor.run {
                    self.togglingIds.remove(recipeId)
                    // 서버 상태와 완전히 동기화하려면 0페이지를 다시 받아서 렌더링
                    self.fetchFirstPage()
                }
            } catch {
                await MainActor.run {
                    self.togglingIds.remove(recipeId)
                    // 실패 시 UI 롤백 (원래 위치로 복구)
                    self.items.insert(removedItem, at: min(index, self.items.count))
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func fetchPage(page: Int) {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[BookmarkedRecipesVM] ✅ fetchPage START | page=\(page)")

        ProfileService.shared.getBookmarkedRecipes(page: page) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(dtoPage):
                let mapped = dtoPage.recipeList.map {
                    var card = ProfileRecipeCard.from(dto: $0)
                    card.difficulty = Int(($0.difficulty ?? 0).rounded())
                    return card
                }

                DispatchQueue.main.async {
                    if page == 0 {
                        self.items = mapped
                    } else {
                        self.items.append(contentsOf: mapped)
                    }

                    self.currentPage = page
                    self.isLast = dtoPage.isLast
                    self.isLoading = false
                }

                print("[BookmarkedRecipesVM] ✅ fetchPage SUCCESS | page=\(page), added=\(mapped.count), total=\(self.items.count), isLast=\(dtoPage.isLast)")

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[BookmarkedRecipesVM] ❌ fetchPage FAIL | page=\(page), error=\(error)")
            }
        }
    }
}
