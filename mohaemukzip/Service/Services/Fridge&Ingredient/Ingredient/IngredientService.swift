//
//  IngredientService.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/29/26.
//

import Foundation
import Moya

class IngredientService {
    private let provider = NetworkManager.shared.makeProvider(for: IngredientAPI.self)
    
    func getIngredients(query: String, category: String, page: Int) async throws -> ([IngredientForAddition], Int, Bool) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchIngredients(query, category, page)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.mapResult(IngredientSearchListDTO.self)
                        let pageNum = decoded.page
                        let isLast = decoded.last
                        let domainModels = decoded.content.map { $0.toDomain() }
                        continuation.resume(returning: (domainModels, pageNum, isLast))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getRecent() async throws -> [RecentSearchIngredient] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getRecent) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.mapResult([String].self)
                        let domainModels = decoded.enumerated().map { (index, keyword) in
                            RecentSearchIngredient(id: index, keyword: keyword) }
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
    
    func getSaved() async throws -> [IngredientForAddition] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getSaved) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.mapResult([IngredientForAdditionDTO].self)
                        let domainModels = decoded.map { $0.toDomain() }
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
    
    func addSaved(id: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.addSaved(id)) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func ingredientRequest(name: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.ingredientRequest(name)) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func deleteRecent(name: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.deleteRecent(name)) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func deleteSaved(id: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.deleteSaved(id)) { result in
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
