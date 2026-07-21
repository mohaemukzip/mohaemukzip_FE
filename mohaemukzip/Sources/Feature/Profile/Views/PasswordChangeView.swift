import SwiftUI

enum PasswordChangeStep {
    case email
    case verification
    case password
}

@Observable
final class PasswordChangeViewModel {

    // MARK: - Account

    let accountVM = AccountSettingsViewModel()

    init() {}

    // MARK: - Step

    var step: PasswordChangeStep = .email

    // MARK: - Email

    var inputEmail: String = ""

    // MARK: - Verification

    var verificationCode: String = ""

    // MARK: - Password

    var newPassword: String = ""
    var confirmPassword: String = ""

    // API 성공 시 true
    var isVerified: Bool = false

    // MARK: - Validation

    /// 이메일 일치 여부
    var canSendVerification: Bool {
        inputEmail.lowercased()
        ==
        (accountVM.accountInfo?.email ?? "").lowercased()
    }
    /// 인증번호 6자리
    var canVerify: Bool {
        verificationCode.count == 6
    }

    /// 비밀번호 정책(임시)
    var isPasswordValid: Bool {
        let hasLetter = newPassword.range(of: "[A-Za-z]", options: .regularExpression) != nil
        let hasNumber = newPassword.range(of: "[0-9]", options: .regularExpression) != nil

        return newPassword.count >= 10 && hasLetter && hasNumber
    }

    /// 비밀번호 일치
    var isPasswordMatched: Bool {
        !newPassword.isEmpty &&
        newPassword == confirmPassword
    }

    /// 완료 버튼 활성화
    var canComplete: Bool {
        isPasswordValid &&
        isPasswordMatched &&
        isVerified
    }
    // MARK: - UI State

    var isLoading = false
    var errorMessage: String?

    // MARK: - Actions

    /// TODO: 이메일 인증 발송 API
    func sendVerificationCode() {

        Task {

            do {

                isLoading = true

                try await AuthService.shared.sendResetPasswordEmail(
                    email: inputEmail
                )

                isLoading = false
                step = .verification

            } catch {

                isLoading = false
                errorMessage = "인증번호 발송에 실패했습니다."
            }
        }
    }

    /// TODO: 이메일 인증 확인 API
    func verifyCode() {

        Task {

            do {

                isLoading = true

                let verified =
                try await AuthService.shared.verifyEmail(
                    email: inputEmail,
                    authCode: verificationCode
                )

                isLoading = false

                if verified {

                    isVerified = true
                    errorMessage = nil
                    step = .password

                } else {

                    errorMessage = "인증번호가 틀립니다."
                }

            } catch {

                isLoading = false
                errorMessage = "인증번호가 틀립니다."
            }
        }
    }

    /// TODO: 비밀번호 변경 API
    func complete(
        dismiss: @escaping () -> Void
    ) {

        Task {

            do {

                isLoading = true

                try await AuthService.shared.resetPassword(
                    email: inputEmail,
                    newPassword: newPassword
                )

                isLoading = false

                dismiss()

            } catch {

                isLoading = false
                errorMessage = "비밀번호 변경에 실패했습니다."
            }
        }
    }
}
struct PasswordChangeView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PasswordChangeViewModel()
    @FocusState private var isCodeFieldFocused: Bool
    

    var body: some View {
       
            VStack(alignment: .leading, spacing: 0) {

                switch viewModel.step {

                case .email:
                    emailView

                case .verification:
                    verificationView

                case .password:
                    passwordView
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle("비밀번호 변경")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(viewModel.step != .email)
            .toolbar {
                if viewModel.step != .email {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            back()
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .tint(.black)
                    }
                }
            }
        
        }
    private func back() {
        switch viewModel.step {
        case .email:
            dismiss()

        case .verification:
            viewModel.step = .email

        case .password:
            viewModel.step = .verification
        }
    }
    }

private extension PasswordChangeView {

