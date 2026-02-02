//
//  ProfileView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import SwiftUI
import Combine
// MARK: - 마이페이지 메인 화면

struct ProfileView: View {

    // MARK: - Properties

    @StateObject private var viewModel = ProfileViewModel()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    profileSection
                    pointBannerSection
                    Divider().padding(.top, 14)
                    activitySection
                    Divider().padding(.top, 20)
                    supportSection
                }
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .task {
                // ✅ 화면 진입 시 마이페이지 데이터 로드
                // - 탭 이동/재진입 등으로 여러 번 호출될 수 있어서,
                //   ViewModel 내부에서 isLoading으로 중복 호출을 막고 있습니다.
                // - 빌드 시 콘솔 로그: [ProfileViewModel] fetchMyPage START/SUCCESS/FAIL
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
}

// MARK: - Subviews

private extension ProfileView {

    // 상단 타이틀 + 설정(톱니) 버튼 영역

    var headerSection: some View {
        HStack {
            Text("마이페이지")
                .font(.system(size: 24, weight: .bold))

            Spacer()

            NavigationLink {
                ProfileSettingsView()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20, weight: .semibold))
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
                HStack(spacing: 8) {
                    Text(viewModel.myPage.profile.nickname.isEmpty ? "닉네임" : viewModel.myPage.profile.nickname)
                        .font(.system(size: 18, weight: .bold))

                    Text(viewModel.myPage.profile.levelText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.75))
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
                print("[ProfileView] ✏️ 닉네임/프로필 수정 화면은 추후 연결")
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            .disabled(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    // 다음 레벨까지 남은 집밥 포인트 배너 영역
    var pointBannerSection: some View {
        HStack {
            Text(viewModel.myPage.pointInfo.remainingScoreText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.75))

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
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.top, 18)

            activityRowTitle(
                title: "최근 조회한 레시피",
                destination: RecentlyViewedRecipesView()
            )
            .padding(.top, 14)

            if viewModel.myPage.activity.isRecentlyViewedEmpty {
                emptyActivityText("최근 조회한 레시피가 없습니다.")
                    .padding(.top, 18)
            } else {
                recipePreviewScroll(recipes: viewModel.recentlyViewedPreview)
                    .padding(.top, 12)
            }

            activityRowTitle(
                title: "저장한 레시피",
                destination: BookmarkedRecipesView()
            )
            .padding(.top, 18)

            if viewModel.myPage.activity.isBookmarkedEmpty {
                emptyActivityText("저장한 레시피가 없습니다.")
                    .padding(.top, 18)
            } else {
                recipePreviewScroll(recipes: viewModel.bookmarkedPreview)
                    .padding(.top, 12)
            }
        }
    }
    // 지원/약관 등 하단 메뉴 영역 (추후 실제 화면/링크로 연결)
    var supportSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("지원")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.top, 18)

            // NOTE: 지원 섹션은 추후 실제 화면/링크로 연결
            ProfileSimpleRow(title: "서비스 이용약관")
            ProfileSimpleRow(title: "개인정보 처리방침")
            ProfileSimpleRow(title: "고객센터")
        }
    }

    func activityRowTitle<Destination: View>(title: String, destination: Destination) -> some View {
        NavigationLink {
            destination
        } label: {
            // 우측 '>' 버튼 포함한 라인 전체가 탭 영역
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }

    func recipePreviewScroll(recipes: [ProfileRecipeCard]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(recipes) { recipe in
                    ProfileRecipePreviewCard(recipe: recipe)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    func emptyActivityText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.gray)
            .frame(maxWidth: .infinity, minHeight: 84)
            .padding(.horizontal, 20)
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
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        ProgressView()
                    }

            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()

            case .failure:
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(Color.gray)
                    }

            @unknown default:
                Circle()
                    .fill(Color.gray.opacity(0.2))
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
                    .frame(width: 154, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(recipe.videoDurationText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.75))
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
        .frame(width: 154)
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
                    .font(.system(size: 15, weight: .medium))
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

// MARK: - 설정 상세 화면

struct ProfileSettingsView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    // NOTE: 버전 문자열은 Info.plist에서 읽는 방식으로 교체해도 됩니다.
    private let appVersionText: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "v\(version) (\(build))"
    }()

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            header

            List {
                Section(header: Text("계정")) {
                    NavigationLink {
                        Text("계정 설정 화면은 추후 구현")
                    } label: {
                        Text("계정 설정")
                    }
                }

                Section {
                    Button(role: .none) {
                        print("[ProfileSettingsView] 🚪 로그아웃 탭")
                    } label: {
                        Text("로그아웃")
                    }

                    Button(role: .destructive) {
                        print("[ProfileSettingsView] 🧨 회원탈퇴 탭")
                    } label: {
                        Text("회원탈퇴")
                    }

                    Text(appVersionText)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gray)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarHidden(true)
        .background(Color.white)
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .padding(8)
            }

            Text("설정")
                .font(.system(size: 18, weight: .bold))
                .padding(.leading, 2)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }
}

// MARK: - 최근 조회한 레시피 목록 화면

struct RecentlyViewedRecipesView: View {

    // MARK: - Properties

    @StateObject private var viewModel = RecentlyViewedRecipesViewModel()

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            listHeader(title: "최근 조회한 레시피")

