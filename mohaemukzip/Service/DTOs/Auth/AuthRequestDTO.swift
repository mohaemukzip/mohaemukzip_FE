//
//  AuthRequestDTO.swift
//  mohaemukzip
//
//  Created by 고석현 on 7/19/26.
//


import Foundation

enum AuthRequestDTO {

    /// 이메일 인증번호 발송
    struct SendEmailVerificationRequest: Encodable {
        let email: String
    }

    /// 이메일 인증번호 검증
    struct VerifyEmailRequest: Encodable {
        let email: String
        let authCode: String
    }

    /// 비밀번호 재설정
    struct ResetPasswordRequest: Encodable {
        let email: String
        let newPassword: String
    }
}
