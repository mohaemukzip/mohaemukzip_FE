
import Foundation
import Observation
import AuthenticationServices

@Observable
final class LoginViewModel {
    // Kakao
    var isKakaoLoading: Bool = false
    var kakaoErrorMessage: String?
    private let kakaoService = KakaoAuthService()
    
    // Apple
    var isAppleLoading: Bool = false
    var appleErrorMessage: String?
    private let appleService = AppleAuthService()
    
    
    // Inputs
    var loginId: String = ""
    var password: String = ""

    // Outputs / UI State
    var isLoading: Bool = false
    var showError: Bool = false
    var errorMessage: String? = nil

    private(set) var tokens: AuthTokensModel? = nil

    private let authService = AuthService()

    @MainActor
    func login() async -> Bool {
        guard !loginId.isEmpty, !password.isEmpty else {
            showError = true
            errorMessage = "아이디와 비밀번호를 입력해주세요."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            print("🟡 [LOGIN] request → loginId: \(loginId)")
            let model = try await authService.login(loginId: loginId, password: password)
            tokens = model
//<<<<<<< HEAD
            
//=======
            print("🟢 [LOGIN] success → userId: \(model.userId)")
            //print("🟢 [LOGIN] accessToken: \(model.accessToken.prefix(20))...")
            //print("🟢 [LOGIN] refreshToken: \(model.refreshToken.prefix(20))...")

            // 토큰 저장
            /*Config.accessTK = model.accessToken
            Config.refreshTK = model.refreshToken*/
            Config.loginId = loginId

//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
            showError = false
            errorMessage = nil
            return true
        } catch {
            print("🔴 [LOGIN] failed → error: \(error)")
            showError = true
            errorMessage = "아이디 또는 비밀번호가 잘못 되었습니다. 다시 입력해주세요."
            return false
        }
    }
    
    @MainActor
    func loginWithKakao() async -> Bool {
        guard !isKakaoLoading else { return false }
        
        isKakaoLoading = true
        defer { isKakaoLoading = false }
        
        do {
            let kakaoAccessToken = try await kakaoService.login()
            print("카카오 SDK 인증 성공")
            let model = try await authService.kakaoLogin(kakaoAccessToken: kakaoAccessToken)
            print("카카오 로그인 API 호출 성공")
            tokens = model
            
            kakaoErrorMessage = nil
            
            return true
        } catch {
            print("카카오 로그인 실패")
            
            kakaoErrorMessage = "카카오 로그인에 실패했습니다."
            
            return false
        }
    }
    
    @MainActor
    func loginWithApple() async -> Bool {
        guard !isAppleLoading else { return false }
        
        isAppleLoading = true
        defer { isAppleLoading = false }
        
        do {
            let identityToken = try await appleService.login()
            print("애플 SDK 인증 성공")
            let tokens = try await authService.appleLogin(identityToken: identityToken)
            print("애플 로그인 API 호출 성공")
            self.tokens = tokens
            
            appleErrorMessage = nil
            
            return true
        } catch {
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled { return false }
            
            print("애플 로그인 실패")
            appleErrorMessage = "애플 로그인에 실패했습니다."
            return false
        }
    }

    func clearErrorIfNeeded() {
        if showError {
            showError = false
            errorMessage = nil
        }
    }
}
