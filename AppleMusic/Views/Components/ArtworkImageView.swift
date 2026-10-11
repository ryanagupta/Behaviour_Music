import SwiftUI

/// High-performance artwork image component with Apple Music style rounded corners and placeholder
public struct ArtworkImageView: View {
    let url: URL?
    var cornerRadius: CGFloat = AppleMusicTheme.albumCornerRadius
    var shadowRadius: CGFloat = 4.0

    public init(url: URL?, cornerRadius: CGFloat = AppleMusicTheme.albumCornerRadius, shadowRadius: CGFloat = 4.0) {
        self.url = url
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(.secondary)
                    )
            @unknown default:
                EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(shadowRadius > 0 ? 0.12 : 0), radius: shadowRadius, x: 0, y: shadowRadius / 2)
    }
}
