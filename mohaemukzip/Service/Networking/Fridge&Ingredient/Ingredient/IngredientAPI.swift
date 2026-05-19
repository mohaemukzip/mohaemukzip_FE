import Foundation
import Moya
import Alamofire

enum IngredientAPI {
    case fetchIngredients(String, String, Int)
    case getRecent
    case getSaved
    case addSaved(Int)
    case ingredientRequest(String)
    case deleteRecent(String)
    case deleteSaved(Int)
    case getRecommendedDate(Int)
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
        case .getRecommendedDate(let id):
            return "/ingredients/\(id)/recommended-expiration"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchIngredients, .getRecent, .getSaved, .getRecommendedDate:
            return .get
        case .addSaved, .ingredientRequest:
            return .post
        case .deleteRecent, .deleteSaved:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .fetchIngredients(let query, let category, let page):
            return .requestParameters(parameters: ["query": query,
                                                   "category": category,
                                                   "page": page], encoding: URLEncoding.queryString)
        case .deleteRecent(let name):
            return .requestParameters(parameters: ["keyword": name], encoding: URLEncoding.queryString)
        case .getRecent, .getSaved, .addSaved, .deleteSaved, .getRecommendedDate:
            return .requestPlain
        case .ingredientRequest(let name):
            return .requestParameters(parameters: ["ingredientName": name], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type" : "application/json"
        ]
    }
}
