# Resolution System Analysis - Comprehensive Report

**Date:** October 12, 2025  
**Author:** AI Agent  
**Project:** XCOM Simple / AlienFall

---

## Executive Summary

This document provides a complete analysis of all code impacted by implementing a dynamic resolution system with fixed GUI. The analysis identifies 11 files requiring changes, categorized by impact level, with detailed implementation guidance.

### Key Findings

1. **Current Problems:**
   - Action buttons in bottom GUI panel are not visible
   - No hover information display for terrain/units
   - Resolution system scales entire window uniformly (incorrect approach)

2. **Required Solution:**
   - GUI fixed at 240×720 pixels (10×30 tiles)
   - Battlefield viewport scales dynamically with resolution
   - Separate coordinate systems for GUI and battlefield

3. **Impact Assessment:**
   - 5 files require CRITICAL/HIGH impact changes
   - 3 files require MEDIUM/LOW impact changes
   - 3 files require NO changes
   - Estimated effort: 7-11 hours

---

## Problem Analysis

### Current Architecture Issues

#### 1. Uniform Scaling Approach
**Problem:** The current `utils/scaling.lua` module applies uniform scale factors across the entire window.

```lua
-- Current (WRONG)
Scaling.scaleX = windowWidth / BASE_WIDTH   -- e.g., 2.0 at 1920×1080
Scaling.scaleY = windowHeight / BASE_HEIGHT -- e.g., 1.5 at 1920×1080

-- This scales EVERYTHING, including GUI
```

**Impact:**
- GUI widgets become huge at high resolutions
- Text becomes blurry from scaling
- Grid system breaks down
- Mouse coordinates are incorrectly translated

#### 2. Hardcoded Screen Dimensions
**Problem:** Multiple files hardcode `960` and `720` values.

**Locations:**
- `battlescape.lua` line 348: `local screenWidth = 960`
- `battlescape.lua` line 497: `local screenWidth = love.graphics.getWidth()`
- `main.lua` lines 35-36: `BASE_WIDTH = 960`, `BASE_HEIGHT = 720`

**Impact:**
- Cannot adapt to different resolutions
- Assumes fixed window size
- Breaks when user resizes window

#### 3. Missing GUI Elements
**Problem:** Action buttons are defined but not created/rendered.

**Evidence:**
- `battlescape.lua` has `actionsFrame` created
- No button widgets added to frame
- No button click handlers implemented
- `drawGUI()` doesn't render buttons

#### 4. No Hover System
**Problem:** No mechanism to display information about hovered tiles/units.

**Missing Components:**
- No `hoveredTileX/Y` state tracking
- No `mousemoved` update to set hovered tile
- No display logic in `drawInformation()`
- No helper to get unit at position

---

## Detailed File Impact Analysis

### Critical Impact Files

#### File: `engine/modules/battlescape.lua`
**Lines of Code:** 857  
**Impact Level:** CRITICAL  
**Changes Required:** ~200 lines modified/added

**Problem Areas:**

1. **Line 95-113: initUI()**
   - **Issue:** No action buttons created
   - **Fix:** Add 9 button widgets with callbacks
   - **Code:** ~30 lines

2. **Line 343-423: draw()**
   - **Issue:** Hardcoded screen dimensions
   - **Fix:** Use dynamic window dimensions
   - **Code:** Replace ~80 lines

3. **Line 526-558: drawInformation()**
   - **Issue:** No hover information
   - **Fix:** Add terrain and unit hover display
   - **Code:** Add ~40 lines

4. **Line 709-857: Mouse handlers**
   - **Issue:** Incorrect coordinate translation
   - **Fix:** Separate GUI vs battlefield handling
   - **Code:** Replace ~50 lines

5. **New methods needed:**
   - `updateHoveredTile(x, y)` - Track mouse hover
   - `getUnitAt(x, y)` - Find unit at tile
   - ~30 lines

**Total Changes:** ~230 lines

