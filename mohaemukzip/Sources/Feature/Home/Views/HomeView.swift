//
//  HomeView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/26/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(HomeViewModel.self) var viewModel
    @State private var selectedTab: TopTab = .board
    @State private var isHomePowerInfoPresented: Bool = false
    
    enum TopTab { case board, stats }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack {
            ScrollView(showsIndicators: false){
                VStack(spacing: 14) {
                    topTabs
                    
                    switch selectedTab {
                    case .board:
                        if let home = viewModel.home {
                            characterSection(home)
                            weeklyChallengeSection(home)
                            todayMissionSection(home)
                            recommendedSection(home)
                        } else if viewModel.isLoading {
                            ProgressView().padding(.top, 40)
                        } else {
                            Text("데이터가 없어요").foregroundStyle(.secondary).padding(.top, 40)
                        }
                    case .stats:
                        StatsView(isHomePowerInfoPresented: $isHomePowerInfoPresented)
                    }
                }
                .padding(.bottom, 20)
            }
            
            
            if isHomePowerInfoPresented {
                HomePowerInfoModalView(isPresented: $isHomePowerInfoPresented)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isHomePowerInfoPresented)
        .task { await viewModel.load() }
        .navigationBarHidden(true)
    }
}

// MARK: - UI Pieces
private extension HomeView {
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
    
    func characterSection(_ home: HomeModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // lv 주는 값에 따라 캐릭터 이미지 다르게
            HStack(spacing: 20) {
                Image(levelImageName(home.level))
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .frame(width: 170, height: 167)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("Lv.\(home.level)")
                            .font(.PretendardRegular14)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundStyle(.white)
                            .background(.grey700)
                            .clipShape(Capsule())
                        
                        Spacer()
                    }
                    
                    Text(home.title)
                        .font(.PretendardSemibold20)
                        .foregroundStyle(.grey900)
                    
                    Text("이달의 집밥 횟수 \(home.monthlyCooking)회")
                        .font(.PretendardRegular16)
                        .foregroundStyle(.grey500)
                }
            }
            .padding(.bottom, 28)
            ProgressView(value: home.progressRatio)
                .tint(.grey700)
                .frame(height: 8)
            
            HStack {
                Text("다음 레벨까지 남은 집밥 포인트")
                    .font(.PretendardRegular14)
                    .foregroundStyle(.grey500)
                Spacer()
                Text(home.progressText)
                    .font(.PretendardRegular14)
                    .foregroundStyle(.grey500)
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18)) //지우기
    }
    
    func weeklyChallengeSection(_ home: HomeModel) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            Rectangle()
                .frame(height: 8)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.grey100)
                .padding(.horizontal, -17)
            Text("_님은 \(home.consecutiveDays)일째 루틴 도전 중!")
                .font(.PretendardSemibold20)
                .foregroundStyle(.grey900)
            
            HStack(spacing: 13) {
                ForEach(Array(home.weekly.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 6) {
                        Text(item.day)
                            .font(.PretendardMedium14)
                            .foregroundStyle(.grey500)
                        ZStack {
                            Circle()
                                .fill(item.isDone ? Color.clear : Color(.systemGray4))
                            
//                            if item.isDone {
//                                Image(.icnBab)
//                                    .resizable()
//                                    .scaledToFit()
//                            }
                        }
                        .frame(width: 40, height: 40)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Rectangle()
                .frame(height: 8)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.grey100)
                .padding(.horizontal, -17)
        }
        .padding(17)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    func todayMissionSection(_ home: HomeModel) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘의 퀘스트")
                .font(.PretendardSemibold20)
                .foregroundStyle(.black)
            
            VStack(spacing: 24) {
                Image(.icnMission)
                    .frame(width: 80, height: 80)
                
                VStack(alignment: .center, spacing: 6) {
                    Text(home.todayMission.title)
                        .font(.PretendardSemibold20)
                        .lineLimit(1)
                        .foregroundStyle(.grey900)
                    
                    Text(home.todayMission.description)
                        .font(.PretendardRegular16)
                        .foregroundStyle(.grey500)
                        .lineLimit(2) //행간 어케 주지
                }
                
                
                Text("보상: +\(home.todayMission.reward) 루틴 포인트, '재료 마스터' 뱃지 획득")
                    .font(.PretendardRegular16)
                    .foregroundStyle(.main400)
                
                Button {
                    // TODO: 퀘스트 화면 이동
                    print("BEFORE:", router.path)
                    router.push(.ingredientDetailSearch)
                    print("AFTER:", router.path)
                } label: {
                    Text(home.todayMission.isCompleted ? "완료됨" : "퀘스트 도전하기")
                        .font(.system(size: 13, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .foregroundStyle(.white)
                        .background(home.todayMission.isCompleted ? Color.gray : Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(home.todayMission.isCompleted)
            }
            .padding(24)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.grey400, lineWidth: 1)
            )
        }
        .padding(.horizontal, 17)
    }
    
    func recommendedSection(_ home: HomeModel) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘의 추천 요리 레시피")
                .font(.PretendardSemibold20)
                .foregroundStyle(.black)
                .padding(.top, 80)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(home.recipes) { recipe in
                        HomeRecipeCardView(recipe: recipe)
                    }
                }
            }
        }
        .padding(.horizontal, 17)
    }
    
    func levelImageName(_ level: Int) -> String {
        switch level {
        case 0: return "icnLv0"
        case 1: return "icnLv1"
        case 2: return "icnLv2"
        case 3: return "icnLv3"
        default: return "icnLv4"
        }
    }
}

// MARK: - Recipe Card 추후 수정!! 석현오빠 뷰 재사용하기

private struct HomeRecipeCardView: View {
    let recipe: RecipeModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: recipe.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Rectangle().fill(Color(.systemGray5))
                    }
                }
                .frame(width: 160, height: 96)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text(recipe.time)
                    .font(.PretendardMedium12)
                    .foregroundColor(.white)
                    .padding(2)
                    .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .padding(2)
                    .padding(.trailing, 5)
                    .padding(.bottom, 6)
            }
            .padding(.bottom, 7)
            
            Text(recipe.title)
                .font(.PretendardMedium16)
                .foregroundStyle(.black)
                .lineLimit(1)
                .padding(.bottom, 2)
            
            HStack(spacing: 4) {
                Text(recipe.channel)
                Text(".")
                Text("조회수 \(formattedViews(recipe.views))회")
            }
            .font(.PretendardRegular13)
            .foregroundStyle(.grey500)
        }
        .frame(width: 160)
    }
    
    private func formattedViews(_ views: Int) -> String {
        if views >= 10_000 {
            let viewNumber = Double(views) / 10_000.0
            return String(format: "%.1f만", viewNumber)
        } else {
            return "\(views)"
        }
    }
}

// MARK: - 모달

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

// MARK: - Preview
#Preview {
    HomeView()
        .environment(NavigationRouter())
        .environment(HomeViewModel())
}
