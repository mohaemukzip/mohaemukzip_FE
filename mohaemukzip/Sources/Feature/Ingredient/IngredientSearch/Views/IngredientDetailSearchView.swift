//
//  IngredientDetailSearchView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/22/26.
//

import SwiftUI

struct IngredientDetailSearchView: View {
    @Binding var selectedCategory: IngredientCategory
    @StateObject var viewModel = IngredientSearchViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Button( action: { } ) {
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
                                           onSaveTap: { id in
                                viewModel.toggleIsSaved(for: id)
                            })
                        }
                        
                    }.padding()
                } else { // 검색 텍스트 있는 경우
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(IngredientCategory.allCases, id: \.self) { category in
                                VStack {
                                    Button( action: { selectedCategory = category } ) {
                                        Text(category.rawValue)
                                            .foregroundStyle(selectedCategory == category ? .grey900 : .grey400)
                                            .font(.PretendardSemibold18)
                                    }.padding(.bottom, 4)
                                    
                                    Rectangle()
                                        .frame(width: 63, height: 2)
                                        .foregroundStyle(selectedCategory == category ? .grey900 : .clear)
                                }.padding(.leading)
                            }
                        }
                    }.padding(.vertical, 10)
                    
                    IngredientList(ingredients: viewModel.filteredIngredients,
                                   onSaveTap: { id in
                        viewModel.toggleIsSaved(for: id)
                    })
                }
            }.onChange(of: selectedCategory) {
                viewModel.selectedCategory = selectedCategory
            } // end of VStack
            
            IngredientRequestButton()
                .padding(.horizontal)
                .padding(.bottom, 35)
        } // end of ZStack
    } // end of body
}

#Preview {
    @Previewable @State var selectedCategory: IngredientCategory = .all
    IngredientDetailSearchView(selectedCategory: $selectedCategory)
}
