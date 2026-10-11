import SwiftUI

/// Fluid, animated blurred mesh background reflecting the current track's album art
public struct AnimatedMeshBackground: View {
    let artworkURL: URL?

    @State private var animateGradients = false

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Base background color
                Color.black.ignoresSafeArea()

                // Blurred ambient artwork layer
                if let url = artworkURL {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width * 1.5, height: proxy.size.height * 1.5)
                                .blur(radius: 70)
                                .opacity(0.85)
                                .scaleEffect(animateGradients ? 1.15 : 1.0)
                                .rotationEffect(.degrees(animateGradients ? 8 : -8))
                        }
                    }
                }

                // Fluid chromatic gradient blobs to ensure rich color dynamics
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppleMusicTheme.accent.opacity(0.55), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: proxy.size.width * 0.7
                        )
                    )
                    .frame(width: proxy.size.width * 1.1, height: proxy.size.width * 1.1)
                    .offset(
                        x: animateGradients ? -proxy.size.width * 0.2 : proxy.size.width * 0.2,
                        y: animateGradients ? -proxy.size.height * 0.25 : proxy.size.height * 0.1
                    )
                    .blur(radius: 50)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.indigo.opacity(0.45), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: proxy.size.width * 0.7
                        )
                    )
                    .frame(width: proxy.size.width * 0.9, height: proxy.size.width * 0.9)
                    .offset(
                        x: animateGradients ? proxy.size.width * 0.25 : -proxy.size.width * 0.2,
                        y: animateGradients ? proxy.size.height * 0.2 : -proxy.size.height * 0.15
                    )
                    .blur(radius: 55)

                // Ultra-thin material scrim for legibility
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.4)
                    .ignoresSafeArea()

                // Subtle dark vignette gradient
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.3),
                        Color.clear,
                        Color.black.opacity(0.65)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                    animateGradients.toggle()
                }
            }
        }
        .ignoresSafeArea()
    }
}
