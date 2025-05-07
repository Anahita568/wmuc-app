//
//  Homepage.swift
//  Radio practice
//
//  Created by Akash B on 6/2/23.
//
import SwiftUI

struct FMHomepage: View {
    @EnvironmentObject var liveFMShow: CurrentFMShow
    @State private var isPlaying: Bool = false // Add state to manage play/pause

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    LazyVStack(pinnedViews: [.sectionFooters]) {
                        CurrentShowWidgetPhotoCover(photoURL: liveFMShow.photoURL, width: .constant(geometry.size.width * 2))
                        
                        // Current FM Show Widget
                        CurrentFMShowWidget(
                            width: .constant(geometry.size.width),
                            isPlaying: $isPlaying,
                            onPlayTapped: {
                                // Toggle play/pause state for FM
                                isPlaying.toggle()
                                print("FM Play button tapped. Playing: \(isPlaying)")
                                // Add logic to handle FM playback here
                            }
                        )
                        .layoutPriority(2)
                        
                        // Schedule Row for FM Shows
                        ScheduleRow(day: "Tuesday", radioType: .fm)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("FM")
            .background(.black)
        }
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        FMHomepage()
            .environmentObject(CurrentFMShow())
    }
}
