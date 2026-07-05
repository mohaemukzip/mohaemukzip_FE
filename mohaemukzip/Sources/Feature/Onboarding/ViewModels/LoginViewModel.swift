
import Foundation
import Observation

@Observable
final class LoginViewModel {
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
            print("🟢 [LOGIN] success → userId: \(model.userId)")
            print("🟢 [LOGIN] accessToken: \(model.accessToken.prefix(20))...")
            print("🟢 [LOGIN] refreshToken: \(model.refreshToken.prefix(20))...")

            // 토큰 저장
            Config.accessTK = model.accessToken
            Config.refreshTK = model.refreshToken
            Config.loginId = loginId

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

    func clearErrorIfNeeded() {
        if showError {
            showError = false
            errorMessage = nil
        }
    }
}