            if viewModel.isLoading {
                ProgressView().padding(.top, 20)
            } else if viewModel.items.isEmpty {
                Text("최근 조회한 레시피가 없습니다.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.items) { item in
                        RecipeListRow(recipe: item)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationBarHidden(true)
        .task {
            // ✅ 최근 조회 목록 최초 로드
            // - 콘솔 로그: [RecentlyViewedRecipesVM] fetch START/SUCCESS/FAIL
            viewModel.fetch()
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

    private func listHeader(title: String) -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.black)
                .padding(.leading, 16)
                .padding(.vertical, 12)
                .onTapGesture {
                    // NavigationStack에서 pop
                    UIApplication.shared.sendAction(
                        #selector(UINavigationController.popViewController(animated:)),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }

            Text(title)
                .font(.system(size: 18, weight: .bold))

            Spacer()
        }
    }
}

final class RecentlyViewedRecipesViewModel: ObservableObject {

    // MARK: - Published

    @Published private(set) var items: [ProfileRecipeCard] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Functions

    func fetch() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[RecentlyViewedRecipesVM] ✅ fetch START")

        ProfileService.shared.getRecentlyViewedRecipes { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(dtoList):
                let mapped = dtoList.map { ProfileRecipeCard.from(dto: $0) }

                DispatchQueue.main.async {
                    self.items = mapped
                    self.isLoading = false
                }

                print("[RecentlyViewedRecipesVM] ✅ fetch SUCCESS | count=\(mapped.count)")

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[RecentlyViewedRecipesVM] ❌ fetch FAIL | error=\(error)")
            }
        }
    }
}

// MARK: - 저장한 레시피 목록 화면

struct BookmarkedRecipesView: View {

    // MARK: - Properties

    @StateObject private var viewModel = BookmarkedRecipesViewModel()

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            listHeader(title: "저장한 레시피")

            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView().padding(.top, 20)
            } else if viewModel.items.isEmpty {
                Text("저장한 레시피가 없습니다.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.items) { item in
                        RecipeListRow(recipe: item)
                            .onAppear {
                                // 마지막 셀에 도달하면 다음 페이지 로드
                                viewModel.loadNextIfNeeded(currentItem: item)
                            }
                    }

                    if viewModel.isLoading && !viewModel.items.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationBarHidden(true)
        .task {
            // ✅ 저장한 레시피 목록 1페이지부터 로드
            // - 페이지네이션은 마지막 셀이 보일 때(loadNextIfNeeded) 다음 페이지를 호출합니다.
            // - 콘솔 로그: [BookmarkedRecipesVM] fetchPage START/SUCCESS/FAIL
            viewModel.fetchFirstPage()
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

    private func listHeader(title: String) -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.black)
                .padding(.leading, 16)
                .padding(.vertical, 12)
                .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UINavigationController.popViewController(animated:)),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }

            Text(title)
                .font(.system(size: 18, weight: .bold))

            Spacer()
        }
    }
}

final class BookmarkedRecipesViewModel: ObservableObject {

    // MARK: - Published

    @Published private(set) var items: [ProfileRecipeCard] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Pagination

    private var currentPage: Int = 0
    private var isLast: Bool = false

    // MARK: - Functions

    func fetchFirstPage() {
        currentPage = 0
        isLast = false
        items = []
        fetchPage(page: currentPage)
    }

    func loadNextIfNeeded(currentItem: ProfileRecipeCard) {
        guard !isLoading, !isLast else { return }
        guard let last = items.last else { return }

        // 마지막 아이템이 화면에 나타났다면 다음 페이지 요청
        if last.id == currentItem.id {
            fetchPage(page: currentPage + 1)
        }
    }

    private func fetchPage(page: Int) {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[BookmarkedRecipesVM] ✅ fetchPage START | page=\(page)")

        ProfileService.shared.getBookmarkedRecipes(page: page) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(dtoPage):
                let mapped = dtoPage.recipeList.map { ProfileRecipeCard.from(dto: $0) }

                DispatchQueue.main.async {
                    if page == 0 {
                        self.items = mapped
                    } else {
                        self.items.append(contentsOf: mapped)
                    }

                    self.currentPage = page
                    self.isLast = dtoPage.isLast
                    self.isLoading = false
                }

                print("[BookmarkedRecipesVM] ✅ fetchPage SUCCESS | page=\(page), added=\(mapped.count), total=\(self.items.count), isLast=\(dtoPage.isLast)")

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[BookmarkedRecipesVM] ❌ fetchPage FAIL | page=\(page), error=\(error)")
            }
        }
    }
}

// MARK: - 리스트 Row 공용

private struct RecipeListRow: View {

    // MARK: - Properties

    let recipe: ProfileRecipeCard

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                ProfileYouTubeThumbnailView(videoId: recipe.videoId)
                    .frame(width: 120, height: 68)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(recipe.videoDurationText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .lineLimit(1)

                Text(recipe.channelName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .lineLimit(1)

                Text("조회수 \(recipe.viewCountText)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            Image(systemName: recipe.isBookmarked ? "bookmark.fill" : "bookmark")
                .foregroundStyle(recipe.isBookmarked ? Color.black : Color.gray)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProfileView()
}
