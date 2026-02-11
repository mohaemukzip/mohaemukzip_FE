//
//  RecipeVideoDetailView.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/11/26.
//

import SwiftUI
import YouTubePlayerKit
import UIKit

struct RecipeVideoDetailView: View {

    let video: RecipeVideo
    let isBookmarkUpdating: Bool
    let isSubmittingCookingComplete: Bool
    let isGeneratingSummary: Bool
    let summaryErrorMessage: String?

    let onTapBookmark: () -> Void
    let onSubmitCookingComplete: (Int) -> Void

    @Environment(\.dismiss)  var dismiss
    @Environment(\.openURL)  var openURL

    @StateObject  var player: YouTubePlayer
    @State  var isCookingCompleteModalPresented: Bool = false
    @State  var selectedRating: Int = 0
    @State  var isSummarySpinnerAnimating: Bool = false

    init(
        video: RecipeVideo,
        isBookmarkUpdating: Bool = false,
        isSubmittingCookingComplete: Bool = false,
        isGeneratingSummary: Bool = false,
        summaryErrorMessage: String? = nil,
        onTapBookmark: @escaping () -> Void,
        onSubmitCookingComplete: @escaping (Int) -> Void = { _ in }
    ) {
        self.video = video
        self.isBookmarkUpdating = isBookmarkUpdating
        self.isSubmittingCookingComplete = isSubmittingCookingComplete
        self.isGeneratingSummary = isGeneratingSummary
        self.summaryErrorMessage = summaryErrorMessage
        self.onTapBookmark = onTapBookmark
        self.onSubmitCookingComplete = onSubmitCookingComplete

        #if DEBUG
        print("[RecipeVideoDetailView] 🧩 init with onTapBookmark")
        #endif

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
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 52)

                playerSection

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection
                        statsSection
                        channelSection
                        Divider().opacity(0.6)
                        ingredientsSection
                        summarySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }

            navigationBar
                .zIndex(10)
                .allowsHitTesting(true)

            if isCookingCompleteModalPresented {
                CookingCompleteReviewModalView(
                    isPresented: $isCookingCompleteModalPresented,
                    selectedRating: $selectedRating,
                    isSubmitting: isSubmittingCookingComplete,
                    onSubmit: { rating in
                        onSubmitCookingComplete(rating)
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isCookingCompleteModalPresented)
        .safeAreaInset(edge: .bottom) { bottomActionBar }
        .toolbar(.hidden, for: .navigationBar)
    }
}
