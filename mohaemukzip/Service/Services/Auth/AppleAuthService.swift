//
//  AppleAuthService.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/15/26.
//

import AuthenticationServices
import UIKit

enum AppleAuthError: Error {
    case invalidIdentityToken
}

final class AppleAuthService: NSObject {
    private var continuation: CheckedContinuation<String, Error>?

    func login() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()

            // 서버가 identityToken만 받으니까 scope는 필수 아님
            // 필요하면 최초 가입자 이메일/이름 수집용으로 사용
            // request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(
                authorizationRequests: [request]
            )
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

extension AppleAuthService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let identityToken = String(data: tokenData, encoding: .utf8) else {
            continuation?.resume(throwing: AppleAuthError.invalidIdentityToken)
            continuation = nil
            return
        }

        continuation?.resume(returning: identityToken)
        continuation = nil
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
