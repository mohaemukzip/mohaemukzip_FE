struct LoginResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: LoginResultDTO
}

struct LoginResultDTO: Decodable {
    let id: Int
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
