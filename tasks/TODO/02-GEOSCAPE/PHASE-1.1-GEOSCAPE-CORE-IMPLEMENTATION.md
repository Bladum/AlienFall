# PHASE 1.1: Geoscape Core Implementation
## Strategic Layer Foundation - Week 1

**Phase:** 1 (Foundation Systems)  
**Week:** 1  
**Priority:** CRITICAL  
**Status:** TODO  
**Estimated Time:** 80 hours  
**Created:** October 15, 2025  
**Dependencies:** None (foundational)  
**Blocks:** Phase 1.2, Phase 1.3 (mission generation requires world map)

---

## 🎯 Overview

Implement the core strategic layer - the 80×40 hex world map representing Earth divided into provinces with biome classification. This creates the foundation for all subsequent strategic layer systems (missions, crafts, time progression).

**Core Deliverable:** A playable hex world where the player can:
- View the 80×40 hex grid (representing ~500km/hex = 40,000 km coverage)
- See province boundaries and biome classifications (colorized)
- Navigate with keyboard/mouse
- Deploy crafts to provinces
- Advance calendar by 1 day per turn
- See active craft positions and status

### Why This First?
- No other game system can function without the world map and calendar
- Enables all strategic decision-making
- Provides the "hub" interface for other systems
- Required for mission spawning system (Phase 1.3)
- Establishes turn-based time progression

---

## 📋 Technical Requirements

### 1. Hex World Map (40 hours)

#### 1.1 Hex Grid System
**Objective:** Render 80×40 hex grid (3,200 tiles total)

**Implementation:**
- Use existing HexRenderer API (docs/rendering/HEX_RENDERING_GUIDE.md)
- Coordinate system: Flat-top hexagons, odd-column offset
- Viewport: Center on player's starting region
- Camera: Pan/zoom for world overview

**Files:**
- Create: `engine/geoscape/world_map.lua`
- Create: `engine/geoscape/world_renderer.lua`
- Reference: `engine/core/hex_renderer.lua` (study existing code)
- Create: `mods/core/data/world_map.toml` (hex grid definitions)

**Tests:**
```lua
-- Test hex coordinate validation
assert(hex:is_valid(), "Hex should be valid")
assert(hex.q >= 0 and hex.q < 80, "Q coordinate should be in range")
assert(hex.r >= 0 and hex.r < 40, "R coordinate should be in range")

-- Test rendering (visually verify in Love2D console output)
-- Test camera pan/zoom
```

#### 1.2 Province System
**Objective:** Divide world into ~30-50 provinces with biome classification

**Provinces should cover:**
- North America, South America, Europe, Africa, Asia, Australia, Oceania
- Arctic/Polar regions
- Ocean coverage (neutral zones)

**Implementation:**
- Define provinces as sets of hexes (not individual tiles)
- Classify each province with biome: temperate, desert, tundra, jungle, ocean, mountain, urban
- Store adjacency relationships (for territorial mechanics)
- Create province graph for pathfinding

**Files:**
- Create: `engine/geoscape/province_system.lua`
- Create: `mods/core/data/provinces.toml` (province definitions with hex lists)
- Create: `mods/core/data/biomes.toml` (biome properties: color, terrain, units, etc.)

**Data Structure (TOML example):**
```toml
[province_north_america]
name = "North America"
hex_list = [  # List of hex coordinates
    {q=5, r=3}, {q=5, r=4}, {q=6, r=3}, ...
]
biome = "temperate"
connections = ["province_central_america", "province_arctic"]
population = 500000000
government = "democratic"
starting_relations = 0.5

[province_arctic]
name = "Arctic"
hex_list = [{q=5, r=0}, {q=6, r=0}, ...]
biome = "tundra"
population = 5000000
```

**Tests:**
- Verify province coverage (all hexes assigned exactly once, except ocean)
- Test province lookup from hex coordinate
- Test province adjacency relationships
- Verify biome application

#### 1.3 Province Visualization
**Objective:** Color-code provinces by biome on the map

