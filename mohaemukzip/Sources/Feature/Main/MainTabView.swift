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
    @State private var selection: TabType = .home
    @State private var router = NavigationRouter()
    @State private var fridgeVM = FridgeViewModel()
    @State private var ingredientSearchVM = IngredientSearchViewModel()
    @State private var yoTeacherVM = YoTeacherChatViewModel()

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
        TabView(selection: $selection) {
            Tab(value: .home) {
                HomeView()
            } label: {
                Label(
                    "홈",
                    image: selection == .home ? "selectedHome" : "icon-home"
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
                    image: selection == .search ? "selectedSearch" : "icon-search"
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
                    image: selection == .ingredient ? "selectedIngredient" : "icon-ingredient"
                )
            }
            Tab(value: .profile) {
                ProfileView()
            } label: {
                Label(
                    "마이",
                    image: selection == .profile ? "selectedProfile" : "icon-profile"
                )
            }
        }
        .environment(router)
        .environment(fridgeVM)
        .environment(ingredientSearchVM)
        .environment(yoTeacherVM)
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
                RecipeVideoDetailView(video: video)
            }
        }
    }
}

#Preview {
    MainTabView()
}
