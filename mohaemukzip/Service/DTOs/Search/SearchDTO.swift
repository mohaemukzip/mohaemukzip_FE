//
//  SearchDTO.swift
//  mohaemukzip
//
//  Created by 이한결 on 2/2/26.
//

import Foundation

struct RecipeSearchResultDTO: Decodable {
    let results: [SearchDTO]
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool
}

struct SearchDTO: Decodable {
    let id: Int
    let title: String

    func toDomain() -> SearchKeyword {
        return SearchKeyword(id: id,
                             text: title)
    }
}

struct SearchResultDTO: Decodable {
    let recipeList: [RecipeInfoDTO]
    let listSize: Int
    let totalPage: Int
    let totalElements: Int
    let isFirst: Bool
    let isLast: Bool
}

struct RecipeInfoDTO: Decodable {
    let id: Int
    let title: String
    let channelName: String
    let viewCount: Int
    let videoId: String
    let channelId: String
    let videoDuration: String
    let cookingTimeMinutes: Int
    let difficulty: Double
    let isBookmarked: Bool
    
    func toDomain() -> RecipeVideo {
        return RecipeVideo(id: id,
                           title: title,
                           videoId: videoId,
                           channelId: channelId,
                           videoDuration: videoDuration,
                           channelName: channelName,
                           viewCount: viewCount,
                           cookingTimeMinutes: cookingTimeMinutes,
                           difficulty: Int(difficulty.rounded()),
                           cuisine: .korean,
                           isBookmarked: isBookmarked)
    }
}
