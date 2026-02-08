import Foundation
import Moya
import Alamofire

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
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
        NetworkDebugPlugin()
    ]

    func makeProvider<T: TargetType>(for target: T.Type) -> MoyaProvider<T> {
        // Alamofire 레벨에서 401을 감지해 토큰 재발급 후 원 요청을 1회 재시도합니다.
        let session = Session(interceptor: authInterceptor)
        return MoyaProvider<T>(session: session, plugins: plugins)
    }
}

// MARK: - 401 자동 토큰 재발급 Interceptor

/// 401 응답을 감지하면 /auth/reissue 를 호출해서 토큰을 갱신한 뒤,
/// 실패한 요청을 1회 재시도하는 Alamofire Interceptor 입니다.
///
/// ⚠️ 주의
/// - 동시에 여러 요청이 401을 맞는 경우, 재발급은 1번만 수행하고 나머지 요청은 대기 후 함께 재시도합니다.
/// - /auth/reissue 자체가 401을 맞을 때는 재시도 루프를 방지하기 위해 재발급을 시도하지 않습니다.
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

        // 이미 Authorization이 있으면 그대로
        if request.value(forHTTPHeaderField: "Authorization") != nil {
            completion(.success(request))
            return
        }

        // accessToken 없으면 건드리지 않음
        guard !Config.accessTK.isEmpty else {
            completion(.success(request))
            return
        }

        // auth 관련 일부 엔드포인트는 Authorization이 불필요할 수 있어 제외
        if let urlString = request.url?.absoluteString {
            if urlString.contains("/auth/login") ||
                urlString.contains("/auth/signup") ||
                urlString.contains("/auth/check-loginid") ||
                urlString.contains("/auth/reissue") {
                completion(.success(request))
                return
            }
        }

        request.setValue("Bearer \(Config.accessTK)", forHTTPHeaderField: "Authorization")

        #if DEBUG
        if let urlString = request.url?.absoluteString {
            let prefix = String(Config.accessTK.prefix(16))
            print("[AuthInterceptor] adapt Authorization added | tokenPrefix=\(prefix)... url=\(urlString)")
        }
        #endif

        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
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

        // reissue 요청 자체가 401이면 루프 방지
        if let urlString = request.request?.url?.absoluteString,
           urlString.contains("/auth/reissue") {
            #if DEBUG
            print("[AuthInterceptor] 401 on /auth/reissue -> doNotRetry")
            #endif
            completion(.doNotRetry)
            return
        }

        // refreshToken이 없으면 재발급 불가
        guard !Config.refreshTK.isEmpty else {
            #if DEBUG
            print("[AuthInterceptor] 401 but refresh token is empty -> doNotRetry")
            #endif
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
            #if DEBUG
            if let urlString = request.request?.url?.absoluteString {
                print("[AuthInterceptor] 401 queued (refresh in progress) | url=\(urlString)")
            }
            #endif
            return
        }

        #if DEBUG
        let accessPrefix = String(Config.accessTK.prefix(16))
        let refreshPrefix = String(Config.refreshTK.prefix(16))
        print("[AuthInterceptor] 401 detected -> start reissue | access=\(accessPrefix)... refresh=\(refreshPrefix)...")
        #endif

        // 실제 재발급 수행
        refreshProvider.request(.reissue) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(ReissueResponseDTO.self)
                    let newAccess = decoded.result.accessToken
                    let newRefresh = decoded.result.refreshToken

                    // 토큰 저장(앱 재시작 대비) + Config 동기화
                    TokenStore.saveTokens(access: newAccess, refresh: newRefresh)
                    Config.accessTK = newAccess
                    Config.refreshTK = newRefresh

                    #if DEBUG
                    let newAccessPrefix = String(newAccess.prefix(16))
                    let newRefreshPrefix = String(newRefresh.prefix(16))
                    print("[AuthInterceptor] reissue success | newAccess=\(newAccessPrefix)... newRefresh=\(newRefreshPrefix)...")
                    #endif

                    self.finishRefreshing(with: .retry)

                } catch {
                    #if DEBUG
                    let raw = String(data: response.data, encoding: .utf8) ?? "(binary/empty)"
                    print("[AuthInterceptor] reissue decode fail | status=\(response.statusCode)")
                    print("[AuthInterceptor] rawBody: \(raw)")
                    print("[AuthInterceptor] error: \(error)")
                    #endif
                    self.finishRefreshing(with: .doNotRetryWithError(error))
                }

            case .failure(let error):
                #if DEBUG
                print("[AuthInterceptor] reissue request fail | error=\(error)")
                if let response = error.response {
                    let raw = String(data: response.data, encoding: .utf8) ?? "(binary/empty)"
                    print("[AuthInterceptor] errorBody: \(raw)")
                }
                #endif
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

        #if DEBUG
        print("[AuthInterceptor] finishRefreshing -> callbacks=\(completions.count) result=\(result)")
        #endif

        completions.forEach { $0(result) }
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
