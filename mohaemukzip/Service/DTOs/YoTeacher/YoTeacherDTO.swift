//
//  YoTeacherDTO.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/31/26.
//

import Foundation

struct YoTeacherResponseDTO: Decodable {
    let id: String
    let senderType: String
    let title: String
    let message: String
    let createdAt: String
    let formattedTime: String
    let recommendRecipes: [YoTeacherDTO]
}

struct YoTeacherDTO: Decodable {
    let recipeId: Int
    let title: String
    let imageUrl: String
    
    func toDomain() -> YoTeacherMessage {
        return YoTeacherMessage(id: recipeId,
                                title: title,
                                thumbnailURL: URL(string: imageUrl)!)
    }
}
