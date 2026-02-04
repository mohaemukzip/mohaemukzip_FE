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

    private func fetchPage(page: Int) {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[BookmarkedRecipesVM] ✅ fetchPage START | page=\(page)")

        ProfileService.shared.getBookmarkedRecipes(page: page) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(dtoPage):
                let mapped = dtoPage.recipeList.map { ProfileRecipeCard.from(dto: $0) }

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
