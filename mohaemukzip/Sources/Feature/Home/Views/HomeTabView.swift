import SwiftUI

struct HomeTabView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(HomeViewModel.self) var viewModel
    @Environment(SearchViewModel.self) var searchViewModel
    @StateObject private var recipeVideoVM = RecipeVideoViewModel()
    
    @State private var selectedTab: TopTab = .board
    @State private var isHomePowerInfoPresented: Bool = false
    
    enum TopTab { case board, stats }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    topTabs
                    
                    switch selectedTab {
                    case .board:
                        HomeView(recipeVideoVM: recipeVideoVM)
                            .padding(.bottom, 20)
                    case .stats:
                        StatsView(isHomePowerInfoPresented: $isHomePowerInfoPresented)
                    }
                }
            }
            
            if isHomePowerInfoPresented {
                HomePowerInfoModalView(isPresented: $isHomePowerInfoPresented)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isHomePowerInfoPresented)
        .navigationBarHidden(true)
    }
}
private extension HomeTabView {
    var topTabs: some View {
        HStack(spacing: 0) {
            HStack(spacing: 16) {
                tabButton(.board, title: "보드")
                tabButton(.stats, title: "통계")
            }
            Spacer()
            Button {
            } label: {
                Image(.iconBell)
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.grey700)
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 17)
    }
    
    func tabButton(_ tab: TopTab, title: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(title)
                .font(.PretendardSemibold24)
                .foregroundStyle(selectedTab == tab ? .grey900 : .grey400)
        }
    }
}

private struct HomePowerInfoModalView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 20) {
                Text("나의 집밥력이란?")
                    .font(.PretendardSemibold20)
                    .foregroundStyle(.grey900)
                    .padding(.top, 6)
                
                VStack(spacing: 18) {
                    infoRow(
                        icon: "statIcon1",
                        title: "냉장고 점수",
                        description: "냉장고 속 재료를 얼마나 잘 관리하고 있는지를 보여줘요. 유통기한을 잘 지킬수록 점수가 유지돼요."
                    )
                    
                    infoRow(
                        icon: "statIcon2",
                        title: "누적 요리 수",
                        description: "집밥을 얼마나 꾸준히 이어오고 있는지를 보여줘요. 요리를 완료할 때마다 기록이 쌓여요."
                    )
                    
                    infoRow(
                        icon: "statIcon3",
                        title: "도전 난이도",
                        description: "지금까지 도전한 요리들의 난이도 평균을 보여줘요. 어려운 요리를 끝까지 해낼수록 점수가 올라가요."
                    )
                }
                .padding(.horizontal, 6)
                
                Button {
                    isPresented = false
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.main400, lineWidth: 1)
                        
                        Text("확인")
                            .font(.PretendardSemibold18)
                            .foregroundStyle(.main400)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .contentShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 24)
        }
        .accessibilityAddTraits(.isModal)
    }
    
    
    private func infoRow(
        icon: String,
        title: String,
        description: String
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Image(icon)
                    .resizable()
                    .frame(width: 64, height: 64)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.PretendardSemibold16)
                    .foregroundStyle(.grey900)
                
                Text(description)
                    .font(.PretendardRegular14)
                    .foregroundStyle(.grey700)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
    }
}

