# AlienFall Build Quick Reference

## 🚀 Quick Start

### Build Game (Windows)
```cmd
cd build
build.bat
```

### Build Game (Linux/macOS)
```bash
cd build
chmod +x build.sh
./build.sh
```

### Test Build
```cmd
test_build.bat          # Windows
./test_build.sh         # Linux/macOS
```

### Run Build
```cmd
love output\alienfall.love     # Windows
love output/alienfall.love     # Linux/macOS
```

---

## 📁 What Gets Built

**alienfall.love** - Universal Love2D package containing:
- All engine/ code (core, geoscape, battlescape, etc.)
- All mods/ content (core mod with units, items, missions)
- Assets (sprites, sounds, UI elements)
- Configuration files (conf.lua, main.lua)

**Size:** ~5-20 MB (uncompressed engine + mods)

---

## 🔧 Build Process

1. **Copies** engine/ to temp/package/
2. **Copies** mods/ to temp/package/mods/
3. **Removes** test files (.luarc.json, test_*.lua)
4. **Creates** ZIP archive (alienfall.love)
5. **Validates** structure (main.lua, conf.lua present)

---

## ✅ Testing Checklist

### Automated (test_build.bat/sh)
- [x] File size check (1-100 MB)
- [x] ZIP structure validation
- [x] Contains main.lua and conf.lua
- [x] Game launches without crash

### Manual
- [ ] Main menu appears
- [ ] Navigate to Geoscape
- [ ] Navigate to Basescape
- [ ] Navigate to Battlescape
- [ ] Test save/load
- [ ] Check console for errors
- [ ] Verify mods loaded (check console output)

---

## 🐛 Common Issues

### "Love2D not found"
**Solution:** Install from https://love2d.org/ or add to PATH

### "Build failed - main.lua not found"
**Solution:** Ensure engine/main.lua exists, run from project root

### "Mods not loading"
**Solution:** Verify mods/core/mod.toml exists and is copied

### "File too large"
**Solution:** 
- Remove unused assets from mods/core/assets/
- Compress PNG files
- Use OGG Vorbis for audio (quality 5-7)

---

## 📦 Distribution

1. Test build thoroughly (manual checklist)
2. Update version.txt (1.0.0 → 1.1.0)
3. Update CHANGELOG.md with changes
4. Run build.bat/sh
5. Upload alienfall.love to GitHub Releases
6. Tag release: `git tag v1.0.0`
7. Push tag: `git push origin v1.0.0`

---

## 🔗 Resources

- **Love2D Docs:** https://love2d.org/wiki/
- **Game Distribution:** https://love2d.org/wiki/Game_Distribution
- **Full README:** build/README.md
- **Project README:** ../README.md

---

**Last Updated:** 2025-10-27  
**Build Version:** 1.0.0

