//
//  RecipeDetailView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/23/26.
//

import SwiftUI
import YouTubePlayerKit

// MARK: - 레시피 상세 화면
/// 레시피 목록에서 선택한 항목의 상세 화면
/// 영상 재생, 레시피 정보, 재료, 요약 스텝을 한 화면에 표시
/// 북마크 및 요리 완료 액션 제공

struct RecipeDetailView: View {

    /// 상세 조회 대상 레시피 id
    let recipeId: Int

    /// 목록 화면에서 전달받은 기본 데이터
    /// 상세 API 응답 전 초기 UI 표시 목적
    let base: RecipeVideo?

    /// 상세 화면 상태 및 비즈니스 로직 관리
    @StateObject private var viewModel: RecipeDetailViewModel

    /// 네비게이션 뒤로가기 dismiss 핸들러
    @Environment(\.dismiss) private var dismiss

    /// RecipeDetailView 초기화
    /// base 데이터가 있으면 즉시 화면 일부 표시
    init(recipeId: Int, base: RecipeVideo? = nil) {
        self.recipeId = recipeId
        self.base = base
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: base))
    }

    var body: some View {
        Group {
            /// 화면 상태 분기
            /// - 로딩 중: ProgressView 표시
            /// - 성공: 상세 컨텐츠 렌더링
            /// - 실패: 에러 안내 UI 표시
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let recipe = viewModel.recipe {
                RecipeVideoDetailView(
                    video: recipe,
                    isBookmarkUpdating: viewModel.isBookmarkUpdating,
                    isSubmittingCookingComplete: viewModel.isCompletingCooking,
                    onTapBookmark: {
                        /// 북마크 버튼 탭 이벤트를 ViewModel로 전달
                        print("[RecipeDetailView] ✅ parent onTapBookmark called")
                        viewModel.toggleBookmark()
                    },
                    onSubmitCookingComplete: { rating in
                        /// 요리 완료 제출 이벤트를 ViewModel로 전달
                        viewModel.completeCooking(rating: rating)
                    }
                )
                /// 북마크 상태 변경 시 View 강제 갱신 목적
                .id("\(recipe.id)-\(recipe.isBookmarked)")
            } else {
                /// 데이터 로드 실패 시 에러 안내 UI
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
            /// 화면 최초 진입 시 상세 데이터 로드
            viewModel.load(recipeId: recipeId, base: base)
        }
        .onChange(of: viewModel.shouldDismissAfterComplete) { shouldDismiss in
            /// 요리 완료 성공 후 이전 화면으로 복귀
            guard shouldDismiss else { return }
            dismiss()
        }
        .navigationBarBackButtonHidden(true)
    }
}


// MARK: - 레시피 상세 컨텐츠
/// 영상 플레이어와 레시피 상세 정보를 구성하는 메인 컨텐츠 뷰
/// RecipeDetailView 내부에서 실제 UI 대부분을 담당
struct RecipeVideoDetailView: View {

    /// 표시할 레시피 상세 데이터
    let video: RecipeVideo

    /// 북마크 요청 처리 중 여부
    /// 중복 요청 및 연타 방지 목적
    let isBookmarkUpdating: Bool

    /// 요리 완료 API 요청 처리 중 여부
    /// 모달 UI 비활성화 제어 목적
    let isSubmittingCookingComplete: Bool

    /// 북마크 버튼 탭 이벤트 콜백
    let onTapBookmark: () -> Void

    /// 요리 완료 제출 이벤트 콜백
    let onSubmitCookingComplete: (Int) -> Void

    /// 뒤로가기 dismiss 핸들러
    @Environment(\.dismiss) private var dismiss

    /// 유튜브 플레이어 상태 유지용 객체
    @StateObject private var player: YouTubePlayer

    /// 요리 완료 확인 모달 표시 여부
    @State private var isCookingCompleteModalPresented: Bool = false

    /// 사용자가 선택한 별점 값
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
            /// 네비게이션 바 + 컨텐츠 영역
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 52) // 네비게이션 바 높이만큼 공간 확보

                /// 상단 영상 플레이어 영역
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

            /// 상단 고정 네비게이션 바
            navigationBar
                .zIndex(10)
                .allowsHitTesting(true)

            /// 요리 완료 확인 모달
            if isCookingCompleteModalPresented {
                CookingCompleteReviewModalView(
                    isPresented: $isCookingCompleteModalPresented,
                    selectedRating: $selectedRating,
                    isSubmitting: isSubmittingCookingComplete,
                    onSubmit: { rating in
                        /// 요리 완료 제출 이벤트 상위 뷰로 전달
                        /// 성공 여부에 따른 dismiss는 상위에서 처리
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

    // MARK: - Sections
    /// 화면을 구성하는 주요 UI 섹션 모음

    /// 상단 네비게이션 바
    /// 뒤로가기 및 북마크 액션 제공
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
                /// 북마크 토글 요청
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
            /// 스크롤 제스처와 충돌 방지 목적
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
                /// 요리 완료 확인 모달 표시
                /// 별점 선택 후 제출 가능
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

    // MARK: - Player Controls
    /// 요약 스텝 타임스탬프 선택 시 영상 위치 이동 처리
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

    /// 화면 표시용 유틸 함수 모음
    /// 난이도 별점, 조회수 포맷 처리
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
/// 상세 화면에서 재사용되는 UI 컴포넌트 모음

private struct RecipeIngredientChip: View {

    let ingredient: RecipeIngredient

    /// 재료 정보를 표시하는 칩 UI
    /// 보유 여부에 따라 배경 색상 분기
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

    /// 요약 레시피 STEP 카드 UI
    /// 타임스탬프 버튼 선택 시 영상 이동
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

    //재생 시간 함수 !
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
