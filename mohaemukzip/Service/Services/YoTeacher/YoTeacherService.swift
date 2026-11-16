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
                        
                        AppAnalytics.logSuccess("요선생 채팅", "요선생 응답", details: ["추천_영상_수": domainModels?.count ?? 0])
                        continuation.resume(returning: (decoded.title, decoded.message, domainModels) )
                    } catch {
                        AppAnalytics.logFailure("요선생 채팅", "요선생 응답", reason: AppAnalytics.failureReason(for: error, response: response))
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    AppAnalytics.logFailure("요선생 채팅", "요선생 응답", reason: AppAnalytics.failureReason(for: error))
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