---

#### File: `engine/main.lua`
**Lines of Code:** 294  
**Impact Level:** HIGH  
**Changes Required:** ~100 lines modified

**Problem Areas:**

1. **Line 35-40: Global variables**
   - **Issue:** Scaling system used incorrectly
   - **Fix:** Remove SCALE, update WIDTH/HEIGHT usage
   - **Code:** ~5 lines

2. **Line 47-88: love.load()**
   - **Issue:** Sets up wrong window mode
   - **Fix:** Enable resizable, remove scaling setup
   - **Code:** ~10 lines

3. **Line 96-107: love.draw()**
   - **Issue:** Applies uniform scaling to everything
   - **Fix:** Remove scaling, widgets handle own rendering
   - **Code:** ~10 lines

4. **Line 126-155: love.keypressed() - F12 handler**
   - **Issue:** Scales entire window uniformly
   - **Fix:** Only update window mode, no scaling
   - **Code:** ~20 lines

5. **Line 160-220: Mouse handlers**
   - **Issue:** Uniform scaling applied to coordinates
   - **Fix:** Separate GUI (physical) vs battlefield (viewport) coordinates
   - **Code:** ~60 lines

**Total Changes:** ~105 lines

---

#### File: `engine/utils/scaling.lua` → `viewport.lua`
**Lines of Code:** 62  
**Impact Level:** HIGH  
**Changes Required:** Complete rewrite

**Current API (WRONG):**
```lua
Scaling.scaleX / scaleY / scaleMin
Scaling.update()
Scaling.scale(value)
Scaling.scaleCoordX/Y(value)
Scaling.getGUIDimensions()
Scaling.getTileSize()
```

**New API (CORRECT):**
```lua
-- Constants
Viewport.GUI_WIDTH = 240
Viewport.GUI_HEIGHT = 720
Viewport.TILE_SIZE = 24

-- Functions
Viewport.getBattlefieldViewport() -> x, y, width, height
Viewport.screenToBattlefield(sx, sy) -> bfx, bfy
Viewport.battlefieldToScreen(bfx, bfy) -> sx, sy
Viewport.getVisibleTileBounds(camera, mapWidth, mapHeight) -> minX, minY, maxX, maxY
Viewport.isInGUI(x, y) -> boolean
Viewport.isInBattlefield(x, y) -> boolean
```

**Total Changes:** 62 lines replaced + 40 new = ~100 lines

---

### Medium Impact Files

#### File: `engine/widgets/grid.lua`
**Lines of Code:** 203  
**Impact Level:** MEDIUM  
**Changes Required:** ~50 lines modified

**Problem Areas:**

1. **Line 15-18: Grid dimensions**
   - **Issue:** `COLS = 40`, `ROWS = 30` for full screen
   - **Fix:** `COLS = 10`, `ROWS = 30` for GUI only
   - **Code:** 2 lines

2. **Line 20-22: Scaling factors**
   - **Issue:** Scaling applied to grid
   - **Fix:** Remove scaling (GUI always fixed size)
   - **Code:** Remove ~10 lines

3. **Line 28-56: Scale functions**
   - **Issue:** Provide scaling API
   - **Fix:** Remove or simplify
   - **Code:** ~20 lines

4. **Line 109-203: Debug overlay**
   - **Issue:** Draws grid over entire screen
   - **Fix:** Only draw over GUI area (0-240px width)
   - **Code:** ~20 lines

**Total Changes:** ~50 lines

---

### Low Impact Files

#### File: `engine/conf.lua`
**Lines of Code:** 43  
**Impact Level:** LOW  
**Changes Required:** 1 line

**Change:**
```lua
-- Line 14
t.window.resizable = false  -- BEFORE
t.window.resizable = true   -- AFTER
```

---

#### File: `engine/systems/battle/camera.lua`
**Lines of Code:** 139  
**Impact Level:** LOW  
**Changes Required:** ~5 lines

