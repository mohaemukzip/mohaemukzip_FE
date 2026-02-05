//
//  RecipeListView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/16/26.
//

import SwiftUI

// MARK: - 카테고리별 검색 뷰 !!!
/// 레시피 영상을 탐색하는 메인 목록 화면
/// 상위 카테고리 → 하위 카테고리 선택 구조
/// 선택 상태에 따라 ViewModel의 필터링 결과를 화면에 표시

struct RecipeListView: View {

    /// 레시피 목록 화면 전용 ViewModel
    /// 카테고리 선택 상태 및 필터링된 영상 목록 관리
    @StateObject private var viewModel: RecipeVideoViewModel

    /// 초기 진입 시 지정된 상위 카테고리
    /// 외부 화면에서 특정 카테고리 선택 진입 용도
    private let initialCuisine: CuisineCategory?

    /// 초기 카테고리 적용 여부
    /// onAppear / task 중복 실행 방지 목적
    @State private var didApplyInitialCuisine = false

    // MARK: - Initializers
    /// 기본 진입
    /// 카테고리 미선택 상태로 시작
    init() {
        self.initialCuisine = nil
        _viewModel = StateObject(wrappedValue: RecipeVideoViewModel())
    }

    /// 특정 상위 카테고리 선택 상태로 진입
    init(category: CuisineCategory) {
        self.initialCuisine = category
        _viewModel = StateObject(wrappedValue: RecipeVideoViewModel())
    }

    // MARK: - Category Button Colors
    /// 선택된 카테고리 배경 색상
    private let selectedOrange = Color(red: 1, green: 0.55, blue: 0.14)

    /// 선택되지 않은 카테고리 배경 색상
    private let unselectedGray = Color(red: 0.96, green: 0.96, blue: 0.96)

    /// 하위 카테고리 그리드 레이아웃
    /// 고정 너비 버튼을 1줄에 5개 배치
    private var subCategoryColumns: [GridItem] {
        Array(repeating: GridItem(.fixed(64), spacing: 12, alignment: .center), count: 5)
    }

    /// 앱 전역 네비게이션 라우터
    @Environment(NavigationRouter.self) var router

    /// 요선생 채팅 ViewModel
    @Environment(YoTeacherChatViewModel.self) var yoTeacherVM

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                /// 검색 → 카테고리 → 콘텐츠 순서로 구성된 메인 레이아웃

                // MARK: - Search Entry
                /// 레시피 검색 화면으로 이동하는 진입 버튼
                Button( action: { router.push(.recipeSearch(viewModel)) } ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.grey100)
                            .frame(height: 44)
                        
