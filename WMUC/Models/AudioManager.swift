//
//  AudioManager.swift
//  WMUC
//
//  Created by Anahita on 12/4/24.
//
import AVFoundation
import MediaPlayer
import UIKit
import Combine

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVPlayer?
    
    @Published var isPlaying: Bool = false
    @Published var currentlyPlaying: RadioType? = nil

    private var currentStreamURL: URL?
    private var currentTitle: String?
    private var currentArtwork: MPMediaItemArtwork?
    
    private var showCancellable: AnyCancellable? // track updates to title/image

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

    // MARK: - Playback
    
    func playStream(
        url: URL,
        title: String,
        coverImage: UIImage?,
        type: RadioType,
        showPublisher: AnyPublisher<CurrentShow, Never>
    ) {
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

        // observe the show for live updates
        showCancellable = showPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                guard let self = self, self.isPlaying else { return }
                self.currentTitle = show.title ?? "Unknown Show"

                if let url = show.photoURL {
                    Task {
                        if let (data, _) = try? await URLSession.shared.data(from: url),
                           let image = UIImage(data: data) {
                            self.currentArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                            self.updateNowPlayingInfo(
                                title: self.currentTitle,
                                artwork: self.currentArtwork,
                                duration: 0,
                                currentTime: self.player?.currentTime().seconds ?? 0
                            )
                        }
                    }
                } else {
                    self.updateNowPlayingInfo(
                        title: self.currentTitle,
                        artwork: nil,
                        duration: 0,
                        currentTime: self.player?.currentTime().seconds ?? 0
                    )
                }
            }
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
        showCancellable = nil // cancel updates
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - Now Playing Info

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

    // MARK: - Remote Command Handling

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

    // MARK: - Interruption Handling

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
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            print("Audio session interrupted")
            isPlaying = false
        case .ended:
            print("Audio session interruption ended")
            // Optionally auto-resume
        @unknown default:
            break
        }
    }
}
