//
//  YoTeacherChatViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import SwiftUI
import Combine

enum ResponseState {
    case idle // 전송 x
    case thinking // 요선생 생각중 (...)
    case skeleton // 스켈레톤 UI
    case completed // 렌더링 완료
}

class YoTeacherChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var recommendQ: [ChatMessage] = [ChatMessage(text: "지금 있는 재료로 만들 요리 추천"),
                                                ChatMessage(text: "허니콤보랑 먹을 떡볶이 추천"),
                                                ChatMessage(text: "엽떡 착한맛 래시피")]
    @Published var responseState: ResponseState = .idle
    @Published var responseVideos: [RecipeVideo]? = nil
    
    func addMessages(text: String) {
        messages.append(ChatMessage(text: text))
        simulateAIResponse(index: messages.count - 1)
    }
    
    func simulateAIResponse(index: Int) {
        responseState = .thinking
        
        // 생각중 흉내 - 1.5초
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.responseState = .skeleton
            
            // 스켈레톤 흉내 - 2초
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                // MARK: - 응답 추천 비디오 더미데이터 -> api 응답
                let dummyVideos: [RecipeVideo] = [
                    RecipeVideo(id: 1, title: "추천 레시피", videoId: "sHpMVI8wQuk", channelName: "요선생", viewCount: 1000, cookingTimeMinutes: 15, cuisine: .korean),
                    RecipeVideo(id: 2, title: "추천 레시피", videoId: "sHpMVI8wQuk", channelName: "요선생", viewCount: 1000, cookingTimeMinutes: 15, cuisine: .korean),
                    RecipeVideo(id: 3, title: "추천 레시피", videoId: "sHpMVI8wQuk", channelName: "요선생", viewCount: 1000, cookingTimeMinutes: 15, cuisine: .korean)
                ]
                
                // MARK: - 해당 인덱스의 ChatMessage 모델의 responseVideos를 수정
                self.messages[index].responseVideos = dummyVideos
                
                self.responseState = .idle
            }
        }
    }
    
}
