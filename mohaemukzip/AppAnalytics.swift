//
//  AppAnalytics.swift
//  mohaemukzip
//
//  Created by 이한결 on 11/1/26.
//

import Foundation
import FirebaseAnalytics
import Moya

// Firebase Analytics 집계 함수
enum AppAnalytics {
    static func logButton(
        _ screen: String,
        _ button: String,
        details: [String: Any] = [:]
    ) {
        var parameters = details
        parameters["화면"] = screen
        parameters["버튼"] = button

        Analytics.logEvent("버튼클릭", parameters: parameters)
    }

    static func logSuccess(
        _ screen: String,
        _ action: String,
        details: [String: Any] = [:]
    ) {
        var parameters = details
        parameters["화면"] = screen
        parameters["작업"] = action

        Analytics.logEvent("작업성공", parameters: parameters)
    }

    static func logFailure(
        _ screen: String,
        _ action: String,
        reason: String,
        details: [String: Any] = [:]
    ) {
        var parameters = details
        parameters["화면"] = screen
        parameters["작업"] = action
        parameters["실패_분류"] = reason

        Analytics.logEvent("작업실패", parameters: parameters)
    }

    // 서버 응답과 오류 유형만 분류하고, 응답 원문이나 인증 정보는 Analytics에 보내지 않습니다.
    static func failureReason(for error: Error, response: Response? = nil) -> String {
        if let response {
            struct ResponseStatus: Decodable {
                let isSuccess: Bool
            }

            if let status = try? JSONDecoder().decode(ResponseStatus.self, from: response.data),
               !status.isSuccess {
                return "서버 처리 거절"
            }
        }

        if error is CancellationError {
            return "요청 취소"
        }

        let nsError = error as NSError
        if nsError.domain == "AuthService" {
            return "서버 처리 거절"
        }
        if nsError.domain == "NetworkMap" {
            // isSuccess=false는 위에서 처리했으므로, 성공 응답에 필수 결과가 없는 경우입니다.
            return response == nil ? "서버 응답 오류" : "응답 형식 오류"
        }
        if nsError.domain == NSURLErrorDomain {
            return nsError.code == NSURLErrorCancelled ? "요청 취소" : "네트워크 오류"
        }
        if error is DecodingError {
            return "응답 해석 실패"
        }
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                return response.statusCode >= 500 ? "서버 오류" : "요청 거절"
            case .objectMapping, .jsonMapping, .stringMapping, .imageMapping:
                return "응답 해석 실패"
            case .underlying(let underlyingError, let response):
                if let response, !(200..<300).contains(response.statusCode) {
                    return response.statusCode >= 500 ? "서버 오류" : "요청 거절"
                }
                return failureReason(for: underlyingError, response: response)
            default:
                return "요청 처리 오류"
            }
        }
        return "알 수 없는 오류"
    }

}
