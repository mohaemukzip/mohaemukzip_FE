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
    
    static var accessTK: String {
        get {
            UserDefaults.standard.string(forKey: "ACCESS_TOKEN") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ACCESS_TOKEN")
        }
    }

    static var refreshTK: String {
        get {
            UserDefaults.standard.string(forKey: "REFRESH_TOKEN") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "REFRESH_TOKEN")
        }
    }
}
