//  HomePageView.swift
//  WMUC
//
//  Created by Anahita on 11/5/24.

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var liveFMShow: CurrentFMShow
    @EnvironmentObject var liveDigitalShow: CurrentDigitalShow
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var isPlayingFM: Bool = false
    @State private var isPlayingDigital: Bool = false
    let fmRadioStreamURL = URL(string: "https://wmuc.umd.edu:8443/wmuc-hq")!
    let digitalRadioStreamURL = URL(string: "https://wmuc.umd.edu:8443/wmuc2-high")!

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Top Section with Gray Background
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: geometry.size.height * 0.25)
                                .cornerRadius(20)
                                .ignoresSafeArea(edges: .top)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("wmuc radio")
                                        .font(Font.custom("SF Pro", size: geometry.size.width * 0.1))
                                        .bold()
                                    
                                    Text("90.5")
                                        .font(Font.custom("SF Pro", size: geometry.size.width * 0.05))
                                        .baselineOffset(geometry.size.height * 0.015)
                                }
                                
                                Text("where college radio is good radio")
                                    .font(Font.custom("SF Pro", size: geometry.size.width * 0.06))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(.black)
                                
                                // Widgets Section
                                HStack(spacing: geometry.size.width * 0.03) {
                                    ForEach(0..<4) { _ in
                                        Button(action: {
                                            print("Widget tapped")
                                        }) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.5))
                                                .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.05)
                                                .cornerRadius(5)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        
                        // Tune In Section Header
                        Text("what’s playing?/tune in")
                            .font(Font.custom("SF Pro", size: geometry.size.width * 0.07))
                            .bold()
                        
                        // FM Show Section
                        Text("fm")
                            .font(Font.custom("SF Pro", size: geometry.size.width * 0.06))
                        NavigationLink(destination: FMHomepage()) {
                            CurrentFMShowWidget(
                                width: .constant(geometry.size.width * 0.85),
                                isPlaying: $isPlayingFM,
                                onPlayTapped: {
                                    togglePlayback(for: .fm)
                                }
                            )
                                .environmentObject(liveFMShow)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        // Digital Show Section
                        Text("digital")
                            .font(Font.custom("SF Pro", size: geometry.size.width * 0.06))
                        NavigationLink(destination: DigitalHomepage()) {
                            CurrentDigitalShowWidget(
                                width: .constant(geometry.size.width * 0.85),
                                isPlaying: $isPlayingDigital,
                                onPlayTapped: {
                                    togglePlayback(for: .digital)
                                }
                            )
                                .environmentObject(liveDigitalShow)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Swipable Media Bar Section
                    MediaBarSwipableView(
                        isPlayingFM: $isPlayingFM,
                        isPlayingDigital: $isPlayingDigital
                    )
                    .frame(height: 70)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // Toggle Playback Logic Using AudioManager
    private func togglePlayback(for radioType: RadioType) {
        switch radioType {
        case .fm:
            if isPlayingFM {
                audioManager.stopPlayback()
            } else {
                audioManager.playStream(url: fmRadioStreamURL)
            }
            isPlayingFM.toggle()
            isPlayingDigital = false // Stop digital playback
        case .digital:
            if isPlayingDigital {
                audioManager.stopPlayback()
            } else {
                audioManager.playStream(url: digitalRadioStreamURL)
            }
            isPlayingDigital.toggle()
            isPlayingFM = false // Stop FM playback
        }
    }
}
