# Geoscape System Architecture Diagram

**Task:** TASK-025 - Geoscape Master Implementation

---

## System Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GAME STATE                              │
│                      (state_manager.lua)                         │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GEOSCAPE STATE                             │
│                      (geoscape/init.lua)                         │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ load()       │  │ update(dt)   │  │ draw()       │         │
│  │ unload()     │  │ endTurn()    │  │ mousePress   │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
                    │              │              │
        ┌───────────┘              │              └───────────┐
        ▼                          ▼                          ▼
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   LOGIC      │         │   SYSTEMS    │         │   UI/RENDER  │
│   LAYER      │         │   LAYER      │         │   LAYER      │
└──────────────┘         └──────────────┘         └──────────────┘
```

---

## Logic Layer - Core Entities

```
┌────────────────────────────────────────────────────────────────────┐
│                            UNIVERSE                                │
│                      (logic/universe.lua)                          │
│                                                                    │
│  • Manages multiple worlds                                        │
│  • Portal travel between worlds                                   │
│  • Current world selection                                        │
└────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────┐
│                             WORLD                                  │
│                        (logic/world.lua)                           │
│                                                                    │
│  • 80×40 hex tile grid (1 tile = 500km)                          │
│  • Background image (800×400 pixels)                              │
│  • Day/night cycle data                                           │
│  • List of provinces, portals                                     │
└────────────────────────────────────────────────────────────────────┘
          │                        │                        │
          ▼                        ▼                        ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│    PROVINCE      │  │     PORTAL       │  │    HEX TILE      │
│ (logic/province) │  │ (logic/portal)   │  │  (in world.tiles)│
│                  │  │                  │  │                  │
│ • Position (q,r) │  │ • From world/prov│  │ • Terrain type   │
│ • Biome          │  │ • To world/prov  │  │ • Travel cost    │
│ • Country        │  │ • Fuel cost      │  │ • Land/water     │
│ • Region         │  │ • Accessible?    │  │                  │
│ • Economy        │  └──────────────────┘  └──────────────────┘
│ • Connections    │
│ • Base (1 max)   │
│ • Crafts (4 max) │
│ • Missions       │
│ • Cities         │
└──────────────────┘
    │       │
    ▼       ▼
