//
//  ForgotPasswordEmailAuthView.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/31/26.
//

import SwiftUI

struct ForgotPasswordEmailAuthView: View {
    
    @EnvironmentObject private var router: AuthRouter
    @Environment(ForgotPasswordViewModel.self) var viewModel
    
    @FocusState private var isCodeFieldFocused: Bool
    
    var body: some View {
        
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 50) {
            
            HStack(spacing: 0) {
                Button(action: { router.pop() }) {
                    Image("icon-back-big")
                        .foregroundStyle(.grey700)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                
                Text("비밀번호 찾기")
                    .foregroundStyle(.black)
                    .font(.PretendardSemibold20)
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Text("인증번호를 입력하세요.")
                        .font(.PretendardSemibold16)
                        .foregroundColor(.black)
                    Spacer()
                }.padding(.bottom, 32)
            
                ZStack {
                    TextField("", text: $viewModel.verificationCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($isCodeFieldFocused)
                        .opacity(0)
                        .onChange(of: viewModel.verificationCode) { _, newValue in
                            viewModel.updateVerificationCode(newValue)
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
                    .padding(.bottom, 5)
                    .onTapGesture {
                        isCodeFieldFocused = true
                    }
                }
                
                if let message = viewModel.verificationCodeErrorMessage {
                    HStack(spacing: 0) {
                        Image(systemName: "info.circle")
                        Text(message)
                        
                        Spacer()
                    }
                    .font(.PretendardRegular13)
                    .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            Button( action: {
                
                Task {
                    let ok = await viewModel.verifyEmailCode()
                    
                    if ok { router.push(.resetPassword) }
                }
                
            } ) {
                Text("인증하기")
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.canRequestVerificationCode ? .main400 : .grey400)
                    )
            }.disabled(!viewModel.canRequestVerificationCode)
        }.padding()
            .navigationBarBackButtonHidden(true)
    }
    
    private func codeCharacter(at index: Int) -> String {
        let characters = Array(viewModel.verificationCode)
        guard index < characters.count else { return "" }
        return String(characters[index])
    }

}

#Preview {
    ForgotPasswordEmailAuthView()
        .environmentObject(AuthRouter())
        .environment(ForgotPasswordViewModel())
}
