import SwiftUI

/// Square album/playlist card used in horizontal scrolling sections and grids
public struct AlbumCardView: View {
    let title: String
    let subtitle: String
    let artworkURL: URL?
    var width: CGFloat = 160

    public init(title: String, subtitle: String, artworkURL: URL?, width: CGFloat = 160) {
        self.title = title
        self.subtitle = subtitle
        self.artworkURL = artworkURL
        self.width = width
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ArtworkImageView(url: artworkURL, cornerRadius: AppleMusicTheme.albumCornerRadius, shadowRadius: 6)
                .frame(width: width, height: width)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppleMusicTheme.cardTitleFont)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(AppleMusicTheme.cardSubtitleFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(width: width, alignment: .leading)
        }
    }
}
