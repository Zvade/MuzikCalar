import Foundation
import AVFoundation
import MediaPlayer
import Combine
import SwiftUI

@MainActor
final class AudioPlayerViewModel: NSObject, ObservableObject {

    // MARK: - Published State (View bunları dinler)
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackDirection: PlaybackDirection = .none // slide animasyonu için
    @Published var isNowPlayingPresented: Bool = false          // sheet/kart geçişi için

    enum PlaybackDirection {
        case forward, backward, none
    }

    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var queue: [Song] = []
    private var currentIndex: Int = 0

    // MARK: - Setup

    override init() {
        super.init()
        configureAudioSession()
        configureRemoteCommandCenter()
    }

    /// Uygulama sessizken bile arka planda çalabilmesi için audio session ayarı.
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session hatası: \(error)")
        }
    }

    // MARK: - Public API

    func setQueue(_ songs: [Song], startAt song: Song) {
        queue = songs
        if let index = songs.firstIndex(of: song) {
            currentIndex = index
        }
        play(song: song)
    }

    func play(song: Song) {
        do {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: song.fileURL)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()

            currentSong = song
            duration = player?.duration ?? 0
            currentTime = 0
            isPlaying = true

            startTimer()
            updateNowPlayingInfo()
        } catch {
            print("Oynatma hatası: \(error)")
        }
    }

    func togglePlayPause() {
        guard let player else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
        updateNowPlayingInfo()
    }

    func playNext() {
        guard !queue.isEmpty else { return }
        playbackDirection = .forward
        currentIndex = (currentIndex + 1) % queue.count
        play(song: queue[currentIndex])
    }

    func playPrevious() {
        guard !queue.isEmpty else { return }
        // 3 saniyeden fazla dinlendiyse başa sar, değilse önceki şarkıya geç (Spotify davranışı)
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        playbackDirection = .backward
        currentIndex = (currentIndex - 1 + queue.count) % queue.count
        play(song: queue[currentIndex])
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
        updateNowPlayingInfo()
    }

    func skip(seconds: TimeInterval) {
        let newTime = min(max((player?.currentTime ?? 0) + seconds, 0), duration)
        seek(to: newTime)
    }

    // MARK: - Timer (slider güncellemesi)

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                self.currentTime = player.currentTime
            }
        }
    }

    // MARK: - Now Playing / Lock Screen

    private func configureRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            self?.togglePlayPause(); return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause(); return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext(); return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPrevious(); return .success
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: event.positionTime)
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let currentSong else { return }
        let info: [String: Any] = [
            MPMediaItemPropertyTitle: currentSong.title,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        // Albüm kapağı yoksa varsayılan ikon kullanılabilir (opsiyonel MPMediaItemArtwork eklenebilir)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayerViewModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.playNext()
        }
    }
}
