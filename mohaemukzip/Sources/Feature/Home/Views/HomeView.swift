import SwiftUI

struct HomeView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(HomeViewModel.self) var viewModel
    @Environment(SearchViewModel.self) var searchViewModel
    @ObservedObject var recipeVideoVM: RecipeVideoViewModel
    
    @State private var isLevelUpPresented: Bool = false
    @State private var previousLevel: Int? = nil
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(spacing: 14) {
            if let home = viewModel.home {
                characterSection(home)
                sectionDivider
                weeklyChallengeSection(home)
                sectionDivider
                todayMissionSection(home)
                recommendedSection(home)
            } else if viewModel.isLoading {
                ProgressView().padding(.top, 40)
            } else {
                Text("데이터가 없어요")
                    .foregroundStyle(.secondary)
                    .padding(.top, 40)
            }
        }
        .task {
            await viewModel.load()
            previousLevel = viewModel.home?.level
        }
        .onChange(of: viewModel.home?.level) { _, newLevel in
            checkLevelUpIfNeeded(newLevel: newLevel)
        }
        .fullScreenCover(isPresented: $isLevelUpPresented) {
            LevelUpView(level: viewModel.home?.level ?? 1) {
                isLevelUpPresented = false
                previousLevel = viewModel.home?.level
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 8)
        .background(.white)
    }
}


private extension HomeView {
    func checkLevelUpIfNeeded(newLevel: Int?) {
        guard let new = newLevel else { return }
        
        // 첫 로드는 기준값만 저장
        guard let prev = previousLevel else {
            previousLevel = new
            return
        }
        
        if new > prev {
            isLevelUpPresented = true
        }
        
        previousLevel = new
    }
    
    func characterSection(_ home: HomeModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 20) {
                Image(levelImageName(home.level))
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .frame(width: 150)
                
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
        .padding(.top, 12)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func weeklyChallengeSection(_ home: HomeModel) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("\(home.nickname)님은 \(home.consecutiveDays)일째 루틴 도전 중!")
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
                                .fill(item.isDone ? Color.clear : .grey300)
                            
                            if item.isDone {
                                Image(.icnBab)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 40, height: 40)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func todayMissionSection(_ home: HomeModel) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘의 퀘스트")
                .font(.PretendardSemibold20)
                .foregroundStyle(.black)
            
            VStack(spacing: 24) {
                Image(.icnMission)
                    .frame(width: 80, height: 80)
                
                VStack(alignment: .center, spacing: 8) {
                    Text(home.todayMission.title)
                        .font(.PretendardSemibold20)
                        .lineLimit(1)
                        .foregroundStyle(.grey900)
                    
                    Text(home.todayMission.description)
                        .multilineTextAlignment(.center)
                        .font(.PretendardRegular16)
                        .foregroundStyle(.grey500)
                        .lineLimit(2)
                }
                
                Text("보상: +\(home.todayMission.reward) 루틴 포인트")
                    .font(.PretendardRegular16)
                    .foregroundStyle(.main400)
                
                Button {
                    print("BEFORE:", router.path)
                    searchViewModel.selectedDishId = home.todayMission.dishId
                    router.push(.videoList(recipeVideoVM))
                    print("AFTER:", router.path)
                } label: {
                    Text(home.todayMission.status == .completed ? "완료됨" : "퀘스트 도전하기")
                        .font(.PretendardSemibold16)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .foregroundStyle(.white)
                        .background(
                            home.todayMission.status == .completed
                            ? Color.grey400
                            : Color.main400
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(home.todayMission.status == .completed)
                .padding(.top, 8)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.grey300, lineWidth: 1)
                    )
            )
        }
        .padding(.bottom, 66)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func recommendedSection(_ home: HomeModel) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘의 추천 요리 레시피")
                .font(.PretendardSemibold20)
                .foregroundStyle(.black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(home.recipes) { recipe in
                        HomeRecipeCardView(recipe: recipe)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                router.push(.recipeDetailById(recipe.id))
                            }
                    }
                }
            }
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var sectionDivider: some View {
        Rectangle()
            .fill(Color.grey100)
            .frame(height: 8)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, -17)
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
            
            Text("\(recipe.channel) · 조회수 \(formattedViews(recipe.views))회")
                .font(.PretendardRegular13)
                .foregroundStyle(.grey500)
                .lineLimit(1)
                .truncationMode(.tail)
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

