//
//  IngredientDetailSearchView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/22/26.
//

import SwiftUI

struct IngredientDetailSearchView: View {
    @Environment(IngredientSearchViewModel.self) var viewModel
    @Environment(FridgeViewModel.self) var fridgeVM
    @Environment(NavigationRouter.self) var router
    @State var isShowingSheet: Bool = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Button( action: { router.pop(); viewModel.searchText = "" } ) {
                        Image("icon-back-big")
                            .foregroundStyle(.grey700)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 44)
                            .foregroundStyle(.grey100)
                        
                        
                        HStack {
                            TextField("재료명을 입력하세요.", text: $viewModel.searchText)
                                .font(.PretendardRegular16)
                                .foregroundStyle(.grey900)
                                .padding(.leading, 14)
                                .onSubmit {
                                    viewModel.addRecentSearch()
                                }
                            Spacer()
                            Image("icon-search")
                                .foregroundStyle(.grey500)
                                .padding(.trailing, 14)
                        }
                    }
                }.padding()
                
                // 검색 텍스트 없는 경우
                if (viewModel.searchText.isEmpty) {
                    VStack {
                        HStack {
                            Text("최근 검색어")
                                .font(.PretendardSemibold18)
                                .foregroundStyle(.grey900)
                            Spacer()
                        }
                        if (viewModel.recentSearchText.isEmpty) {
                            Text("최근 검색어가 없어요.")
                                .font(.PretendardRegular16)
                                .foregroundStyle(.grey500)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.recentSearchText) { ingredient in
                                        RecentSearch(text: ingredient.name,
                                                     onTap: { viewModel.tapRecentSearch(for: ingredient.id)},
                                                     onDelete: { viewModel.deleteRecentSearch(for: ingredient.id)})
                                    }
                                }
                            }.padding(.vertical, 16)
                        }
                        
                        HStack {
                            Text("즐겨찾기")
                                .font(.PretendardSemibold18)
                                .foregroundStyle(.grey900)
                            Spacer()
                        }.padding(.top, 30)
                        if (viewModel.savedIngredient.isEmpty) {
                            ZStack {
                                Rectangle()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .foregroundStyle(.clear)
                                Text("즐겨찾기한 재료가 없어요.")
                                    .font(.PretendardRegular16)
                                    .foregroundStyle(.grey500)
                            }
                        } else {
                            IngredientList(ingredients: viewModel.savedIngredient,
                                           onSaveTap: { id in viewModel.toggleIsSaved(for: id) },
                                           onPlusTap: { item in viewModel.selectedIngredientForAddition = item })
                        }
                        
                    }.padding()
                } else { // 검색 텍스트 있는 경우
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(IngredientCategory.allCases, id: \.self) { category in
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
                                   onSaveTap: { id in viewModel.toggleIsSaved(for: id) },
                                   onPlusTap: { item in viewModel.selectedIngredientForAddition = item })
                }
            } // end of VStack
            Button ( action: { isShowingSheet = true } ) {
                IngredientRequestButton()
                    .padding(.horizontal)
                    .padding(.bottom, 35)
            }
            .sheet(isPresented: $isShowingSheet) {
                RequestBottomSheet(isShowingSheet: $isShowingSheet,
                                   onRequest: { requestedText in
                    viewModel.sendRequest(name: requestedText)
                    viewModel.searchText = ""
                }).presentationDetents([.fraction(0.45), .large])
            }
            .sheet(item: $viewModel.selectedIngredientForAddition) { ingredient in
                IngredientAdditionBottomSheet(ingredient: ingredient,
                                              onAdd: { storage, date, weight in
                    fridgeVM.addIngredientToFridge(name: ingredient.name,
                                                   amount: weight,
                                                   storage: storage)
                    viewModel.selectedIngredientForAddition = nil
                    router.navigateToRoot()
                },
                                              onSave: {
                    viewModel.toggleIsSaved(for: ingredient.id)
                    viewModel.selectedIngredientForAddition?.isSaved.toggle()
                },
                                              onDismiss: {
                    viewModel.selectedIngredientForAddition = nil
                    viewModel.searchText = ""
                }).presentationDetents([.fraction(0.98)])
            }
        }.navigationBarBackButtonHidden() // end of ZStack
    } // end of body
}

#Preview {
    IngredientDetailSearchView()
        .environment(NavigationRouter())
        .environment(FridgeViewModel())
        .environment(IngredientSearchViewModel())
}
