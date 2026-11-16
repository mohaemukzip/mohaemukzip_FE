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
                    Button( action: { AppAnalytics.logButton("요선생 채팅", "뒤로가기"); router.pop() } ) {
                        Image("backbutton")
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
                                        
                                        if message.id != viewModel.messages.last?.id {
                                            BotResponse(response: message.chatBotResponse,
                                                        title: message.chatBotTitle,
                                                        text: message.chatBotText,
                                                        onTapVideo: { id in router.push(.recipeDetailById(id)) })
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
                                                            text: message.chatBotText,
                                                            onTapVideo: { id in router.push(.recipeDetailById(id)) })
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
                            .onAppear() {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                    }
                }
                
                Spacer()
                VStack {
                    
                    if viewModel.messages.isEmpty {
                        HStack(spacing: 17) {
                            ForEach(viewModel.recommendQ) { q in
                                Button ( action: { AppAnalytics.logButton("요선생 채팅", "추천 질문 선택"); Task {await viewModel.sendMessage(message: q.text)} } ) {
                                    RecommendQuestion(text: q.text)
                                }.frame(height: 66)
                            }
                        }.padding(.horizontal)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.grey100)
                            .frame(height: 52)
                        HStack {
                            TextField("재료, 상황, 메뉴 키워드를 입력하세요.", text: $text)
                                .padding(.leading)
                            Spacer()
                            Button ( action: { AppAnalytics.logButton("요선생 채팅", "메시지 전송"); let messageToSend = text; text = "";
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
