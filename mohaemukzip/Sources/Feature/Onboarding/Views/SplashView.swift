
import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.main400.ignoresSafeArea()
            Image(.loginLogo)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 69)
                .foregroundStyle(.white)
        }
    }
}
