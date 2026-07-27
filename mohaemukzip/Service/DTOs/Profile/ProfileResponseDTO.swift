
import Foundation

enum ProfileResponseDTO {

    /// 마이페이지 / 최근 본 레시피 / 저장된 레시피 목록에서 공통으로 사용
    struct RecipeCard: Decodable {
        let id: Int

        // 마이페이지 프리뷰에서는 누락될 수 있음 → Optional
        let title: String?
        let channelName: String?
        let viewCount: Int?

        let videoId: String
        let channelId: String?
        let videoDuration: String

        let cookingTimeMinutes: Int?
        let difficulty: Double?

        let isBookmarked: Bool
    }

    // MARK: - 마이페이지 조회
    /// GET /members/me/mypage
    struct MyPage: Decodable {
        let profileImageUrl: String?
        let nickname: String
        let level: Int
        let remainingScore: Int
        let recentlyViewedRecipes: [RecipeCard]
        let bookmarkedRecipes: [RecipeCard]
    }

    // MARK: - 최근 본 레시피 목록 조회
    /// GET /members/me/recently-viewed
    /// - result: [RecipeCard]

    // MARK: - 저장된(북마크) 레시피 목록 조회
    /// GET /members/me/bookmarked?page=
    struct BookmarkedRecipePage: Decodable {
        let recipeList: [RecipeCard]
        let listSize: Int
        let totalPage: Int
        let totalElements: Int
        let isFirst: Bool
        let isLast: Bool
    }

    // MARK: - 프로필 이미지 업로드 URL 발급
    /// POST /s3/profile/upload-url
    struct PresignedUpload: Decodable {
        let key: String
        let presignedUrl: String
    }
    
    // MARK: - 계정 설정 조회
    /// GET /members/me/account-setting
    struct AccountSetting: Decodable {
        let email: String
        let loginType: String
    }

    // MARK: - 빈 응답 처리용
    /// PATCH /members/me/profile
    /// result: {}
    struct EmptyResult: Decodable { }
}
