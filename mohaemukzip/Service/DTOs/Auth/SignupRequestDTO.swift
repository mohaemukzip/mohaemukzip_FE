
import SwiftUI
import Foundation

struct SignUpRequestDTO: Encodable {
    let nickname: String
    let loginId: String
    let password: String
    let terms: [SignUpTermDTO]

    enum CodingKeys: String, CodingKey {
        case nickname
        case loginId
        case password
        case terms = "termAgreements"
    }
}

struct SignUpTermDTO: Encodable, Equatable, Hashable {
    let id: Int
    var isAgreed: Bool

    enum CodingKeys: String, CodingKey {
        case id = "termId"
        case isAgreed
    }
}

struct SendEmailVerificationRequestDTO: Encodable {
    let email: String
}

struct SendEmailVerificationResultDTO: Decodable {
    let message: String
}

struct VerifyEmailRequestDTO: Encodable {
    let email: String
    let authCode: String
}

struct VerifyEmailResultDTO: Decodable {
    let verified: Bool
    let message: String
}
