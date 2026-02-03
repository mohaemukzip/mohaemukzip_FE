//
//  ProfileChangeView.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/3/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct ProfileChangeView: View {

    // MARK: - Properties

    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: ProfileViewModel

    @State private var originalNickname: String = ""
    @State private var nickname: String = ""
    @State private var didUserEditNickname: Bool = false

    @State private var isSaving: Bool = false

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    @FocusState private var isNicknameFocused: Bool

    // MARK: - Init

    /// ProfileView에서 사용 중인 같은 ViewModel 인스턴스를 주입해서 들어오는 화면
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
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
            seedNicknameIfNeeded(force: false)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isNicknameFocused = true
            }
        }
        .onChange(of: viewModel.myPage.profile.nickname) { _ in
            // ProfileView에서 fetchMyPage로 값이 들어오면 초기 닉네임을 채움
            seedNicknameIfNeeded(force: false)
        }
        .onChange(of: nickname) { newValue in
            // 유저가 직접 수정 중이면 서버 값으로 덮어쓰지 않도록 플래그를 올려둠
            if !newValue.isEmpty {
                didUserEditNickname = true
            }

            if newValue.count > 15 {
                nickname = String(newValue.prefix(15))
            }
        }
        .overlay {
            if viewModel.isLoading || isSaving {
                ZStack {
                    Color.black.opacity(0.12)
                        .ignoresSafeArea()

                    ProgressView()
                }
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
                dismiss()
            } label: {
                Image("backbutton")
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
                    .foregroundStyle(
                        isConfirmEnabled ? Color("grey700") : Color("grey700").opacity(0.4)
                    )
                    .padding(.trailing, 10)
                    .frame(height: 44)
            }
            .disabled(!isConfirmEnabled || isSaving || viewModel.isLoading)
        }
        .padding(.horizontal, 5)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    var avatarSection: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                    } else if let url = URL(string: viewModel.myPage.profile.profileImageUrl),
                              !viewModel.myPage.profile.profileImageUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case let .success(image):
                                image
                                    .resizable()

                            default:
                                Image("realprofile")
                                    .resizable()
                            }
                        }
                    } else {
                        Image("realprofile")
                            .resizable()
                    }
                }
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
        .buttonStyle(.plain)
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem else { return }

            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            self.selectedImageData = data
                        }
                        print("[ProfileChangeView] ✅ selectedImage bytes=\(data.count)")
                    }
                } catch {
                    print("[ProfileChangeView] ❌ selectedImage FAIL | error=\(error)")
                }
            }
        }
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
        let nicknameChanged = nickname != originalNickname
        let imageChanged = selectedImageData != nil

        // 닉네임이 바뀌는 경우에만 유효성 통과가 필요
        let canSaveNickname = nicknameChanged && isNicknameValid

        // 이미지만 바뀌어도 저장 가능
        return canSaveNickname || imageChanged
    }

    var isNicknameValid: Bool {
        validateNickname(nickname) == nil
    }

    var validationMessage: String? {
        // 닉네임이 비어있거나(최소 1자), 허용되지 않은 문자가 있으면 메시지 노출
        // 닉네임이 기존과 동일한 건 에러가 아니라 “변경 없음” 상태라 메시지를 띄우지 않아
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

    func seedNicknameIfNeeded(force: Bool) {
        let fetched = viewModel.myPage.profile.nickname
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 서버에서 닉네임이 오기 전엔 빈 값 유지(하드코딩 fallback으로 잠가버리면 이후 갱신이 안 됨)
        guard !fetched.isEmpty else {
            return
        }

        // 최초 원본 닉네임은 서버 값으로만 잡음
        if force || originalNickname.isEmpty {
            originalNickname = fetched
        }

        // 유저가 직접 수정 중이 아니라면 서버 값이 들어오는 순간 텍스트필드를 서버 값으로 채움
        if force || (!didUserEditNickname && nickname != fetched) {
            nickname = fetched
        }
    }

    func saveAndDismiss() {
        guard isConfirmEnabled, !isSaving, !viewModel.isLoading else { return }

        isSaving = true

        let nicknameChanged = nickname != originalNickname
        let imageToSend = selectedImageData

        // 닉네임이 바뀌면 새로운 닉네임을 보냄
        // 이미지만 바뀌는 경우에도 서버 PATCH 바디에 nickname이 필요할 수 있으니 현재 닉네임을 함께 보냄
        let nicknameToSend: String? = {
            guard isNicknameValid else { return nil }

            if nicknameChanged {
                return nickname
            }

            if imageToSend != nil {
                // 이미지 변경만 해도 PATCH 바디에 nickname 포함
                return nickname
            }

            return nil
        }()

        print("[ProfileChangeView] ✅ save START | nicknameChanged=\(nicknameToSend != nil), imageChanged=\(imageToSend != nil)")

        viewModel.updateProfile(nickname: nicknameToSend, imageData: imageToSend) { result in
            DispatchQueue.main.async {
                self.isSaving = false

                switch result {
                case .success:
                    print("[ProfileChangeView] ✅ save SUCCESS")

                    // 저장 성공 직후 마이페이지를 다시 불러와서 이전 화면(ProfileView)에서 즉시 변경사항이 보이게 해
                    viewModel.fetchMyPage()

                    // ProfileView로 자동 복귀
                    router.pop()
                    dismiss()

                case let .failure(error):
                    print("[ProfileChangeView] ❌ save FAIL | error=\(error)")
                }
            }
        }
    }
}

#Preview {
    ProfileChangePreviewWrapper()
}

private struct ProfileChangePreviewWrapper: View {
    @State private var router = NavigationRouter()
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileChangeView(viewModel: vm)
                .setupNavigationDestinations()
        }
        .environment(router)
    }
}
