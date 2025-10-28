# Build System File Structure

```
build/
│
├── 📘 README.md                    # Comprehensive documentation
├── 📗 QUICK_START.md               # Quick reference guide
├── 📙 CHANGELOG.md                 # Release notes template
├── 📕 SETUP_COMPLETE.md            # This setup guide
├── 📋 version.txt                  # Current version (1.0.0)
├── 🔒 .gitignore                   # Exclude outputs from git
│
├── 🔨 Build Scripts (Windows)
│   ├── build.bat                   # Full-featured build
│   ├── build_simple.bat            # Simplified build (recommended)
│   └── test_build.bat              # Test built .love file
│
├── 🔧 Build Scripts (Linux/macOS)
│   ├── build.sh                    # Full-featured build
│   └── test_build.sh               # Test built .love file
│
├── 📦 output/                      # Build outputs (generated)
│   ├── alienfall.love              # Universal Love2D package
│   ├── alienfall-windows.zip       # Windows build (optional)
│   ├── alienfall-linux.tar.gz      # Linux build (optional)
│   └── alienfall-macos.zip         # macOS build (optional)
│
└── 🗂️ temp/                        # Temporary build files (generated)
    └── package/                    # Staging area for .love contents
        ├── main.lua
        ├── conf.lua
        ├── icon.png
        ├── [all engine/ folders]
        └── mods/
            └── core/
```

---

## File Purposes

### Documentation Files

**README.md** (Comprehensive)
- Full build system documentation
- Love2D best practices
- Troubleshooting guide
- Platform-specific build instructions
- Advanced configuration

**QUICK_START.md** (Quick Reference)
- Essential commands
- Common tasks
- Quick troubleshooting
- Distribution checklist

**CHANGELOG.md** (Release Notes)
- Template for version history
- What changed in each release
- Breaking changes documentation

**SETUP_COMPLETE.md** (Setup Guide)
- Installation verification
- First build instructions
- Testing procedures
- Next steps

**version.txt** (Version Number)
- Single source of truth for version
- Used by build scripts
- Semantic versioning (MAJOR.MINOR.PATCH)

---

### Build Scripts

**build_simple.bat** (Windows - Recommended)
- Simplified build process
- Creates alienfall.love
- Easy to understand and modify
- Good for most use cases

**build.bat** (Windows - Full Featured)
- Advanced build options
- Platform-specific builds
- Cleanup prompts
- 7-Zip support

**build.sh** (Linux/macOS)
- Cross-platform build
- Creates .love + platform builds
- AppImage for Linux
- .app bundle for macOS

**test_build.bat/sh** (Testing)
- Automated validation
- File size checks
- Structure verification
- Runtime testing

---

### Generated Directories

