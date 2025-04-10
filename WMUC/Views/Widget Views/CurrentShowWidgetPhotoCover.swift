//
//  CurrentShowWidgetPhotoCover.swift
//  Radio practice
//
//  Created by Akash Balenalli on 6/2/24.
//

import SwiftUI

struct CurrentShowWidgetPhotoCover: View {
     var photoURL: URL?
    @Binding var width: CGFloat
    var isActive: Bool  
    
    var body: some View {
        if !isActive || photoURL == nil {
            Image("notLive")
                .resizable()
                .scaledToFit()
                .frame(width: 0.30 * width, height: 0.30 * width)
                .cornerRadius(10)
                .clipped()
        } else {
            AsyncImage(url: photoURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .frame(width: 0.3 * width, height: 0.3 * width)
                        .cornerRadius(10)
                        .foregroundStyle(.gray)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 0.3 * width, height: 0.3 * width)
                        .cornerRadius(10)
                        .clipped() // Prevents overflow.
                        .padding(.leading, 0)
                case .failure:
                    Image("notLive")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 0.30 * width, height: 0.30 * width)
                        .cornerRadius(10)
                        .clipped()
                @unknown default:
                    Rectangle()
                        .frame(width: 0.3 * width, height: 0.3 * width)
                        .foregroundStyle(.gray)
                        .cornerRadius(10)
                }
            }
        }
    }
}
