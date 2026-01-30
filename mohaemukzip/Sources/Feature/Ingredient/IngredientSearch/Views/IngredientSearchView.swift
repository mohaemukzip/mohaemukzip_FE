//
//  IngredientSearchView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/21/26.
//

import SwiftUI

struct IngredientSearchView: View {
    @Environment(IngredientSearchViewModel.self) var viewModel
    @Environment(FridgeViewModel.self) var fridgeVM
    @Environment(NavigationRouter.self) var router
    
    var body: some View {
        @Bindable var viewModel = viewModel
        VStack {
            HStack {
                Button( action: { router.pop() } ) {
                    Image("icon-back-big")
                        .foregroundStyle(.grey700)
                }
                
                Button ( action: { router.push(.ingredientDetailSearch) } ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 44)
                            .foregroundStyle(.grey100)
                        
                        HStack {
                            Text("재료명을 입력하세요.")
                                .font(.PretendardRegular16)
                                .foregroundStyle(.grey400)
                                .padding(.leading, 14)
                            Spacer()
                            Image("icon-search")
                                .foregroundStyle(.grey500)
                                .padding(.trailing, 14)
                        }
                    }
                }
            }.padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Category.allCases, id: \.self) { category in
                        VStack {
                            Button( action: { viewModel.selectedCategory = category } ) {
                                Text(category.rawValue)
                                    .foregroundStyle(viewModel.selectedCategory == category ? .grey900 : .grey400)
                                    .font(.PretendardSemibold18)
                            }.padding(.bottom, 4)
                            
                            Rectangle()
                                .frame(width: 63, height: 2)
                                .foregroundStyle(viewModel.selectedCategory == category ? .grey900 : .clear)
                        }.padding(.leading)
                    }
                }
            }.padding(.vertical, 10)
            
            IngredientList(ingredients: viewModel.filteredIngredients,
                           onSaveTap: { id in
                Task { await viewModel.toggleSaved(id: id) }},
                           onPlusTap: { item in viewModel.selectedIngredientForAddition = item},
                           // MARK: 무한스크롤 구현 - 마지막 item 나타나면 fetchNextPage() 호출
                           onLastAppear: { item in
                                            if item.id == viewModel.allIngredients.last?.id {
                                                Task { await viewModel.fetchNextPage() } }})
                            
        }.sheet(item: $viewModel.selectedIngredientForAddition) { ingredient in
            IngredientAdditionBottomSheet(ingredient: ingredient,
                                          onAdd: { storage, date, weight in
                Task {
                    await fridgeVM.addIngredient(id: ingredient.id,
                                                 ty: storage.rawValue,
                                                 date: date,
                                                 amount: weight)
                    viewModel.selectedIngredientForAddition = nil
                    router.navigateToRoot()
                    viewModel.searchText = ""
                }
            },
                                          onSave: { id in
                Task { await viewModel.toggleSaved(id: ingredient.id) }
                viewModel.selectedIngredientForAddition?.isSaved.toggle()
            },
                                          onDismiss: {
                viewModel.selectedIngredientForAddition = nil
                viewModel.searchText = ""
            }).presentationDetents([.fraction(0.98)])
        }
        .navigationBarBackButtonHidden()
        .task {
            await viewModel.fetchIngredients()
        }
        
    }
}

#Preview {
    IngredientSearchView()
        .environment(NavigationRouter())
        .environment(FridgeViewModel())
        .environment(IngredientSearchViewModel())
}
