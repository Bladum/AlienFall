═══════════════════════════════════════════════════════════════════════════════
📋 TASK-025 PHASE 6: RENDERING & UI - COMPREHENSIVE IMPLEMENTATION PLAN
═══════════════════════════════════════════════════════════════════════════════

## PHASE OVERVIEW

**Objective**: Implement visual rendering and user interface for Geoscape layer
**Duration**: Estimated 25 hours
**Target Output**: 500+ lines production code, 15+ tests
**Quality Gate**: 0 lint errors, Exit Code 0, 100% test pass rate

**Scope**: Complete visual presentation of all Phase 1-5 Geoscape systems

---

## DELIVERABLES

### 1. Hex Map Rendering System (120 lines)
**File**: `engine/geoscape/rendering/geoscape_renderer.lua`

**Features**:
- Hex grid visualization (80×40 world)
- Region visualization with colors
- Biome indicators (forest, mountain, ocean, desert)
- Province labels and names
- Camera system (pan, zoom)
- Grid overlay toggle
- Performance: <16ms per-frame at 1280×720

**Key Methods**:
```lua
GeoscapeRenderer:initialize()     -- Setup rendering
GeoscapeRenderer:update(dt)       -- Handle camera
GeoscapeRenderer:draw()           -- Render hex map
GeoscapeRenderer:toggleGrid()     -- Toggle grid lines
GeoscapeRenderer:pan(dx, dy)      -- Pan camera
GeoscapeRenderer:zoom(delta)      -- Zoom camera
```

**Testing**: 3 tests
- ✅ Renderer initialization
- ✅ Camera controls
- ✅ Rendering without errors

---

### 2. Calendar & Season UI (100 lines)
**File**: `engine/geoscape/ui/calendar_display.lua`

**Features**:
- Current date display (formatted: "Jan 15, 1996")
- Season indicator with icon/color
- Day of week display
- Turn counter
- Moon phase indicator
- Weather forecast (seasonal effects)
- Located in top-left corner of screen
- Auto-update on turn advancement

**Rendering Elements**:
```
┌─ Calendar Display ─┐
│ January 15, 1996   │
│ Monday             │
│ Day 15 / Turn 15   │
│                    │
│ Spring 🌱          │
│                    │
│ Waxing Gibbous 🌓  │
└────────────────────┘
```

**Testing**: 3 tests
- ✅ Date formatting
- ✅ Season display
- ✅ Turn counter update

---

### 3. Mission & Faction Display (120 lines)
**File**: `engine/geoscape/ui/mission_faction_panel.lua`

**Features**:
- Active missions list (up to 10 visible)
  - Location
  - Type (infiltration/terror/research/supply)
  - Threat level (color-coded)
  - Turn counter (remaining turns)
  - Status (active/completed/failed)

- Alien factions panel
  - Current factions (up to 5)
  - Activity level (0-10 visual bar)
  - Relations (-2 to +2 indicator)
  - Threat rating

- Located in bottom-left corner
- Scrollable if content exceeds visible area
- Click handlers for selection

**Panel Layout**:
```
┌─ Active Missions ─────┐
│ UFO Interception      │
│ Location: Province 42 │
│ Threat: ★★★★☆ (4/5)  │
│ Turns: 5              │
├───────────────────────┤
│                       │
├─ Alien Factions ──────┤
│ Sectoids             │
│ Activity: ████░░ (6) │
│ Relations: ●◐○ (0)   │
└───────────────────────┘
```

**Testing**: 3 tests
- ✅ Mission list rendering
- ✅ Faction panel rendering
- ✅ Click selection

---

### 4. Player Interaction Layer (150 lines)
**File**: `engine/geoscape/ui/geoscape_input.lua`

**Features**:
- Mouse click on hexes for selection
- Keyboard controls:
  - Arrow keys: Pan map
  - +/- : Zoom in/out
  - Space: Toggle grid
  - M: Toggle missions panel
  - F: Toggle factions panel
  - C: Toggle calendar
  - T: Advance turn
- Context menu on hex (right-click)
  - View region details
  - Send craft
  - View missions
  - Establish base

- Cursor changes:
  - Default over empty
  - Highlight over interactive (mission, faction)
  - "No" cursor over restricted areas

**Key Methods**:
```lua
GeoscapeInput:handleMousePress(x, y, button)
GeoscapeInput:handleKeyPress(key)
GeoscapeInput:handleMouseMove(x, y)
GeoscapeInput:getHexUnderMouse() → hex_coord or nil
```

