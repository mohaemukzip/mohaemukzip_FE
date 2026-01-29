//
//  IngredientDTO.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/29/26.
//

import Foundation

struct IngredientResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [IngredientForAdditionDTO]
}

struct IngredientForAdditionDTO: Decodable {
    let ingredientId: Int
    let name: String
    let category: String
    let unit: String
    let weight: Int
    
    func toDomain() -> IngredientForAddition {
        return IngredientForAddition(id: ingredientId,
                                     name: name,
                                     category: Category(rawValue: self.category) ?? .dairy,
                                     unit: unit,
                                     weight: weight)
    }
}
