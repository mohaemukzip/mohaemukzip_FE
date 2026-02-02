//
//  ProfileRequestDTO.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/2/26.
//

import Foundation

/// Profile/Mypage 관련 Request DTO 모음
/// - NOTE: GET 요청(마이페이지 조회/최근 본 레시피/저장된 레시피 목록)은 body가 없으므로 RequestDTO가 필요하지 않습니다.

enum ProfileRequestDTO {

    // MARK: - 프로필 이미지 업로드 URL 발급

    /// POST /s3/profile/upload-url
    /// - Parameters:
    ///   - fileName: 예) "profileImage.png"
    ///   - contentType: 예) "image/png"
    struct IssueUploadURLRequest: Codable {
        let fileName: String
        let contentType: String

        init(fileName: String, contentType: String) {
            self.fileName = fileName
            self.contentType = contentType
        }
    }

    // MARK: - 프로필 수정

    /// PATCH /members/me/profile
    /// - Parameters:
    ///   - profileImageKey: presigned URL 발급 시 받은 key (예: "profiles/uuid.png")
    ///   - nickname: 변경할 닉네임 (예: "뭐해먹집")
    struct UpdateProfileRequest: Codable {
        let profileImageKey: String
        let nickname: String

        init(profileImageKey: String, nickname: String) {
            self.profileImageKey = profileImageKey
            self.nickname = nickname
        }
    }
}
