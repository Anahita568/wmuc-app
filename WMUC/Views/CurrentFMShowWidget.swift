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
      
        
        return Group {
            if !liveFMShow.isLoading {
                HStack {
                    CurrentShowWidgetPhotoCover(
                        photoURL: liveFMShow.photoURL,
                        width: $width,
                        isActive: liveFMShow.isActive
                    )
                    
                    CurrentShowWidgetText<CurrentFMShow>()
                        .environmentObject(liveFMShow)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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
                .padding(.horizontal, 18)
            } else {
                Text("Loading FM Show...")
                    .frame(width: width)
                    .padding(.all, 18)
            }
        }
    }
}
