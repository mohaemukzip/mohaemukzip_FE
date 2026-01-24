//
//  YoTeacherChatView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/24/26.
//

import SwiftUI

struct YoTeacherChatView: View {
    @StateObject var viewModel = YoTeacherChatViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button( action: {} ) {
                    Image("back button")
                        .foregroundStyle(.grey700)
                }
                Spacer()
            }.padding(.horizontal, 17)
                .padding(.top, 20)
            
            ZStack {
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
                                UserBubble(text: message.text)
                                
                                // TODO: 메시지에 맞는 적절한 응답을 ForEach문 안에 두어야 입력 하나 당 출력이 나옴
                            }
                        }
                        
                    }
                }
                
                
            } // end of ZStack
            
        } // end of VStack
        
    }
    
}

#Preview {
    YoTeacherChatView()
}
