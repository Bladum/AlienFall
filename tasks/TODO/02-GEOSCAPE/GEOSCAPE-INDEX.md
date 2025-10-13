# Geoscape Task Documentation Index

**Task ID:** TASK-025  
**Created:** October 13, 2025  
**Status:** TODO  
**Priority:** Critical  
**Estimated Time:** 140 hours (17-18 days)

---

## 📋 Quick Navigation

| Document | Purpose | Use When |
|----------|---------|----------|
| **[Main Task Document](TASK-025-geoscape-master-implementation.md)** | Complete implementation plan with detailed requirements, phases, and documentation | Planning work, understanding full scope |
| **[Quick Reference](GEOSCAPE-QUICK-REFERENCE.md)** | Core mechanics, APIs, and data structures at a glance | Need quick lookup of system details |
| **[Architecture Diagram](GEOSCAPE-ARCHITECTURE-DIAGRAM.md)** | Visual system architecture, data flow, and file structure | Understanding system design and dependencies |
| **[Implementation Checklist](GEOSCAPE-IMPLEMENTATION-CHECKLIST.md)** | Phase-by-phase checklist with all tasks | Tracking progress during implementation |

---

## 📊 Task Overview

### What is the Geoscape?

The **Geoscape** is the strategic layer that connects all game modes (Battlescape, Basescape, Interception). It provides:

- **Global Strategy:** World-level resource management and decision-making
- **Mission System:** Detection, deployment, and interception mechanics
- **Political Simulation:** Country relations, funding, diplomacy
- **Economic Layer:** Province economies, base costs, craft operations
- **Travel System:** Hex-based pathfinding for craft deployment
- **Time Management:** Turn-based calendar driving all events
- **Multi-World Support:** Earth, Mars, and other planetary bodies

### Core Systems Summary

```
Universe → Worlds → Provinces → Crafts/Bases/Missions
    ↓         ↓          ↓            ↓
  Portals  Hex Grid  Countries    Travel System
                      Regions      Radar Detection
                      Biomes       Auto-Return
```

### Key Mechanics

| System | Description | Time Estimate |
|--------|-------------|---------------|
| **Hex Grid** | 80×40 hex map (500km/tile) with axial coordinates | 6h |
| **Province Graph** | Node-based strategic map with A* pathfinding | 8h |
| **Calendar** | 1 turn = 1 day, 360 days/year turn-based system | 6h |
| **Day/Night Cycle** | 50/50 coverage, moves 4 tiles/day | 4h |
| **Craft Travel** | Hex pathfinding with fuel costs and operational range | 8h |
| **Country Relations** | -2 to +2 scale affecting funding | 6h |
| **Biomes & Regions** | Geographic grouping for missions and scoring | 10h |
| **Bases & Portals** | Base construction and inter-world travel | 18h |
| **UI Layer** | World map, panels, widgets (grid-snapped) | 30h |

---

## 🎯 Implementation Strategy

### Phase Order (9 Phases, 140 hours)

1. **Phase 1:** Core Data Structures & World Grid (18h)
   - Hex grid math, world entity, province graph

2. **Phase 2:** Calendar & Time System (10h)
   - Turn-based calendar, day/night cycle

3. **Phase 3:** Geographic & Political Systems (16h)
   - Biomes, countries, regions

4. **Phase 4:** Craft & Travel System (20h)
   - Craft entity, hex pathfinding, radar, auto-return

5. **Phase 5:** Base Management (10h)
   - Base entity, construction system with cost modifiers

6. **Phase 6:** Universe & Portal System (12h)
   - Multi-world container, inter-world travel

7. **Phase 7:** UI Implementation (30h)
   - World map renderer, panels, widgets (all grid-snapped)

8. **Phase 8:** Integration & Polish (14h)
   - State manager integration, turn processing, testing

9. **Phase 9:** Documentation (10h)
   - API docs, FAQ, user guide

### Critical Dependencies

- **Widget System:** Must be stable (Phase 7 depends on it)
- **State Manager:** Must support Geoscape state
- **Data Loader:** Must parse TOML files

---

## 📁 File Structure Preview

