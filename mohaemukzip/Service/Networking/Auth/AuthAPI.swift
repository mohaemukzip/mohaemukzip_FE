import Foundation
import Moya
import Alamofire

enum AuthAPI {
    case signup(SignUpRequestDTO)
    case login(LoginRequestDTO)
    case kakaoLogin(KakaoLoginRequestDTO)
    case appleLogin(AppleLoginRequestDTO)
    case agreeTerms([SignUpTermDTO], String)
    case checkLoginId(CheckLoginIdRequestDTO)

    // MARK: - Email
    case sendResetPasswordEmail(AuthRequestDTO.SendEmailVerificationRequest)
    //case verifyEmail(AuthRequestDTO.VerifyEmailRequest)
    case resetPassword(AuthRequestDTO.ResetPasswordRequest)

    case reissue
    case logout
    case withdrawal
    case requestEmailVerification(SendEmailVerificationRequestDTO)
    case verifyEmail(VerifyEmailRequestDTO)
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        print("Config.baseURL =", Config.baseURL)
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .signup:
            return "/auth/signup"

        case .login:
            return "/auth/login"
//<<<<<<< HEAD
        case .kakaoLogin:
            return "/auth/login/kakao"
        case .appleLogin:
            return "/auth/login/apple"
        case .agreeTerms:
            return "/auth/terms/agree"
//=======

//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
        case .checkLoginId:
            return "/auth/check-loginid"

        case .sendResetPasswordEmail:
            return "/auth/email/send/reset-password"

        case .verifyEmail:
            return "/auth/email/verify"

        case .resetPassword:
            return "/auth/reset-password"

        case .reissue:
            return "/auth/reissue"

        case .logout:
            return "/auth/logout"

        case .withdrawal:
            return "/auth/withdrawal"
        case .requestEmailVerification:
            return "/auth/email/send"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signup,
//<<<<<<< HEAD
            .requestEmailVerification,
            .verifyEmail,
            .login,
            .kakaoLogin,
            .appleLogin,
            .agreeTerms,
            .logout,
            .checkLoginId,
            .reissue,
//=======
             
            .sendResetPasswordEmail:
//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
            return .post

        case .resetPassword:
            return .patch

        case .withdrawal:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .signup(let request):
            return .requestJSONEncodable(request)

        case .login(let request):
            return .requestJSONEncodable(request)
//<<<<<<< HEAD
        case .kakaoLogin(let request):
            return .requestJSONEncodable(request)
        case .appleLogin(let request):
            return .requestJSONEncodable(request)
        case .agreeTerms(let request, _):
            return .requestJSONEncodable(request)
//=======

//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
        case .checkLoginId(let request):
            return .requestJSONEncodable(request)

        case .sendResetPasswordEmail(let request):
            return .requestJSONEncodable(request)

        case .verifyEmail(let request):
            return .requestJSONEncodable(request)

        case .resetPassword(let request):
            return .requestJSONEncodable(request)

        case .reissue,
             .logout,
             .withdrawal:
            return .requestPlain
        case .requestEmailVerification(let request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        let tokens = TokenStore.loadTokens()
        
        switch self {
            // NetworkManager에서 의도적으로 reissue는 제외
            // -> refresh token 수동으로 주입해주어야 함
        case .reissue:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(tokens.access ?? "")",
                "X-Refresh-Token": tokens.refresh ?? ""
            ]
//<<<<<<< HEAD
            
            // access token 필요 없는 API들 (필요하더라도 interceptor에서)
        case .signup, .login, .kakaoLogin, .appleLogin, .logout, .withdrawal, .checkLoginId, .requestEmailVerification, .verifyEmail:
//=======
//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
            return [
                "Content-Type": "application/json",
            ]
        
        case .agreeTerms(_, let token):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
//<<<<<<< HEAD
            
//=======

        default:
            return [
                "Content-Type": "application/json"
            ]
//>>>>>>> origin/FEAT--계정설정/비밀번호-변경
        }
    }
    
    var validationType: ValidationType {
        .successCodes
    }
}
