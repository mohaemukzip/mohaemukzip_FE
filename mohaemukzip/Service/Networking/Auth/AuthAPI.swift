
import Foundation
import Moya
import Alamofire

enum AuthAPI {
    case signup(SignUpRequestDTO)
    case login(LoginRequestDTO)
    case checkLoginId(CheckLoginIdRequestDTO)
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
        case .signup:
            return .post
        case .login:
            return .post
        case .checkLoginId:
            return .post
        case .reissue:
            return .post
        case .logout:
            return .post
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
        case .reissue, .logout, .withdrawal:
            return .requestPlain
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
            
            // access token 필요 없는 API들 (필요하더라도 interceptor에서)
        case .signup, .login, .logout, .withdrawal, .checkLoginId:
            return [
                "Content-Type": "application/json",
            ]
            
        }
    }
}
