//
//  AuthAPI.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//

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
        switch self {
        case .reissue:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(Config.accessTK)",
                "X-Refresh-Token": "\(Config.refreshTK)"
            ]

        case .logout, .withdrawal, .checkLoginId:
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
