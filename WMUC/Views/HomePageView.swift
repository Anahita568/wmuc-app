//  HomePageView.swift
//  WMUC
//
//  Created by Anahita on 11/5/24.
import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var liveFMShow: CurrentFMShow
    @EnvironmentObject var liveDigitalShow: CurrentDigitalShow
    @State private var isPlaying: Bool = false


    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Top Section with Gray Background
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: geometry.size.height * 0.25) // Adjust height
                                .cornerRadius(20)
                                .ignoresSafeArea(edges: .top)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("wmuc radio")
                                        .font(Font.custom("SF Pro", size: geometry.size.width * 0.1))
                                        .bold()
                                    
                                    Text("90.5")
                                        .font(Font.custom("SF Pro", size: geometry.size.width * 0.05))
                                        .baselineOffset(geometry.size.height * 0.015) // Align properly
                                }
                                
                                Text("where college radio is good radio")
                                    .font(Font.custom("SF Pro", size: geometry.size.width * 0.06))
                                    .lineLimit(1) // Words stay on one line
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(.black)
                                
                                // Widgets Section (links for social media?)
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
                            CurrentFMShowWidget(width: .constant(geometry.size.width * 0.85))
                                .environmentObject(liveFMShow)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        // Digital Show Section
                        Text("digital")
                            .font(Font.custom("SF Pro", size: geometry.size.width * 0.06))
                        NavigationLink(destination: DigitalHomepage()) {
                            CurrentDigitalShowWidget(width: .constant(geometry.size.width * 0.85))
                                .environmentObject(liveDigitalShow)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal) //consistent horizontal padding
                    
                    VStack {
                        Spacer()
                        MediaBarView(isPlaying: isPlaying, radioType: .fm) // To finish later
                            .environmentObject(liveFMShow)
                            .environmentObject(liveDigitalShow)
                            .frame(height: 60)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray, radius: 4, x: 0, y: -2)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }
                
                }
                .navigationTitle("") // Remove "Home Page" title
                .navigationBarTitleDisplayMode(.inline) // Inline title display
            }
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .environmentObject(CurrentFMShow())
            .environmentObject(CurrentDigitalShow())
    }
}


