//
//  HomeAPI.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//

import Foundation
import Moya
import Alamofire

enum HomeAPI {
    case fetchHomeDashboard
    case fetchHomeStats
    case fetchHomeStatsCalendar(year: Int, month: Int)
}

extension HomeAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchHomeDashboard:
            return "/home"
        case .fetchHomeStats:
            return "/home/stats"
        case .fetchHomeStatsCalendar:
            return "/home/stats/calendar"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchHomeDashboard:
            return .get
        case .fetchHomeStats:
            return .get
        case .fetchHomeStatsCalendar:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchHomeDashboard:
            return .requestPlain
        case .fetchHomeStats:
            return .requestPlain
        case let .fetchHomeStatsCalendar(year, month):
            return .requestParameters(parameters: ["year": year, "month": month], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Config.accessTK)"
        ]
    }
}
