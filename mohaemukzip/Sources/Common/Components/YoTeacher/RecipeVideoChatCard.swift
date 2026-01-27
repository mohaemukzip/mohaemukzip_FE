//
//  RecipeVideoChatCard.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/25/26.
//

import SwiftUI

struct RecipeVideoChatCard: View {
    let video: RecipeVideo
    var body: some View {
        ThumbnailView(videoId: video.videoId, durationText: video.videoDuration ?? "")
            .frame(width: 160, height: 96)
            .cornerRadius(4)
            .clipped()
    }
}

private struct ThumbnailView: View {

    let videoId: String
    let durationText: String

    @State private var useFallbackHQ = false

    private var maxResURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoId)/maxresdefault.jpg")
    }

    private var hqURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg")
    }

    private var currentURL: URL? {
        useFallbackHQ ? hqURL : maxResURL
    }

    var body: some View {
        ZStack {
            AsyncImage(url: currentURL) { phase in
                switch phase {
                case .empty:
                    Color.black.opacity(0.12)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    // maxres가 없는 영상들이 많아서 실패하면 hq로 fallback
                    Color.black.opacity(0.12)
                        .onAppear {
                            if !useFallbackHQ {
                                useFallbackHQ = true
                            }
                        }

                @unknown default:
                    Color.black.opacity(0.12)
                }
            }
            .clipped()

            //  재생 시간 (우측 하단 오버레이)
            if !durationText.isEmpty {
                Text(durationText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RecipeVideoChatCard(video: RecipeVideo(id: 1, title: "추천 레시피", videoId: "sHpMVI8wQuk", channelName: "요선생", viewCount: 1000, cookingTimeMinutes: 15, cuisine: .korean))
    
}
