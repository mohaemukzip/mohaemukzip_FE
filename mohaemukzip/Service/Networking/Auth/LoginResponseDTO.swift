//
//  LoginResponseDTO.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//


struct LoginResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: LoginResultDTO
}

struct LoginResultDTO: Decodable {
    let id: Int
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let isInactive: Bool
}