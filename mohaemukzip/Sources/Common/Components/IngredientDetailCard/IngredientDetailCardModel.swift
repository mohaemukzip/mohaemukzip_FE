//
//  IngredientDetailCardModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/15/26.
//

import Foundation

struct IngredientDetailCardModel: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let amount: String
    let nnng: String
}
