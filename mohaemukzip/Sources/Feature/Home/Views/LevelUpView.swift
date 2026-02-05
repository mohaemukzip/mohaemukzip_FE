//
//  LevelUpView.swift
//  mohaemukzip
//
//  Created by 이서현 on 2/4/26.
//

import SwiftUI

struct LevelUpView: View {
    let level: Int
    var onConfirm: (() -> Void)? = nil

    private var content: LevelUpContent {
        LevelUpContent(level: level)
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 96)

                VStack(spacing: 10) {
                    Text("레벨업 성공!")
                        .font(.PretendardSemibold24)
                        .foregroundStyle(.grey900)

                    Text("\(content.title)가 되었어요.")
                        .font(.PretendardRegular16)
                        .foregroundStyle(.grey500)
                }

                Spacer().frame(height: 56)

                Image(content.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260)

                Spacer().frame(height: 44)

                HStack(spacing: 6) {
                    Text("Lv.\(content.level)")
                        .font(.PretendardRegular14)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(.grey700)
                        )

                    Text(content.title)
                        .font(.PretendardSemibold18)
                        .kerning(-0.5)
                        .foregroundStyle(.black)
                }

                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                onConfirm?()
            } label: {
                Text("확인")
                    .font(.PretendardSemibold18)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.main400)
                    )
            }
            .padding(.horizontal, 17)
            .padding(.bottom, 38)
        }
    }
}

private struct LevelUpContent {
    let level: Int
    let title: String
    let imageName: String

    init(level: Int) {
        let clamped = min(max(level, 1), 4)
        self.level = clamped

        switch clamped {
        case 1:
            self.title = "집밥 입문자"
            self.imageName = "icnLv1"
        case 2:
            self.title = "집밥 적응중"
            self.imageName = "icnLv2"
        case 3:
            self.title = "집밥 루틴러"
            self.imageName = "icnLv3"
        default:
            self.title = "집밥계의 고수"
            self.imageName = "icnLv4"
        }
    }
}

#Preview {
    LevelUpView(level: 1)
}
