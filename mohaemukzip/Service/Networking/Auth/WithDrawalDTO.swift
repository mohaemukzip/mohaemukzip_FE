import Foundation
struct WithdrawalResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: EmptyResult?
}
