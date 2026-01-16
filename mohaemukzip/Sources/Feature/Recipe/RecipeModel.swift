//
//  RecipyModel.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/16/26.
//

import Foundation

// MARK: - Model

import SwiftUI

// 음식 카테고리
enum RecipeCategory: String, CaseIterable, Identifiable {
    case korean = "한식"
    case chinese = "중식"
    case japanese = "일식"
    case western = "양식"
    case southeastAsian = "동남아"
    case soup = "국/찌개"
    case rice = "밥요리"
    case noodle = "국수"
    case stirFry = "볶음"
    case braised = "조림"
    case pancake = "전/부침"
    case mix = "비빔/무침"
    case side = "반찬"
    case kimchi = "김치 요리"
  

    var id: String { rawValue }
}

struct RecipeVideo: Identifiable {
    let id: Int                 // 서버에서 내려주는 고정 id (더미일 경우 직접 지정)
    let title: String
    let channelName: String
    let viewCount: Int
    let thumbnailImageName: String
    let videoId: String
    let category: RecipeCategory
    var isBookmarked: Bool
}




