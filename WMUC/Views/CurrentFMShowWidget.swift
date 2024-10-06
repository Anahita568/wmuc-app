//
//  CurrentFMShowWidget.swift
//  Radio practice
//
//  Created by Akash Balenalli on 12/21/23.
//

import SwiftUI

struct CurrentFMShowWidget: View {
    @EnvironmentObject private var liveFMShow: CurrentFMShow
    @Binding var width: CGFloat
    
    var body: some View {
        if !liveFMShow.isLoading {
            HStack {
                // 📱 The photo that appears at the top of the page showing the current show's cover
                CurrentShowWidgetPhotoCover(photoURL: liveFMShow.photoURL, width: $width)
                
                // 📱 The views that appear at the top of the page showing the current show's title, live status, and end time
                CurrentShowWidgetText(showEndTime: liveFMShow.endTime!, showTitle: liveFMShow.title!, showIsActive: liveFMShow.isActive)
                
                Spacer()
            }
            .padding(.leading, 18)
            .padding(.trailing, 18)
        }
    }
}


