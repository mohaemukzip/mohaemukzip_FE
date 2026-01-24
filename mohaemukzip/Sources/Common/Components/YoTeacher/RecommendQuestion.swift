//
//  RecommendQuestion.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import SwiftUI

struct RecommendQuestion: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.PretendardMedium13)
            .foregroundStyle(.main400)
            .lineSpacing(1.5)
            .padding(10)
            .frame(maxWidth: 110)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.main400, lineWidth: 1)
            )
    }
}

#Preview {
    RecommendQuestion(text: "이건 어떠세요? 추천 메뉴는 라면입니다. ㅋㅋ")
}
