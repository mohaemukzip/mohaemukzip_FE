//
//  YoTeacherService.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/31/26.
//

import Foundation
import Moya

class YoTeacherService {
    private var provider = NetworkManager.shared.makeProvider(for: YoTeacherAPI.self)
    
    func getResponse(message: String) async throws -> (String, String, [YoTeacherMessage]) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getResponse(message)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(YoTeacherResponseDTO.self, from: response.data)
                        
                        let title = decoded.title
                        let message = decoded.message
                        let domainModels = decoded.recommendRecipes.map { $0.toDomain() }
                        continuation.resume(returning: (title, message, domainModels) )
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
