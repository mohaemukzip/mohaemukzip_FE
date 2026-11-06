import Foundation
import Moya

class FridgeService {
    private struct RegistrationResponse: Decodable {
        let isSuccess: Bool
    }

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
        
        let details: [String: Any] = [
            "재료_번호": id,
            "보관장소": StorageType(rawValue: ty)?.displayName ?? "알 수 없음"
        ]

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.addIngredients(requestDTO)) { result in
                switch result {
                case .success(let response):
                    do {
                        // 본문이 없는 성공 응답도 허용하며, 본문이 있으면 서버의 성공 여부를 확인합니다.
                        if !response.data.isEmpty {
                            let decoded = try response.map(RegistrationResponse.self)
                            guard decoded.isSuccess else {
                                throw NSError(
                                    domain: "FridgeService",
                                    code: response.statusCode,
                                    userInfo: nil
                                )
                            }
                        }
                        AppAnalytics.logSuccess("재료 입력", "재료 등록", details: details)
                        continuation.resume()
                    } catch {
                        AppAnalytics.logFailure("재료 입력", "재료 등록", reason: AppAnalytics.failureReason(for: error, response: response), details: details)
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    AppAnalytics.logFailure("재료 입력", "재료 등록", reason: AppAnalytics.failureReason(for: error), details: details)
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
    
    func updateIngredient(id: Int, ty: String, date: String, amount: Double) async throws {
        let requestDTO = UpdateIngredientRequestDTO(storageType: ty,
                                                    expireDate: date,
                                                    weight: amount)
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.updateIngredient(id, requestDTO)) { result in
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
