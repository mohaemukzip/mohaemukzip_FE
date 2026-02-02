//
//  YoTeacherAPI.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/31/26.
//

import Foundation
import Moya
import Alamofire

enum YoTeacherAPI {
    case getResponse(String)
}

extension YoTeacherAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }
    
    var path: String {
        return "/chats"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .getResponse(let text):
            return .requestParameters(parameters: ["message": text], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(Config.accessTK)"
        ]
    }
}
