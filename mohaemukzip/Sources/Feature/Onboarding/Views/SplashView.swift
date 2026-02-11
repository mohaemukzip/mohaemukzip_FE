
import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var appState: AppState
    
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
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if appState.accessToken == nil {
                appState.root = .auth
            } else {
                appState.root = .main
            }
        }
    }
}
