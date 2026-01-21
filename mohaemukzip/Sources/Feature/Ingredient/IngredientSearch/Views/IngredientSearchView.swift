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
            }
            
            IngredientList(ingredients: viewModel.filteredIngredients)
            
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
