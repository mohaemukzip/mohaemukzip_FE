//
//  AuthService.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//


import Foundation
import Moya

final class AuthService {
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
}
