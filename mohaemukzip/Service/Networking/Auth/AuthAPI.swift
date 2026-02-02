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
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
