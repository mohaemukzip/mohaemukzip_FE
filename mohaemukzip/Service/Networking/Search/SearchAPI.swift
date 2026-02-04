//
//  SearchAPI.swift
//  mohaemukzip
//
//  Created by 이한결 on 2/4/26.
//

import Foundation
import Moya
import Alamofire

enum SearchAPI {
    case getSearchText(String, Int)
}

extension SearchAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }
    
    var path: String {
        return "/search"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getSearchText(let keyword, let page):
            return .requestParameters(parameters: ["keyword": keyword, "page": page], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(Config.accessTK)"
        ]
    }
}