    var emailView: some View {
        VStack(alignment: .leading, spacing: 24) {

            VStack(alignment: .leading, spacing: 8) {

                Text("이메일")
                    .font(.custom("Pretendard-SemiBold", size: 15))
                    .foregroundColor(.black)

                TextField("이메일을 입력해주세요.", text: $viewModel.inputEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("가입한 이메일과 동일해야 합니다.")
                    .font(.custom("Pretendard-Regular", size: 13))
                    .foregroundColor(.gray)
            }

            Button {

                viewModel.sendVerificationCode()

            } label: {

                Text("인증번호 받기")
                    .font(.custom("Pretendard-SemiBold", size: 16))
            
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        viewModel.canSendVerification
                        ? Color.black
                        : Color.gray.opacity(0.35)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!viewModel.canSendVerification)
        }
        .padding(.top, 32)
    }
}

private extension PasswordChangeView {

    var verificationView: some View {
        VStack(alignment: .leading, spacing: 24) {

            VStack(alignment: .leading, spacing: 12) {

                Text("인증번호")
                    .font(.custom("Pretendard-SemiBold", size: 15))

                ZStack {

                    TextField("", text: $viewModel.verificationCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($isCodeFieldFocused)
                        .opacity(0.01)
                        .frame(width: 1, height: 1)
                        .onChange(of: viewModel.verificationCode) { _, newValue in

                            let filtered = newValue.filter(\.isNumber)

                            if filtered.count > 6 {
                                viewModel.verificationCode = String(filtered.prefix(6))
                            } else {
                                viewModel.verificationCode = filtered
                            }

                            if viewModel.verificationCode.count == 6 {
                                isCodeFieldFocused = false
                            }
                        }

                    HStack(spacing: 12) {

                        ForEach(0..<6, id: \.self) { index in

                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    index == viewModel.verificationCode.count
                                    ? Color.black
                                    : Color.gray.opacity(0.3),
                                    lineWidth: 1.5
                                )
                                .frame(width: 48, height: 58)
                                .overlay {

                                    if index < viewModel.verificationCode.count {

                                        let chars = Array(viewModel.verificationCode)

                                        Text(String(chars[index]))
                                            .font(.system(size: 24, weight: .semibold))
                                    }
                                }
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isCodeFieldFocused = true
                }

                Text("이메일로 전송된 인증번호를 입력해주세요.")
                    .font(.custom("Pretendard-Regular", size: 13))
                    .foregroundColor(.gray)

                if let message = viewModel.errorMessage {
                    Text(message)
                        .font(.custom("Pretendard-Regular", size: 13))
                        .foregroundStyle(.red)
                }
            }

            Button {

                viewModel.verifyCode()

            } label: {

                Text("인증하기")
                    .font(.custom("Pretendard-SemiBold", size: 16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        viewModel.canVerify
                        ? Color.black
                        : Color.gray.opacity(0.35)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!viewModel.canVerify)
        }
        .padding(.top, 32)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isCodeFieldFocused = true
            }
        }
    }
}


private extension PasswordChangeView {

    var passwordView: some View {
        VStack(alignment: .leading, spacing: 24) {

            VStack(alignment: .leading, spacing: 8) {

                Text("새 비밀번호")
                    .font(.custom("Pretendard-SemiBold", size: 15))
                    .foregroundColor(.black)

                SecureField("새 비밀번호를 입력해주세요.", text: $viewModel.newPassword)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("영문과 숫자를 포함해 10자 이상 입력해주세요.")                    .font(.custom("Pretendard-Regular", size: 13))
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 8) {

                Text("새 비밀번호 확인")
                    .font(.custom("Pretendard-SemiBold", size: 15))
                    .foregroundColor(.black)

                SecureField("비밀번호를 다시 입력해주세요.", text: $viewModel.confirmPassword)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if !viewModel.confirmPassword.isEmpty {

                    Text(
                        viewModel.isPasswordMatched
                        ? "비밀번호가 일치합니다."
                        : "비밀번호가 일치하지 않습니다."
                    )
                    .font(.custom("Pretendard-Regular", size: 13))
                
                    .foregroundStyle(
                        viewModel.isPasswordMatched
                        ? .green
                        : .red
                    )
                }
            }

            if viewModel.canComplete {

                Button {

                    viewModel.complete {
                        dismiss()
                    }

                } label: {

                    Text("비밀번호 변경")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
          
        }
        .padding(.top, 32)
    }
}



#Preview {
    NavigationStack {
        PasswordChangeView()
    }
}
