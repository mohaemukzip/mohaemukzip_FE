//
//  ResetPasswordView.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/31/26.
//

import SwiftUI

struct ResetPasswordView: View {
    
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
            
            VStack(spacing: 15) {
                HStack {
                    Text("변경할 비밀번호를 입력해주세요.")
                        .foregroundStyle(.black)
                        .font(.PretendardSemibold16)
                    
                    Spacer()
                }
                
                SecureField("비밀번호를 입력해주세요.", text: $viewModel.newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.grey100)
                    )
                    .onChange(of: viewModel.newPassword) { _, newValue in
                        viewModel.updateNewPassword(newValue)
                    }
                
                SecureField("비밀번호 확인", text: $viewModel.confirmPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.grey100)
                    )
                    .onChange(of: viewModel.confirmPassword) { _, newValue in
                        viewModel.updateConfirmPassword(newValue)
                    }
                
                if let message = viewModel.passwordErrorMessage {
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
            
            Button( action: { router.popToRoot() } ) {
                Text("완료")
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.canRequestResetPassword ? .main400 : .grey400)
                    )
            }.disabled(!viewModel.canRequestResetPassword)
        }.padding()
    }
}

#Preview {
    ResetPasswordView()
        .environmentObject(AuthRouter())
        .environment(ForgotPasswordViewModel())
}
