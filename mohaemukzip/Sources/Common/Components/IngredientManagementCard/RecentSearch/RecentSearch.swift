import SwiftUI

struct RecentSearch: View {
    let text: String
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button ( action: { AppAnalytics.logButton("재료 검색", "최근 검색어 선택"); onTap() } ) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .strokeBorder(.grey300, lineWidth: 1)
                    .frame(height: 32)
                
                HStack {
                    Text(text)
                        .font(.PretendardRegular16)
                        .foregroundStyle(.grey700)
                    
                    Button( action: { AppAnalytics.logButton("재료 검색", "최근 검색어 삭제"); onDelete() } ) {
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

