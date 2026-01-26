//
//  FridgeView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import SwiftUI

struct FridgeView: View {
    @Environment(FridgeViewModel.self) var viewModel
    @Environment(IngredientSearchViewModel.self) var ingredientSearchVM
    @State var isEditing: Bool = false
    @Environment(NavigationRouter.self) var router
    
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
                        IngredientBox(isEditing: $isEditing,
                                      text: "냉동",
                                      ingredients: viewModel.frozenIngredients,
                                      onDelete: { id in viewModel.deleteIngredient(at: id)})
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                        IngredientBox(isEditing: $isEditing,
                                      text: "냉장",
                                      ingredients: viewModel.chilledIngredients,
                                      onDelete: { id in viewModel.deleteIngredient(at: id)})
                        IngredientBox(isEditing: $isEditing,
                                      text: "실온",
                                      ingredients: viewModel.roomIngredients,
                                      onDelete: { id in viewModel.deleteIngredient(at: id)})
                        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                    }.padding()
                }
            }.background(.grey100)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.white)
                HStack {
                    Spacer()
                    Button ( action: { } ) { OrangeButton(text: "장보기 연동하기", size: .small) }
                    Spacer()
                    Button ( action: { router.push(.ingredientSearch); ingredientSearchVM.searchText = "" } ) { OrangeButton(text: "재료 입력하기", size: .small) }
                    Spacer()
                }.padding()
            }.frame(height: 94)
            
        }
    }
}

#Preview {
    FridgeView()
        .environment(NavigationRouter())
}
