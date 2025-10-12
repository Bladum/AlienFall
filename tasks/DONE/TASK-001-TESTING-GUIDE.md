# TASK-001 Testing Guide

## Status: ✅ GAME IS RUNNING

The game has been launched successfully. Follow this guide to verify all features.

---

## 🎮 Testing Checklist

### 1. Launch Verification ✅
- [x] Game launched via `run_xcom.bat`
- [ ] Main menu displays correctly
- [ ] Can navigate to Battlescape

### 2. Hex Grid System Testing

#### Basic Grid Display
1. Navigate to Battlescape from main menu
2. **Press F9** to toggle hex grid overlay
3. **Expected:** Green hexagonal grid appears over the map
4. **Verify:**
   - [ ] Grid appears/disappears on F9 toggle
   - [ ] Hexagons are properly shaped
   - [ ] Grid aligns with 24px tiles
   - [ ] No rendering glitches

#### Grid Coordinate System
1. With hex grid visible (F9)
2. Move mouse over different hexes
3. **Expected:** Hex coordinates displayed in debug mode
4. **Verify:**
   - [ ] Coordinates update as mouse moves
   - [ ] Even-Q offset pattern visible
   - [ ] No coordinate misalignment

### 3. Fog of War Testing

#### FOW Toggle
1. **Press F8** to toggle fog of war
2. **Expected:** FOW overlay appears/disappears
3. **Verify:**
   - [ ] FOW toggles on/off correctly
   - [ ] No rendering artifacts
   - [ ] Explored/visible/hidden states clear

### 4. Debug Mode Testing

#### Debug Information Display
1. **Press F10** to enable debug mode
2. **Expected:** Additional debug info appears
3. **Verify:**
   - [ ] Debug info overlay visible
   - [ ] Performance metrics shown
   - [ ] Module logging appears in console
   - [ ] No performance degradation

#### Debug Console Output
1. Check the Love2D console window
2. **Expected:** Module-prefixed log messages
3. **Verify:**
   - [ ] `[HexSystem]` messages present
   - [ ] `[MovementSystem]` messages present
   - [ ] `[VisionSystem]` messages present
   - [ ] No error messages
   - [ ] No Lua stack traces

### 5. Integration Testing

#### System Initialization
1. Check console output on battlescape enter
2. **Expected Messages:**
   ```
   [HexSystem] Initialized 60x60 hex grid (24px tiles)
   [Debug] Debug mode initialized
   [Debug] FOW display: enabled
   [Debug] Hex grid display: disabled
   ```
3. **Verify:**
   - [ ] All systems initialized
   - [ ] No error messages
   - [ ] Correct grid dimensions

#### Key Handler Testing
1. Press each debug key multiple times
2. **Test sequence:**
   - F8 → F8 → F8 (toggle FOW 3 times)
   - F9 → F9 → F9 (toggle hex grid 3 times)
   - F10 → F10 → F10 (toggle debug 3 times)
3. **Verify:**
   - [ ] All toggles work correctly
   - [ ] No key conflicts
   - [ ] State persists correctly
   - [ ] No crashes

### 6. Performance Testing

#### Frame Rate Check
1. With all debug features enabled (F8, F9, F10)
2. Move camera around the map
3. **Expected:** Smooth 60 FPS performance
4. **Verify:**
   - [ ] No frame drops
   - [ ] No stuttering
   - [ ] Smooth camera panning
   - [ ] Hex grid renders smoothly

#### Memory Check
1. Toggle features on/off repeatedly
2. Play for 5 minutes with all features enabled
3. **Expected:** No memory leaks
4. **Verify:**
   - [ ] Memory usage stable
   - [ ] No growing memory footprint
   - [ ] No garbage collection spikes

---

## 🐛 Known Issues & Workarounds

### Issue: Hex Grid Not Visible
**Symptom:** F9 pressed but no grid appears  
**Solution:** Ensure you're in Battlescape, not menu  
**Status:** Expected behavior

### Issue: Console Messages Too Verbose
**Symptom:** Too many debug messages  
**Solution:** Press F10 to disable debug mode  
**Status:** Normal in debug mode

