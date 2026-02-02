
//
//  ProfileModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import Foundation

// MARK: - 마이페이지 화면 모델 (Domain Model)

/// 마이페이지 화면에서 사용하는 최상위 모델
/// - NOTE: ResponseDTO(서버 응답)와 View에서 쓰는 값을 분리하기 위해 Domain Model을 둡니다.
struct ProfileMyPageModel: Equatable {
    let profile: ProfileUserProfile
    let pointInfo: ProfilePointInfo
    let activity: ProfileActivityPreview

    static let empty: ProfileMyPageModel = .init(
        profile: .empty,
        pointInfo: .empty,
        activity: .empty
    )
}

// MARK: - 1) 사용자 프로필 정보 영역

/// 사용자 프로필 정보(이미지/닉네임/레벨)
struct ProfileUserProfile: Equatable {
    let profileImageUrl: String
    let nickname: String
    let level: Int

    /// UI에서 표시하는 형태: "Lv.N"
    var levelText: String {
        "Lv.\(level)"
    }

    static let empty: ProfileUserProfile = .init(
        profileImageUrl: "",
        nickname: "",
        level: 0
    )
}

// MARK: - 2) 사용자 레벨 및 집밥 포인트 영역

/// 다음 레벨까지 남은 포인트 정보
struct ProfilePointInfo: Equatable {
    /// 서버 명세: remainingScore
    let remainingScore: Int

    /// UI 문구 예시: "다음 레벨까지 17 집밥 포인트가 남았어요!"
    var remainingScoreText: String {
        "다음 레벨까지 \(remainingScore) 집밥 포인트가 남았어요!"
    }

    static let empty: ProfilePointInfo = .init(remainingScore: 0)
}

// MARK: - 3) 나의 활동 요약 영역

/// 최근 본 레시피 / 저장한 레시피 미리보기
struct ProfileActivityPreview: Equatable {
    let recentlyViewed: [ProfileRecipeCard]
    let bookmarked: [ProfileRecipeCard]

    static let empty: ProfileActivityPreview = .init(recentlyViewed: [], bookmarked: [])

    var isRecentlyViewedEmpty: Bool { recentlyViewed.isEmpty }
    var isBookmarkedEmpty: Bool { bookmarked.isEmpty }
}

// MARK: - 공통: 레시피 카드(썸네일 프리뷰에 사용)

/// 마이페이지에서 쓰는 레시피 카드 모델
/// - NOTE: 나중에 상세 화면/리스트 화면에서 공용 모델이 따로 있으면 그걸로 통합해도 됩니다.
struct ProfileRecipeCard: Identifiable, Equatable {
    let id: Int
    let title: String
    let channelName: String
    let viewCount: Int
    let videoId: String
    let channelId: String
    let videoDuration: String
    let cookingTimeMinutes: Int
    let difficulty: Int
    let isBookmarked: Bool

    /// "10:23" 같은 재생 시간 표시
    var videoDurationText: String { videoDuration }

    /// 조회수 표시용(간단 버전)
    /// - NOTE: 프로젝트에 이미 포맷터가 있으면 그걸로 교체하세요.
    var viewCountText: String {
        if viewCount < 10_000 {
            return "\(viewCount)회"
        }

        // 10,000 이상이면 1.2만 같은 형태
        let tenThousandUnit = Double(viewCount) / 10_000.0
        let formatted = String(format: "%.1f", tenThousandUnit)
        return "\(formatted)만회"
    }
}

// MARK: - DTO → Model 매핑

extension ProfileMyPageModel {
    /// 서버 응답 DTO(MyPage) → 마이페이지 화면 모델 변환
    static func from(dto: ProfileResponseDTO.MyPage) -> ProfileMyPageModel {
        let profile = ProfileUserProfile(
            profileImageUrl: dto.profileImageUrl,
            nickname: dto.nickname,
            level: dto.level
        )

        let pointInfo = ProfilePointInfo(remainingScore: dto.remainingScore)

        let recentlyViewed = dto.recentlyViewedRecipes.map { ProfileRecipeCard.from(dto: $0) }
        let bookmarked = dto.bookmarkedRecipes.map { ProfileRecipeCard.from(dto: $0) }

        let activity = ProfileActivityPreview(
            recentlyViewed: recentlyViewed,
            bookmarked: bookmarked
        )

        return ProfileMyPageModel(
            profile: profile,
            pointInfo: pointInfo,
            activity: activity
        )
    }
}

extension ProfileRecipeCard {
    /// 서버 응답 DTO(RecipeCard) → 레시피 카드 모델 변환
    static func from(dto: ProfileResponseDTO.RecipeCard) -> ProfileRecipeCard {
        return ProfileRecipeCard(
            id: dto.id,
            title: dto.title ?? "",                // 없으면 빈값
            channelName: dto.channelName ?? "",
            viewCount: dto.viewCount ?? 0,
            videoId: dto.videoId,
            channelId: dto.channelId ?? "",
            videoDuration: dto.videoDuration,
            cookingTimeMinutes: dto.cookingTimeMinutes ?? 0,
            difficulty: dto.difficulty ?? 0,
            isBookmarked: dto.isBookmarked
        )
    }
}
