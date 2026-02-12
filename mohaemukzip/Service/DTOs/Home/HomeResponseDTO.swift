
struct HomeResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: HomeResultDTO
}

struct HomeResultDTO: Decodable {
    let level: Int
    let title: String
    let monthlyCooking: Int
    let score: Int
    let nextLevelScore: Int
    let nickname: String
    let consecutiveDays: Int
    let weeklyCooking: WeeklyCookingDTO
    let todayMission: TodayMissionDTO
    let recommendedRecipes: [RecommendedRecipeDTO]

    enum CodingKeys: String, CodingKey {
        case level
        case title
        case monthlyCooking
        case score
        case nextLevelScore
        case nickname
        case consecutiveDays
        case weeklyCooking
        case todayMission
        case recommendedRecipes
    }
}

struct WeeklyCookingDTO: Decodable {
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
    
    var asArray: [(day: String, isDone: Bool)] {
        [
            ("월", monday),
            ("화", tuesday),
            ("수", wednesday),
            ("목", thursday),
            ("금", friday),
            ("토", saturday),
            ("일", sunday)
        ]
    }
}

// MARK: - TodayMission
struct TodayMissionDTO: Decodable {
    let missionId: Int
    let title: String
    let description: String
    let reward: Int
    var status: MissionStatusDTO
    let dishId: Int
}

enum MissionStatusDTO: String, Decodable {
    case assigned = "ASSIGNED"
    case completed = "COMPLETED"
}

struct RecommendedRecipeDTO: Decodable, Identifiable {
    let recipeId: Int
    let title: String
    let videoId: String
    let videoUrl: String
    let imageUrl: String
    let channel: String
    let channelId: String
    let views: Int
    let time: String
    let cookingTime: Int
    
    var id: Int { recipeId }
}
