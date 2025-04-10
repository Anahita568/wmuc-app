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

    // track the current stream URL
    private var currentStreamURL: URL?
    
    // store the current title and artwork so remote commands can use them
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
    }
    // starts playing audiostream with now playing metadata
    func playStream(url: URL, title: String, coverImage: UIImage?) {
        stopPlayback() // stop any currently playing stream
        currentStreamURL = url
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        
        // save current title
        currentTitle = title
        
        // create an MPMediaItemArtwork object if a cover image is given
        if let image = coverImage {
            currentArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        } else {
            currentArtwork = nil
        }
        
        // update now playing info with the show title and artwork
        updateNowPlayingInfo(title: currentTitle, artwork: currentArtwork, duration: 0, currentTime: 0)
    }
    
    func pausePlayback() {
        player?.pause()
        isPlaying = false
        if let currentTime = player?.currentTime().seconds {
            updateNowPlayingInfo(title: currentTitle, artwork: currentArtwork, duration: 0, currentTime: currentTime)
        }
    }
    
    func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // handle play command
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self, let player = self.player else { return .commandFailed }
            player.play()
            self.isPlaying = true
            if let currentTime = player.currentTime().seconds as Double? {
                self.updateNowPlayingInfo(title: self.currentTitle, artwork: self.currentArtwork, duration: 0, currentTime: currentTime)
            }
            return .success
        }
        
        // handle pause command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self, let player = self.player else { return .commandFailed }
            player.pause()
            self.isPlaying = false
            if let currentTime = player.currentTime().seconds as Double? {
                self.updateNowPlayingInfo(title: self.currentTitle, artwork: self.currentArtwork, duration: 0, currentTime: currentTime)
            }
            return .success
        }
    }
    //update the now playing info displayed in lock screen/control center
    private func updateNowPlayingInfo(title: String?, artwork: MPMediaItemArtwork?, duration: TimeInterval, currentTime: TimeInterval) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title ?? "Unknown Show"
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        if let artwork = artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
