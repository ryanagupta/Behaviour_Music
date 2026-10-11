import SwiftUI

/// "Radio" Tab - Apple Music 1, live radio broadcasts, and genre stations
public struct RadioView: View {
    @State private var audio = AudioPlayerService.shared

    private let stations: [(name: String, desc: String, colors: [Color], icon: String)] = [
        ("Apple Music 1", "The new music that matters.", [Color(hex: "#ED213A"), Color(hex: "#93291E")], "antenna.radiowaves.left.and.right"),
        ("Apple Music Hits", "Songs you know and love.", [Color(hex: "#F12711"), Color(hex: "#F5AF19")], "sparkles"),
        ("Apple Music Country", "Where the good stuff lives.", [Color(hex: "#56ab2f"), Color(hex: "#a8e063")], "guitars.fill")
    ]

    private let genreStations: [(name: String, colors: [Color])] = [
        ("Today's Country", [Color(hex: "#DA4453"), Color(hex: "#89216B")]),
        ("Hip-Hop Station", [Color(hex: "#654ea3"), Color(hex: "#eaafc8")]),
        ("Pure Pop Radio", [Color(hex: "#00b09b"), Color(hex: "#96c93d")]),
        ("Heavy Metal Radio", [Color(hex: "#232526"), Color(hex: "#414345")]),
        ("Classical Station", [Color(hex: "#1D2671"), Color(hex: "#C33764")])
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Radio")
                        .font(AppleMusicTheme.navigationTitleFont)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Live Stations Banner Carousel
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(stations, id: \.name) { station in
                                LiveRadioCard(
                                    name: station.name,
                                    description: station.desc,
                                    colors: station.colors,
                                    icon: station.icon
                                ) {
                                    if let sample = Track.sampleList.randomElement() {
                                        audio.playTrack(sample)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Genre Stations Grid
                    SectionHeaderView(title: "Genre Stations")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 14) {
                            ForEach(genreStations, id: \.name) { item in
                                Button {
                                    if let sample = Track.sampleList.randomElement() {
                                        audio.playTrack(sample)
                                    }
                                } label: {
                                    ZStack(alignment: .bottomLeading) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(LinearGradient(colors: item.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 140, height: 140)

                                        Text(item.name)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .padding(12)
                                    }
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
        }
    }
}

private struct LiveRadioCard: View {
    let name: String
    let description: String
    let colors: [Color]
    let icon: String
    let onTuneIn: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppleMusicTheme.heroBannerCornerRadius, style: .continuous)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 300, height: 200)
                .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("LIVE")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.3))
                .clipShape(Capsule())

                Spacer()

                Text(name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))

                Button {
                    onTuneIn()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                        Text("Listen Now")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            .padding(18)
        }
    }
}
