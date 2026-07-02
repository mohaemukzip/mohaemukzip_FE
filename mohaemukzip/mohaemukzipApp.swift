import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct mohaemukzipApp: App {
    
    init() {
        guard let appKey = Bundle.main.object(
            forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY"
        ) as? String,
        !appKey.isEmpty else {
            assertionFailure("KAKAO_NATIVE_APP_KEY가 설정되지 않았습니다.")
            return
        }

        KakaoSDK.initSDK(appKey: appKey)
    }
    
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
