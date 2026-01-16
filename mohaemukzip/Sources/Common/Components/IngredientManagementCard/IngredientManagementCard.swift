//
//  IngredientCard.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/15/26.
//

import SwiftUI

struct IngredientManagementCard: View {
    let ingredientInfo: IngredientManagementCardModel
    let color: Color // MARK: viewModel에서 소비기한 계산해서 color 넘겨줄 것
    
        
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.grey50)
                .frame(width: 76, height: 80)
            VStack {
                Text(ingredientInfo.name)
                    .font(.PretendardMedium13)
                    .foregroundStyle(.grey900)
                Spacer().frame(height: 4)
                Text(ingredientInfo.amount)
                    .font(.PretendardMedium13)
                    .foregroundStyle(.grey600)
                Spacer().frame(height: 6)
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                        .foregroundStyle(Color.clear)
                        .frame(width: 44, height: 18)
                    
                    Text("D-\(ingredientInfo.expirationDate)")
                        .font(.PretendardMedium13)
                        .foregroundStyle(color)
                }
            }
        }

    } // end of body
}

#Preview {
    IngredientManagementCard(ingredientInfo: IngredientManagementCardModel(name: "배추", amount: "100g", expirationDate: 100), color: .green)
}
