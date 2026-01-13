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
                Text("홈")
            }
            Tab("검색", image: "icon-search") {
                Text("검색")
            }
            Tab("재료", image: "icon-ingredient") {
                Text("재료")
            }
            Tab("마이", image: "icon-profile") {
                Text("마이")
            }
        } // end of TabView
        
    } // end of body
} // end of MainTabView

#Preview {
    MainTabView()
}
