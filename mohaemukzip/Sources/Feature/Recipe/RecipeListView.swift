//
//  RecipeListView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/16/26.
//

import SwiftUI

// MARK: - RecipeListView
// 카테고리(상위/하위) 선택을 통해 레시피 영상을 탐색하는 목록 화면
// 선택된 카테고리에 따라 ViewModel에서 필터링된 영상 목록을 표시함

struct RecipeListView: View {

    /// 레시피 목록 화면 전용 ViewModel
    /// 카테고리 선택 상태 및 필터링된 영상 목록을 관리함
    @StateObject private var viewModel: RecipeVideoViewModel

    // MARK: - 초기화
    // 기본 진입: 아무것도 선택되지 않은 상태. 초기화.     
    init() {
        _viewModel = StateObject(wrappedValue: RecipeVideoViewModel())
    }

    init(category: CuisineCategory) {
        _viewModel = StateObject(wrappedValue: RecipeVideoViewModel(category: category))
    }

    // MARK: - 카테고리 버튼 색상 정의
    // 선택 / 비선택 상태를 명확히 구분하기 위한 컬러
    private let selectedOrange = Color(red: 1, green: 0.55, blue: 0.14)
    private let unselectedGray = Color(red: 0.96, green: 0.96, blue: 0.96)

    /// 하위 카테고리 그리드 레이아웃
    /// 스크린샷 기준으로 고정 너비(64) 버튼을 1줄에 5개 배치
    private var subCategoryColumns: [GridItem] {
        Array(repeating: GridItem(.fixed(64), spacing: 12, alignment: .center), count: 5)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // 상위 음식 카테고리 선택 영역 (한식/중식/일식/양식/동남아)
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

                // 선택된 상위 카테고리에 따라 하위 카테고리를 노출
                // 상위 카테고리가 선택되지 않은 경우에는 표시하지 않음
                // MARK: - 하위 카테고리 그리드
                // 상위 카테고리 선택 이후에만 노출되며, 선택 결과에 따라 영상 목록이 갱신됨
                subCategoryGrid

                // 카테고리 영역과 콘텐츠 영역을 시각적으로 구분하기 위한 디바이더
                // MARK: - Category / Content Divider
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 8)
                    .padding(.top, 16)

                // 선택된 상위 + 하위 카테고리를 기준으로 필터링된 영상 목록
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
        }
    }

    // MARK: - 상위 카테고리 버튼
    // 선택 시 ViewModel의 selectedCuisine 상태를 갱신함
    private func categoryButton(_ cuisine: CuisineCategory) -> some View {
        // 현재 카테고리가 선택된 상태인지 여부
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

    /// 하위 카테고리 버튼
    /// 선택 시 해당 하위 카테고리를 기준으로 영상 목록을 필터링함
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

// MARK: - 레시피 영상 카드
// 영상 제목, 채널 정보, 북마크 버튼, 썸네일을 표시하는 카드 UI
struct RecipeVideoCard: View {

    let video: RecipeVideo

    /// 카드 내부에서만 사용하는 북마크 상태
    /// 현재는 UI용 상태이며, 서버 연동 시 ViewModel로 이동 예정
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

                // 북마크 버튼 (현재는 UI 토글만 처리)
                Button {
                    isBookmarked.toggle()
                } label: {
                    Image(isBookmarked ? "bookmark.fill" : "bookmark")
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

// MARK: - 유튜브 썸네일 뷰
// maxres 이미지 우선 사용, 실패 시 hq 이미지로 fallback
private struct ThumbnailView: View {

    let videoId: String
    let durationText: String

    /// maxres 썸네일 실패 시 hq 썸네일로 전환하기 위한 상태값
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
                    // maxres 썸네일이 없는 영상이 많아 실패 시 hq 이미지로 대체
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

 // MARK: - Preview
#Preview {
    RecipeListView()
}

// MARK: - 조회수 포맷팅 유틸

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
