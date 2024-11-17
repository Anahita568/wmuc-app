import SwiftUI

struct MediaBarView: View {
    @State var isPlaying: Bool
    @EnvironmentObject var liveFMShow: CurrentFMShow
    @EnvironmentObject var liveDigitalShow: CurrentDigitalShow
    var radioType: RadioType // Determines if we're handling FM or Digital
    
    var body: some View {
        ZStack {
            Color.white
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -2) // Add shadow to "float" the bar
                .ignoresSafeArea(edges: .bottom)
            
            HStack {
                // Album Cover or Placeholder
                Image("albumPlaceholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 55, height: 55)
                    .cornerRadius(7)
                
                // Show Title and DJ Name
                VStack(alignment: .leading) {
                    Text(currentShowTitle())
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(currentDJName())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 5)
                
                // Play/Pause Button
                Button(action: {
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
            }
            .padding()
        }
        .frame(height: 70) // Fixed height for the MediaBar
        .background(Color.white) // Background color
        .cornerRadius(15) // Rounded top corners
    }
    
    // Function to determine the current show title
    private func currentShowTitle() -> String {
        switch radioType {
        case .fm:
            return liveFMShow.title ?? "Loading FM Show"
        case .digital:
            return liveDigitalShow.title ?? "Loading Digital Show"
        }
    }
    
    // Function to determine the current DJ name //Fix later
    private func currentDJName() -> String {
        switch radioType {
        case .fm:
            return "Placeholder FM DJ"
        case .digital:
            return "Placeholder Digital DJ"
        }
    }
}


struct MediaBarView_Previews: PreviewProvider {
    static var previews: some View {
        MediaBarView(isPlaying: true, radioType: .fm)
            .environmentObject(CurrentFMShow())
            .environmentObject(CurrentDigitalShow())
            .previewLayout(.sizeThatFits)
    }
}


