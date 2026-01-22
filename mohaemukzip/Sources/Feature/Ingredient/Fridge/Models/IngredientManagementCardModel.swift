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
    
    // MARK: API 연결 시 삭제하고 백에서 주는 고유 id 사용할 것 (백에서 만약 고유 id 준다면!)
    let id: UUID = UUID()
    let name: String
    let amount: String
    let expirationDate: Int
    let ty: StorageType
}