### Issue: Coordinate Mismatch
**Symptom:** Hex coordinates don't match mouse position  
**Solution:** Camera offset not accounted for - this is expected  
**Status:** Known limitation, fix in future update

---

## 📊 Test Results Log

### Test Run #1 - Initial Launch
**Date:** _____________  
**Tester:** _____________  

| Test | Status | Notes |
|------|--------|-------|
| Game Launch | ⬜ Pass / ⬜ Fail | |
| Main Menu | ⬜ Pass / ⬜ Fail | |
| Battlescape Load | ⬜ Pass / ⬜ Fail | |
| F9 Hex Grid | ⬜ Pass / ⬜ Fail | |
| F8 FOW Toggle | ⬜ Pass / ⬜ Fail | |
| F10 Debug Mode | ⬜ Pass / ⬜ Fail | |
| Console Output | ⬜ Pass / ⬜ Fail | |
| Performance | ⬜ Pass / ⬜ Fail | |

**Overall Status:** ⬜ PASS / ⬜ FAIL

**Issues Found:**
```
[List any issues discovered during testing]
```

---

## 🔍 Manual Verification Steps

### Verify HexSystem Integration

1. Open `engine/modules/battlescape.lua`
2. Verify lines 1-30: Requires present
3. Verify line ~50: HexSystem initialization
4. Verify line ~625: Key handlers added
5. Verify line ~440: Hex grid rendering added

**Checklist:**
- [ ] All requires present
- [ ] HexSystem initialized correctly
- [ ] Key handlers properly mapped
- [ ] Rendering code in draw loop

### Verify File Structure

```
engine/systems/battle/
├── components/      [5 files ✓]
├── systems/         [3 files ✓]
├── entities/        [1 file ✓]
├── utils/           [2 files ✓]
└── tests/           [2 files ✓]
```

**Checklist:**
- [ ] All 13 files present
- [ ] No missing modules
- [ ] Directory structure correct

---

## 🎯 Acceptance Criteria

### Must Pass (Critical)
- [x] Game launches without errors
- [ ] Battlescape loads correctly
- [ ] F9 toggles hex grid
- [ ] No crashes or Lua errors
- [ ] Console output clean

### Should Pass (Important)
- [ ] F8 toggles FOW correctly
- [ ] F10 enables debug mode
- [ ] Performance remains smooth
- [ ] All systems initialized

### Nice to Have (Optional)
- [ ] Hex coordinates display accurately
- [ ] Vision cones render (if units exist)
- [ ] Debug logging informative

---

## 📝 Next Steps After Testing

### If All Tests Pass ✅
1. Mark TASK-001 as fully validated
2. Update FAQ.md with hex system info
3. Update DEVELOPMENT.md with ECS architecture
4. Plan Phase 8 (unit migration)

### If Tests Fail ❌
1. Document all failures in this file
2. Create bug fix tasks
3. Debug using Love2D console
4. Iterate on implementation

### If Partial Pass ⚠️
1. Document passing features
2. Create tasks for failing features
3. Prioritize fixes
4. Update timeline

---

## 🚀 Quick Commands

```bash
# Launch game
cd c:\Users\tombl\Documents\Projects
lovec engine

# Run tests
cd engine/systems/battle/tests
lovec test_ecs_components.lua
lovec test_all_systems.lua

# View logs
# (Check Love2D console window)

# Stop game
# (Close game window or Ctrl+C in terminal)
```

---

## 📞 Debug Hotkeys Reference

| Key | Function | State |
|-----|----------|-------|
| **F8** | Toggle Fog of War | Default: ON |
| **F9** | Toggle Hex Grid | Default: OFF |
| **F10** | Toggle Debug Mode | Default: OFF |
| **F11** | _(Reserved)_ | - |
| **F12** | Toggle Fullscreen | Always available |

---

## ✅ Testing Complete

**Date:** _____________  
**Final Status:** ⬜ ALL TESTS PASS

**Sign-off:**
- Tester: _____________
- Date: _____________
- Notes: _____________

---

**Remember:** This is a hex grid OVERLAY system. The existing rectangular grid still functions normally. The hex system is for future migration and can be toggled on/off for testing.

**Status:** Ready for comprehensive testing! 🎮
