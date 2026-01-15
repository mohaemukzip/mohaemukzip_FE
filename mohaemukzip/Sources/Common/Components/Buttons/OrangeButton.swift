//
//  Button.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/15/26.
//

import SwiftUI

enum type {
    case big
    case small
}

struct OrangeButton: View {
    let text: String
    let type: type
    
    var body: some View {
        switch type {
        case .big:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.main400)
                    .frame(width: 359, height: 57)
                Text(text)
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold18)
            }
        case .small:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.main400)
                    .frame(width: 150, height: 46)
                Text(text)
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold16)
            }
        } // end of switch
        
    } // end of body
}

#Preview {
    OrangeButton(text: "시작하기", type: .small)
}

/// OrangeButton(text: "버튼 안에 넣을 텍스트", type: .big 아니면 .small)
