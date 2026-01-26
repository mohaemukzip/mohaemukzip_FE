//
//  YoTeacherFloating.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import SwiftUI

struct YoTeacherFloating: View {
    var onTap: () -> Void
    
    var body: some View {
        // MARK: - 세부 카테고리 선택 후 요선생 플로팅 버튼
        HStack {
            Spacer()
            VStack {
                Spacer()
                Button( action: { onTap() } ) {
                    Image("icon-yoteacher-floating")
                }
            }
        }.padding(.bottom, 25)
            .padding(.trailing, 25)
    }
}

#Preview {
    YoTeacherFloating(onTap: { })
}
