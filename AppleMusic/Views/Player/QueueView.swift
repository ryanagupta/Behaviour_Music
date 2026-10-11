import SwiftUI

/// Queue management view displaying "Playing Next" with reordering and shuffle/repeat toggles
public struct QueueView: View {
    @State private var audio = AudioPlayerService.shared

    public var body: some View {
        VStack(spacing: 0) {
            // Header controls: Shuffle, Repeat, Clear
            HStack {
                Text("Playing Next")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Spacer()

                // Shuffle Button
                Button {
                    audio.toggleShuffle()
                } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(audio.isShuffled ? AppleMusicTheme.accent : .white.opacity(0.7))
                        .padding(8)
                        .background(audio.isShuffled ? Color.white.opacity(0.15) : Color.clear)
                        .clipShape(Circle())
                }

                // Repeat Button
                Button {
                    audio.toggleRepeat()
                } label: {
                    Image(systemName: audio.repeatMode == .one ? "repeat.1" : "repeat")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(audio.repeatMode != .off ? AppleMusicTheme.accent : .white.opacity(0.7))
                        .padding(8)
                        .background(audio.repeatMode != .off ? Color.white.opacity(0.15) : Color.clear)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Queue List
            List {
                // Currently playing
                if let current = audio.currentTrack {
                    Section {
                        TrackRowDark(track: current, isPlaying: true)
                    } header: {
                        Text("Now Playing")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                }

                // Upcoming items
                Section {
                    let upcomingIndices = audio.queue.indices.filter { $0 > audio.currentIndex }
                    ForEach(upcomingIndices, id: \.self) { index in
                        let track = audio.queue[index]
                        TrackRowDark(track: track, isPlaying: false)
                            .onTapGesture {
                                audio.currentIndex = index
                                audio.playTrack(track)
                            }
                    }
                    .onDelete { indexSet in
                        for offset in indexSet {
                            let queueIndex = audio.currentIndex + 1 + offset
                            if queueIndex < audio.queue.count {
                                audio.queue.remove(at: queueIndex)
                            }
                        }
                    }
                    .onMove { source, destination in
                        // Reorder upcoming tracks
                        var upcoming = Array(audio.queue.suffix(from: audio.currentIndex + 1))
                        upcoming.move(fromOffsets: source, toOffset: destination)
                        audio.queue = Array(audio.queue.prefix(audio.currentIndex + 1)) + upcoming
                    }
                } header: {
                    Text("Up Next")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.6))
                }
                .listRowBackground(Color.white.opacity(0.05))
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
    }
}

/// Dark themed track row for Queue overlay
private struct TrackRowDark: View {
    let track: Track
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 12) {
            ArtworkImageView(url: track.highResArtwork(size: 120), cornerRadius: 6, shadowRadius: 0)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.system(size: 15, weight: isPlaying ? .bold : .regular))
                    .foregroundStyle(isPlaying ? AppleMusicTheme.accent : .white)
                    .lineLimit(1)

                Text(track.artistName)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()

            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 14))
                    .foregroundStyle(AppleMusicTheme.accent)
            }
        }
        .padding(.vertical, 2)
    }
}
