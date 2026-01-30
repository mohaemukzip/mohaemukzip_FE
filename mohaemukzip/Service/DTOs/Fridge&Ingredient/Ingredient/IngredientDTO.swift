//
//  IngredientDTO.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/29/26.
//

import Foundation

struct IngredientSearchListDTO: Decodable {
    let content: [IngredientForAdditionDTO]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let first: Bool
    let last: Bool
}


struct IngredientForAdditionDTO: Decodable {
    let ingredientId: Int
    let name: String
    let category: String
    let unit: String
    let weight: Int
    let isFavorite: Bool
    
    
    func toDomain() -> IngredientForAddition {
        return IngredientForAddition(id: ingredientId,
                                     name: name,
                                     category: Category(rawValue: self.category) ?? .dairy,
                                     unit: unit,
                                     amount: weight,
                                     isSaved: isFavorite)
    }
}

struct RecentSearchIngredientDTO: Decodable {
    let recentList: [RecentSearch1]
}

struct RecentSearch1: Decodable {
    let memberRecentSearchId: Int
    let keyword: String
    
    func toDomain() -> RecentSearchIngredient {
        return RecentSearchIngredient(id: memberRecentSearchId,
                                      keyword: keyword)
    }
}

struct FavoriteIngredient: Decodable {
    let ingredientId: Int
    let name: String
    let category: String
    let unit: String
    let weight: Int
    let isFavorite: Bool
    
    func toDomain() -> SavedIngredient {
        return SavedIngredient(id: ingredientId,
                               name: name,
                               category: Category(rawValue: self.category) ?? .dairy,
                               unit: unit,
                               amount: weight,
                               isSaved: isFavorite)
    }
}
