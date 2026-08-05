import Foundation
import Moya

class YoTeacherService {
    private var provider = NetworkManager.shared.makeProvider(for: YoTeacherAPI.self)
    
    func getResponse(message: String) async throws -> (String, String, [YoTeacherMessage]?) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getResponse(message)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.mapResult(YoTeacherResponseDTO.self)
                        
                        let domainModels = decoded.recipeCards?.compactMap { $0.toDomain() } ?? nil
                        
                        continuation.resume(returning: (decoded.title, decoded.message, domainModels) )
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
