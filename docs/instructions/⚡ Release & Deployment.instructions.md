# ⚡ Release & Deployment Best Practices

**Domain:** Deployment & Distribution  
**Focus:** Build automation, versioning, release process, platform packaging  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers preparing releases, automating builds, managing versions, and deploying across platforms.

## Build Automation

### ✅ DO: Implement Semantic Versioning

```lua
-- version.lua
VERSION = {
    major = 1,
    minor = 2,
    patch = 3,
    prerelease = nil,  -- "alpha", "beta", "rc1", nil for release
}

function getVersionString()
    local version = VERSION.major .. "." .. VERSION.minor .. "." .. VERSION.patch
    if VERSION.prerelease then
        version = version .. "-" .. VERSION.prerelease
    end
    return version
end

-- Usage
print("Game Version: " .. getVersionString())  -- "1.2.3" or "1.2.3-beta"
```

---

### ✅ DO: Automate Version Bumping

```batch
:: bump_version.bat
@echo off

:: Read current version
for /f "tokens=*" %%A in ('findstr "^VERSION" version.lua') do set VERSION_LINE=%%A

:: Parse and increment
set MAJOR=1
set MINOR=2
set PATCH=3

:: Check what to bump
if "%1"=="major" (
    set /a MAJOR+=1
    set MINOR=0
    set PATCH=0
) else if "%1"=="minor" (
    set /a MINOR+=1
    set PATCH=0
) else (
    set /a PATCH+=1
)

:: Write updated version
(
    echo VERSION = {
    echo     major = %MAJOR%,
    echo     minor = %MINOR%,
    echo     patch = %PATCH%,
    echo     prerelease = nil,
    echo }
) > version.lua

echo Version bumped to %MAJOR%.%MINOR%.%PATCH%
```

---

### ✅ DO: Create Automated Build Script

```bash
#!/bin/bash
# build.sh - Automated build process

set -e  # Exit on error

BUILD_DIR="builds"
VERSION=$(grep -oP 'major = \K\d+' version.lua).$(grep -oP 'minor = \K\d+' version.lua).$(grep -oP 'patch = \K\d+' version.lua)
BUILD_NAME="alienfall_v${VERSION}"

echo "[BUILD] Starting build for version $VERSION"

# Create build directory
mkdir -p $BUILD_DIR/$BUILD_NAME

# Copy engine files
cp -r engine/* $BUILD_DIR/$BUILD_NAME/
cp conf.lua $BUILD_DIR/$BUILD_NAME/
cp main.lua $BUILD_DIR/$BUILD_NAME/

# Copy assets
cp -r assets $BUILD_DIR/$BUILD_NAME/

# Create distribution packages for each platform
for platform in windows linux macos; do
    echo "[BUILD] Packaging for $platform"
    # Platform-specific packaging logic
done

echo "[BUILD] Build complete: $BUILD_DIR/$BUILD_NAME"
```

---

## Release Workflow

### ✅ DO: Create Release Checklist

```lua
-- release_checklist.txt
[] Version updated in version.lua
[] Changelog updated with new features
[] All tests passing (run_tests.bat)
[] Performance verified (FPS stable at 60+)
[] No console errors with Love2D
[] Assets manifest verified
[] Mod compatibility checked
[] Save file format validated
[] README updated
[] Release notes written
[] Git tag created (v1.2.3)
[] Builds created for all platforms
[] Distribution uploaded
[] Release announcement prepared
```

---

### ✅ DO: Create Changelog Automatically

```lua
function generateChangelog()
    local changelog = {}
    
    -- Get git log since last release
    local git_cmd = "git log --oneline v1.2.2..HEAD"
    local handle = io.popen(git_cmd)
    local result = handle:read("*a")
    handle:close()
    
    -- Parse commits
    local lines = {}
    for line in result:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    -- Format as changelog
    local output = "## Version " .. getVersionString() .. "\n\n"
    for _, commit in ipairs(lines) do
        output = output .. "- " .. commit .. "\n"
    end
    
    return output
end

-- Write to CHANGELOG.md
local changelog = generateChangelog()
love.filesystem.write("CHANGELOG.md", changelog)
```

---

## Practical Implementation

### ✅ DO: Package for Multiple Platforms

```batch
:: package_windows.bat
@echo off

set VERSION=1.2.3
set BUILD_DIR=builds\alienfall_v%VERSION%_windows
set LOVE_EXE="C:\Program Files\LOVE\love.exe"

mkdir %BUILD_DIR%

:: Create .love file
cd %BUILD_DIR%
%LOVE_EXE% --fused . alienfall.exe

:: Create installer metadata
(
    echo [Build]
    echo Version=%VERSION%
    echo BuildDate=%date%
    echo Platform=Windows
) > version.txt

echo Packaged for Windows: %BUILD_DIR%
```

---

### ✅ DO: Verify Builds Before Release

```lua
function verifyBuild(buildPath)
    local checks = {
        main_lua = love.filesystem.getInfo(buildPath .. "/main.lua"),
        conf_lua = love.filesystem.getInfo(buildPath .. "/conf.lua"),
        assets = love.filesystem.getInfo(buildPath .. "/assets"),
        version_file = love.filesystem.getInfo(buildPath .. "/version.txt")
    }
    
    local allOk = true
    for check, result in pairs(checks) do
        if not result then
            print("[VERIFY] Missing: " .. check)
            allOk = false
        end
    end
    
    if allOk then
        print("[VERIFY] Build verified successfully")
    end
    
    return allOk
end
```

---

### ❌ DON'T: Hardcode Paths in Build Script

```bash
# BAD: Hardcoded paths
LOVE_EXE="/Users/tom/love/lovec.exe"
PROJECT_DIR="/c/Users/tom/Documents/Projects"

# GOOD: Use environment variables or relative paths
LOVE_EXE="${LOVE_HOME}/lovec.exe"
PROJECT_DIR="$(pwd)"
```

---

### ❌ DON'T: Release Without Testing

```lua
-- BAD: Skip verification
function releaseQuick()
    zipDir("build/", "game.zip")
    uploadToItch("game.zip")
    -- Done!
end

-- GOOD: Full verification pipeline
function releaseProper()
    if not runAllTests() then error("Tests failed") end
    if not verifyAssets() then error("Asset verification failed") end
    if not verifyBuild() then error("Build verification failed") end
    if not verifyPerformance() then error("Performance test failed") end
    
    zipDir("build/", "game.zip")
    uploadToItch("game.zip")
end
```

---

## Common Patterns & Checklist

- [x] Use semantic versioning (MAJOR.MINOR.PATCH)
- [x] Automate version bumping
- [x] Create build automation scripts
- [x] Package for all target platforms
- [x] Generate changelogs from git history
- [x] Verify builds before release
- [x] Create pre-release checklist
- [x] Tag releases in git
- [x] Document platform-specific requirements
- [x] Plan rollback strategy

---

## References

- Semantic Versioning: https://semver.org/
- GitHub Releases: https://docs.github.com/en/repositories/releasing-projects-on-github
- Itch.io Butler: https://itch.io/docs/butler

