//
//  SearchView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import SwiftUI

struct SearchView: View {
    @Environment(SearchViewModel.self) var viewModel
    @Environment(NavigationRouter.self) var router
    @ObservedObject var recipeVideoVM: RecipeVideoViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        VStack {
            HStack(spacing: 30) {
                Button( action: { router.pop(); viewModel.searchText = "" } ) { Image("backbutton") }
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.grey100)
                        .frame(height: 44)
                    HStack {
                        TextField("먹고 싶은 메뉴를 검색해보세요.", text: $viewModel.searchText)
                            .padding(.leading, 10)
                        
                        if !viewModel.searchText.isEmpty {
                            Button ( action: { viewModel.searchText = "" } ) {
                                Image("icon-x")
                                    .foregroundStyle(.grey500)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                }
            }
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.suggestions) { suggestion in
                        
                        Button ( action: { viewModel.selectedDishId = suggestion.id
                                           router.push(.videoList(recipeVideoVM)) } ) {
                            SearchSuggestion(inputText: viewModel.searchText, suggestionText: suggestion.text)
                                // MARK: onAppear 활용해서 무한스크롤 구현
                                .onAppear {
                                    if suggestion.id == viewModel.suggestions.last?.id {
                                        Task { await viewModel.searchNextPage() }
                                    }
                                }
                            }
                        
                        }
                }
            }.scrollIndicators(.hidden)
        }.padding(.horizontal)
            .padding(.top, 5)
            .navigationBarBackButtonHidden()
            .task(id: viewModel.searchText) {
                if viewModel.searchText.isEmpty {
                    viewModel.suggestions = []
                    return
                }
                // MARK: 검색어가 입력되는 동안 불필요한 api 호출을 없애기 위한 0.5초 디바운싱
                // MARK: 검색어 입력이 멈추고 0.5초 이후 api 호출
                try? await Task.sleep(nanoseconds: 500_000_000)
                
                if !Task.isCancelled {
                    await viewModel.resetAndSearch()
                }
            }
    }
}

#Preview {
    SearchView(recipeVideoVM: RecipeVideoViewModel())
        .environment(SearchViewModel())
        .environment(NavigationRouter())
}
