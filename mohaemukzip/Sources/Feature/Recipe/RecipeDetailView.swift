//
//  RecipeDetailView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/23/26.
//

import SwiftUI
import YouTubePlayerKit

// MARK: -레시피 목록 상세 화면

struct RecipeDetailView: View {

    let recipeId: Int
    /// Optional base data from list screen (helps show title/channel immediately)
    let base: RecipeVideo?

    @StateObject private var viewModel: RecipeDetailViewModel

    init(recipeId: Int, base: RecipeVideo? = nil) {
        self.recipeId = recipeId
        self.base = base
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: base))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let recipe = viewModel.recipe {
                RecipeVideoDetailView(video: recipe)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.toggleBookmark()
                            } label: {
                                Image(recipe.isBookmarked ? "bookmark_filled" : "bookmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                            }
                            .accessibilityLabel("북마크")
                        }
                    }
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24, weight: .semibold))
                    Text(viewModel.errorMessage ?? "레시피를 불러오지 못했어요")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            }
        }
        .onAppear {
            viewModel.load(recipeId: recipeId, base: base)
        }
    }
}


struct RecipeVideoDetailView: View {

    let video: RecipeVideo

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
        ScrollView {
            VStack(spacing: 0) {
                playerSection

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
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var playerSection: some View {
        GeometryReader { geometry in
            YouTubePlayerView(player) { state in
                switch state {
                case .idle:
                    ProgressView()
                case .ready:
                    EmptyView()
                case .error:
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("영상을 불러오지 못했어요")
                            .font(.footnote)
                    }
                    .padding(12)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width * 9 / 16)
            .clipped()
        }
        .frame(height: UIScreen.main.bounds.width * 9 / 16)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(video.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)

            Text("조회수 \(formattedViews(video.viewCount))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar")
                        .font(.subheadline)
                    Text("난이도")
                        .font(.subheadline)
                }
                difficultyStars(filledCount: video.displayDifficultyStars)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                    Text("소요시간")
                        .font(.subheadline)
                }
                Text("\(video.cookingTimeMinutes)분")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
    }

    private var channelSection: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: video.channelProfileImageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Circle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            ProgressView().scaleEffect(0.7)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Circle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        )
                @unknown default:
                    Circle()
                        .fill(Color(.systemGray5))
                }
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())

            Text(video.channelName)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("필요한 재료")
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(video.displayIngredients) { ingredient in
                        RecipeIngredientChip(ingredient: ingredient)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("요선생의 요약 레시피")
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)

            if video.hasSummary {
                VStack(spacing: 12) {
                    ForEach(video.displaySteps) { step in
                        RecipeStepCard(step: step)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("요약을 생성 중이에요")
                        .font(.subheadline.weight(.semibold))
                    Text("잠시 후 다시 시도해주세요.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6))
                )
            }
        }
        .padding(.top, 8)
    }

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.6)
            Button {
                // TODO: 완료 액션 연결
            } label: {
                Text("요리 완성")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.orange)
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
            }
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Small UI Helpers

    private func difficultyStars(filledCount: Int) -> some View {
        let filled = max(0, min(5, filledCount))

        return HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < filled ? "star.fill" : "star")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(index < filled ? Color.orange : Color(.systemGray4))
            }
        }
    }

    private func formattedViews(_ views: Int) -> String {
        if views < 10_000 {
            return "\(views)회"
        }

        let value = Double(views) / 10_000.0
        let rounded = (value * 10).rounded() / 10
        let string = rounded.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(rounded))
            : String(rounded)
        return "\(string)만회"
    }
}

// MARK: - Components

private struct RecipeIngredientChip: View {

    let ingredient: RecipeIngredient

