import Foundation
import Moya

final class AuthService {
    // Singleton instance used across the app
    static let shared = AuthService()
    private let provider = NetworkManager.shared.makeProvider(for: AuthAPI.self)
    
    func signup(nickname: String, loginId: String, password: String, terms: [SignUpTermDTO]) async throws -> AuthTokensModel {
        let requestDTO = SignUpRequestDTO(
            nickname: nickname,
            loginId: loginId,
            password: password,
            terms: terms
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.signup(requestDTO)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(SignUpResponseDTO.self)
                        continuation.resume(returning: decoded.result.toModel())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func login(loginId: String, password: String) async throws -> AuthTokensModel {
        let requestDTO = LoginRequestDTO(loginId: loginId, password: password)
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.login(requestDTO)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(LoginResponseDTO.self)
                        let model = decoded.result.toModel()
                        
                        // 정상 동작: 로그인 성공 시 토큰을 저장하고 상위(AppState 등)에서 화면 전환을 처리한다.
                        // 아래 TEST ONLY 블록은 "access 토큰이 깨진 상태에서 401 → reissue → 재시도" 흐름이
                        // 자동으로 동작하는지 확인하기 위한 테스트 코드다.
                        // - 평소엔 주석 상태로 두고,
                        // - 테스트할 때만 주석을 풀어 사용한 뒤 반드시 제거한다.
                        /*
                         // ================================
                         // TEST ONLY: accessToken 강제 오염
                         // 자동 reissue 동작 확인용
                         // ================================
                         let corruptedAccess = String(model.accessToken.dropLast(8)) + "TESTTEST"
                         
                         // UserDefaults/Keychain 저장소에 오염된 access를 덮어쓴다.
                         TokenStore.saveTokens(access: corruptedAccess, refresh: model.refreshToken)
                         
                         // 런타임에서 사용하는 Config도 함께 갱신한다.
                         Config.accessTK = corruptedAccess
                         Config.refreshTK = model.refreshToken
                         
                         print("[TEST] access token intentionally corrupted")
                         */
                        
                        continuation.resume(returning: model)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Kakao Login
    func kakaoLogin(kakaoAccessToken: String) async throws -> AuthTokensModel {
        let requestDTO = KakaoLoginRequestDTO(kakaoAccessToken: kakaoAccessToken)
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.kakaoLogin(requestDTO)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(LoginResponseDTO.self)
                        continuation.resume(returning: decoded.result.toModel())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: Apple Login
    func appleLogin(identityToken: String) async throws -> AuthTokensModel {
        let requestDTO = AppleLoginRequestDTO(identityToken: identityToken)
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.appleLogin(requestDTO)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(LoginResponseDTO.self)
                        continuation.resume(returning: decoded.result.toModel())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: 약관 여부 전달
    func submitTermsAgreement(terms: [SignUpTermDTO], token: String) async throws -> Bool {
        let requestDTO = terms
        
        return await withCheckedContinuation { continuation in
            provider.request(.agreeTerms(requestDTO, token)) { result in
                switch result {
                case .success:
                    continuation.resume(returning: true)
                case .failure:
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    // MARK: - Check LoginId (Duplicate Check)
    func checkLoginId(loginId: String) async throws -> CheckLoginIdModel {
        let requestDTO = CheckLoginIdRequestDTO(loginId: loginId)
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.checkLoginId(requestDTO)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(CheckLoginIdResponseDTO.self)
                        continuation.resume(returning: decoded.toModel())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func checkDuplicateId(loginId: String) async throws -> Bool {
        try await checkLoginId(loginId: loginId).available
    }
    
    // MARK: - Token Reissue
    
    /// AccessToken 만료 등으로 401 발생 시 사용
    /// - Returns: 새로 발급된 (accessToken, refreshToken)
    func reissue() async throws -> (accessToken: String, refreshToken: String) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.reissue) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(ReissueResponseDTO.self)
                        continuation.resume(returning: (decoded.result.accessToken, decoded.result.refreshToken))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Logout
    
    func logout() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.logout) { result in
                switch result {
                case .success:
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Withdrawal
    
    func withdrawal() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.withdrawal) { result in
                switch result {
                case .success:
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    

    // MARK: - Email Verification

    /// 인증번호 발송 (비밀번호 재설정용)
    func sendResetPasswordEmail(email: String) async throws {
        let requestDTO = AuthRequestDTO.SendEmailVerificationRequest(
            email: email
        )

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.sendResetPasswordEmail(requestDTO)) { result in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.map(SendEmailVerificationResponseDTO.self)
                        continuation.resume(returning: ())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// 이메일 인증번호 요청
    func requestEmailVerification(email: String) async throws {
        let request = SendEmailVerificationRequestDTO(email: email)

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.requestEmailVerification(request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let _: SendEmailVerificationResultDTO = try response.mapResult(SendEmailVerificationResultDTO.self)
                        continuation.resume(returning: ())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// 이메일 인증번호 검증
    func verifyEmail(email: String, authCode: String) async throws -> Bool {
        let request = VerifyEmailRequestDTO(
            email: email,
            authCode: authCode
        )

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.verifyEmail(request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded: VerifyEmailResultDTO = try response.mapResult(VerifyEmailResultDTO.self)
                        continuation.resume(returning: decoded.verified)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// 비밀번호 재설정
    func resetPassword(
        email: String,
        newPassword: String
    ) async throws {
        let requestDTO = AuthRequestDTO.ResetPasswordRequest(
            email: email,
            newPassword: newPassword
        )

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.resetPassword(requestDTO)) { result in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.map(ResetPasswordResponseDTO.self)
                        continuation.resume(returning: ())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
