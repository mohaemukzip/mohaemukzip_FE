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
