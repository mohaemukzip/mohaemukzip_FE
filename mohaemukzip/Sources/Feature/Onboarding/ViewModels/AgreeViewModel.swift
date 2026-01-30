//
//  AgreeViewModel.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/28/26.
//

import SwiftUI

@Observable
final class AgreeViewModel {

    // 필수
    var isOver14: Bool = false
    var isServiceAgree: Bool = false
    var isPrivacyAgree: Bool = false

    // 선택
    var isMarketingAgree: Bool = false

    // 모두 동의
    var isAllAgree: Bool = false

    var isNextEnabled: Bool {
        isOver14 && isServiceAgree && isPrivacyAgree
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
}

