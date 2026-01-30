//
//  SignupView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/28/26.
//

import SwiftUI
import Observation

// MARK: - Model
struct SignupModel: Equatable {
    var nickname: String = ""
    var userId: String = ""
    var password: String = ""
    var passwordConfirm: String = ""
}

// MARK: - ViewModel
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
    var isPasswordMismatch: Bool = false

    func onChangeNickname(_ newValue: String) {
        // 15자 제한
        if newValue.count <= 15 {
            model.nickname = newValue
        } else {
            model.nickname = String(newValue.prefix(15))
        }
    }

    func onChangeUserId(_ newValue: String) {
        // 15자 제한 (15자 넘어가면 더 이상 타이핑 안 되게)
        if newValue.count <= 15 {
            model.userId = newValue
        } else {
            model.userId = String(newValue.prefix(15))
        }
        // 아이디가 바뀌면 중복확인 다시 필요
        idCheckState = .none
    }

    func onChangePassword(_ newValue: String) {
        model.password = newValue
        validatePasswordMatch()
    }

    func onChangePasswordConfirm(_ newValue: String) {
        model.passwordConfirm = newValue
        validatePasswordMatch()
    }

    func checkDuplicateId() {
        guard isValidIdFormat(model.userId) else {
            idCheckState = .invalidFormat
            return
        }

        // 예: "abcde"는 사용 가능, "taken"은 중복, 나머지는 사용 가능 처리
        let lower = model.userId.lowercased()
        if lower == "taken" || lower == "admin" {
            idCheckState = .duplicated
        } else {
            idCheckState = .available
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
        "6~15자 영문, 숫자를 입력해주세요."
    }

    func helperTextForPasswordFormat() -> String {
        "6~20자 영문, 숫자, 특수문자를 입력해주세요."
    }

    private func validatePasswordMatch() {
        guard !model.password.isEmpty || !model.passwordConfirm.isEmpty else {
            isPasswordMismatch = false
            return
        }
        isPasswordMismatch = (!model.passwordConfirm.isEmpty) && (model.password != model.passwordConfirm)
    }

    private func isValidIdFormat(_ text: String) -> Bool {
        // 6~15자 영문/숫자
        let pattern = "^[A-Za-z0-9]{6,15}$"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private func isValidPasswordFormat(_ text: String) -> Bool {
        let pattern = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{6,20}$"
        return text.range(of: pattern, options: .regularExpression) != nil
    }
}

struct SignupView: View {

    @Environment(NavigationRouter.self) private var router
    @State private var viewModel = SignupViewModel()

    var body: some View {
        VStack(spacing: 0) {
            topBar
                VStack(alignment: .leading, spacing: 18) {
                    header
                    nicknameSection
                    idSection
                    passwordSection
                    passwordConfirmSection

                    Spacer(minLength: 24)

                    startButton
                        .padding(.bottom, 38)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        .background(Color.white)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("아이디")
                .font(.PretendardMedium14)
                .foregroundStyle(Color.black.opacity(0.8))

            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.grey700)
                        .frame(height: 44)

                    HStack(spacing: 10) {
                        TextField("아이디를 입력해주세요.", text: Binding(
                            get: { viewModel.model.userId },
                            set: { viewModel.onChangeUserId($0) }
                        ))
                        .textInputAutocapitalization(.never)
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
                    viewModel.checkDuplicateId()
                } label: {
                    Text("중복확인")
                        .font(.PretendardMedium16)
                        .foregroundStyle(.main400)
                        .frame(width: 84, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.main400, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                }
            }

            if let msg = viewModel.idCheckState.message {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.idCheckState.isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
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
            font(.PretendardRegular16)
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
                .padding(.horizontal, 14)
                font(.PretendardRegular16)
            }

            if viewModel.isPasswordMismatch {
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
            router.push(.signupFinish)
        } label: {
            Text("시작하기")
                .font(.PretendardSemibold18 )
                .foregroundStyle(viewModel.isReadyToStart ? Color.white : Color.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 57)
                .background(viewModel.isReadyToStart ? .main400 : .grey400)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(Rectangle())
        }
        .disabled(!viewModel.isReadyToStart)
    }
}

#Preview {
    SignupView()
        .environment(NavigationRouter())
}
