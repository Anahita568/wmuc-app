//
//  CurrentFMShowWidget.swift
//  Radio practice
//
//  Created by Akash Balenalli on 12/21/23.
//
//
import SwiftUI

struct CurrentFMShowWidget: View {
    @EnvironmentObject private var liveFMShow: CurrentFMShow
    @Binding var width: CGFloat // Binding to adjust the widget width
    @Binding var isPlaying: Bool // Binding to manage play/pause state
    var onPlayTapped: () -> Void // Closure for play button action
    
    var body: some View {
        if !liveFMShow.isLoading {
            HStack {
                // Play button
//                Button(action: {
//                    onPlayTapped() // Execute the action passed as a parameter
//                }) {
//                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.white)
//                        .padding()
////                        .border(.white)
////                        .buttonStyle(.bordered)
////                        .clipShape(Circle())
////                        .overlay(
////                            Circle()
////                                .stroke(Color.white, lineWidth: 1)
////                        )
//                }
                
                HStack {
                    // Show Cover Photo
                    CurrentShowWidgetPhotoCover(photoURL: liveFMShow.photoURL, width: $width)
                    
                    // Show Details: Title, Status, and End Time
                    CurrentShowWidgetText(
                        showEndTime: liveFMShow.endTime ?? Date(),
                        showTitle: liveFMShow.title ?? "Unknown Show",
                        showIsActive: liveFMShow.isActive
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
//                        .padding([.trailing], 10)
//                        .imageScale(.large)
                        .font(.title3)
                }
//                .padding(.horizontal, 18)
//                .background(Color.gray.opacity(0.2))
//                .cornerRadius(10)
//                .overlay(
//                    Rectangle()
//                        .stroke(Color.white, lineWidth: 1)
//                )
            }
            
        } else {
            // Show a loading view or a placeholder while data is being fetched
            Text("Loading FM Show...")
                .frame(width: width)
                .padding(.all, 18)
        }
    }
}
