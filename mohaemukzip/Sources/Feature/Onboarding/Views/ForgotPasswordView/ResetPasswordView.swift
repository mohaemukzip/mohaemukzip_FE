//
//  ResetPasswordView.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/31/26.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var newPassword = ""
    @State private var passwordAgain = ""
    
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
            
            VStack(spacing: 15) {
                HStack {
                    Text("변경할 비밀번호를 입력해주세요.")
                        .foregroundStyle(.black)
                        .font(.PretendardSemibold16)
                    
                    Spacer()
                }
                
                TextField("비밀번호를 입력해주세요.", text: $newPassword)
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
                
                TextField("비밀번호 확인", text: $passwordAgain)
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
            }
            
            Spacer()
            
            Button( action: { /* TODO: 이메일 변경 완료 */ } ) {
                Text("완료")
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
}

#Preview {
    ResetPasswordView()
}
