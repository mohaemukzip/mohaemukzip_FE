import Foundation
import Moya
import Alamofire

enum AuthAPI {
    case signup(SignUpRequestDTO)
    case login(LoginRequestDTO)
    case checkLoginId(CheckLoginIdRequestDTO)

    // MARK: - Email
    case sendEmailVerification(AuthRequestDTO.SendEmailVerificationRequest)
    case verifyEmail(AuthRequestDTO.VerifyEmailRequest)
    case resetPassword(AuthRequestDTO.ResetPasswordRequest)

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

        case .checkLoginId:
            return "/auth/check-loginid"

        case .sendEmailVerification:
            return "/auth/email/send"

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
        }
    }

    var method: Moya.Method {
        switch self {
        case .signup,
             .login,
             .checkLoginId,
             .sendEmailVerification,
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

        case .checkLoginId(let request):
            return .requestJSONEncodable(request)

        case .sendEmailVerification(let request):
            return .requestJSONEncodable(request)

        case .verifyEmail(let request):
            return .requestJSONEncodable(request)

        case .resetPassword(let request):
            return .requestJSONEncodable(request)

        case .reissue,
             .logout,
             .withdrawal:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .reissue:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(Config.accessTK)",
                "X-Refresh-Token": "\(Config.refreshTK)"
            ]

        case .logout,
             .withdrawal,
             .checkLoginId,
             .resetPassword:
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
}
