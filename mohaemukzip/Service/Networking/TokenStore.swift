import Foundation
import KeychainSwift

enum TokenStore {
    
    // 키체인에 접근하기 위한 키
    private static let accessKey = "ACCESS_TOKEN"
    private static let refreshKey = "REFRESH_TOKEN"
    private static let loginTypeKey = "LOGIN_TYPE"
    
    // 키체인
    private static let keychain = KeychainSwift(keyPrefix: "mohaemukzip.umc")

    // 토큰 구조체
    struct Tokens {
        let access: String?
        let refresh: String?
        let loginType: String?
    }

    // 저장된 토큰을 불러오는 함수
    static func loadTokens() -> Tokens {
        return Tokens(
            access: keychain.get(accessKey),
            refresh: keychain.get(refreshKey),
            loginType: keychain.get(loginTypeKey)
        )
    }

    // 로그인 API 호출 후 받아온 토큰들을 키체인에 저장하는 함수
    static func saveTokens(access: String, refresh: String, loginType: String? = nil) {
        keychain.set(access, forKey: accessKey)
        keychain.set(refresh, forKey: refreshKey)
        
        if let loginType, !loginType.isEmpty {
            keychain.set(loginType, forKey: loginTypeKey)
        }
    }

    // 키체인에 저장되어 있는 토큰 삭제하는 함수
    static func clear() {
        keychain.delete(accessKey)
        keychain.delete(refreshKey)
        keychain.delete(loginTypeKey)
    }

}

