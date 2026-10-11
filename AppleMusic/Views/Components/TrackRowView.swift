import SwiftUI

/// Standard Apple Music track row with artwork, title, explicit indicator, and context actions
public struct TrackRowView: View {
    let track: Track
    var showArtwork: Bool = true
    var showTrackNumber: Bool = false
    var trackNumber: Int? = nil
    var onPlay: (() -> Void)? = nil

    @State private var storage = StorageService.shared
    @State private var audio = AudioPlayerService.shared
    @State private var showPlaylistSheet = false

    private var isCurrentTrack: Bool {
        audio.currentTrack?.id == track.id
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Track Number or Artwork
            if showTrackNumber, let num = trackNumber ?? track.trackNumber {
                Text("\(num)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .center)
            } else if showArtwork {
                ZStack {
                    ArtworkImageView(url: track.highResArtwork(size: 160), cornerRadius: 6, shadowRadius: 0)
                        .frame(width: 48, height: 48)

                    if isCurrentTrack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.45))
                            .frame(width: 48, height: 48)

                        Image(systemName: audio.isPlaying ? "waveform" : "pause.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .symbolEffect(.variableColor.iterative, isActive: audio.isPlaying)
                    }
                }
            }

            // Title and Subtitle
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(track.title)
                        .font(AppleMusicTheme.trackTitleFont)
                        .fontWeight(isCurrentTrack ? .semibold : .regular)
                        .foregroundStyle(isCurrentTrack ? AppleMusicTheme.accent : .primary)
                        .lineLimit(1)

                    if track.isExplicit {
                        Image(systemName: "e.square.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Text("\(track.artistName) — \(track.albumName)")
                    .font(AppleMusicTheme.trackArtistFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Downloaded indicator if cached
            if track.isDownloaded || storage.downloadedTracks.contains(where: { $0.id == track.id }) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            // Context Menu Button
            Menu {
                Button {
                    audio.playTrack(track)
                } label: {
                    Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                }

                Button {
                    storage.toggleFavorite(track: track)
                } label: {
                    let isFav = storage.isFavorite(track: track)
                    Label(isFav ? "Unlove" : "Love", systemImage: isFav ? "heart.slash" : "heart")
                }

                Button {
                    showPlaylistSheet = true
                } label: {
                    Label("Add to a Playlist...", systemImage: "text.badge.plus")
                }

                Button {
                    Task {
                        await storage.downloadTrack(track)
                    }
                } label: {
                    Label("Download", systemImage: "arrow.down.circle")
                }

                ShareLink(item: "Check out \(track.title) by \(track.artistName) on Apple Music!") {
                    Label("Share Song...", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onPlay?() ?? audio.playTrack(track)
        }
        .sheet(isPresented: $showPlaylistSheet) {
            AddToPlaylistSheet(track: track)
        }
    }
}

/// Modal for adding a track to a playlist
private struct AddToPlaylistSheet: View {
    let track: Track
    @Environment(\.dismiss) private var dismiss
    @State private var storage = StorageService.shared
    @State private var newPlaylistTitle = ""
    @State private var showingCreateAlert = false

    var body: some View {
        NavigationStack {
            List {
                Button {
                    showingCreateAlert = true
                } label: {
                    Label("New Playlist...", systemImage: "plus")
                        .foregroundStyle(AppleMusicTheme.accent)
                }

                ForEach(storage.playlists) { playlist in
                    Button {
                        storage.addTrack(track, to: playlist.id)
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(playlist.title)
                                    .font(.headline)
                                Text("\(playlist.tracks.count) songs")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundStyle(AppleMusicTheme.accent)
                        }
                    }
                }
            }
            .navigationTitle("Add to Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("New Playlist", isPresented: $showingCreateAlert) {
                TextField("Playlist Name", text: $newPlaylistTitle)
                Button("Cancel", role: .cancel) { }
                Button("Create") {
                    if !newPlaylistTitle.isEmpty {
                        storage.createPlaylist(title: newPlaylistTitle)
                        if let created = storage.playlists.last {
                            storage.addTrack(track, to: created.id)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
