//
//  SplashView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/30/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        ZStack {
            Color.main400
                .ignoresSafeArea()

            Image("loginLogo")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.white)
                .scaledToFit()
                .frame(width: 64, height: 64)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                router.push(.onboarding)
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(NavigationRouter())
}
