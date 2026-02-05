//
//  RecentlyViewedRecipesView.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/3/26.
//
import SwiftUI

struct RecentlyViewedRecipesView: View {

    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RecentlyViewedRecipesViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // ===============================
            // 🔽 NEW: 고정 헤더 (로딩/빈 상태에서도 위치 고정)
            // ===============================
            listHeader(title: "최근 조회한 레시피")
                .background(Color.white)
            // ===============================
            // 🔼 END NEW
            // ===============================
            if viewModel.isLoading {
                ProgressView().padding(.top, 20)
            } else if viewModel.items.isEmpty {
                Text("최근 조회한 레시피가 없습니다.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.items) { item in
                        RecipeListRow(recipe: item, showsBookmark: false)
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                router.push(.recipeDetailById(item.id))
                            }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
        // ===============================
        // 🔽 LEGACY: safeAreaInset 기반 헤더 (로딩 시 위치 점프 발생)
        // ===============================
//        .safeAreaInset(edge: .top) {
//            listHeader(title: "최근 조회한 레시피")
//                .background(Color.white)
//        }
        // ===============================
        // 🔼 LEGACY END
        // ===============================
        .navigationBarHidden(true)
        .task {
            viewModel.fetch()
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
    RecentlyViewedRecipesPreviewWrapper()
}

private struct RecentlyViewedRecipesPreviewWrapper: View {
    @State private var router = NavigationRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            RecentlyViewedRecipesView()
                .setupNavigationDestinations()
        }
        .environment(router)
    }
}
