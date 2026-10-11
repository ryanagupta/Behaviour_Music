import SwiftUI

/// "Browse" Tab - Apple Music global charts, editorial features, and new releases
public struct BrowseView: View {
    @State private var catalog = AppleCatalogService.shared
    @State private var audio = AudioPlayerService.shared

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Title
                    Text("Browse")
                        .font(AppleMusicTheme.navigationTitleFont)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Curated Spotlight Banners
                    spotlightCarousel

                    // Top 100 Charts
                    SectionHeaderView(title: "Top Songs: Global")
                    VStack(spacing: 8) {
                        ForEach(Array(catalog.topSongs.prefix(10).enumerated()), id: \.element.id) { index, track in
                            HStack(spacing: 14) {
                                Text("\(index + 1)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(index < 3 ? AppleMusicTheme.accent : .secondary)
                                    .frame(width: 24, alignment: .center)

                                TrackRowView(track: track, showArtwork: true) {
                                    audio.playTrack(track, in: catalog.topSongs)
                                }
                            }
                            .padding(.horizontal)

                            if index < 9 {
                                Divider().padding(.leading, 80)
                            }
                        }
                    }

                    // Featured Playlists
                    SectionHeaderView(title: "Must-Hear Playlists")
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
                                        artworkURL: playlist.highResArtwork(size: 320),
                                        width: 165
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Bottom padding for mini-player
                    Spacer().frame(height: 100)
                }
            }
            .navigationBarHidden(true)
            .task {
                if catalog.topSongs.isEmpty {
                    await catalog.fetchTopCharts(limit: 50)
                }
            }
        }
    }

    private var spotlightCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                SpotlightCard(
                    category: "GLOBAL PREMIERE",
                    title: "The Sound of Today",
                    subtitle: "Catch the latest chart-topping hits",
                    gradient: LinearGradient(colors: [Color(hex: "#FF416C"), Color(hex: "#8A2387")], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

                SpotlightCard(
                    category: "NEW IN SPATIAL AUDIO",
                    title: "Immersive Soundscapes",
                    subtitle: "Feel sound all around you with Spatial Audio",
                    gradient: LinearGradient(colors: [Color(hex: "#4E54C8"), Color(hex: "#8F94FB")], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }
            .padding(.horizontal)
        }
    }
}

private struct SpotlightCard: View {
    let category: String
    let title: String
    let subtitle: String
    let gradient: LinearGradient

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppleMusicTheme.heroBannerCornerRadius, style: .continuous)
                .fill(gradient)
                .frame(width: 320, height: 180)
                .shadow(color: Color.black.opacity(0.12), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.caption2.bold())
                    .foregroundStyle(.white.opacity(0.8))

                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
        }
    }
}
