import SwiftUI

/// 1-to-1 Apple Music Album Detail View matching Image 1 (The Weeknd) and Image 2 (SZA)
public struct AlbumDetailView: View {
    let album: Album
    @Environment(\.dismiss) private var dismiss

    @State private var tracks: [Track] = []
    @State private var isLoading = false
    @State private var isDescriptionExpanded = false
    @State private var audio = AudioPlayerService.shared
    @State private var storage = StorageService.shared

    // Background color dynamically matched to album tone
    private var ambientColor: Color {
        if album.name.localizedCaseInsensitiveContains("tomorrow") || album.artistName.localizedCaseInsensitiveContains("weeknd") {
            return Color(hex: "#EFECE6")
        } else if album.name.localizedCaseInsensitiveContains("sos") || album.artistName.localizedCaseInsensitiveContains("sza") {
            return Color(hex: "#091D34")
        } else {
            return Color(uiColor: .systemBackground)
        }
    }

    private var isDarkTone: Bool {
        ambientColor == Color(hex: "#091D34")
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Artwork & Navigation Bar overlay (Image 1 & 2)
                heroArtworkHeader

                // Album Title, Artist, and Badges
                albumMetadataSection

                // Action Buttons Trio: [ Shuffle ]  [ ▶ Play ]  [ + ]
                actionButtonsTrio

                // Editorial description with "MORE" expander
                editorialReviewSection

                // Tracklist
                tracklistSection

                // Bottom spacer for MiniPlayer and Floating Tab Bar
                Spacer().frame(height: 140)
            }
        }
        .background(ambientColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if album.tracks.isEmpty {
                isLoading = true
                tracks = await AppleCatalogService.shared.fetchAlbumTracks(albumId: album.id)
                isLoading = false
            } else {
                tracks = album.tracks
            }
        }
    }

    // MARK: - Hero Artwork Header (Image 1 & 2)

    private var heroArtworkHeader: some View {
        ZStack(alignment: .top) {
            // Full bleed hero artwork with downward gradient fade
            GeometryReader { proxy in
                let width = proxy.size.width
                ZStack(alignment: .bottom) {
                    ArtworkImageView(
                        url: album.highResArtwork(size: 1000),
                        cornerRadius: 0,
                        shadowRadius: 0
                    )
                    .frame(width: width, height: width * 1.05)
                    .clipped()

                    // Smooth gradient fade into ambient background
                    LinearGradient(
                        colors: [
                            Color.clear,
                            ambientColor.opacity(0.4),
                            ambientColor
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: width * 0.6)
                }
            }
            .frame(height: 380)

            // Top Frosted Navigation Controls (Back button & Share/More Pill)
            HStack {
                // Back Button (Frosted Circle `<`)
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(isDarkTone ? 0.35 : 0.15))
                            .frame(width: 38, height: 38)

                        Image(systemName: "chevron.backward")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isDarkTone ? .white : .black)
                    }
                }

                Spacer()

                // Share & Ellipsis Pill
                HStack(spacing: 12) {
                    ShareLink(item: "Check out \(album.name) by \(album.artistName) on Apple Music!") {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(isDarkTone ? .white : .black)
                    }

                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isDarkTone ? .white : .black)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.black.opacity(isDarkTone ? 0.35 : 0.15))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 54)
        }
    }

    // MARK: - Album Metadata Section

    private var albumMetadataSection: some View {
        VStack(spacing: 6) {
            Text(album.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(isDarkTone ? .white : .black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Text(album.artistName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(isDarkTone ? .white.opacity(0.85) : .black.opacity(0.8))

            // Badges Line: "R&B/Soul • 2025 • [Dolby Atmos] • [Hi-Res Lossless]"
            HStack(spacing: 6) {
                Text(album.genre ?? "R&B/Soul")
                Text("•")
                Text(album.releaseYear?.prefix(4) ?? "2024")
                Text("•")
                HStack(spacing: 3) {
                    Image(systemName: "wave.3.forward")
                        .font(.system(size: 10))
                    Text("Dolby Atmos")
                        .font(.system(size: 11, weight: .semibold))
                }
                Text("•")
                HStack(spacing: 2) {
                    Image(systemName: "waveform")
                        .font(.system(size: 9))
                    Text("Hi-Res Lossless")
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(isDarkTone ? .white.opacity(0.6) : .black.opacity(0.55))
            .padding(.top, 2)
        }
        .padding(.top, 4)
    }

    // MARK: - Action Buttons Trio: [ Shuffle ]  [ ▶ Play ]  [ + ]

    private var actionButtonsTrio: some View {
        HStack(spacing: 16) {
            // Shuffle Button (Frosted Circle)
            Button {
                if !tracks.isEmpty {
                    var shuffled = tracks
                    shuffled.shuffle()
                    if let first = shuffled.first {
                        audio.playTrack(first, in: shuffled)
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(isDarkTone ? 0.35 : 0.08))
                        .frame(width: 48, height: 48)

                    Image(systemName: "shuffle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isDarkTone ? .white : .black)
                }
            }

            // Wide Play Capsule [ ▶ Play ]
            Button {
                if let first = tracks.first {
                    audio.playTrack(first, in: tracks)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 15))
                    Text("Play")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(isDarkTone ? .black : .white)
                .frame(width: 140, height: 48)
                .background(isDarkTone ? Color.white : Color.black)
                .clipShape(Capsule())
            }

            // Add Button (Frosted Circle +)
            Button {
                // Add album to library
                for track in tracks {
                    storage.toggleFavorite(track: track)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(isDarkTone ? 0.35 : 0.08))
                        .frame(width: 48, height: 48)

                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isDarkTone ? .white : .black)
                }
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Editorial Review

    private var editorialReviewSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isDescriptionExpanded
                 ? "On what was meant to be the last date of his 2022 tour, The Weeknd took the stage at Inglewood's SoFi Stadium for an unforgettable stadium experience. A masterclass in modern pop and R&B, delivering atmospheric synth epics and raw vocal perfection."
                 : "On what was meant to be the last date of his 2022 tour, The Weeknd took the stage at Inglewood...")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(isDarkTone ? .white.opacity(0.8) : .black.opacity(0.75))
                .lineLimit(isDescriptionExpanded ? nil : 2)

            Button {
                withAnimation {
                    isDescriptionExpanded.toggle()
                }
            } label: {
                Text(isDescriptionExpanded ? "LESS" : "MORE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isDarkTone ? .white : .black)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Tracklist Section (Image 1 & 2)

    private var tracklistSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                let isPlayingThis = (audio.currentTrack?.id == track.id)

                HStack(spacing: 14) {
                    // Number or Equalizer
                    if isPlayingThis {
                        Image(systemName: "waveform")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppleMusicTheme.accent)
                            .frame(width: 24, alignment: .center)
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(isDarkTone ? .white.opacity(0.4) : .black.opacity(0.4))
                            .frame(width: 24, alignment: .center)
                    }

                    // Track title & artist
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(track.title)
                                .font(.system(size: 16, weight: isPlayingThis ? .bold : .regular))
                                .foregroundStyle(isPlayingThis ? AppleMusicTheme.accent : (isDarkTone ? .white : .black))
                                .lineLimit(1)

                            if track.isExplicit {
                                Image(systemName: "e.square.fill")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(isDarkTone ? .white.opacity(0.6) : .black.opacity(0.5))
                            }
                        }

                        Text(track.artistName)
                            .font(.system(size: 13))
                            .foregroundStyle(isDarkTone ? .white.opacity(0.6) : .black.opacity(0.5))
                            .lineLimit(1)
                    }

                    Spacer()

                    // Context Menu
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15))
                        .foregroundStyle(isDarkTone ? .white.opacity(0.5) : .black.opacity(0.4))
                        .frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
                .onTapGesture {
                    audio.playTrack(track, in: tracks)
                }

                Divider()
                    .background(isDarkTone ? Color.white.opacity(0.12) : Color.black.opacity(0.08))
                    .padding(.leading, 58)
            }
        }
        .padding(.top, 14)
    }
}
