//  HomePageView.swift
//  WMUC
//
//  Created by Anahita on 11/5/24.
import SwiftUI
import Combine

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
                ZStack {
                    Color(red: 0.5333, green: 0.21569, blue: 0.1765).ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // HEADER
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: geometry.size.height * 0.18)
                                    //.padding(.top, 20)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                                        Text("wmuc radio")
                                            .font(.system(size: geometry.size.width * 0.1))
                                            .foregroundColor(.white)
                                        
                                        Text("90.5")
                                            .font(.system(size: geometry.size.width * 0.05))
                                            .baselineOffset(geometry.size.height * 0.015)
                                            .foregroundColor(.white)
                                            
                                    }
                                    .padding(.top, 25)
                                    
                                    Text("where college radio is good radio")
                                        .font(.system(size: geometry.size.width * 0.06))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundColor(.white)
                                    
                                }
                            }
                            Spacer().frame(height: 5)
                            
                            // FM Section
                            Button(action: {
                                togglePlayback(for: .fm)
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: isPlayingFM ? "pause.fill" : "play.fill")
                                        .imageScale(.large)
                                        .foregroundColor(.white)
                                    
                                    Text("fm")
                                        .font(.system(size: geometry.size.width * 0.06))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .frame(height: 1.5)
                                .overlay(.white)
                            
                            // FM Widget
                            CurrentFMShowWidget(
                                width: .constant(geometry.size.width * 0.85),
                                isPlaying: $isPlayingFM,
                                onPlayTapped: {
                                    togglePlayback(for: .fm)
                                }
                            )
                            .environmentObject(liveFMShow)
                            
                            Divider()
                                .frame(height: 1.5)
                                .overlay(.white)
                            
                            Spacer().frame(height: 14)
                            
                            // DIGITAL Section
                            VStack(spacing: 15) {
                                Button(action: {
                                    togglePlayback(for: .digital)
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: isPlayingDigital ? "pause.fill" : "play.fill")
                                            .imageScale(.large)
                                            .foregroundColor(.white)
                                        
                                        Text("digital")
                                            .font(.system(size: geometry.size.width * 0.06))
                                            .foregroundColor(.white)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                    .frame(height: 1.5)
                                    .overlay(.white)
                                
                                CurrentDigitalShowWidget(
                                    width: .constant(geometry.size.width * 0.85),
                                    isPlaying: $isPlayingDigital,
                                    onPlayTapped: {
                                        togglePlayback(for: .digital)
                                    }
                                )
                                .environmentObject(liveDigitalShow)
                                
                                Divider()
                                    .frame(height: 1.5)
                                    .overlay(.white)
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                .onReceive(audioManager.$currentlyPlaying.combineLatest(audioManager.$isPlaying)) { playingType, isPlaying in
                    isPlayingFM = isPlaying && playingType == .fm
                    isPlayingDigital = isPlaying && playingType == .digital
                }
                .onReceive(audioManager.$isPlaying) { isPlaying in
                    if !isPlaying {
                        isPlayingFM = false
                        isPlayingDigital = false
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
        }
    }
    
    // MARK: - Toggle Logic
    private func togglePlayback(for radioType: RadioType) {
        if audioManager.isPlaying && audioManager.currentlyPlaying == radioType {
            audioManager.stopPlayback()
            isPlayingFM = false
            isPlayingDigital = false
        } else {
            Task {
                let coverImage: UIImage?
                let titleToUse: String
                let publisher: AnyPublisher<CurrentShow, Never>

                switch radioType {
                case .fm:
                    coverImage = liveFMShow.isActive && liveFMShow.photoURL != nil
                        ? await fetchCoverImage(from: liveFMShow.photoURL)
                        : UIImage(named: "notLive")
                    titleToUse = liveFMShow.isActive ? (liveFMShow.title ?? "Unknown Show") : "WMUC 24/7"

                    //  continuous updates instead of Just(...)
                    publisher = liveFMShow.changePublisher

                    audioManager.playStream(
                        url: fmRadioStreamURL,
                        title: titleToUse,
                        coverImage: coverImage,
                        type: .fm,
                        showPublisher: publisher
                    )

                case .digital:
                    coverImage = liveDigitalShow.isActive && liveDigitalShow.photoURL != nil
                        ? await fetchCoverImage(from: liveDigitalShow.photoURL)
                        : UIImage(named: "notLive")
                    titleToUse = liveDigitalShow.isActive ? (liveDigitalShow.title ?? "Unknown Show") : "WMUC 24/7"

                    // continuous updates instead of Just(...)
                    publisher = liveDigitalShow.changePublisher

                    audioManager.playStream(
                        url: digitalRadioStreamURL,
                        title: titleToUse,
                        coverImage: coverImage,
                        type: .digital,
                        showPublisher: publisher
                    )
                }
                
                await MainActor.run {
                    isPlayingFM = (radioType == .fm)
                    isPlayingDigital = (radioType == .digital)
                }
            }
        }
    }

    // MARK: - Helpers
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
