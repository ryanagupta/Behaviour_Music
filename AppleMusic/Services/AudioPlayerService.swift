import Foundation
import AVFoundation
import MediaPlayer
import SwiftUI

public enum RepeatMode: String, CaseIterable {
    case off
    case all
    case one
}

/// Core audio playback engine supporting background playback, lock screen controls, and queue management
@Observable
public final class AudioPlayerService: NSObject {
    public static let shared = AudioPlayerService()

    // Playback state
    public var currentTrack: Track?
    public var isPlaying: Bool = false
    public var isLoading: Bool = false
    public var currentTime: TimeInterval = 0
    public var duration: TimeInterval = 0
    public var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }

    // Queue & Playback Modes
    public var queue: [Track] = []
    public var originalQueue: [Track] = []
    public var currentIndex: Int = 0
    public var repeatMode: RepeatMode = .off
    public var isShuffled: Bool = false

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var playerItemObserver: NSKeyValueObservation?

    public override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommands()
    }

    deinit {
        removeTimeObserver()
    }

    // MARK: - Audio Session Setup (Background Playback)

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to activate background audio session: \(error)")
        }
    }

    // MARK: - Remote Commands (Lock Screen & Control Center)

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.skipNext()
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.skipPrevious()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.seek(to: positionEvent.positionTime)
            return .success
        }
    }

    // MARK: - Playback Controls

    public func playTrack(_ track: Track, in queue: [Track]? = nil) {
        if let newQueue = queue, !newQueue.isEmpty {
            self.queue = newQueue
            self.originalQueue = newQueue
            self.currentIndex = newQueue.firstIndex(where: { $0.id == track.id }) ?? 0
        } else if self.queue.isEmpty {
            self.queue = [track]
            self.originalQueue = [track]
            self.currentIndex = 0
        } else {
            self.currentIndex = self.queue.firstIndex(where: { $0.id == track.id }) ?? 0
        }

        self.currentTrack = track
        self.currentTime = 0
        self.duration = track.duration > 0 ? track.duration : 180
        self.isLoading = true

        StorageService.shared.recordPlay(track: track)
        Task {
            await LyricsService.shared.fetchLyrics(for: track)
        }

        Task { [weak self] in
            guard let self = self else { return }
            guard let streamURL = await StreamResolverService.shared.resolveStreamURL(for: track) else {
                await MainActor.run {
                    self.isLoading = false
                    print("Failed to resolve stream for track: \(track.title)")
                }
                return
            }

            await MainActor.run {
                self.setupPlayer(with: streamURL)
            }
        }
    }

    private func setupPlayer(with url: URL) {
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        self.player?.volume = self.volume

        // Observe Item duration
        playerItemObserver = playerItem.observe(\.duration, options: [.new]) { [weak self] item, _ in
            let seconds = item.duration.seconds
            if !seconds.isNaN && seconds > 0 {
                DispatchQueue.main.async {
                    self?.duration = seconds
                    self?.updateNowPlayingInfo()
                }
            }
        }

        // Periodic Time Observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let seconds = time.seconds
            if !seconds.isNaN {
                self.currentTime = seconds
                self.updateNowPlayingPlaybackValues()
            }
        }

        // Auto Advance when song ends
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        self.player?.play()
        self.isPlaying = true
        self.isLoading = false
        self.updateNowPlayingInfo()
    }

    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    public func play() {
        guard let player = player else {
            if let current = currentTrack {
                playTrack(current)
            }
            return
        }
        player.play()
        isPlaying = true
        updateNowPlayingPlaybackValues()
    }

    public func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingPlaybackValues()
    }

    public func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: max(0, min(time, duration)), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        self.currentTime = time
        updateNowPlayingPlaybackValues()
    }

    public func skipNext() {
        guard !queue.isEmpty else { return }

        if repeatMode == .one {
            seek(to: 0)
            play()
            return
        }

        if currentIndex < queue.count - 1 {
            currentIndex += 1
            playTrack(queue[currentIndex])
        } else if repeatMode == .all {
            currentIndex = 0
            playTrack(queue[0])
        } else {
            pause()
            seek(to: 0)
        }
    }

    public func skipPrevious() {
        if currentTime > 3.0 {
            seek(to: 0)
            return
        }

        if currentIndex > 0 {
            currentIndex -= 1
            playTrack(queue[currentIndex])
        } else {
            seek(to: 0)
        }
    }

    public func toggleShuffle() {
        isShuffled.toggle()
        if isShuffled {
            guard let current = currentTrack else { return }
            var remaining = queue.filter { $0.id != current.id }
            remaining.shuffle()
            queue = [current] + remaining
            currentIndex = 0
        } else {
            queue = originalQueue
            if let current = currentTrack {
                currentIndex = queue.firstIndex(where: { $0.id == current.id }) ?? 0
            }
        }
    }

    public func toggleRepeat() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    @objc private func playerItemDidReachEnd() {
        skipNext()
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        playerItemObserver?.invalidate()
        playerItemObserver = nil
    }

    // MARK: - Now Playing Info Center (Lock Screen / Dynamic Island)

    private func updateNowPlayingInfo() {
        guard let track = currentTrack else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artistName,
            MPMediaItemPropertyAlbumTitle: track.albumName,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        // Load high-res artwork asynchronously for lock screen
        if let artworkURL = track.highResArtwork(size: 600) {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: artworkURL),
                   let image = UIImage(data: data) {
                    let mpArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    await MainActor.run {
                        info[MPMediaItemPropertyArtwork] = mpArtwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    }
                }
            }
        }
    }

    private func updateNowPlayingPlaybackValues() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
