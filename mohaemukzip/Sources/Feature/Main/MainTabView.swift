//
//  MainTabView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/13/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("홈", image: "icon-home") {
                HomeView()
            }
            Tab("검색", image: "icon-search") {
                SearchView()
            }
            Tab("재료", image: "icon-ingredient") {
                IngredientView()
            }
            Tab("마이", image: "icon-profile") {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
