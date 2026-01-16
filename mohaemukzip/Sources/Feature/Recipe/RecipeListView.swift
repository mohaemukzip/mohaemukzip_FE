//
//  RecipyView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/16/26.
//
import SwiftUI
import Combine

// MARK: - View

struct RecipeListView: View {
    

    @StateObject private var viewModel: RecipeVideoViewModel
    @Environment(\.dismiss) private var dismiss

    init(category: RecipeCategory) {
        _viewModel = StateObject(wrappedValue: RecipeVideoViewModel(category: category))
    }
    
    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack(spacing: 8) {
            Button {
                dismiss()
            } label: {
                Image("back button")
                    .foregroundColor(.black)
            }
            Spacer().frame(width:2)

            Text("\"\(viewModel.selectedCategory.rawValue)\" 레시피 영상이에요.")
                .font(.PretendardSemibold20)
                .foregroundColor(.black)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.top, 10)
        .padding(.bottom,15)
        .background(Color.white)
    }


    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                LazyVStack(spacing: 50) {
                    ForEach(viewModel.filteredVideos, id: \.id) { video in
                        RecipeVideoCard(video: video)
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
    }
}




struct RecipeVideoCard: View {

    let video: RecipeVideo
    @State private var isBookmarked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 제목 + 북마크 영역
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.PretendardSemibold18)
                        .foregroundColor(.grey900)

                    Text("\(video.channelName) · 조회수 \(video.viewCount.formatted())회")
                        .font(.PretendardRegular14)
                        .foregroundColor(.grey500)
                }

                Spacer()

                Button {
                    isBookmarked.toggle()
                } label: {
                    Image(isBookmarked ? "bookmark.fill" : "bookmark")
                        .renderingMode(.original)
                }
            }
            .padding(.horizontal, 16)

            // 영상 썸네일 영역 (UI 전용)
            Image(video.thumbnailImageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .onTapGesture {
                    isBookmarked.toggle()
                }
        }
    }
}


#Preview {
    RecipeListView(category: .korean)
}
