//
//  CheckLoginIdDTO.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//


struct CheckLoginIdRequestDTO: Encodable {
    let loginId: String
}

struct CheckLoginIdResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: CheckLoginIdResultDTO
}

struct CheckLoginIdResultDTO: Decodable {
    let available: Bool
    let message: String
}

extension CheckLoginIdResponseDTO {
    func toModel() -> CheckLoginIdModel {
        .init(available: result.available, message: result.message)
    }
}
