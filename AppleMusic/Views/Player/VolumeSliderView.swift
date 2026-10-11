import SwiftUI

/// Apple Music volume slider with min and max speaker symbols
public struct VolumeSliderView: View {
    @Binding var volume: Float

    public init(volume: Binding<Float>) {
        self._volume = volume
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))

            GeometryReader { geometry in
                let width = geometry.size.width
                let progress = CGFloat(max(0, min(1, volume)))

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(height: 5)

                    Capsule()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: max(0, width * progress), height: 5)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let ratio = Float(max(0, min(1, value.location.x / width)))
                            volume = ratio
                        }
                )
            }
            .frame(height: 16)

            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}
