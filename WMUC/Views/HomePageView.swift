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
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        ZStack(alignment: .topLeading) {
                            // gray background rectangle with rounded corners
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: geometry.size.height * 0.20) // % of screen height
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Image("wmucLogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.8) // adjust logo width
                                    .padding(.bottom, 4)
                                
                                Text("where college radio is good radio")
                                    .font(.system(size: geometry.size.width * 0.06))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(.black)
                            }
                            .padding(.top, 30) // how wmuc logo is centered
                            .padding(.horizontal)
                        }
                        
                        Text("what’s playing?/tune in")
                            .font(.system(size: geometry.size.width * 0.07))
                            .padding(.top, 5) //increase to increase space between text and logo
                        
                        Text("fm")
                            .font(.system(size: geometry.size.width * 0.06))
                            .padding(.top, 8) //increase to increase space between fm and what's playing
                            .foregroundColor(.red)
                        
                        // fm show details and play/pause button
                        CurrentFMShowWidget(
                            width: .constant(geometry.size.width * 0.85), // widget width
                            isPlaying: $isPlayingFM, // binding to play/pause state
                            onPlayTapped: {
                                togglePlayback(for: .fm) // handle fm play/pause
                            }
                        )
                        .environmentObject(liveFMShow) // inject fm show data
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        
                        Text("digital")
                            .font(.system(size: geometry.size.width * 0.06))
                            .foregroundColor(.red)
                        
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
                        
                        //add extra vertical space at the bottom of content
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 40)      // top padding to shift content down
                    .padding(.horizontal)   // horizontal padding for layout margins
                }
                
                VStack {
                    Spacer() // pushes the media bar to the bottom
                    MediaBarSwipableView(
                        isPlayingFM: $isPlayingFM,
                        isPlayingDigital: $isPlayingDigital
                    )
                    .frame(height: 70)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)        // bottom padding to avoid the screen edge
                }
            }
        }
    }
    
    private func togglePlayback(for radioType: RadioType) {
        switch radioType {
        case .fm:
            // stop playback if already playing, otherwise start the stream
            if isPlayingFM {
                audioManager.stopPlayback()
            } else {
                audioManager.playStream(url: fmRadioStreamURL)
            }
            isPlayingFM.toggle()         // update fm play state
            isPlayingDigital = false     // make sure dig stream is stopped
        case .digital:
            if isPlayingDigital {
                audioManager.stopPlayback()
            } else {
                audioManager.playStream(url: digitalRadioStreamURL)
            }
            isPlayingDigital.toggle()
            isPlayingFM = false
        }
    }
}
