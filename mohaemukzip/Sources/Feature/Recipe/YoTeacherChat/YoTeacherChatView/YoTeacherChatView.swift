//
//  YoTeacherChatView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import SwiftUI

struct YoTeacherChatView: View {
    @StateObject var viewModel = YoTeacherChatViewModel()
    @State var text: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button( action: {} ) {
                        Image("back button")
                            .foregroundStyle(.grey700)
                    }
                    Spacer()
                }.padding(.horizontal, 17)
                    .padding(.top, 20)
                
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack {
                            
                            if viewModel.messages.isEmpty {
                                HStack {
                                    Image("icon-yoteacher-chatbot")
                                    Spacer()
                                    YoTeacherBubble(text: "오늘은 어떤 요리가 좋을지\n요선생에게 다 말해봐!")
                                }.padding(.horizontal, 17)
                                    .padding(.top, 40)
                            }
                            
                            if !viewModel.messages.isEmpty {
                                ForEach(viewModel.messages) { message in
                                    VStack {
                                        HStack {
                                            Spacer()
                                            UserBubble(text: message.text)
                                                .padding(.trailing, 34)
                                                .padding(.bottom, 70)
                                        }
                                        
                                        if let videos = message.responseVideos {
                                            BotResponse(responseVideos: videos)
                                                .padding(.bottom, 70)
                                        }
                                        
                                        if message.id == viewModel.messages.last?.id {
                                            // TODO: 메세지 당 응답을 같은 ForEach문에 배치
                                            if viewModel.responseState == .thinking {
                                                HStack {
                                                    Image("icon-thinking")
                                                    Spacer()
                                                }.padding(.bottom, 70)
                                            } else if viewModel.responseState == .skeleton {
                                                BotResponse(responseVideos: message.responseVideos)
                                                    .padding(.bottom, 70)
                                            }
                                        }
                                    }.padding(.leading, 17)
                                        .id(message.id)
                                }
                            }
                        }.padding(.top, 50)
                            .onChange(of: viewModel.messages.count) {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                                }
                            }
                            .onChange(of: viewModel.responseState) {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                                }
                            }
                    }
                    
                }
                
                Spacer()
                VStack {
                    
                    if viewModel.messages.isEmpty {
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(viewModel.recommendQ) { q in
                                    Button ( action: { viewModel.addMessages(text: q.text) } ) {
                                        RecommendQuestion(text: q.text)
                                            .padding(.trailing, 2)
                                    }
                                }
                            }
                        }.padding(.leading, 17)
                            .frame(height: 66)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.grey100)
                            .frame(height: 52)
                        HStack {
                            TextField("재료, 상황, 메뉴 키워드를 입력하세요.", text: $text)
                                .padding(.leading)
                            Spacer()
                            Button ( action: { viewModel.addMessages(text: text )} ) {
                                Image("icon-chat")
                                    .foregroundStyle(.grey700)
                                    .padding()
                            }
                        }
                        
                    }.padding(.horizontal, 17)
                        .padding(.bottom, 10)
                }
                            
            } // end of VStack
        }
        
        
    }
    
}

#Preview {
    YoTeacherChatView()
}
