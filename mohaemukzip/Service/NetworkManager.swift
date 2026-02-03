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

/// result가 없는 성공 응답(예: PATCH)용 공용 빈 결과 타입
struct EmptyResult: Decodable {
    init() {}
}

// MARK: - 공용 provider 생성기
//
final class NetworkManager {
    static let shared = NetworkManager()
    init() {}

    private let plugins: [PluginType] = [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
        NetworkDebugPlugin()
    ]

    func makeProvider<T: TargetType>(for target: T.Type) -> MoyaProvider<T> {
        return MoyaProvider<T>(plugins: plugins)
    }
}

// MARK: - 디버깅용 네트워크 플러그인

/// NetworkLoggerPlugin이 환경/설정에 따라 출력이 약할 때를 대비해서,
/// 요청/응답의 핵심 정보를 무조건 콘솔에 찍어주는 보조 플러그인입니다.
private final class NetworkDebugPlugin: PluginType {

    func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        guard let urlRequest = request.request else {
            print("[NetworkDebug] ➡️ willSend | (no URLRequest)")
            return
        }

        let method = urlRequest.httpMethod ?? "(nil)"
        let url = urlRequest.url?.absoluteString ?? "(nil)"
        print("[NetworkDebug] ➡️ \(method) \(url)")

        if let headers = urlRequest.allHTTPHeaderFields, !headers.isEmpty {
            // Authorization은 길어서 일부만 표시
            var safeHeaders = headers
            if let auth = safeHeaders["Authorization"], auth.count > 24 {
                safeHeaders["Authorization"] = String(auth.prefix(24)) + "..."
            }
            print("[NetworkDebug] headers: \(safeHeaders)")
        }

        if let body = urlRequest.httpBody,
           let bodyString = String(data: body, encoding: .utf8),
           !bodyString.isEmpty {
            print("[NetworkDebug] body: \(bodyString)")
        }
        #endif
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case let .success(response):
            let url = response.request?.url?.absoluteString ?? "(nil)"
            print("[NetworkDebug] ⬅️ status=\(response.statusCode) url=\(url)")

            let raw = String(data: response.data, encoding: .utf8) ?? "(binary/empty)"
            let preview = raw.count > 2000 ? String(raw.prefix(2000)) + "..." : raw
            print("[NetworkDebug] responseBody: \(preview)")

        case let .failure(error):
            let url = error.response?.request?.url?.absoluteString ?? "(nil)"
            print("[NetworkDebug] ⬅️ FAIL url=\(url) error=\(error)")

            if let response = error.response {
                let raw = String(data: response.data, encoding: .utf8) ?? "(binary/empty)"
                let preview = raw.count > 2000 ? String(raw.prefix(2000)) + "..." : raw
                print("[NetworkDebug] errorBody: \(preview)")
            }
        }
        #endif
    }
}

// MARK: - BaseResponse에서 result만 뽑아내는 함수
extension Response {
    func mapResult<T: Decodable>(_ type: T.Type) throws -> T {
        do {
            let base = try self.map(BaseResponse<T>.self)

            // 서버에서 isSuccess=false 이면 여기서 잡아서 원문을 찍어줍니다.
            guard base.isSuccess else {
                #if DEBUG
                let url = request?.url?.absoluteString ?? "(nil)"
                let raw = String(data: data, encoding: .utf8) ?? "(binary/empty)"
                print("[NetworkMap] ❌ mapResult fail | status=\(statusCode) url=\(url)")
                print("[NetworkMap] isSuccess=\(base.isSuccess) code=\(base.code) message=\(base.message)")
                print("[NetworkMap] rawBody: \(raw)")
                #endif

                throw NSError(
                    domain: "NetworkMap",
                    code: statusCode,
                    userInfo: [NSLocalizedDescriptionKey: base.message]
                )
            }

            // 정상 케이스: result가 있을 때
            if let result = base.result {
                return result
            }

            // 성공인데 result가 없는 케이스(예: PATCH /members/me/profile)
            if T.self == EmptyResult.self {
                return EmptyResult() as! T
            }

            // 프로젝트에서 특정 도메인 EmptyResult를 쓰는 경우도 지원
            if T.self == ProfileResponseDTO.EmptyResult.self {
                return ProfileResponseDTO.EmptyResult() as! T
            }

            #if DEBUG
            let url = request?.url?.absoluteString ?? "(nil)"
            let raw = String(data: data, encoding: .utf8) ?? "(binary/empty)"
            print("[NetworkMap] ❌ mapResult empty result | status=\(statusCode) url=\(url)")
            print("[NetworkMap] isSuccess=\(base.isSuccess) code=\(base.code) message=\(base.message)")
            print("[NetworkMap] rawBody: \(raw)")
            #endif

            // 성공인데 result가 없고, 호출한 타입이 빈 결과 타입도 아니면 구조 불일치로 에러 처리
            throw NSError(
                domain: "NetworkMap",
                code: statusCode,
                userInfo: [NSLocalizedDescriptionKey: base.message]
            )
        } catch {
            if let nsError = error as NSError?, nsError.domain == "NetworkMap" {
                throw error
            }
            // BaseResponse<T> 자체 디코딩이 실패한 경우(JSON 구조가 다르거나 HTML/텍스트일 가능성)
            #if DEBUG
            let url = request?.url?.absoluteString ?? "(nil)"
            let raw = String(data: data, encoding: .utf8) ?? "(binary/empty)"
            print("[NetworkMap] ❌ JSON decode fail | status=\(statusCode) url=\(url)")
            print("[NetworkMap] rawBody: \(raw)")
            print("[NetworkMap] error: \(error)")
            #endif
            throw error
        }
    }
}
