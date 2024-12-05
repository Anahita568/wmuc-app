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
                // Show Cover Photo
                CurrentShowWidgetPhotoCover(photoURL: liveFMShow.photoURL, width: $width)
                
                // Show Details: Title, Status, and End Time
                CurrentShowWidgetText(
                    showEndTime: liveFMShow.endTime ?? Date(),
                    showTitle: liveFMShow.title ?? "Unknown Show",
                    showIsActive: liveFMShow.isActive
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Play Button
                Button(action: {
                    onPlayTapped() // Execute the action passed as a parameter
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 18)
        } else {
            // Show a loading view or a placeholder while data is being fetched
            Text("Loading FM Show...")
                .frame(width: width)
                .padding(.all, 18)
        }
    }
}
