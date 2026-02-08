//
//  RootView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/30/26.
//

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
        TokenStore.clear() // << 자동로그인 제거용
        Task { @MainActor in
            // 스플래시가 너무 빨리 사라져서 안 보이는 문제 방지 (필요 시 시간 조절)
            try? await Task.sleep(nanoseconds: 1500_000_000)

            let tokens = TokenStore.loadTokens()
            accessToken = tokens.access
            refreshToken = tokens.refresh

            print("boot accessToken:", accessToken ?? "nil")

            // Config 와 동기화 (API 레이어가 Config를 참조하는 구조 유지)
            Config.accessTK = accessToken ?? ""
            Config.refreshTK = refreshToken ?? ""

            root = (accessToken == nil) ? .auth : .main
        }
    }

    func loginSucceeded(accessToken: String, refreshToken: String) {
        TokenStore.saveTokens(access: accessToken, refresh: refreshToken)
        self.accessToken = accessToken
        self.refreshToken = refreshToken

        Config.accessTK = accessToken
        Config.refreshTK = refreshToken

        root = .main
    }
    
// 로그아웃 미구현
//    func logout() {
//        TokenStore.clear()
//        accessToken = nil
//        refreshToken = nil
//
//        Config.accessTK = nil
//        Config.refreshTK = nil
//
//        root = .auth
//    }
}

// MARK: - Token Store (임시: UserDefaults)

enum TokenStore {
    private static let accessKey = "ACCESS_TOKEN"
    private static let refreshKey = "REFRESH_TOKEN"

    struct Tokens {
        let access: String?
        let refresh: String?
    }

    static func loadTokens() -> Tokens {
        return .init(
            access: UserDefaults.standard.string(forKey: accessKey),
            refresh: UserDefaults.standard.string(forKey: refreshKey)
        )
    }

    static func saveTokens(access: String, refresh: String?) {
        UserDefaults.standard.set(access, forKey: accessKey)
        if let refresh {
            UserDefaults.standard.set(refresh, forKey: refreshKey)
        } else {
            UserDefaults.standard.removeObject(forKey: refreshKey)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: accessKey)
        UserDefaults.standard.removeObject(forKey: refreshKey)
    }

    /// 개발 중: 자동로그인 상태 해제용
    static func clearTokenForDebug() {
        clear()
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
