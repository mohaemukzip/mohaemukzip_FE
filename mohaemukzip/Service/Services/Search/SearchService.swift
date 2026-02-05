//
//  SearchService.swift
//  mohaemukzip
//
//  Created by 이한결 on 2/4/26.
//

import Foundation
import Moya

class SearchService {
    private var provider = NetworkManager.shared.makeProvider(for: SearchAPI.self)
    
    // MARK: SearchKeyword 배열, isLast 튜플 형식으로 반환
    func getSearchText(keyword: String, page: Int) async throws -> ([SearchKeyword], Bool) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getSearchText(keyword, page)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.mapResult(RecipeSearchResultDTO.self)
                        
                        let domainModels = decoded.results.map { $0.toDomain() }
                        
                        let isLast = decoded.isLast
                        continuation.resume(returning: (domainModels, isLast))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: RecipeVideo 배열, isLast 튜플 형식으로 반환
    func getResultForKeyword(dishId: Int, page: Int) async throws -> ([RecipeVideo], Bool) {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getResultForKeyword(dishId, page)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.mapResult(SearchResultDTO.self)
                        
                        let domainModels = decoded.recipeList.map { $0.toDomain() }
                        
                        let isLast = decoded.isLast
                        continuation.resume(returning: (domainModels, isLast))
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
