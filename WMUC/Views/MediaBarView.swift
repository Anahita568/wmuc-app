//
//  MediaBarView.swift
//  Radio practice
//
//  Created by Akash B on 6/2/23.
//

import SwiftUI

struct FMMediaBarView: View {
    @State var isPlaying: Bool
    @EnvironmentObject var liveFMShow: CurrentFMShow
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            HStack {
                Image("albumPlaceholder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 55, height: 55)
                    .cornerRadius(7)
                Spacer()
                VStack(alignment: .leading) {
                    Text(liveFMShow.title ?? "Loading")
                        .font(.headline)
                        .redacted(reason: .placeholder)
                    Text("DJ Names")
                        .font(.subheadline)
                }
                .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
                .padding([.leading], 5)
                Spacer()
                Button(action: {
                    isPlaying = !isPlaying
                }) {
                    isPlaying ?
                    Image(systemName: "play.fill")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 15, height: 15)
                        .aspectRatio(contentMode: .fit)
                    : Image(systemName: "pause.fill")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 15, height: 15)
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding([.trailing], 40)
            .padding([.leading], 25)
            .padding([.top, .bottom], 15)
        }
    }
}

class FMMediaBarManager: MediaBarManager, ObservableObject {
    private static let url = ""
    @Published var name: String = ""
    @Published var djs: [String] = [""]
    
    init() {
        // Connects self to InternetManager class
        InternetManager.connectFMShowManager(self as MediaBarManager)
    }
    
    func updateMedia(name: String, djs: [String]) {
        
    }
}

struct MediaBarView_Previews: PreviewProvider {
    static var previews: some View {
        FMMediaBarView(isPlaying: false)
            .environmentObject(CurrentFMShow())
    }
}