**Visual Design:**
- Biome colors:
  - Temperate: Medium green
  - Desert: Sandy yellow
  - Tundra: Light blue
  - Jungle: Dark green
  - Ocean: Deep blue
  - Mountain: Gray
  - Urban: Concrete gray

**Features:**
- Hover over province: Show name, biome, population, relations
- Click province: Show detailed info panel
- Selected province: Highlight with brighter color

**Files:**
- Modify: `engine/geoscape/world_renderer.lua` (add province coloring)
- Create: `engine/ui/province_panel.lua` (info display)

**Tests:**
- Verify colors render correctly
- Test info panel display
- Test province selection/highlighting

---

### 2. Calendar System (15 hours)

#### 2.1 Turn Management
**Objective:** Implement turn counter with game time tracking

**Requirements:**
- 1 turn = 1 day (in-game)
- Track: Year, Month, Day, Season
- Starting date: 1996-01-01 (campaign begins)
- Calendar range: 1996-2004 (8 years = 2,920 days)

**Implementation:**
- Create: `engine/core/calendar.lua`
- Integrate with state manager (existing `engine/core/state_manager.lua`)
- Support for pausing/resuming time
- Event triggers on specific dates

**Data:**
```lua
-- Calendar state in save file
calendar = {
    year = 1996,
    month = 1,          -- 1-12
    day = 1,            -- 1-31
    season = "winter",  -- winter, spring, summer, fall
    turn = 0,           -- Total turns elapsed
    paused = false,     -- Can pause during planning
}

-- Date advancement
function calendar:advance_day()
    self.day = self.day + 1
    if self.day > 31 then  -- Simplified: ignore month lengths
        self.day = 1
        self.month = self.month + 1
        self:update_season()
    end
    if self.month > 12 then
        self.month = 1
        self.year = self.year + 1
    end
    self.turn = self.turn + 1
end
```

**Tests:**
- Test date advancement (day, month, year wrapping)
- Test season calculation
- Test turn counter
- Test pausing/resuming

#### 2.2 UI Display
**Objective:** Show calendar in strategic layer UI

**Display:**
- Top-left corner: "1996-01-15 (Winter) - Day 14"
- Progress bar: Campaign progress (0-2920 days)
- Button: "Next Turn" (advance by 1 day)
- Button: "Speed controls" (advance by 1 week, 1 month, etc.)

**Files:**
- Modify: `engine/ui/geoscape_ui.lua` (add calendar widget)
- Reference: `engine/ui/` (existing UI framework)

**Tests:**
- Verify calendar display updates
- Test button interactions
- Test multiple turn advancement

---

### 3. Craft Positioning & Movement (20 hours)

#### 3.1 Craft System Integration
**Objective:** Track craft positions on the world map

**Features:**
- Player has 1-3 starting crafts (configurable)
- Each craft tracks current position (province or hex)
- Each craft has status: idle, traveling, in_combat, damaged
- Display crafts as distinct icons on map

**Implementation:**
- Create: `engine/geoscape/craft_position_manager.lua`
- Modify: `engine/core/crafts.lua` (add position tracking)
- Create: `mods/core/data/starting_crafts.toml` (initial craft configuration)

**Data:**
```lua
craft_positions = {
    [craft_id] = {
        current_hex = {q=10, r=10},       -- Current position
        destination_hex = {q=15, r=12},   -- Target (if traveling)
        status = "idle",                  -- idle, traveling, in_combat
        travel_progress = 0.0,            -- 0.0 = start, 1.0 = arrived
        arrival_turn = nil,               -- Turn when craft arrives
    }
}
```

**Tests:**
- Verify craft starting positions
- Test position lookup
- Test status transitions

#### 3.2 Hex Pathfinding (15 hours)
**Objective:** Calculate travel routes between hexes

**Requirements:**
- Craft travels from current hex to destination
- Path follows connected hexes
- Travel takes time (based on distance and craft speed)
- Calculate shortest path using A* or Dijkstra

**Implementation:**
- Create: `engine/geoscape/hex_pathfinding.lua`
- Reference: `docs/rendering/HEX_RENDERING_GUIDE.md` (neighbor calculation)
- Use existing hex coordinate system

