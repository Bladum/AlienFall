═══════════════════════════════════════════════════════════════════════════════
⚡ PHASE 6 QUICK REFERENCE - EXECUTION GUIDE
═══════════════════════════════════════════════════════════════════════════════

## PHASE 6: RENDERING & UI - QUICK START

**Status**: ✅ READY FOR IMPLEMENTATION
**Total Effort**: ~25 hours
**Modules**: 6 production + 1 test suite
**Quality Target**: 0 lint errors, 100% tests, <16ms/frame, Exit Code 0

---

## MODULE CHECKLIST

### Phase 6.1: Hex Map Renderer
**File**: `engine/geoscape/rendering/geoscape_renderer.lua`
**Size**: ~120 lines
**Priority**: P0 (CRITICAL)
**Dependencies**: HexMath utility, World system
**Tests**: 3 (initialization, camera ops, rendering)

**Quick Checklist**:
- [ ] Initialize hex grid (80×40)
- [ ] Implement camera (pan/zoom)
- [ ] Add biome coloring
- [ ] Implement culling for 60 FPS
- [ ] Add FPS counter
- [ ] Write 3 tests
- [ ] Verify <10ms frame time

**Key Methods**:
```lua
initialize(world, screen_width, screen_height)
update(dt)
draw()
drawHex(q, r)
hexToPixel(q, r)
pan(dx, dy)
zoom(factor)
toggleGrid()
```

---

### Phase 6.2: Calendar Display
**File**: `engine/geoscape/ui/calendar_display.lua`
**Size**: ~100 lines
**Priority**: P0 (CRITICAL)
**Dependencies**: Calendar system, SeasonSystem
**Tests**: 3 (date format, season, turn counter)

**Quick Checklist**:
- [ ] Create display panel (10, 10, 200×120)
- [ ] Format date (Month Day, Year)
- [ ] Get day of week
- [ ] Display turn counter
- [ ] Add season indicator with colors
- [ ] Show seasonal modifier
- [ ] Write 3 tests
- [ ] Wire to CampaignManager

**Season Colors**:
- Winter: Blue (0.3, 0.5, 1)
- Spring: Green (0.3, 1, 0.3)
- Summer: Yellow (1, 0.8, 0.2)
- Autumn: Orange (1, 0.6, 0.2)

---

### Phase 6.3: Mission & Faction Panel
**File**: `engine/geoscape/ui/mission_faction_panel.lua`
**Size**: ~120 lines
**Priority**: P0 (HIGH)
**Dependencies**: MissionSystem, FactionSystem
**Tests**: 3 (mission list, faction display, threat colors)

**Quick Checklist**:
- [ ] Create panel (10, 400, 250×200)
- [ ] Draw mission list (up to 10)
- [ ] Show threat level (★ rating)
- [ ] Show turns remaining
- [ ] Draw faction list
- [ ] Show activity bars
- [ ] Implement scrolling (PageUp/PageDown)
- [ ] Color-code threat (green/yellow/red)
- [ ] Write 3 tests

**Threat Colors**:
- Low (1-2): Green
- Medium (3-4): Yellow
- High (5): Red

---

### Phase 6.4: Player Input Handler
**File**: `engine/geoscape/ui/geoscape_input.lua`
**Size**: ~150 lines
**Priority**: P0 (CRITICAL)
**Dependencies**: GeoscapeRenderer, GeoscapeManager
**Tests**: 3 (mouse input, keyboard input, context menu)

**Quick Checklist**:
- [ ] Implement mouse click detection
- [ ] Convert screen coords → hex coords
- [ ] Left-click: select hex
- [ ] Right-click: show context menu
- [ ] Arrow keys: already in renderer (pan)
- [ ] +/-: already in renderer (zoom)
- [ ] SPACE: advance turn
- [ ] M/F/C: toggle UI panels
- [ ] Write 3 tests

**Key Methods**:
```lua
handleMousePress(x, y, button)
handleKeyPress(key)
getHexUnderMouse(x, y)
drawContextMenu()
hideContextMenu()
```

---

### Phase 6.5: Region Detail Panel
**File**: `engine/geoscape/ui/region_detail_panel.lua`
**Size**: ~100 lines
**Priority**: P1 (HIGH)
**Dependencies**: RegionSystem
**Tests**: 1 (panel rendering and auto-close)

**Quick Checklist**:
- [ ] Create panel (1000, 10, 250×200)
- [ ] Show region name
- [ ] Show biome type
- [ ] Show control status
- [ ] Show resources (water, minerals)
- [ ] Implement auto-close (5 seconds)
- [ ] Reset timer on interaction
- [ ] Make draggable
- [ ] Write 1 test

---

### Phase 6.6: Craft & UFO Indicators
**File**: `engine/geoscape/ui/craft_indicators.lua`
**Size**: ~80 lines
**Priority**: P1 (MEDIUM)
**Dependencies**: World, AlienDirector
**Tests**: 2 (craft/UFO/base rendering)

**Quick Checklist**:
- [ ] Draw craft icons (green circles)
- [ ] Add craft health bars
- [ ] Draw UFO icons (red triangles)
- [ ] Add UFO threat labels
- [ ] Draw base icons (yellow squares)
- [ ] Show facility count
- [ ] Integrate with renderer
- [ ] Write 2 tests

---

## TEST SUITE STRUCTURE

**File**: `tests/geoscape/test_phase6_rendering_ui.lua`

