//
//  AudioManager.swift
//  WMUC
//
//  Created by Anahita on 12/4/24.
//
import AVFoundation
import MediaPlayer
import UIKit

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVPlayer?
    
    @Published var isPlaying: Bool = false
    @Published var currentlyPlaying: RadioType? = nil

    private var currentStreamURL: URL?
    private var currentTitle: String?
    private var currentArtwork: MPMediaItemArtwork?
    
    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
        setupRemoteCommandCenter()
        observeInterruptionNotifications()
    }

    func playStream(url: URL, title: String, coverImage: UIImage?, type: RadioType) {
        stopPlayback()
        currentStreamURL = url
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        currentlyPlaying = type
        currentTitle = title
        
        if let image = coverImage {
            currentArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        } else {
            currentArtwork = nil
        }
        
        updateNowPlayingInfo(title: currentTitle, artwork: currentArtwork, duration: 0, currentTime: 0)
    }

    func pausePlayback() {
        player?.pause()
        isPlaying = false
        let currentTime = player?.currentTime().seconds ?? 0
        updateNowPlayingInfo(title: currentTitle, artwork: currentArtwork, duration: 0, currentTime: currentTime)
    }

    func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
        currentlyPlaying = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self, let player = self.player else { return .commandFailed }
            player.play()
            self.isPlaying = true
            let currentTime = player.currentTime().seconds
            self.updateNowPlayingInfo(title: self.currentTitle, artwork: self.currentArtwork, duration: 0, currentTime: currentTime)
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self, let player = self.player else { return .commandFailed }
            player.pause()
            self.isPlaying = false
            let currentTime = player.currentTime().seconds
            self.updateNowPlayingInfo(title: self.currentTitle, artwork: self.currentArtwork, duration: 0, currentTime: currentTime)
            return .success
        }
    }

    private func updateNowPlayingInfo(title: String?, artwork: MPMediaItemArtwork?, duration: TimeInterval, currentTime: TimeInterval) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: title ?? "Unknown Show",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration
        ]
        if let artwork = artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Audio Session Interruption

    private func observeInterruptionNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            print("Audio session interrupted")
            isPlaying = false
        case .ended:
            print("Audio session interruption ended")
            // Optionally resume
        @unknown default:
            break
        }
    }
}
