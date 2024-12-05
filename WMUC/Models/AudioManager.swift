//
//  AudioManager.swift
//  WMUC
//
//  Created by Anahita on 12/4/24.
//

import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVPlayer?
    @Published var isPlaying: Bool = false

        private init() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                print("Audio session configured")
            } catch {
                print("Failed to configure audio session: \(error.localizedDescription)")
            }
        }


    // Start playing the audio from the given URL
    func playStream(url: URL) {
        stopPlayback() // Stop any currently playing stream
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
    }

    // Pause the current playback
    func pausePlayback() {
        player?.pause()
        isPlaying = false
    }

    // Stop the player completely
    func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
    }
}
