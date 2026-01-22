//
//  IngredientListComponent.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/21/26.
//

import SwiftUI

struct IngredientListComponent: View {
    let name: String
    let amount: String
    let category: String
    let isSaved: Bool
    let onSaveTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(name)
                        .foregroundStyle(.grey900)
                        .font(.PretendardMedium16)
                    Button( action: { onSaveTap() } ) {
                        Image("icon-star")
                            .foregroundStyle(isSaved ? .main300 : .grey300)
                    }
                }
                Text(amount)
                    .foregroundStyle(.grey500)
                    .font(.PretendardRegular13)
            }
            
            Spacer()
            
            Button( action: { } ) {
                Image("icon-plus")
                    .frame(width: 32, height: 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 96)
        .padding()
    }
}


#Preview {
    IngredientListComponent(name: "대파", amount: "1기본량(100g)", category: "가공/유제품", isSaved: false, onSaveTap: { })
}

