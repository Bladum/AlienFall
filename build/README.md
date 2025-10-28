# AlienFall Love2D Build System

**Purpose:** Build distributable packages for Windows, Linux, and macOS  
**Output:** `.love` file and platform-specific executables  
**Audience:** Developers, release managers

---

## 🎯 Overview

This build system packages AlienFall for distribution across multiple platforms following Love2D best practices.

**Build Outputs:**
- `alienfall.love` - Universal Love2D package (all platforms)
- `alienfall-windows.zip` - Windows standalone (x64)
- `alienfall-linux.tar.gz` - Linux standalone (x64)
- `alienfall-macos.zip` - macOS application bundle

---

## 📁 Build Structure

```
build/
├── README.md           # This file
├── build.bat           # Windows build script
├── build.sh            # Linux/macOS build script
├── test_build.bat      # Windows build test script
├── test_build.sh       # Linux/macOS build test script
├── version.txt         # Current version number
├── CHANGELOG.md        # Release notes
├── output/             # Build outputs (generated)
│   ├── alienfall.love
│   ├── alienfall-windows.zip
│   ├── alienfall-linux.tar.gz
│   └── alienfall-macos.zip
└── temp/               # Temporary build files (generated)
```

---

## 🚀 Quick Start

### Windows
```cmd
cd build
build.bat
```

### Linux/macOS
```bash
cd build
chmod +x build.sh
./build.sh
```

---

## 📋 Build Process

### What Gets Packaged

**Included:**
- `engine/` folder contents (all .lua files, assets, libs)
- `mods/` folder (game content)
- `engine/icon.png` (game icon)
- `engine/conf.lua` (Love2D configuration)
- `engine/main.lua` (entry point)

**Excluded:**
- `.git/` version control
- `tests2/` test suite
- `docs/` documentation
- `tools/` development tools
- `temp/` temporary files
- `logs/` runtime logs
- `.luarc.json` IDE config
- `test_*.lua` test files

### Build Steps

1. **Clean:** Remove old build artifacts
2. **Validate:** Check version number, verify engine structure
3. **Package:** Create `.love` file (ZIP of engine + mods)
4. **Platform Builds:** Fuse with Love2D runtime for each platform
5. **Test:** Run build to verify it starts
6. **Archive:** Create distribution ZIPs

---

## 🔧 Configuration

### Version Number

Edit `build/version.txt`:
```
1.0.0
```

Uses semantic versioning: MAJOR.MINOR.PATCH
- **MAJOR:** Breaking changes
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes

### Release Notes

Edit `build/CHANGELOG.md` before building:
```markdown
# v1.0.0 - 2025-10-27

## Added
- Feature 1
- Feature 2

## Fixed
- Bug fix 1
- Bug fix 2

## Changed
- Change 1
```

---

## 🎮 Platform-Specific Builds

### Windows Build

**Requirements:**
- Love2D 12.0 for Windows (64-bit)
- 7-Zip or built-in PowerShell Compress-Archive

**Output:** `alienfall-windows.zip`
- Contains: `alienfall.exe`, DLLs, license files
- Fuses `.love` with `love.exe`

**Distribution:**
- Unzip anywhere
- Run `alienfall.exe`
- No installation required

### Linux Build

**Requirements:**
- Love2D 12.0 for Linux (64-bit)
- tar, gzip

**Output:** `alienfall-linux.tar.gz`
- Contains: `alienfall` binary, shared libraries
- Fuses `.love` with Love2D AppImage

**Distribution:**
```bash
tar -xzf alienfall-linux.tar.gz
cd alienfall
./alienfall
```

### macOS Build

**Requirements:**
- Love2D 12.0 for macOS
- Xcode command line tools

**Output:** `alienfall-macos.zip`
- Contains: `AlienFall.app` application bundle
- `.love` file embedded in app bundle

**Distribution:**
- Unzip
- Drag `AlienFall.app` to Applications
- Run from Launchpad or Applications folder

---

## 🧪 Testing Builds

### Automated Test

**Windows:**
```cmd
test_build.bat
```

**Linux/macOS:**
```bash
./test_build.sh
```

**Tests:**
1. `.love` file exists and is valid ZIP
2. Size check (should be 5-50 MB)
3. Contains required files (main.lua, conf.lua)
4. Game launches without errors
5. Main menu appears
6. Exits cleanly

### Manual Test

1. **Run .love directly:**
   ```cmd
   love output/alienfall.love
   ```

2. **Test platform build:**
   - Extract platform-specific ZIP
   - Run executable
   - Verify all features work:
     - Main menu navigation
     - Geoscape loads
     - Basescape loads
     - Battlescape loads
     - Settings work
     - Save/load works

3. **Check logs:**
   - Look for errors in console
   - Verify all mods loaded
   - Check asset loading

---

## 📦 Distribution Checklist

