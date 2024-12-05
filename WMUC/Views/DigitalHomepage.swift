//
//  CurrentDigitalShowWidget.swift
//  WMUC
//
//  Created by Anahita on 10/18/24.
//

import SwiftUI

struct DigitalHomepage: View {
    @EnvironmentObject var liveDigitalShow: CurrentDigitalShow
    @State private var isPlaying: Bool = false // Add state to manage play/pause

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    LazyVStack(pinnedViews: [.sectionFooters]) {
                        // Current Digital Show Widget
                        CurrentDigitalShowWidget(
                            width: .constant(geometry.size.width),
                            isPlaying: $isPlaying,
                            onPlayTapped: {
                                // Toggle play/pause state for Digital
                                isPlaying.toggle()
                                print("Digital Play button tapped. Playing: \(isPlaying)")
                                // Add logic to handle Digital playback here
                            }
                        )
                        .layoutPriority(2)
                        
                        // Schedule Row for Digital Shows
                        ScheduleRow(day: "Tuesday", radioType: .digital)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Digital")
        }
    }
}

struct DigitalHomepage_Previews: PreviewProvider {
    static var previews: some View {
        DigitalHomepage()
            .environmentObject(CurrentDigitalShow())
    }
}
