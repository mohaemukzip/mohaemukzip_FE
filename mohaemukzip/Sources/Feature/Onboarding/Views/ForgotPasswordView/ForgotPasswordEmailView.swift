//
//  ForgotPasswordEmailView.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/30/26.
//

import SwiftUI

struct ForgotPasswordEmailView: View {
    
    @EnvironmentObject private var router: AuthRouter
    @Environment(ForgotPasswordViewModel.self) var viewModel
    
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
                    Text("가입에 사용한 이메일 주소를 입력하세요.")
                        .foregroundStyle(.black)
                        .font(.PretendardSemibold16)
                    
                    Spacer()
                }
                
                TextField("이메일을 입력하세요.", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.grey100)
                    )
                    .onChange(of: viewModel.email) { _, newValue in
                        viewModel.updateEmail(newValue) }
                
                if let message = viewModel.emailErrorMessage {
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
                    let ok = await viewModel.requestEmailVerification(email: viewModel.email)
                    
                    if ok { router.push(.forgotPasswordEmailAuth) }
                }
                
            } ) {
                Text("인증 메일 받기")
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.canRequestVerificationEmail ? .main400 : .grey400)
                    )
            }.disabled(!viewModel.canRequestVerificationEmail)
        }.padding()
    }
}

#Preview {
    ForgotPasswordEmailView()
        .environmentObject(AuthRouter())
        .environment(ForgotPasswordViewModel())
}