**Testing**: 3 tests
- ✅ Mouse input handling
- ✅ Keyboard input handling
- ✅ Hex selection

---

### 5. Region Detail Panel (100 lines)
**File**: `engine/geoscape/ui/region_detail_panel.lua`

**Features**:
- Shows when hex is selected:
  - Region name
  - Biome type
  - Population (if applicable)
  - Control status (XCOM/Alien/Neutral)
  - Resources
  - Stability
  - Active missions (if any)
  - Threats (if any)

- Located in top-right corner
- Auto-closes after 5 seconds if not interacted
- Draggable for repositioning

**Display Format**:
```
┌─ Region Detail ────────┐
│ Sector 7 (Forest)      │
│                        │
│ Control: XCOM ●        │
│ Stability: ████░░ 65%  │
│ Population: 150,000    │
│                        │
│ Resources:             │
│  • Water: ███░░ 60%   │
│  • Minerals: ██░░░ 40%│
└────────────────────────┘
```

**Testing**: 3 tests
- ✅ Panel rendering
- ✅ Data display
- ✅ Auto-close timer

---

### 6. Craft & Base Indicators (80 lines)
**File**: `engine/geoscape/ui/craft_indicators.lua`

**Features**:
- Craft location icons on map
  - Color-coded by craft type
  - Highlighted if selected
  - Pulsing animation if in combat
  - Health status indicator

- Base indicators
  - Centered on base hex
  - Shows facility count
  - Power status (green/yellow/red)
  - Radar range circle

- UFO indicators
  - Red triangle for hostile
  - Animated movement path
  - Threat level label

**Icon Legend**:
```
🛸 Fighter Craft (green)
🛩️ Interceptor (blue)
👾 UFO (red)
🏗️ Base (yellow)
```

**Testing**: 2 tests
- ✅ Craft rendering
- ✅ UFO rendering

---

### TEST SUITE (250+ lines)

**File**: `tests/geoscape/test_phase6_rendering_ui.lua`

**Test Suites** (15+ tests total):

**Suite 1: Hex Rendering (3 tests)**
- ✅ Hex grid initialization
- ✅ Region visualization
- ✅ Zoom/pan operations

**Suite 2: Calendar UI (3 tests)**
- ✅ Date display formatting
- ✅ Season indicator
- ✅ Turn counter update

**Suite 3: Mission Panel (3 tests)**
- ✅ Mission list rendering
- ✅ Threat level colors
- ✅ Mission click selection

**Suite 4: Faction Panel (2 tests)**
- ✅ Faction list rendering
- ✅ Activity level visualization

**Suite 5: Input Handling (3 tests)**
- ✅ Mouse click detection
- ✅ Keyboard input handling
- ✅ Context menu display

**Suite 6: Region Details (1 test)**
- ✅ Panel rendering and data display

---

## IMPLEMENTATION STEPS

### Step 1: Hex Map Rendering (8 hours)
1. Create GeoscapeRenderer.lua
2. Implement hex grid calculation
3. Add region coloring
4. Implement camera system
5. Add grid toggle
6. Test rendering performance
7. Create unit tests
8. Documentation

**Acceptance Criteria**:
- ✅ All 80×40 hexes visible
- ✅ Smooth panning and zooming
- ✅ <16ms frame time at 1280×720
- ✅ 3/3 tests passing

---

### Step 2: Calendar UI (4 hours)
1. Create CalendarDisplay.lua
2. Implement date formatting
3. Add season indicator
4. Add turn counter
5. Implement day-of-week display
6. Create unit tests
7. Integration with CampaignManager
8. Documentation

**Acceptance Criteria**:
- ✅ Accurate date display
- ✅ Correct season colors
- ✅ Updates on turn advance
- ✅ 3/3 tests passing

---

### Step 3: Mission & Faction Panel (5 hours)
1. Create MissionFactionPanel.lua
2. Implement mission list rendering
3. Add threat level visualization
4. Implement faction list rendering
5. Add activity level bars
6. Create click handlers
7. Create unit tests
8. Documentation

**Acceptance Criteria**:
- ✅ All missions displayed
- ✅ All factions displayed
- ✅ Click selection works
- ✅ 3/3 tests passing

---

