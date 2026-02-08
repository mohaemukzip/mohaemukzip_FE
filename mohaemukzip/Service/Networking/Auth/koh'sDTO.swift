//
//  koh'sDTO.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/8/26.
//

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

// MARK: - Auth: Logout / Withdrawal

struct LogoutResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: EmptyResult?
}

struct WithdrawalResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: EmptyResult?
}
