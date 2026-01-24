//
//  YoTeacherChatViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import SwiftUI
import Combine

class YoTeacherChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [ChatMessage(text: "다이어트 중인데 뭐가 좋을까?")]
    @Published var recommendQ: [ChatMessage] = [ChatMessage(text: "지금 있는 재료로 만들 요리 추천"),
                                                ChatMessage(text: "허니콤보랑 먹을 떡볶이 추천"),
                                                ChatMessage(text: "엽떡 착한맛 래시피")]
    
    func addMessages(text: String) {
        messages.insert(ChatMessage(text: text), at: 0)
    }
}
