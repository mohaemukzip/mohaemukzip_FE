//
//  ContentView.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/8/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .foregroundStyle(.sub400)
                .font(.PretendardRegular13)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
