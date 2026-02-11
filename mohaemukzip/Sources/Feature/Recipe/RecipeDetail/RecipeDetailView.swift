//
//  RecipeDetailView.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/11/26.
//

import SwiftUI

struct RecipeDetailView: View {

    let recipeId: Int
    let base: RecipeVideo?

    @StateObject var viewModel: RecipeDetailViewModel

    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL)  var openURL
    @Environment(TabRouter.self) var tabRouter

    init(recipeId: Int, base: RecipeVideo? = nil) {
        self.recipeId = recipeId
        self.base = base
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: base))
        print("DeatilView init")
    }

    var body: some View {
        Group {
            if let recipe = viewModel.recipe {
                RecipeVideoDetailView(
                    video: recipe,
                    isBookmarkUpdating: viewModel.isBookmarkUpdating,
                    isSubmittingCookingComplete: viewModel.isCompletingCooking,
                    isGeneratingSummary: viewModel.isGeneratingSummary,
                    summaryErrorMessage: viewModel.summaryErrorMessage,
                    onTapBookmark: {
                        print("[RecipeDetailView] ✅ parent onTapBookmark called")
                        viewModel.toggleBookmark()
                    },
                    onSubmitCookingComplete: { rating in
                        viewModel.completeCooking(rating: rating)
                    }
                )
                .id("\(recipe.id)-\(recipe.isBookmarked)")
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.03))
                    }
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24, weight: .semibold))
                    Text(viewModel.errorMessage ?? "레시피를 불러오지 못했어요")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            }
        }
        .onAppear {
            viewModel.load(recipeId: recipeId, base: base)
        }
        .onChange(of: viewModel.shouldDismissAfterComplete) { _, shouldDismiss in
            guard shouldDismiss else { return }
            tabRouter.goHome()
        }
        .navigationBarBackButtonHidden(true)
    }
}
