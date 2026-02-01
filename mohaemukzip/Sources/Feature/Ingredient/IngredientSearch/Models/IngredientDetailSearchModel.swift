//
//  IngredientDetailSearchModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/22/26.
//

import Foundation

struct IngredientDetailSearchModel: Identifiable {
    let id: UUID = UUID()
    let name: String
}

struct searchQuery: Equatable {
    let text: String
    let category: Category
}
