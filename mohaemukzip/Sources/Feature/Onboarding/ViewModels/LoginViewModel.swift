
import Foundation
import Observation

@Observable
final class LoginViewModel {
    // Kakao
    var isKakaoLoading: Bool = false
    var kakaoErrorMessage: String?
    private let kakaoService = KakaoAuthService()
    
    
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
            print("카카오 SDK 인증 성공")
            print("카카오 로그인 API 호출 성공")
            
            let kakaoAccessToken = try await kakaoService.login()
            let model = try await authService.kakaoLogin(kakaoAccessToken: kakaoAccessToken)
            tokens = model
            
            kakaoErrorMessage = nil
            
            return true
        } catch {
            print("카카오 로그인 실패")
            
            kakaoErrorMessage = "카카오 로그인에 실패했습니다."
            
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
