import SwiftUI

/// Apple Music interactive scrubber bar with real-time dragging and remaining time countdown
public struct ScrubberBar: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void

    @State private var isDragging: Bool = false
    @State private var dragValue: TimeInterval = 0

    private var displayTime: TimeInterval {
        isDragging ? dragValue : currentTime
    }

    private var remainingTime: TimeInterval {
        max(0, duration - displayTime)
    }

    public var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let progress = duration > 0 ? CGFloat(displayTime / duration) : 0
                let clampedProgress = max(0, min(1, progress))

                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(height: isDragging ? 7 : 4)

                    // Elapsed track progress
                    Capsule()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: max(0, width * clampedProgress), height: isDragging ? 7 : 4)

                    // Scrubber thumb
                    if isDragging {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                            .shadow(radius: 2)
                            .offset(x: max(0, min(width - 14, width * clampedProgress - 7)))
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let ratio = max(0, min(1, value.location.x / width))
                            dragValue = TimeInterval(ratio) * duration
                        }
                        .onEnded { value in
                            let ratio = max(0, min(1, value.location.x / width))
                            let target = TimeInterval(ratio) * duration
                            onSeek(target)
                            isDragging = false
                        }
                )
            }
            .frame(height: 14)

            // Timestamps
            HStack {
                Text(formatTime(displayTime))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                Text("-\(formatTime(remainingTime))")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let total = Int(max(0, time))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
