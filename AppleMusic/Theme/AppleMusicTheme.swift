import SwiftUI

/// Authentic Apple Music design constants, typography, and color tokens
enum AppleMusicTheme {
    /// The iconic Apple Music vibrant pink-red accent color
    static let accent = Color(red: 250 / 255.0, green: 45 / 255.0, blue: 72 / 255.0)
    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 255 / 255.0, green: 59 / 255.0, blue: 92 / 255.0),
            Color(red: 235 / 255.0, green: 30 / 255.0, blue: 60 / 255.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Background tones
    static let primaryBackground = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)

    /// Card and separator styling
    static let cardCornerRadius: CGFloat = 10.0
    static let albumCornerRadius: CGFloat = 8.0
    static let miniPlayerCornerRadius: CGFloat = 16.0
    static let heroBannerCornerRadius: CGFloat = 12.0

    /// Shadows
    static let artworkShadowRadius: CGFloat = 8.0
    static let miniPlayerShadowRadius: CGFloat = 12.0

    /// Apple Music Typography standard sizes
    static let navigationTitleFont = Font.system(size: 34, weight: .bold, design: .default)
    static let sectionHeaderFont = Font.system(size: 22, weight: .bold, design: .default)
    static let cardTitleFont = Font.system(size: 15, weight: .semibold, design: .default)
    static let cardSubtitleFont = Font.system(size: 13, weight: .regular, design: .default)
    static let trackTitleFont = Font.system(size: 16, weight: .regular, design: .default)
    static let trackArtistFont = Font.system(size: 14, weight: .regular, design: .default)
    static let nowPlayingTitleFont = Font.system(size: 22, weight: .bold, design: .default)
    static let nowPlayingArtistFont = Font.system(size: 18, weight: .semibold, design: .default)
}

extension Color {
    init(hex: String) {
        let hexClean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexClean).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexClean.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
