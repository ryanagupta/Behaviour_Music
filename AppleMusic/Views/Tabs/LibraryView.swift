import SwiftUI

/// "Library" Tab - Apple Music local collections, playlists, and downloaded music
public struct LibraryView: View {
    @State private var storage = StorageService.shared
    @State private var audio = AudioPlayerService.shared

    private let menuItems: [(title: String, icon: String)] = [
        ("Playlists", "music.note.list"),
        ("Artists", "music.mic"),
        ("Albums", "square.stack"),
        ("Songs", "music.note"),
        ("Made for You", "person.crop.square"),
        ("Downloaded", "arrow.down.circle")
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Header
                    HStack {
                        Text("Library")
                            .font(AppleMusicTheme.navigationTitleFont)
                        Spacer()
                        Button("Edit") {
                            // Edit library arrangement
                        }
                        .foregroundStyle(AppleMusicTheme.accent)
                        .font(.headline)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Library Navigation Items
                    VStack(spacing: 0) {
                        ForEach(menuItems, id: \.title) { item in
                            NavigationLink {
                                destinationView(for: item.title)
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: item.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(AppleMusicTheme.accent)
                                        .frame(width: 28)

                                    Text(item.title)
                                        .font(.system(size: 20, weight: .regular))
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondary.opacity(0.6))
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal)
                            }

                            Divider().padding(.leading, 60)
                        }
                    }

                    // Recently Added Section
                    SectionHeaderView(title: "Recently Added", showSeeAll: false)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        // User playlists
                        ForEach(storage.playlists) { playlist in
                            NavigationLink {
                                PlaylistDetailView(playlist: playlist)
                            } label: {
                                AlbumCardView(
                                    title: playlist.title,
                                    subtitle: "\(playlist.tracks.count) songs",
                                    artworkURL: playlist.highResArtwork(size: 300),
                                    width: 165
                                )
                            }
                        }

                        // Downloaded tracks
                        ForEach(storage.downloadedTracks) { track in
                            Button {
                                audio.playTrack(track, in: storage.downloadedTracks)
                            } label: {
                                AlbumCardView(
                                    title: track.title,
                                    subtitle: track.artistName,
                                    artworkURL: track.highResArtwork(size: 300),
                                    width: 165
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Bottom padding for mini-player
                    Spacer().frame(height: 100)
                }
            }
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private func destinationView(for title: String) -> some View {
        switch title {
        case "Playlists":
            PlaylistsListView()
        case "Songs":
            SongsListView()
        case "Downloaded":
            DownloadedMusicView()
        default:
            SongsListView()
        }
    }
}

/// List of all playlists
private struct PlaylistsListView: View {
    @State private var storage = StorageService.shared
    @State private var showCreate = false
    @State private var title = ""

    var body: some View {
        List {
            Button {
                showCreate = true
            } label: {
                Label("New Playlist...", systemImage: "plus")
                    .foregroundStyle(AppleMusicTheme.accent)
            }

            ForEach(storage.playlists) { playlist in
                NavigationLink {
                    PlaylistDetailView(playlist: playlist)
                } label: {
                    HStack(spacing: 14) {
                        ArtworkImageView(url: playlist.highResArtwork(size: 140), cornerRadius: 6, shadowRadius: 0)
                            .frame(width: 52, height: 52)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(playlist.title)
                                .font(.headline)
                            Text("\(playlist.tracks.count) songs")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Playlists")
        .alert("New Playlist", isPresented: $showCreate) {
            TextField("Playlist Title", text: $title)
            Button("Cancel", role: .cancel) { }
            Button("Create") {
                if !title.isEmpty {
                    storage.createPlaylist(title: title)
                    title = ""
                }
            }
        }
    }
}

/// List of favorited songs
private struct SongsListView: View {
    @State private var storage = StorageService.shared
    @State private var audio = AudioPlayerService.shared

    var body: some View {
        List {
            ForEach(storage.favoriteTracks) { track in
                TrackRowView(track: track) {
                    audio.playTrack(track, in: storage.favoriteTracks)
                }
            }
        }
        .navigationTitle("Songs")
        .overlay {
            if storage.favoriteTracks.isEmpty {
                ContentUnavailableView("No Songs Yet", systemImage: "music.note", description: Text("Favorite tracks by tapping the heart icon to add them here."))
            }
        }
    }
}

/// Downloaded music for offline listening
private struct DownloadedMusicView: View {
    @State private var storage = StorageService.shared
    @State private var audio = AudioPlayerService.shared

    var body: some View {
        List {
            ForEach(storage.downloadedTracks) { track in
                TrackRowView(track: track) {
                    audio.playTrack(track, in: storage.downloadedTracks)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        storage.deleteDownload(track: track)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Downloaded")
        .overlay {
            if storage.downloadedTracks.isEmpty {
                ContentUnavailableView("No Downloaded Music", systemImage: "arrow.down.circle", description: Text("Songs you download will appear here for offline playback."))
            }
        }
    }
}