```
engine/geoscape/
├── init.lua                      -- Geoscape state entry point
│
├── logic/                        -- Core entities (11 files)
│   ├── universe.lua              -- Multi-world manager
│   ├── world.lua                 -- 80×40 hex world
│   ├── province.lua              -- Province node
│   ├── province_graph.lua        -- Graph + A* pathfinding
│   ├── craft.lua                 -- Craft entity
│   ├── base.lua                  -- Base entity
│   ├── country.lua               -- Political entity
│   ├── region.lua                -- Geographic grouping
│   ├── biome.lua                 -- Biome definitions
│   ├── portal.lua                -- Inter-world portal
│   └── pathfinding.lua           -- A* on hex grid
│
├── systems/                      -- Game systems (9 files)
│   ├── hex_grid.lua              -- Hex coordinate math
│   ├── calendar.lua              -- Turn-based time
│   ├── daynight_cycle.lua        -- Day/night movement
│   ├── travel_system.lua         -- Craft movement
│   ├── radar_system.lua          -- Mission detection
│   ├── base_construction.lua     -- Base building
│   ├── craft_return.lua          -- Auto-return system
│   └── turn_processor.lua        -- End turn logic
│
├── rendering/                    -- Rendering (2 files)
│   ├── world_renderer.lua        -- Hex grid + provinces
│   └── daynight_overlay.lua      -- Dark shader
│
├── ui/                           -- UI widgets (6 files)
│   ├── world_map.lua             -- Interactive map
│   ├── province_panel.lua        -- Province info
│   ├── craft_selector.lua        -- Craft list
│   ├── range_highlighter.lua     -- Operational range
│   ├── calendar_widget.lua       -- Date + end turn
│   └── country_relations_panel.lua -- Country list
│
└── tests/                        -- Test suite (5 files)
    ├── test_hex_grid.lua
    ├── test_calendar.lua
    ├── test_travel_system.lua
    ├── test_country.lua
    └── test_geoscape_integration.lua

Total: ~40 new files
```

---

## 🎮 Example Data Files

### World Definition (earth.toml)
```toml
[world]
id = "earth"
name = "Earth"
width = 80
height = 40
scale = 500  # km per tile

[daynight]
speed = 4
coverage = 0.5
```

### Province Definition (earth_provinces.toml)
```toml
[[province]]
id = "province_001"
name = "Central Europe"
q = 40
r = 20
biomeId = "temperate_forest"
countryId = "germany"
regionId = "central_europe"
isLand = true
cities = ["Berlin", "Munich", "Hamburg"]

[[province.connections]]
targetId = "province_002"
cost = 2
```

### Country Definition (countries.toml)
```toml
[[country]]
id = "germany"
name = "Germany"
flag = "flags/germany.png"
baseFunding = 50000
initialRelations = 0
```

---

## 🧪 Testing Strategy

### Unit Tests (5 files)
- Hex grid calculations (distance, neighbors, conversion)
- Calendar advancement (day/week/month/year rollovers)
- A* pathfinding on hex grid
- Craft type restrictions (land/air/water)
- Country funding calculations

### Integration Tests
- World loading from TOML
- Province graph connectivity
- Craft deployment flow (base → craft → target)
- Fuel deduction and travel point management
- Calendar triggers (monthly funding)
- Portal travel between worlds

### Manual Testing
1. Run: `lovec "engine"` (console enabled)
2. Navigate to Geoscape
3. Verify hex grid renders
4. Deploy craft to province
5. Advance turns, check calendar
6. Verify day/night cycle moves
7. Check country relations update
8. Test portal travel

---

## 🔧 Development Tools

### Debug Commands
```lua
print("[Geoscape] Craft " .. craftId .. " at " .. provinceId)
print("[Calendar] " .. Calendar:getDate())
print("[Fuel] Base: " .. base.fuel .. "/" .. base.maxFuel)
```

### Debug Keys
- **F9:** Toggle hex grid overlay (essential for UI work)
- **F12:** Toggle fullscreen
- **F1:** Show debug info (crafts, provinces, calendar)

### Run Command
```bash
lovec "engine"
```
or use VS Code task: **"Run XCOM Simple Game"**

