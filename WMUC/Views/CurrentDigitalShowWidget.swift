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
    
    var body: some View {
        if !liveDigitalShow.isLoading {
            HStack {
                // 📱 The photo that appears at the top of the page showing the current show's cover
                CurrentShowWidgetPhotoCover(photoURL: liveDigitalShow.photoURL, width: $width)
                
                // 📱 The views that show the current show's title, live status, and end time
                CurrentShowWidgetText(
                    showEndTime: liveDigitalShow.endTime ?? Date(),
                    //If no title is given for whatever reason
                    showTitle: liveDigitalShow.title ?? "Unknown Show",
                    showIsActive: liveDigitalShow.isActive
                )
                
                Spacer()
            }
            .padding(.leading, 18)
            .padding(.trailing, 18)
        } else {
            // Show a loading view or a placeholder while data is being fetched
            Text("Loading Digital Show...")
                .frame(width: width)
                .padding(.all, 18)
        }
    }
}

