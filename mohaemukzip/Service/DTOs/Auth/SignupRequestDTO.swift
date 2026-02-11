
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

struct SignUpTermDTO: Encodable {
    let id: Int
    let isAgreed: Bool

    enum CodingKeys: String, CodingKey {
        case id = "termId"
        case isAgreed
    }
}