┌─────┐  ┌─────┐
│BASE │  │CRAFT│
└─────┘  └─────┘
```

---

## Geographic & Political Entities

```
┌────────────────────────────────────────────────────────────────────┐
│                           COUNTRY                                  │
│                      (logic/country.lua)                           │
│                                                                    │
│  • ID, Name, Flag                                                 │
│  • List of owned provinces                                        │
│  • Economy (sum of province GDPs)                                 │
│  • Relations with player (-2 to +2)                               │
│  • Monthly funding to player                                      │
│  • Performance score                                              │
│                                                                    │
│  Funding = baseFunding × (1 + relations × 0.5) × (score / 100)   │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                            REGION                                  │
│                       (logic/region.lua)                           │
│                                                                    │
│  • ID, Name                                                       │
│  • List of provinces in region                                    │
│  • Accumulated score/fame                                         │
│  • Marketplace access (boolean)                                   │
│  • Mission scripting target                                       │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                            BIOME                                   │
│                        (logic/biome.lua)                           │
│                                                                    │
│  • ID, Name                                                       │
│  • Interception background image                                  │
│  • List of battlescape terrain types                              │
│  • Base construction cost modifier                                │
└────────────────────────────────────────────────────────────────────┘
```

---

## Craft & Base Entities

```
┌────────────────────────────────────────────────────────────────────┐
│                             CRAFT                                  │
│                        (logic/craft.lua)                           │
│                                                                    │
│  • ID, Type ID, Name                                              │
│  • Current province ID                                            │
│  • Home base ID                                                   │
│  • Fuel (current / max)                                           │
│  • Travel points (remaining / max per turn)                       │
│  • Craft type: "land", "air", "water"                            │
│  • Speed (max hex range per travel)                               │
│  • Radar range (mission detection)                                │
│                                                                    │
│  Types:                                                           │
│  • Land: Uses land paths only, cost 1-3 per tile                 │
│  • Air: Can cross water, ignores terrain cost                    │
│  • Water: Uses water paths only, cost 1 per tile                 │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                              BASE                                  │
│                        (logic/base.lua)                            │
│                                                                    │
│  • ID, Name                                                       │
│  • Province ID (location)                                         │
│  • Country ID (host country)                                      │
│  • Construction cost                                              │
│  • Fuel stockpile (current / max)                                │
│  • List of stationed crafts                                       │
│  • Facilities (future)                                            │
│                                                                    │
│  Restrictions:                                                    │
│  • One base per province maximum                                  │
│  • Cost affected by biome, country relations, region              │
└────────────────────────────────────────────────────────────────────┘
```

---

## Systems Layer

```
┌────────────────────────────────────────────────────────────────────┐
│                          HEX GRID SYSTEM                           │
│                      (systems/hex_grid.lua)                        │
│                                                                    │
│  Coordinate System:                                               │
│  • Axial coordinates (q, r)                                       │
│  • Cube coordinates (x, y, z) for distance                        │
│                                                                    │
│  Functions:                                                       │
│  • distance(q1, r1, q2, r2)          - Hex distance               │
│  • neighbors(q, r)                    - 6 adjacent hexes          │
│  • ring(q, r, radius)                 - Hexes at exact distance   │
│  • area(q, r, radius)                 - All hexes within range    │
│  • toPixel(q, r)                      - Hex → screen coords       │
│  • toHex(x, y)                        - Screen → hex coords       │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                        TRAVEL SYSTEM                               │
│                    (systems/travel_system.lua)                     │
│                                                                    │
│  Craft Movement:                                                  │
│  • canTravel(craftId, targetProvinceId)                           │
│  • getOperationalRange(craftId)     - All reachable provinces     │
│  • calculatePath(craftId, targetId) - A* hex pathfinding          │
│  • travel(craftId, targetId)        - Execute travel              │
│                                                                    │
│  Dependencies:                                                    │
│  • HexGrid for distance calculations                              │
│  • ProvinceGraph for pathfinding                                  │
│  • Base fuel stockpile for cost                                   │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                         CALENDAR SYSTEM                            │
│                      (systems/calendar.lua)                        │
│                                                                    │
│  Time Structure:                                                  │
│  • 1 turn = 1 day                                                 │
│  • 6 days = 1 week                                                │
│  • 5 weeks = 1 month (30 days)                                    │
│  • 3 months = 1 quarter (90 days)                                 │
│  • 4 quarters = 1 year (360 days)                                 │
│                                                                    │
│  Functions:                                                       │
│  • advanceTurn()        - Increment day                           │
│  • getDate()            - Formatted date string                   │
│  • getDayOfYear()       - 1-360                                   │
│  • getDayOfWeek()       - 1-6                                     │
│  • getDayOfMonth()      - 1-30                                    │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                      DAY/NIGHT CYCLE                               │
│                  (systems/daynight_cycle.lua)                      │
│                                                                    │
│  Mechanics:                                                       │
│  • 50% of map is day, 50% is night                                │
│  • Moves 4 tiles per day (left to right)                          │
│  • Full cycle = 20 days (80 tiles / 4)                            │
│                                                                    │
│  Functions:                                                       │
│  • update(turn)              - Move day/night line                │
│  • isDay(q, r)               - Check if hex is in daylight        │
│  • getDayNightLine()         - Get current dividing line position │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                        RADAR SYSTEM                                │
│                    (systems/radar_system.lua)                      │
│                                                                    │
│  Mission Detection:                                               │
│  • scan(craftId)                - Scan province for missions      │
│  • autoScanOnArrival(craftId)   - Triggered by travel            │
│  • getDetectedMissions(provinceId) - List missions                │
│                                                                    │
│  Detection Range:                                                 │
│  • Each craft has radarRange (e.g., 10 hexes)                    │
│  • Scans own province + adjacent within range                     │
│  • Better radar = more mission details revealed                   │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                      BASE CONSTRUCTION                             │
│                (systems/base_construction.lua)                     │
│                                                                    │
│  Functions:                                                       │
│  • canBuild(provinceId)      - Check if province available        │
│  • getCost(provinceId)       - Calculate cost with modifiers     │
│  • build(provinceId, name)   - Create base                        │
│                                                                    │
│  Cost Modifiers:                                                  │
│  • Biome: Desert +0%, Forest +20%, Arctic +50%                    │
│  • Country Relations: Hostile +100%, Allied -25%                  │
│  • Region: Strategic regions +30%                                 │
│                                                                    │
│  Restrictions:                                                    │
│  • One base per province                                          │
│  • Relations ≥ -1 required                                        │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                       TURN PROCESSOR                               │
│                   (systems/turn_processor.lua)                     │
│                                                                    │
│  End Turn Logic (in order):                                       │
│  1. Advance calendar (+1 day)                                     │
│  2. Update day/night cycle                                        │
│  3. Reset craft travel points                                     │
│  4. Process missions (spawn/expiration)                           │
│  5. Update country funding (monthly trigger)                      │
│  6. Process economy updates                                       │
│  7. Trigger region events                                         │
│  8. Save game state                                               │
└────────────────────────────────────────────────────────────────────┘
```

---

## Pathfinding Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                      PROVINCE GRAPH                                │
│                  (logic/province_graph.lua)                        │
│                                                                    │
│  Graph Structure:                                                 │
│  • Nodes: Provinces                                               │
│  • Edges: Connections with travel costs                           │
│  • Weighted graph (terrain costs 1-3)                             │
│                                                                    │
│  Operations:                                                      │
│  • addProvince(province)                                          │
│  • addConnection(id1, id2, cost)                                  │
│  • getNeighbors(provinceId)                                       │
│  • findPath(fromId, toId, craftType)  - A* pathfinding           │
│  • getRange(fromId, maxCost, craftType) - Operational range       │
└────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────────────────────────────┐
│                       A* PATHFINDING                               │
│                    (logic/pathfinding.lua)                         │
│                                                                    │
│  Algorithm:                                                       │
│  • A* on hex grid with terrain costs                              │
│  • Heuristic: Hex distance (Manhattan on cube coords)             │
│  • Cost: Accumulated terrain cost from start                      │
│                                                                    │
│  Craft Type Restrictions:                                         │
│  • Land: Only land tiles, cost 1-3 per tile                       │
│  • Air: All tiles, uniform cost (ignores terrain)                 │
│  • Water: Only water tiles, cost 1 per tile                       │
│                                                                    │
│  Output:                                                          │
│  • List of province IDs from start to goal                        │
│  • Total cost (fuel required)                                     │
└────────────────────────────────────────────────────────────────────┘
```

