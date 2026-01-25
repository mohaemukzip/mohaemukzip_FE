//
//  YoTeacherChatModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import Foundation

struct ChatMessage: Identifiable {
    let id: UUID = UUID()
    let text: String
    var responseVideos: [RecipeVideo]? = nil
}
