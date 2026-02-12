import SwiftUI
import PhotosUI
import UIKit

struct ProfileChangeView: View {

    // MARK: - Properties

    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: ProfileViewModel

    @State private var originalNickname: String = ""
    @State private var nickname: String = ""
    @State private var didUserEditNickname: Bool = false

    @State private var isSaving: Bool = false

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    @FocusState private var isNicknameFocused: Bool

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
            // ProfileView와 동일하게: 진입 시 서버 프로필을 한 번 보장해서(값이 비어있을 때)
            // 아바타 이미지/닉네임이 즉시 표시되게 함
            let nickEmpty = viewModel.myPage.profile.nickname
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
            let urlEmpty = viewModel.myPage.profile.profileImageUrl
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty

            if nickEmpty || urlEmpty {
                viewModel.fetchMyPage()
            }

            // 이미 값이 있으면 바로 반영
            if !viewModel.myPage.profile.nickname
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty {
                seedNicknameIfNeeded(force: true)
            } else {
                seedNicknameIfNeeded(force: false)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isNicknameFocused = true
            }
        }
        .onChange(of: viewModel.myPage.profile.nickname) { _, _ in
            seedNicknameIfNeeded(force: false)
        }
        .overlay {
            if viewModel.isLoading || isSaving {
                ZStack {
                    Color.black.opacity(0.12).ignoresSafeArea()
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
                            .scaledToFill()
                    } else if
                        !viewModel.myPage.profile.profileImageUrl
                            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        let url = URL(string: viewModel.myPage.profile.profileImageUrl)
                    {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Image("realprofile")
                                    .resizable()
                                    .scaledToFill()
                                    .overlay {
                                        ProgressView()
                                    }

                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFill()

                            case .failure:
                                Image("realprofile")
                                    .resizable()
                                    .scaledToFill()

                            @unknown default:
                                Image("realprofile")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    } else {
                        Image("realprofile")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 120, height: 120)
                .clipped()
                .clipShape(Circle())

                ZStack {
                    Circle().fill(Color.white).frame(width: 30, height: 30)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.gray)
                }
                .overlay {
                    Circle().stroke(Color.gray.opacity(0.25), lineWidth: 1)
                }
                .offset(x: 2, y: 2)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }

            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run { self.selectedImageData = data }
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
                    .onChange(of: nickname) { _, newValue in
                        // 서버 seed로 바뀌는 건 제외하고, 포커스 있을 때만 “유저 편집” 처리
                        if isNicknameFocused { didUserEditNickname = true }

                        if newValue.count > 15 {
                            nickname = String(newValue.prefix(15))
                        }
                    }
                    .onSubmit {
                        if isConfirmEnabled { saveAndDismiss() }
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

            Text(validationMessage ?? "닉네임은 한글/영문/숫자만 입력할 수 있어요")
                .font(.custom("Pretendard-Regular", size: 12))
                .foregroundStyle(validationMessage == nil ? Color.gray : Color.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
    }
}

// MARK: - Validation & Actions

private extension ProfileChangeView {

    var isConfirmEnabled: Bool {
        let nicknameChanged = nickname != originalNickname
        let imageChanged = selectedImageData != nil

        let canSaveNickname = nicknameChanged && isNicknameValid
        return canSaveNickname || imageChanged
    }

    var isNicknameValid: Bool { validateNickname(nickname) == nil }

    var validationMessage: String? { validateNickname(nickname) }

    func validateNickname(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        // 0자(공백만 포함) 입력
        if trimmed.isEmpty { return "닉네임을 1자 이상 입력해 주세요." }
        if trimmed.count > 15 { return "닉네임은 최대 15자까지 가능해" }

        // 공백 불가(한글/영문/숫자만)
        if value.contains(where: { $0.isWhitespace }) {
            return "닉네임은 한글/영문/숫자만 입력할 수 있어요"
        }

        // 한글(완성형 + 자모) / 영문 / 숫자만 허용
        // - "ㅇ" 같은 자모도 허용하기 위해 ㄱ-ㅎ, ㅏ-ㅣ 범위를 포함
        let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣA-Za-z0-9]+$"
        if value.range(of: pattern, options: .regularExpression) == nil {
            return "이모지 및 특수문자 입력 불가"
        }
        return nil
    }

    func seedNicknameIfNeeded(force: Bool) {
        let fetched = viewModel.myPage.profile.nickname
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 서버 닉네임이 오기 전에는 하드코딩으로 잠그지 않음
        guard !fetched.isEmpty else { return }

        if force || originalNickname.isEmpty { originalNickname = fetched }

        if force || (!didUserEditNickname && nickname != fetched) {
            nickname = fetched
        }
    }

    func saveAndDismiss() {
        guard isConfirmEnabled, !isSaving, !viewModel.isLoading else { return }

        isSaving = true
        print("[ProfileChangeView] ✅ save START | nicknameChanged=\(nickname != originalNickname), imageChanged=\(selectedImageData != nil)")

        let nicknameChanged = nickname != originalNickname
        let imageToSend = selectedImageData

        //  요청 바디는 변경된 값만 포함
        // - 닉네임만 변경: nickname만 전송
        // - 이미지만 변경: nickname은 nil (전송 안 함)
        // - 둘 다 변경: nickname + imageData 전송
        let nicknameToSend: String? = {
            guard nicknameChanged else { return nil }
            guard isNicknameValid else { return nil }
            return nickname
        }()

        viewModel.updateProfile(nickname: nicknameToSend, imageData: imageToSend) { result in
            DispatchQueue.main.async {
                self.isSaving = false

                switch result {
                case .success:
                    viewModel.fetchMyPage()
                    router.pop()
                    dismiss()

                case let .failure(error):
                    print("[ProfileChangeView] ❌ save FAIL | error=\(error)")
                }
            }
        }
    }
}

