//
//  MainTabView.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/15/26.
//

import SwiftUI

struct MainTabView: View {
    enum TabType: Hashable {
        case home
        case search
        case ingredient
        case profile
    }
    
    //기본 설정된 상태 -> home
    // ✅ 탭 선택을 외부(상세 화면 등)에서도 제어할 수 있도록 라우터로 분리
    @State private var tabRouter = TabRouter()
    
    // MARK: - 각 뷰에서 사용하는 뷰모델은 MainTabView에서 소유(@State)
    // MARK: - MainTabView에서 소유하는 뷰모델을 환경변수로 각 뷰에 주입
    // MARK: - 중앙 집중적으로 뷰모델을 관리해야 공통된 데이터로 뷰를 그릴 수 있음
    @State private var router = NavigationRouter()
    @State private var fridgeVM = FridgeViewModel()
    @State private var ingredientSearchVM = IngredientSearchViewModel()
    @State private var yoTeacherVM = YoTeacherChatViewModel()
    @State private var searchVM = SearchViewModel()
    @State private var homeVM = HomeViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    //@State private var loginVM = LoginViewModel()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // 탭 아이템 간 간격 조절 (가운데 정렬 + 간격 촘촘하게)
        UITabBar.appearance().itemPositioning = .centered
        
        
        // 각 탭 아이템의 너비를 줄여 전체 간격을 촘촘하게 유지 (좌우 대칭 유지)
        
        
        // 선택되지 않은 상태 (grey500)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "grey500")
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(named: "grey500") as Any
        ]
        
        // 선택된 상태 (grey900)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "grey900")
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(named: "grey900") as Any
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
    }
    var body: some View {
        TabView(selection: $tabRouter.selection) {
            Tab(value: .home) {
                NavigationStack(path: $router.path) {
                    HomeView()
                        .setupNavigationDestinations()
                }
            } label: {
                Label(
                    "홈",
                    image: tabRouter.selection == .home ? "selectedHome" : "icon-home"
                )
            }
            Tab(value: .search) {
                NavigationStack(path: $router.path) {
                    RecipeListView()
                        .setupNavigationDestinations()
                }
            } label: {
                Label(
                    "검색",
                    image: tabRouter.selection == .search ? "selectedSearch" : "searchicon"
                )
            }
            Tab(value: .ingredient) {
                NavigationStack(path: $router.path) {
                    FridgeView()
                        .setupNavigationDestinations()
                }
            } label: {
                Label(
                    "재료",
                    image: tabRouter.selection == .ingredient ? "selectedIngredient" : "icon-ingredient"
                )
            }
            Tab(value: .profile) {
                NavigationStack(path: $router.path) {
                    ProfileView()
                        .setupNavigationDestinations()
                }
            } label: {
                Label(
                    "마이",
                    image: tabRouter.selection == .profile ? "selectedProfile" : "icon-profile"
                )
            }
        }
        .onChange(of: tabRouter.selection) { _, _ in
            // 탭 전환 시 기존 네비게이션 스택(Route)이 남아있으면
            // 다른 탭의 NavigationStack에서 동일 path를 해석하려다 크래시가 날 수 있다.
            router.navigateToRoot()
        }
        .onChange(of: tabRouter.goHomeToken) { _, _ in
            // ✅ 이미 홈 탭인 상태에서 goHome()이 호출될 수도 있어서
            // selection 변화가 없어도 스택을 루트로 확실히 초기화한다.
            router.navigateToRoot()
        }
        .environment(router)
        // ✅ 탭 이동(특히 "항상 홈으로")을 위해 탭 라우터 주입
        // 상세 화면/모달에서 tabRouter.goHome() 호출 가능
        .environment(tabRouter)
        .environment(fridgeVM)
        .environment(ingredientSearchVM)
        .environment(yoTeacherVM)
        .environment(searchVM)
        .environment(homeVM)
        .environmentObject(profileVM)
    }
}

// MARK: - TabRouter
// ✅ 상세 화면 등 어디서든 "홈으로" 이동을 요청할 수 있게 하는 탭 라우터
// 사용 예: @Environment(TabRouter.self) private var tabRouter
//         tabRouter.goHome()
@Observable
final class TabRouter {
    var selection: MainTabView.TabType = .home

    // goHome()이 이미 홈인 상태에서 호출될 수도 있어서 토큰으로 한 번 더 트리거
    var goHomeToken: Int = 0

    func goHome() {
        selection = .home
        goHomeToken += 1
    }
}

extension View {
    func setupNavigationDestinations() -> some View {
        self.navigationDestination(for: Route.self) { route in
            switch route {
            case .ingredientSearch:
                IngredientSearchView()
            case .ingredientDetailSearch:
                IngredientDetailSearchView()
            case .yoTeacher:
                YoTeacherChatView()
            case .recipeDetail(let video):
                RecipeDetailView(recipeId: video.id, base: video)
            case .recipeSearch:
                SearchView()
            case .home:
                HomeView()
            // 상세화면 넘어갈 때
            case .recipeDetailById(let recipeId):
                RecipeDetailView(recipeId: recipeId, base: nil)

            // ✅ 추가
            case .profileSettings:
                ProfileSettingsView()

            case .profileChange:
                ProfileChangeDestinationView()

            case .recentlyViewedRecipes:
                RecentlyViewedRecipesView()

            case .bookmarkedRecipes:
                BookmarkedRecipesView()

//            case .recipeDetailNoComplete(let video):
//                // TODO: 여기만 나중에 “요리 완료 모달 없는 RecipeDetailView”로 교체
//                RecipeVideoDetailView(video: video)
            }
        }
    }
}

private struct ProfileChangeDestinationView: View {
    @EnvironmentObject private var profileVM: ProfileViewModel

    var body: some View {
        ProfileChangeView()
    }
}

#Preview {
    MainTabView()
}
