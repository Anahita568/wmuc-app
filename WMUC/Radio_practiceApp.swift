//
//  Radio_practiceApp.swift
//  Radio practice
//
//  Created by Akash B on 6/1/23.
//
//

import SwiftUI

@main
struct Radio_practiceApp: App {
    @StateObject private var liveFMShow = CurrentFMShow()
    @StateObject private var liveDigitalShow = CurrentDigitalShow()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(liveFMShow)
                .environmentObject(liveDigitalShow)
        }
    }
}

