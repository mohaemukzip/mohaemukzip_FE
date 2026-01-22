//
//  IngredientModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/15/26.
//

import Foundation

struct IngredientModel: Identifiable, Hashable {
    enum StorageType {
        case frozen
        case chilled
        case room
    }

    let id: UUID = UUID()
    let name: String
    let amount: String
    let expirationDate: Int
    let ty: StorageType
}
