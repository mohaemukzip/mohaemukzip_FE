import Foundation



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
    struct UpdateProfileRequest: Encodable {
        let profileImageKey: String?
        let nickname: String?

        init(profileImageKey: String? = nil, nickname: String? = nil) {
            self.profileImageKey = profileImageKey
            self.nickname = nickname
        }

        enum CodingKeys: String, CodingKey {
            case profileImageKey
            case nickname
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            if let profileImageKey {
                try container.encode(profileImageKey, forKey: .profileImageKey)
            }
            if let nickname {
                try container.encode(nickname, forKey: .nickname)
            }
        }
    }
}
