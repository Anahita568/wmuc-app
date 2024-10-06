//
//  CurrentShowWidgetPhotoCover.swift
//  Radio practice
//
//  Created by Akash Balenalli on 6/2/24.
//

import SwiftUI

struct CurrentShowWidgetPhotoCover: View {
    @State var photoURL: URL?
    @Binding var width: CGFloat
    
    var body: some View {
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
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .frame(width: 0.3 * width)
                    .padding(.leading, 0)
                
            case .failure:
                Rectangle()
                    .frame(width: 0.3 * width, height: 0.3 * width)
                    .foregroundStyle(.gray)
                    .cornerRadius(10)
            @unknown default:
                Rectangle()
                    .frame(width: 0.3 * width, height: 0.3 * width)
                    .foregroundStyle(.gray)
                    .cornerRadius(10)
            }
        }
    }
}
