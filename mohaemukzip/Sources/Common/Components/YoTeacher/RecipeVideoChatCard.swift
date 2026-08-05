import SwiftUI

struct RecipeVideoChatCard: View {
    let url: URL
    let videoTime: String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
            
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .foregroundStyle(.grey600)
                    .frame(height: 18)
                    .frame(maxWidth: 36)
                    .opacity(0.8)
                Text(videoTime)
                    .foregroundStyle(.white)
                    .font(.PretendardMedium12)
            }.padding(.trailing, 8)
                .padding(.bottom, 7)
            
        }
    }
}

#Preview {
    RecipeVideoChatCard(
        url: URL(string: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg")!,
        videoTime: "10:54"
    )
}
