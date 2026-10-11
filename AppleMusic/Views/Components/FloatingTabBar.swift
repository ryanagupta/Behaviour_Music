import SwiftUI

public enum MusicTab: Int, CaseIterable {
    case home = 0
    case browse = 1
    case radio = 2
    case library = 3
    case search = 4

    var title: String {
        switch self {
        case .home: return "Home"
        case .browse: return "New"
        case .radio: return "Radio"
        case .library: return "Library"
        case .search: return "Search"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .browse: return "square.grid.2x2.fill"
        case .radio: return "dot.radiowaves.left.and.right"
        case .library: return "square.stack.fill"
        case .search: return "magnifyingglass"
        }
    }
}

/// Authentic Apple Music floating island tab bar with detached search button (iOS 18 / latest Apple Music UI)
public struct FloatingTabBar: View {
    @Binding var selectedTab: MusicTab

    public init(selectedTab: Binding<MusicTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Main navigation island capsule
            HStack(spacing: 0) {
                tabButton(.home)
                tabButton(.browse)
                tabButton(.radio)
                tabButton(.library)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 5)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )

            // Detached floating circular Search button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    selectedTab = .search
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 54, height: 54)
                        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 5)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        )

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(selectedTab == .search ? AppleMusicTheme.accent : .primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private func tabButton(_ tab: MusicTab) -> some View {
        let isSelected = selectedTab == tab
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                    .frame(height: 22)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? AppleMusicTheme.accent : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
    }
}
