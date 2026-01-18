//
//  IngredientBox.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/16/26.
//

import SwiftUI

struct IngredientBox: View {
    @State private var isExpanded: Bool = false
    @State private var plus: Bool = false
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let text: String
    let ingredients: [IngredientModel]
    
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .frame(width: 359)
                .foregroundStyle(.white)
            
            VStack {
                HStack {
                    Text(text)
                        .font(.PretendardSemibold16)
                        .foregroundStyle(.grey700)
                    Spacer().frame(width: 278)
                    Button(action: { withAnimation { isExpanded.toggle() } } ) {
                        Image(isExpanded ? "icon-chevron.down" : "icon-chevron.up")
                            .foregroundStyle(.grey700)
                    }
                }
                
                Spacer().frame(height: 20)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    let displayCount = isExpanded ? max(ingredients.count, 8) : 8
                    
                    ForEach(0..<displayCount, id: \.self) { index in
                        if index < ingredients.count {
                            IngredientManagementCard(ingredientInfo: ingredients[index], color: .green)
                        }
                        else if index == ingredients.count {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(.grey300)
                                    .frame(width: 76, height: 80)
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundStyle(.grey100)
                                    .frame(width: 32, height: 32)
                                Image("icon-plus")
                                    .foregroundStyle(.grey400)
                            }
                        }
                        else {
                            Rectangle()
                                .frame(width: 76, height: 80)
                                .foregroundStyle(.clear)
                        }
                    }
                    
                    if (isExpanded && ingredients.count >= 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.grey300)
                                .frame(width: 76, height: 80)
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundStyle(.grey100)
                                .frame(width: 32, height: 32)
                            Image("icon-plus")
                                .foregroundStyle(.grey400)
                        }
                    }
                }
            }.frame(width: 327) // end of VStack
                .padding()
        } // end of ZStack
        
    }
}

#Preview {
    IngredientBox(text: "냉장", ingredients: [IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen),
                                            IngredientModel(name: "양배추", amount: "100g", expirationDate: 100, ty: .frozen)
                                            ])
}
