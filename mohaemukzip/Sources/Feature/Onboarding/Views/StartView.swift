//
//  StartView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/29/26.
//

import SwiftUI

struct StartView: View {
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: 12) {
                Image("onboarding5")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            VStack(spacing: 18) {
                Button {
                    router.push(.login)
                } label: {
                    HStack(spacing: 4) {
                        Text("이미 계정이 있다면?")
                            .font(.PretendardRegular16)
                            .foregroundStyle(Color.gray.opacity(0.65))

                        Text("로그인")
                            .font(.PretendardMedium16)
                            .foregroundStyle(Color.main400)
                            .underline(true, color: Color.main400)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    router.push(.agree)
                } label: {
                    Text("가입하기")
                        .font(.PretendardSemibold18)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 57)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.main400)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 17)
                .padding(.bottom, 38)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    StartView()
        .environment(NavigationRouter())
}
