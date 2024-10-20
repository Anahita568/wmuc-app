import SwiftUI


struct MediaBarView: View {
    @State var isPlaying: Bool
    @EnvironmentObject var liveFMShow: CurrentFMShow
    @EnvironmentObject var liveDigitalShow: CurrentDigitalShow
    var radioType: RadioType // Determines if we're handling FM or Digital
    
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
                    // Display different show titles based on whether it's FM or Digital
                    Text(currentShowTitle())
                        .font(.headline)
                        .redacted(reason: .placeholder)
                    Text("DJ Names") // You can update this later to show actual DJ names if needed
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
    
    // A helper function to switch between FM and Digital show titles
    private func currentShowTitle() -> String {
        switch radioType {
        case .fm:
            return liveFMShow.title ?? "Loading FM Show"
        case .digital:
            return liveDigitalShow.title ?? "Loading Digital Show"
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

class DigitalMediaBarManager: MediaBarManager, ObservableObject {
    private static let url = ""
    @Published var name: String = ""
    @Published var djs: [String] = [""]
    
    init() {
        // Connects self to InternetManager class
        InternetManager.connectDigitalShowManager(self as MediaBarManager)
    }
    
    func updateMedia(name: String, djs: [String]) {
        
    }
}

struct MediaBarView_Previews: PreviewProvider {
    static var previews: some View {
        MediaBarView(isPlaying: false, radioType: .fm)
            .environmentObject(CurrentFMShow()) // FM Show preview
            .environmentObject(CurrentDigitalShow()) // Digital Show preview
    }
}

