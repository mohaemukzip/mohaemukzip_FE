//
//  YoTeacherChatViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import SwiftUI
import Combine

class YoTeacherChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    func addMessages(text: String) {
        messages.insert(ChatMessage(text: text), at: 0)
    }
}
