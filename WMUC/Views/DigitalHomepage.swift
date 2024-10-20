//
//  DigitalHomepage.swift
//  WMUC
//
//  Created by Anahita on 10/20/24.
//

import SwiftUI

struct DigitalHomepage: View {
    @EnvironmentObject var liveDigitalShow: CurrentDigitalShow
    
    var body: some View {
        // GeometryReader provides constraints that can be passed down the view stack
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    LazyVStack(pinnedViews: [.sectionFooters]) {
                        // 📱 Widget-like detail view at the top of the page displaying the current digital show
                        CurrentDigitalShowWidget(width: .constant(geometry.size.width))
                            .layoutPriority(2)
                        
                        // ScheduleRow for digital radio (change radioType to .digital)
                        ScheduleRow(day: "Tuesday", radioType: .digital)
                            .padding(.horizontal)
                        
                        // Additional UI elements?
                    }
                    .navigationTitle("Digital")
                }
            }
        }
    }
}

struct DigitalHomepage_Previews: PreviewProvider {
    static var previews: some View {
        DigitalHomepage()
            .environmentObject(CurrentDigitalShow())
    }
}
