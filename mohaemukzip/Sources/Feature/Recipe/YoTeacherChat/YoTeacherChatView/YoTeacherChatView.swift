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
                    LazyVStack {
                        
                        if viewModel.messages.isEmpty {
                            HStack {
                                Image("icon-yoteacher-chatbot")
                                Spacer()
                                YoTeacherBubble(text: "오늘은 어떤 요리가 좋을지\n요선생에게 다 말해봐!")
                            }.padding(.horizontal, 17)
                                .padding(.top, 40)
                        }
                        
                        if !viewModel.messages.isEmpty  {
                            ForEach(viewModel.messages) { message in
                                HStack {
                                    Spacer()
                                    UserBubble(text: message.text)
                                        .padding(.trailing, 34)
                                }
                                // TODO: 메시지에 맞는 적절한 응답을 ForEach문 안에 두어야 입력 하나 당 출력이 나옴
                            }
                        }
                        
                    }
                }
                
                Spacer()
                VStack {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(viewModel.recommendQ) { q in
                                Button ( action: {} ) {
                                    RecommendQuestion(text: q.text)
                                        .padding(.trailing, 2)
                                }
                            }
                        }
                    }.padding(.leading, 17)
                        .frame(height: 66)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.grey100)
                            .frame(height: 52)
                        HStack {
                            Spacer()
                            Button ( action: {} ) {
                                Image("icon-chat")
                                    .foregroundStyle(.grey700)
                                    .padding()
                            }
                        }
                        TextField("재료, 상황, 메뉴 키워드를 입력하세요.", text: $text)
                            .padding(.leading)
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