---

## UI/Rendering Layer

```
┌────────────────────────────────────────────────────────────────────┐
│                       WORLD RENDERER                               │
│                 (rendering/world_renderer.lua)                     │
│                                                                    │
│  Renders:                                                         │
│  • Background image (800×400 pixels)                              │
│  • Hex grid overlay (optional, toggled with F9)                   │
│  • Province shapes (filled/outlined)                              │
│  • Day/night overlay (dark shader on night side)                  │
│  • Craft icons at province positions                              │
│  • Base icons                                                     │
│  • Mission indicators                                             │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                        WORLD MAP UI                                │
│                     (ui/world_map.lua)                             │
│                                                                    │
│  Interactive Elements:                                            │
│  • Province hover (highlight + tooltip)                           │
│  • Province selection (detailed info)                             │
│  • Craft click (show info)                                        │
│  • Base click (show crafts)                                       │
│  • Pan/zoom controls                                              │
│                                                                    │
│  Grid Snapping: All UI at 24×24 pixel grid                        │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                     PROVINCE INFO PANEL                            │
│                   (ui/province_panel.lua)                          │
│                                                                    │
│  Displays:                                                        │
│  • Province name, country, region                                 │
│  • Biome type                                                     │
│  • Active missions (count + types)                                │
│  • Crafts in province (list)                                      │
│  • Player base (if present)                                       │
│  • Cities list                                                    │
│                                                                    │
│  Grid Snapping: Panel at 24×24 multiples                          │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                    CRAFT DEPLOYMENT UI                             │
│                   (ui/craft_selector.lua)                          │
│                 (ui/range_highlighter.lua)                         │
│                                                                    │
│  Flow:                                                            │
│  1. User clicks base → Show craft list                            │
│  2. User selects craft → Highlight operational range              │
│  3. User clicks target province → Confirm travel                  │
│  4. System executes travel, deducts fuel                          │
│                                                                    │
│  Highlighting Colors:                                             │
│  • Green: Reachable provinces (within fuel/travel points)         │
│  • Yellow: Edge of range                                          │
│  • Red: Out of range                                              │
│                                                                    │
│  Grid Snapping: All widgets at 24×24 multiples                    │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                   CALENDAR & COUNTRY PANEL                         │
│                  (ui/calendar_widget.lua)                          │
│              (ui/country_relations_panel.lua)                      │
│                                                                    │
│  Calendar Widget:                                                 │
│  • Current date display                                           │
│  • "End Turn" button                                              │
│  • Turn counter                                                   │
│                                                                    │
│  Country Panel:                                                   │
│  • List of major countries                                        │
│  • Relations (-2 to +2) with color coding:                        │
│    - Red: Hostile (-2, -1)                                        │
│    - Yellow: Neutral (0)                                          │
│    - Green: Friendly (+1, +2)                                     │
│  • Monthly funding amount                                         │
│  • Score in their territory                                       │
│                                                                    │
│  Grid Snapping: All widgets at 24×24 multiples                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow - Craft Deployment

```
1. USER INPUT
   └─> Click Base Icon on World Map
       │
       ▼
