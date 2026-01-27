//
//  BotResponse.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/25/26.
//

import SwiftUI

struct BotResponse: View {
    var responseVideos: [RecipeVideo]? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text("그렇다면 이런 요리는 어때요?")
                    .font(.PretendardSemibold18)
                    .foregroundStyle(.grey900)
                Spacer()
            }.padding(.bottom, 1)
            HStack {
                Text("집밥 몇 가지를 추천해드릴게요.")
                    .font(.PretendardMedium16)
                    .foregroundStyle(.grey900)
                Spacer()
            }.padding(.bottom)
            ScrollView(.horizontal) {
                LazyHStack {
                    if let videos = responseVideos {
                        ForEach(videos) { video in
                            // TODO: 응답으로 온 영상 카드를 나열
                            RecipeVideoChatCard(video: video)
                        }
                    } else {
                        ForEach(0..<3) { _ in
                            YoSkeleton()
                        }
                    }
                }
            }.frame(height: 100)
                .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    BotResponse(responseVideos: [
        RecipeVideo(id: 1, title: "추천 레시피", videoId: "sHpMVI8wQuk", channelName: "요선생", viewCount: 1000, cookingTimeMinutes: 15, cuisine: .korean),
        RecipeVideo(id: 2, title: "추천 레시피", videoId: "sHpMVI8wQuk", channelName: "요선생", viewCount: 1000, cookingTimeMinutes: 15, cuisine: .korean),
        RecipeVideo(id: 3, title: "추천 레시피", videoId: "sHpMVI8wQuk", channelName: "요선생", viewCount: 1000, cookingTimeMinutes: 15, cuisine: .korean)
    ])
}