**Algorithm:**
```lua
function hex_pathfinding:find_path(start_hex, end_hex, max_distance)
    -- Returns: {hex1, hex2, hex3, ...} or nil if unreachable
    -- Uses A* with hex distance heuristic
    -- max_distance: prevent impossible paths
end

function hex_pathfinding:get_neighbors(hex)
    -- Returns 6 neighbors (N, NE, SE, S, SW, NW)
    -- Wraps around map edges if needed
end

function hex_pathfinding:hex_distance(hex1, hex2)
    -- Manhattan distance in hex coordinates
    return (abs(hex1.q - hex2.q) + abs(hex1.r - hex2.r) + 
            abs(-hex1.q - hex1.r + hex2.q + hex2.r)) / 2
end
```

**Tests:**
- Test neighbor calculation (6 neighbors per hex)
- Test pathfinding: direct line
- Test pathfinding: around obstacles (ocean)
- Test pathfinding: wrapped edges
- Test distance calculation

#### 3.3 Craft Travel
**Objective:** Implement craft movement along calculated paths

**Features:**
- Player selects destination province
- System calculates hex path
- Craft travels at configurable speed (e.g., 3 hexes/turn)
- Arrives at destination after N turns
- Display travel progress on map

**Implementation:**
- Modify: `engine/geoscape/craft_position_manager.lua` (add travel logic)
- Create: `mods/core/data/craft_speeds.toml` (craft movement speed)

**Logic:**
```lua
function craft_manager:start_travel(craft_id, destination_hex)
    local craft = self.craft_positions[craft_id]
    local path = self.pathfinding:find_path(craft.current_hex, destination_hex)
    if not path then return false end  -- Unreachable
    
    craft.destination_hex = destination_hex
    craft.path = path
    craft.path_index = 1
    craft.status = "traveling"
    craft.arrival_turn = current_turn + #path / craft_speed
    return true
end

function craft_manager:advance_travel()
    for craft_id, craft in pairs(self.craft_positions) do
        if craft.status == "traveling" then
            craft.travel_progress = craft.travel_progress + 0.25  -- 4 updates/turn
            if craft.travel_progress >= 1.0 then
                -- Move to next hex in path
                craft.path_index = craft.path_index + 1
                craft.travel_progress = 0.0
                if craft.path_index > #craft.path then
                    -- Arrived!
                    craft.status = "idle"
                    craft.current_hex = craft.destination_hex
                end
            end
        end
    end
end
```

**Tests:**
- Test travel initiation
- Test progress along path
- Test arrival at destination
- Test speed calculation

---

### 4. Strategic UI (10 hours)

#### 4.1 World View Interface
**Objective:** Create main geoscape screen layout

**Layout:**
```
┌─────────────────────────────────────────┐
│ Calendar: 1996-01-15 (Winter) - Day 14  │
├─────────────────────────────────────────┤
│                                         │
│          HEX WORLD MAP (80×40)          │
│          [Colored by province/biome]    │
│          [Craft icons overlay]          │
│          [Province info on hover]       │
│                                         │
├─────────────────────────────────────────┤
│ [Next Turn] [Info] | Craft 1: Idle @ .. │
└─────────────────────────────────────────┘
```

**Features:**
- World map centered in viewport
- Craft positions displayed as distinct icons (different for each craft type)
- Province hover shows name, biome, population, relations
- Province click shows detailed info panel
- Calendar display (top)
- Control panel (bottom): Next Turn button, craft status list

**Files:**
- Create: `engine/geoscape/geoscape_scene.lua` (scene definition)
- Create: `engine/ui/geoscape_ui.lua` (UI layout and controls)
- Create: `engine/ui/geoscape_viewport.lua` (viewport management)

**Tests:**
- Verify layout on 960×720 resolution
- Test UI responsiveness
- Test element positioning

#### 4.2 Input Handling
**Objective:** Keyboard/mouse controls for strategic layer

**Controls:**
- Arrow keys / WASD: Pan map
- Mouse scroll: Zoom in/out
- Click province: Show info
- Click craft: Select craft
- Right-click destination: Deploy craft (or use UI panel)
- Space / "Next Turn": Advance calendar

