//
//  BotResponse.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/25/26.
//

import SwiftUI

struct BotResponse: View {
    var response: [YoTeacherMessage]? = nil
    var title: String? = nil
    var text: String? = nil
    
    var body: some View {
        if let unwrappedResponse = response {
            
            if unwrappedResponse .isEmpty {
                VStack {
                    HStack {
                        Text("챗봇 응답을 불러올 수 없습니다.")
                            .font(.PretendardMedium16)
                            .foregroundStyle(.grey900)
                        Spacer()
                    }.padding(.bottom)
                }
            } else {
                VStack {
                    HStack {
                        Text(title ?? "")
                            .font(.PretendardSemibold18)
                            .foregroundStyle(.grey900)
                        Spacer()
                    }.padding(.bottom, 5)
                    HStack {
                        Text(text ?? "")
                            .font(.PretendardRegular16)
                            .foregroundStyle(.grey900)
                        Spacer()
                    }.padding(.bottom, 5)
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(unwrappedResponse) { image in
                                RecipeVideoChatCard(url: image.thumbnailURL)
                            }
                        }
                    }.frame(height: 100)
                        .scrollIndicators(.hidden)
                }
            }
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
                                            thumbnailURL: URL(string: "https://i.ytimg.com/vi/L4NreAnu6a0/mqdefault.jpg")!)],
                title: "제목",
                text: "내용")
}
