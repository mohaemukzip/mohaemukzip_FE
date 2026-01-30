//
//  AgreeView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/28/26.
//

import SwiftUI

struct AgreeView: View {

    @Environment(NavigationRouter.self) var router
    @State private var viewModel = AgreeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("서비스 이용약관")
                        .font(.PretendardSemibold24)
                        .foregroundStyle(.black)
                        .padding(.top, 21)
                        .padding(.bottom, 10)

                    AgreeCheckRow(
                        title: "모두 동의",
                        isChecked: $viewModel.isAllAgree,
                        onToggle: { viewModel.toggleAllAgree() }
                    )
                    .padding(.bottom, 6)

                    Divider()
                        .padding(.bottom, 6)

                    VStack(spacing: 0) {
                        AgreeCheckRow(
                            title: "만 14세 이상입니다. (필수)",
                            isChecked: $viewModel.isOver14,
                            onToggle: { viewModel.toggleOver14() }
                        )

                        AgreeCheckRow(
                            title: "서비스 이용약관에 동의 (필수)",
                            isChecked: $viewModel.isServiceAgree,
                            onToggle: { viewModel.toggleServiceAgree() }
                        )

                        AgreeCheckRow(
                            title: "개인정보 수집 및 이용에 동의 (필수)",
                            isChecked: $viewModel.isPrivacyAgree,
                            onToggle: { viewModel.togglePrivacyAgree() }
                        )

                        AgreeCheckRow(
                            title: "광고 및 마케팅 수신에 동의 (선택)",
                            isChecked: $viewModel.isMarketingAgree,
                            onToggle: { viewModel.toggleMarketingAgree() }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }

            bottomButton
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
    }

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

    private var bottomButton: some View {
        VStack(spacing: 0) {
            Button {
                router.push(.signup)
            } label: {
                Text("다음")
                    .font(.PretendardSemibold18)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(viewModel.isNextEnabled ? Color.main400 : Color.grey300)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 17)
                    .padding(.vertical, 16)
            }
            .disabled(!viewModel.isNextEnabled)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden()
    }
}

private struct AgreeCheckRow: View {
    let title: String
    @Binding var isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(isChecked ? Color.main400 : Color.grey300)

                Text(title)
                    .font(.PretendardRegular16)
                    .foregroundStyle(Color.black)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AgreeView()
        .environment(NavigationRouter())
}
