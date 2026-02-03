//
//  BookmarkedRecipesView.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/3/26.
//

import SwiftUI

struct BookmarkedRecipesView: View {

    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BookmarkedRecipesViewModel()

    var body: some View {
        VStack(spacing: 0) {
            listHeader(title: "저장한 레시피")

            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView().padding(.top, 20)
            } else if viewModel.items.isEmpty {
                Text("저장한 레시피가 없습니다.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.items) { item in
                        RecipeListRow(recipe: item, showsBookmark: true)
                            .listRowSeparator(.hidden)
                            .onAppear {
                                viewModel.loadNextIfNeeded(currentItem: item)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // TODO: 여기서 RecipeDetailView로 라우팅 연결
                            }
                    }

                    if viewModel.isLoading && !viewModel.items.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarHidden(true)
        .task {
            viewModel.fetchFirstPage()
        }
        .alert(
            "오류",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func listHeader(title: String) -> some View {
        HStack(spacing: 8) {
            Button {
                router.pop()
                dismiss()
            } label: {
                Image("backbutton")
                    .frame(width: 44, height: 44)
            }

            Text(title)
                .font(.custom("Pretendard-SemiBold", size: 18))
                .foregroundStyle(Color.black)

            Spacer()
        }
        .padding(.horizontal, 5)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

#Preview {
    BookmarkedRecipesPreviewWrapper()
}

private struct BookmarkedRecipesPreviewWrapper: View {
    @State private var router = NavigationRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            BookmarkedRecipesView()
                .setupNavigationDestinations()
        }
        .environment(router)
    }
}