    var body: some View {
        VStack(spacing: 4) {
            Text(ingredient.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text("분량 (\(formattedAmount(ingredient.amount))\(ingredient.unit))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 88, height: 64)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
    }

    private func formattedAmount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(value)
    }

    private var backgroundColor: Color {
        ingredient.hasIngredient
            ? Color(.systemGray6)
            : Color(.systemGray4)
    }
}

private struct RecipeStepCard: View {

    let step: RecipeStep

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("STEP \(step.stepNumber)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.orange)

                    Text(step.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text(formattedTime(step.videoTime))
                        .font(.caption.weight(.semibold))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule()
                        .fill(Color(.systemGray5))
                )
            }

            Text(step.description)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = max(0, seconds) / 60
        let s = max(0, seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Preview

#Preview("RecipeDetailView (Dummy via ViewModel)") {
    NavigationStack {
        RecipeDetailView(recipeId: 12, base: .previewBase)
    }
    .environment(\.verticalSizeClass, .regular)
}

#Preview("RecipeVideoDetailView (Filled Detail)") {
    NavigationStack {
        RecipeVideoDetailView(video: .previewDetail)
    }
    .environment(\.verticalSizeClass, .regular)
}

private extension RecipeVideo {

    /// 목록 화면에서 넘어오는 base 형태(= list API에 가까운 형태)
    static var previewBase: RecipeVideo {
        RecipeVideo(
            id: 12,
            title: "초간단 제육볶음 레시피",
            videoUrl: nil,
            videoId: "sHpMVI8wQuk",
            channelId: "UC_KOREAN_002",
            videoDuration: "13:10",
            channelName: "고석현",
            viewCount: 1_250_000,
            cookingTimeMinutes: 15,
            difficulty: 3,
            level: nil,
            ratingCount: nil,
            ingredients: nil,
            steps: nil,
            summaryExists: nil,
            cuisine: .korean,
            koreanSubCategory: .soupStew,
            chineseSubCategory: nil,
            japaneseSubCategory: nil,
            westernSubCategory: nil,
            southeastAsianSubCategory: nil,
            isBookmarked: false,
            channelProfileImageUrl: "https://picsum.photos/seed/goseokhyun/200"
        )
    }

    /// 상세 화면에 필요한 값이 채워진 형태(= detail API에 가까운 형태)
    static var previewDetail: RecipeVideo {
        RecipeVideo(
            id: 12,
            title: "초간단 제육볶음 레시피",
            videoUrl: "https://www.youtube.com/watch?v=sHpMVI8wQuk",
            videoId: "sHpMVI8wQuk",
            channelId: nil,
            videoDuration: nil,
            channelName: "고석현",
            viewCount: 1_250_000,
            cookingTimeMinutes: 15,
            difficulty: nil,
            level: 3.0,
            ratingCount: 0,
            ingredients: [
                RecipeIngredient(id: 3, name: "돼지고기", amount: 400.0, unit: "g", hasIngredient: true),
                RecipeIngredient(id: 7, name: "양배추", amount: 1.0, unit: "개", hasIngredient: false),
                RecipeIngredient(id: 9, name: "양파", amount: 0.5, unit: "개", hasIngredient: true)
            ],
            steps: [
                RecipeStep(stepNumber: 1, title: "고기와 기본 재료 준비하기", description: "돼지고기와 채소를 손질합니다.", videoTime: 304),
                RecipeStep(stepNumber: 2, title: "팬에 고기 볶기", description: "달군 팬에 고기를 볶습니다.", videoTime: 443),
                RecipeStep(stepNumber: 3, title: "양념 넣고 볶기", description: "양념을 넣고 1~2분 더 볶습니다.", videoTime: 650)
            ],
            summaryExists: true,
            cuisine: .korean,
            koreanSubCategory: .soupStew,
            chineseSubCategory: nil,
            japaneseSubCategory: nil,
            westernSubCategory: nil,
            southeastAsianSubCategory: nil,
            isBookmarked: true,
            channelProfileImageUrl: "https://picsum.photos/seed/goseokhyun/200"
        )
    }
}
