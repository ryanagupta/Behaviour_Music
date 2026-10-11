import SwiftUI

/// Apple Music karaoke-style synchronized lyrics view with active glow and auto-scrolling
public struct LyricsView: View {
    let lyrics: ParsedLyrics?
    let currentTime: TimeInterval
    let onSeek: (TimeInterval) -> Void

    @State private var userIsScrolling: Bool = false

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 24) {
                    // Top spacing
                    Spacer().frame(height: 40)

                    if let parsed = lyrics, parsed.isSynced, !parsed.lines.isEmpty {
                        let activeIdx = parsed.activeIndex(for: currentTime) ?? 0

                        ForEach(Array(parsed.lines.enumerated()), id: \.element.id) { index, line in
                            let isActive = (index == activeIdx)

                            Text(line.text)
                                .font(.system(size: isActive ? 28 : 22, weight: .bold, design: .default))
                                .foregroundStyle(isActive ? .white : .white.opacity(0.35))
                                .scaleEffect(isActive ? 1.03 : 0.98, anchor: .leading)
                                .blur(radius: isActive ? 0 : 0.3)
                                .contentShape(Rectangle())
                                .id(index)
                                .onTapGesture {
                                    onSeek(line.timestamp)
                                }
                                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isActive)
                        }

                        // Bottom spacing
                        Spacer().frame(height: 120)
                    } else if let plain = lyrics?.plainLyrics, !plain.isEmpty {
                        Text(plain)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(12)
                            .padding(.top, 20)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "quote.bubble")
                                .font(.system(size: 44))
                                .foregroundStyle(.white.opacity(0.4))

                            Text("Lyrics not available for this song")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    }
                }
                .padding(.horizontal, 28)
            }
            .onChange(of: currentTime) { _, newTime in
                if let parsed = lyrics, parsed.isSynced, !userIsScrolling {
                    if let activeIdx = parsed.activeIndex(for: newTime) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            proxy.scrollTo(activeIdx, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}
