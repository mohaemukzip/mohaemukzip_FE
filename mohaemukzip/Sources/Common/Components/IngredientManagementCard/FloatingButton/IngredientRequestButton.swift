//
//  IngredientRequestButton.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/23/26.
//

import SwiftUI

struct IngredientRequestButton: View {
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.white)
                .frame(height: 79)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(.grey400)
                .frame(height: 79)
            
            HStack {
                VStack {
                    HStack {
                        Text("찾는 재료가 없나요?")
                            .font(.PretendardSemibold16)
                            .foregroundStyle(.black)
                        Spacer()
                    }.padding(.bottom, 1)
                    
                    HStack {
                        Text("없는 재료는 바로 추가 요청해보세요")
                            .font(.PretendardRegular14)
                            .foregroundStyle(.grey600)
                        Spacer()
                    }.padding(.top, 1)
                }.padding(.leading, 18)
                
                Image("icon-chevron-right")
                    .foregroundStyle(.grey500)
                    .padding(.trailing, 18)
            }
            
        }
        
    }
}

#Preview {
    IngredientRequestButton()
}
