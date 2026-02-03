//
//  HomeStatDTO.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//

import SwiftUI

struct HomeStatsResponseDTO: Decodable {
    let fridgeScore: Int
    let totalCookingCount: Int
    let averageDifficulty: Double?
    let monthlyCookingStats: [MonthlyCookingStatDTO]
}

struct MonthlyCookingStatDTO: Decodable {
    let month: Int
    let count: Int
}

struct HomeStatsCalendarResponseDTO: Decodable {
    let year: Int
    let month: Int
    let cookedDates: [Int]
    let cookingRecords: [String: [CookingRecordDTO]]
}

struct CookingRecordDTO: Decodable {
    let recipeId: Int
    let imageUrl: String
    let title: String
    let channel: String
    let views: Int
    let time: String
    let rating: Int
}
