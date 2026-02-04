//
//  VideoListView.swift
//  mohaemukzip
//
//  Created by 이한결 on 2/2/26.
//

import SwiftUI

struct VideoListView: View {
    @Environment(RecipeVideoViewModel.self) var viewModel
    @Environment(NavigationRouter.self) var router
    
    var body: some View {
        VStack {
            HStack {
                Button( action: { router.pop() } ) {
                    Image("backbutton")
                        .foregroundStyle(.grey700)
                }
                Spacer()
            }
            
            ScrollView {
                LazyVStack(spacing: 40) {
                    ForEach(viewModel.searchedVideos) { video in
                        NavigationLink(value: Route.recipeDetail(video)) {
                            RecipeVideoCard(video: video)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 16)
            }
        }.padding(.horizontal)
    }
}

#Preview {
    VideoListView()
        .environment(RecipeVideoViewModel())
}
