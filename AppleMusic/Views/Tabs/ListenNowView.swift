import SwiftUI

/// "Home" / "Listen Now" Tab - Apple Music personalized home tab matching Image 1
public struct ListenNowView: View {
    @State private var catalog = AppleCatalogService.shared
    @State private var storage = StorageService.shared
    @State private var audio = AudioPlayerService.shared

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Profile avatar & date header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Top Picks")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text("Home")
                                .font(AppleMusicTheme.navigationTitleFont)
                        }

                        Spacer()

                        Button {
                            // Account
                        } label: {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppleMusicTheme.accent)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Hero Editorial Banner featuring "Hurry Up Tomorrow" (Image 1)
                    NavigationLink {
                        AlbumDetailView(album: Album.hurryUpTomorrow)
                    } label: {
                        heroEditorialBanner
                    }

                    // Featured Albums (Hurry Up Tomorrow & SOS matching Image 1 & 2)
                    SectionHeaderView(title: "New Releases")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            NavigationLink {
                                AlbumDetailView(album: Album.hurryUpTomorrow)
                            } label: {
                                AlbumCardView(
                                    title: Album.hurryUpTomorrow.name,
                                    subtitle: Album.hurryUpTomorrow.artistName,
                                    artworkURL: Album.hurryUpTomorrow.highResArtwork(size: 320),
                                    width: 160
                                )
                            }

                            NavigationLink {
                                AlbumDetailView(album: Album.szaSOS)
                            } label: {
                                AlbumCardView(
                                    title: Album.szaSOS.name,
                                    subtitle: Album.szaSOS.artistName,
                                    artworkURL: Album.szaSOS.highResArtwork(size: 320),
                                    width: 160
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Recently Played
                    if !storage.recentlyPlayed.isEmpty {
                        SectionHeaderView(title: "Recently Played")
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(storage.recentlyPlayed) { track in
                                    Button {
                                        audio.playTrack(track, in: storage.recentlyPlayed)
                                    } label: {
                                        AlbumCardView(
                                            title: track.title,
                                            subtitle: track.artistName,
                                            artworkURL: track.highResArtwork(size: 300),
                                            width: 150
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Stations For You
                    SectionHeaderView(title: "Stations for You")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(catalog.featuredPlaylists) { playlist in
                                Button {
                                    if let first = playlist.tracks.first {
                                        audio.playTrack(first, in: playlist.tracks)
                                    }
                                } label: {
                                    AlbumCardView(
                                        title: playlist.title,
                                        subtitle: playlist.curatorName,
                                        artworkURL: playlist.highResArtwork(size: 300),
                                        width: 160
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Top Tracks Today
                    if !catalog.topSongs.isEmpty {
                        SectionHeaderView(title: "Top Tracks")
                        VStack(spacing: 4) {
                            ForEach(Array(catalog.topSongs.prefix(5))) { track in
                                TrackRowView(track: track) {
                                    audio.playTrack(track, in: catalog.topSongs)
                                }
                                .padding(.horizontal)
                                Divider().padding(.leading, 72)
                            }
                        }
                    }

                    // Bottom padding for mini-player and island tab bar
                    Spacer().frame(height: 120)
                }
            }
            .navigationBarHidden(true)
            .task {
                await catalog.fetchTopCharts(limit: 25)
            }
        }
    }

    private var heroEditorialBanner: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppleMusicTheme.heroBannerCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#EDE9E1"), Color(hex: "#D0C8B8")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 220)
                .shadow(color: Color.black.opacity(0.12), radius: 10, y: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("NEW ALBUM")
                    .font(.caption.bold())
                    .foregroundStyle(.black.opacity(0.6))

                Text("Hurry Up Tomorrow")
                    .font(.title.bold())
                    .foregroundStyle(.black)

                Text("The Weeknd concludes his monumental trilogy with visceral pop epics.")
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.75))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Listen Now")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Color.black)
                .clipShape(Capsule())
                .padding(.top, 4)
            }
            .padding(20)
        }
        .padding(.horizontal)
    }
}
