import Foundation
// MARK: - Auth: Reissue

struct ReissueResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ReissueResultDTO
}

struct ReissueResultDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
