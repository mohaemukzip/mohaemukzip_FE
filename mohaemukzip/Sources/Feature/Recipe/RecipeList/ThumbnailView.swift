

import SwiftUI

// MARK: - ThumbnailView
/// 유튜브 영상 썸네일 표시 뷰

struct ThumbnailView: View {

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

