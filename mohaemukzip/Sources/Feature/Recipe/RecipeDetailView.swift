//
//  RecipeDetailView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/23/26.
//

import SwiftUI
import YouTubePlayerKit

// MARK: -레시피 목록 상세 화면


struct RecipeVideoDetailView: View {

    let video: RecipeVideo

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @StateObject private var player: YouTubePlayer

    init(video: RecipeVideo) {
        self.video = video
        _player = StateObject(
            wrappedValue: YouTubePlayer(
                source: .video(id: video.videoId),
                configuration: .init(
                    fullscreenMode: .system,
                    allowsInlineMediaPlayback: true
                )
            )
        )
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                YouTubePlayerView(player)
                    .aspectRatio(
                        verticalSizeClass == .compact ? nil : 16 / 9,
                        contentMode: verticalSizeClass == .compact ? .fill : .fit
                    )
                    .frame(
                        width: geometry.size.width,
                        height: verticalSizeClass == .compact
                            ? geometry.size.height
                            : geometry.size.width * 9 / 16
                    )
                    .clipped()

                if verticalSizeClass != .compact {
                    Spacer()
                }
            }
            .ignoresSafeArea(
                verticalSizeClass == .compact ? .all : [],
                edges: .all
            )
        }
        .navigationTitle(video.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}