**Files:**
- Modify: `engine/geoscape/geoscape_scene.lua` (input handling)
- Reference: `engine/main.lua` (input event structure)

**Implementation:**
```lua
function scene:on_key_pressed(key)
    if key == "space" then
        self:advance_turn()
    elseif key == "up" or key == "w" then
        self:pan_camera(0, -CAMERA_SPEED)
    -- ... more keys
    end
end

function scene:on_mouse_pressed(x, y, button)
    if button == 1 then  -- Left click
        local hex = self:screen_to_hex(x, y)
        self:on_hex_clicked(hex)
    elseif button == 2 then  -- Right click
        local hex = self:screen_to_hex(x, y)
        self:on_hex_right_clicked(hex)
    end
end
```

**Tests:**
- Test all keyboard inputs
- Test mouse click detection
- Test camera panning and zooming

---

## 🔄 Integration Points

### With Existing Systems

**State Manager:** `engine/core/state_manager.lua`
- Register geoscape state
- Handle scene transitions (geoscape ↔ battlescape ↔ basescape)

**Calendar Integration:** 
- Existing time system or create new one
- Sync with turn manager

**Craft System:** `engine/core/crafts.lua`
- Existing craft definitions
- Add position and status tracking

**HexRenderer:** `engine/core/hex_renderer.lua`
- Leverage for all hex rendering
- Verify coordinate system compatibility

---

## 📊 Testing Strategy

### Unit Tests
```lua
-- tests/geoscape/test_hex_world.lua
local world = HexWorld.new(80, 40)

function test_hex_validation()
    assert(world:is_valid_hex({q=0, r=0}), "Valid hex")
    assert(not world:is_valid_hex({q=-1, r=0}), "Invalid hex (negative)")
    assert(not world:is_valid_hex({q=80, r=0}), "Invalid hex (out of bounds)")
end

function test_province_coverage()
    local covered_hexes = {}
    for prov_id, province in pairs(world.provinces) do
        for hex in pairs(province.hex_list) do
            assert(not covered_hexes[hex_key(hex)], "Hex covered twice")
            covered_hexes[hex_key(hex)] = true
        end
    end
end

-- tests/geoscape/test_pathfinding.lua
function test_pathfinding_direct()
    local path = pathfinding:find_path({q=0,r=0}, {q=5,r=0})
    assert(path, "Path should exist")
    assert(#path == 6, "Path length should be 6 (0 to 5)")
end

function test_calendar()
    local cal = Calendar.new()
    assert(cal.day == 1 and cal.month == 1, "Start date correct")
    cal:advance_day()
    assert(cal.turn == 1, "Turn incremented")
    assert(cal.day == 2, "Day incremented")
end
```

### Integration Tests
```lua
-- tests/integration/test_geoscape_flow.lua
function test_complete_turn_cycle()
    local world = GeoScapeManager.new()
    
    -- Initial state
    assert(world.calendar.turn == 0)
    assert(world.crafts[1].status == "idle")
    
    -- Advance turn
    world:advance_turn()
    assert(world.calendar.turn == 1)
    
    -- Deploy craft
    world:start_craft_travel(1, {q=10, r=10})
    assert(world.crafts[1].status == "traveling")
    
    -- Advance several turns until arrival
    for i=1,10 do world:advance_turn() end
    assert(world.crafts[1].status == "idle")
    assert(world.crafts[1].current_hex.q == 10)
end
```

### Manual Testing
```
1. Run: lovec "engine"
2. Verify:
   - [ ] Hex grid renders (80×40 visible)
   - [ ] Provinces colored by biome
   - [ ] Calendar displays correctly
   - [ ] Can pan/zoom map
   - [ ] Can hover provinces (info shows)
   - [ ] Can advance turn (calendar updates)
   - [ ] Craft icons visible
   - [ ] Can select and deploy craft
   - [ ] Craft travels smoothly
   - [ ] FPS > 60 at all resolutions
```

---

## 📦 Deliverables

