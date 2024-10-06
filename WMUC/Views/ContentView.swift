//
//  ContentView.swift
//  Radio practice
//
//  Created by Akash B on 6/1/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FMHomepage()
                .tabItem {
                    Text("FM")
                }.tag(1)
            Text("Tab Content 2")
                .tabItem {
                    Text("Digital")
                }.tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CurrentFMShow())
    }
}
