import SwiftUI
import Combine
// MARK: - 마이페이지 메인 화면

struct ProfileView: View {

    // MARK: - Properties

    @EnvironmentObject private var viewModel: ProfileViewModel
    @Environment(NavigationRouter.self) private var router

    // ✅ 화면이 다시 보일 때마다 최신 상태로 동기화하기 위한 fetch 타이밍 제어
    // 너무 짧은 간격으로 onAppear가 연속 호출되는 경우를 방지한다.
    @State private var lastFetchAt: Date? = nil

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                profileSection
                pointBannerSection
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 8)
                    .padding(.top, 14)
                activitySection
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 8)
                    .padding(.top, 12)
                supportSection
            }
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
            // ✅ 다른 화면(프로필 수정/저장 목록 등)에서 돌아올 때마다 최신 상태로 동기화
            // - 닉네임/프로필 이미지/최근 조회/저장 레시피 썸네일 등이 바뀔 수 있으니
            //   화면이 다시 보이는 시점에 서버에서 재조회한다.

            // onAppear가 연속 호출될 수 있어 너무 잦은 호출은 짧게 막는다.
            // (예: 스크롤/레이아웃 변화로 인해 재등장처럼 보이는 경우)
            let now = Date()
            if let lastFetchAt, now.timeIntervalSince(lastFetchAt) < 2 {
                return
            }
            lastFetchAt = now

            viewModel.fetchMyPage()
        }
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .alert(
            "오류",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Subviews

private extension ProfileView {

    // 상단 타이틀 + 설정(톱니) 버튼 영역

    var headerSection: some View {
        HStack {
            Text("마이페이지")
                .font(.custom("Pretendard-SemiBold", size: 24))

            Spacer()

            Button {
                router.push(.profileSettings)
            } label: {
                Image("setting")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.black)
            }
            .accessibilityLabel("설정")
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }
    // 프로필 이미지 / 닉네임 / 레벨 표시 영역 (수정 버튼은 추후 연결)
    var profileSection: some View {
        HStack(spacing: 14) {
            ProfileAvatarView(imageUrl: viewModel.myPage.profile.profileImageUrl)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 8) {
                    Text(viewModel.myPage.profile.nickname.isEmpty ? "닉네임" : viewModel.myPage.profile.nickname)
                        .font(.custom("Pretendard-SemiBold", size: 18))

                    Text(viewModel.myPage.profile.levelText)
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color("grey700"))
                        .clipShape(Capsule())
                }

                Text(" ")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray)
                    .frame(height: 1)
            }

            Spacer()

            // NOTE: 닉네임/프로필 사진 수정 화면은 다음 단계에서 구현할 예정
            Button {
                router.push(.profileChange)
            } label: {
                Image("pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    // 다음 레벨까지 남은 집밥 포인트 배너 영역
    var pointBannerSection: some View {
        HStack {
            Spacer()

            Text(viewModel.myPage.pointInfo.remainingScoreText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.75))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color(red: 1.0, green: 0.95, blue: 0.90))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 20)
        .padding(.top, 6)
    }
    // 나의 활동 요약 영역 (최근 조회 / 저장 레시피 미리보기 + 전체 목록 이동)
    var activitySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("나의 활동")
                .font(.custom("Pretendard-SemiBold", size: 18))
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 20)

            activityRowTitle(
                title: "최근 조회한 레시피",
                route: .recentlyViewedRecipes,
                verticalPadding: 10
            )
            .padding(.top, 0)

            if viewModel.myPage.activity.isRecentlyViewedEmpty {
                emptyActivityText("최근 조회한 레시피가 없습니다.")
                    .padding(.top, 8)
            } else {
                recipePreviewScroll(recipes: viewModel.recentlyViewedPreview)
                    .padding(.top, 0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.push(.recentlyViewedRecipes)
                    }
            }

            activityRowTitle(
                title: "저장한 레시피",
                route: .bookmarkedRecipes,
                verticalPadding: 10
            )
            .padding(.top, 0)

            if viewModel.myPage.activity.isBookmarkedEmpty {
                emptyActivityText("저장한 레시피가 없습니다.")
                    .padding(.top, 8)
            } else {
                recipePreviewScroll(recipes: viewModel.bookmarkedPreview)
                    .padding(.top, 0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.push(.bookmarkedRecipes)
                    }
            }
        }
    }
    // 지원/약관 등 하단 메뉴 영역 (추후 실제 화면/링크로 연결)
    var supportSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("지원")
                .font(.custom("Pretendard-SemiBold", size: 18))
                .padding(.horizontal, 20)
                .padding(.top, 12)

            // NOTE: 지원 섹션은 추후 실제 화면/링크로 연결
            ProfileSimpleRow(title: "서비스 이용약관")
            ProfileSimpleRow(title: "개인정보 처리방침")
            ProfileSimpleRow(title: "1:1 문의하기")
        }
    }

    func activityRowTitle(
        title: String,
        route: Route,
        verticalPadding: CGFloat = 10
    ) -> some View {
        Button {
            router.push(route)
        } label: {
            // 우측 '>' 버튼 포함한 라인 전체가 탭 영역
            HStack {
                Text(title)
                    .font(.custom("Pretendard-Medium", size: 16))
                    .foregroundStyle(Color.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, verticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    func recipePreviewScroll(recipes: [ProfileRecipeCard]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(recipes) { recipe in
                    ProfileRecipePreviewCard(recipe: recipe)
                }
            }
            .padding(.horizontal,20)
        }
    }

    func emptyActivityText(_ text: String) -> some View {
        Text(text)
            .font(.PretendardMedium16)
            .foregroundStyle(Color.grey500)
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(.horizontal,40)
            .padding(.bottom,20)
    }

    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.08).ignoresSafeArea()
            ProgressView()
        }
    }
}

// MARK: - 프로필 아바타

private struct ProfileAvatarView: View {

    // MARK: - Properties

    let imageUrl: String

    // MARK: - Body

    var body: some View {
        // 서버에서 내려준 profileImageUrl로 이미지 로딩 (없거나 실패하면 기본 아이콘 표시)
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .empty:
                Image("realprofile")
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        ProgressView()
                    }

            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                Image("realprofile")
                    .resizable()
                    .scaledToFill()

            @unknown default:
                Image("realprofile")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
    }
}

// MARK: - 썸네일 카드(마이페이지 프리뷰)

private struct ProfileRecipePreviewCard: View {

    // MARK: - Properties

    let recipe: ProfileRecipeCard

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                ProfileYouTubeThumbnailView(videoId: recipe.videoId)
                    .frame(width: 160, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(recipe.videoDurationText)
                    .font(.custom("Pretendard-SemiBold", size: 12))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(6)
            }

            Text(recipe.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.black)
                .lineLimit(1)

            Text(recipe.channelName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray)
                .lineLimit(1)
        }
        .frame(width: 160)
    }
}

// MARK: - YouTube 썸네일(최소 구현)

private struct ProfileYouTubeThumbnailView: View {

    // MARK: - Properties

    let videoId: String

    // MARK: - Body

    var body: some View {
        // NOTE: API 응답에 썸네일 URL이 없어서 videoId로 유튜브 썸네일 URL을 생성해서 사용합니다.
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

// MARK: - 공용 Row

private struct ProfileSimpleRow: View {

    // MARK: - Properties

    let title: String

    // MARK: - Body

    var body: some View {
        Button {
            print("[ProfileView] ℹ️ \(title) 탭 - 추후 연결")
        } label: {
            HStack {
                Text(title)
                    .font(.custom("Pretendard-Regular", size: 16))
                    .foregroundStyle(Color.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}