2. UI RESPONSE
   └─> CraftSelector:show(baseId)
       │
       ▼
3. DISPLAY CRAFTS
   └─> Fetch crafts from Base:getCrafts()
       │
       ▼
4. USER SELECTS CRAFT
   └─> Click craft in list
       │
       ▼
5. CALCULATE RANGE
   └─> TravelSystem:getOperationalRange(craftId)
       │ (uses A* pathfinding on province graph)
       ▼
6. HIGHLIGHT PROVINCES
   └─> RangeHighlighter:show(reachableProvinces)
       │ (green = reachable, red = out of range)
       ▼
7. USER SELECTS TARGET
   └─> Click target province on map
       │
       ▼
8. VALIDATE TRAVEL
   └─> TravelSystem:canTravel(craftId, targetProvinceId)
       │ (check fuel, travel points, path exists)
       ▼
9. EXECUTE TRAVEL
   └─> TravelSystem:travel(craftId, targetProvinceId)
       │
       ├─> Deduct fuel from base stockpile
       ├─> Use 1 travel point on craft
       ├─> Update craft.provinceId = targetProvinceId
       ├─> Add craft to target province's craft list
       └─> Remove craft from old province's craft list
       │
       ▼
10. AUTO RADAR SCAN
    └─> RadarSystem:autoScanOnArrival(craftId)
        │ (detect missions in province + adjacent)
        ▼
11. DISPLAY RESULTS
    └─> Show detected missions in UI
        └─> User can now start interceptions
```

---

## Data Flow - End Turn

```
1. USER CLICKS "END TURN"
   │
   ▼