**Problem:**
- `getVisibleBounds()` accepts viewport dimensions but they default to 720×720

**Fix:**
- Ensure battlescape always passes actual viewport dimensions
- No defaults, require parameters

**Changes:** Parameter validation, ~5 lines

---

#### File: `engine/systems/battle/renderer.lua`
**Lines of Code:** 446  
**Impact Level:** LOW  
**Changes Required:** ~10 lines

**Problem:**
- `draw()` method has optional `viewportWidth/Height` with defaults

**Fix:**
- Remove defaults
- Require viewport dimensions to be passed
- Update call from battlescape

**Changes:** ~10 lines

---

### Minimal/No Impact Files

#### File: `engine/widgets/dialog.lua`
**Lines of Code:** ~120  
**Impact Level:** MINIMAL  
**Changes Required:** 0 lines

**Analysis:**
- Line 24: Uses `love.graphics.getWidth/Height()` for overlay
- **Correct behavior:** Dialog should cover full screen
- **No change needed**

---

#### File: `engine/widgets/tooltip.lua`
**Lines of Code:** ~80  
**Impact Level:** MINIMAL  
**Changes Required:** ~5 lines

**Problem:**
- Tooltip position calculated from mouse without boundary checks

**Fix:**
- Ensure tooltip stays within window bounds
- Already has positioning logic, just need bounds check

**Changes:** ~5 lines

---

#### Files: `engine/modules/menu.lua`, `basescape.lua`
**Impact Level:** NONE  
**Changes Required:** 0 lines

**Analysis:**
- These modules have their own layout systems
- Not affected by battlescape resolution changes
- menu.lua: Centers buttons dynamically (correct)
- basescape.lua: Has its own UI system (separate)

---

## Coordinate System Architecture

### Current (BROKEN) System

```
Screen Space (Physical Pixels)
         ↓ (uniform scale)
    Scaled Space
         ↓
   Logical Space (960×720)
         ↓
    Tile Space
```

**Problem:** Uniform scaling applied to GUI and battlefield together.

### New (CORRECT) System

```
Screen Space (Physical Pixels)
         ↓
    ┌────────────────┬──────────────────────┐
    │                │                      │
    │   GUI Space    │  Battlefield Space   │
    │   (240×720)    │  (dynamic viewport)  │
    │   physical px  │                      │
    │                │    ↓                 │
    │                │  Camera Transform    │
    │                │    ↓                 │
    │                │  World Space         │
    │                │    ↓                 │
    │                │  Tile Space          │
    │                │                      │
    └────────────────┴──────────────────────┘
```

**Solution:** Two separate coordinate systems with clear boundaries.

### Coordinate Conversion Examples

#### Example 1: Mouse Click at (300, 400)

**Check:** Is it in GUI?
```lua
if x < Viewport.GUI_WIDTH then  -- 300 < 240? NO
    -- Not in GUI
end
```

**Convert to Battlefield:**
```lua
-- Remove GUI offset
local bfScreenX = x - Viewport.GUI_WIDTH  -- 300 - 240 = 60
local bfScreenY = y                       -- 400

-- Convert to world coordinates (camera transform)
local worldX = (bfScreenX - camera.x) / camera.zoom
local worldY = (bfScreenY - camera.y) / camera.zoom

-- Convert to tile coordinates
local tileX = math.floor(worldX / TILE_SIZE) + 1
local tileY = math.floor(worldY / TILE_SIZE) + 1
```

#### Example 2: Mouse Click at (100, 500)

**Check:** Is it in GUI?
```lua
if x < Viewport.GUI_WIDTH then  -- 100 < 240? YES
    -- In GUI, use physical coordinates directly
    guiX = x  -- 100
    guiY = y  -- 500
    -- Check which GUI element was clicked
end
```

---

## Resolution Behavior Examples

