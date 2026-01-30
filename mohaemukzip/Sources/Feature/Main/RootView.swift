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

    /// 앱 시작 시 토큰 확인 후 루트 결정
    func boot() {
        #if DEBUG
        // ✅ 개발 중에는 자동로그인으로 main으로 튀지 않게 Auth 플로우부터 보이게
        // 필요하면 false로 바꾸면 토큰 기반 자동로그인 테스트 가능
        let forceAuthForDebug = true
        if forceAuthForDebug {
            accessToken = nil
            root = .splash
            return
        }
        #endif

        accessToken = TokenStore.loadAccessToken()
        root = (accessToken == nil) ? .auth : .main
    }

    func loginSucceeded(token: String) {
        TokenStore.saveAccessToken(token)
        accessToken = token
        root = .main
    }

    func logout() {
        TokenStore.clear()
        accessToken = nil
        root = .auth
    }
}

// MARK: - Token Store (임시: UserDefaults)

/// ✅ 나중에 Keychain으로 교체 추천
enum TokenStore {
    private static let key = "access_token"

    static func loadAccessToken() -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    static func saveAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
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
