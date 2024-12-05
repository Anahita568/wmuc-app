import SwiftUI

struct MediaBarView: View {
    @EnvironmentObject var liveFMShow: CurrentFMShow
    @EnvironmentObject var liveDigitalShow: CurrentDigitalShow
    var isPlaying: Bool
    var radioType: RadioType
    var onPlayPauseTapped: () -> Void // Closure for play/pause action

    var body: some View {
        if !isShowLoading() {
            ZStack {
                // Background for the bar with shadow effect
                Color.white
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)

                HStack {
                    // Album Cover
                    CurrentShowWidgetPhotoCover(photoURL: currentPhotoURL(), width: .constant(UIScreen.main.bounds.width * 0.40))

                    // Show Details
                    VStack(alignment: .leading) {
                        Text(currentShowTitle())
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(.black)

                        Text(currentDJName())
                            .font(.subheadline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)

                    // Play/Pause Button
                    Button(action: {
                        handlePlayPause()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 70)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40) // Adjust this value to move the bar lower
            .padding(.top, 30)    // Add a bit of spacing to push it further down from other elements
        } else {
            // Show a loading placeholder
            Text("Loading Show...")
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
        }
    }

    private func handlePlayPause() {
        onPlayPauseTapped() // Trigger the closure passed from the parent

        // Play or pause the appropriate stream
        if isPlaying {
            AudioManager.shared.pausePlayback()
        } else {
            let streamURL = currentStreamURL()
            if let url = streamURL {
                AudioManager.shared.playStream(url: url)
            } else {
                print("Stream URL is unavailable.")
            }
        }
    }

    // Helper function to determine if the show data is loading
    private func isShowLoading() -> Bool {
        switch radioType {
        case .fm:
            return liveFMShow.isLoading
        case .digital:
            return liveDigitalShow.isLoading
        }
    }

    // Helper function to get the stream URL
    private func currentStreamURL() -> URL? {
        switch radioType {
        case .fm:
            return URL(string: "https://wmuc.umd.edu:8443/wmuc-hq")
        case .digital:
            return URL(string: "https://wmuc.umd.edu:8443/wmuc2-high")
        }
    }

    // Helper function to get the photo URL
    private func currentPhotoURL() -> URL? {
        switch radioType {
        case .fm:
            return liveFMShow.photoURL
        case .digital:
            return liveDigitalShow.photoURL
        }
    }

    // Helper function to get the current show title
    private func currentShowTitle() -> String {
        switch radioType {
        case .fm:
            return liveFMShow.title ?? "FM Show"
        case .digital:
            return liveDigitalShow.title ?? "Digital Show"
        }
    }

    // Helper function to get the current DJ name
    private func currentDJName() -> String {
        switch radioType {
        case .fm:
            if let djs = liveFMShow.djs, !djs.isEmpty {
                return djs.joined(separator: ", ")
            } else {
                return "Unknown FM DJ"
            }
        case .digital:
            if let djs = liveDigitalShow.djs, !djs.isEmpty {
                return djs.joined(separator: ", ")
            } else {
                return "Unknown Digital DJ"
            }
        }
    }
}
