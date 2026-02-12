import SwiftUI

struct RequestBottomSheet: View {
    @State var text: String = ""
    @Binding var isShowingSheet: Bool
    var onRequest: (String) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("어떤 재료를 찾고 계신가요?")
                    .font(.PretendardSemibold20)
                    .foregroundStyle(.black)
                Spacer()
            }.padding(.bottom, 1)
            
            HStack {
                Text("요청해주시면 확인 후 재료 목록에 반영할게요")
                    .font(.PretendardRegular16)
                    .foregroundStyle(.grey600)
                Spacer()
            }.padding(.bottom, 45)
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.grey100)
                    .frame(height: 56)
                TextField("재료 이름을 입력해주세요.", text: $text)
                    .font(.PretendardRegular16)
                    .foregroundStyle(.grey900)
                    .padding(.leading, 14)
            }.padding(.bottom, 50)
            
            Button( action: { onRequest(text); isShowingSheet.toggle() } ) {
                OrangeButton(text: "추가 요청하기", size: .big)
            }.frame(height: 56)
        }.padding(.horizontal)
    }
}
