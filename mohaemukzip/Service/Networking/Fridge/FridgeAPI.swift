//
//  FridgeAPI.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/28/26.
//

import SwiftUI
import Moya
import Alamofire

enum FridgeAPI {
    case fetchIngredients
    case addIngredients(AddIngredientRequestDTO)
    case deleteIngredient(Int)
}

extension FridgeAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchIngredients, .addIngredients, .deleteIngredient:
            return "/me/ingredients"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchIngredients:
            return .get
        case .addIngredients:
            return .post
        case .deleteIngredient:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .fetchIngredients, .deleteIngredient:
            return .requestPlain
        case .addIngredients(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer YOUR_TOKEN"
        ]
    }
}