### Scenario 1: Base Resolution (960×720)
```
┌──────┬────────────────────┐
│      │                    │
│ GUI  │    Battlefield     │
│ 240  │       720px        │
│  px  │                    │
│      │                    │
└──────┴────────────────────┘
   10        30 tiles wide
  tiles
```

- **GUI:** 240×720 pixels (10×30 tiles)
- **Battlefield:** 720×720 pixels visible
- **Visible tiles:** ~30 tiles wide × 30 tiles tall

### Scenario 2: Full HD (1920×1080)
```
┌──────┬──────────────────────────────────────┐
│      │                                      │
│ GUI  │         Battlefield                  │
│ 240  │          1680px                      │
│  px  │                                      │
│      │                                      │
└──────┴──────────────────────────────────────┘
   10              70 tiles wide
  tiles
```

- **GUI:** 240×1080 pixels (10×45 tiles) - **Wait, GUI height is 720 max!**
- **Correction:** GUI stays 240×720, battlefield is 1680×1080
- **Battlefield:** 1680×1080 pixels visible
- **Visible tiles:** ~70 tiles wide × 45 tiles tall

### Scenario 3: Widescreen (1280×720)
```
┌──────┬────────────────────────────────┐
│      │                                │
│ GUI  │        Battlefield             │
│ 240  │          1040px                │
│  px  │                                │
│      │                                │
└──────┴────────────────────────────────┘
   10           43 tiles wide
  tiles
```

- **GUI:** 240×720 pixels (10×30 tiles)
- **Battlefield:** 1040×720 pixels visible
- **Visible tiles:** ~43 tiles wide × 30 tiles tall

---

## Implementation Complexity Analysis

### Complexity Ratings

| File | Lines Changed | Complexity | Risk Level | Time Est. |
|------|--------------|------------|------------|-----------|
| battlescape.lua | 230 | High | Medium | 3-4h |
| main.lua | 105 | High | High | 2-3h |
| viewport.lua | 100 | Medium | Medium | 1-2h |
| grid.lua | 50 | Medium | Low | 1h |
| camera.lua | 5 | Low | Low | 15min |
| renderer.lua | 10 | Low | Low | 15min |
| conf.lua | 1 | Low | None | 5min |
| tooltip.lua | 5 | Low | None | 15min |
| **TOTAL** | **506** | **High** | **Medium** | **7-11h** |

### Risk Factors

**High Risk Areas:**
1. **Mouse coordinate translation** - Easy to break click detection
   - Mitigation: Extensive testing, debug output
   
2. **Rendering pipeline** - Scissor regions, transformations
   - Mitigation: Incremental changes, visual verification

**Medium Risk Areas:**
3. **Widget positioning** - Grid alignment could break
   - Mitigation: Use grid system API consistently

4. **Camera calculations** - Viewport bounds could be wrong
   - Mitigation: Add debug visualization

**Low Risk Areas:**
5. **Configuration changes** - Easy to revert
6. **Documentation updates** - No code impact

---

## Testing Matrix

### Resolution Test Cases

| Resolution | Aspect | GUI Size | BF Viewport | Expected Tiles | Status |
|------------|--------|----------|-------------|----------------|--------|
| 960×720 | 4:3 | 240×720 | 720×720 | 30×30 | ⏳ |
| 1280×720 | 16:9 | 240×720 | 1040×720 | 43×30 | ⏳ |
| 1920×1080 | 16:9 | 240×720 | 1680×1080 | 70×45 | ⏳ |
| 1024×768 | 4:3 | 240×720 | 784×768 | 32×32 | ⏳ |
| 2560×1440 | 16:9 | 240×720 | 2320×1440 | 96×60 | ⏳ |

### Interaction Test Cases

| Action | Expected Result | Status |
|--------|----------------|--------|
| Click GUI button | Button activates | ⏳ |
| Click battlefield tile | Tile selected | ⏳ |
| Hover over terrain | Info panel shows terrain data | ⏳ |
| Hover over unit | Info panel shows unit data | ⏳ |
| Drag minimap | Camera moves | ⏳ |
| F12 fullscreen | Layout maintained | ⏳ |
| Window resize | GUI fixed, battlefield adjusts | ⏳ |

