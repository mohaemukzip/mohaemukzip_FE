import SwiftUI

enum ButtonSize {
    case big
    case small
}

struct OrangeButton: View {
    let text: String
    let size: ButtonSize
    
    var body: some View {
        switch size {
        case .big:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.main400)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text(text)
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold18)
            }
        case .small:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.main400)
                    .frame(width: 150, height: 46)
                Text(text)
                    .foregroundStyle(.white)
                    .font(.PretendardSemibold16)
            }
        }
    }
}

#Preview {
    OrangeButton(text: "시작하기", size: .small)
}
