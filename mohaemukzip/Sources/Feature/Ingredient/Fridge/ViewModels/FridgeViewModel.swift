//
//  FridgeViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import SwiftUI
import Combine

class FridgeViewModel: ObservableObject {
    @Published var allIngredients: [FridgeIngredientModel] = []
    
    // MARK: 냉동, 냉장, 실온 -> 서버에서 받은 allIngredient를 분기처리할 것
    var frozenIngredients: [FridgeIngredientModel] {
        allIngredients.filter { $0.ty == .frozen }
    }
    var chilledIngredients: [FridgeIngredientModel] {
        allIngredients.filter { $0.ty == .chilled }
    }
    var roomIngredients: [FridgeIngredientModel] {
        allIngredients.filter { $0.ty == .room }
    }
    
    init() {
        self.allIngredients = [FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .room),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .room),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .chilled),
                               FridgeIngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .room)]
    }
    
    func deleteIngredient(at id: UUID) {
        withAnimation {
            allIngredients.removeAll{ $0.id == id }
        }
    }
    
    func addIngredientToFridge(name: String, amount: String, storage: FridgeIngredientModel.StorageType) {
        let newEntry = FridgeIngredientModel(name: name,
                                       amount: amount,
                                       expirationDate: 10,
                                       ty: storage)
        withAnimation {
            self.allIngredients.insert(newEntry, at: 0)
        }
    }
    
}
