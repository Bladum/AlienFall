═══════════════════════════════════════════════════════════════════════════════
✅ PHASE 6 IMPLEMENTATION CHECKLIST & EXECUTION GUIDE
═══════════════════════════════════════════════════════════════════════════════

**TASK-025 Phase 6: Rendering & UI Systems - Implementation Checklist**

**Ready for**: Next development session
**Estimated Duration**: 25 hours
**Production Target**: 750+ lines
**Test Target**: 15+ tests (100% pass rate)
**Quality Target**: 0 lint errors, Exit Code 0, 60 FPS

---

## PRE-IMPLEMENTATION CHECKLIST

Before starting Phase 6, verify:

- [ ] Phase 5 verification complete
  - [ ] All 4 Phase 5 systems present in `engine/geoscape/systems/`
  - [ ] Campaign integration in `campaign_manager.lua`
  - [ ] All 36 tests passing (22 core + 14 integration)
  - [ ] Exit Code 0 verified
  - [ ] Zero lint errors

- [ ] Development environment ready
  - [ ] Love2D 12+ installed with console enabled
  - [ ] Test runner working (`lovec tests/runners`)
  - [ ] Git repository ready for commits

- [ ] Documentation reviewed
  - [ ] Read PHASE-6-PLANNING-COMPREHENSIVE.md
  - [ ] Read PHASE-6-QUICK-REFERENCE.md
  - [ ] Reviewed TASK-025-STATUS-SUMMARY.md

---

## MODULE 6.1: HEX MAP RENDERER

**File**: `engine/geoscape/rendering/geoscape_renderer.lua`
**Size**: ~120 lines
**Time**: ~8 hours
**Priority**: P0 CRITICAL (foundation for all rendering)

### Implementation Checklist

**Setup** (0.5 hours):
- [ ] Create file with module docstring (Google-style)
- [ ] Add requires (HexMath utility)
- [ ] Create GeoscapeRenderer table with getter

**Initialization** (1.5 hours):
- [ ] Implement `initialize(world, screen_width, screen_height)`
- [ ] Store world reference
- [ ] Initialize camera (camera_x = 40, camera_y = 20)
- [ ] Set zoom to 1.0
- [ ] Set hex_size to 24

**Rendering** (3 hours):
- [ ] Implement `draw()` function
  - [ ] Clear screen with background color
  - [ ] Loop through all hexes (0-79 q, 0-39 r)
  - [ ] Cull off-screen hexes
  - [ ] Draw each hex with biome color
  - [ ] Draw grid overlay if enabled
  - [ ] Draw FPS counter
- [ ] Implement `drawHex(q, r)` function
  - [ ] Get province from world
  - [ ] Determine biome color
  - [ ] Convert hex coords to pixels
  - [ ] Draw hex shape (6-sided polygon)
  - [ ] Draw border

**Camera System** (2 hours):
- [ ] Implement `update(dt)` function
  - [ ] Check arrow keys for pan
  - [ ] Check +/- for zoom
  - [ ] Check SPACE for grid toggle
- [ ] Implement `pan(dx, dy)` function
  - [ ] Update camera position
  - [ ] Clamp to world bounds (0-79 q, 0-39 r)
- [ ] Implement `zoom(factor)` function
  - [ ] Update zoom level
  - [ ] Clamp zoom (0.5x to 4.0x)
- [ ] Implement `toggleGrid()` function
  - [ ] Toggle show_grid boolean
- [ ] Implement `hexToPixel(q, r)` function
  - [ ] Convert hex coords to screen pixels
  - [ ] Apply camera offset
  - [ ] Return (x, y)

**Testing** (1 hour):
- [ ] Test file: `tests/geoscape/test_phase6_rendering_ui.lua`
  - [ ] Test 1: Renderer initialization
  - [ ] Test 2: Camera pan/zoom operations
  - [ ] Test 3: Rendering without errors + <16ms frame time
- [ ] Run tests: `lovec tests/runners geoscape`

### Acceptance Criteria

- [ ] All 80×40 hexes visible on screen
- [ ] Biomes display correct colors (forest=green, mountain=gray, ocean=blue, desert=yellow)
- [ ] Camera pans smoothly with arrow keys
- [ ] Zoom in/out works with +/- (0.5x to 4.0x)
- [ ] FPS counter displays and shows ~60 FPS
- [ ] Grid toggle works with SPACE
- [ ] Performance: <10ms per-frame verified
- [ ] 0 lint errors
- [ ] 3/3 tests passing
- [ ] Exit Code 0

