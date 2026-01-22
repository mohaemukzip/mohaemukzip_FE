//
//  IngredientSearchView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/21/26.
//

import SwiftUI

struct IngredientSearchView: View {
    @Binding var selectedCategory: IngredientCategory
    @StateObject var viewModel = IngredientSearchViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button( action: { } ) {
                    Image("icon-back-big")
                        .foregroundStyle(.grey700)
                }
                
                Button ( action: { /* FRG-SRC-002 이동 */ } ) {
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
        .onChange(of: selectedCategory) {
            viewModel.selectedCategory = selectedCategory
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory: IngredientCategory = .all
    IngredientSearchView(selectedCategory: $selectedCategory)
}
