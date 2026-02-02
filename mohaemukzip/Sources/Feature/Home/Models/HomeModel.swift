//
//  HomeModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

struct HomeModel {
    let level: Int
    let title: String
    let monthlyCooking: Int
    let score: Int
    let nextLevelScore: Int
    let consecutiveDays: Int
    let weekly: [(day: String, isDone: Bool)]
    let todayMission: TodayMissionModel
    let recipes: [RecipeModel]
    
    var progressText: String { "\(score)/\(nextLevelScore)" }
    var progressRatio: Double {
        guard nextLevelScore > 0 else { return 0 }
        return min(max(Double(score) / Double(nextLevelScore), 0), 1)
    }
}

struct TodayMissionModel: Equatable {
    let missionId: Int
    let title: String
    let description: String
    let reward: Int
    let isCompleted: Bool
}

struct RecipeModel: Identifiable, Equatable {
    let id: Int
    let title: String
    let videoId: String
    let videoUrl: String
    let imageUrl: String
    let channel: String
    let views: Int
    let time: String
    let cookingTime: Int
}

extension HomeResultDTO {
    func toModel() -> HomeModel {
        HomeModel(
            level: level,
            title: title,
            monthlyCooking: monthlyCooking,
            score: score,
            nextLevelScore: nextLevelScore,
            consecutiveDays: consecutiveDays,
            weekly: weeklyCooking.asArray,
            todayMission: .init(
                missionId: todayMission.missionId,
                title: todayMission.title,
                description: todayMission.description,
                reward: todayMission.reward,
                isCompleted: todayMission.isCompleted
            ),
            recipes: recommendedRecipes.map {
                .init(
                    id: $0.recipeId,
                    title: $0.title,
                    videoId: $0.videoId,
                    videoUrl: $0.videoUrl,
                    imageUrl: $0.imageUrl,
                    channel: $0.channel,
                    views: $0.views,
                    time: $0.time,
                    cookingTime: $0.cookingTime
                )
            }
        )
    }
}
