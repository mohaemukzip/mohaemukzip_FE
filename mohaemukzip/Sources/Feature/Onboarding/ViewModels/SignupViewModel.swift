
import SwiftUI

@Observable
final class SignupViewModel {

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

    func onChangeUserId(_ newValue: String) {
        // 15자 제한
        let limited: String
        if newValue.count <= 15 {
            limited = newValue
        } else {
            limited = String(newValue.prefix(15))
        }

        // 같은 값이 다시 들어오면(예: 다른 필드 입력/리렌더링 과정에서 onChange가 호출됨)
        // 중복확인 상태를 초기화하지 않는다.
        guard limited != model.userId else { return }

        model.userId = limited

        // 아이디가 실제로 변경되었을 때만 중복확인 다시 필요
        idCheckState = .none
        idCheckMessage = nil
    }

    func onChangePassword(_ newValue: String) {
        model.password = newValue
        validatePasswordMatch()
    }

    func onChangePasswordConfirm(_ newValue: String) {
        model.passwordConfirm = newValue
        validatePasswordMatch()
    }

    @MainActor
    func checkDuplicateId() async {
        guard isValidIdFormat(model.userId) else {
            idCheckState = .invalidFormat
            idCheckMessage = nil
            return
        }

        isCheckingId = true
        defer { isCheckingId = false }

        do {
            let result = try await authService.checkLoginId(loginId: model.userId)
            idCheckMessage = result.message
            idCheckState = result.available ? .available : .duplicated
            errorMessage = nil
        } catch {
            idCheckState = .none
            idCheckMessage = "아이디 중복확인에 실패했어요. 다시 시도해 주세요."
            errorMessage = nil
        }
    }

    var nicknameCountText: String {
        "\(model.nickname.count)/15"
    }

    var userIdCountText: String {
        "\(model.userId.count)/15"
    }

    var isValidNickname: Bool {
        !model.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isValidPassword: Bool {
        isValidPasswordFormat(model.password)
    }

    var isReadyToStart: Bool {
        isValidNickname
        && idCheckState == .available
        && isValidPassword
        && !isPasswordMismatch
        && !model.passwordConfirm.isEmpty
    }

    func helperTextForIdFormat() -> String {
        "아이디는 영문과 숫자를 사용해 4자 이상 입력해주세요."
    }

    func helperTextForPasswordFormat() -> String {
        "6~20자 영문, 숫자, 특수문자로 입력해주세요."
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

    private func isValidPasswordFormat(_ text: String) -> Bool {
        let pattern = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{6,20}$"
        return text.range(of: pattern, options: .regularExpression) != nil
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
                loginId: model.userId,
                password: model.password,
                terms: terms
            )
            tokens = model
            Config.accessTK = model.accessToken
            errorMessage = nil
            return true
        } catch {
            errorMessage = "회원가입에 실패했어요."
            return false
        }
    }
}
