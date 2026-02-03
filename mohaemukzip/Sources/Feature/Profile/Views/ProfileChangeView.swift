//
//  ProfileChangeView.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/3/26.
//

import SwiftUI

//
//  ProfileChangeView.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/3/26.
//

import SwiftUI

// MARK: - Notification

extension Notification.Name {
    static let profileNicknameUpdated = Notification.Name("profileNicknameUpdated")
}

// MARK: - View

struct ProfileChangeView: View {

    // MARK: - Properties

    @Environment(NavigationRouter.self) private var router

    /// 서버에서 받아온 기존 닉네임(지금은 캐시/기본값으로 사용)
    private let originalNickname: String

    @State private var nickname: String
    @FocusState private var isNicknameFocused: Bool

    // MARK: - Init

    init(originalNickname: String? = nil) {
        let cached = UserDefaults.standard.string(forKey: "profile_cached_nickname")
        let base = (originalNickname?.isEmpty == false) ? originalNickname! : (cached?.isEmpty == false ? cached! : "뭐해먹집")
        self.originalNickname = base
        _nickname = State(initialValue: base)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(spacing: 30) {
                avatarSection
                    .padding(.top, 24)

                nicknameFieldSection
                    .padding(.top, 28)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isNicknameFocused = true
            }
        }
        .onChange(of: nickname) { newValue in
            if newValue.count > 15 {
                nickname = String(newValue.prefix(15))
            }
        }
    }
}

// MARK: - Subviews

private extension ProfileChangeView {

    var header: some View {
        HStack(spacing: 8) {
            Button {
                router.pop()
            } label: {
                Image("backbutton")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .frame(width: 44, height: 44)
            }

            Text("프로필 수정")
                .font(.custom("Pretendard-SemiBold", size: 20))
                .foregroundStyle(Color.black)

            Spacer()

            Button {
                saveAndDismiss()
            } label: {
                Text("확인")
                    .font(.custom("Pretendard-Medium", size: 16))
                    .foregroundColor(.grey600)
                    
                    
                    .padding(.trailing, 6)
                    .frame(height: 44)
            }
            .disabled(!isConfirmEnabled)
        }
        .padding(.horizontal, 5)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    var avatarSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("realprofile")
                .resizable()
                .scaledToFill()
                .frame(width: 84, height: 84)
                .clipShape(Circle())

            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)

                Image(systemName: "camera.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            .overlay {
                Circle()
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            }
            .offset(x: 2, y: 2)
        }
        .frame(maxWidth: .infinity)
    }

    var nicknameFieldSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                TextField("", text: $nickname)
                    .font(.custom("Pretendard-Regular", size: 16))
                    .foregroundStyle(Color.black)
                    .focused($isNicknameFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        if isConfirmEnabled {
                            saveAndDismiss()
                        }
                    }

                Spacer(minLength: 8)

                Text("\(nickname.count)/15")
                    .font(.custom("Pretendard-Regular", size: 14))
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if let message = validationMessage {
                Text(message)
                    .font(.custom("Pretendard-Regular", size: 12))
                    .foregroundStyle(Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Validation & Actions

private extension ProfileChangeView {

    var isConfirmEnabled: Bool {
        isNicknameValid && nickname != originalNickname
    }

    var isNicknameValid: Bool {
        validateNickname(nickname) == nil
    }

    var validationMessage: String? {
        return validateNickname(nickname)
    }

    func validateNickname(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return "닉네임은 1자 이상이어야 해"
        }

        if value.count > 15 {
            return "닉네임은 최대 15자까지 가능해"
        }

        if value.contains("  ") {
            return "연속 공백은 사용할 수 없어"
        }

        let pattern = "^[가-힣A-Za-z0-9 ]+$"
        if value.range(of: pattern, options: .regularExpression) == nil {
            return "한글, 영문, 숫자, 공백만 사용할 수 있어"
        }

        return nil
    }

    func saveAndDismiss() {
        guard isConfirmEnabled else { return }

        UserDefaults.standard.set(nickname, forKey: "profile_cached_nickname")
        NotificationCenter.default.post(name: .profileNicknameUpdated, object: nickname)

        router.pop()
    }
}

#Preview {
    ProfileChangePreviewWrapper()
}

private struct ProfileChangePreviewWrapper: View {
    @State private var router = NavigationRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileChangeView(originalNickname: "뭐해먹집")
                .setupNavigationDestinations()
        }
        .environment(router)
    }
}
