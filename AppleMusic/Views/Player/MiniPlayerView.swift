import SwiftUI

/// Floating frosted glass mini-player matching Image 1, 2, and 4
public struct MiniPlayerView: View {
    let onExpand: () -> Void

    @State private var audio = AudioPlayerService.shared

    public var body: some View {
        HStack(spacing: 12) {
            if let track = audio.currentTrack {
                // Active Track State (Image 1 & 2)
                ArtworkImageView(url: track.highResArtwork(size: 160), cornerRadius: 7, shadowRadius: 2)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(track.artistName)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Play / Pause Button
                Button {
                    audio.togglePlayPause()
                } label: {
                    if audio.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 19))
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                    }
                }

                // Next Button
                Button {
                    audio.skipNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                }
            } else {
                // Idle / "Not Playing" State (Image 4)
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)

                    Image(systemName: "music.note")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                }

                Text("Not Playing")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    if let first = Track.sampleList.first {
                        audio.playTrack(first)
                    }
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 19))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                }

                Button {
                    // Forward
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            if audio.currentTrack != nil {
                onExpand()
            }
        }
    }
}
