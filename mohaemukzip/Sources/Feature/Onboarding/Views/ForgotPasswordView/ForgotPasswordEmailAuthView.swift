//
//  ForgotPasswordEmailAuthView.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/31/26.
//

import SwiftUI

struct ForgotPasswordEmailAuthView: View {
    
    @State private var verificationCode = ""
    @FocusState private var isCodeFieldFocused: Bool
    
    var body: some View {
        
        VStack(spacing: 50) {
            
            HStack(spacing: 0) {
                Button(action: { /* TODO: 뒤로가기 */ }) {
                    Image("icon-back-big")
                        .foregroundStyle(.grey700)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                
                Text("비밀번호 찾기")
                    .foregroundStyle(.black)
                    .font(.PretendardSemibold20)
                
                Spacer()
            }
            
            VStack(spacing: 32) {
                HStack {
                    Text("인증번호를 입력하세요.")
                        .font(.PretendardSemibold16)
                        .foregroundColor(.black)
                    Spacer()
                }
            
                ZStack {
                    TextField("", text: $verificationCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($isCodeFieldFocused)
                        .opacity(0)
                        .onChange(of: verificationCode) { _, newValue in
                            verificationCode = String(newValue.filter { $0.isNumber }.prefix(6))
                        }

                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            Text(codeCharacter(at: index))
                                .font(.pretend(type: .regular, size: 24))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.grey400, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        isCodeFieldFocused = true
                    }
                }
            }
            
            Spacer()
            
            Button( action: { /* TODO: 비밀번호 재설정 뷰로 이동 */ } ) {
                Text("인증하기")
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.main400)
                    )
            }
        }.padding()
    }
    
    private func codeCharacter(at index: Int) -> String {
        let characters = Array(verificationCode)
        guard index < characters.count else { return "" }
        return String(characters[index])
    }

}

#Preview {
    ForgotPasswordEmailAuthView()
}
