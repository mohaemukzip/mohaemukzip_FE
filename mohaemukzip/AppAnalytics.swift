//
//  AppAnalytics.swift
//  mohaemukzip
//
//  Created by 이한결 on 11/1/26.
//

import Foundation
import FirebaseAnalytics

// Firebase Analytics 집계 함수
enum AppAnalytics {
    static func logButton(
        _ screen: String,
        _ button: String,
        details: [String: Any] = [:]
    ) {
        var parameters = details
        parameters["화면"] = screen
        parameters["버튼"] = button
        
        Analytics.logEvent("버튼클릭", parameters: parameters)
    }
    
    static func logSuccess(
        _ screen: String,
        _ action: String,
        details: [String: Any] = [:]
    ) {
        var parameters = details
        parameters["화면"] = screen
        parameters["작업"] = action
        
        Analytics.logEvent("작업성공", parameters: parameters)
    }
}
