//
//  FridgeDTO.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/28/26.
//

import Foundation

struct FridgeListDTO: Decodable {
    let fridgeList: [IngredientDTO]
}

struct IngredientDTO: Decodable {
    let memberIngredientId: Int
    let name: String
    let storageType: String
    let expiryDate: String
    let weight: Int
    let unit: String
    let statusColor: String
    let dday: String
    
    func toDomain() -> FridgeIngredient {
        return FridgeIngredient(id: self.memberIngredientId,
                                name: self.name,
                                storage: StorageType(rawValue: self.storageType) ?? .room,
                                color: dDayColor(rawValue: self.statusColor) ?? .GREEN,
                                amount: "\(self.weight)\(self.unit)", // ~~g 형태로
                                expiryDate: self.expiryDate,
                                dDay: self.dday)
    }
}

struct AddIngredientRequestDTO: Encodable {
    let ingredientId: Int
    let storageType: String
    let expireDate: String
    let weight: Int
}
