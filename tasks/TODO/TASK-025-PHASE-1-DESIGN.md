# TASK-025: Geoscape - Master Implementation Plan

**Status:** Phase 1 - Design & Planning | **Date:** October 24, 2025
**Scope:** 140 hours estimated | **Phases:** 6 (Design → Implementation → Testing → Release)
**Objective:** Complete Geoscape system (global strategy layer for AlienFall)

---

## Overview

The **Geoscape** is the global strategic layer of AlienFall, where players manage:
- **Global World Map** (80×40 provinces with biomes, politics, economics)
- **Regional Control** (countries, factions, relationships, politics)
- **Base Management** (already built - Phase 4-8 earlier)
- **Mission Generation** (procedural on tactical battlefield)
- **UFO Tracking & Interception** (global defense system)
- **Research & Development** (tech tree progression)
- **Economic System** (credits, marketplace, manufacturing - Phase 6-8 earlier)
- **Diplomacy** (faction relations, treaties, politics - Phase 9 earlier)

**Status of Existing Systems:**
- ✅ Battlescape (3D tactical combat - TASK-028 complete)
- ✅ Basescape (base management - Phase 4-8)
- ✅ Economics (marketplace, manufacturing - Phase 6-8)
- ✅ Diplomacy (faction relations - Phase 9)
- ❌ Geoscape (global map) - **THIS TASK**

---

## What Needs to Be Built

### Core Geoscape Components

1. **World Map System** (New)
   - 80×40 province grid
   - Biome system (urban, desert, forest, arctic, water)
   - Terrain elevation
   - Procedural generation with seeding

2. **Regional Management** (New)
   - Countries/regions (15-20 territories)
   - City locations
   - Control markers
   - Infrastructure

3. **Faction System** (Extend from Phase 9)
   - Alien activity tracking
   - UFO sightings
   - Terror missions
   - Base locations

4. **Mission Generation** (Integrate with Battlescape)
   - Procedural map generation
   - Enemy force composition
   - Difficulty scaling
   - Time of day/weather

5. **Time System** (New)
   - Game calendar (days, weeks, months, years)
   - Turn-based progression
   - Historical events

6. **Rendering** (New)
   - Isometric or 2D map view
   - Panning/zooming
   - Unit markers
   - Status indicators

---

## Technical Architecture

### Layer Structure

```
┌─────────────────────────────────────┐
│  Main Game State Manager            │  Orchestrates all systems
├─────────────────────────────────────┤
│  Geoscape System                    │  This task
│  ├─ World (Map, Provinces)          │
│  ├─ Time (Calendar, Turns)          │
│  ├─ Factions (Activities, Missions) │
│  ├─ Rendering (Map Display)         │
│  └─ Input (Player Actions)          │
├─────────────────────────────────────┤
│  Basescape (Phase 4-8) ✅           │
│  Battlescape (TASK-028) ✅          │
│  Economics (Phase 6-8) ✅           │
│  Diplomacy (Phase 9) ✅             │
└─────────────────────────────────────┘
```

### Data Flow

```
Player Input (Geoscape)
    ↓
[Geoscape Input Handler]
    ↓
[Game Command]
    ├─ Move Unit → World State Update
    ├─ Scan Region → Faction Activity Check
    ├─ Start Mission → Generate Battlescape
    ├─ Manage Base → Transition to Basescape
    └─ End Turn → Time Advance, AI Activity
    ↓
[Render State Update]
    ↓
[Display Update]
```

---

## Phase Breakdown (140 Hours Estimated)

### Phase 1: Design & Planning (20 hours) ← CURRENT
**Deliverables:**
- Architecture document
- Data structure definitions
- API contracts
- Technology choices
- Task breakdown for Phases 2-6

**Timeline:** Next 2-3 hours

### Phase 2: World Generation (20 hours)
**Deliverables:**
- World map data structure
- Procedural generation algorithm
- Biome system
- City/location placement
- Province relationships

