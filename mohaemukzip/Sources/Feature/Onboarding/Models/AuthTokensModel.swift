import Foundation

struct AuthTokensModel {
    let userId: Int
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let isInactive: Bool
    let loginType: String
}

extension SignUpResultDTO {
    func toModel() -> AuthTokensModel {
        AuthTokensModel(
            userId: id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: isNewUser,
            isInactive: isInactive,
            loginType: loginType
        )
    }
}

extension LoginResultDTO {
    func toModel() -> AuthTokensModel {
        AuthTokensModel(
            userId: id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: isNewUser,
            isInactive: isInactive,
            loginType: loginType
        )
    }
}
