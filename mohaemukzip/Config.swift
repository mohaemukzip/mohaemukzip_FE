import Foundation

enum Config {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist 없음")
        }
        return dict
    }()
    
    static let baseURL: String = {
        guard let baseURL = Config.infoDictionary["BASE_URL"] as? String else {
            fatalError()
        }
        return baseURL
    }()

    // TODO: Config에서 관리하던 AccessTK, RefreshTK는 삭제
    // 필요시 git history에서 복구

    // 로그인 ID도 저장. 마이페이지에서 조회. 비밀번호 변경시 이메일 인증시도 사용
    static var loginId: String {
        get {
            UserDefaults.standard.string(forKey: "LOGIN_ID") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LOGIN_ID")
        }
    }
}
