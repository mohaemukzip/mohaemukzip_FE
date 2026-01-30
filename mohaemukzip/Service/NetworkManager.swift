//
//  NetworkManager.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/29/26.
//

import Foundation
import Moya

// MARK: - 공용 BaseResposneDTO
struct BaseResponse<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T?
}

// MARK: - 공용 provider 생성기
// 
final class NetworkManager {
    static let shared = NetworkManager()
    init() {}
    
    private let plugins: [PluginType] = [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ]
    
    func makeProvider<T: TargetType>(for target: T.Type) -> MoyaProvider<T> {
        return MoyaProvider<T>(plugins: plugins)
    }
}

// MARK: - BaseResponse에서 result만 뽑아내는 함수
extension Response {
    func mapResult<T: Decodable>(_ type: T.Type) throws -> T {
        let base = try self.map(BaseResponse<T>.self)
        
        guard base.isSuccess, let result = base.result else {
            throw MoyaError.jsonMapping(self)
        }
        
        return result
    }
}
