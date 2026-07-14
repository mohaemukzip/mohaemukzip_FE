
import SwiftUI

@Observable
final class AgreeViewModel {
    
    private let authService = AuthService()
    var isSubmitting: Bool = false

    // 필수
    var isOver14: Bool = false
    var isServiceAgree: Bool = false
    var isPrivacyAgree: Bool = false

    // 선택
    var isMarketingAgree: Bool = false

    // 모두 동의
    var isAllAgree: Bool = false

    var isNextEnabled: Bool {
        isOver14 && isServiceAgree && isPrivacyAgree && !isSubmitting
    }

    // MARK: - Toggle Actions

    func toggleAllAgree() {
        isAllAgree.toggle()
        let value = isAllAgree
        isOver14 = value
        isServiceAgree = value
        isPrivacyAgree = value
        isMarketingAgree = value
    }

    func toggleOver14() {
        isOver14.toggle()
        syncAllAgree()
    }

    func toggleServiceAgree() {
        isServiceAgree.toggle()
        syncAllAgree()
    }

    func togglePrivacyAgree() {
        isPrivacyAgree.toggle()
        syncAllAgree()
    }

    func toggleMarketingAgree() {
        isMarketingAgree.toggle()
        syncAllAgree()
    }

    private func syncAllAgree() {
        // 4개가 모두 true일 때만 "모두 동의" true
        isAllAgree = isOver14 && isServiceAgree && isPrivacyAgree && isMarketingAgree
    }
    
    @MainActor
    func submitAgreement(terms: [SignUpTermDTO], token: String) async -> Bool {
        guard !isSubmitting else { return false }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            return try await authService.submitTermsAgreement(terms: terms, token: token)
        } catch {
            print("약관 여부 제출 실패")
            return false
        }
    }
}