                        HStack {
                            Text("재료, 상황, 메뉴 키워드를 입력하세요.")
                                .font(.PretendardRegular16)
                                .foregroundStyle(.grey500)
                                .padding(.leading, 10)
                            Spacer()
                            Image("icon-search")
                                .foregroundStyle(.grey500)
                                .padding(.trailing, 10)
                        }
                    }
                }.padding(.horizontal, 16)
                    .padding(.bottom, 16)

                // MARK: - Main Categories
                /// 상위 음식 카테고리 선택 영역
                HStack(alignment: .top, spacing: 12) {
                    categoryButton(.korean)
                    categoryButton(.chinese)
                    categoryButton(.japanese)
                    categoryButton(.western)
                    categoryButton(.southeastAsian)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // MARK: - Sub Categories
                /// 선택된 상위 카테고리에 따라 노출되는 하위 카테고리
                subCategoryGrid

                /// 카테고리 영역과 콘텐츠 영역 시각적 분리
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 8)
                    .padding(.top, 16)
                
                // MARK: - YoTeacher Banner
                /// 하위 카테고리 미선택 상태에서만 노출
                if viewModel.selectedKoreanSubCategory == nil &&
                    viewModel.selectedChineseSubCategory == nil &&
                    viewModel.selectedWesternSubCategory == nil &&
                    viewModel.selectedJapaneseSubCategory == nil &&
                    viewModel.selectedSoutheastAsianSubCategory == nil {
                    YoTeacher(onTap: {router.push(.yoTeacher)} )
                        .padding(.top, 25)
                        .padding(.horizontal, 16)
                }

                // MARK: - Video List
                /// 선택된 상위 + 하위 카테고리 기준 필터링 결과
                ScrollView {
                    LazyVStack(spacing: 40) {
                        ForEach(viewModel.filteredVideos) { video in
                            /// 개별 레시피 영상 카드
                            RecipeVideoCard(
                                video: video,
                                onTapBookmark: {
                                    viewModel.toggleBookmark(recipeId: video.id)
                                }
                            )
                            .contentShape(Rectangle())
                            /// 영상 카드 탭 시 상세 화면 진입
                            .onTapGesture {
                                Task {
                                    if let detail = await viewModel.prepareDetailVideo(recipeId: video.id) {
                                        router.push(.recipeDetail(detail))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            /// 최초 진입 시 initialCuisine 적용
            /// 중복 적용 방지를 위해 플래그 사용
            .task {
                guard !didApplyInitialCuisine else { return }
                didApplyInitialCuisine = true

                if let initialCuisine {
                    viewModel.selectCuisine(initialCuisine)
                }
            }
            // MARK: - YoTeacher Floating Button
            /// 하위 카테고리 선택 이후 노출
            if !(viewModel.selectedKoreanSubCategory == nil &&
                viewModel.selectedChineseSubCategory == nil &&
                viewModel.selectedWesternSubCategory == nil &&
                viewModel.selectedJapaneseSubCategory == nil &&
                 viewModel.selectedSoutheastAsianSubCategory == nil) {
                YoTeacherFloating( onTap: {router.push(.yoTeacher)} )
            }
        }
    }

    // MARK: - Main Category Button
    /// 상위 카테고리 버튼 UI
    /// 선택 시 ViewModel의 cuisine 상태 갱신
    private func categoryButton(_ cuisine: CuisineCategory) -> some View {
        /// 현재 버튼이 선택된 상태인지 여부
        let isSelected = (viewModel.selectedCuisine == cuisine)

        return Button {
            viewModel.selectCuisine(cuisine)
        } label: {
            VStack(spacing: 8) {
                HStack(alignment: .center, spacing: 0) {
                    Image(categoryAssetName(for: cuisine))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                .padding(.leading, 4.2605)
                .padding(.trailing, 3.6469)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64, alignment: .center)
                .background(isSelected ? selectedOrange : unselectedGray)
                .cornerRadius(8)
//TODO: - 의견 듣고 세미볼드로 수정 할 수도 !
                Text(cuisine.rawValue)
                    .font(.custom("Pretendard-Medium", size: 14))
                    .foregroundColor(isSelected ? selectedOrange : Color.black.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    /// 상위 카테고리에 대응하는 에셋 이미지 이름 반환
    private func categoryAssetName(for cuisine: CuisineCategory) -> String {
        switch cuisine {
        case .korean: return "korean"
        case .chinese: return "chinese"
        case .japanese: return "japanese"
        case .western: return "western"
        case .southeastAsian: return "southeastasian"
        }
    }

    /// 선택된 상위 카테고리에 따른 하위 카테고리 버튼 목록
    @ViewBuilder
    private var subCategoryGrid: some View {
        if let selectedCuisine = viewModel.selectedCuisine {
            LazyVGrid(columns: subCategoryColumns, alignment: .center, spacing: 12) {
                switch selectedCuisine {
                case .korean:
                    ForEach(KoreanSubCategory.allCases, id: \.self) { sub in
                        subCategoryButton(
                            title: sub.rawValue,
                            isSelected: viewModel.selectedKoreanSubCategory == sub,
                            onTap: { viewModel.selectKoreanSubCategory(sub) }
                        )
                    }
                case .chinese:
                    ForEach(ChineseSubCategory.allCases, id: \.self) { sub in
                        subCategoryButton(
                            title: sub.rawValue,
                            isSelected: viewModel.selectedChineseSubCategory == sub,
                            onTap: { viewModel.selectChineseSubCategory(sub) }
                        )
                    }
                case .japanese:
                    ForEach(JapaneseSubCategory.allCases, id: \.self) { sub in
                        subCategoryButton(
                            title: sub.rawValue,
                            isSelected: viewModel.selectedJapaneseSubCategory == sub,
                            onTap: { viewModel.selectJapaneseSubCategory(sub) }
                        )
                    }
                case .western:
                    ForEach(WesternSubCategory.allCases, id: \.self) { sub in
                        subCategoryButton(
                            title: sub.rawValue,
                            isSelected: viewModel.selectedWesternSubCategory == sub,
                            onTap: { viewModel.selectWesternSubCategory(sub) }
                        )
                    }
                case .southeastAsian:
                    ForEach(SoutheastAsianSubCategory.allCases, id: \.self) { sub in
                        subCategoryButton(
                            title: sub.rawValue,
                            isSelected: viewModel.selectedSoutheastAsianSubCategory == sub,
                            onTap: { viewModel.selectSoutheastAsianSubCategory(sub) }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        } else {
            EmptyView()
        }
    }

    /// 하위 카테고리 버튼 UI
    /// 선택 시 해당 하위 카테고리 기준으로 영상 필터링
    private func subCategoryButton(
        title: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(.custom("Pretendard-Medium", size: 14))
                    .foregroundColor(isSelected ? .white : Color.black.opacity(0.75))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 18)
            .frame(width: 64, height: 44, alignment: .center)
            .background(isSelected ? selectedOrange : unselectedGray)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - RecipeVideoCard
/// 레시피 영상 요약 카드 UI
/// 제목, 채널, 북마크 버튼, 썸네일 표시
struct RecipeVideoCard: View {

    /// 카드에 표시할 레시피 영상 데이터
    let video: RecipeVideo

    /// 북마크 버튼 탭 이벤트 콜백
    /// 목록 ViewModel에서 토글 처리
    let onTapBookmark: () -> Void

    init(
        video: RecipeVideo,
        onTapBookmark: @escaping () -> Void
    ) {
        self.video = video
        self.onTapBookmark = onTapBookmark
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            /// 제목 및 채널 정보 영역
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.custom("Pretendard-SemiBold", size: 18))
                        .foregroundColor(.primary)

                    Text("\(video.channelName) · 조회수 \(video.viewCount.formattedViewCount)회")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                /// 북마크 토글 버튼
                Button {
                    onTapBookmark()
                } label: {
                    Image(video.isBookmarked ? "bookmark.fill" : "bookmark")
                        .renderingMode(.original)
                }
            }
            .padding(.horizontal, 16)

            /// 유튜브 썸네일 영역
            ThumbnailView(videoId: video.videoId, durationText: video.videoDuration ?? "")
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - ThumbnailView
/// 유튜브 영상 썸네일 표시 뷰
/// maxres 이미지 우선, 실패 시 hq 이미지 사용
private struct ThumbnailView: View {

    let videoId: String
    let durationText: String

    /// maxres 썸네일 실패 여부
    /// 실패 시 hq 썸네일로 대체
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
            /// 썸네일 이미지 로딩 상태 처리
            AsyncImage(url: currentURL) { phase in
                switch phase {
                case .empty:
                    Color.black.opacity(0.12)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
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

            /// 영상 재생 시간 오버레이 표시
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

 // MARK: - Preview
#Preview {
    NavigationStack {
        RecipeListView()
            .setupNavigationDestinations()
    }
        .environment(NavigationRouter())
        .environment(YoTeacherChatViewModel())
        
}

// MARK: - View Count Formatting
/// 조회수 숫자를 화면 표시용 문자열로 변환

private extension Int {
    var formattedViewCount: String {
        if self < 10_000 {
            return self.formatted()
        }

        let value = Double(self) / 10_000.0
        let rounded = (value * 10).rounded() / 10

        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(rounded))만"
        }

        return "\(rounded)만"
    }
}
