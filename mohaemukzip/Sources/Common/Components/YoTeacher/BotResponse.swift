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
    var onTapVideo: (Int) -> Void
    
    var body: some View {
        if let unwrappedResponse = response {
            
            if unwrappedResponse.isEmpty {
                VStack {
                    HStack {
                        Image("icon-yoteacher-floating")
                            .padding(.trailing, 10)
                        Text("앗, 아직 제가 잘 못 알아들었어요.\n다시 한 번 알려주실래요?")
                            .font(.PretendardRegular16)
                            .lineSpacing(5)
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
                                Button ( action: { onTapVideo(image.id) } ) {
                                    RecipeVideoChatCard(url: image.thumbnailURL)
                                }
                            }
                        }
                    }.frame(height: 100)
                        .scrollIndicators(.hidden)
                }
            }
        }
    }
}

/*
#Preview("response is not empty") {
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
                text: "내용",
                onTapVideo: { _ in  } )
}
*/
#Preview("response is empty") {
    BotResponse(response: [],
                title: "제목",
                text: "내용",
                onTapVideo: { _ in  } )
}
