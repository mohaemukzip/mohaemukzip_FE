//
//  BotResponse.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/25/26.
//

import SwiftUI

struct BotResponse: View {
    var response: [YoTeacherMessage]? = nil
    
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
                    if let videos = response {
                        ForEach(videos) { video in
                            // TODO: 응답으로 온 영상 카드를 나열
                            RecipeVideoChatCard(url: video.thumbnailURL)
                        }
                    }
                }
            }.frame(height: 100)
                .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    BotResponse(response: [YoTeacherMessage(id: 1,
                                            title: "",
                                            thumbnailURL: URL(string: "https://i.ytimg.com/vi/L4NreAnu6a0/mqdefault.jpg")!),
                           YoTeacherMessage(id: 2,
                                                                   title: "",
                                                                   thumbnailURL: URL(string: "https://i.ytimg.com/vi/L4NreAnu6a0/mqdefault.jpg")!),
                           YoTeacherMessage(id: 3,
                                                                   title: "",
                                                                   thumbnailURL: URL(string: "https://i.ytimg.com/vi/L4NreAnu6a0/mqdefault.jpg")!)])
}
