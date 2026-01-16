// MARK: - ViewModel

import SwiftUI
import Combine

final class RecipeVideoViewModel: ObservableObject {
    
    // 선택된 카테고리
    @Published var selectedCategory: RecipeCategory
    
    @Published private(set) var videos: [RecipeVideo] = []
    
    var filteredVideos: [RecipeVideo] {
        videos.filter { $0.category == selectedCategory }
    }
    init(category: RecipeCategory) {
        self.selectedCategory = category
        loadDummyData()
    }
    
    // TODO: API 연동 시 Service 호출로 교체
    private func loadDummyData() {
        videos = [
            RecipeVideo(
                id: 1,
                title: "초간단 제육볶음 레시피",
                channelName: "요리채널",
                viewCount: 27000,
                thumbnailImageName: "thumbnail3",
                videoId: "VIDEO_ID_1",
                category: .korean,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 2,
                title: "집에서 만드는 제육볶음",
                channelName: "집밥백선생",
                viewCount: 152000,
                thumbnailImageName: "thumbnail",
                videoId: "VIDEO_ID_2",
                category: .korean,
                isBookmarked: true
            ),
            RecipeVideo(
                id: 3,
                title: "매콤한 김치볶음밥",
                channelName: "자취요리",
                viewCount: 98000,
                thumbnailImageName: "thumbnail2",
                videoId: "VIDEO_ID_3",
                category: .korean,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 4,
                title: "초보도 가능한 된장찌개",
                channelName: "한식연구소",
                viewCount: 45000,
                thumbnailImageName: "thumbnail1",
                videoId: "VIDEO_ID_4",
                category: .korean,
                isBookmarked: false
            ),
            RecipeVideo(
                id: 5,
                title: "10분 완성 계란말이",
                channelName: "간단요리",
                viewCount: 120000,
                thumbnailImageName: "thumbnail4",
                videoId: "VIDEO_ID_5",
                category: .korean,
                isBookmarked: false
            )
        ]
    }
    
    // TODO: 스크랩 기능 구현 시 Repository로 분리
    func toggleBookmark(videoId: Int) {
        guard let index = videos.firstIndex(where: { $0.id == videoId }) else { return }
        
        videos[index].isBookmarked.toggle()
        
        if videos[index].isBookmarked {
            print("스크랩 저장 되었습니다")
        } else {
            print("스크랩 해제되었습니다")
        }
    }
}