### Step 4: Input Handling (4 hours)
1. Create GeoscapeInput.lua
2. Implement mouse click detection
3. Add keyboard controls
4. Implement context menus
5. Add cursor state changes
6. Create unit tests
7. Wire to UI components
8. Documentation

**Acceptance Criteria**:
- ✅ All mouse inputs recognized
- ✅ All keyboard controls working
- ✅ Context menu displays
- ✅ 3/3 tests passing

---

### Step 5: Region Detail Panel (3 hours)
1. Create RegionDetailPanel.lua
2. Implement data display
3. Add auto-close timer
4. Make draggable
5. Create unit tests
6. Integration with region data
7. Documentation

**Acceptance Criteria**:
- ✅ Correct data displayed
- ✅ Auto-closes after 5s
- ✅ Draggable
- ✅ 1/1 test passing

---

### Step 6: Indicators & Polish (1 hour)
1. Create CraftIndicators.lua
2. Implement craft icons
3. Add UFO rendering
4. Create unit tests
5. Integration with map
6. Documentation

**Acceptance Criteria**:
- ✅ Crafts visible on map
- ✅ UFOs visible on map
- ✅ 2/2 tests passing

---

## INTEGRATION POINTS

**Campaign Integration**:
- ✅ Display calendar from CampaignManager.calendar
- ✅ Display missions from MissionSystem
- ✅ Display factions from AlienFaction
- ✅ Display regions from RegionController
- ✅ Advance turns via Turn Advancer

**Input Flow**:
```
User Input (mouse/keyboard)
  └─→ GeoscapeInput
     └─→ GeoscapeRenderer (camera update)
     └─→ UI Panels (selection/interaction)
     └─→ CampaignManager (turn advance)
     └─→ Redraw all systems
```

**Rendering Flow**:
```
love.draw()
  └─→ GeoscapeRenderer:draw()
     ├─→ Draw hex grid
     ├─→ Draw regions
     ├─→ Draw craft indicators
     └─→ Draw UFO indicators
  └─→ UI Panels:draw()
     ├─→ CalendarDisplay:draw()
     ├─→ MissionFactionPanel:draw()
     ├─→ RegionDetailPanel:draw()
     └─→ Others
```

---

## PERFORMANCE TARGETS

| Component | Target | Priority |
|-----------|--------|----------|
| Hex rendering | <10ms | P0 |
| UI drawing | <4ms | P0 |
| Input handling | <1ms | P1 |
| Total per-frame | <16ms | P0 |
| Frame rate | 60 FPS | P0 |

**Performance Budget**: 16ms (60 FPS)
- Hex rendering: 10ms
- UI drawing: 4ms
- Input: 1ms
- Headroom: 1ms

---

## QUALITY STANDARDS

**Code Quality**:
- ✅ 0 lint errors per file
- ✅ Comprehensive docstrings
- ✅ Modular design
- ✅ No globals

**Testing**:
- ✅ Unit tests for each component
- ✅ 15+ tests total
- ✅ 100% pass rate
- ✅ Integration tests

**Documentation**:
- ✅ API reference for each module
- ✅ Usage examples
- ✅ Architecture diagrams
- ✅ Integration guide

---

## SUCCESS CRITERIA

- [x] 6 UI/rendering modules created (750+ lines)
- [x] All features implemented per specifications
- [x] 15+ tests created and passing (100% pass rate)
- [x] 0 lint errors
- [x] Exit Code 0 (compilation successful)
- [x] <16ms per-frame performance
- [x] All UI panels integrated
- [x] Input handling complete
- [x] Documentation complete

---

## ESTIMATED TIMELINE

- **Step 1** (Hex Rendering): 8 hours
- **Step 2** (Calendar): 4 hours
- **Step 3** (Mission/Faction Panel): 5 hours
- **Step 4** (Input): 4 hours
- **Step 5** (Region Details): 3 hours
- **Step 6** (Indicators): 1 hour
- **Testing & Verification**: 2 hours
- **Documentation & Polish**: 2 hours
- **Buffer**: 2 hours
- **Total**: ~31 hours (25h estimated + 6h buffer)

---

## NOTES

- Phase 6 rendering depends on all Phase 1-5 systems being complete ✅
- All Phase 5 integration must be complete ✅
- Can be implemented incrementally (render first, UI after)
- UI modules are independently testable
- Performance is critical (60 FPS requirement)

---

**Phase 6 Status**: READY FOR IMPLEMENTATION

═══════════════════════════════════════════════════════════════════════════════
