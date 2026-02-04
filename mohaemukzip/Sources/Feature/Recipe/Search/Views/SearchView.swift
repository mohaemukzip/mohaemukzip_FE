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
                        TextField("재료, 상황, 메뉴 키워드를 입력하세요.", text: $viewModel.searchText)
                            .padding(.leading, 10)
                            .onChange(of: viewModel.searchText) { viewModel.performSearch() }
                        
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
                    ForEach(viewModel.filteredSuggestion, id: \.self) { suggestion in
                        SearchSuggestion(inputText: viewModel.searchText, suggestionText: suggestion)
                            .padding(.horizontal)
                    }
                }
            }.scrollIndicators(.hidden)
        }.padding(.horizontal)
            .padding(.top, 5)
            .navigationBarBackButtonHidden()
    }
}

#Preview {
    SearchView()
        .environment(SearchViewModel())
        .environment(NavigationRouter())
}