**Key Systems:**
- WorldMap class (80×40 grid)
- BiomeSystem class
- ProceduralGenerator class
- LocationSystem class

### Phase 3: Regional Management (15 hours)
**Deliverables:**
- Region/country system
- Control tracking
- Political boundaries
- Infrastructure system
- Economic integration

**Key Systems:**
- RegionSystem class
- CountrySystem class
- ControlTracker class

### Phase 4: Faction & Mission System (20 hours)
**Deliverables:**
- Alien faction tracking
- UFO activity simulation
- Mission generation integration
- Terror attack mechanics
- Difficulty scaling

**Key Systems:**
- FactionActivitySystem class
- MissionGenerator class
- UFOSystem class

### Phase 5: Time & Turn Management (15 hours)
**Deliverables:**
- Game calendar
- Turn progression
- Event scheduling
- Historical tracking
- Save/load system

**Key Systems:**
- TimeSystem class
- TurnManager class
- EventScheduler class

### Phase 6: Rendering & UI (30 hours)
**Deliverables:**
- Map rendering (isometric/2D)
- UI overlays (stats, indicators)
- Interactive elements (clickable provinces)
- Minimap
- HUD information display

**Key Systems:**
- MapRenderer class
- UIRenderer class
- InputHandler class
- Camera/viewport system

### Phase 7: Testing & Documentation (20 hours)
**Deliverables:**
- Integration tests (all systems)
- Performance benchmarks
- Comprehensive API documentation
- Tutorial/guide

---

## Data Structure Design

### World Map
```lua
World = {
    width = 80,
    height = 40,
    provinces = {
        [1] = {
            x = 0, y = 0,
            biome = "urban",        -- urban, desert, forest, arctic, water
            elevation = 0.5,        -- 0-1 scale
            population = 5000000,
            country_id = 1,
            control = "player",     -- player, alien, neutral
            has_city = true,
            cities = {
                {name = "New York", pop = 2000000}
            },
            infrastructure = 0.8,   -- 0-1 development level
            economy = {credits_per_turn = 100},
            military = {base_count = 2, units = 50}
        },
        -- ... 3,199 more provinces
    },
    biome_map = {},  -- For fast biome lookup
    regions = {},    -- Countries/regions
    factions = {}    -- Alien/player factions
}
```

### Time System
```lua
GameTime = {
    calendar = {
        year = 2026,
        month = 3,      -- 1-12
        day = 15,       -- 1-28/30/31
        hour = 14,      -- 0-23 (for day/night)
        turn = 42       -- Global turn counter
    },
    days_elapsed = 75,
    seasons = "spring",

    -- Event tracking
    events = {
        {turn = 50, type = "alien_invasion", location = {x=40, y=20}},
        {turn = 60, type = "country_falls", region_id = 3}
    }
}
```

### Faction Activity
```lua
FactionActivity = {
    aliens = {
        total_ufos = 12,
        threat_level = 0.6,  -- 0-1 scale
        activity_regions = {5, 12, 18},
        terror_missions = {
            {target_region = 5, turn = 55}
        },
        bases = {
            {x = 20, y = 15, strength = 0.8}
        }
    },
    player = {
        bases = 5,
        current_funds = 50000,
        research_progress = {
            laser_weapons = 0.4,
            armor = 0.2
        }
    }
}
```

---

## API Design (Phase 1 Planning)

### GeoScape Main Interface
```lua
-- Initialize
local geoscape = Geoscape.new(seed, difficulty)

-- Update each turn
geoscape:update(turn_count)
geoscape:endTurn()

-- Query state
local world = geoscape:getWorld()
local province = geoscape:getProvince(x, y)
local regions = geoscape:getRegions()
local time = geoscape:getGameTime()

-- Perform actions
geoscape:startMission(province, difficulty)
geoscape:moveUnit(unit_id, from, to)
geoscape:manageFaction(faction_id, action, params)
geoscape:advanceTime(days)

-- Rendering
local render_data = geoscape:getRenderData()
geoscape:render(renderTarget)
geoscape:handleInput(input_type, x, y)
```

