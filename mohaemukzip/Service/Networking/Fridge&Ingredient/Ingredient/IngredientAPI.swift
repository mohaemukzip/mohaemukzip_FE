//
//  IngredientAPI.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/29/26.
//

import Foundation
import Moya
import Alamofire

enum IngredientAPI {
    case fetchIngredients(Int)
    case getRecent
    case getSaved
    case addSaved(Int)
    case ingredientRequest(String)
    case deleteRecent(String)
    case deleteSaved(Int)
}

extension IngredientAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchIngredients:
            return "/ingredients"
        case .getRecent, .deleteRecent:
            return "/ingredients/recent-searches"
        case .getSaved:
            return "/ingredients/favorites"
        case .addSaved(let id), .deleteSaved(let id):
            return "ingredients/\(id)/favorites"
        case .ingredientRequest:
            return "/ingredients/requests"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchIngredients, .getRecent, .getSaved:
            return .get
        case .addSaved, .ingredientRequest:
            return .post
        case .deleteRecent, .deleteSaved:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .fetchIngredients(let page):
            return .requestParameters(parameters: ["page": page], encoding: URLEncoding.queryString)
        case .deleteRecent(let name):
            return .requestParameters(parameters: ["keyword": name], encoding: URLEncoding.queryString)
        case .getRecent, .getSaved, .addSaved, .deleteSaved:
            return .requestPlain
        case .ingredientRequest(let name):
            return .requestParameters(parameters: ["ingredientName": name], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(Config.accessTK)"
        ]
    }
}
