#!/bin/bash
# BioShield - Frida Gadget Downloader
# Downloads the correct Frida Gadget binary for your device

set -e  # Exit on error

FRIDA_VERSION="16.5.9"
DOWNLOAD_DIR="."

echo "===== BioShield Frida Gadget Downloader ====="
echo ""

# Detect architecture
echo "Select your target architecture:"
echo "  1) x86_64 (Android Emulator)"
echo "  2) arm64 (Physical Device - 64-bit)"
echo "  3) arm (Physical Device - 32-bit, older devices)"
echo ""
read -p "Enter choice [1-3]: " arch_choice

case $arch_choice in
    1)
        ARCH="x86_64"
        ;;
    2)
        ARCH="arm64"
        ;;
    3)
        ARCH="arm"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Selected architecture: $ARCH"
echo "Frida version: $FRIDA_VERSION"
echo ""

# Construct download URL
FILENAME="frida-gadget-${FRIDA_VERSION}-android-${ARCH}.so.xz"
URL="https://github.com/frida/frida/releases/download/${FRIDA_VERSION}/${FILENAME}"

echo "Downloading from:"
echo "  $URL"
echo ""

# Check if wget or curl is available
if command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget"
elif command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -LO"
else
    echo "Error: Neither wget nor curl found. Please install one of them."
    exit 1
fi

# Download
echo "Downloading..."
$DOWNLOAD_CMD "$URL"

if [ ! -f "$FILENAME" ]; then
    echo "Error: Download failed"
    exit 1
fi

echo "✓ Downloaded successfully"
echo ""

# Extract
echo "Extracting..."
if ! command -v xz &> /dev/null; then
    echo "Error: 'xz' not found. Please install xz-utils:"
    echo "  Ubuntu/Debian: sudo apt-get install xz-utils"
    echo "  macOS: brew install xz"
    exit 1
fi

xz -d "$FILENAME"

EXTRACTED_FILE="${FILENAME%.xz}"
if [ ! -f "$EXTRACTED_FILE" ]; then
    echo "Error: Extraction failed"
    exit 1
fi

echo "✓ Extracted successfully"
echo ""

# Rename to standard name
mv "$EXTRACTED_FILE" "libfrida-gadget.so"

echo "===== SUCCESS ====="
echo ""
echo "Frida Gadget ready:"
echo "  File: libfrida-gadget.so"
echo "  Architecture: $ARCH"
echo "  Version: $FRIDA_VERSION"
echo ""
echo "Next steps:"
echo "  1. Copy libfrida-gadget.so to app_decompiled/lib/$ARCH/"
echo "  2. Copy libfrida-gadget.config.so to app_decompiled/lib/$ARCH/"
echo "  3. Copy libfrida-gadget.script.so to app_decompiled/lib/$ARCH/"
echo ""
echo "See README.md for complete instructions"
