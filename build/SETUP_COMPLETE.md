# AlienFall Build System - Setup Guide

## ✅ Build System Installation Complete

The build system has been set up in the `build/` directory with the following files:

### 📄 Files Created

1. **README.md** - Comprehensive documentation (best practices, troubleshooting)
2. **QUICK_START.md** - Quick reference guide
3. **CHANGELOG.md** - Release notes template
4. **version.txt** - Current version (1.0.0)
5. **build.bat** - Full-featured Windows build script
6. **build_simple.bat** - Simplified Windows build script (recommended)
7. **build.sh** - Linux/macOS build script
8. **test_build.bat** - Windows build testing script
9. **test_build.sh** - Linux/macOS build testing script
10. **.gitignore** - Exclude build outputs from git

---

## 🚀 How to Build

### Windows (Recommended - Simple Version)

```cmd
cd build
build_simple.bat
```

This will:
1. ✅ Validate engine structure (main.lua, conf.lua)
2. ✅ Copy engine/ contents to temp/package/
3. ✅ Copy mods/ to temp/package/mods/
4. ✅ Remove test files (.luarc.json, test_*.lua)
5. ✅ Create alienfall.love (ZIP archive)
6. ✅ Place output in build/output/alienfall.love

### Windows (Full-Featured Version)

```cmd
cd build
build.bat
```

Includes additional features:
- Platform-specific builds (Windows .exe, Linux AppImage, macOS .app)
- Requires Love2D distribution files in love2d-windows/, etc.
- Cleanup prompts

### Linux/macOS

```bash
cd build
chmod +x build.sh
./build.sh
```

---

## 📦 What Gets Packaged

### Included in alienfall.love:

```
alienfall.love (ZIP containing:)
├── main.lua              # Entry point
├── conf.lua              # Love2D configuration
├── icon.png              # Game icon
├── accessibility/        # All engine folders
├── ai/
├── analytics/
├── assets/
├── audio/
├── basescape/
├── battlescape/
├── content/
├── core/
├── economy/
├── geoscape/
├── gui/
├── interception/
├── libs/
├── localization/
├── lore/
├── politics/
├── tutorial/
├── utils/
└── mods/                 # Game content
    ├── core/             # Default game content
    │   ├── mod.toml
    │   ├── rules/        # TOML configurations
    │   └── assets/       # Sprites, sounds
    ├── examples/
    └── minimal_mod/
```

### Excluded:

- `.luarc.json` (IDE config)
- `test_scan.lua` (test file)
- `simple_test.lua` (test file)
- Any .git folders
- Build artifacts

---

## 🧪 Testing Your Build

### Automated Test

```cmd
cd build
test_build.bat          # Windows
./test_build.sh         # Linux/macOS
```

Tests:
- ✅ File size (should be 5-50 MB)
- ✅ ZIP structure (main.lua, conf.lua present)
- ✅ Game launches
- ✅ Runs for 5 seconds without crash

### Manual Test

```cmd
love output\alienfall.love     # Windows
love output/alienfall.love     # Linux/macOS
```

**Test Checklist:**
- [ ] Main menu appears
- [ ] Navigate to Geoscape
- [ ] Navigate to Basescape  
- [ ] Navigate to Battlescape
- [ ] Settings menu works
- [ ] Save/Load works
- [ ] Console shows no errors
- [ ] Mods loaded successfully (check console output)

---

## 🔧 Build Process Details

### Step 1: Preparation

The build script:
1. Reads version from `version.txt`
2. Creates `output/` and `temp/` directories
3. Validates engine structure

### Step 2: File Collection

1. Copies all `engine/` files to `temp/package/`
2. Copies `mods/` directory to `temp/package/mods/`
3. Removes excluded files (test files, IDE configs)

### Step 3: Packaging

1. Changes to `temp/package/` directory
2. Creates ZIP archive using PowerShell Compress-Archive
3. Names it `alienfall.love`
4. Moves to `output/` directory

### Step 4: Validation

1. Checks that `alienfall.love` exists
2. Displays file size
3. Ready for testing

---

## 📋 Pre-Release Checklist

Before distributing:

