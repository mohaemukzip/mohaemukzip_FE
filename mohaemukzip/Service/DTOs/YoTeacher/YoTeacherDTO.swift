import Foundation

struct YoTeacherResponseDTO: Decodable {
    let id: String
    let senderType: String
    let title: String
    let message: String
    let createdAt: String
    let formattedTime: String
    let recipeCards: [YoTeacherDTO]?
}

struct YoTeacherDTO: Decodable {
    let recipeId: Int
    let title: String
    let imageUrl: String
    let videoTime: String

    enum CodingKeys: String, CodingKey {
        case recipeId = "recipe_id"
        case title
        case imageUrl = "image_url"
        case videoTime = "video_time"
    }

    func toDomain() -> YoTeacherMessage? {
        guard let thumbnailURL = URL(string: imageUrl) else {
            return nil
        }

        return YoTeacherMessage(
            id: recipeId,
            title: title,
            thumbnailURL: thumbnailURL,
            videoTime: videoTime
        )
    }
}
