# Apple Music iOS Replica (1-to-1 Native SwiftUI App)

A pixel-perfect, 1-to-1 native iOS replica of Apple Music built in Swift & SwiftUI for iOS 17.0+ & iOS 18, complete with on-device music streaming, time-synced karaoke lyrics, offline downloads, dynamic blurred mesh backgrounds, lock screen controls, and two separate build pipelines:
1. **Local Build on Windows via `xtool` + WSL (No Mac required)**
2. **Automated Cloud Build via GitHub Actions (Zero local setup)**

---

## 🏗️ How to Get / Build the `.ipa`

You have **two complete ways** to get your compiled `Music.ipa`:

---

### Option A: Local Build on Windows using `xtool` & WSL (No Mac Needed)

`xtool` compiles Swift Package Manager projects for iOS using the official Apple SDK on Linux/WSL.

#### Step 1: Install WSL (Ubuntu 24.04)
1. Open PowerShell as Administrator (Right click Start Menu -> **Terminal (Admin)** or **PowerShell (Admin)**).
2. Run:
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```
3. Restart your computer when prompted.
4. Launch **Ubuntu 24.04** from your Windows Start Menu and set your Linux username and password.

#### Step 2: Download Xcode 16 from Apple
1. Log into [Apple Developer Downloads](https://developer.apple.com/download/all/).
2. Search for **Xcode 16** (e.g. `Xcode_16.2.xip` or `Xcode_16.0.xip`) — *this contains the iOS 18 SDK*.
3. Save it in your Windows Downloads folder (`C:\Users\ry4ngupta\Downloads`).

#### Step 3: Run the Automated `xtool` Installer
In your Ubuntu terminal, run:
```bash
cd /mnt/c/Users/ry4ngupta/Documents/antigravity/blissful-pasteur
chmod +x ./install-xtool.sh
./install-xtool.sh
```

#### Step 4: Extract the iOS SDK & Configure Signing
In Ubuntu, run:
```bash
xtool setup
```
When prompted for the path to the Xcode archive, provide:
```bash
/mnt/c/Users/ry4ngupta/Downloads/Xcode_16.2.xip
```
Follow the on-screen prompt to authenticate with your Apple ID for code signing.

#### Step 5: Compile `AppleMusic.ipa`
```bash
cd /mnt/c/Users/ry4ngupta/Documents/antigravity/blissful-pasteur
xtool build --release
```
`xtool` compiles the Swift Package (`Package.swift`), links the framework dependencies, and generates your sideloadable `.ipa` right on your computer!

---

### Option B: Cloud Build via GitHub Actions (Fastest, No 12GB Download)

If you don't want to install WSL or download a 12GB Xcode file, GitHub Actions will compile it on Apple Silicon in ~2 minutes for free:

1. Push this repository to GitHub:
   ```powershell
   git remote add origin https://github.com/<YOUR-USERNAME>/<YOUR-REPO>.git
   git push -u origin main
   ```
2. Go to your repo on GitHub -> click **Actions** -> **Build Sideloadable IPA**.
3. Download the **Music-IPA** zip artifact at the bottom of the completed run.
4. Inside is your compiled **`Music.ipa`**.

---

## 📲 Sideloading onto your iPhone

Once you have `Music.ipa` (either from `xtool` or GitHub Actions):

- **AltStore / SideStore**: Open AltStore/SideStore on your iPhone, tap **+**, select `Music.ipa`, and enter your free personal Apple ID.
- **Sideloadly (Windows)**: Connect your iPhone via USB, drag `Music.ipa` into Sideloadly, and click **Start**.
- **TrollStore** *(iOS 14 - 16.6.1 / 17.0)*: Open `Music.ipa` directly in TrollStore for permanent signing without refresh limits.

---

## ✨ 1-to-1 UI Parity Features

- **iOS 18 Floating Island Tab Bar**: Floating `.ultraThinMaterial` pill `[ Home | New | Radio | Library ]` with detached circular search button.
- **Docked Mini-Player**: Floats above island tab bar; displays active artwork thumbnail, title, artist, and play/skip buttons (or "Not Playing" idle state).
- **Now Playing Sheet**: Dynamic animated mesh gradient background, user listening pill, Star favorite button, Ellipsis menu, scrubber with countdown remaining, transport controls, volume slider, Lyrics bubble, and AirPlay/SharePlay capsule.
- **Album Detail**: Hero full-bleed artwork with ambient color transition (warm cream for *The Weeknd*, deep ocean blue for *SZA*), Dolby Atmos / Hi-Res Lossless badges, Shuffle / ▶ Play / + trio, and tracklist with live equalizer bars.
- **Search**: Centered search header with mic and red Cancel button, scope bar `[ Apple Music | Library ]`, 2-column Category Cards, and live suggestions with `🔍` prefix.
- **Zero-Key Streaming**: Piped / YouTube audio extraction with Apple CDN preview fallback.
- **Background Playback & Lock Screen**: `AVAudioSession` `.playback` + `MPNowPlayingInfoCenter` + `MPRemoteCommandCenter`.
"# Behaviour_Music" 
