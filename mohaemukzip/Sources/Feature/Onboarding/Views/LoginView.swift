////
////  LoginView.swift
////  mohaemukzip
////
////  Created by 이서현 on 1/28/26.
////
//

import SwiftUI

struct LoginView: View {
    @Environment(NavigationRouter.self) private var router

    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var showError: Bool = false

    private enum Field {
        case email
        case password
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 120)

            Image("loginLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)

            Spacer().frame(height: 44)

            VStack(spacing: 12) {
                // 아이디
                TextField("아이디", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(focusedField == .email ? .grey50 : Color.grey100)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                showError ? Color.red : (focusedField == .email ? Color.main400 : Color.clear),
                                lineWidth: 1
                            )
                    )

                // 비밀번호
                SecureField("비밀번호", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .focused($focusedField, equals: .password)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(focusedField == .password ? Color.grey50 : Color.grey100)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                showError ? Color.red : (focusedField == .password ? Color.main400 : Color.clear),
                                lineWidth: 1
                            )
                    )
            }
            .padding(.horizontal, 20)

            // 에러 문구
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle")
                    .font(.PretendardRegular13)
                Text("아이디 또는 비밀번호가 잘못 되었습니다. 다시 입력해주세요.")
                    .font(.PretendardRegular13)
            }
            .foregroundStyle(Color.red)
            .padding(.top, 10)
            .padding(.horizontal, 20)
            .opacity(showError ? 1 : 0)

            // 로그인 버튼
            Button {
                // TODO: 실제 로그인 API 연동 후 성공 시에만 push
                showError = false
                focusedField = nil
                router.push(.home)
            } label: {
                Text("로그인")
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.main400)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            HStack(spacing: 18) {
                Button { }
                label: {
                    Text("아이디 찾기")
                        .font(.PretendardMedium16)
                        .foregroundStyle(Color.grey300)
                }

                Text("|")
                    .font(.PretendardMedium16)
                    .foregroundStyle(Color.grey300)

                Button { }
                label: {
                    Text("비밀번호 찾기")
                        .font(.PretendardMedium16)
                        .foregroundStyle(Color.grey300)
                }
            }
            .padding(.top, 22)

            Spacer()
        }
        .navigationBarBackButtonHidden()
        .background(Color.white)
        .onChange(of: email) { _, _ in
            if showError { showError = false }
        }
        .onChange(of: password) { _, _ in
            if showError { showError = false }
        }
    }
}

#Preview {
    LoginView()
        .environment(NavigationRouter())
}
