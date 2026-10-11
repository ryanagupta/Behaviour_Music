#!/usr/bin/env bash
set -e

echo "=================================================="
echo "          xtool Setup Script for WSL/Linux        "
echo "=================================================="

# 1. Update and install system dependencies
echo "[1/4] Updating packages and installing prerequisites..."
sudo apt update
sudo apt install -y curl gpg ca-certificates build-essential libxml2 libsqlite3-0 libfuse2t64 usbmuxd libimobiledevice-utils 2>/dev/null || \
sudo apt install -y curl gpg ca-certificates build-essential libxml2 libsqlite3-0 libfuse2 usbmuxd libimobiledevice-utils

# 2. Check and install Swift toolchain via Swiftly
if ! command -v swift &> /dev/null; then
    echo "[2/4] Installing Swift toolchain via Swiftly..."
    curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz
    tar zxf swiftly-$(uname -m).tar.gz
    ./swiftly init --quiet-shell-followup
    rm -f swiftly-$(uname -m).tar.gz swiftly
    export PATH="$HOME/.local/share/swiftly/bin:$PATH"
    if [ -f "$HOME/.local/share/swiftly/env.sh" ]; then
        source "$HOME/.local/share/swiftly/env.sh"
    fi
else
    echo "[2/4] Swift is already installed: $(swift --version | head -n 1)"
fi

# 3. Download and install xtool
echo "[3/4] Downloading latest xtool AppImage..."
ARCH=$(uname -m)
APPIMAGE_NAME="xtool-${ARCH}.AppImage"
XTOOL_URL="https://github.com/xtool-org/xtool/releases/latest/download/${APPIMAGE_NAME}"

curl -fL "$XTOOL_URL" -o xtool
chmod +x xtool
sudo mv xtool /usr/local/bin/xtool

echo "[4/4] Verifying xtool installation..."
xtool --help > /dev/null

echo "=================================================="
echo " xtool successfully installed!"
echo "=================================================="
echo ""
echo "NEXT STEPS TO BUILD Apple Music IPA LOCALLY:"
echo "1. Download Xcode 16 (.xip) from Apple Developer:"
echo "   https://developer.apple.com/download/all/ (Search 'Xcode 16')"
echo "   Save it in your Windows Downloads folder: C:\\Users\\ry4ngupta\\Downloads\\"
echo ""
echo "2. Setup xtool with your Xcode 16.x archive:"
echo "   xtool setup"
echo "   (When prompted, enter: /mnt/c/Users/ry4ngupta/Downloads/Xcode_16.2.xip)"
echo ""
echo "3. Compile this project into an IPA:"
echo "   cd /mnt/c/Users/ry4ngupta/Documents/antigravity/blissful-pasteur"
echo "   xtool build --release"
echo "=================================================="
