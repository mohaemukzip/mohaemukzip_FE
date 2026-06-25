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
        HStack {
            Text(title)
                .font(.custom("Pretendard-Regular", size: 16))
                .foregroundStyle(Color.black)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
