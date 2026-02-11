import SwiftUI

struct RecentSearch: View {
    let text: String
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button ( action: { onTap() } ) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.grey300)
                    .frame(height: 32)
                
                HStack {
                    Text(text)
                        .font(.PretendardRegular16)
                        .foregroundStyle(.grey700)
                    
                    Button( action: { onDelete() } ) {
                        Image("icon-x")
                            .foregroundStyle(.grey700)
                    }
                }.padding(.horizontal, 10)
            }
        }.fixedSize()
            .buttonStyle(.plain)
    }
}

#Preview {
    RecentSearch(text: "대파", onTap: {print("")}, onDelete: {print("")})
}

