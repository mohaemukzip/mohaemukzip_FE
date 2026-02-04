//
//  RecentlyViewedRecipesViewModel.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/3/26.
//

import Foundation
import Combine

final class RecentlyViewedRecipesViewModel: ObservableObject {

    @Published private(set) var items: [ProfileRecipeCard] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetch() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[RecentlyViewedRecipesVM] ✅ fetch START")

        ProfileService.shared.getRecentlyViewedRecipes { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(dtoList):
                let mapped = dtoList.map { ProfileRecipeCard.from(dto: $0) }

                DispatchQueue.main.async {
                    self.items = mapped
                    self.isLoading = false
                }

                print("[RecentlyViewedRecipesVM] ✅ fetch SUCCESS | count=\(mapped.count)")

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[RecentlyViewedRecipesVM] ❌ fetch FAIL | error=\(error)")
            }
        }
    }
}
