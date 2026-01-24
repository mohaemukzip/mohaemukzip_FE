//
//  IngredientList.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/21/26.
//

import SwiftUI

struct IngredientList: View {
    var ingredients: [IngredientSearchModel]
    var onSaveTap: (UUID) -> Void
    var onPlusTap: (IngredientSearchModel) -> Void
    
    var body: some View {
        if (ingredients.isEmpty) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.clear)
                VStack {
                    Image("icon-noingredient")
                        .frame(width: 100)
                        .padding(.bottom, 5)
                    Text("재료가 없어요")
                        .foregroundStyle(.grey500)
                        .font(.PretendardRegular14)
                    Text("직접 재료를 등록해보세요")
                        .foregroundStyle(.grey500)
                        .font(.PretendardRegular14)
                }
            }
        }
        
        else {
            ScrollView {
                LazyVStack {
                    ForEach(ingredients) { ingredient in
                        IngredientListComponent(
                            name: ingredient.name,
                            amount: ingredient.amount,
                            category: ingredient.category,
                            isSaved: ingredient.isSaved,
                            onSaveTap: {onSaveTap(ingredient.id)},
                            onPlusTap: {onPlusTap(ingredient)})
                    }
                }
            }
        }
        
    }
}

/*
#Preview {
    IngredientList(ingredients: [
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품"),
        IngredientSearchModel(name: "대파", amount: "1기본량(100g)", category: "가공/유제품")
    ])
}
*/
