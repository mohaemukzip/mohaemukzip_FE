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
        //MARK: - 수정했어 한결아 계속 nil 값 강제 언래핑되서
        // NOTE: URL(string:) can return nil if the string is empty or missing a scheme (e.g., "https://").
        // Force-unwrapping here causes: "Fatal error: Unexpectedly found nil while unwrapping an Optional value"
        guard let url = URL(string: Config.baseURL), !Config.baseURL.isEmpty else {
            fatalError("[FridgeAPI] Invalid Config.baseURL: \"\(Config.baseURL)\". Make sure it is a non-empty absolute URL including scheme (e.g., https://example.com).")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .fetchIngredients, .addIngredients:
            return "/me/ingredients"
        case .deleteIngredient(let id):
            return "/me/ingredients/\(id)"
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
            "Authorization" : "Bearer \(Config.accessTK)"
        ]
    }
}
