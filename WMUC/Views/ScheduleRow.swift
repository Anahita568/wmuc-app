//
//  PopularShowsView.swift
//  Radio practice
//
//  Created by Akash B on 6/1/23.
//

import SwiftUI

/* TODO: (1) Rename to ScheduleRow (2) Take in two state objects: One is a daysFromNow variable, the other is an FM/Digital enum. Both are used to access the correct environment variable */
struct ScheduleRow: View {
    @State var day: String
    @State var radioType: RadioType
    
    var body: some View {
        VStack(alignment: .leading) {
            Label("Live today", systemImage: "wallet")
                .labelStyle(.titleOnly)
                .alignmentGuide(.leading, computeValue: {dimen in dimen[.leading]})
                .font(.title2)
                .fontWeight(.bold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(0..<21) {_ in
                        Rectangle()
                            .frame(width: 150, height: 150)
                    }
                }
            }
        }
        
    }
    
    struct PopularShowsView_Previews: PreviewProvider {
        static var previews: some View {
            ScheduleRow(day: "Tuesday", radioType: .fm)
        }
    }
    
}
