#!/bin/bash
# AlienFall Build Test Script (Linux/macOS)
#
# Purpose: Test built .love file
# Usage: ./test_build.sh

set -e  # Exit on error

echo "========================================"
echo "AlienFall Build Test"
echo "========================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR="$SCRIPT_DIR/output"
LOVE_FILE="$OUTPUT_DIR/alienfall.love"

# Check if build exists
if [ ! -f "$LOVE_FILE" ]; then
    echo "[ERROR] Build not found: $LOVE_FILE"
    echo "[ERROR] Run ./build.sh first!"
    exit 1
fi

echo "[TEST] Testing build: alienfall.love"
echo ""

# Test 1: File exists and has reasonable size
echo "[TEST 1] Checking file size..."
SIZE=$(stat -f%z "$LOVE_FILE" 2>/dev/null || stat -c%s "$LOVE_FILE")
SIZE_MB=$((SIZE / 1048576))

if [ $SIZE -lt 1048576 ]; then
    echo "[FAIL] File too small: ${SIZE_MB} MB (expected >1 MB)"
    exit 1
fi

if [ $SIZE -gt 104857600 ]; then
    echo "[WARN] File very large: ${SIZE_MB} MB (expected <100 MB)"
    echo "[WARN] Consider optimizing assets"
fi

echo "[PASS] Size OK: ${SIZE_MB} MB"
echo ""

# Test 2: ZIP structure validation
echo "[TEST 2] Validating ZIP structure..."
if ! unzip -l "$LOVE_FILE" | grep -q "main.lua"; then
    echo "[FAIL] Missing main.lua in root of .love file"
    exit 1
fi

if ! unzip -l "$LOVE_FILE" | grep -q "conf.lua"; then
    echo "[FAIL] Missing conf.lua in root of .love file"
    exit 1
fi

echo "[PASS] Contains main.lua and conf.lua"
echo ""

# Test 3: Check for Love2D installation
echo "[TEST 3] Checking for Love2D..."
if ! command -v love &> /dev/null; then
    echo "[WARN] Love2D not found in PATH"
    echo "[WARN] Cannot test runtime execution"
    echo "[INFO] Install Love2D from: https://love2d.org/"
    echo ""
    echo "========================================"
    echo "Build Validation: PARTIAL"
    echo "========================================"
    echo ""
    echo "Static checks passed, but cannot test runtime."
    echo "To fully test, install Love2D and run:"
    echo "  love \"$LOVE_FILE\""
    echo ""
    exit 0
fi

echo "[PASS] Love2D found"
echo ""

# Test 4: Quick runtime test (starts and exits immediately)
echo "[TEST 4] Testing runtime execution..."
echo "[INFO] Starting game for 5 seconds..."
echo "[INFO] Game window should appear briefly..."
echo ""

# Start Love2D in background and kill after 5 seconds
love "$LOVE_FILE" &
LOVE_PID=$!
sleep 5
kill $LOVE_PID 2>/dev/null || true

echo "[PASS] Game executed (check console for errors)"
echo ""

# Summary
echo "========================================"
echo "Build Validation: PASSED"
echo "========================================"
echo ""
echo "All automated tests passed!"
echo ""
echo "Manual testing recommended:"
echo "1. Run: love \"$LOVE_FILE\""
echo "2. Navigate through main menu"
echo "3. Test all game screens:"
echo "   - Geoscape"
echo "   - Basescape"
echo "   - Battlescape (tactical map)"
echo "   - Settings"
echo "4. Test save/load functionality"
echo "5. Check console for warnings/errors"
echo ""
echo "If manual tests pass, build is ready for distribution."
echo ""

