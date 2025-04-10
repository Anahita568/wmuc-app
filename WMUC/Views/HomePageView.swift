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
                                .fill(Color.gray.opacity(0.3))
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
                
                
            }
        }
    }
    
    private func togglePlayback(for radioType: RadioType) {
        switch radioType {
        case .fm:
            if isPlayingFM {
                audioManager.stopPlayback()
                isPlayingFM.toggle()
            } else {
                Task {
                    let coverImage: UIImage?
                    if liveFMShow.isActive, let url = liveFMShow.photoURL {
                        coverImage = await fetchCoverImage(from: url)
                    } else {
                        coverImage = UIImage(named: "notLive")
                    }
                    let titleToUse = liveFMShow.isActive ? (liveFMShow.title ?? "Unknown Show") : "WMUC 24/7"
                    audioManager.playStream(url: fmRadioStreamURL,
                                            title: titleToUse,
                                            coverImage: coverImage)
                    await MainActor.run {
                        isPlayingFM.toggle()
                        isPlayingDigital = false
                    }
                }
            }
        case .digital:
            if isPlayingDigital {
                audioManager.stopPlayback()
                isPlayingDigital.toggle()
            } else {
                Task {
                    let coverImage: UIImage?
                    if liveDigitalShow.isActive, let url = liveDigitalShow.photoURL {
                        coverImage = await fetchCoverImage(from: url)
                    } else {
                        coverImage = UIImage(named: "notLive")
                    }
                    let titleToUse = liveDigitalShow.isActive ? (liveDigitalShow.title ?? "Unknown Show") : "WMUC 24/7"
                    audioManager.playStream(url: digitalRadioStreamURL,
                                            title: titleToUse,
                                            coverImage: coverImage)
                    await MainActor.run {
                        isPlayingDigital.toggle()
                        isPlayingFM = false
                    }
                }
            }
        }
    }
    
    func fetchCoverImage(from url: URL?) async -> UIImage? {
        guard let url = url else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error fetching cover image: \(error)")
            return nil
        }
    }
}
