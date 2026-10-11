import SwiftUI

/// Section Header in Apple Music style with bold title and optional "See All" chevron
public struct SectionHeaderView: View {
    let title: String
    var showSeeAll: Bool = true
    var onSeeAllTapped: (() -> Void)? = nil

    public init(title: String, showSeeAll: Bool = true, onSeeAllTapped: (() -> Void)? = nil) {
        self.title = title
        self.showSeeAll = showSeeAll
        self.onSeeAllTapped = onSeeAllTapped
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(AppleMusicTheme.sectionHeaderFont)
                .foregroundStyle(.primary)

            Spacer()

            if showSeeAll {
                Button {
                    onSeeAllTapped?()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }
}
