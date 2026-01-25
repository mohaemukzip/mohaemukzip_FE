//
//  SearchSuggestion.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/25/26.
//

import SwiftUI

struct SearchSuggestion: View {
    let inputText: String
    let suggestionText: String
    
    private var highlightedText: AttributedString {
        var attributedString = AttributedString(suggestionText)
        attributedString.font = .PretendardRegular16
        attributedString.foregroundColor = .grey900
        
        // MARK: - 연관검색어 중 inputText 찾아서 색깔 다르게
        if !inputText.isEmpty {
            if let range = attributedString.range(of: inputText, options: [.caseInsensitive, .diacriticInsensitive]) {
                attributedString[range].foregroundColor = .main400
            }
        }
        
        return attributedString
    }
    
    var body: some View {
        VStack(spacing: 13) {
            HStack {
                Image("icon-search")
                    .foregroundStyle(.grey400)
                Text(highlightedText)
                    .font(.PretendardRegular16)
                Spacer()
            }
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.grey200)
        }
    }
}

#Preview {
    SearchSuggestion(inputText: "김", suggestionText: "김칫국")
}
