//
//  CurrentShowWidgetText.swift
//  Radio practice
//
//  Created by Akash Balenalli on 6/2/24.
//
import SwiftUI

struct CurrentShowWidgetText<T: CurrentShow & ObservableObject>: View {
    @EnvironmentObject var liveShow: T

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
           
            Text(liveShow.isActive
                 ? (liveShow.title ?? "Unknown Show")
                 : "WMUC 24/7")
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.medium)
                .foregroundColor(.white)

           
            Text(liveShow.djs?.joined(separator: ", ") ?? "--")
                .font(.subheadline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

           
            HStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(liveShow.isActive ? .red : .gray)
                Text(liveShow.isActive
                     ? "Live until \(liveShow.endTime?.formatted(date: .omitted, time: .shortened) ?? "N/A")"
                     : "Not live")
                    .font(.system(size: 15))
                    .foregroundColor(liveShow.isActive ? .red : .gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 7)
    }
}