---

## ✅ Acceptance Criteria Checklist

- [ ] 80×40 hex world map renders correctly
- [ ] Day/night cycle visually moves 4 tiles per day
- [ ] User can deploy crafts via base → craft → target flow
- [ ] Craft travel costs fuel from base stockpile
- [ ] Radar automatically detects missions on arrival
- [ ] Calendar advances 1 day per turn (360 days/year)
- [ ] Country relations affect monthly funding
- [ ] Multiple worlds accessible via portals
- [ ] Province graph pathfinding respects terrain types
- [ ] All UI elements snap to 24×24 pixel grid
- [ ] No console errors or warnings during gameplay

---

## 📚 Key APIs Preview

### HexGrid System
```lua
HexGrid.new(80, 40)
HexGrid:distance(q1, r1, q2, r2) -- Hex distance
HexGrid:neighbors(q, r)          -- 6 adjacent hexes
HexGrid:toPixel(q, r)            -- Hex → screen coords
```

### Travel System
```lua
TravelSystem:canTravel(craftId, targetProvinceId)
TravelSystem:getOperationalRange(craftId)  -- Reachable provinces
TravelSystem:calculatePath(craftId, targetId) -- A* path
TravelSystem:travel(craftId, targetId)     -- Execute travel
```

### Calendar System
```lua
Calendar:advanceTurn()  -- +1 day
Calendar:getDate()      -- "Year 1, Q2, Month 5, Week 3, Day 4"
Calendar:getDayOfYear() -- 1-360
```

### Universe System
```lua
Universe:addWorld(world)
Universe:switchWorld(worldId)
Universe:canTravel(craftId, portalId) -- Check portal access
```

---

## 🚀 Getting Started

### Step 1: Read the Task Documents
1. **[Main Task](TASK-025-geoscape-master-implementation.md)** - Full implementation plan
2. **[Quick Reference](GEOSCAPE-QUICK-REFERENCE.md)** - Core mechanics summary
3. **[Architecture](GEOSCAPE-ARCHITECTURE-DIAGRAM.md)** - System design

### Step 2: Review the Checklist
- **[Implementation Checklist](GEOSCAPE-IMPLEMENTATION-CHECKLIST.md)** - Track progress

### Step 3: Start Phase 1
- Begin with hex grid system implementation
- Run tests frequently with `lovec "engine"`
- Mark checklist items as completed

### Step 4: Update Progress
- Update checklist checkboxes
- Update `tasks/tasks.md` with status
- Log blockers and decisions

---

## 📝 Progress Tracking

**Created:** October 13, 2025  
**Status:** TODO  
**Current Phase:** Not Started  
**Hours Completed:** 0/140 (0%)  
**Expected Completion:** TBD

---

## 🔗 Related Tasks

- **TASK-016:** HEX Grid Tactical Combat (Battlescape) - Uses similar hex grid math
- **ENGINE-RESTRUCTURE:** Folder restructure - Creates `geoscape/` folder structure

---

## 📞 Quick Reference Links

- **Task Tracking:** `tasks/tasks.md`
- **Task Template:** `tasks/TASK_TEMPLATE.md`
- **API Documentation:** `wiki/API.md`
- **FAQ:** `wiki/FAQ.md`
- **Development Guide:** `wiki/DEVELOPMENT.md`

---

## 💡 Important Reminders

1. **Always run with Love2D console:** `lovec "engine"`
2. **All UI must snap to 24×24 pixel grid**
3. **All temp files go to:** `os.getenv("TEMP")`
4. **Use print for debugging:** `print("[Geoscape] Message")`
5. **Update checklist as you work**
6. **Test frequently with F9 (grid overlay)**
7. **Document all public APIs**
8. **No global variables - use `local`**

---

**Good luck with implementation! 🚀**

---

## Document Change Log

| Date | Change | Author |
|------|--------|--------|
| Oct 13, 2025 | Initial task creation | AI Agent |
| Oct 13, 2025 | Created all 4 supporting documents | AI Agent |
| Oct 13, 2025 | Added to tasks.md | AI Agent |

---

**End of Index**
