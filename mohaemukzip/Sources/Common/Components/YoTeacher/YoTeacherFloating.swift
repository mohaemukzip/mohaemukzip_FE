import SwiftUI

struct YoTeacherFloating: View {
    var onTap: () -> Void
    
    var body: some View {
        // MARK: - 세부 카테고리 선택 후 요선생 플로팅 버튼
        HStack {
            Spacer()
            VStack {
                Spacer()
                Button( action: { AppAnalytics.logButton("레시피 목록", "요선생 열기", details: ["버튼_위치": "플로팅 버튼"]); onTap() } ) {
                    Image("icon-yoteacher-floating")
                }
            }
        }.padding(.bottom, 25)
            .padding(.trailing, 25)
    }
}

#Preview {
    YoTeacherFloating(onTap: { })
}
