//
//  AuthService.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//


import Foundation
import Moya

final class AuthService {
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
}
