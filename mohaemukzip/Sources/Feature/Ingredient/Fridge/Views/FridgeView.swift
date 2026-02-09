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
                                      onDelete: { id in Task { await viewModel.deleteIngredient(at: id) } })
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                        IngredientBox(isEditing: $isEditing,
                                      text: "냉장",
                                      ingredients: viewModel.chilledIngredients,
                                      onDelete: { id in Task { await viewModel.deleteIngredient(at: id) } })
                        IngredientBox(isEditing: $isEditing,
                                      text: "실온",
                                      ingredients: viewModel.roomIngredients,
                                      onDelete: { id in Task { await viewModel.deleteIngredient(at: id) } })
                        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                    }.padding()
                }
            }.background(.grey100)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.white)
                HStack {
                    // MARK: 버튼의 action 안에 초기화 로직
                    // 뷰모델의 viewId에 UUID를 할당하고 IngredientSearchView에서 이를 감지하여 뷰를 다시 그리게 - 스크롤 원위치
                    // 뷰모델의 selectedCategory를 .all로 초기화
                    Button ( action: { router.push(.ingredientSearch); ingredientSearchVM.searchText = ""; ingredientSearchVM.viewId = UUID(); ingredientSearchVM.selectedCategory = .all } ) { OrangeButton(text: "재료 입력하기", size: .big)
                                    .frame(height: 46)}
                }.padding()
            }.frame(height: 94)
            
        }.task {
            await viewModel.fetchList()
        }
        .onDisappear {
            self.isEditing = false
        }
    }
}

#Preview {
    FridgeView()
        .environment(NavigationRouter())
        .environment(FridgeViewModel())
        .environment(IngredientSearchViewModel())
}
