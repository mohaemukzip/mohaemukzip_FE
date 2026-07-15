
import Foundation

struct LoginRequestDTO: Encodable {
    let loginId: String
    let password: String
}

struct KakaoLoginRequestDTO: Encodable {
    let kakaoAccessToken: String
}

struct AppleLoginRequestDTO: Encodable {
    let identityToken: String
}
