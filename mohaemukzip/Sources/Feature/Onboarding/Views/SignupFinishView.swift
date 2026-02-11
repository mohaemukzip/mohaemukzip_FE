
import SwiftUI

struct SignupFinishView: View {
    @EnvironmentObject private var router: AuthRouter
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("가입이 완료되었어요!")
                        .font(.PretendardSemibold24)
                        .foregroundStyle(.grey900)
                    
                    Text("뭐해먹집과 함께 집밥 요리 루틴을 만들어보아요.")
                        .font(.PretendardRegular16)
                        .foregroundStyle(.grey500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 17)
                .padding(.top, 58)
                
                Spacer(minLength: 0)
                
                Image("signupLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer(minLength: 0)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button {
                router.push(.login)
            } label: {
                Text("시작하기")
                    .font(.PretendardSemibold18)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 57)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.main400)
                    )
            }
            .padding(.horizontal, 17)
            .padding(.bottom, 0)
        }
        .navigationBarBackButtonHidden()
    }
}
