import SwiftUI

struct YoTeacher: View {
    var onTap: () -> Void
    
    var body: some View {
        // MARK: - 세부 카테고리 선택 전 요선생 배너
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.main100)
            VStack {
                HStack {
                    Text("어떤 메뉴가 좋을지 검색으로도 모르겠다면?")
                        .font(.PretendardMedium16)
                        .foregroundStyle(.grey900)
                    Spacer()
                }
                
                HStack {
                    Image("icon-yoteacher")
                    Spacer()
                    VStack {
                        Spacer()
                        Button ( action: { onTap() } ) {
                            Image("icon-yoteacher-button")
                        }
                    }
                }
            }.padding(20)
        }.frame(height: 202)
    }
}

#Preview {
    YoTeacher(onTap: { })
}
