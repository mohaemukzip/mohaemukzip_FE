import SwiftUI

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

