import Foundation
import Moya

class FridgeService {
    private let provider = NetworkManager.shared.makeProvider(for: FridgeAPI.self)
    
    func getIngredients() async throws -> [FridgeIngredient] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchIngredients) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.mapResult(FridgeListDTO.self)
                        let domainModels = decoded.fridgeList.map { $0.toDomain() }
                        continuation.resume(returning: domainModels)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func addIngredient(id: Int, ty: String, date: String, amount: Double) async throws {
        let requestDTO = AddIngredientRequestDTO(ingredientId: id,
                                                 storageType: ty,
                                                 expireDate: date,
                                                 weight: amount)
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.addIngredients(requestDTO)) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func deleteIngredient(id: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.deleteIngredient(id)) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
