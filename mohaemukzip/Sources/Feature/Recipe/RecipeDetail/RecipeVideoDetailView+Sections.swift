import SwiftUI
import YouTubePlayerKit
import UIKit

extension RecipeVideoDetailView {

    // MARK: - 네비바
    var navigationBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image("backbutton")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("뒤로")

            Spacer()

            Button {
                #if DEBUG
                print("[RecipeDetailView] 🔘 bookmark button tapped")
                #endif
                onTapBookmark()
                #if DEBUG
                print("[RecipeDetailView] ✅ onTapBookmark closure invoked")
                #endif
            } label: {
                ZStack {
                    Image("bookmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    if video.isBookmarked {
                        Image("bookmark.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }

                    if isBookmarkUpdating {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }
                .frame(width: 36, height: 36)
            }
            .disabled(isBookmarkUpdating)
            .accessibilityLabel("북마크")
            .accessibilityHint("북마크 상태를 변경합니다")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .allowsHitTesting(true)
    }

    // MARK: - Player
    var playerSection: some View {
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
        .allowsHitTesting(true)
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipped()
        .padding(.bottom, 2)
    }

    // MARK: - Header
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(video.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)

            Text("조회수 \(RecipeDetailFormatters.formattedViews(video.viewCount))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Stats
    var statsSection: some View {
        HStack(spacing: 0) {
            VStack(spacing: 10) {
                HStack(spacing: 5) {
                    Image("difficult")
                    Text("난이도")
                        .font(.custom("Pretendard-Regular", size: 14))
                        .foregroundStyle(Color("grey700"))
                }
                DifficultyStarsView(filledCount: video.displayDifficultyStars)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 10) {
                HStack(spacing: 5) {
                    Image("clock")
                    Text("소요시간")
                        .font(.custom("Pretendard-Regular", size: 14))
                        .foregroundStyle(Color("grey700"))
                }
                Text("\(video.cookingTimeMinutes)분")
                    .font(.custom("Pretendard-Regular", size: 16))
                    .foregroundStyle(Color("grey900"))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.grey50))
        )
    }

    // MARK: - Channel
    var channelSection: some View {
        Button {
            openChannelHome(channelId: video.channelId)
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: video.channelProfileImageUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color(.systemGray5))
                            .overlay(ProgressView().scaleEffect(0.7))
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Circle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            )
                    @unknown default:
                        Circle().fill(Color(.systemGray5))
                    }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())

                Text(video.channelName)
                    .font(.custom("Pretendard-Regular", size: 14))
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Ingredients
    var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("필요한 재료")
                .font(.custom("Pretendard-SemiBold", size: 18))
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

    // MARK: - Summary
    var summarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("요선생의 요약 레시피")
                .font(.custom("Pretendard-SemiBold", size: 18))
                .foregroundStyle(.primary)

            if video.hasSummary {
                VStack(spacing: 12) {
                    ForEach(video.displaySteps) { step in
                        RecipeStepCard(
                            step: step,
                            onTapTimestamp: { seconds in
                                seekToTime(seconds)
                            }
                        )
                    }
                }
            } else {
                VStack(spacing: 14) {
                    Spacer(minLength: 8)

                    Image("summary")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)

                    if isGeneratingSummary {
                        VStack(spacing: 10) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 22, weight: .semibold))
                                .rotationEffect(.degrees(isSummarySpinnerAnimating ? 360 : 0))
                                .animation(
                                    .linear(duration: 0.9).repeatForever(autoreverses: false),
                                    value: isSummarySpinnerAnimating
                                )
                                .onAppear { isSummarySpinnerAnimating = true }
                                .onDisappear { isSummarySpinnerAnimating = false }

                            Text("[로딩중]")
                                .font(.subheadline.weight(.semibold))
                                .multilineTextAlignment(.center)

                            Text("요선생이 레시피 핵심만 정리하고 있어요.\n조금만 기다리면 바로 확인할 수 있어요!")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    } else if let message = summaryErrorMessage {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.secondary)

                            Text(message)
                                .font(.subheadline.weight(.semibold))
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        VStack(spacing: 10) {
                            ProgressView()
                            Text("요약을 준비 중이에요")
                                .font(.subheadline.weight(.semibold))
                                .multilineTextAlignment(.center)
                        }
                    }

                    Spacer(minLength: 8)
                }
                .onAppear { isSummarySpinnerAnimating = false }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                )
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Bottom Action Bar
    var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.6)
            Button {
                selectedRating = 0
                isCookingCompleteModalPresented = true
            } label: {
                Text("요리 완료")
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

    // MARK: - Channel Navigation
    func openChannelHome(channelId: String?) {
        let trimmed = (channelId ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        if let appURL = URL(string: "youtube://www.youtube.com/channel/\(trimmed)"),
           UIApplication.shared.canOpenURL(appURL) {
            openURL(appURL)
            return
        }

        if let webURL = URL(string: "https://www.youtube.com/channel/\(trimmed)") {
            openURL(webURL)
        }
    }

    // MARK: - Player Controls
    func seekToTime(_ seconds: Int) {
        Task {
            do {
                try await player.seek(
                    to: Measurement(value: Double(max(0, seconds)), unit: UnitDuration.seconds),
                    allowSeekAhead: true
                )
                try await player.play()
            } catch {
                // ignore
            }
        }
    }
}
