
import SwiftUI

struct AgreeView: View {
    
    @EnvironmentObject private var router: AuthRouter
    @State private var viewModel = AgreeViewModel()
    
    // 선택된 TermsPage
    @State private var selectedTermsPage: TermsPage?
    
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
                        onToggle: { viewModel.toggleAllAgree() },
                        onTitleTap: nil
                    )
                    .padding(.bottom, 6)
                    
                    Divider()
                        .padding(.bottom, 6)
                    
                    VStack(spacing: 0) {
                        AgreeCheckRow(
                            title: "만 14세 이상입니다. (필수)",
                            isChecked: $viewModel.isOver14,
                            onToggle: { viewModel.toggleOver14() },
                            onTitleTap: nil
                        )
                        
                        AgreeCheckRow(
                            title: "서비스 이용약관에 동의 (필수)",
                            isChecked: $viewModel.isServiceAgree,
                            onToggle: { viewModel.toggleServiceAgree() },
                            onTitleTap: { selectedTermsPage = .service }
                        )
                        
                        AgreeCheckRow(
                            title: "개인정보 수집 및 이용에 동의 (필수)",
                            isChecked: $viewModel.isPrivacyAgree,
                            onToggle: { viewModel.togglePrivacyAgree() },
                            onTitleTap: { selectedTermsPage = .privacy }
                        )
                        
                        AgreeCheckRow(
                            title: "광고 및 마케팅 수신에 동의 (선택)",
                            isChecked: $viewModel.isMarketingAgree,
                            onToggle: { viewModel.toggleMarketingAgree() },
                            onTitleTap: { selectedTermsPage = .marketing }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomButton
        }
        .navigationBarBackButtonHidden(true)
        // selectedTermsPage가 바뀌면 사파리 페이지 열기
        // SafariView에 url은 TermsPage 열거형에 정의해둔 notion page url 연결
        .sheet(item: $selectedTermsPage) { page in
            SafariView(url: page.url)
        }
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
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 17)
                    .padding(.top, 16)
            }
            .disabled(!viewModel.isNextEnabled)
        }
        .background(Color.white)
    }
}

// MARK: 약관 정책 notion url
private enum TermsPage: Identifiable {
    case service // 서비스 이용 약관
    case privacy // 개인정보처리방침
    case marketing // 광고 및 마케팅 정보 수신 동의

    var id: Self { self }

    var url: URL {
        switch self {
        case .service:
            return URL(string: "https://troubled-parmesan-24d.notion.site/37e3dc31532c80b19ca9d940eb648de6?source=copy_link")!
        case .privacy:
            return URL(string: "https://troubled-parmesan-24d.notion.site/3853dc31532c806f838cf3fa5347fe7d?source=copy_link")!
        case .marketing:
            return URL(string: "https://troubled-parmesan-24d.notion.site/3853dc31532c80069babe191e0f9d212?source=copy_link")!
        }
    }
}

private struct AgreeCheckRow: View {
    let title: String
    @Binding var isChecked: Bool
    let onToggle: () -> Void
    let onTitleTap: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                onToggle()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(isChecked ? Color.main400 : Color.grey300)
            }.buttonStyle(.plain)
            
            Button {
                if let onTitleTap {
                    onTitleTap()
                } else {
                    onToggle()
                }
            } label: {
                    Text(title)
                        .underline(onTitleTap != nil)
                        .font(.PretendardRegular16)
                        .foregroundStyle(Color.black)
            }.buttonStyle(.plain)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
}
