import SwiftUI

public struct MusicCategory: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let gradient: LinearGradient
    public let iconName: String

    public static let standardCategories: [MusicCategory] = [
        MusicCategory(
            name: "Pop",
            gradient: LinearGradient(colors: [Color(hex: "#FF416C"), Color(hex: "#FF4B2B")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "music.mic"
        ),
        MusicCategory(
            name: "Hip-Hop",
            gradient: LinearGradient(colors: [Color(hex: "#8A2387"), Color(hex: "#E94057"), Color(hex: "#F27121")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "speaker.wave.3.fill"
        ),
        MusicCategory(
            name: "Dance & EDM",
            gradient: LinearGradient(colors: [Color(hex: "#00F260"), Color(hex: "#0575E6")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "bolt.fill"
        ),
        MusicCategory(
            name: "R&B / Soul",
            gradient: LinearGradient(colors: [Color(hex: "#4A00E0"), Color(hex: "#8E2DE2")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "heart.fill"
        ),
        MusicCategory(
            name: "Rock",
            gradient: LinearGradient(colors: [Color(hex: "#232526"), Color(hex: "#414345")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "guitars.fill"
        ),
        MusicCategory(
            name: "Chill",
            gradient: LinearGradient(colors: [Color(hex: "#11998E"), Color(hex: "#38EF7D")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "leaf.fill"
        ),
        MusicCategory(
            name: "Workout",
            gradient: LinearGradient(colors: [Color(hex: "#FF512F"), Color(hex: "#DD2476")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "flame.fill"
        ),
        MusicCategory(
            name: "Alternative",
            gradient: LinearGradient(colors: [Color(hex: "#5614B0"), Color(hex: "#DBD65C")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "waveform"
        ),
        MusicCategory(
            name: "Country",
            gradient: LinearGradient(colors: [Color(hex: "#D38312"), Color(hex: "#A83279")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "sun.max.fill"
        ),
        MusicCategory(
            name: "Focus",
            gradient: LinearGradient(colors: [Color(hex: "#2193B0"), Color(hex: "#6DD5ED")], startPoint: .topLeading, endPoint: .bottomTrailing),
            iconName: "brain.head.profile"
        )
    ]
}

/// Category Card in Apple Music Search Browse tab
public struct CategoryCardView: View {
    let category: MusicCategory

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppleMusicTheme.cardCornerRadius, style: .continuous)
                .fill(category.gradient)
                .frame(height: 100)
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)

            // Category Icon in background
            HStack {
                Spacer()
                Image(systemName: category.iconName)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white.opacity(0.22))
                    .rotationEffect(.degrees(-15))
                    .offset(x: -8, y: 12)
            }

            // Title
            Text(category.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .padding(14)
        }
        .frame(height: 100)
    }
}
