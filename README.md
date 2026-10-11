# Apple Music iOS Replica (1-to-1 Native SwiftUI App)

A pixel-perfect, 1-to-1 native iOS replica of Apple Music built in Swift & SwiftUI for iOS 17.0+, complete with on-device music streaming, time-synced karaoke lyrics, offline downloads, dynamic blurred mesh backgrounds, lock screen controls, and an automated GitHub Actions CI pipeline that packages unsigned `.ipa` builds ready for sideloading.

---

## ✨ Features & Visual Parity (Replicated 1-to-1)

1. **iOS 18 Floating Island Tab Bar & Mini-Player (Image 1 & 2 Parity)**:
   - Floating navigation island capsule: `[ Home | New | Radio | Library ]` with `.ultraThinMaterial` frosted glass.
   - Detached circular floating Search button with authentic red magnifying glass.
   - Docked floating Mini-Player showing live album art thumbnail, title, artist, play/pause and skip buttons.
   - Seamless interactive tap gesture expanding to the full-screen Now Playing sheet.

2. **Full-Bleed Album Detail View (Image 1 & 2 Parity)**:
   - Full-bleed hero artwork fading smoothly into dynamic ambient background tints (e.g. *The Weeknd - Hurry Up Tomorrow* in warm cream, *SZA - SOS* in deep ocean blue).
   - Frosted navigation buttons: Circular `<` back button, Share/Ellipsis capsule.
   - Metadata badges: `R&B/Soul • 2025 • [Dolby Atmos] • [Hi-Res Lossless]`.
   - Control buttons trio: Circular frosted **Shuffle**, prominent wide **▶ Play** capsule, circular frosted **+** add button.
   - Editorial description with interactive **MORE** / **LESS** expansion.
   - Numbered tracklist with animated equalizer bars `waveform` on active playing song, explicit `[E]` badges, and duration.

3. **Now Playing Modal (Image 3 Parity)**:
   - Dynamic fluid blurred mesh gradient backdrop reacting in real-time to album artwork.
   - Floating artwork with spring animations on play/pause state transitions.
   - Personal Audio user tag capsule: `[avatar] Personal Audio`.
   - Song title & artist row flanked by frosted circular **Star** favorite button and **Ellipsis** menu.
   - Precise interactive scrub bar with elapsed and remaining countdown timers (`-1:00`).
   - Transport controls: Backward, giant Play/Pause, Forward.
   - Smooth system volume slider with minimum/maximum speaker glyphs.
   - Bottom action bar: **Time-Synced Lyrics** bubble, **AirPlay & SharePlay** capsule, and **Up Next Queue** button.

4. **Search Experience (Image 4 & 5 Parity)**:
   - Custom search header with microphone icon and red animated **Cancel** button.
   - Segmented scope bar: `[ Apple Music | Library ]`.
   - Rich 2-column **Browse Categories** grid with vibrantly tinted cards (HEAD TRIP, Hits, Pop, Hip-Hop, Dance, Alternative, R&B/Soul, Country, Rock, Chill).
   - Real-time instant auto-complete suggestions prefixed by `🔍`.
   - Live song and album query results with instant tap-to-play.

5. **Audio Engine & On-Device Streaming**:
   - Zero-key streaming via multi-tier fallback architecture:
     1. Piped API audio stream extraction (`audio/mp4` / AAC 128-256kbps).
     2. Invidious / InnerTube audio stream fallback.
     3. Official iTunes Store 256kbps preview stream instant fallback.
   - Background audio playback (`AVAudioSession` `.playback` category).
   - Full iOS Lock Screen & Control Center integration via `MPNowPlayingInfoCenter` (artwork, progress, metadata) and `MPRemoteCommandCenter` (play, pause, next, previous, scrub).
   - Dynamic time-synced karaoke lyrics powered by LRCLIB public API.
   - Local library storage and offline audio downloading to `Documents/Downloads/`.

---

## 🚀 Sideloading onto iPhone (.IPA Installation)

You don't need a paid Apple Developer Account or a Mac to install this app on your iPhone. Free personal Apple IDs can sign and sideload up to 3 apps.

### Option 1: AltStore (Recommended for Windows & Mac)
1. Download [AltServer](https://altstore.io/) on Windows or Mac.
2. Install the Mail plug-in (Mac) or iTunes/iCloud desktop apps from Apple (not Microsoft Store on Windows).
3. Connect your iPhone to your computer via USB and select **Install AltStore**.
4. On your iPhone, download the `Music.ipa` artifact from GitHub Actions.
5. In AltStore on your phone, go to **My Apps**, tap **+**, and select `Music.ipa`.
6. Enter your Apple ID to sign and install.

### Option 2: SideStore (On-Device Sideloading without Computer)
1. Install [SideStore](https://sidestore.io/) onto your iPhone once using SideServer.
2. Download `Music.ipa` in Safari.
3. Open SideStore -> tap **+** -> select `Music.ipa`.
4. The app refreshes wirelessly over Wi-Fi without needing a computer!

### Option 3: TrollStore (iOS 14.0 - 16.6.1 / 17.0)
If your device is running a TrollStore-supported iOS version:
1. Open TrollStore.
2. Share `Music.ipa` directly to TrollStore or tap **+** -> **Install IPA File**.
3. Permanently installed with no 7-day expiration and no app limits!

### Option 4: Sideloadly (Windows / Mac)
1. Download [Sideloadly](https://sideloadly.io/).
2. Plug your iPhone into your PC.
3. Drag and drop `Music.ipa` into Sideloadly.
4. Enter your Apple ID and click **Start**.

---

## 🛠️ Automated CI / GitHub Actions Pipeline

Whenever you push commits or tags to GitHub, the included `.github/workflows/build-ipa.yml` workflow automatically runs:

1. Spins up a `macos-14` Apple Silicon runner.
2. Builds `AppleMusic.xcodeproj` with `xcodebuild archive`.
3. Packages the application bundle into `Music.ipa`.
4. Uploads `Music.ipa` directly to GitHub Actions Artifacts ready for one-click download.

To trigger manually:
- Go to your repository on GitHub.
- Click **Actions** -> **Build Sideloadable IPA** -> **Run workflow**.
