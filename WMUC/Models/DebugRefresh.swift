//
//  DebugRefresh.swift
//  WMUC
//
//  Created by Anahita on 5/8/25.
//



import Foundation
import Combine

#if DEBUG       // ───── remove or flip to false for App-Store builds
import MediaPlayer

extension AudioManager {

    /// Call **once** in `AudioManager`’s `init()` when you want the fast cycle.
    func enableThirtySecondDebugRefresh() {

        // Cancel the normal 1-hour timer if it exists
        refreshTimer?.cancel()

        // New 30-second timer on the main actor
        refreshTimer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                // Log what we’re about to push to the lock screen
                let artURL = self.currentArtwork?.imageLoader?().description ?? "nil"
                let name   = self.currentTitle ?? "Unknown Show"
                print("🛠 [DebugRefresh] Pushing “\(name)”  artworkURL: \(artURL)")

                // Refresh the metadata
                Task { @MainActor in
                    self.updateNowPlayingInfo(
                        title      : self.currentTitle,
                        artwork    : self.currentArtwork,
                        duration   : 0,
                        currentTime: self.player?.currentTime().seconds ?? 0
                    )
                }
            }

        print(" [DebugRefresh] 30-second lock-screen refresh ENABLED")
    }
}
#endif
