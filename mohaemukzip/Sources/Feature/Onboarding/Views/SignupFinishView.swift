//
//  SignupFinishView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/30/26.
//

import SwiftUI

struct SignupFinishView: View {
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 8) {
                Spacer().frame(height: 80)

                Text("가입이 완료되었어요!")
                    .font(.PretendardSemibold24)
                    .foregroundStyle(.grey900)

                Text("뭐해먹집과 함께 집밥 요리 루틴을 만들어보아요.")
                    .font(.PretendardRegular16)
                    .foregroundStyle(.grey500)

                Spacer()

                Image("signupLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding(.horizontal, 17)

            VStack {
                Spacer()

                Button {
                    router.push(.login)
                } label: {
                    Text("시작하기")
                        .font(.PretendardSemibold18)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 57)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.main400)
                        )
                }
                .padding(.horizontal, 17)
                .padding(.bottom, 38)
            }
        }
    }
}

#Preview {
    SignupFinishView()
        .environment(NavigationRouter())
}
