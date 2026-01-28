//
//  HomeViewModel.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/26/26.
//
//

import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    var home: HomeModel?
    var isLoading: Bool = false
    var errorMessage: String?
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: 실제 API 연결 시 여기서 HomeResponseDTO 디코딩 후 toModel()
            // let dto: HomeResponseDTO = try await api.fetchHome()
            // self.home = dto.result.toModel()
            
            self.home = Self.mockHome()
        } catch {
            self.errorMessage = "홈 정보를 불러오지 못했어요."
        }
    }
}

extension HomeViewModel {
    static func mockHome() -> HomeModel {
        HomeModel(
            level: 0,
            title: "집밥 왕초보",
            monthlyCooking: 2,
            score: 3,
            nextLevelScore: 8,
            consecutiveDays: 3,
            weekly: [("월", true), ("화", true), ("수", true), ("목", false), ("금", false), ("토", false), ("일", false)],
            todayMission: .init(
                missionId: 1,
                title: "냉장고 속 팽이버섯 구출 대작전!",
                description: "팽이버섯이 2일 후면 유통기한이 끝나요. 오늘 꼭 활용해보세요!",
                reward: 2,
                isCompleted: false
            ),
            recipes: [
                .init(id: 101, title: "영상 제목", videoId: "gqSWYwcBTV8", videoUrl: "https://www.youtube.com/watch?v=gqSWYwcBTV8",
                      imageUrl: "https://picsum.photos/300/200?1", channel: "채널명", views: 27000, time: "15:30", cookingTime: 15),
                .init(id: 102, title: "영상 제목", videoId: "dasDqB21v8", videoUrl: "https://www.youtube.com/watch?v=dasDqB21v8",
                      imageUrl: "https://picsum.photos/300/200?2", channel: "채널명", views: 150300, time: "21:10", cookingTime: 45)
            ]
        )
    }
}