---

## MODULE 6.2: CALENDAR DISPLAY

**File**: `engine/geoscape/ui/calendar_display.lua`
**Size**: ~100 lines
**Time**: ~4 hours
**Priority**: P0 CRITICAL (UI foundation)

### Implementation Checklist

**Setup** (0.5 hours):
- [ ] Create file with module docstring
- [ ] Add requires (Calendar, SeasonSystem)
- [ ] Create CalendarDisplay table

**Initialization** (0.5 hours):
- [ ] Implement `initialize(calendar, season_system)`
- [ ] Store calendar and season_system references
- [ ] Set position (x=10, y=10)
- [ ] Set size (width=200, height=120)

**Display Rendering** (1.5 hours):
- [ ] Implement `draw()` function
  - [ ] Draw background panel (dark blue with alpha)
  - [ ] Draw border (light blue)
  - [ ] Draw title "Calendar"
  - [ ] Draw date (formatted)
  - [ ] Draw day of week
  - [ ] Draw turn counter
  - [ ] Draw season with emoji
  - [ ] Draw seasonal modifier multiplier
- [ ] Implement `formatDate()` helper
  - [ ] Month names array
  - [ ] Format: "Month Day, Year"
- [ ] Implement `getDayOfWeek()` helper
  - [ ] Day names array
  - [ ] Call calendar:getDayOfWeek()
- [ ] Implement `getSeasonColor(season)` helper
  - [ ] Winter: Blue (0.3, 0.5, 1)
  - [ ] Spring: Green (0.3, 1, 0.3)
  - [ ] Summer: Yellow (1, 0.8, 0.2)
  - [ ] Autumn: Orange (1, 0.6, 0.2)

**Integration** (1 hour):
- [ ] Verify Calendar has required methods:
  - [ ] calendar.year, month, day, turn
  - [ ] calendar:getSeason()
  - [ ] calendar:getDayOfWeek()
- [ ] Verify SeasonSystem has:
  - [ ] season_system:getSeasonalModifier()
- [ ] Update method (minimal, auto-update)

**Testing** (0.5 hours):
- [ ] Test file additions in `test_phase6_rendering_ui.lua`
  - [ ] Test 4: Date formatting accuracy (Jan 1 vs Dec 31, leap years)
  - [ ] Test 5: Season indicator displays correct color
  - [ ] Test 6: Turn counter updates on change
- [ ] Run tests

### Acceptance Criteria

