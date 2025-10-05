# Known Issues

**Tags:** #bugs #issues #troubleshooting  
**Last Updated:** September 30, 2025

---

## Critical Issues

### None Currently

---

## High Priority Bugs

### Save Game Compatibility
**Status:** In Progress  
**Affects:** Version 0.3.x saves in version 0.4.x  
**Workaround:** Export squad before updating  
**Fix ETA:** Version 0.4.1

### Performance Degradation on Large Maps
**Status:** Investigating  
**Affects:** Maps larger than 40×40 tiles  
**Workaround:** Reduce visual quality settings  
**Fix ETA:** TBD

---

## Medium Priority Issues

### UI Scaling on 4K Displays
**Status:** Known Issue  
**Affects:** 4K monitors, UI appears small  
**Workaround:** Use windowed mode at 1920×1080  
**Fix ETA:** Version 0.5.0

### Mod Load Order Sometimes Incorrect
**Status:** Investigating  
**Affects:** Mods with complex dependencies  
**Workaround:** Manually adjust load order in settings  
**Fix ETA:** Version 0.4.2

---

## Low Priority Issues

### Minor Visual Glitches
- Rare sprite flickering on death animations
- Shadow rendering artifacts in some conditions
- UI tooltip positioning edge cases

### Audio Issues
- Some sound effects clip on rapid fire
- Music transition occasionally abrupt

---

## Platform-Specific Issues

### Windows
- None currently

### macOS
- First launch may be slow (Love2D caching)
- Retina display scaling needs testing

### Linux
- Some distros need manual Love2D install
- Wayland support untested

---

## Workarounds Collection

### Game Won't Start
1. Run `lovec.exe` (console version) to see errors
2. Check GPU supports OpenGL 2.1+
3. Update graphics drivers
4. Verify all files extracted

### Crashes on Mission Start
1. Disable all mods
2. Delete `save/cache/` folder
3. Verify map blocks folder integrity
4. Check console logs

### Save Won't Load
1. Try loading from main menu (not in-game)
2. Check save file isn't from newer version
3. Restore from backup in `save/backups/`

---

## Reporting New Issues

**Before Reporting:**
- [ ] Check this list
- [ ] Search existing GitHub issues
- [ ] Try with mods disabled
- [ ] Try with clean save

**Include in Report:**
1. **Alien Fall version** (see main menu)
2. **Operating system** and version
3. **Steps to reproduce**
4. **Expected behavior**
5. **Actual behavior**
6. **Console logs** (from `lovec.exe`)
7. **Save file** (if applicable)
8. **Screenshots** (if visual bug)

**Report on GitHub:** [Issues Page](https://github.com/alienfall/alienfall/issues)

---

## Fixed in Recent Versions

### Version 0.3.5 (Sept 2025)
- Fixed crash when destroying cover during overwatch
- Fixed research tree not updating after completion
- Fixed soldier promotions not saving correctly

### Version 0.3.4 (Aug 2025)
- Fixed pathfinding breaking on multi-level maps
- Fixed alien turn AI freezing occasionally
- Fixed equipment duplication exploit

### Version 0.3.3 (July 2025)
- Fixed game hanging on mission victory
- Fixed manufacturing costs displaying incorrectly
- Fixed mod conflicts with base game items

---

## Known Limitations (By Design)

### Not Bugs
- Maximum 8 soldiers per mission (balance decision)
- No multiplayer (engine limitation)
- Fixed 800×600 internal resolution (pixel art design)
- Turn-based only (genre choice)

---

**Last Updated:** September 30, 2025  
**Next Review:** October 7, 2025