```
Test Suite 1: Hex Rendering (3 tests)
  - Renderer initialization
  - Camera controls
  - Rendering performance

Test Suite 2: Calendar UI (3 tests)
  - Date formatting
  - Season display
  - Turn counter update

Test Suite 3: Mission Panel (3 tests)
  - Mission list rendering
  - Threat color coding
  - Faction display

Test Suite 4: Input Handling (3 tests)
  - Mouse click detection
  - Keyboard input
  - Context menu

Test Suite 5: Region Details (1 test)
  - Panel rendering and auto-close

Test Suite 6: Indicators (2 tests)
  - Craft/UFO/base rendering
  - Status display

TOTAL: 15+ tests
```

---

## INTEGRATION CHECKLIST

### Campaign Integration
- [ ] Wire CalendarDisplay to CampaignManager.calendar
- [ ] Wire MissionFactionPanel to MissionSystem
- [ ] Wire MissionFactionPanel to FactionSystem
- [ ] Wire RegionDetailPanel to hex selection
- [ ] Wire CraftIndicators to World/AlienDirector

### Input Integration
- [ ] Wire GeoscapeInput to GeoscapeRenderer (camera)
- [ ] Wire GeoscapeInput.SPACE to CampaignManager.advanceTurn()
- [ ] Wire mouse click to RegionDetailPanel.show()

### Rendering Integration
- [ ] Call GeoscapeRenderer.update() in love.update()
- [ ] Call GeoscapeRenderer.draw() first in love.draw()
- [ ] Call all UI panels' draw() methods
- [ ] Call CraftIndicators.draw() in renderer

---

## PERFORMANCE TARGETS

| Component | Target | Key Optimization |
|-----------|--------|-----------------|
| Hex rendering | <10ms | Culling off-screen hexes |
| UI drawing | <4ms | Simple rectangle/text |
| Input handling | <1ms | Direct calculation |
| **Total per-frame** | **<16ms** | Budget maintained |
| **Frame rate** | **60 FPS** | Verified |

---

## DEPENDENCY MAP

```
CampaignManager
  ├─ Calendar (Phase 5)
  ├─ SeasonSystem (Phase 5)
  ├─ EventScheduler (Phase 5)
  ├─ TurnAdvancer (Phase 5)
  ├─ MissionSystem
  ├─ FactionSystem
  ├─ AlienDirector
  └─ World

GeoscapeRenderer (6.1)
  ├─ World
  └─ HexMath

CalendarDisplay (6.2) ← Calendar + SeasonSystem
MissionFactionPanel (6.3) ← MissionSystem + FactionSystem
GeoscapeInput (6.4) ← GeoscapeRenderer + CampaignManager
RegionDetailPanel (6.5) ← RegionSystem
CraftIndicators (6.6) ← World + AlienDirector
```

---

## CODING STANDARDS REMINDER

✅ **Required for all modules**:
- Google-style docstrings (---)
- Parameter documentation
- Return value documentation
- Module export at end

✅ **Required for tests**:
- Comprehensive test cases
- Edge case coverage
- Integration verification
- Performance assertions

✅ **Required for integration**:
- Wire Phase 5 systems
- Verify campaign functionality
- Test save/load
- Run game exit code 0

---

## EXECUTION ORDER

**Recommended Sequential Execution** (to minimize blocking):

1. **Phase 6.1** (Hex Renderer) - 8 hours
   - Foundation for all rendering
   - Needed for other UI to display

2. **Phase 6.4** (Input Handler) - 4 hours
   - Can work in parallel with 6.2/6.3
   - Needed for turn advancement

3. **Phase 6.2** (Calendar UI) - 4 hours
   - Standalone, no render dependencies
   - Can work in parallel

4. **Phase 6.3** (Mission Panel) - 5 hours
   - Standalone, no render dependencies
   - Can work in parallel with 6.2

5. **Phase 6.5** (Region Details) - 3 hours
   - Depends on 6.1 (hex selection)
   - Can work after 6.1 complete

6. **Phase 6.6** (Indicators) - 1 hour
   - Depends on 6.1
   - Quick final polish

7. **Testing & Integration** - 2 hours
   - Write comprehensive test suite
   - Verify all integrations
   - Performance profiling

---

## QUICK TROUBLESHOOTING

| Issue | Cause | Solution |
|-------|-------|----------|
| <16 FPS | Hex culling missing | Add visibility check in drawHex() |
| Hex misalignment | Coordinate conversion wrong | Verify hexToPixel() math |
| Input not working | Event handler not wired | Check love.mousepressed() binding |
| Panels overlapping | Z-order not managed | Draw in correct order |
| Memory leak | Effects/objects not cleaned | Add cleanup in update() |

---

## VERIFICATION CHECKLIST (Before Completion)

- [ ] All 6 modules created (750+ lines total)
- [ ] Test suite comprehensive (15+ tests)
- [ ] 0 lint errors (run linter on all files)
- [ ] 100% tests passing
- [ ] Exit Code 0 (game runs without crash)
- [ ] 60 FPS maintained (<16ms per-frame)
- [ ] All UI panels visible and interactive
- [ ] Turn advancement works
- [ ] Save/load preserves state
- [ ] Documentation complete

---

## AFTER PHASE 6: PHASE 7

**Phase 7: Final Integration & Testing**
- End-to-end playability testing
- Campaign progression verification
- Performance profiling
- Content validation
- Save/load comprehensive testing
- Documentation finalization

**Estimated Time**: 20 hours
**Estimated Lines**: 200+ production + tests

---

═══════════════════════════════════════════════════════════════════════════════
✅ PHASE 6 READY - BEGIN IMPLEMENTATION
═══════════════════════════════════════════════════════════════════════════════
