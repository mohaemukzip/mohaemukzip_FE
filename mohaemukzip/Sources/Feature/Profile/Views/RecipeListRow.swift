//
//  RecipeListRow.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/3/26.
//

import SwiftUI

struct RecipeListRow: View {

    let recipe: ProfileRecipeCard
    let showsBookmark: Bool
    let onTapBookmark: (() -> Void)?

    init(
        recipe: ProfileRecipeCard,
        showsBookmark: Bool = true,
        onTapBookmark: (() -> Void)? = nil
    ) {
        self.recipe = recipe
        self.showsBookmark = showsBookmark
        self.onTapBookmark = onTapBookmark
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                YouTubeThumbnailView(videoId: recipe.videoId)
                    .frame(width: 160, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(recipe.videoDurationText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.custom("Pretendard-Medium", size: 16))
                    .foregroundStyle(Color("grey900"))
                    .lineLimit(1)

                Text(recipe.channelName)
                    .font(.custom("Pretendard-Regular", size: 13))
                    .foregroundStyle(Color("grey500"))
                    .lineLimit(1)

                Text("조회수 \(recipe.viewCountText)")
                    .font(.custom("Pretendard-Regular", size: 13))
                    .foregroundStyle(Color("grey500"))
            }

            Spacer()

            if showsBookmark {
                if let onTapBookmark {
                    Button {
                        onTapBookmark()
                    } label: {
                        Image("bookmark.fill")
                            .foregroundStyle(Color.black)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image( "bookmark.fill")
                        .foregroundStyle(Color.black)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - YouTube Thumbnail (공용)

private struct YouTubeThumbnailView: View {
    let videoId: String

    var body: some View {
        let url = URL(string: "https://i.ytimg.com/vi/\(videoId)/mqdefault.jpg")

        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .overlay { ProgressView() }

            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))

            @unknown default:
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
            }
        }
        .clipped()
    }
}