### Edge Case Test Cases

| Scenario | Expected Behavior | Status |
|----------|------------------|--------|
| Click at x=239 (GUI edge) | GUI handles | ⏳ |
| Click at x=240 (BF edge) | Battlefield handles | ⏳ |
| Mouse at screen edge | No crash/overflow | ⏳ |
| Very small window (800×600) | Min size enforced | ⏳ |
| Very large window (3840×2160) | Viewport scales correctly | ⏳ |

---

## Dependencies and Prerequisites

### Required Before Starting

1. **Backup current code**
   ```bash
   git commit -am "Before resolution system overhaul"
   git branch backup-before-resolution-changes
   ```

2. **Verify current functionality**
   - Run game at 960×720
   - Test all basic interactions
   - Confirm minimap works
   - Verify unit selection

3. **Read documentation**
   - Love2D coordinate systems
   - Scissor regions
   - Graphics transformations

### External Dependencies

- **Love2D 12.0+**: Already required, no changes needed
- **No new libraries**: All changes use existing Love2D APIs

### Internal Dependencies

- **Widget System**: Must remain compatible with fixed positioning
- **Battle Systems**: Must work with new coordinate system
- **Asset System**: No changes required

---

## Rollback Plan

### If Implementation Fails

1. **Revert to backup branch**
   ```bash
   git checkout backup-before-resolution-changes
   ```

2. **Identify specific failure point**
   - Check console for errors
   - Note which file/function failed
   - Review git diff to see what broke

3. **Implement incremental fix**
   - Fix one file at a time
   - Test after each change
   - Use debug output extensively

### Partial Implementation Option

If full implementation proves too complex, implement in stages:

**Stage 1:** Fix immediate issues (buttons, hover info)
- Add action buttons to battlescape
- Implement hover information display
- Keep current resolution system

**Stage 2:** Implement new coordinate system
- Create viewport module
- Update mouse handlers
- Test at 960×720 only

**Stage 3:** Enable resolution changes
- Allow window resize
- Test multiple resolutions
- Fix any issues

---

## Success Metrics

### Quantitative Metrics

1. **All buttons visible**: 9/9 action buttons displayed
2. **Hover information**: 100% of tiles show info when hovered
3. **Resolution support**: 5+ different resolutions tested
4. **Performance**: Maintains 60 FPS at all resolutions
5. **Code quality**: 0 console errors or warnings

### Qualitative Metrics

1. **Usability**: GUI remains readable at all resolutions
2. **Visual quality**: No scaling artifacts or blurriness
3. **Responsiveness**: Mouse clicks feel accurate and immediate
4. **Flexibility**: Easy to add new GUI elements
5. **Maintainability**: Code is clear and well-documented

---

## Conclusion

This comprehensive analysis identifies all code impacted by implementing a dynamic resolution system with fixed GUI. The changes are substantial but well-scoped:

- **11 files** require examination
- **5 files** need significant changes
- **3 files** need minor updates
- **3 files** need no changes

The estimated **7-11 hours** of work will result in:
- ✅ Professional UI that scales properly
- ✅ More tactical information visible
- ✅ Better user experience
- ✅ Support for modern resolutions
- ✅ Foundation for future UI enhancements

The risk is manageable with proper testing and incremental implementation. The detailed task document (TASK-001) provides step-by-step guidance for implementation.

---

**Next Steps:**
1. Review this analysis document
2. Confirm approach with stakeholders
3. Begin Phase 1 implementation (Core Resolution System)
4. Test thoroughly after each phase
5. Update documentation as changes are made

---

**Document Version:** 1.0  
**Last Updated:** October 12, 2025  
**Status:** Complete - Ready for Implementation
