//
//  CurrentShowWidgetText.swift
//  Radio practice
//
//  Created by Akash Balenalli on 6/2/24.
//

import SwiftUI

struct CurrentShowWidgetText: View {
    @State var showEndTime: Date
    @State var showTitle: String
    @State var showIsActive: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundStyle(showIsActive ? Color.red : Color.gray)
                Text(showIsActive ? "Live now" : "Not live")
                    .fontDesign(.monospaced)
                    .fontWeight(.regular)
                    .fontWidth(.compressed)
                    .font(.footnote)
                    .foregroundStyle(showIsActive ? Color.red : Color.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(showIsActive ? "Until \(showEndTime.formatted(date: .omitted, time: .shortened))" : "----")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.gray)
            
            Text(showIsActive ? showTitle: "----")
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.medium)
        }
        .padding(.leading, 7)
    }
}
