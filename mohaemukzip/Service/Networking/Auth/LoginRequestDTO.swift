//
//  LoginRequestDTO.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//


import Foundation

struct LoginRequestDTO: Encodable {
    let loginId: String
    let password: String
}