### Code Files
- `engine/geoscape/world_map.lua` - Hex grid and data management
- `engine/geoscape/world_renderer.lua` - Rendering logic
- `engine/geoscape/province_system.lua` - Province definitions and lookup
- `engine/geoscape/hex_pathfinding.lua` - Path calculation
- `engine/geoscape/craft_position_manager.lua` - Craft positioning and travel
- `engine/geoscape/geoscape_scene.lua` - Scene definition
- `engine/ui/geoscape_ui.lua` - UI layout and widgets
- `engine/ui/geoscape_viewport.lua` - Camera and viewport
- `engine/core/calendar.lua` - Calendar system (new or enhance existing)

### Data Files
- `mods/core/data/world_map.toml` - Hex grid configuration
- `mods/core/data/provinces.toml` - Province definitions (30-50 provinces)
- `mods/core/data/biomes.toml` - Biome properties and colors
- `mods/core/data/craft_speeds.toml` - Craft movement speeds
- `mods/core/data/starting_crafts.toml` - Starting craft configuration

### Tests
- `tests/geoscape/test_hex_world.lua` - Hex grid tests
- `tests/geoscape/test_provinces.lua` - Province system tests
- `tests/geoscape/test_pathfinding.lua` - Pathfinding tests
- `tests/geoscape/test_calendar.lua` - Calendar tests
- `tests/integration/test_geoscape_flow.lua` - Full scenario tests

### Documentation
- Update: `docs/geoscape/README.md` - Geoscape overview
- Create: `docs/geoscape/world_map_system.md` - World map documentation
- Create: `docs/geoscape/calendar_system.md` - Calendar documentation
- Update: `docs/API.md` - Add new API classes

---

## 🎬 How to Run & Debug

### Console Commands (Love2D Debug Console)
```lua
-- In console while game is running:

-- Show hex grid debug info
love.graphics.print("Current hex: " .. tostring(current_hex), 10, 10)

-- Teleport craft to test location
geoscape_manager:set_craft_position(1, {q=40, r=20})

-- Advance multiple turns
for i=1,30 do geoscape_manager:advance_turn() end

-- Print calendar state
print("Date: " .. calendar.year .. "-" .. calendar.month .. "-" .. calendar.day)
```

### Running
```bash
# Run with console enabled
lovec "engine"
```

### Expected Console Output
```
[Geoscape] World map initialized: 80x40 hex grid
[Geoscape] Loaded 35 provinces from provinces.toml
[Geoscape] Loaded 7 biome types from biomes.toml
[Geoscape] Initialized 3 starting crafts
[Calendar] Starting date: 1996-01-01
[OK] Geoscape Core ready for gameplay
```

---

## ✅ Success Criteria

### Functional
- [x] 80×40 hex world map renders without lag
- [x] All 30-50 provinces visible and color-coded by biome
- [x] Calendar displays and advances correctly
- [x] Crafts display on map with visible icons
- [x] Can pan/zoom map smoothly
- [x] Can deploy crafts and see travel animation
- [x] Turn advancement works
- [x] No console errors

### Performance
- [x] FPS ≥ 60 at all resolutions (240×360 to 1920×1080)
- [x] Map render time < 16ms per frame
- [x] Pathfinding < 5ms per calculation

### Code Quality
- [x] All functions documented with LuaDoc
- [x] All files follow `docs/core/LUA_BEST_PRACTICES.md`
- [x] Unit tests pass (100% critical path coverage)
- [x] No warnings in console

---

## 📈 Milestone Validation

**Milestone:** Core gameplay loop functional (Time → Map → Deployment)

**Verification:**
1. Start game → See Geoscape
2. Navigate world map
3. Advance time (calendar updates)
4. Deploy craft to new province
5. Craft travels and arrives
6. No crashes or errors

**Estimated Completion:** 80 hours (5 days at 16 hours/day)

---

**Status:** TODO - Ready for Implementation  
**Next Phase:** 1.2 Map Generation System  
**Blocks:** Phase 1.2 and 1.3 depend on this

---

*Part of MASTER-IMPLEMENTATION-PLAN.md*  
*Created: October 15, 2025*  
*Phase 1 Week 1 Foundation Task*
