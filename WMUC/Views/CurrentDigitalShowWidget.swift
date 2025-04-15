//
//  CurrentDigitalShowWidget.swift
//  WMUC
//
//  Created by Anahita on 10/18/24.
//
import SwiftUI

struct CurrentDigitalShowWidget: View {
    @EnvironmentObject private var liveDigitalShow: CurrentDigitalShow
    @Binding var width: CGFloat // Binding to adjust the widget width
    @Binding var isPlaying: Bool // Binding to manage play/pause state
    var onPlayTapped: () -> Void // Closure for play button action
    
    var body: some View {
        if !liveDigitalShow.isLoading {
            HStack(spacing: 12) {
                // Show Cover Photo with the active flag
                CurrentShowWidgetPhotoCover(
                    photoURL: liveDigitalShow.photoURL,
                    width: $width,
                    isActive: liveDigitalShow.isActive
                )
                .frame(width: 0.3 * width, height: 0.3 * width)
                .clipped()
                
                // Show Details: Title, Status, and End Time
                CurrentShowWidgetText<CurrentDigitalShow>()
                    .environmentObject(liveDigitalShow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Play Button
                Button(action: {
                    onPlayTapped()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                               .scaledToFit()
                               .frame(width: 26, height: 26)
                               .foregroundColor(.black)
                               .padding(18)
                               .background(Circle().fill(Color.gray.opacity(0.4)))
                       }
                       .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 8) // move everything closer to edges
            .padding(.vertical, 10)
        } else {
            // Display a loading view or a placeholder while data is being fetched
            Text("Loading Digital Show...")
                .frame(width: width)
                .padding(.all, 18)
        }
    }
}
