import SwiftUI

/// Main container replicating the iOS 18 Apple Music interface with floating navigation island
public struct MainTabView: View {
    @State private var selectedTab: MusicTab = .home
    @State private var showNowPlaying: Bool = false
    @State private var audio = AudioPlayerService.shared

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Selected Tab Content View
            Group {
                switch selectedTab {
                case .home:
                    ListenNowView()
                case .browse:
                    BrowseView()
                case .radio:
                    RadioView()
                case .library:
                    LibraryView()
                case .search:
                    SearchView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom Stack: Floating Mini-Player and Island Tab Bar (Image 1, 2, and 4)
            VStack(spacing: 8) {
                // Mini Player
                MiniPlayerView {
                    showNowPlaying = true
                }

                // Floating Island Tab Bar with detached Search button
                FloatingTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 2)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .tint(AppleMusicTheme.accent)
        .sheet(isPresented: $showNowPlaying) {
            NowPlayingView()
                .presentationDragIndicator(.hidden)
        }
    }
}
