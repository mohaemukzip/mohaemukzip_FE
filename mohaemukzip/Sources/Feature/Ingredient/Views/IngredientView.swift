//
//  IngredientView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import SwiftUI

struct IngredientView: View {
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(height: 73)
                    .foregroundStyle(.white)
                HStack {
                    Text("냉장고")
                        .foregroundStyle(.black)
                        .font(.PretendardSemibold24)
                    Spacer()
                    Button( action: { } ) { Image("icon-bell") }
                }.padding()
            }
            
            ZStack {
                ScrollView {
                    Group {
                        IngredientBox(text: "냉동", ingredients: [
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100)])
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                        IngredientBox(text: "냉장", ingredients: [
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100)])
                        IngredientBox(text: "실온", ingredients: [
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100),
                            IngredientManagementCardModel(name: "양배추", amount: "100g", expirationDate: 100)])
                        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                    }.padding()
                } // end of ScrollView
            }.background(.grey100)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.white)
                HStack {
                    Spacer()
                    Button ( action: { } ) { OrangeButton(text: "장보기 연동하기", size: .small) }
                    Spacer()
                    Button ( action: { } ) { OrangeButton(text: "재료 입력하기", size: .small) }
                    Spacer()
                }.padding()
            }.frame(height: 94)
            
        }
    }
}

#Preview {
    IngredientView()
}
