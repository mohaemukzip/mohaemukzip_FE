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

@Observable
class YoTeacherChatViewModel {
    var messages: [ChatMessages] = []
    var recommendQ: [ChatMessages] = [ChatMessages(text: "10분 이내로\n만들 수 있는 요리"),
                                                ChatMessages(text: "대파가\n들어가는 요리"),
                                                ChatMessages(text: "다이어터를 위한\n저녁 레시피")]
    var responseState: ResponseState = .idle
    var responseVideos: [RecipeVideo]? = nil
    var service = YoTeacherService()
    
    func sendMessage(message: String) async {
        messages.append(ChatMessages(text: message))
        self.responseState = .thinking
        
        do {
            let (chatBotTitle, chatBotText, chatBotResponse) = try await service.getResponse(message: message)
            
            if let lastIndex = messages.indices.last {
                messages[lastIndex].chatBotTitle = chatBotTitle
                messages[lastIndex].chatBotText = chatBotText
                messages[lastIndex].chatBotResponse = chatBotResponse
            }
            
            self.responseState = .completed
        } catch {
            print("챗봇 응답을 불러올 수 없습니다: \(error)")
            self.responseState = .idle
        }
    }
}
