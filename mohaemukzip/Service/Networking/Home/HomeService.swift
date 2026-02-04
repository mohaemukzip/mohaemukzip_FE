//
//  HomeService.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//

import Foundation
import Moya

final class HomeService {
    
    private let provider = NetworkManager.shared.makeProvider(for: HomeAPI.self)
    
    func fetchHomeDashboard() async throws -> HomeResultDTO {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchHomeDashboard) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(HomeResponseDTO.self)
                        continuation.resume(returning: decoded.result)
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

extension HomeService {
    
    func fetchHomeStats() async throws -> HomeStatsResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchHomeStats) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(HomeStatsRootDTO.self)
                        continuation.resume(returning: decoded.result)
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

extension HomeService {
    func fetchHomeStatsCalendar(year: Int, month: Int) async throws -> HomeStatsCalendarModel {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.fetchHomeStatsCalendar(year: year, month: month)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(HomeStatsCalendarRootDTO.self)
                        continuation.resume(returning: decoded.result.toModel())
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

private struct HomeStatsRootDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: HomeStatsResponseDTO
}

private struct HomeStatsCalendarRootDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: HomeStatsCalendarResponseDTO
}
