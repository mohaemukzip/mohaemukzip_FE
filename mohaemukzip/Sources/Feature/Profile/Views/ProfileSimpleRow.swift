//
//  ProfileSimpleRow.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/11/26.
//

import SwiftUI

// MARK: - 공용 Row

struct ProfileSimpleRow: View {

    // MARK: - Properties

    let title: String

    // MARK: - Body

    var body: some View {
        Button {
            print("[ProfileView] ℹ️ \(title) 탭 - 추후 연결")
        } label: {
            HStack {
                Text(title)
                    .font(.custom("Pretendard-Regular", size: 16))
                    .foregroundStyle(Color.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}




