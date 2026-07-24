import SwiftUI

struct ProfileSettingsView: View {

    @Environment(NavigationRouter.self) private var router

    @EnvironmentObject private var appState: AppState

    @State private var isPerformingAuthAction: Bool = false
    @State private var showLogoutConfirm: Bool = false
    @State private var showWithdrawalConfirm: Bool = false

    private let appVersionText: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "v.\(version) (\(build))"
    }()

    var body: some View {
        ZStack {


            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 16) {
                        accountSection
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 8)
                            .padding(.top, 14)
                            .padding(.horizontal, -16)
                            
                        actionSection
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("로그아웃", isPresented: $showLogoutConfirm) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                Task { @MainActor in
                    isPerformingAuthAction = true
                    defer { isPerformingAuthAction = false }

                    print("[ProfileSettingsView] logout -> confirm")
                    await appState.logout()
                }
            }
        } message: {
            Text("정말 로그아웃할까요?")
        }
        .alert("회원탈퇴", isPresented: $showWithdrawalConfirm) {
            Button("취소", role: .cancel) {}
            Button("회원탈퇴", role: .destructive) {
                Task { @MainActor in
                    isPerformingAuthAction = true
                    defer { isPerformingAuthAction = false }

                    print("[ProfileSettingsView] withdrawal -> confirm")
                    await appState.withdrawal()
                }
            }
        } message: {
            Text("탈퇴하면 계정 정보가 삭제될 수 있어요. 계속할까요?")
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button {
                router.pop()
            } label: {
                Image("backbutton")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .frame(width: 44, height: 44)
            }

            Text("설정")
                .font(.custom("Pretendard-SemiBold", size: 20))
                .foregroundStyle(Color.black)

            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Color.white)
    }

    // MARK: - Sections

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("계정")
                .font(.custom("Pretendard-SemiBold", size: 16))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

            settingsRow(
                title: "계정 설정",
                showsChevron: true
            ) {
                router.push(.accountSettings)
                //계정 설정 변경 화면으로 push
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            settingsRow(title: "로그아웃", showsChevron: false) {
                guard !isPerformingAuthAction else {
                    print("[ProfileSettingsView] logout ignored (busy)")
                    return
                }
                showLogoutConfirm = true
            }

       

            settingsRow(title: "회원탈퇴", showsChevron: false, titleColor: .black) {
                guard !isPerformingAuthAction else {
                    print("[ProfileSettingsView] withdrawal ignored (busy)")
                    return
                }
                showWithdrawalConfirm = true
            }

            Text(appVersionText)
                .font(.custom("Pretendard-Regular", size: 14))
                .foregroundStyle(Color.gray)
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 14)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Components

    private func settingsRow(
        title: String,
        showsChevron: Bool,
        titleColor: Color = .black,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.custom("Pretendard-Regular", size: 16))
                    .foregroundStyle(titleColor)

                Spacer()

                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .disabled(isPerformingAuthAction)
        .buttonStyle(.plain)
    }
}
