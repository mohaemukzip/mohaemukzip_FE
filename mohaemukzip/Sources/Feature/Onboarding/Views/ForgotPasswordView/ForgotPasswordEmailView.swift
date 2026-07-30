//
//  ForgotPasswordEmailView.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/30/26.
//

import SwiftUI

struct ForgotPasswordEmailView: View {
    
    @State private var email = ""
    
    var body: some View {
        
        VStack(spacing: 50) {
            
            HStack(spacing: 0) {
                Button(action: { /* 뒤로가기 */ }) {
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
                        .font(.PretendardSemibold18)
                    
                    Spacer()
                }
                
                TextField("이메일을 입력하세요.", text: $email)
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
            
            Button( action: { /* 인증 코드 작성 뷰로 이동 */} ) {
                Text("인증 메일 받기")
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
    ForgotPasswordEmailView()
}
