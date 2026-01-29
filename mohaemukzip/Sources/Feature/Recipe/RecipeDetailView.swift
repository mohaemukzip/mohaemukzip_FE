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
                RecipeVideoDetailView(
                    video: recipe,
                    isBookmarked: recipe.isBookmarked,
                    onTapBookmark: {
                        viewModel.toggleBookmark()
                    }
                )
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
        .navigationBarBackButtonHidden(true)
    }
}


struct RecipeVideoDetailView: View {

    let video: RecipeVideo
    let isBookmarked: Bool
    let onTapBookmark: () -> Void

    @Environment(\.dismiss) private var dismiss

    @StateObject private var player: YouTubePlayer

    // 네비게이션바 북마크는 즉시 반응해야 해서 UI용 상태를 따로 둠
    @State private var isBookmarkedUI: Bool

    // 요리 완료 모달 표시 여부
    @State private var isCookingCompleteModalPresented: Bool = false

    // 사용자가 선택한 체감 난이도(별점). 0이면 미선택 상태
    @State private var selectedRating: Int = 0

    init(
        video: RecipeVideo,
        isBookmarked: Bool = false,
        onTapBookmark: @escaping () -> Void = {}
    ) {
        self.video = video
        self.isBookmarked = isBookmarked
        self.onTapBookmark = onTapBookmark
        _isBookmarkedUI = State(initialValue: isBookmarked)
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
        ZStack {
            // 상단 네비게이션 + 영상 플레이어는 고정, 아래 컨텐츠만 스크롤
            VStack(spacing: 0) {
                navigationBar

                // ✅ 스크롤해도 영상이 고정되도록 ScrollView 바깥에 둠
                playerSection
                    .padding(.top, 8)

                // 아래 정보(제목/통계/재료/요약 레시피)는 스크롤 영역
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

            // ✅ 요리 완료 확인 모달 (별점 선택 후 제출)
            if isCookingCompleteModalPresented {
                CookingCompleteReviewModalView(
                    isPresented: $isCookingCompleteModalPresented,
                    selectedRating: $selectedRating,
                    onSubmit: { rating in
                        // TODO: 서버 연결 시 여기에서 요리 완료 API 호출
                        // - recipeId: video.id (path)
                        // - rating: rating (query)
                        // - 완료 후 홈/통계 갱신 트리거
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
        .onChange(of: isBookmarked) { newValue in
            // 외부(뷰모델)에서 북마크 상태가 갱신되면 UI 상태도 맞춰줌
            isBookmarkedUI = newValue
        }
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
                // UI는 즉시 반응, 실제 상태는 ViewModel에서 동기화
                withAnimation(.easeInOut(duration: 0.15)) {
                    isBookmarkedUI.toggle()
                }
                onTapBookmark()
            } label: {
                ZStack {
                    // 북마크 기본 아이콘 (에셋)
                    Image("bigbookmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    // 북마크 활성화 시, 아이콘 형태 그대로 노란색으로 채움
                    if isBookmarkedUI {
                       Image("bookmark.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
                .frame(width: 36, height: 36)
            }
            .accessibilityLabel("북마크")
            .accessibilityHint("북마크 상태를 변경합니다")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Color(.systemBackground))
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

#Preview("RecipeDetailView (Dummy via ViewModel)") {
    NavigationStack {
        RecipeDetailView(recipeId: 12, base: .previewBase)
    }
    .environment(\.verticalSizeClass, .regular)
}

#Preview("RecipeVideoDetailView (Filled Detail)") {
    NavigationStack {
        RecipeVideoDetailView(
            video: .previewDetail,
            isBookmarked: RecipeVideo.previewDetail.isBookmarked,
            onTapBookmark: {}
        )
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

