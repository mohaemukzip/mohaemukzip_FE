import Foundation

struct HomeStatsModel {
    let fridgeScore: Int
    let totalCookingCount: Int
    let averageDifficulty: Double?
    let monthlyPoints: [MonthlyCookingPoint]
}

struct HomeStatsCalendarModel {
    let year: Int
    let month: Int
    let cookedDates: [Int]
    let recordsByDay: [Int: [CookingRecord]]
}

struct CookingRecord: Identifiable {
    let id: Int            // recipeId
    let imageUrl: String
    let title: String
    let channel: String
    let views: Int
    let time: String
    let rating: Int
}

extension HomeStatsResponseDTO {
    func toModel() -> HomeStatsModel {
        let monthDict = Dictionary(uniqueKeysWithValues: monthlyCookingStats.map {
            ($0.month, $0.count)
        })
        
        let points: [MonthlyCookingPoint] = (1...12).map { month in
                .init(month: month, count: monthDict[month] ?? 0)
        }
        
        return HomeStatsModel(
            fridgeScore: fridgeScore,
            totalCookingCount: totalCookingCount,
            averageDifficulty: averageDifficulty,
            monthlyPoints: points
        )
    }
}

extension HomeStatsCalendarResponseDTO {
    func toModel() -> HomeStatsCalendarModel {
        let mapped: [Int: [CookingRecord]] = cookingRecords.reduce(into: [:]) { result, element in
            let (key, records) = element
            guard let day = Int(key) else { return }
            
            result[day] = records.map {
                CookingRecord(
                    id: $0.recipeId,
                    imageUrl: $0.imageUrl,
                    title: $0.title,
                    channel: $0.channel,
                    views: $0.views,
                    time: $0.time,
                    rating: $0.rating
                )
            }
        }
        
        return HomeStatsCalendarModel(
            year: year,
            month: month,
            cookedDates: cookedDates,
            recordsByDay: mapped
        )
    }
}