Before releasing:

- [ ] Update version in `build/version.txt`
- [ ] Update `build/CHANGELOG.md` with all changes
- [ ] Update version in `engine/conf.lua` if needed
- [ ] Run full test suite: `run\run_tests2_all.bat`
- [ ] Build for all platforms
- [ ] Test each platform build manually
- [ ] Verify file sizes are reasonable (5-50 MB)
- [ ] Check that mods load correctly
- [ ] Verify saves work across versions (if applicable)
- [ ] Create GitHub release with changelog
- [ ] Upload platform builds to release
- [ ] Tag version in git: `git tag v1.0.0`
- [ ] Push tag: `git push origin v1.0.0`

---

## 🔍 Troubleshooting

### Build fails with "Love2D not found"

**Problem:** Love2D runtime not in expected location  
**Solution:** 
- Download Love2D 12.0 from https://love2d.org/
- Extract to `build/love2d-windows/` (or update script paths)
- Or ensure `love` is in system PATH

### .love file won't run

**Problem:** Corrupted ZIP or missing files  
**Solution:**
- Verify `main.lua` and `conf.lua` exist in root of .love
- Check build script for file copy errors
- Manually unzip and inspect contents

### Game crashes on startup

**Problem:** Missing dependencies or broken paths  
**Solution:**
- Check that `mods/` folder is included
- Verify all `require()` paths use relative paths
- Check console output for missing files
- Ensure `libs/` folder is included with all libraries

### Mods not loading

**Problem:** Mod path incorrect in packaged build  
**Solution:**
- Verify `mods/` is at same level as `main.lua` in .love
- Check `engine/mods/mod_manager.lua` uses correct relative paths
- Ensure `mods/core/` exists and has `mod.toml`

### Large file size

**Problem:** Unnecessary files included  
**Solution:**
- Review exclusion list in build script
- Remove test assets from `mods/core/assets/`
- Compress audio files (OGG Vorbis, quality 5-7)
- Compress images (PNG with pngcrush or similar)

---

## 📚 Love2D Build Best Practices

### File Structure in .love

```
alienfall.love (ZIP file)
├── main.lua           # Entry point (MUST be in root)
├── conf.lua           # Configuration (MUST be in root)
├── icon.png           # Game icon
├── accessibility/     # Engine folders
├── ai/
├── audio/
├── ... (all engine/ contents)
└── mods/              # Game content
    └── core/
        ├── mod.toml
        ├── rules/
        └── assets/
```

### Path Handling

**Correct (relative):**
```lua
require("core.state.state_manager")
require("mods.mod_manager")
love.graphics.newImage("assets/icon.png")
```

**Incorrect (absolute):**
```lua
require("C:/Projects/engine/core/state/state_manager")
love.graphics.newImage("C:/Projects/mods/core/assets/icon.png")
```

### Asset Loading

**Use Love2D filesystem:**
```lua
-- Correct
local image = love.graphics.newImage("mods/core/assets/units/soldier.png")

-- Also correct (for save data)
love.filesystem.write("save1.dat", data)
local contents = love.filesystem.read("save1.dat")
```

### Debugging Builds

**Enable console in conf.lua:**
```lua
t.console = true  -- Shows print() output on Windows
```

**Add logging:**
```lua
print("[BUILD_TEST] Main.lua loaded")
print("[BUILD_TEST] Mods path: " .. love.filesystem.getSource())
```

---

## 🔗 References

**Love2D Documentation:**
- Game Distribution: https://love2d.org/wiki/Game_Distribution
- Config File: https://love2d.org/wiki/Config_Files
- Filesystem: https://love2d.org/wiki/love.filesystem

**Project Documentation:**
- Main README: `../README.md`
- Modding Guide: `../api/MODDING_GUIDE.md`
- Release Guide: `../docs/instructions/⚡ Release & Deployment.instructions.md`

**Tools:**
- Love2D Downloads: https://love2d.org/
- 7-Zip: https://www.7-zip.org/

---

## ⚙️ Advanced Configuration

### Custom Build Profiles

Create profile-specific builds:

**Demo build:**
- Exclude late-game content
- Disable debug console
- Include demo splash screen

**Development build:**
- Include test suite
- Enable all debug features
- Include profiling tools

**Release build:**
- Strip debug code
- Optimize assets
- Include only core mods

### Continuous Integration

For automated builds (GitHub Actions, GitLab CI):

```yaml
# .github/workflows/build.yml
name: Build Game
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Love2D
        run: sudo apt-get install love
      - name: Build
        run: cd build && ./build.sh
      - name: Test
        run: cd build && ./test_build.sh
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: alienfall-builds
          path: build/output/
```

---

**Last Updated:** 2025-10-27  
**Build System Version:** 1.0.0  
**Compatible Love2D:** 12.0+  
**Status:** 🟢 Ready for production builds