**output/** (Build Results)
- Contains final distributable files
- `alienfall.love` - Universal package
- Platform-specific builds (if enabled)
- Excluded from git (.gitignore)

**temp/** (Build Staging)
- Temporary files during build
- `package/` subfolder with .love contents
- Cleaned up after build (optional)
- Excluded from git (.gitignore)

---

## What Goes Into alienfall.love

```
alienfall.love (ZIP file containing:)
│
├── main.lua                        # Entry point (required at root)
├── conf.lua                        # Love2D config (required at root)
├── icon.png                        # Game icon
│
├── 🎮 Engine Code (from engine/)
│   ├── accessibility/              # Accessibility features
│   ├── ai/                         # AI systems
│   ├── analytics/                  # Analytics and logging
│   ├── assets/                     # Core engine assets
│   ├── audio/                      # Audio system
│   ├── basescape/                  # Base management
│   ├── battlescape/                # Tactical combat
│   ├── content/                    # Content management
│   ├── core/                       # Core systems (state, events)
│   ├── economy/                    # Economy systems
│   ├── geoscape/                   # Strategic map
│   ├── gui/                        # UI framework and scenes
│   ├── interception/               # Air combat
│   ├── libs/                       # Third-party libraries
│   ├── localization/               # i18n support
│   ├── lore/                       # Lore management
│   ├── politics/                   # Faction/diplomacy
│   ├── tutorial/                   # Tutorial system
│   └── utils/                      # Utility functions
│
└── 📦 Game Content (from mods/)
    ├── core/                       # Default game content
    │   ├── mod.toml                # Mod metadata
    │   ├── rules/                  # TOML configurations
    │   │   ├── units/              # Unit definitions
    │   │   ├── items/              # Item definitions
    │   │   ├── facilities/         # Facility definitions
    │   │   ├── crafts/             # Craft definitions
    │   │   ├── missions/           # Mission definitions
    │   │   └── [other content types]
    │   └── assets/                 # Sprites, sounds, data
    │       ├── units/              # Unit sprites
    │       ├── items/              # Item icons
    │       ├── ui/                 # UI elements
    │       └── sounds/             # Audio files
    ├── examples/                   # Example mods
    └── minimal_mod/                # Mod template
```

---

## Build Process Flow

```
1. START
   ↓
2. Read version.txt
   ↓
3. Create output/ and temp/ directories
   ↓
4. VALIDATE
   ├─ Check engine/main.lua exists
   ├─ Check engine/conf.lua exists
   └─ Check mods/core/mod.toml exists
   ↓
5. COPY FILES
   ├─ Copy engine/* → temp/package/
   └─ Copy mods/* → temp/package/mods/
   ↓
6. CLEANUP
   ├─ Remove .luarc.json
   ├─ Remove test_scan.lua
   └─ Remove simple_test.lua
   ↓
7. CREATE ARCHIVE
   ├─ cd temp/package/
   ├─ ZIP all files → alienfall.love
   └─ Move to output/alienfall.love
   ↓
8. VALIDATE OUTPUT
   ├─ Check file exists
   ├─ Check file size (5-50 MB)
   └─ Verify ZIP structure
   ↓
9. SUCCESS!
   └─ output/alienfall.love ready to distribute
```

---

## Distribution Workflow

```
1. Development
   ├─ Code changes in engine/
   ├─ Content changes in mods/
   ├─ Run tests: run\run_tests2_all.bat
   └─ Test in-engine: lovec "engine"
   ↓
2. Prepare Release
   ├─ Update version.txt (1.0.0 → 1.1.0)
   ├─ Update CHANGELOG.md (what's new)
   └─ Review all changes
   ↓
3. Build
   ├─ cd build/
   ├─ Run build_simple.bat
   └─ Wait for completion
   ↓
4. Test Build
   ├─ Run test_build.bat (automated)
   ├─ love output\alienfall.love (manual)
   └─ Verify all features work
   ↓
5. Distribute
   ├─ Create GitHub release
   ├─ Upload alienfall.love
   ├─ Add CHANGELOG notes
   ├─ Tag version: git tag v1.1.0
   └─ Push: git push origin v1.1.0
   ↓
6. Users Download & Play
   ├─ Download alienfall.love
   └─ Run: love alienfall.love
```

---

## Platform-Specific Builds (Optional)

To enable Windows/Linux/macOS builds:

1. **Download Love2D distributions:**
   - Windows: https://love2d.org/ → love-12.0-win64.zip
   - Linux: AppImage from love2d.org
   - macOS: love.app from love2d.org

2. **Extract to build directory:**
   ```
   build/
   ├── love2d-windows/
   │   ├── love.exe
   │   ├── *.dll
   │   └── license files
   ├── love2d-linux/
   │   └── love.AppImage
   └── love2d-macos/
       └── love.app/
   ```

3. **Run build script:**
   - Windows: `build.bat` (detects love2d-windows/)
   - Linux: `./build.sh` (detects love2d-linux/)
   - macOS: `./build.sh` (detects love2d-macos/)

4. **Output includes:**
   - `alienfall.love` (universal)
   - `alienfall-windows.zip` (Windows executable)
   - `alienfall-linux.tar.gz` (Linux AppImage)
   - `alienfall-macos.zip` (macOS app bundle)

---

## Summary

✅ **11 files created** in build/ directory  
✅ **2 build methods** (simple + full-featured)  
✅ **Cross-platform** (Windows, Linux, macOS)  
✅ **Comprehensive docs** (README, Quick Start, Setup)  
✅ **Testing tools** (automated + manual)  
✅ **Best practices** (Love2D standards, semantic versioning)  

**Ready to build!**

```cmd
cd build
build_simple.bat
```

