
import SwiftUI
import Observation

struct SignupView: View {
    
    @EnvironmentObject private var router: AuthRouter
    @State private var viewModel = SignupViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            VStack(alignment: .leading, spacing: 32) {
                header
                nicknameSection
                idSection
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
        Text("아이디와 비밀번호만으로\n뭐해먹집?을 이용할 수 있어요.")
            .font(.PretendardSemibold20)
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
        // ✅ 높이 제약으로 인해 말줄임표가 생기지 않도록 세로로 확장 허용
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
    
    private var idSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("아이디")
                .font(.PretendardMedium14)
                .foregroundStyle(.grey600)
            
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.grey100)
                        .frame(height: 44)
                    
                    HStack(spacing: 10) {
                        TextField("아이디를 입력해주세요.", text: Binding(
                            get: { viewModel.model.userId },
                            set: { viewModel.onChangeUserId($0) }
                        ))
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .padding(.leading, 14)
                        .font(.PretendardRegular16)
                        
                        Spacer(minLength: 0)
                        
                        Text(viewModel.userIdCountText)
                            .font(.PretendardRegular14)
                            .foregroundStyle(.grey500)
                            .padding(.trailing, 12)
                    }
                }
                
                Button {
                    Task { await viewModel.checkDuplicateId() }
                } label: {
                    Text(viewModel.isCheckingId ? "확인중" : "중복확인")
                        .font(.PretendardMedium16)
                        .foregroundStyle(.main400)
                        .frame(width: 84, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.main400, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                }
                .disabled(viewModel.isCheckingId)
                .opacity(viewModel.isCheckingId ? 0.6 : 1)
            }
            
            if let msg = (viewModel.idCheckMessage ?? viewModel.idCheckState.message) {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.idCheckState.isSuccess ? "checkmark.circle" : "exclamationmark.circle")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(viewModel.idCheckState.isSuccess ? Color.green : Color.red)
                    
                    Text(msg)
                        .font(.system(size: 12))
                        .foregroundStyle(viewModel.idCheckState.isSuccess ? Color.green : Color.red)
                }
                .padding(.top, 2)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(.grey500)
                    
                    Text(viewModel.helperTextForIdFormat())
                        .font(.system(size: 12))
                        .foregroundStyle(.grey500)
                }
                .padding(.top, 2)
            }
        }
    }
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.PretendardRegular13)
                    .foregroundStyle(.grey500)
                
                Text(viewModel.helperTextForPasswordFormat())
                    .font(.PretendardRegular13)
                    .foregroundStyle(.grey500)
            }
            .padding(.top, 2)
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
                let ok = await viewModel.signup()
                if ok {
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
