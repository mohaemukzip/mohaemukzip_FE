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

    @Environment(\.dismiss) private var dismiss

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
                RecipeVideoDetailView(
                    video: recipe,
                    isBookmarkUpdating: viewModel.isBookmarkUpdating,
                    isSubmittingCookingComplete: viewModel.isCompletingCooking,
                    onTapBookmark: {
                        print("[RecipeDetailView] ✅ parent onTapBookmark called")
                        viewModel.toggleBookmark()
                    },
                    onSubmitCookingComplete: { rating in
                        viewModel.completeCooking(rating: rating)
                    }
                )
                .id("\(recipe.id)-\(recipe.isBookmarked)")
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
        .onChange(of: viewModel.shouldDismissAfterComplete) { shouldDismiss in
            // 요리 완료 성공 시 이전 화면으로 돌아간다.
            guard shouldDismiss else { return }
            dismiss()
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct RecipeVideoDetailView: View {

    let video: RecipeVideo

    /// 북마크 토글 요청 중 여부 (연타 방지)
    let isBookmarkUpdating: Bool

    /// 요리 완료 제출 중 여부 (API 호출 중)
    /// - Note: 모달에서 제출 중 UX(연타/닫기 방지)를 위해 사용한다.
    let isSubmittingCookingComplete: Bool

    let onTapBookmark: () -> Void
    let onSubmitCookingComplete: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    @StateObject private var player: YouTubePlayer

    // 요리 완료 모달 표시 여부
    @State private var isCookingCompleteModalPresented: Bool = false

    // 사용자가 선택한 체감 난이도(별점). 0이면 미선택 상태
    @State private var selectedRating: Int = 0

    init(
        video: RecipeVideo,
        isBookmarkUpdating: Bool = false,
        isSubmittingCookingComplete: Bool = false,
        onTapBookmark: @escaping () -> Void,
        onSubmitCookingComplete: @escaping (Int) -> Void = { _ in }
    ) {
        self.video = video
        self.isBookmarkUpdating = isBookmarkUpdating
        self.isSubmittingCookingComplete = isSubmittingCookingComplete
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
            // 메인 컨텐츠
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 52) // 네비게이션 바 높이만큼 공간 확보

                // 영상 플레이어
                playerSection
                    .padding(.top, 8)

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

            // 상단 네비게이션 바 (터치 우선권 확보)
            navigationBar
                .zIndex(10)
                .allowsHitTesting(true)

            // ✅ 요리 완료 확인 모달 (별점 선택 후 제출)
            if isCookingCompleteModalPresented {
                CookingCompleteReviewModalView(
                    isPresented: $isCookingCompleteModalPresented,
                    selectedRating: $selectedRating,
                    isSubmitting: isSubmittingCookingComplete,
                    onSubmit: { rating in
                        // 요리 완료 제출
                        // - Note: 성공 시 상위 View(RecipeDetailView)에서 dismiss 처리한다.
                        onSubmitCookingComplete(rating)
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isCookingCompleteModalPresented)
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .toolbar(.hidden, for: .navigationBar)
        // 북마크 상태는 video.isBookmarked에서 직접 반영됨
    }

    // MARK: - Sections (화면 구성 단위)
    // 화면을 구성하는 주요 섹션들을 아래에 모아두었어요.
    // (네비게이션/플레이어/헤더/통계/채널/재료/요약 레시피/하단 버튼)

    /// 상단 네비게이션 바 (뒤로가기 / 북마크)
    private var navigationBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image( "backbutton")
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

    /// 유튜브 플레이어 영역 (16:9 비율 고정)
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
            .allowsHitTesting(false)
            .frame(width: geometry.size.width, height: geometry.size.width * 9 / 16)
            .clipped()
        }
        .frame(height: UIScreen.main.bounds.width * 9 / 16)
    }

    /// 레시피 제목 + 조회수
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

    /// 난이도 / 소요시간 정보
    private var statsSection: some View {
        HStack(spacing: 0) {
            VStack(spacing: 10) {
                HStack(spacing: 5) {
                    Image("difficult")
                    Text("난이도")
                        .font(.custom("Pretendard-Regular", size: 14))
                        .foregroundStyle(Color("grey700"))
                }
                difficultyStars(filledCount: video.displayDifficultyStars)
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

    /// 채널 정보 (프로필 이미지 + 채널명)
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
    }

    /// 필요한 재료 (가로 스크롤 칩)
    private var ingredientsSection: some View {
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

    /// 요선생의 요약 레시피 (STEP 카드 리스트)
    private var summarySection: some View {
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

    /// 하단 고정 버튼 영역 (요리 완성)
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.6)
            Button {
                // 요리 완료 버튼을 누르면 확인 모달을 띄움
                // (별점 선택 후에만 제출 가능)
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

    // MARK: - Player Controls (플레이어 제어)
    // 타임스탬프(초)를 눌렀을 때 해당 시점으로 이동(seek)시키기 위한 함수들

    /// Seek the YouTube player to a specific time (in seconds) and start playing.
    private func seekToTime(_ seconds: Int) {
        Task {
            do {
                try await player.seek(
                    to: Measurement(value: Double(max(0, seconds)), unit: UnitDuration.seconds),
                    allowSeekAhead: true
                )
                try await player.play()
            } catch {
                // Intentionally ignore errors (e.g., player not ready yet)
            }
        }
    }

    
    // 별점 표시, 조회수 포맷 등 화면에서 자주 쓰는 작은 유틸들을 모아둠

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



// MARK: - Components (재사용 컴포넌트)
// 재료 칩, STEP 카드처럼 여러 번 쓰이는 뷰를 분리해둠

private struct RecipeIngredientChip: View {

    let ingredient: RecipeIngredient

    // 재료 1개를 보여주는 칩(보유/미보유 배경색 분기)
    var body: some View {
        VStack(spacing: 4) {
            Text(ingredient.name)
                .font(
                Font.custom("Pretendard", size: 14)
                .weight(.medium)
                )

            Text("분량 (\(formattedAmount(ingredient.amount))\(ingredient.unit))")
                .font(Font.custom("Pretendard", size: 13))
                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
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
            ? Color(red: 0.98, green: 0.98, blue: 0.98)
            : Color("grey200")
    }
}

private struct RecipeStepCard: View {

    let step: RecipeStep
    let onTapTimestamp: (Int) -> Void

    // STEP 카드 1개 (타임스탬프 누르면 해당 시점으로 이동)
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("STEP \(step.stepNumber)")
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundStyle(Color.orange)

                    Text(step.title)
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundStyle(.primary)
                }

                Spacer()

                Button {
                    onTapTimestamp(step.videoTime)
                } label: {
                    HStack(spacing: 0) {
                        Image("play.arrow.filled")
                        Text(formattedTime(step.videoTime))
                            .font(.custom("Pretendard-Medium", size: 14))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
                .padding(.trailing, 8)
                .padding(.vertical, 2)
                .background(Color(red: 0.29, green: 0.28, blue: 0.28))
                .cornerRadius(30)
            }

            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 339, height: 1)
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))

            Text(step.description)
                .font(.custom("Pretendard-Regular", size: 16))
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

#Preview("RecipeDetailView") {
    NavigationStack {
        RecipeDetailView(
            recipeId: 1,
            base: RecipeVideo(
                id: 1,
                title: "프리뷰용 제육볶음",
                videoUrl: nil,
                videoId: "sHpMVI8wQuk",
                channelId: "UC_TEST",
                videoDuration: "10:00",
                channelName: "프리뷰 채널",
                viewCount: 12_345,
                cookingTimeMinutes: 20,
                difficulty: 3,
                level: nil,
                ratingCount: nil,
                ingredients: [],
                steps: [],
                summaryExists: false,
                cuisine: .korean,
                koreanSubCategory: .soupStew,
                chineseSubCategory: nil,
                japaneseSubCategory: nil,
                westernSubCategory: nil,
                southeastAsianSubCategory: nil,
                isBookmarked: false,
                channelProfileImageUrl: nil
            )
        )
    }
}
