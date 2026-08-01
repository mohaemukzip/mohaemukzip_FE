//
//  ForgotPasswordViewModel.swift
//  mohaemukzip
//
//  Created by 이한결 on 7/31/26.
//

import Foundation

@Observable
class ForgotPasswordViewModel {
    
    var email = ""
    var verificationCode = ""
    var newPassword = ""
    var confirmPassword = ""
    
    // MARK: 이메일 관련
    var emailStatus: EmailStatus = .idle
    
    // 이메일 상태
    enum EmailStatus {
        case idle
        case invalidFormat
        case validFormat
        case checking
        case notFound
        case kakaoUser
        case appleUser
    }
    
    // 인증메일 버튼 활성화
    var canRequestVerificationEmail: Bool {
        emailStatus == .validFormat &&
        emailStatus != .checking &&
        !isRequestEmailVerificationLoading
    }
    
    // 이메일 에러메시지
    var emailErrorMessage: String? {
        switch emailStatus {
        case .notFound:
            return "가입된 계정을 찾을 수 없습니다."
        case .kakaoUser:
            return "카카오로 가입되어 있는 계정입니다."
        case .appleUser:
            return "Apple로 가입되어 있는 계정입니다."
        case .invalidFormat:
            return "올바른 이메일 주소를 입력해주세요."
        default:
            return nil
        }
    }
    
    // 이메일이 쓰일 때마다 상태를 갱신
    func updateEmail(_ value: String) {
        self.email = value
        
        if value.isEmpty { emailStatus = .idle }
        else if !isValidEmail(value) { emailStatus = .invalidFormat }
        else { emailStatus = .validFormat }
    }
    
    // 이메일 형식 검증 함수
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
    
    
    // MARK: 이메일 인증번호 관련
    var verificationCodeStatus: VerificationCodeStatus = .not6yet

    // 인증 코드 상태
    enum VerificationCodeStatus {
        case not6yet
        case lengthIs6
        case notCorrectCode
    }
    
    // 인증 코드 에러메시지
    var verificationCodeErrorMessage: String? {
        switch verificationCodeStatus {
        case .notCorrectCode:
            return "인증번호가 일치하지 않습니다. 다시 입력해주세요."
        default:
            return nil
        }
    }
    
    // 인증번호가 쓰일 때마다 상태를 갱신
    func updateVerificationCode(_ value: String) {
        
        let filteredCode = String(value.filter { $0.isNumber }.prefix(6))
        verificationCode = filteredCode
        
        if filteredCode.count == 6 { verificationCodeStatus = .lengthIs6 }
        else { verificationCodeStatus = .not6yet }
    }
    
    // verificationCodeStatue == .lengthIs6일 떄 인증하기 버튼 활성화
    var canRequestVerificationCode: Bool {
        return self.verificationCodeStatus == .lengthIs6
    }
    
    
    // MARK: 비밀번호 재설정 관련
    
    var newPasswordStatus: NewPasswordStatus = .idle
    var confirmPasswordStatus: ConfirmPasswordStatus = .idle
    
    enum NewPasswordStatus {
        case idle
        case lessThan6
        case moreThan20
        case notContainsNumber
        case notContainsEng
        case notContainsSpecialCharacter
        case validPassword
    }
    
    enum ConfirmPasswordStatus {
        case idle
        case notMatching
        case matching
    }
    
    // 비밀번호 에러 메시지
    var passwordErrorMessage: String? {
        // newPassworErrorMessage를 우선 표시
        
        if let errorMessage = newPasswordErrorMessage {
            return errorMessage
        } else if let errorMessage = confirmPasswordErrorMessage {
            return errorMessage
        } else { return nil }
    }
    
    var newPasswordErrorMessage: String? {
        switch newPasswordStatus {
        case .idle, .validPassword:
            return nil
        default:
            return "영문, 숫자, 특수문자를 모두 포함하여 6~20자로 입력해주세요."
        }
    }
    
    var confirmPasswordErrorMessage: String? {
        // 만약 newPassworErrorMessage가 있다면 newPasswordErrorMessage를 우선 표시
        if newPasswordErrorMessage != nil { return nil }
        
        switch confirmPasswordStatus {
        case .idle, .matching:
            return nil
        case .notMatching:
            return "비밀번호가 일치하지 않습니다. 다시 입력해주세요."
        }
    }
    
    // 갱신 함수
    func updateNewPassword(_ value: String) {
        newPassword = value
        
        if value.isEmpty { newPasswordStatus = .idle }
        else if value.count < 6 { newPasswordStatus = .lessThan6 }
        else if value.count > 20 { newPasswordStatus = .moreThan20 }
        else if !value.contains(where: \.isNumber) { newPasswordStatus = .notContainsNumber }
        else if !value.contains(where: \.isLetter) { newPasswordStatus = .notContainsEng }
        else if !containsSpecialCharacter(value) { newPasswordStatus = .notContainsSpecialCharacter }
        else { newPasswordStatus = .validPassword }
        
        updateConfirmPassword(confirmPassword)
    }
    
    func updateConfirmPassword(_ value: String) {
        confirmPassword = value
        
        if value.isEmpty { confirmPasswordStatus = .idle }
        else if value != newPassword { confirmPasswordStatus = .notMatching }
        else { confirmPasswordStatus = .matching }
    }
    
    var canRequestResetPassword: Bool {
        newPasswordStatus == .validPassword
        && confirmPasswordStatus == .matching
    }
    
    private func containsSpecialCharacter(_ value: String) -> Bool {
        let specialCharacters = "!@#$%^&*()_+-=[]{}|;':\",.<>/?`~"
        return value.contains { specialCharacters.contains($0) }
    }
    
    
    // MARK: api 호출 관련
    private let authService = AuthService()
    
    // Loading
    var isRequestEmailVerificationLoading = false
    
    // 이메일 인증번호 전송
    
    @MainActor
    func requestEmailVerification(email: String) async -> Bool {
        guard !isRequestEmailVerificationLoading else { return false }
        
        isRequestEmailVerificationLoading = true
        defer { isRequestEmailVerificationLoading = false }
        
        do {
            try await authService.requestEmailVerificationToFindPwd(email: email)
            
            return true
        } catch {
            
            /* 서버 에러메시지 받아서 emailErrorMessage에 할당 */
            
            return false
        }
    }
    
    
}


