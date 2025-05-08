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
    @Binding var width: CGFloat      // Binding to adjust the widget width
    @Binding var isPlaying: Bool     // Binding to manage play/pause state
    var onPlayTapped: () -> Void     // Closure for play button action
    
    var body: some View {
        Group {
            if !liveFMShow.isLoading {
                HStack(spacing: 12) {
                    // Image on the far left
                    CurrentShowWidgetPhotoCover(
                        photoURL: liveFMShow.photoURL,
                        width: $width,
                        isActive: liveFMShow.isActive
                    )
                    .frame(width: 0.3 * width, height: 0.3 * width)
                    .clipped()
                    
                    // Show Details
                    CurrentShowWidgetText<CurrentFMShow>()
                        .environmentObject(liveFMShow)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
            } else {
                Text("Loading FM Show...")
                    .frame(width: width)
                    .padding(.all, 18)
            }
        }
    }
}
