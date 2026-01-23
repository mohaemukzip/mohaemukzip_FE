//
//  FridgeViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import SwiftUI
import Combine

class FridgeViewModel: ObservableObject {
    @Published var allIngredients: [IngredientModel] = []
    
    // MARK: 냉동, 냉장, 실온 -> 서버에서 받은 allIngredient를 분기처리할 것
    var frozenIngredients: [IngredientModel] {
        allIngredients.filter { $0.ty == .frozen }
    }
    var chilledIngredients: [IngredientModel] {
        allIngredients.filter { $0.ty == .chilled }
    }
    var roomIngredients: [IngredientModel] {
        allIngredients.filter { $0.ty == .room }
    }
    
    init() {
        self.allIngredients = [IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .room),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .room),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .room)]
    }
    
    func deleteIngredient(at id: UUID) {
        withAnimation {
            allIngredients.removeAll{ $0.id == id }
        }
    }
    
    func addIngredientToFridge(name: String, amount: String, storage: IngredientModel.StorageType) {
        let newEntry = IngredientModel(name: name,
                                       amount: amount,
                                       expirationDate: 10,
                                       ty: storage)
        withAnimation {
            self.allIngredients.insert(newEntry, at: 0)
        }
    }
    
}
