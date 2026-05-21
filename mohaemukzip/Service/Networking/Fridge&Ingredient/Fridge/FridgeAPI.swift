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
            "Content-Type" : "application/json"
        ]
    }
    
    var validationType: ValidationType {
        .successCodes
    }
}
