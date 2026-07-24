import Foundation
import Moya
import Alamofire

extension Notification.Name {
    static let authSessionExpired =
        Notification.Name("authSessionExpired")
}

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

    private let authInterceptor = AuthInterceptor()

    private let plugins: [PluginType] = [
        NetworkDebugPlugin()
    ]

    func makeProvider<T: TargetType>(for target: T.Type) -> MoyaProvider<T> {
        // Alamofire 레벨에서 401을 감지해 토큰 재발급 후 원 요청을 1회 재시도
        let session = Session(interceptor: authInterceptor)
        return MoyaProvider<T>(session: session, plugins: plugins)
    }
}

// MARK: - 401 자동 토큰 재발급 Interceptor

/// 401 응답을 감지하면 /auth/reissue 를 호출해서 토큰을 갱신한 뒤,
/// 실패한 요청을 1회 재시도하는 Alamofire Interceptor 입니다.

private final class AuthInterceptor: RequestInterceptor {

    private let lock = NSLock()
    private var isRefreshing = false
    private var retryCompletions: [(RetryResult) -> Void] = []

    // 재발급 호출은 Interceptor가 붙지 않은 별도 Provider로 수행(무한루프 방지)
    private let refreshProvider: MoyaProvider<AuthAPI> = {
        // 기본 Provider는 별도의 Session을 사용하므로 현재 Interceptor(Session)과 분리됩니다.
        MoyaProvider<AuthAPI>()
    }()

    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        let tokens = TokenStore.loadTokens() // 키체인에서 토큰을 불러옴

        // 이미 Authorization이 있으면 그대로
        if request.value(forHTTPHeaderField: "Authorization") != nil {
            completion(.success(request))
            return
        }

        // accessToken 없으면 건드리지 않음
        guard let accessToken = tokens.access, !accessToken.isEmpty else {
            completion(.success(request))
            return
        }

        // auth 관련 일부 엔드포인트는 Authorization이 불필요할 수 있어 제외
        /*if let urlString = request.url?.absoluteString {
            if urlString.contains("/auth/login") ||
                urlString.contains("/auth/signup") ||
                urlString.contains("/auth/check-loginid") ||
                urlString.contains("/auth/reissue") ||
                urlString.contains("/auth/email/send") ||
                urlString.contains("/auth/email/verify") {
                completion(.success(request))
                return
            }
        }*/
        
        // 토큰 불필요한 api는 인터셉터에서 토큰 주입 제외
        if let path = request.url?.path {
            if path == "/auth/login" ||
                path == "/auth/signup" ||
                path == "/auth/check-loginid" ||
                path == "/auth/reissue" ||
                path == "/auth/email/send" ||
                path == "/auth/email/verify" {
                completion(.success(request))
                return
            }
        }

        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let tokens = TokenStore.loadTokens()
        
        // status code가 없으면 재시도 판단 불가
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetry)
            return
        }

        // 401이 아니면 재시도하지 않음
        guard response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        // 이미 재시도 요청 보냈으면 중복재시도 X
        guard request.retryCount == 0 else {
            completion(.doNotRetry)
            return
        }

        // reissue 요청 자체가 401이면 루프 방지
        /*if let urlString = request.request?.url?.absoluteString,
           urlString.contains("/auth/reissue") ||
            urlString.contains("/auth/email/send") ||
            urlString.contains("/auth/email/verify") {
            // DEBUG LOG REMOVED
            completion(.doNotRetry)
            return
        }*/
        
        if let path = request.request?.url?.path,
           path == "/auth/reissue" ||
           path == "/auth/email/send" ||
           path == "/auth/email/verify" {
            completion(.doNotRetry)
            return
        }

        // refreshToken이 없으면 재발급 불가
        guard let refreshToken = tokens.refresh, !refreshToken.isEmpty else {
            completion(.doNotRetry)
            return
        }

        // 동시 401 단일화: 현재 요청을 대기열에 넣고, 재발급이 진행 중이면 종료
        lock.lock()
        retryCompletions.append(completion)
        let shouldStartRefresh = !isRefreshing
        if shouldStartRefresh { isRefreshing = true }
        lock.unlock()

        if !shouldStartRefresh {
            // DEBUG LOG REMOVED
            return
        }

        // DEBUG LOG REMOVED

        // 실제 재발급 수행
        refreshProvider.request(.reissue) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(ReissueResponseDTO.self)
                    let newAccess = decoded.result.accessToken
                    let newRefresh = decoded.result.refreshToken

                    // 토큰 저장
                    TokenStore.saveTokens(access: newAccess, refresh: newRefresh)

                    // DEBUG LOG REMOVED

                    self.finishRefreshing(with: .retry)

                } catch {
                    // DEBUG LOG REMOVED
                    self.finishRefreshing(with: .doNotRetryWithError(error))
                }

            case .failure(let error):
                // 재발급 실패한 리프레시 토큰이 만료됐다는 뜻 -> expireSession함수 호출 -> 리프레시 토큰 만료 알림을 보내 RootView에서 처리 
                if case let .statusCode(response) = error,
                       response.statusCode == 401 || response.statusCode == 403 {
                        self.expireSession()
                    }
                
                // DEBUG LOG REMOVED
                self.finishRefreshing(with: .doNotRetryWithError(error))
            }
        }
    }

    private func finishRefreshing(with result: RetryResult) {
        lock.lock()
        let completions = retryCompletions
        retryCompletions.removeAll()
        isRefreshing = false
        lock.unlock()

        // DEBUG LOG REMOVED

        completions.forEach { $0(result) }
    }
    
    // 리프레시 토큰 만료 시
    private func expireSession() {
        TokenStore.clear()

        NotificationCenter.default.post(
            name: .authSessionExpired,
            object: nil
        )
    }
}

// MARK: - 디버깅용 네트워크 플러그인


private final class NetworkDebugPlugin: PluginType {

    func willSend(_ request: RequestType, target: TargetType) {
        // DEBUG LOG REMOVED
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        // DEBUG LOG REMOVED
    }
}

// MARK: - BaseResponse에서 result만 뽑아내는 함수
extension Response {
    func mapResult<T: Decodable>(_ type: T.Type) throws -> T {
        do {
            let base = try self.map(BaseResponse<T>.self)

            // 서버에서 isSuccess=false 이면 여기서 잡아서 원문을 찍어줍니다.
            guard base.isSuccess else {
                // DEBUG LOG REMOVED


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

            // DEBUG LOG REMOVED

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
            // DEBUG LOG REMOVED
            throw error
        }
    }
}
