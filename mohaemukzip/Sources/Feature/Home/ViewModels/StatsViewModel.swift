//
//  HomStatsViewModel.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/31/26.
//

import SwiftUI

@Observable
final class StatsViewModel {
    private(set) var fridgeScore: Int = 0
    private(set) var totalCookingCount: Int = 0
    private(set) var averageDifficulty: Double? = nil
    private(set) var monthlyPoints: [MonthlyCookingPoint] = (1...12).map { .init(month: $0, count: 0) }
    
    // 캘린더(스티커)용
    private(set) var stickerDates: Set<Date> = []
    private(set) var calendarYear: Int = Calendar.current.component(.year, from: Date())
    private(set) var calendarMonth: Int = Calendar.current.component(.month, from: Date())

    var initialMonthDate: Date {
        Calendar.current.date(from: DateComponents(year: calendarYear, month: calendarMonth, day: 1)) ?? Date()
    }
    
    private let homeService = HomeService()
    
    var averageDifficultyText: String {
        guard let averageDifficulty else { return "-" }
        // 소수 1자리 고정 (예: 3.8)
        return String(format: "%.1f", averageDifficulty)
    }
    
    @MainActor
    func load() async {
        do {
            // 1) 상단 통계
            let statsDTO = try await homeService.fetchHomeStats()
            let statsModel = statsDTO.toModel()
            fridgeScore = statsModel.fridgeScore
            totalCookingCount = statsModel.totalCookingCount
            averageDifficulty = statsModel.averageDifficulty
            monthlyPoints = statsModel.monthlyPoints

            // 2) 캘린더 스티커 날짜
            let calendarModel = try await homeService.fetchHomeStatsCalendar(year: calendarYear, month: calendarMonth)
            stickerDates = Self.makeStickerDates(
                year: calendarModel.year,
                month: calendarModel.month,
                cookedDates: calendarModel.cookedDates
            )
        } catch {
            print("❌ StatsViewModel.load error:", error)
        }
    }
    
    private static func makeStickerDates(year: Int, month: Int, cookedDates: [Int]) -> Set<Date> {
        let calendar = Calendar.current
        let dates: [Date] = cookedDates.compactMap { day in
            calendar.date(from: DateComponents(year: year, month: month, day: day))
        }
        return Set(dates.map { calendar.startOfDay(for: $0) })
    }
}