### World System
```lua
local world = World.new(width, height, seed)

world:generateProvinces(biome_config)
world:setProvince(x, y, province_data)
local province = world:getProvince(x, y)
local neighbors = world:getNeighbors(x, y)
local distance = world:getDistance({x=10, y=20}, {x=40, y=30})
```

### Time System
```lua
local time = TimeSystem.new()

time:advanceDay()
time:advanceTurn()
time:getCalendarString()   -- "March 15, 2026"
local elapsed = time:getDaysElapsed()
time:scheduleEvent(event_type, turn_count, params)
```

### Faction System
```lua
local factions = FactionSystem.new(world)

factions:updateAlienActivity(turn)
factions:generateMission(difficulty, target_region)
local ufo_count = factions:getUFOCount()
factions:recordTerrorAttack(region)
```

---

## Technology Choices

### Data Storage
- **Lua Tables:** All primary data structures
- **Serialization:** Love2D filesystem for save/load
- **Optimization:** Hash maps for O(1) lookups

### Procedural Generation
- **Algorithm:** Perlin noise + cellular automata (for biomes)
- **Seeding:** Deterministic with seed value
- **Distribution:** Balanced across map

### Rendering
- **View:** Isometric projection (40×30 tile viewport)
- **Performance:** Tile culling (only render visible tiles)
- **Zoom:** 0.5x to 3.0x magnification
- **Frame Rate:** 60 FPS target

### AI/Simulation
- **Alien Activity:** Turn-based behavior tree
- **Country Activity:** Faction behavior model
- **Economic Simulation:** Per-turn calculations
- **Event Timing:** Scheduled event system

---

## Estimated Component Breakdown

### Code Organization
```
engine/geoscape/
├── README.md                    -- Overview
├── geoscape.lua                 -- Main coordinator (150 lines)
├── world/
│   ├── world.lua                -- Map system (250 lines)
│   ├── biome_system.lua         -- Biome generation (150 lines)
│   ├── location_system.lua      -- Cities/POIs (100 lines)
│   └── terrain.lua              -- Elevation/terrain (80 lines)
├── regions/
│   ├── region_system.lua        -- Region management (150 lines)
│   ├── country_system.lua       -- Country/faction control (120 lines)
│   └── control_tracker.lua      -- Ownership tracking (80 lines)
├── factions/
│   ├── faction_system.lua       -- Faction management (200 lines)
│   ├── alien_activity.lua       -- UFO/alien behavior (180 lines)
│   ├── mission_generator.lua    -- Mission creation (150 lines)
│   └── ufo_system.lua           -- UFO tracking (120 lines)
├── time/
│   ├── time_system.lua          -- Calendar/turns (120 lines)
│   ├── event_scheduler.lua      -- Event management (100 lines)
│   └── history.lua              -- Historical records (80 lines)
├── rendering/
│   ├── map_renderer.lua         -- Map display (250 lines)
│   ├── ui_renderer.lua          -- UI overlays (200 lines)
│   ├── camera.lua               -- Viewport management (100 lines)
│   └── tiles.lua                -- Tile rendering (150 lines)
└── input/
    └── input_handler.lua        -- Player input (120 lines)

Total Estimated: 2,900+ lines
```

---

## Integration Points

### With Basescape (Phase 4-8)
```lua
-- Launch from Geoscape
geoscape:enterBase(base_id)
↓
basescape = Basescape.new(base_data)
↓
-- Return after base management
geoscape:exitBase(updated_base_state)
```

### With Battlescape (TASK-028)
```lua
-- Generate mission from Geoscape
local mission = geoscape:generateMission(province, difficulty)
↓
battlescape = Battlescape.new(mission)
↓
-- Return after combat
geoscape:resolveMission(battlescape.results)
```

