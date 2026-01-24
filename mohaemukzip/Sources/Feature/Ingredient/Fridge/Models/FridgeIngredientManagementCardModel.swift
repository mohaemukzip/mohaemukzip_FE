//
//  IngredientModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/15/26.
//

import Foundation

struct FridgeIngredientModel: Identifiable, Hashable {
    enum StorageType: String, CaseIterable{
        case frozen
        case chilled
        case room
        
        var description: String {
            switch self {
            case .frozen: return "냉동보관"
            case .chilled: return "냉장보관"
            case .room: return "실온보관"
            }
        }
    }

    let id: UUID = UUID()
    let name: String
    let amount: String
    let expirationDate: Int
    let ty: StorageType
}


