
//
//  ProfileViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import Foundation
import Combine

// MARK: - ProfileViewModel

/// 마이페이지(프로필) 화면용 ViewModel
/// - NOTE: Service(API) 결과(DTO)를 ProfileModel(Domain Model)로 변환해서 View에 제공합니다.
/// - IMPORTANT: 네트워크 콜백 스레드는 보장되지 않으므로, UI 상태 변경은 main thread에서 처리합니다.

final class ProfileViewModel: ObservableObject {

    // MARK: - Published (View State)

    /// 마이페이지 화면 데이터
    @Published private(set) var myPage: ProfileMyPageModel = .empty

    /// 로딩 상태
    @Published private(set) var isLoading: Bool = false

    /// 에러 메시지(간단 표시용)
    @Published var errorMessage: String? = nil

    // MARK: - Dependencies

    private let profileService: ProfileService

    // MARK: - Init

    init(profileService: ProfileService = .shared) {
        self.profileService = profileService
    }

    // MARK: - Computed (Preview)

    /// 최근 조회 레시피 미리보기(최대 3개)
    var recentlyViewedPreview: [ProfileRecipeCard] {
        Array(myPage.activity.recentlyViewed.prefix(3))
    }

    /// 저장한 레시피 미리보기(최대 3개)
    var bookmarkedPreview: [ProfileRecipeCard] {
        Array(myPage.activity.bookmarked.prefix(3))
    }

    // MARK: - Functions

    /// 마이페이지 최초 진입/리프레시 시 호출
    func fetchMyPage() {
        // 중복 호출 방지(원하면 제거 가능)
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[ProfileViewModel] ✅ fetchMyPage START")

        profileService.getMyPage { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(dto):
                let model = ProfileMyPageModel.from(dto: dto)

                DispatchQueue.main.async {
                    self.myPage = model
                    self.isLoading = false
                }

                print("[ProfileViewModel] ✅ fetchMyPage SUCCESS | nickname=\(model.profile.nickname), level=\(model.profile.level), remainingScore=\(model.pointInfo.remainingScore)")
                print("[ProfileViewModel] ✅ recentlyViewed=\(model.activity.recentlyViewed.count), bookmarked=\(model.activity.bookmarked.count)")

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[ProfileViewModel] ❌ fetchMyPage FAIL | error=\(error)")
            }
        }
    }

    /// 뷰에서 pull-to-refresh 같은 갱신 동작이 필요할 때 사용
    func refresh() {
        print("[ProfileViewModel] 🔄 refresh")
        fetchMyPage()
    }

    /// 프로필 이미지 변경 (발급 → PUT → PATCH) 플로우 실행
    /// - Parameters:
    ///   - imageData: 선택한 이미지 데이터(png 권장)
    ///   - nickname: 현재/변경 닉네임
    func changeProfileImage(imageData: Data, nickname: String) {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        print("[ProfileViewModel] ✅ changeProfileImage START")

        profileService.changeProfileImage(imageData: imageData, nickname: nickname) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.isLoading = false
                }

                print("[ProfileViewModel] ✅ changeProfileImage SUCCESS")

                // 변경 성공 후 최신 정보 재조회
                self.fetchMyPage()

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

                print("[ProfileViewModel] ❌ changeProfileImage FAIL | error=\(error)")
            }
        }
    }
}
