//
//  Radio_practiceApp.swift
//  Radio practice
//
//  Created by Akash B on 6/1/23.
//

import SwiftUI

@main
struct Radio_practiceApp: App {
    @StateObject private var liveFMShow = CurrentFMShow()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(liveFMShow)
        }
    }
}