- [ ] Date displays correctly (Month Day, Year format)
- [ ] Day of week correct (Zeller's congruence verified)
- [ ] Season indicator shows correct color
- [ ] Seasonal modifier shows correct multiplier (0.7-1.3 range)
- [ ] Panel positioned correctly (top-left)
- [ ] Text colors distinct (different blue/green/yellow/orange shades)
- [ ] Performance: <2ms per-frame
- [ ] 0 lint errors
- [ ] 3/3 tests passing
- [ ] Exit Code 0

---

## MODULE 6.3: MISSION & FACTION PANEL

**File**: `engine/geoscape/ui/mission_faction_panel.lua`
**Size**: ~120 lines
**Time**: ~5 hours
**Priority**: P0 HIGH (critical gameplay UI)

### Implementation Checklist

**Setup** (0.5 hours):
- [ ] Create file with module docstring
- [ ] Add requires (MissionSystem, FactionSystem)
- [ ] Create MissionFactionPanel table

**Initialization** (0.5 hours):
- [ ] Implement `initialize(mission_system, faction_system)`
- [ ] Store system references
- [ ] Set position (x=10, y=400)
- [ ] Set size (width=250, height=200)
- [ ] Initialize scroll_offset = 0
- [ ] Set max_visible_missions = 5

**Mission Display** (2 hours):
- [ ] Implement `draw()` function
  - [ ] Draw background panel
  - [ ] Draw "Active Missions" header
  - [ ] Get active missions from mission_system
  - [ ] Loop through visible missions (respecting scroll)
  - [ ] Draw mission entries (name, threat, turns)
  - [ ] Draw "Alien Factions" header
  - [ ] Get active factions from faction_system
  - [ ] Draw faction entries (name, activity bar)
- [ ] Implement `drawMissionEntry(mission, x, y)`
  - [ ] Mission name (light blue)
  - [ ] Threat level as stars (★ rating, color-coded)
    - [ ] 1-2 stars: Green
    - [ ] 3-4 stars: Yellow
    - [ ] 5 stars: Red
  - [ ] Turns remaining counter
- [ ] Implement `drawFactionEntry(faction, x, y)`
  - [ ] Faction name (light green)
  - [ ] Activity bar (0-10 scale)
    - [ ] Background: gray
    - [ ] Fill: red (filled by percentage)
    - [ ] Border: light
  - [ ] Activity value displayed

**Input** (1 hour):
- [ ] Implement `update(dt)` function
  - [ ] Check PageUp for scroll up
  - [ ] Check PageDown for scroll down
  - [ ] Clamp scroll_offset to valid range
- [ ] Prepare for click handlers (stub for now)

**Testing** (1 hour):
- [ ] Test file additions
  - [ ] Test 7: Mission list rendering (no crashes)
  - [ ] Test 8: Threat color coding (green/yellow/red correct)
  - [ ] Test 9: Faction activity bar rendering
- [ ] Run tests

### Acceptance Criteria

- [ ] Mission list shows up to 5 missions
- [ ] Scrolling works with PageUp/PageDown
- [ ] Threat level shows correct stars (1-5)
- [ ] Threat colors correct (green/yellow/red)
- [ ] Faction activity bars visible
- [ ] Activity scale 0-10 correct
- [ ] Panel positioned correctly (bottom-left)
- [ ] Performance: <2ms per-frame
- [ ] 0 lint errors
- [ ] 3/3 tests passing
- [ ] Exit Code 0

---

## MODULE 6.4: PLAYER INPUT HANDLER

**File**: `engine/geoscape/ui/geoscape_input.lua`
**Size**: ~150 lines
**Time**: ~4 hours
**Priority**: P0 CRITICAL (player interaction)

### Implementation Checklist

**Setup** (0.5 hours):
- [ ] Create file with module docstring
- [ ] Add requires (GeoscapeRenderer, GeoscapeManager)
- [ ] Create GeoscapeInput table

**Initialization** (0.5 hours):
- [ ] Implement `initialize(renderer, geoscape_manager)`
- [ ] Store references
- [ ] Initialize selected_hex = nil
- [ ] Initialize context_menu state

**Mouse Input** (1.5 hours):
- [ ] Implement `handleMousePress(x, y, button)`
  - [ ] Left click (button 1):
    - [ ] Get hex under mouse
    - [ ] Set selected_hex
    - [ ] Print debug message
  - [ ] Right click (button 2):
    - [ ] Get hex under mouse
    - [ ] Show context menu
    - [ ] Store context menu position
- [ ] Implement `getHexUnderMouse(x, y)`
  - [ ] Convert screen coords to grid coords
  - [ ] Use renderer's hex grid and camera
  - [ ] Calculate q, r from screen position
  - [ ] Validate hex bounds (0-79 q, 0-39 r)
  - [ ] Return hex table or nil
- [ ] Implement `drawContextMenu()`
  - [ ] Draw menu items if visible
  - [ ] Items: "View Province", "Send Craft", "View Missions", "Establish Base"
  - [ ] Draw with background and borders

**Keyboard Input** (1.5 hours):
- [ ] Implement `handleKeyPress(key)`
  - [ ] SPACE: advanceTurn()
  - [ ] M: Toggle missions panel
  - [ ] F: Toggle factions panel
  - [ ] C: Toggle calendar
  - [ ] Arrows: Already handled by renderer (camera pan)
  - [ ] +/-: Already handled by renderer (zoom)
- [ ] Implement `hideContextMenu()`
  - [ ] Set visible = false

**Testing** (0.5 hours):
- [ ] Test file additions
  - [ ] Test 10: Mouse click detection and hex selection
  - [ ] Test 11: Keyboard input handling
  - [ ] Test 12: Context menu display
- [ ] Run tests

### Acceptance Criteria

- [ ] Left-click selects hex correctly
- [ ] Right-click shows context menu
- [ ] Context menu positioned at mouse
- [ ] SPACE advances turn (calls advanceTurn())
- [ ] M/F/C keys work (print statements show)
- [ ] Arrow keys work for camera (handled by renderer)
- [ ] +/- keys work for zoom (handled by renderer)
- [ ] Hex calculation accurate
- [ ] Performance: <1ms per-frame
- [ ] 0 lint errors
- [ ] 3/3 tests passing
- [ ] Exit Code 0

---

## MODULE 6.5: REGION DETAIL PANEL

**File**: `engine/geoscape/ui/region_detail_panel.lua`
**Size**: ~100 lines
**Time**: ~3 hours
**Priority**: P1 HIGH (information display)

### Implementation Checklist

**Setup** (0.5 hours):
- [ ] Create file with module docstring
- [ ] Create RegionDetailPanel table

**Initialization** (0.5 hours):
- [ ] Implement `initialize()`
- [ ] Set visible = false
- [ ] Set position (x=1000, y=10)
- [ ] Set size (width=250, height=200)
- [ ] Set auto_close_delay = 5 seconds

**Lifecycle** (1 hour):
- [ ] Implement `show(region_data)`
  - [ ] Store region_data
  - [ ] Set visible = true
  - [ ] Reset visible_timer = 0
- [ ] Implement `update(dt)`
  - [ ] If visible: increment visible_timer
  - [ ] If timer > auto_close_delay: hide panel
- [ ] Implement `mousepressed(x, y, button)`
  - [ ] Check if click inside panel
  - [ ] If yes: reset timer (interaction)

**Display** (1 hour):
- [ ] Implement `draw()`
  - [ ] Check if visible and region_data exists
  - [ ] Draw background panel
  - [ ] Draw border (tan/brown color)
  - [ ] Draw title "Region Detail"
  - [ ] Draw region name
  - [ ] Draw biome type
  - [ ] Draw control status
  - [ ] Draw resources (water, minerals)
  - [ ] Draw close timer ("closes in Ns")

**Testing** (0.5 hours):
- [ ] Test file additions
  - [ ] Test 13: Panel rendering with data display
  - [ ] Test 14: Auto-close timer (panel closes after 5s)
- [ ] Run tests

### Acceptance Criteria

- [ ] Panel visible when shown
- [ ] Data displays correctly (name, biome, control, resources)
- [ ] Auto-closes after 5 seconds
- [ ] Interaction resets timer
- [ ] Panel positioned top-right
- [ ] Performance: <1ms per-frame
- [ ] 0 lint errors
- [ ] 2/2 tests passing (1 test + integration)
- [ ] Exit Code 0

---

## MODULE 6.6: CRAFT & UFO INDICATORS

**File**: `engine/geoscape/ui/craft_indicators.lua`
**Size**: ~80 lines
**Time**: ~1 hour
**Priority**: P1 MEDIUM (visual polish)

### Implementation Checklist

**Setup** (0.25 hours):
- [ ] Create file with module docstring
- [ ] Add requires (world reference)
- [ ] Create CraftIndicators table

**Initialization** (0.25 hours):
- [ ] Implement `initialize(world)`
- [ ] Store world reference
- [ ] Define craft_color (green)
- [ ] Define ufo_color (red)
- [ ] Define base_color (yellow)

**Drawing** (0.5 hours):
- [ ] Implement `draw(renderer)`
  - [ ] Call drawBases()
  - [ ] Call drawCrafts()
  - [ ] Call drawUFOs()
- [ ] Implement `drawCrafts(renderer)`
  - [ ] Get crafts from world
  - [ ] For each craft:
    - [ ] Get pixel position via renderer:hexToPixel()
    - [ ] Draw circle (green, size 8)
    - [ ] Draw health bar below
- [ ] Implement `drawUFOs(renderer)`
  - [ ] Get UFOs from world
  - [ ] For each UFO:
    - [ ] Get pixel position
    - [ ] Draw triangle (red, size 10)
    - [ ] Draw threat label below
- [ ] Implement `drawBases(renderer)`
  - [ ] Get bases from world
  - [ ] For each base:
    - [ ] Get pixel position
    - [ ] Draw square (yellow, size 16)
    - [ ] Draw facility count inside

**Testing** (0.25 hours):
- [ ] Test file additions
  - [ ] Test 15: Craft/UFO/base rendering (no crashes)
  - [ ] Test 16: Icon colors and status display
- [ ] Run tests

### Acceptance Criteria

- [ ] Crafts display as green circles
- [ ] UFOs display as red triangles
- [ ] Bases display as yellow squares
- [ ] Health bars show for crafts
- [ ] Threat labels show for UFOs
- [ ] Facility count shows for bases
- [ ] All icons positioned correctly on map
- [ ] Performance: <2ms per-frame
- [ ] 0 lint errors
- [ ] 2/2 tests passing
- [ ] Exit Code 0

---

## TEST SUITE COMPLETION

**File**: `tests/geoscape/test_phase6_rendering_ui.lua`
**Total**: 15+ tests
**Time**: 1 hour

### Test Suite Structure

```lua
describe("Phase 6 Rendering & UI", function()
  describe("Hex Rendering (3 tests)", function()
    it("initializes renderer correctly")
    it("performs camera pan and zoom")
    it("renders without errors in <16ms")
  end)

  describe("Calendar UI (3 tests)", function()
    it("formats date correctly")
    it("displays season with color")
    it("updates turn counter")
  end)

  describe("Mission Panel (3 tests)", function()
    it("renders mission list")
    it("colors threat levels (green/yellow/red)")
    it("displays faction activity")
  end)

  describe("Input Handling (3 tests)", function()
    it("detects mouse click and hex selection")
    it("handles keyboard input")
    it("displays context menu")
  end)

  describe("Region Details (1 test)", function()
    it("renders panel and auto-closes after 5s")
  end)

  describe("Indicators (2 tests)", function()
    it("renders craft/UFO/base icons")
    it("displays status information")
  end)
end)
```

### Testing Checklist

- [ ] Create test file with module docstring
- [ ] Write 15+ test cases (see structure above)
- [ ] All tests use proper assertions
- [ ] Run full test suite: `lovec tests/runners geoscape`
- [ ] Verify 15+/15+ tests passing
- [ ] Check for lint errors: 0
- [ ] Verify Exit Code 0

---

## INTEGRATION CHECKLIST

After all modules complete:

**Wiring** (1 hour):
- [ ] Wire CalendarDisplay to CampaignManager.calendar
- [ ] Wire MissionFactionPanel to MissionSystem
- [ ] Wire MissionFactionPanel to FactionSystem
- [ ] Wire RegionDetailPanel to hex selection (input handler)
- [ ] Wire CraftIndicators to World system
- [ ] Wire GeoscapeInput to GeoscapeRenderer (camera)
- [ ] Wire GeoscapeInput SPACE to CampaignManager.advanceTurn()

**Verification** (1 hour):
- [ ] Game loads without errors
- [ ] All UI panels visible
- [ ] Turn advancement works
- [ ] Save/load preserves state
- [ ] Performance stable at 60 FPS
- [ ] Exit Code 0
- [ ] Zero lint errors
- [ ] All tests passing

---

## FINAL VERIFICATION

Before marking Phase 6 complete:

**Code Quality**:
- [ ] All 6 modules created (750+ lines total)
- [ ] 0 lint errors across all files
- [ ] All docstrings complete (Google-style)
- [ ] All comments clear and helpful

**Testing**:
- [ ] 15+ tests created
- [ ] 100% test pass rate (15/15 or more)
- [ ] Integration tests verify all systems work together

**Performance**:
- [ ] 60 FPS maintained (<16ms per-frame)
- [ ] Each module <2ms per-frame
- [ ] Camera pan/zoom smooth
- [ ] UI rendering fast

**Functionality**:
- [ ] Hex grid renders correctly
- [ ] Calendar displays accurate date/season
- [ ] Missions and factions display
- [ ] Input controls work
- [ ] Region details show on selection
- [ ] Craft/UFO indicators visible
- [ ] Turn advancement works

**Compilation**:
- [ ] Game runs: `lovec engine`
- [ ] No compile errors
- [ ] Exit Code 0
- [ ] Console debug output shows expected messages

---

## DOCUMENTATION AFTER PHASE 6

After implementation, create:

1. **PHASE-6-IMPLEMENTATION-SUMMARY.md**
   - What was built
   - How it works
   - Integration points

2. **PHASE-6-API-REFERENCE.md**
   - Module APIs
   - Method signatures
   - Usage examples

3. **PHASE-6-TROUBLESHOOTING.md**
   - Common issues
   - Solutions
   - Performance tips

---

## SUCCESS CRITERIA - FINAL

Phase 6 is complete when ALL of the following are true:

- [x] All 6 modules created (750+ lines)
- [x] All 15+ tests passing (100% pass rate)
- [x] 0 lint errors
- [x] Exit Code 0 (game runs)
- [x] 60 FPS maintained
- [x] All UI panels integrated
- [x] Turn advancement works
- [x] Save/load working
- [x] Documentation complete
- [x] Ready for Phase 7

---

## NEXT: PHASE 7 FINAL INTEGRATION

After Phase 6:
- End-to-end playability testing (~20 hours)
- Campaign progression verification
- Performance profiling
- Content validation
- Save/load comprehensive testing
- Final documentation

---

═══════════════════════════════════════════════════════════════════════════════
✅ PHASE 6 CHECKLIST COMPLETE - READY FOR IMPLEMENTATION
═══════════════════════════════════════════════════════════════════════════════
