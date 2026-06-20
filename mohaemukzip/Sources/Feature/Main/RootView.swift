

import SwiftUI
import Combine

// MARK: - Root Switching State

/// 앱 전체에서 "어떤 루트 화면을 보여줄지"만 결정하는 상태
final class AppState: ObservableObject {
    enum Root {
        case splash
        case auth
        case main
    }

    @Published var root: Root = .splash
    @Published var accessToken: String? = nil
    @Published var refreshToken: String? = nil

    /// 앱 시작 시 토큰 확인 후 루트 결정
    func boot() {
        // Splash 를 먼저 보여주고, 토큰 로딩 후 루트를 결정
        root = .splash
        Task { @MainActor in
            // 스플래시가 너무 빨리 사라져서 안 보이는 문제 방지 (필요 시 시간 조절)
            try? await Task.sleep(nanoseconds: 1500_000_000)

            let tokens = TokenStore.loadTokens()
            accessToken = tokens.access
            refreshToken = tokens.refresh

            print("boot accessToken:", accessToken ?? "nil")

            // accessToken이 있으면 바로 메인
            if let accessToken, !accessToken.isEmpty {
                root = .main
                return
            }

            // accessToken이 없고 refreshToken만 있으면 1회 재발급 시도
            if let refreshToken, !refreshToken.isEmpty {
                print("[AppState] boot -> accessToken nil, try reissue")
                do {
                    let tokens = try await AuthService.shared.reissue()
                    loginSucceeded(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
                    print("[AppState] boot -> reissue success, go main")
                } catch {
                    print("[AppState] boot -> reissue fail, go auth | error=\(error)")
                    clearSession(reason: "boot reissue fail")
                }
                return
            }

            // 둘 다 없으면 인증 루트
            root = .auth
        }
    }
    
    // 토큰만 저장, 홈으로 이동은 X
    func saveSession(accessToken: String, refreshToken: String) {
        TokenStore.saveTokens(
            access: accessToken,
            refresh: refreshToken
        )

        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    // 홈으로 이동
    func enterMain() {
        root = .main
    }

    // 토큰 저장 & 홈으로 이동
    func loginSucceeded(accessToken: String, refreshToken: String) {
        saveSession(accessToken: accessToken, refreshToken: refreshToken)
        enterMain()
    }


    // MARK: - Session Control

    /// 토큰/루트 전환을 한 곳에서 처리
    @MainActor
    private func clearSession(reason: String) {
        print("[AppState] clearSession | reason=\(reason)")

        TokenStore.clear()
        accessToken = nil
        refreshToken = nil
        root = .auth
    }

    /// 마이페이지 로그아웃 버튼에서 호출할 예정
    @MainActor
    func logout() async {
        print("[AppState] logout -> start")
        do {
            try await AuthService.shared.logout()
            print("[AppState] logout -> api success")
            clearSession(reason: "logout")
        } catch {
            // 서버가 이미 세션을 만료/차단한 경우에도 로컬은 안전하게 정리
            print("[AppState] logout -> api fail, clear local anyway | error=\(error)")
            clearSession(reason: "logout api fail")
        }
    }

    /// 마이페이지 회원탈퇴 버튼에서 호출할 예정
    @MainActor
    func withdrawal() async {
        print("[AppState] withdrawal -> start")
        do {
            try await AuthService.shared.withdrawal()
            print("[AppState] withdrawal -> api success")
            clearSession(reason: "withdrawal")
        } catch {
            // 탈퇴 API 실패여도 토큰이 꼬였을 수 있으니 로컬은 정리
            print("[AppState] withdrawal -> api fail, clear local anyway | error=\(error)")
            clearSession(reason: "withdrawal api fail")
        }
    }
    
    // 세션 만료 (리프레시 토큰 만료)
    @MainActor
    func sessionExpired() {
        clearSession(reason: "refresh token expired")
    }
}


// MARK: - RootView

/// ✅ Splash/Auth/Main 을 "push"가 아니라 "뷰 자체 교체"로 전환
struct RootView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            switch appState.root {
            case .splash:
                SplashView()
                    .environmentObject(appState)

            case .auth:
                AuthRootView()
                    .environmentObject(appState)

            case .main:
                MainTabView()
                    .environmentObject(appState)
            }
        }
        .onAppear {
            // 첫 진입 시 1번만 부트
            if appState.root == .splash {
                appState.boot()
            }
        }
        // 리프레시 토큰 만료 알림을 받아 처리
        .onReceive(
            NotificationCenter.default.publisher(
                for: .authSessionExpired
            )
        ) { _ in
            Task { @MainActor in
                appState.sessionExpired()
            }
        }
    }
}

// MARK: - Auth Router

enum AuthRoute: Hashable {
    case onboarding
    case login
    case signup
    case signupFinish
    case start
    case agree
}

final class AuthRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: AuthRoute) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func popToRoot() { path = .init() }
}

// MARK: - Auth Root

struct AuthRootView: View {
    @StateObject private var router = AuthRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            OnboardingView()
                .environmentObject(router)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .onboarding:
                        OnboardingView().environmentObject(router)
                    case .login:
                        LoginView().environmentObject(router)
                    case .signup:
                        SignupView().environmentObject(router)
                    case .signupFinish:
                        SignupFinishView().environmentObject(router)
                    case .start:
                        StartView().environmentObject(router)
                    case .agree:
                        AgreeView().environmentObject(router)
                    }
                }
        }
    }
}

#Preview {
    RootView()
}
