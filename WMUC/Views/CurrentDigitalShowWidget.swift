//
//  CurrentDigitalShowWidget.swift
//  WMUC
//
//  Created by Anahita on 10/18/24.
//
import SwiftUI

struct CurrentDigitalShowWidget: View {
    @EnvironmentObject private var liveDigitalShow: CurrentDigitalShow
    @Binding var width: CGFloat
    @Binding var isPlaying: Bool
    var onPlayTapped: () -> Void

    var body: some View {
        if !liveDigitalShow.isLoading {
            HStack(spacing: 12) {
                // Show Cover Photo
                CurrentShowWidgetPhotoCover(
                    photoURL: liveDigitalShow.photoURL,
                    width: $width,
                    isActive: liveDigitalShow.isActive
                )
                .frame(width: 0.3 * width, height: 0.3 * width)
                .clipped()

                // Show Details
                CurrentShowWidgetText<CurrentDigitalShow>()
                    .environmentObject(liveDigitalShow)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        } else {
            Text("Loading Digital Show...")
                .frame(width: width)
                .padding(.all, 18)
        }
    }
}
