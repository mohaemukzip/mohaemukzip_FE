//
//  KakaoAuthService.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/2/26.
//

import Foundation
import KakaoSDKUser
import KakaoSDKAuth

final class KakaoAuthService {
    
    // 카카오톡 앱 설치 -> 카카오톡 앱으로 SDK 인증: loginWithKakaoTalk
    // 카카오톡 앱 미설치 -> 브라우저로 이동하여 SDK 인증: loginWithKakaoAccount
    func login() async throws -> String {
        if UserApi.isKakaoTalkLoginAvailable() {
            return try await loginWithKakaoTalk()
        } else {
            return try await loginWithKakaoAccount()
        }
    }
    
    // 카카오톡 앱 설치된 경우
    private func loginWithKakaoTalk() async throws -> String {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<String, Error>) in

            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let accessToken = token?.accessToken else {
                    continuation.resume(
                        throwing: KakaoAuthError.missingAccessToken
                    )
                    return
                }

                continuation.resume(returning: accessToken)
            }
        }
    }
    
    // 카카오톡 앱 미설치인 경우
    private func loginWithKakaoAccount() async throws -> String {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<String, Error>) in
            
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let accessToken = token?.accessToken else {
                    continuation.resume(
                        throwing: KakaoAuthError.missingAccessToken
                    )
                    return
                }
                
                continuation.resume(returning: accessToken)
            }
        }
    }
}

enum KakaoAuthError: Error {
    case missingAccessToken
}
