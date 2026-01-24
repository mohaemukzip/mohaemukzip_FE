//
//  IngredientDetailCard.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/15/26.
//

import SwiftUI

struct IngredientDetailCard: View {
    let ingredientInfo: IngredientDetailCardModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.grey50)
                .frame(width: 76, height: 72)
            VStack {
                Text(ingredientInfo.name)
                    .font(.PretendardMedium13)
                    .foregroundStyle(.grey900)
                Spacer().frame(height: 4)
                Text(ingredientInfo.amount)
                    .font(.PretendardRegular13)
                    .foregroundStyle(.grey600)
                Text("(\(ingredientInfo.nnng))")
                    .font(.PretendardRegular13)
                    .foregroundStyle(.grey600)
            }
        }
    }
    
}

#Preview {
    IngredientDetailCard(ingredientInfo: IngredientDetailCardModel(name: "양배추", amount: "100g", nnng: "nnng"))
}
