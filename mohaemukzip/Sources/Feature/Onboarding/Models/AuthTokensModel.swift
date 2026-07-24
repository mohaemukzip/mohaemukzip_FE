import Foundation

struct AuthTokensModel {
    let userId: Int
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let isInactive: Bool
    let loginType: String
//<<<<<<< HEAD
    let termsAgreed: Bool
//=======
//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
}

extension SignUpResultDTO {
    func toModel() -> AuthTokensModel {
        AuthTokensModel(
            userId: id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: isNewUser,
            isInactive: isInactive,
//<<<<<<< HEAD
            loginType: loginType,
            termsAgreed: termsAgreed
//=======
            
//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
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
//<<<<<<< HEAD
            loginType: loginType,
            termsAgreed: termsAgreed
//=======
            //loginType: loginType
//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
        )
    }
}