- [ ] Update `version.txt` (e.g., 1.0.0 → 1.1.0)
- [ ] Update `CHANGELOG.md` with all changes since last release
- [ ] Run full test suite: `run\run_tests2_all.bat`
- [ ] Run build script: `build_simple.bat`
- [ ] Test build manually (all screens, save/load)
- [ ] Check file size is reasonable (5-50 MB)
- [ ] Verify console output (no errors)
- [ ] Test on clean system (no development dependencies)
- [ ] Create GitHub release
- [ ] Tag version in git: `git tag v1.0.0`
- [ ] Push tag: `git push origin v1.0.0`

---

## 🐛 Troubleshooting

### Build fails: "main.lua not found"

**Cause:** Running from wrong directory  
**Solution:** Must run from `build/` directory

```cmd
cd C:\Users\tombl\Documents\Projects\build
build_simple.bat
```

### Build fails: "PowerShell command not found"

**Cause:** Old Windows version without PowerShell  
**Solution:** 
1. Use `build.bat` instead (supports 7-Zip)
2. Or install 7-Zip from https://www.7-zip.org/

### .love file won't run: "No such file or directory"

**Cause:** Love2D not installed  
**Solution:** Install Love2D from https://love2d.org/

### Game crashes on startup: "module not found"

**Cause:** Incorrect paths in .love file  
**Solution:**
1. Verify `mods/` folder is at root level in .love
2. Check that all `require()` statements use relative paths
3. Extract .love (it's a ZIP) and inspect structure

### Mods not loading

**Cause:** mod.toml missing or incorrect structure  
**Solution:**
1. Verify `mods/core/mod.toml` exists in .love file
2. Check console output for mod loading errors
3. Verify mods/ is copied correctly by build script

### File size too large

**Cause:** Unnecessary assets included  
**Solution:**
1. Compress PNG assets (use pngcrush or similar)
2. Use OGG Vorbis for audio (quality 5-7)
3. Remove unused assets from mods/core/assets/
4. Check for accidentally included large files

---

## 📚 Additional Resources

**Documentation:**
- Full README: `build/README.md`
- Quick Start: `build/QUICK_START.md`
- Project README: `../README.md`
- Modding Guide: `../api/MODDING_GUIDE.md`

**Love2D Resources:**
- Game Distribution: https://love2d.org/wiki/Game_Distribution
- Config Files: https://love2d.org/wiki/Config_Files
- Filesystem: https://love2d.org/wiki/love.filesystem

**Project Resources:**
- Discord: (TBD)
- GitHub: (TBD)
- Documentation: `../docs/`

---

## 🎯 Next Steps

1. **Test the build:**
   ```cmd
   cd build
   build_simple.bat
   love output\alienfall.love
   ```

2. **Verify everything works:**
   - Main menu loads
   - All screens accessible
   - No console errors

3. **Customize for release:**
   - Update version in `version.txt`
   - Edit `CHANGELOG.md`
   - Run build again

4. **Distribute:**
   - Upload `alienfall.love` to GitHub Releases
   - Users can run with: `love alienfall.love`
   - Or provide platform-specific builds

---

## 💡 Best Practices

### Version Numbering (Semantic Versioning)

- **MAJOR.MINOR.PATCH** (e.g., 1.0.0)
- **MAJOR:** Breaking changes (incompatible saves, major gameplay changes)
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes, balance tweaks

### Distribution

1. **Universal .love file** (cross-platform, requires Love2D)
2. **Platform builds** (includes Love2D, larger but easier for users)

### Testing

- Always test on clean system before release
- Verify save compatibility if updating existing version
- Check all game modes (Geoscape, Basescape, Battlescape)

### Documentation

- Keep CHANGELOG.md updated
- Document breaking changes prominently
- Include migration guide for save files if needed

---

**Build System Version:** 1.0.0  
**Created:** 2025-10-28  
**Status:** ✅ Ready for use  
**Tested:** Pending first manual test

---

## Summary

The build system is now complete and ready to use:

✅ **Scripts created** - Windows and Linux/macOS build scripts  
✅ **Documentation** - Comprehensive guides and quick references  
✅ **Testing tools** - Automated and manual testing procedures  
✅ **Best practices** - Following Love2D distribution standards  

**To build your first .love file, run:**
```cmd
cd build
build_simple.bat
```

The output will be in `build/output/alienfall.love` and can be distributed or tested with `love output\alienfall.love`.

