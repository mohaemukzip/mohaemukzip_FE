//
//  AccountSettings.swift
//  mohaemukzip
//
//  Created by 고석현 on 6/25/26.
//

import SwiftUI
import Combine

// MARK: - Model
/// 서버에서 내려올 로그인 타입 정의
enum LoginType: String {
    case general = "GENERAL"
    case kakao = "KAKAO"
    case apple = "APPLE"
}

/// 계정 정보 모델
struct AccountInfo {
    var email: String?
    var loginType: LoginType
}


// MARK: - ViewModel
class AccountSettingsViewModel: ObservableObject {
    @Published var accountInfo: AccountInfo?
    
    // API 통신 전이므로 임시 데이터로 초기화
    init() {
        fetchAccountSetting()
    }
    
    func fetchAccountSetting() {
        ProfileService.shared.getAccountSetting { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let loginType = LoginType(rawValue: response.loginType) ?? .general

                    self?.accountInfo = AccountInfo(
                        email: response.email,
                        loginType: loginType
                    )

                case .failure(let error):
                    print("계정 설정 조회 실패:", error)
                }
            }
        }
    }
    /// 이메일 영역에 표시할 텍스트
    /// 이메일 영역에 표시할 텍스트
    var displayEmailText: String {
        accountInfo?.email ?? "정보를 불러오는 중..."
    }
    /// 비밀번호 변경 버튼 활성화 여부 (GENERAL일 때만 true)
    var isPasswordChangeEnabled: Bool {
        return accountInfo?.loginType == .general
    }
    
    /// 소셜 로그인일 경우 하단에 띄워줄 안내 문구
    /// 로그인 타입에 따른 안내 문구
    var socialLoginHelperText: String? {
        guard let type = accountInfo?.loginType else { return nil }

        switch type {
        case .general:
            return "소셜 로그인이 아닌 일반 계정이에요."
        case .kakao:
            return "카카오로 가입한 계정이에요."
        case .apple:
            return "애플로 가입한 계정이에요."
        }
    }
}


// MARK: - View
struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss // 뒤로가기 액션을 위해
    @StateObject private var viewModel = AccountSettingsViewModel()
    
    var body: some View {
        VStack(spacing: 0) { // alignment 제거 (헤더 꽉 차게)
            // 1. ProfileSettingsView와 완벽히 통일된 네비게이션 바
            header
            
            // 본문 컨텐츠 영역
            VStack(alignment: .leading, spacing: 0) {
                // 2. 이메일 영역
                emailSection
                    .padding(.bottom, 40)
                
                // 3. 비밀번호 영역
                passwordSection
                
                Spacer()
            }
            .padding(.top, 24) // 헤더와 본문 사이의 적절한 여백
            .padding(.horizontal, 20) // 본문에만 좌우 패딩 적용
        }
        .navigationBarBackButtonHidden(true) // 기본 네비게이션 바 숨김
    }
    
    // MARK: - View Components
    
    private var header: some View {
        HStack(spacing: 8) {
            Button {
                dismiss() // 라우터 pop 또는 dismiss
            } label: {
                // 이전 뷰와 동일한 에셋 및 크기 적용
                Image("backbutton")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .frame(width: 44, height: 44)
            }
            
            Text("계정 설정")
                .font(.custom("Pretendard-SemiBold", size: 20))
                .foregroundStyle(Color.black)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Color.white) // 배경색 통일
    }
    
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("이메일")
                .font(.custom("Pretendard-SemiBold", size: 18))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.displayEmailText)
                    .font(.custom("Pretendard-Medium", size: 16))
                    .foregroundColor(.black)
                
                // 피그마 밑줄 코드 적용 (가로 꽉 차게)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .background(Color(red: 0.59, green: 0.58, blue: 0.58))
            }
            
            if let helperText = viewModel.socialLoginHelperText {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(helperText)
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.top, -4)
            }
        }
    }
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("비밀번호")
                .font(.custom("Pretendard-SemiBold", size: 18))
                .foregroundColor(.black)
            
            Button(action: {
                // TODO: 비밀번호 변경 화면으로 이동
                print("비밀번호 변경 화면으로 이동")
            }) {
                Text("비밀번호 변경")
                    .font(.custom("Pretendard-SemiBold", size: 16))
                    .foregroundColor(viewModel.isPasswordChangeEnabled ? .white : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.isPasswordChangeEnabled ? Color.black : Color(hex: "C4C4C4"))
                    .cornerRadius(8)
            }
            .disabled(!viewModel.isPasswordChangeEnabled)
        }
    }
}

// 스크린샷의 회색을 표현하기 위한 Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

// 프리뷰
struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
    }
}
