import Foundation
import Moya
import Alamofire

enum AuthAPI {
    case signup(SignUpRequestDTO)
    case login(LoginRequestDTO)
    case kakaoLogin(KakaoLoginRequestDTO)
    case appleLogin(AppleLoginRequestDTO)
    case agreeTerms([SignUpTermDTO], String) // terms + bearer token
    case checkLoginId(CheckLoginIdRequestDTO)

    // MARK: - Email
    case sendResetPasswordEmail(AuthRequestDTO.SendEmailVerificationRequest)
    case resetPassword(AuthRequestDTO.ResetPasswordRequest)

    // Use a single verifyEmail case to avoid redeclaration. Prefer the newer DTO name if applicable.
    case requestEmailVerification(SendEmailVerificationRequestDTO)
    case verifyEmail(VerifyEmailRequestDTO)

    case reissue
    case logout
    case withdrawal
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
        case .kakaoLogin:
            return "/auth/login/kakao"
        case .appleLogin:
            return "/auth/login/apple"
        case .agreeTerms:
            return "/auth/terms/agree"
        case .checkLoginId:
            return "/auth/check-loginid"
        case .sendResetPasswordEmail:
            return "/auth/email/send/reset-password"
        case .resetPassword:
            return "/auth/reset-password"
        case .requestEmailVerification:
            return "/auth/email/send"
        case .verifyEmail:
            return "/auth/email/verify"
        case .reissue:
            return "/auth/reissue"
        case .logout:
            return "/auth/logout"
        case .withdrawal:
            return "/auth/withdrawal"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signup,
             .login,
             .kakaoLogin,
             .appleLogin,
             .agreeTerms,
             .checkLoginId,
             .sendResetPasswordEmail,
             .requestEmailVerification,
             .verifyEmail,
             .reissue,
             .logout:
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
        case .kakaoLogin(let request):
            return .requestJSONEncodable(request)
        case .appleLogin(let request):
            return .requestJSONEncodable(request)
        case .agreeTerms(let request, _):
            return .requestJSONEncodable(request)
        case .checkLoginId(let request):
            return .requestJSONEncodable(request)
        case .sendResetPasswordEmail(let request):
            return .requestJSONEncodable(request)
        case .requestEmailVerification(let request):
            return .requestJSONEncodable(request)
        case .verifyEmail(let request):
            return .requestJSONEncodable(request)
        case .resetPassword(let request):
            return .requestJSONEncodable(request)
        case .reissue, .logout, .withdrawal:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        // If your project uses TokenStore, you can re-enable it here. For now, align with Config as used elsewhere.
        switch self {
        case .reissue:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(Config.accessTK)",
                "X-Refresh-Token": "\(Config.refreshTK)"
            ]
        case .agreeTerms(_, let token):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        case .logout, .withdrawal, .checkLoginId:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(Config.accessTK)"
            ]
        case .sendResetPasswordEmail:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(Config.accessTK)"
            ]
        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }

    var validationType: ValidationType {
        .successCodes
    }
}
