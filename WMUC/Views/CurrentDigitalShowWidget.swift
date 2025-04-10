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
            HStack {
                // Show Cover Photo with the active flag
                CurrentShowWidgetPhotoCover(
                    photoURL: liveDigitalShow.photoURL,
                    width: $width,
                    isActive: liveDigitalShow.isActive
                )
                
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
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 18)
        } else {
            // Display a loading view or a placeholder while data is being fetched
            Text("Loading Digital Show...")
                .frame(width: width)
                .padding(.all, 18)
        }
    }
}
