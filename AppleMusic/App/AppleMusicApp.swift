import SwiftUI

@main
struct AppleMusicApp: App {
    init() {
        // Initialize background audio session and remote command center
        _ = AudioPlayerService.shared
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .tint(AppleMusicTheme.accent)
        }
    }
}
