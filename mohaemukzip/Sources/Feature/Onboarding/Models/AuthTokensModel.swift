//
//  AuthTokensModel.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//


import Foundation

struct AuthTokensModel {
    let userId: Int
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let isInactive: Bool
}

extension SignUpResultDTO {
    func toModel() -> AuthTokensModel {
        AuthTokensModel(
            userId: id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: isNewUser,
            isInactive: isInactive
        )
    }
}

extension LoginResultDTO {
    func toModel() -> AuthTokensModel {
        AuthTokensModel(
            userId: id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: isNewUser,
            isInactive: isInactive
        )
    }
}
