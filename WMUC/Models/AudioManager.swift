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

@MainActor
class AudioManager: ObservableObject {

    // MARK: - Singleton
    static let shared = AudioManager()
    private init() {
        configureAudioSession()
        setupRemoteCommandCenter()
        observeInterruptionNotifications()
        startLockScreenRefreshTimer()
        #if DEBUG
        //enableThirtySecondDebugRefresh()
        #endif
    }

    // MARK: - Published state
    @Published var isPlaying        : Bool       = false
    @Published var currentlyPlaying : RadioType? = nil

    // MARK: - Private state
    private var player          : AVPlayer?
    private var currentStreamURL: URL?
    private var currentTitle    : String?
    private var currentArtwork  : MPMediaItemArtwork?
    private var refreshTimer    : AnyCancellable?
    private var showCancellable : AnyCancellable?

    // MARK: - Playback API
    @MainActor
    func playStream(
        url          : URL,
        title        : String,
        coverImage   : UIImage?,
        type         : RadioType,
        showPublisher: AnyPublisher<CurrentShow, Never>
    ) {
        stopPlayback()                       // clears any previous stream

        currentStreamURL = url
        player           = AVPlayer(url: url)
        player?.play()

        isPlaying        = true
        currentlyPlaying = type
        currentTitle     = title
        currentArtwork = coverImage.map { image in
            MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }

        updateNowPlayingInfo(
            title      : currentTitle,
            artwork    : currentArtwork,
            duration   : 0,
            currentTime: 0
        )

        // Live metadata subscription
        showCancellable = showPublisher
            .receive(on: DispatchQueue.main)         // ensure main-actor
            .sink { [weak self] show in
                guard let self, self.isPlaying else { return }

                self.currentTitle = show.title ?? "Unknown Show"

                if let url = show.photoURL {
                    Task { [weak self] in
                        guard let self else { return }

                        if let (data, _) = try? await URLSession.shared.data(from: url),
                           let img       = UIImage(data: data) {

                            await MainActor.run {
                                self.currentArtwork = MPMediaItemArtwork(
                                    boundsSize: img.size) { _ in img }

                                self.updateNowPlayingInfo(
                                    title      : self.currentTitle,
                                    artwork    : self.currentArtwork,
                                    duration   : 0,
                                    currentTime: self.player?.currentTime().seconds ?? 0
                                )
                            }
                        }
                    }
                } else {
                    self.updateNowPlayingInfo(
                        title      : self.currentTitle,
                        artwork    : nil,
                        duration   : 0,
                        currentTime: self.player?.currentTime().seconds ?? 0
                    )
                }
            }
    }

    @MainActor
    func pausePlayback() {
        player?.pause()
        isPlaying = false

        updateNowPlayingInfo(
            title      : currentTitle,
            artwork    : currentArtwork,
            duration   : 0,
            currentTime: player?.currentTime().seconds ?? 0
        )
    }

    @MainActor
    func stopPlayback() {
        player?.pause()
        player            = nil
        isPlaying         = false
        currentlyPlaying  = nil
        showCancellable   = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - Manual metadata refresh (used by actors)
    @MainActor
    func refreshNowPlaying(title: String?, artworkURL: URL?) async {
        currentTitle = title ?? currentTitle

        if let url = artworkURL,
           let (data, _) = try? await URLSession.shared.data(from: url),
           let image     = UIImage(data: data) {

            currentArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }

        updateNowPlayingInfo(
            title      : currentTitle,
            artwork    : currentArtwork,
            duration   : 0,
            currentTime: player?.currentTime().seconds ?? 0
        )
    }

    // MARK: - Now Playing Info (main-actor-only)
    private func updateNowPlayingInfo(
        title      : String?,
        artwork    : MPMediaItemArtwork?,
        duration   : TimeInterval,
        currentTime: TimeInterval
    ) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle              : title ?? "Unknown Show",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration   : duration,
            MPNowPlayingInfoPropertyPlaybackRate  : isPlaying ? 1.0 : 0.0
        ]
        if let artwork { info[MPMediaItemPropertyArtwork] = artwork }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Remote Command Center
    private func setupRemoteCommandCenter() {
        let cmd = MPRemoteCommandCenter.shared()

        cmd.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.player?.play()
            self.isPlaying = true
            Task { @MainActor in
                self.updateNowPlayingInfo(
                    title      : self.currentTitle,
                    artwork    : self.currentArtwork,
                    duration   : 0,
                    currentTime: self.player?.currentTime().seconds ?? 0
                )
            }
            return .success
        }

        cmd.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.player?.pause()
            self.isPlaying = false
            Task { @MainActor in
                self.updateNowPlayingInfo(
                    title      : self.currentTitle,
                    artwork    : self.currentArtwork,
                    duration   : 0,
                    currentTime: self.player?.currentTime().seconds ?? 0
                )
            }
            return .success
        }
    }

    // MARK: - Periodic lock-screen refresh
    private func startLockScreenRefreshTimer() {
        let calendar     = Calendar.current
        let nextFullHour = calendar.nextDate(
            after         : Date(),
            matching      : DateComponents(minute: 0, second: 0),
            matchingPolicy: .nextTime) ?? Date().addingTimeInterval(3600)

        let delay = nextFullHour.timeIntervalSinceNow
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            Task { await self?.forceNowPlayingRefresh() }
            self?.scheduleRepeatingControlBarRefresh()
        }
    }

    private func scheduleRepeatingControlBarRefresh() {
        refreshTimer = Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.forceNowPlayingRefresh() }
            }
    }

    @MainActor
    private func forceNowPlayingRefresh() async {
        updateNowPlayingInfo(
            title      : currentTitle,
            artwork    : currentArtwork,
            duration   : 0,
            currentTime: player?.currentTime().seconds ?? 0
        )
    }

    // MARK: - Helpers
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    private func observeInterruptionNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name    : AVAudioSession.interruptionNotification,
            object  : nil
        )
    }

    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard
            let info      = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type      = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        if type == .began { isPlaying = false }
    }
}

#if !DEBUG       // remove or flip to false for App-Store builds


extension AudioManager {

   
    func enableThirtySecondDebugRefresh() {

        // Cancel the normal 1-hour timer if it exists
        refreshTimer?.cancel()

        // New 30-second timer on the main actor
        refreshTimer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                // Log what we’re about to push to the lock screen
                let artDesc = (self.currentArtwork != nil) ? "artwork-set" : "nil"
                let name    = self.currentTitle ?? "Unknown Show"
                print("🛠 [DebugRefresh] Pushing “\(name)”  artwork: \(artDesc)")

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
