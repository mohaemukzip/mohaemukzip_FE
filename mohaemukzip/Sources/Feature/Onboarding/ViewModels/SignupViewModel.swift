
import SwiftUI

@Observable
final class SignupViewModel {
    
    // 이메일 유효성 검증상태
    enum EmailVerificationState: Equatable {
        case idle
        case invalidFormat
        case codeSent
        case invalidCode
        case verified
        case expired
    }
    
    var emailVerificationState: EmailVerificationState = .idle
    
    var remainingSeconds = 180
    
    private var verificationTimerTask: Task<Void, Never>?
    
    var verificationTimeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var canVerifyCode: Bool {
        model.verificationCode.count == 6
            && remainingSeconds > 0
            && emailVerificationState != .verified
    }
    
    func startVerificationTimer() {
        verificationTimerTask?.cancel()
        remainingSeconds = 180
        
        verificationTimerTask = Task { @MainActor [weak self] in
            while let self, remainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))

                guard !Task.isCancelled else { return }

                remainingSeconds -= 1
            }

            if !Task.isCancelled {
                self?.emailVerificationState = .expired
            }
        }
    }
    
    func stopVerificationTimer() {
        verificationTimerTask?.cancel()
        verificationTimerTask = nil
    }
    
    enum PasswordValidationState: Equatable {
        case empty
        case tooShort
        case tooLong
        case containsWhitespace
        case containsInvalidCharacter
        case missingLetter
        case missingNumber
        case missingSpecialCharacter
        case valid

        var message: String {
            switch self {
            case .empty:
                return ""
            case .tooShort:
                return "비밀번호는 6자 이상 입력해주세요."
            case .tooLong:
                return "비밀번호는 20자 이하로 입력해주세요."
            case .containsWhitespace:
                return "공백은 사용할 수 없습니다."
            case .containsInvalidCharacter:
                return "사용할 수 없는 문자가 포함되어 있습니다."
            case .missingLetter:
                return "영문을 포함하여 입력해주세요."
            case .missingNumber:
                return "숫자를 포함하여 입력해주세요."
            case .missingSpecialCharacter:
                return "특수문자를 포함하여 입력해주세요."
            case .valid:
                return "사용 가능한 비밀번호입니다."
            }
        }

        var isError: Bool {
            self != .empty && self != .valid
        }
    }

    enum IdCheckState: Equatable {
        case none
        case invalidFormat
        case duplicated
        case available

        var message: String? {
            switch self {
            case .none: return nil
            case .invalidFormat: return "아이디 형식이 올바르지 않아요."
            case .duplicated: return "이미 사용 중인 아이디예요. 다른 아이디를 입력해 주세요."
            case .available: return "사용 가능한 아이디예요."
            }
        }

        var isError: Bool {
            switch self {
            case .invalidFormat, .duplicated:
                return true
            default:
                return false
            }
        }

        var isSuccess: Bool {
            self == .available
        }
    }

    var model: SignupModel = .init()

    // UI State
    var idCheckState: IdCheckState = .none
    var idCheckMessage: String? = nil
    var isCheckingId: Bool = false
    var isPasswordMismatch: Bool = false

    // API
    private let authService = AuthService()
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var tokens: AuthTokensModel? = nil

    func onChangeNickname(_ newValue: String) {
        // 15자 제한
        if newValue.count <= 15 {
            model.nickname = newValue
        } else {
            model.nickname = String(newValue.prefix(15))
        }
    }
    
    // 이메일에 새로운 값이 들어올 때
    func onChangeEmail(_ newValue: String) {
        guard newValue != model.email else { return }
        
        stopVerificationTimer()
        
        model.email = newValue
        model.verificationCode = ""
        remainingSeconds = 180 
        emailVerificationState = .idle
    }
    
    // 이메일 유효성 검증 코드가 바뀔 때
    func onChangeVerificationCode(_ newValue: String) {
        model.verificationCode = String(newValue.prefix(6))
    }
    
    // 이메일 형식이 올바른지
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return model.email.range(of: pattern, options: .regularExpression) != nil
    }
    
    var shouldShowVerificationField: Bool {
        switch emailVerificationState {
        case .codeSent, .invalidCode, .verified, .expired:
            return true
        default:
            return false
        }
    }
    
    func onChangePassword(_ newValue: String) {
        model.password = newValue
        validatePasswordMatch()
    }

    func onChangePasswordConfirm(_ newValue: String) {
        model.passwordConfirm = newValue
        validatePasswordMatch()
    }
    
    var nicknameCountText: String {
        "\(model.nickname.count)/15"
    }
    
    var isValidNickname: Bool {
        !model.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isReadyToStart: Bool {
        isValidNickname
        && emailVerificationState == .verified
        && isValidPassword
        && !isPasswordMismatch
        && !model.passwordConfirm.isEmpty
    }

    func helperTextForIdFormat() -> String {
        "아이디는 영문과 숫자를 사용해 4자 이상 입력해주세요."
    }

    private func validatePasswordMatch() {
        guard !model.password.isEmpty || !model.passwordConfirm.isEmpty else {
            isPasswordMismatch = false
            return
        }
        isPasswordMismatch = (!model.passwordConfirm.isEmpty) && (model.password != model.passwordConfirm)
    }

    private func isValidIdFormat(_ text: String) -> Bool {
        // 영문/숫자, 4자 이상
        let pattern = "^[A-Za-z0-9]{4,}$"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    var passwordValidationState: PasswordValidationState {
        validatePassword(model.password)
    }

    var isValidPassword: Bool {
        passwordValidationState == .valid
    }

    private func validatePassword(_ password: String) -> PasswordValidationState {
        if password.isEmpty {
            return .empty
        }

        if password.count < 6 {
            return .tooShort
        }

        if password.count > 20 {
            return .tooLong
        }

        if password.contains(where: { $0.isWhitespace }) {
            return .containsWhitespace
        }

        guard password.range(of: "[A-Za-z]", options: .regularExpression) != nil else {
            return .missingLetter
        }

        guard password.range(of: "[0-9]", options: .regularExpression) != nil else {
            return .missingNumber
        }

        guard password.range(
            of: "[!@#$%^&*()_+\\-=]",
            options: .regularExpression
        ) != nil else {
            return .missingSpecialCharacter
        }

        guard password.range(
            of: "^[A-Za-z0-9!@#$%^&*()_+\\-=]+$",
            options: .regularExpression
        ) != nil else {
            return .containsInvalidCharacter
        }

        return .valid
    }

    @MainActor
    func signup() async -> Bool {
        guard isReadyToStart else { return false }

        isLoading = true
        defer { isLoading = false }

        do {
            let terms: [SignUpTermDTO] = [
                .init(id: 1, isAgreed: true),
                .init(id: 2, isAgreed: true),
                .init(id: 3, isAgreed: true),
                .init(id: 4, isAgreed: false)
            ]

            let model = try await authService.signup(
                nickname: model.nickname,
                loginId: model.email,
                password: model.password,
                terms: terms
            )
            tokens = model
            errorMessage = nil
            return true
        } catch {
            errorMessage = "회원가입에 실패했어요."
            return false
        }
    }
}
