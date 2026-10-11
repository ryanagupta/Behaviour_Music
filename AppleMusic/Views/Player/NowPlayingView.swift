import SwiftUI

/// Mode for Now Playing screen
public enum NowPlayingMode {
    case artwork
    case lyrics
    case queue
}

/// 1-to-1 Apple Music Now Playing View matching iOS 18 screenshot (Image 3)
public struct NowPlayingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var audio = AudioPlayerService.shared
    @State private var storage = StorageService.shared
    @State private var lyricsService = LyricsService.shared
    @State private var mode: NowPlayingMode = .artwork

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic animated mesh background
                AnimatedMeshBackground(artworkURL: audio.currentTrack?.highResArtwork(size: 600))

                VStack(spacing: 0) {
                    // Top drag grabber
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    // Main display area: Artwork, Lyrics, or Queue
                    Group {
                        switch mode {
                        case .artwork:
                            artworkSection(geometry: geometry)
                        case .lyrics:
                            LyricsView(
                                lyrics: lyricsService.currentLyrics,
                                currentTime: audio.currentTime,
                                onSeek: { audio.seek(to: $0) }
                            )
                        case .queue:
                            QueueView()
                        }
                    }
                    .frame(maxHeight: .infinity)

                    // Track info, scrubber, transport controls, volume, and bottom action bar
                    bottomControlsSection
                }
                .padding(.horizontal, 24)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Artwork Section

    @ViewBuilder
    private func artworkSection(geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width - 48, geometry.size.height * 0.44)

        VStack {
            Spacer()

            if let track = audio.currentTrack {
                ArtworkImageView(
                    url: track.highResArtwork(size: 1000),
                    cornerRadius: 16,
                    shadowRadius: audio.isPlaying ? 24 : 10
                )
                .frame(width: size, height: size)
                .scaleEffect(audio.isPlaying ? 1.0 : 0.86)
                .animation(.spring(response: 0.5, dampingFraction: 0.72), value: audio.isPlaying)
            }

            Spacer()
        }
    }

    // MARK: - Bottom Controls Section (Matching Image 3)

    private var bottomControlsSection: some View {
        VStack(spacing: 16) {
            if let track = audio.currentTrack {
                // User listening tag pill (Image 3: "[avatar] Jasmine Garcia")
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.yellow)
                        Text("Personal Audio")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())

                    Spacer()
                }

                // Title, Artist, Star, and Ellipsis row
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(track.title)
                            .font(.system(size: 23, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(track.artistName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white.opacity(0.65))
                            .lineLimit(1)
                    }

                    Spacer()

                    // Star Favorite button & Ellipsis buttons in frosted circles (Image 3)
                    HStack(spacing: 10) {
                        Button {
                            storage.toggleFavorite(track: track)
                        } label: {
                            let isFav = storage.isFavorite(track: track)
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Image(systemName: isFav ? "star.fill" : "star")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(isFav ? .yellow : .white.opacity(0.8))
                            }
                        }

                        Menu {
                            Button {
                                audio.playTrack(track)
                            } label: {
                                Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                            }

                            Button {
                                Task {
                                    await storage.downloadTrack(track)
                                }
                            } label: {
                                Label("Download", systemImage: "arrow.down.circle")
                            }

                            ShareLink(item: "Listening to \(track.title) by \(track.artistName) on Apple Music!") {
                                Label("Share Song...", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Image(systemName: "ellipsis")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                    }
                }
            }

            // Scrubber Bar
            ScrubberBar(
                currentTime: audio.currentTime,
                duration: audio.duration,
                onSeek: { audio.seek(to: $0) }
            )

            // Transport Controls: Backward, Giant Pause/Play, Forward
            HStack(spacing: 52) {
                Button {
                    audio.skipPrevious()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }

                Button {
                    audio.togglePlayPause()
                } label: {
                    ZStack {
                        if audio.isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.4)
                        } else {
                            Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 46))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 56, height: 56)
                }

                Button {
                    audio.skipNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }
            }
            .padding(.vertical, 6)

            // Volume Slider
            VolumeSliderView(volume: Binding(
                get: { audio.volume },
                set: { audio.volume = $0 }
            ))
            .padding(.horizontal, 6)

            // Bottom Action Bar matching Image 3:
            // [Lyrics]      [ (c) | (person.2 3) ]      [Queue]
            HStack {
                // Lyrics toggle
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        mode = (mode == .lyrics) ? .artwork : .lyrics
                    }
                } label: {
                    Image(systemName: mode == .lyrics ? "quote.bubble.fill" : "quote.bubble")
                        .font(.system(size: 21))
                        .foregroundStyle(mode == .lyrics ? .white : .white.opacity(0.55))
                        .frame(width: 44, height: 44)
                }

                Spacer()

                // Center SharePlay & AirPlay Pill
                HStack(spacing: 8) {
                    Image(systemName: "airplayaudio")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))

                    Divider()
                        .frame(height: 12)
                        .background(Color.white.opacity(0.3))

                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 13))
                        Text("1")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())

                Spacer()

                // Queue toggle
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        mode = (mode == .queue) ? .artwork : .queue
                    }
                } label: {
                    Image(systemName: mode == .queue ? "list.bullet.circle.fill" : "list.bullet")
                        .font(.system(size: 21))
                        .foregroundStyle(mode == .queue ? .white : .white.opacity(0.55))
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.bottom, 16)
        }
    }
}