2. TurnProcessor:endTurn()
   │
   ├─> Calendar:advanceTurn()
   │   └─> day++, calculate week/month/year
   │
   ├─> DayNightCycle:update(turn)
   │   └─> Move day/night line 4 tiles
   │
   ├─> Reset Craft Travel Points
   │   └─> For each craft: craft.usedTravelPoints = 0
   │
   ├─> Process Missions
   │   ├─> Spawn new missions (region-based)
   │   └─> Expire old missions
   │
   ├─> Monthly Trigger (if day == 1 of month)
   │   ├─> Update Country Funding
   │   │   └─> For each country:
   │   │       funding = base × (1 + relations × 0.5) × (score / 100)
   │   └─> Process Economy Updates
   │       └─> Update province GDPs, country economies
   │
   ├─> Region Events
   │   └─> Trigger region-specific events (UFO scripts, etc.)
   │
   └─> Save Game State
       └─> Serialize world, calendar, crafts, bases
   │
   ▼
3. DISPLAY UPDATED UI
   └─> Refresh calendar widget, day/night overlay, country panel
```

---

## File Structure Summary

```
engine/geoscape/
├── init.lua                      -- Geoscape state (load/update/draw)
│
├── logic/                        -- Core entities
│   ├── universe.lua              -- Multi-world manager
│   ├── world.lua                 -- 80×40 hex world
│   ├── province.lua              -- Province node
│   ├── province_graph.lua        -- Graph with A* pathfinding
│   ├── craft.lua                 -- Craft entity
│   ├── base.lua                  -- Base entity
│   ├── country.lua               -- Political entity
│   ├── region.lua                -- Geographic grouping
│   ├── biome.lua                 -- Biome definitions
│   ├── portal.lua                -- Inter-world portal
│   └── pathfinding.lua           -- A* on hex grid
│
├── systems/                      -- Game systems
│   ├── hex_grid.lua              -- Hex coordinate math
│   ├── calendar.lua              -- Turn-based time
│   ├── daynight_cycle.lua        -- Day/night movement
│   ├── travel_system.lua         -- Craft movement
│   ├── radar_system.lua          -- Mission detection
│   ├── base_construction.lua     -- Base building
│   ├── craft_return.lua          -- Auto-return after interception
│   └── turn_processor.lua        -- End turn logic
│
├── rendering/                    -- Rendering layer
│   ├── world_renderer.lua        -- Hex grid + provinces
│   └── daynight_overlay.lua      -- Dark shader on night side
│
├── ui/                           -- UI widgets
│   ├── world_map.lua             -- Interactive map
│   ├── province_panel.lua        -- Province info display
│   ├── craft_selector.lua        -- Craft list UI
│   ├── range_highlighter.lua     -- Operational range display
│   ├── calendar_widget.lua       -- Date + end turn button
│   └── country_relations_panel.lua -- Country list + funding
│
└── tests/                        -- Test suite
    ├── test_hex_grid.lua
    ├── test_calendar.lua
    ├── test_travel_system.lua
    ├── test_country.lua
    └── test_geoscape_integration.lua
```

---

## Data Files

```
engine/data/
├── worlds/
│   ├── earth.toml                -- Earth world definition
│   ├── earth_provinces.toml      -- Province graph
│   ├── mars.toml                 -- Mars world (future)
│   └── mars_provinces.toml
│
├── countries.toml                -- Country definitions
├── regions.toml                  -- Region definitions
├── biomes.toml                   -- Biome configurations
├── crafts.toml                   -- Craft type definitions
├── bases.toml                    -- Base type definitions
├── portals.toml                  -- Inter-world portals
└── universe.toml                 -- Universe configuration
```

---

**Full Task Document:** [TASK-025-geoscape-master-implementation.md](TASK-025-geoscape-master-implementation.md)  
**Quick Reference:** [GEOSCAPE-QUICK-REFERENCE.md](GEOSCAPE-QUICK-REFERENCE.md)
