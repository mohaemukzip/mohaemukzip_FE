//
//  RecipeVideoChatCard.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/25/26.
//

import SwiftUI

struct RecipeVideoChatCard: View {
    let url: URL
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 96)
                .cornerRadius(4)
                .clipped()
        } placeholder: {
            YoSkeleton()
        }
    }
}

#Preview {
    RecipeVideoChatCard(url: URL(string: "https://i.ytimg.com/vi/L4NreAnu6a0/mqdefault.jpg")!)
    
}
