//
//  VideoListView.swift
//  mohaemukzip
//
//  Created by 이한결 on 2/2/26.
//

import SwiftUI

// TODO: SearchView에서 검색 후 이쪽 뷰로 넘어오게 하기

struct VideoListView: View {
    @Environment(NavigationRouter.self) var router
    @Environment(SearchViewModel.self) var viewModel
    @ObservedObject var recipeVideoVM: RecipeVideoViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button( action: { router.pop() } ) {
                    Image("backbutton")
                        .foregroundStyle(.grey700)
                }
                Spacer()
            }.padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                LazyVStack(spacing: 40) {
                    ForEach(viewModel.searchedVideos) { video in
                        NavigationLink(value: Route.recipeDetail(video)) {
                            RecipeVideoCard(video: video, onTapBookmark: {recipeVideoVM.toggleBookmark(recipeId: video.id)})
                                .padding(.top, 20)
                                .onAppear {
                                    if video.id == viewModel.searchedVideos.last?.id {
                                    Task { await viewModel.getNextSearchedVideos() }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 16)
            }.scrollIndicators(.hidden)
        }.task(id: viewModel.selectedDishId) {
                await viewModel.resetAndGetSearchedVideos()
            }
            .navigationBarBackButtonHidden()
    }
}

#Preview {
    VideoListView(recipeVideoVM: RecipeVideoViewModel())
        .environment(NavigationRouter())
        .environment(SearchViewModel())
}
