import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AuthRouter
    
    @State private var viewModel = LoginViewModel()
    
    private enum Field {
        case loginId
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
            
            VStack(spacing: 16) {
                // 아이디
                TextField("아이디", text: $viewModel.loginId)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .loginId)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(focusedField == .loginId ? .grey50 : Color.grey100)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.showError ? Color.red : (focusedField == .loginId ? Color.main400 : Color.clear),
                                lineWidth: 1
                            )
                    )
                
                SecureField("비밀번호", text: $viewModel.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.plain)
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
                                viewModel.showError ? Color.red : (focusedField == .password ? Color.main400 : Color.clear),
                                lineWidth: 1
                            )
                    )
            }
            .padding(.horizontal, 17)
            
            // 에러 문구
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle")
                    .font(.PretendardRegular13)
                Text(viewModel.errorMessage ?? "아이디 또는 비밀번호가 잘못 되었습니다. 다시 입력해주세요.")
                    .font(.PretendardRegular13)
            }
            .foregroundStyle(Color.red)
            .padding(.top, 10)
            .opacity(viewModel.showError ? 1 : 0)
            
            // MARK: 로그인 버튼
            Button {
                focusedField = nil
                Task {
                    let ok = await viewModel.login() // 로그인 성공시 true
                    if ok, let tokens = viewModel.tokens {
                        appState.loginSucceeded(accessToken: tokens.accessToken,
                                                refreshToken: tokens.refreshToken, loginType: "GENERAL")
                    }
                }
            } label: {
                Text("로그인")
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold18)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill((viewModel.isLoading || viewModel.loginId.isEmpty || viewModel.password.isEmpty) ? Color.grey400 : Color.main400)
                    )
            }
            .padding(.horizontal, 17)
            .padding(.top, 3)
            .disabled(viewModel.isLoading || viewModel.loginId.isEmpty || viewModel.password.isEmpty)
            
            HStack {
                Button { }
                label: {
                    Text("아이디 찾기")
                }
                
                Text("|").padding(.horizontal)
                    .foregroundStyle(.grey300)
                
                Button { }
                label: {
                    Text("비밀번호 찾기")
                }
                
                Text("|").padding(.horizontal)
                    .foregroundStyle(.grey300)
                
                Button { router.push(.agree) }
                label: {
                    Text("회원가입")
                        
                }
            }
            .font(.PretendardMedium14)
            .foregroundStyle(.grey500)
            .padding(.top, 15)
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                VStack { Divider().foregroundStyle(.grey300) }.padding(.horizontal)
                Text("또는").font(.PretendardRegular16).foregroundStyle(.grey500)
                VStack { Divider().foregroundStyle(.grey300) }.padding(.horizontal)
            }.padding(.bottom)
            
            // MARK: 카카오 소셜 로그인
            Button {
                
                focusedField = nil
                Task {
                    let ok = await viewModel.loginWithKakao()
                    
                    // 로그인 성공 시,
                    if ok, let tokens = viewModel.tokens {
                        // 약관 동의 완료하지 않은 유저라면,
                        if !tokens.termsAgreed {
                            appState.setSession(accessToken: tokens.accessToken,
                                                refreshToken: tokens.refreshToken)
                            router.push(.socialAgree)
                        } else {
                            appState.loginSucceeded(accessToken: tokens.accessToken,
                                                    refreshToken: tokens.refreshToken,loginType: "GENERAL")
                        }
                    }
                }
            } label: {
                HStack {
                    Image("social-kakao")
                    Spacer()
                    Text("카카오로 로그인")
                        .font(.PretendardMedium16)
                        .foregroundStyle(.grey800)
                    Spacer()
                }.padding(.horizontal, 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.grey300, lineWidth: 1)
                        .foregroundStyle(.clear)
                        .frame(height: 52)
                )
            }.padding()
                .padding(.bottom, 10)
                .padding(.top, 10)
                .disabled(viewModel.isKakaoLoading)
            
            // MARK: 애플 소셜 로그인
            
            // 애플 기본 제공 버튼 - 반려 시 기본 제공 버튼 고려
            /*SignInWithAppleButton(
                .signIn,
                onRequest: { _ in },
                onCompletion: { _ in }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)*/
            
            Button {
                focusedField = nil
                Task {
                    let ok = await viewModel.loginWithApple()
                    
                    // 로그인 성공 시,
                    if ok, let tokens = viewModel.tokens {
                        // 약관 동의 완료하지 않은 유저라면,
                        if !tokens.termsAgreed {
                            appState.setSession(accessToken: tokens.accessToken,
                                                refreshToken: tokens.refreshToken)
                            router.push(.socialAgree)
                        } else {
                            appState.loginSucceeded(accessToken: tokens.accessToken,
                                                    refreshToken: tokens.refreshToken, loginType: "GENERAL")
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "apple.logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.black)
                    Spacer()
                    Text("Apple로 로그인")
                        .font(.PretendardMedium16)
                        .foregroundStyle(.grey800)
                    Spacer()
                }.padding(.horizontal, 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.grey300, lineWidth: 1)
                        .foregroundStyle(.clear)
                        .frame(height: 52)
                )
            }.padding()
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .background(Color.white)
        .onChange(of: viewModel.loginId) { _, _ in
            viewModel.clearErrorIfNeeded()
        }
        .onChange(of: viewModel.password) { _, _ in
            viewModel.clearErrorIfNeeded()
        }
    }
}

#Preview("로그인") {
    NavigationStack {
        LoginView()
            .environmentObject(AppState())
            .environmentObject(AuthRouter())
    }
}
