import Foundation

// MARK: - 이메일 인증 발송
struct SendEmailVerificationResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SendEmailVerificationResultDTO?
}

struct SendEmailVerificationResultDTO: Decodable {
    let message: String
}

// MARK: - 이메일 인증 확인

struct VerifyEmailResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: VerifyEmailResultDTO
}

struct VerifyEmailResultDTO: Decodable {
    let verified: Bool
    let message: String
}

// MARK: - 비밀번호 재설정

struct ResetPasswordResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: EmptyResultDTO?
}

// MARK: - 공통 Result

struct EmptyResultDTO: Decodable { }