### With Economics (Phase 6-8)
```lua
-- Automatic credit generation per turn
geoscape:update(turn) → economics:calculateIncome()

-- Market integration
geoscape:accessMarketplace() → marketplace.trade()
```

### With Diplomacy (Phase 9)
```lua
-- Faction relations affect region control
geoscape:updateRegionControl(region_id)
  ├─ Check faction_relations
  ├─ Apply territory modifiers
  └─ Update control markers
```

---

## Success Criteria

### Functionality
- ✅ 80×40 world map with procedural generation
- ✅ Region/country system with control tracking
- ✅ Biome and terrain system
- ✅ City/location placement
- ✅ Alien faction activity simulation
- ✅ Mission generation system
- ✅ Game calendar and turn progression
- ✅ Map rendering with UI
- ✅ Player input handling

### Performance
- 60 FPS target on standard hardware
- <100ms per turn calculation
- Smooth panning/zooming
- No memory leaks (save/load cycles)

### Quality
- 0 lint errors
- Comprehensive documentation (API reference)
- All systems tested (unit + integration)
- Production-ready code

### Integration
- Seamless transition to Basescape
- Seamless mission launch to Battlescape
- Proper save/load support
- Backward compatible with existing systems

---

## Next Steps (Phase 1 Activities)

### Immediate (Next 2-3 Hours)
1. ✅ Create this architecture document
2. Create data structure specifications
3. Create detailed task breakdown for Phases 2-6
4. Create API contracts document
5. Create technology decision document

### Following (Before Phase 2 Start)
1. Get design approval
2. Create test framework for Phase 2
3. Set up project structure
4. Create Phase 2 detailed plan

---

## Key Design Decisions

### World Size: 80×40 Provinces
- **Rationale:** Large enough for interesting gameplay, small enough for O(1) lookups
- **Performance:** 3,200 provinces, ~200 bytes each = 640 KB memory
- **Rendering:** 40×30 visible at 2.0x zoom = manageable draw calls

### Procedural Generation with Seeding
- **Rationale:** Unlimited replayability, deterministic for multiplayer
- **Algorithm:** Perlin noise (biomes) + cellular automata (connections)
- **Performance:** Generated once at startup, cached in memory

### Turn-Based Advancement
- **Rationale:** Matches existing Battlescape/Basescape turn systems
- **Frequency:** Player controls turn duration
- **Automation:** AI faction activity calculated per turn

### Isometric Rendering
- **Rationale:** Classic strategy game perspective, good for region view
- **Performance:** Single layer rendering (no 3D depth)
- **Clarity:** Clear tile boundaries and interactivity

---

## Timeline Estimate

| Phase | Hours | Days | Target Completion |
|-------|-------|------|-------------------|
| 1: Design | 20 | 2.5 | Oct 25 |
| 2: World Gen | 20 | 2.5 | Oct 27 |
| 3: Regions | 15 | 2 | Oct 29 |
| 4: Factions | 20 | 2.5 | Oct 31 |
| 5: Time/Turns | 15 | 2 | Nov 2 |
| 6: Rendering | 30 | 4 | Nov 6 |
| 7: Testing | 20 | 2.5 | Nov 8 |
| **TOTAL** | **140** | **18** | **Nov 8** |

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Procedural generation performance | Medium | Use caching, pre-compute at startup |
| Rendering bottleneck (3,200 tiles) | Medium | Implement frustum culling for visible tiles |
| State management complexity | High | Clear data flow, modular architecture |
| Integration with existing systems | Medium | Well-defined APIs, extensive testing |
| Save/load data size | Low | Compress when needed, incremental saves |

---

## Questions for Review

1. Confirm 80×40 province size
2. Confirm isometric rendering approach
3. Confirm turn-based advancement
4. Confirm integration points with Basescape/Battlescape
5. Any additional Geoscape features beyond scope?

---

**End of Phase 1 Planning**

**Next Phase:** Phase 2 (World Generation) - 20 hours estimated

**Status:** Ready to proceed with Phase 2 implementation
