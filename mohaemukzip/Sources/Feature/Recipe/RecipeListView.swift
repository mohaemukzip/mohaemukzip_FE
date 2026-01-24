//
//  RecipeListView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/16/26.
//

import SwiftUI


struct RecipeListView: View {

    @StateObject private var viewModel: RecipeVideoViewModel

    // 기본 진입: 아무것도 선택되지 않은 상태. 초기화.     
    init() {
        _viewModel = StateObject(wrappedValue: RecipeVideoViewModel())
    }

    init(category: CuisineCategory) {
        _viewModel = StateObject(wrappedValue: RecipeVideoViewModel(category: category))
    }

    private let selectedOrange = Color(red: 1, green: 0.55, blue: 0.14)
    private let unselectedGray = Color(red: 0.96, green: 0.96, blue: 0.96)

    private var subCategoryColumns: [GridItem] {
        Array(repeating: GridItem(.fixed(64), spacing: 12, alignment: .center), count: 5)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    
                    // MARK: - 최상단 검색창
                    Button( action: { } ) {
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

                    // MARK: - 상위 카테고리 (스크린샷 스타일)
                    HStack(alignment: .top, spacing: 12) {
                        categoryButton(.korean)
                        categoryButton(.chinese)
                        categoryButton(.japanese)
                        categoryButton(.western)
                        categoryButton(.southeastAsian)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // MARK: - 하위 카테고리 (상위 선택 후에만 노출)
                    subCategoryGrid

                    // MARK: - Category / Content Divider
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 8)
                        .padding(.top, 16)
                    
                    // MARK: - 요선생과 대화하기 배너 (viewModel의 SubCategory가 하나라도 선택된다면 나타남)
                    if viewModel.selectedKoreanSubCategory == nil &&
                        viewModel.selectedChineseSubCategory == nil &&
                        viewModel.selectedWesternSubCategory == nil &&
                        viewModel.selectedJapaneseSubCategory == nil &&
                        viewModel.selectedSoutheastAsianSubCategory == nil { YoTeacher()
                            .padding(.top, 25)
                            .padding(.horizontal, 16) }

                    // MARK: - 영상 목록 (상위+하위 모두 선택해야 filteredVideos가 생김)
                    ScrollView {
                        LazyVStack(spacing: 40) {
                            ForEach(viewModel.filteredVideos) { video in
                                NavigationLink {
                                    RecipeVideoDetailView(video: video)
                                } label: {
                                    RecipeVideoCard(video: video)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 16)
                    }
                    
                    
                }
                .navigationBarHidden(true)
                // MARK: - 요선생 플로팅 버튼 (viewModel의 filteredVideos가 비어있지 않으면 나타남)
                if !(viewModel.selectedKoreanSubCategory == nil &&
                    viewModel.selectedChineseSubCategory == nil &&
                    viewModel.selectedWesternSubCategory == nil &&
                    viewModel.selectedJapaneseSubCategory == nil &&
                     viewModel.selectedSoutheastAsianSubCategory == nil) { YoTeacherFloating() }
            }
        }
    }

    // MARK: - 상위 카테고리 버튼

    private func categoryButton(_ cuisine: CuisineCategory) -> some View {
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

    private func categoryAssetName(for cuisine: CuisineCategory) -> String {
        switch cuisine {
        case .korean: return "korean"
        case .chinese: return "chinese"
        case .japanese: return "japanese"
        case .western: return "western"
        case .southeastAsian: return "southeastasian"
        }
    }

    // MARK: - SubCategory Grid

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

// MARK: - Recipe Video Card (Thumbnail Only)

struct RecipeVideoCard: View {

    let video: RecipeVideo

    @State private var isBookmarked: Bool

    init(video: RecipeVideo) {
        self.video = video
        _isBookmarked = State(initialValue: video.isBookmarked)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // 제목 + 북마크
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

                Button {
                    isBookmarked.toggle()
                } label: {
                    Image(isBookmarked ? "bookmark_filled" : "bookmark")
                        .renderingMode(.original)
                }
            }
            .padding(.horizontal, 16)

            //  유튜브 썸네일만 표시 + 썸네일 스타일 오버레이
            ThumbnailView(videoId: video.videoId, durationText: video.videoDuration ?? "")
                .frame(maxWidth: .infinity)   //  타이틀/북마크와 동일한 좌우 라인
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - Thumbnail View (maxres → hq fallback)

private struct ThumbnailView: View {

    let videoId: String
    let durationText: String

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
            AsyncImage(url: currentURL) { phase in
                switch phase {
                case .empty:
                    Color.black.opacity(0.12)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    // maxres가 없는 영상들이 많아서 실패하면 hq로 fallback
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

            //  재생 시간 (우측 하단 오버레이)
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

//// MARK: -상세 화면
////TODO: - 할 예정 !!!!!!!
//
//struct RecipeVideoDetailView: View {
//
//    let video: RecipeVideo
//
//    @StateObject private var player: YouTubePlayer
//
//    init(video: RecipeVideo) {
//        self.video = video
//        _player = StateObject(
//            wrappedValue: YouTubePlayer(
//                source: .video(id: video.videoId),
//                configuration: .init(
//                    fullscreenMode: .system,
//                    allowsInlineMediaPlayback: true
//                )
//            )
//        )
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            YouTubePlayerView(player)
//                .aspectRatio(16 / 9, contentMode: .fit)
//
//            Spacer()
//        }
//        .navigationTitle(video.title)
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
#Preview {
    RecipeListView()
}

// MARK: - 영상 조회수 포맷팅 확장.

private extension Int {
    /// 조회수 포맷팅
    /// - 10,000 미만: 그대로 표시 (예: 8,532)
    /// - 10,000 이상: n.n만 형식 (예: 12,345 -> 1.2만)
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
