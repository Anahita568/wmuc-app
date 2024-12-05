//
//  MediaBarSwipableView.swift
//  WMUC
//
//  Created by Anahita on 12/4/24.
//
import SwiftUI

struct MediaBarSwipableView: View {
    @Binding var isPlayingFM: Bool
    @Binding var isPlayingDigital: Bool
    @State private var currentIndex: Int = 0 // Tracks the active media bar
    let items = ["FM", "Digital"]
    
    var body: some View {
        TabView(selection: $currentIndex) {
            // FM Media Bar
            MediaBarView(
                isPlaying: isPlayingFM,
                radioType: .fm,
                onPlayPauseTapped: {
                    isPlayingFM.toggle()
                    if isPlayingFM {
                        isPlayingDigital = false
                    }
                }
            )
            .tag(0)
            
            // Digital Media Bar
            MediaBarView(
                isPlaying: isPlayingDigital,
                radioType: .digital,
                onPlayPauseTapped: {
                    isPlayingDigital.toggle()
                    if isPlayingDigital {
                        isPlayingFM = false
                    }
                }
            )
            .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide page dots
        .frame(height: 70) // Fixed height for media bar
    }
}
