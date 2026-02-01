//
//  YoTeacherChatView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import SwiftUI

struct YoTeacherChatView: View {
    @Environment(YoTeacherChatViewModel.self) var viewModel
    @Environment(NavigationRouter.self) var router
    @State var text: String = ""
    var isSendButtonDisabled: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button( action: { router.pop() } ) {
                        Image("backbutton")
                            .foregroundStyle(.grey700)
                    }
                    Spacer()
                }.padding(.horizontal, 17)
                    .padding(.top, 20)
                
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack {
                            
                            if viewModel.messages1.isEmpty {
                                HStack {
                                    Image("icon-yoteacher-chatbot")
                                    Spacer()
                                    YoTeacherBubble(text: "오늘은 어떤 요리가 좋을지\n요선생에게 다 말해봐!")
                                }.padding(.horizontal, 17)
                                    .padding(.top, 40)
                            }
                            
                            if !viewModel.messages1.isEmpty {
                                ForEach(viewModel.messages1) { message in
                                    VStack {
                                        HStack {
                                            Spacer()
                                            UserBubble(text: message.text)
                                                .padding(.trailing, 34)
                                                .padding(.bottom, 70)
                                        }
                                        
                                        if message.id != viewModel.messages1.last?.id {
                                            BotResponse(response: message.chatBotResponse,
                                                        title: message.chatBotTitle,
                                                        text: message.chatBotText)
                                                .padding(.bottom, 70)
                                        } else {
                                            if viewModel.responseState == .thinking {
                                                HStack {
                                                    Image("icon-thinking")
                                                    Spacer()
                                                }.padding(.bottom, 70)
                                            } else if viewModel.responseState == .completed {
                                                BotResponse(response: message.chatBotResponse,
                                                            title: message.chatBotTitle,
                                                            text: message.chatBotText)
                                                    .padding(.bottom, 70)
                                            }
                                        }
                                        
                                    }.padding(.leading, 17)
                                        .id(message.id)
                                }
                            }
                        }.padding(.top, 50)
                            .onChange(of: viewModel.messages1.count) {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(viewModel.messages1.last?.id, anchor: .bottom)
                                }
                            }
                            .onChange(of: viewModel.responseState) {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(viewModel.messages1.last?.id, anchor: .bottom)
                                }
                            }
                    }
                    
                }
                
                Spacer()
                VStack {
                    
                    if viewModel.messages1.isEmpty {
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(viewModel.recommendQ) { q in
                                    Button ( action: { Task {await viewModel.sendMessage(message: q.text)} } ) {
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
                            Button ( action: { let messageToSend = text; text = "";
                                Task {await viewModel.sendMessage(message: messageToSend)} } ) {
                                Image("icon-chat")
                                        .foregroundStyle(isSendButtonDisabled ? .grey300 : .grey700)
                                    .padding()
                                }.disabled(isSendButtonDisabled)
                        }
                        
                    }.padding(.horizontal, 17)
                        .padding(.bottom, 10)
                }
            } // end of VStack
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    YoTeacherChatView()
        .environment(NavigationRouter())
        .environment(YoTeacherChatViewModel())
}
