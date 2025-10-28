#!/bin/bash
# AlienFall Love2D Build Script (Linux/macOS)
#
# Purpose: Package AlienFall for distribution
# Output: .love file and platform-specific builds
# Usage: ./build.sh [clean|all]

set -e  # Exit on error

echo "========================================"
echo "AlienFall Build System"
echo "========================================"
echo ""

# Read version
VERSION=$(cat version.txt)
echo "[BUILD] Version: $VERSION"
echo ""

# Determine build mode
BUILD_MODE="${1:-all}"
echo "[BUILD] Mode: $BUILD_MODE"
echo ""

# Setup paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
ENGINE_DIR="$PROJECT_ROOT/engine"
MODS_DIR="$PROJECT_ROOT/mods"
BUILD_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$BUILD_DIR/output"
TEMP_DIR="$BUILD_DIR/temp"

# Clean old builds if requested
if [ "$BUILD_MODE" == "clean" ]; then
    echo "[CLEAN] Removing old build artifacts..."
    rm -rf "$OUTPUT_DIR"
    rm -rf "$TEMP_DIR"
    echo "[CLEAN] Done."
    echo ""
fi

# Create output directories
echo "[SETUP] Creating output directories..."
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR/package"
echo "[SETUP] Done."
echo ""

# Validate engine structure
echo "[VALIDATE] Checking engine structure..."
if [ ! -f "$ENGINE_DIR/main.lua" ]; then
    echo "[ERROR] main.lua not found in engine directory!"
    exit 1
fi
if [ ! -f "$ENGINE_DIR/conf.lua" ]; then
    echo "[ERROR] conf.lua not found in engine directory!"
    exit 1
fi
if [ ! -f "$MODS_DIR/core/mod.toml" ]; then
    echo "[ERROR] Core mod not found in mods directory!"
    exit 1
fi
echo "[VALIDATE] Engine structure OK."
echo ""

# Copy engine files to temp package directory
echo "[PACKAGE] Copying engine files..."
cp -r "$ENGINE_DIR"/* "$TEMP_DIR/package/"

# Remove excluded files/folders from package
echo "[PACKAGE] Removing excluded files..."
rm -f "$TEMP_DIR/package/.luarc.json"
rm -f "$TEMP_DIR/package/test_scan.lua"
rm -f "$TEMP_DIR/package/simple_test.lua"

# Copy mods directory to package
echo "[PACKAGE] Copying mods directory..."
mkdir -p "$TEMP_DIR/package/mods"
cp -r "$MODS_DIR"/* "$TEMP_DIR/package/mods/"
echo "[PACKAGE] Files prepared."
echo ""

# Create .love file (ZIP archive)
echo "[BUILD] Creating .love file..."
cd "$TEMP_DIR/package"
zip -9 -r "$OUTPUT_DIR/alienfall.love" . > /dev/null
cd "$BUILD_DIR"

if [ ! -f "$OUTPUT_DIR/alienfall.love" ]; then
    echo "[ERROR] Failed to create .love file!"
    exit 1
fi

# Get file size
SIZE=$(stat -f%z "$OUTPUT_DIR/alienfall.love" 2>/dev/null || stat -c%s "$OUTPUT_DIR/alienfall.love")
SIZE_MB=$((SIZE / 1048576))
echo "[BUILD] Created: alienfall.love (${SIZE_MB} MB)"
echo ""

# Platform-specific builds (optional)
echo "[INFO] Platform-specific builds require Love2D distribution files."
echo "[INFO] Download from: https://love2d.org/"
echo "[INFO] Extract to: build/love2d-linux/, build/love2d-macos/, etc."
echo ""

# Linux build
if [ -d "$BUILD_DIR/love2d-linux" ]; then
    echo "[LINUX] Building Linux AppImage..."
    mkdir -p "$TEMP_DIR/linux"

    # Copy Love2D AppImage
    cp "$BUILD_DIR/love2d-linux/love.AppImage" "$TEMP_DIR/linux/alienfall.AppImage"

    # Fuse .love with AppImage
    cat "$OUTPUT_DIR/alienfall.love" >> "$TEMP_DIR/linux/alienfall.AppImage"
    chmod +x "$TEMP_DIR/linux/alienfall.AppImage"

    # Create tarball
    cd "$TEMP_DIR/linux"
    tar -czf "$OUTPUT_DIR/alienfall-linux.tar.gz" alienfall.AppImage
    cd "$BUILD_DIR"

    if [ -f "$OUTPUT_DIR/alienfall-linux.tar.gz" ]; then
        LINUX_SIZE=$(stat -f%z "$OUTPUT_DIR/alienfall-linux.tar.gz" 2>/dev/null || stat -c%s "$OUTPUT_DIR/alienfall-linux.tar.gz")
        LINUX_SIZE_MB=$((LINUX_SIZE / 1048576))
        echo "[LINUX] Created: alienfall-linux.tar.gz (${LINUX_SIZE_MB} MB)"
    else
        echo "[LINUX] Warning: Failed to create Linux build"
    fi
    echo ""
else
    echo "[INFO] Skipping Linux build (love2d-linux not found)"
    echo ""
fi

# macOS build
if [ -d "$BUILD_DIR/love2d-macos" ]; then
    echo "[MACOS] Building macOS app bundle..."
    mkdir -p "$TEMP_DIR/macos"

    # Copy Love2D.app
    cp -r "$BUILD_DIR/love2d-macos/love.app" "$TEMP_DIR/macos/AlienFall.app"

    # Add .love to app bundle
    cp "$OUTPUT_DIR/alienfall.love" "$TEMP_DIR/macos/AlienFall.app/Contents/Resources/"

    # Update Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleName AlienFall" "$TEMP_DIR/macos/AlienFall.app/Contents/Info.plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.alienfall.game" "$TEMP_DIR/macos/AlienFall.app/Contents/Info.plist" 2>/dev/null || true

    # Create ZIP
    cd "$TEMP_DIR/macos"
    zip -9 -r "$OUTPUT_DIR/alienfall-macos.zip" AlienFall.app > /dev/null
    cd "$BUILD_DIR"

    if [ -f "$OUTPUT_DIR/alienfall-macos.zip" ]; then
        MACOS_SIZE=$(stat -f%z "$OUTPUT_DIR/alienfall-macos.zip" 2>/dev/null || stat -c%s "$OUTPUT_DIR/alienfall-macos.zip")
        MACOS_SIZE_MB=$((MACOS_SIZE / 1048576))
        echo "[MACOS] Created: alienfall-macos.zip (${MACOS_SIZE_MB} MB)"
    else
        echo "[MACOS] Warning: Failed to create macOS build"
    fi
    echo ""
else
    echo "[INFO] Skipping macOS build (love2d-macos not found)"
    echo ""
fi

# Summary
echo "========================================"
echo "Build Complete!"
echo "========================================"
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Files created:"
ls -1 "$OUTPUT_DIR"
echo ""
echo "To test: love output/alienfall.love"
echo "Or run: ./test_build.sh"
echo ""

# Cleanup temp directory (optional)
read -p "Clean up temporary files? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "[CLEANUP] Removing temporary files..."
    rm -rf "$TEMP_DIR"
    echo "[CLEANUP] Done."
fi

echo ""
echo "[BUILD] Success!"
echo ""

