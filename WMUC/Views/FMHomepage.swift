//
//  Homepage.swift
//  Radio practice
//
//  Created by Akash B on 6/2/23.
//

import SwiftUI

struct FMHomepage: View {
    @EnvironmentObject var liveFMShow: CurrentFMShow
    
    var body: some View {
        // GeometryReader provides constraints that can be passed down the view stack, which
        // helps account for some lost control in nested elements that CSS usually provides in
        // web-based frameworks like React.
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    LazyVStack(pinnedViews: [.sectionFooters]) {
                        // 📱 The widget-like detail view at the top of the page that
                        // displays the current show's cover, live status, etc.
                        CurrentFMShowWidget(width: .constant(geometry.size.width))
                            .layoutPriority(2)
                        
                            
                        ScheduleRow(day: "Tuesday", radioType: .fm)
                            .padding(.horizontal)
//                            .background {
//                                Color.red
//                            }
                        //                        Section(footer: FMMediaBarView(isPlaying: true)) {
                        //
                        ////
                        
                        ////    //                        ScheduleRow()
                        ////    //                            .padding(.horizontal)
                        ////    //                        ScheduleRow()
                        ////    //                            .padding(.horizontal)
                        ////    //                        ScheduleRow()
                        ////    //                            .padding(.horizontal)
                        ////    //                        ScheduleRow()
                        ////    //                            .padding(.horizontal)
                        ////    //                            .padding([.bottom], 20)
                        //                       }
//                            .background(Color.red)
                    }
                    .navigationTitle("FM")
                }
            }
        }
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        FMHomepage()
            .environmentObject(CurrentFMShow())
    }
}
