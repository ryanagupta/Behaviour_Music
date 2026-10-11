import SwiftUI

/// Playlist detail view displaying curated or user-created tracks
public struct PlaylistDetailView: View {
    let playlist: Playlist
    @State private var audio = AudioPlayerService.shared
    @State private var storage = StorageService.shared

    private var currentPlaylist: Playlist {
        storage.playlists.first(where: { $0.id == playlist.id }) ?? playlist
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Artwork
                ArtworkImageView(
                    url: currentPlaylist.highResArtwork(size: 600),
                    cornerRadius: 12,
                    shadowRadius: 14
                )
                .frame(width: 240, height: 240)
                .padding(.top, 10)

                // Playlist Info
                VStack(spacing: 4) {
                    Text(currentPlaylist.title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text(currentPlaylist.curatorName)
                        .font(.headline)
                        .foregroundStyle(AppleMusicTheme.accent)

                    if let desc = currentPlaylist.description {
                        Text(desc)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }
                }

                // Play & Shuffle
                HStack(spacing: 16) {
                    Button {
                        if let first = currentPlaylist.tracks.first {
                            audio.playTrack(first, in: currentPlaylist.tracks)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Play")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .foregroundStyle(AppleMusicTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button {
                        if !currentPlaylist.tracks.isEmpty {
                            var shuffled = currentPlaylist.tracks
                            shuffled.shuffle()
                            if let first = shuffled.first {
                                audio.playTrack(first, in: shuffled)
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "shuffle")
                            Text("Shuffle")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .foregroundStyle(AppleMusicTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 24)

                // Tracklist
                VStack(spacing: 0) {
                    ForEach(Array(currentPlaylist.tracks.enumerated()), id: \.element.id) { index, track in
                        TrackRowView(track: track, showArtwork: true) {
                            audio.playTrack(track, in: currentPlaylist.tracks)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)

                        Divider().padding(.leading, 72)
                    }
                }

                Spacer().frame(height: 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
