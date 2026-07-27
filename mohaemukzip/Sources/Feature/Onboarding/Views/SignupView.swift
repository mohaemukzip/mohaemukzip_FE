
import SwiftUI
import Observation

struct SignupView: View {
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AuthRouter
    @State private var viewModel = SignupViewModel()
    var terms: [SignUpTermDTO]
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            VStack(alignment: .leading, spacing: 32) {
                header
                nicknameSection
                emailSection
                passwordSection
                passwordConfirmSection
                
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 17)
            .padding(.top, 12)
        }
        .background(Color.white)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            startButton
                .padding(.horizontal, 17)
        }
        .navigationBarBackButtonHidden()
        .onDisappear(perform: viewModel.stopVerificationTimer)
    }
    
    // MARK: - Components
    
    private var topBar: some View {
        HStack {
            Button(action: { router.pop() }) {
                Image("icon-back-big")
                    .foregroundStyle(.grey700)
                    .frame(width: 44, height: 44, alignment: .leading)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
    }
    
    private var header: some View {
        Text("이메일과 비밀번호만으로\n뭐해먹집?을 이용할 수 있어요.")
            .font(.PretendardSemibold20)
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 4)
    }
    
    private var nicknameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("닉네임")
                .font(.PretendardMedium14)
                .foregroundStyle(.grey700)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.grey100)
                    .frame(height: 44)
                
                HStack(spacing: 10) {
                    TextField("뭐해먹집", text: Binding(
                        get: { viewModel.model.nickname },
                        set: { viewModel.onChangeNickname($0) }
                    ))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.leading, 14)
                    .font(.PretendardRegular16)
                    
                    Spacer(minLength: 0)
                    
                    Text(viewModel.nicknameCountText)
                        .font(.PretendardRegular14)
                        .foregroundStyle(.grey500)
                        .padding(.trailing, 12)
                }
            }
        }
    }
    
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이메일")
                .font(.PretendardMedium14)
                .foregroundStyle(.grey600)
            
            HStack(spacing: 10) {
                TextField("이메일을 입력해주세요.", text: Binding(
                    get: { viewModel.model.email },
                    set: { viewModel.onChangeEmail($0) }
                ))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .padding(.leading, 14)
                .font(.PretendardRegular16)
                .frame(height: 44)
                .background(Color.grey100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button {
                    guard viewModel.isValidEmail else {
                        viewModel.emailVerificationState = .invalidFormat
                        return
                    }
                    
                    Task { await viewModel.requestEmailVerification() }
                } label: {
                    Text("인증 요청")
                        .font(.PretendardMedium16)
                        .foregroundStyle(.main400)
                        .frame(width: 84, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.main400, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                }.disabled(viewModel.isRequestingEmailCode)
            }
            
            emailStatusMessage
            
            if viewModel.shouldShowVerificationField {
                verificationCodeSection
            }
        }
    }
    
    // email 상태 메세지
    @ViewBuilder
    private var emailStatusMessage: some View {
        switch viewModel.emailVerificationState {
        case .invalidFormat:
            statusMessage(
                "유효한 이메일 주소를 입력하세요.",
                color: .red,
                icon: "exclamationmark.circle"
            )
            
        case .codeSent:
            statusMessage(
                "인증번호가 발송되었어요.",
                color: .green,
                icon: "checkmark.circle"
            )
            
        case .verified:
            statusMessage(
                "인증이 완료되었어요.",
                color: .green,
                icon: "checkmark.circle"
            )
            
        case .requestFailed:
            statusMessage(
                "인증번호 요청이 실패했어요.",
                color: .red,
                icon: "exclamationmark.circle"
            )
            
        default:
            EmptyView()
        }
    }
    
    private func statusMessage(_ msg: String, color: Color, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(msg)
        }
        .font(.PretendardRegular13)
        .foregroundStyle(color)
    }
    
    // 인증번호
    private var verificationCodeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("인증번호")
                .font(.PretendardMedium14)
                .foregroundStyle(.grey600)
            
            HStack(spacing: 6) {
                HStack {
                    TextField(
                        "인증번호 6자리 입력",
                        text: Binding(
                            get: { viewModel.model.verificationCode },
                            set: { viewModel.onChangeVerificationCode($0) }
                        )
                    )
                    .keyboardType(.numberPad)
                    
                    Spacer()
                    
                    Text(viewModel.verificationTimeText)
                        .font(.PretendardRegular13)
                        .foregroundStyle(
                            viewModel.remainingSeconds > 0
                            ? Color.grey500
                            : Color.red
                        )
                    
                    Button {
                        Task { await viewModel.requestEmailVerification() }
                    } label: {
                        Text("재요청")
                            .font(.PretendardRegular13)
                            .foregroundStyle(.grey700)
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isRequestingEmailCode)
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.grey100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button {
                    Task { await viewModel.verifyEmailCode() }
                } label: {
                    Text("확인")
                        .font(.PretendardMedium16)
                        .foregroundStyle(.main400)
                }
                .foregroundStyle(.main400)
                .frame(width: 55, height: 44)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.main400)
                }
                .disabled(!viewModel.canVerifyCode || viewModel.isVerifyingEmailCode || viewModel.isRequestingEmailCode)
                .opacity(viewModel.canVerifyCode ? 1 : 0.6)
            }
            
            if viewModel.shouldShowVerificationField {
                verificationStatusMessage
            }
        }
    }
    
    @ViewBuilder
    private var verificationStatusMessage: some View {
        switch viewModel.emailVerificationState {
        case .verified:
            statusMessage(
                "인증이 완료되었어요.",
                color: .green,
                icon: "checkmark.circle"
            )

        case .invalidCode:
            statusMessage(
                "인증번호가 일치하지 않아요.",
                color: .red,
                icon: "exclamationmark.circle"
            )

        case .expired:
            statusMessage(
                "인증 시간이 만료되었어요. 다시 요청해주세요.",
                color: .red,
                icon: "exclamationmark.circle"
            )
            
        default:
            EmptyView()
        }
    }
    
    private var passwordSection: some View {
        let state = viewModel.passwordValidationState

        return VStack(alignment: .leading, spacing: 8) {
            Text("비밀번호")
                .font(.PretendardMedium14)
                .foregroundStyle(.grey700)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.grey100)
                    .frame(height: 44)
                
                SecureField("비밀번호를 입력해주세요.", text: Binding(
                    get: { viewModel.model.password },
                    set: { viewModel.onChangePassword($0) }
                ))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .font(.PretendardRegular16)
            }
            if (state != .empty) {
                HStack(spacing: 6) {
                    Image(systemName: state == .valid
                          ? "checkmark.circle"
                          : "info.circle")

                    Text(state.message)
                }
                .font(.PretendardRegular13)
                .foregroundStyle(
                    state == .empty
                        ? Color.grey500
                        : state.isError
                            ? Color.red
                            : Color.green
                )
                .padding(.top, 2)
            }
        }
    }
    
    private var passwordConfirmSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("비밀번호 확인")
                .font(.PretendardRegular16)
                .foregroundStyle(.grey600)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.grey100)
                    .frame(height: 44)
                
                SecureField("비밀번호 확인", text: Binding(
                    get: { viewModel.model.passwordConfirm },
                    set: { viewModel.onChangePasswordConfirm($0) }
                ))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .font(.PretendardRegular16)
            }
            
            if let error = viewModel.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.PretendardRegular13)
                        .foregroundStyle(Color.red)
                    
                    Text(error)
                        .font(.PretendardRegular13)
                        .foregroundStyle(Color.red)
                }
                .padding(.top, 2)
            } else if viewModel.isPasswordMismatch {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.PretendardRegular13)
                        .foregroundStyle(Color.red)
                    
                    Text("비밀번호가 서로 일치하지 않아요.")
                        .font(.PretendardRegular13)
                        .foregroundStyle(Color.red)
                }
                .padding(.top, 2)
            }
        }
    }
    
    private var startButton: some View {
        Button {
            Task {
                let ok = await viewModel.signup(terms: self.terms)
                if ok, let tokens = viewModel.tokens {
                    // 토큰 저장만 하고 signupFinishView로 이동 (아직 홈으로 이동 X)
                    appState.saveSession(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken, loginType: tokens.loginType)
                    router.push(.signupFinish)
                }
            }
        } label: {
            Text("시작하기")
                .font(.PretendardSemibold18 )
                .foregroundStyle(viewModel.isReadyToStart && !viewModel.isLoading ? Color.white : Color.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 57)
                .background((viewModel.isReadyToStart && !viewModel.isLoading) ? .main400 : .grey400)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(Rectangle())
        }
        .disabled(!viewModel.isReadyToStart || viewModel.isLoading)
    }
}

#Preview("회원가입") {
    SignupView(terms: [SignUpTermDTO(id: 1, isAgreed: false)])
        .environmentObject(AuthRouter())
        .environmentObject(AppState())
}
