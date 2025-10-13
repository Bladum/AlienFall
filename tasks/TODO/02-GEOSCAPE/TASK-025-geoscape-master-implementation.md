# Task: Geoscape Master Implementation - Strategic World Management System

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Complete implementation of the Geoscape strategic layer - a comprehensive world management system that handles:
- **Universe**: Multi-world management and inter-world travel via portals
- **World**: 80×40 hex tile map (1 tile = 500km), province graph, day/night cycle
- **Provinces**: Node-based strategic locations with biomes, economy, bases, crafts, missions
- **Regions**: Geographical grouping for missions, scoring, and marketplace access
- **Countries**: Political entities with funding, relations, and economies
- **Travel**: Craft movement via hex pathfinding with fuel costs
- **Calendar**: 1 turn = 1 day, 30 days/month, 360 days/year turn-based system
- **Bases & Crafts**: Player operations and craft deployment

This is the **strategic layer** connecting all game modes (Basescape, Interception, Battlescape).

---

## Purpose

The Geoscape is the **heart of the strategic gameplay**, providing:
1. **Global Strategy**: World-level decisions, resource allocation, territory control
2. **Mission System**: Detection, deployment, and interception mechanics
3. **Economic Layer**: Country funding, province economies, player income
4. **Political System**: Country relations, diplomacy, regional influence
5. **Operational Range**: Hex-based travel system for craft deployment
6. **Time Progression**: Turn-based calendar driving all game events
7. **Multi-World**: Support for Earth and other planetary bodies

Without this, the game has no strategic framework connecting tactical battles to long-term progression.

---

## Requirements

### Functional Requirements

#### Core Systems
- [ ] **Universe**: Manage multiple worlds with portal travel between them
- [ ] **World**: 80×40 hex grid map with 500km/tile scale
- [ ] **Province Graph**: Node-based province system with pathfinding
- [ ] **Hex Pathfinding**: A* on hex grid for craft travel range calculation
- [ ] **Day/Night Cycle**: 50/50 coverage, moves 4 tiles/day (20-day full cycle)
- [ ] **Calendar**: Turn-based time (1 turn = 1 day, 360 days/year)

#### Geographic & Political
- [ ] **Provinces**: Land/water biomes, economy, bases, crafts, missions
- [ ] **Regions**: Grouping for missions, scoring, marketplace availability
- [ ] **Countries**: Owners of provinces, provide funding based on performance
- [ ] **Relations**: -2 to +2 scale affecting funding and hostility
- [ ] **Biomes**: Define interception backgrounds and battlescape terrain

#### Craft & Travel
- [ ] **Craft Management**: Position tracking, fuel, travel points, operational range
- [ ] **Travel System**: Move crafts between provinces with fuel/travel point costs
- [ ] **Radar Coverage**: Auto-scan for missions when craft enters province
- [ ] **Auto-Return**: Crafts return to base after interception phase

#### Base Operations
- [ ] **Base Placement**: One base per province, cost depends on country/biome/region
- [ ] **Fuel Management**: Base fuel stockpile for craft operations

#### Mission System
- [ ] **Mission Detection**: Radar scans reveal missions in provinces
- [ ] **Mission Deployment**: Send crafts to provinces for interceptions

### Technical Requirements
- [ ] **Hex Grid Math**: Proper hex calculations (axial or cube coordinates)
- [ ] **Graph Data Structure**: Province adjacency list with weighted edges
- [ ] **Pathfinding**: Efficient A* for hex grid with terrain costs (1-3 land, 1 water)
- [ ] **State Management**: Geoscape as a state in `core/state_manager.lua`
- [ ] **Data-Driven**: World data in TOML/JSON (provinces, countries, regions, portals)
- [ ] **Performance**: Handle 100+ provinces, 50+ countries, 20+ crafts
- [ ] **Serialization**: Save/load world state, calendar, craft positions

### Acceptance Criteria
- [ ] User can see 80×40 hex world map with provinces displayed
- [ ] Day/night cycle visually moves 4 tiles per day
- [ ] User can select base → craft → see operational range → deploy to province
- [ ] Craft travels cost fuel from base stockpile
- [ ] Radar automatically detects missions in province when craft arrives
- [ ] Calendar advances 1 day per turn (6 days/week, 30 days/month, 360 days/year)
- [ ] Country relations affect funding based on performance in their provinces
- [ ] Multiple worlds accessible via portal system
- [ ] Province graph pathfinding respects land/water terrain types
- [ ] UI shows: world map, province info, craft status, calendar, country relations

---

## Plan

### Phase 1: Core Data Structures & World Grid (18 hours)

#### Step 1.1: Hex Grid System (6 hours)
**Description:** Implement hex coordinate system and grid utilities  
**Files to create:**
- `engine/geoscape/systems/hex_grid.lua`
- `engine/geoscape/tests/test_hex_grid.lua`

**Implementation:**
- Axial coordinate system (q, r)
- Cube coordinate conversion for distance calculations
- Neighbor finding (6 directions)
- Distance calculation (Manhattan on cube coordinates)
- Pixel-to-hex and hex-to-pixel conversion
- Ring/area finding (all hexes within N tiles)

**Key Functions:**
```lua
HexGrid.new(width, height) -- 80×40 grid
HexGrid:toPixel(q, r) -- Hex to screen coordinates
HexGrid:toHex(x, y) -- Screen to hex coordinates
HexGrid:distance(q1, r1, q2, r2) -- Hex distance
HexGrid:neighbors(q, r) -- 6 adjacent hexes
HexGrid:ring(q, r, radius) -- Hexes at exact distance
HexGrid:area(q, r, radius) -- All hexes within distance
```

**Estimated time:** 6 hours

---

#### Step 1.2: World Data Structure (4 hours)
**Description:** Create world entity with provinces, tile grid, background  
**Files to create:**
- `engine/geoscape/logic/world.lua`
- `engine/data/worlds/earth.toml`

**Implementation:**
```lua
World = {
    id = "earth",
    name = "Earth",
    width = 80,  -- tiles
    height = 40, -- tiles
    tileSize = 10, -- pixels
    scale = 500, -- km per tile
    backgroundImage = "assets/images/geoscape/earth_map.png",
    dayNightCycle = {
        speed = 4, -- tiles per day
        coverage = 0.5 -- 50% day, 50% night
    },
    provinces = {}, -- List of provinces
    tiles = {}, -- 80×40 grid: {terrain, cost, isLand, isWater}
    portals = {} -- Inter-world portals
}
```

**Data File Structure (earth.toml):**
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

[[tiles]]
# 80×40 tile definitions
q = 0
r = 0
terrain = "grassland"
cost = 1
isLand = true
```

**Estimated time:** 4 hours

---

#### Step 1.3: Province & Graph System (8 hours)
**Description:** Province node system with adjacency graph  
**Files to create:**
- `engine/geoscape/logic/province.lua`
- `engine/geoscape/logic/province_graph.lua`
- `engine/data/worlds/earth_provinces.toml`

**Province Structure:**
```lua
Province = {
    id = "province_001",
    name = "Central Europe",
    position = {q = 40, r = 20}, -- Hex coordinates
    biomeId = "temperate_forest",
    countryId = "germany",
    regionId = "central_europe",
    isLand = true,
    economy = {
        gdp = 1000000,
        population = 5000000
    },
    connections = {}, -- Adjacent province IDs
    playerBase = nil, -- Base object or nil
    crafts = {}, -- List of craft IDs (max 4)
    missions = {}, -- List of active missions
    cities = {"Berlin", "Munich", "Hamburg"}
}
```

**Graph Operations:**
```lua
ProvinceGraph:addProvince(province)
ProvinceGraph:addConnection(provinceId1, provinceId2, cost)
ProvinceGraph:getNeighbors(provinceId) -- Adjacent provinces
ProvinceGraph:findPath(fromId, toId, craftType) -- A* pathfinding
ProvinceGraph:getRange(fromId, maxCost, craftType) -- Operational range
```

**Estimated time:** 8 hours

---

### Phase 2: Calendar & Time System (10 hours)

#### Step 2.1: Calendar Implementation (6 hours)
**Description:** Turn-based calendar with day/week/month/year tracking  
**Files to create:**
- `engine/geoscape/systems/calendar.lua`
- `engine/geoscape/tests/test_calendar.lua`

**Implementation:**
```lua
Calendar = {
    turn = 0,
    day = 1,
    week = 1,
    month = 1,
    quarter = 1,
    year = 1
}

Calendar:advanceTurn() -- +1 day
Calendar:getDate() -- "Year 1, Q2, Month 5, Week 3, Day 4"
Calendar:getDayOfWeek() -- 1-6
Calendar:getDayOfMonth() -- 1-30
Calendar:getDayOfYear() -- 1-360
```

**Rules:**
- 1 turn = 1 day
- 6 days = 1 week
- 5 weeks = 1 month (30 days)
- 3 months = 1 quarter (90 days)
- 4 quarters = 1 year (360 days)

**Estimated time:** 6 hours

---

#### Step 2.2: Day/Night Cycle (4 hours)
**Description:** Visual day/night overlay moving across world map  
**Files to create:**
- `engine/geoscape/systems/daynight_cycle.lua`
- `engine/geoscape/rendering/daynight_overlay.lua`

**Implementation:**
- Track day/night line position (moves 4 tiles/day)
- 50% of map is day, 50% is night
- Full cycle = 20 days (80 tiles / 4 tiles per day)
- Render dark overlay on night side
- Calculate if province is in day or night
- Affects mission visibility/difficulty (optional)

**Estimated time:** 4 hours

---

### Phase 3: Geographic & Political Systems (16 hours)

#### Step 3.1: Biome System (4 hours)
**Description:** Biome definitions for provinces  
**Files to create:**
- `engine/geoscape/logic/biome.lua`
- `engine/data/biomes.toml`

**Biome Structure:**
```toml
[[biome]]
id = "temperate_forest"
name = "Temperate Forest"
interceptionBackground = "forest_interception.png"
terrainTypes = ["forest", "plains", "urban", "industrial"]
baseConstructionCost = 1000000
```

**Purpose:**
- Define interception background image
- List available battlescape terrains
- Affect base construction costs
- Terrain-specific mission generation

**Estimated time:** 4 hours

---

#### Step 3.2: Country System (6 hours)
**Description:** Political entities with relations, funding, economy  
**Files to create:**
- `engine/geoscape/logic/country.lua`
- `engine/data/countries.toml`

**Country Structure:**
```lua
Country = {
    id = "germany",
    name = "Germany",
    flag = "flags/germany.png",
    provinceIds = {}, -- Owned provinces
    economy = 0, -- Sum of province GDPs
    relations = 0, -- -2 to +2
    funding = 50000, -- Monthly funding to player
    score = 0 -- Performance score in their territory
}
```

**Relations System:**
- Score based on missions completed in country's provinces
- Relations: -2 (hostile), -1 (unfriendly), 0 (neutral), +1 (friendly), +2 (allied)
- Better relations → higher funding
- Hostile countries may generate enemy missions

**Funding Formula:**
```lua
funding = baseFunding * (1 + relations * 0.5) * (score / 100)
```

**Estimated time:** 6 hours

---

#### Step 3.3: Region System (6 hours)
**Description:** Geographical grouping for missions and scoring  
**Files to create:**
- `engine/geoscape/logic/region.lua`
- `engine/data/regions.toml`

**Region Structure:**
```lua
Region = {
    id = "central_europe",
    name = "Central Europe",
    provinceIds = {}, -- Provinces in region
    score = 0, -- Accumulated score
    fame = 0, -- Regional reputation
    marketplaceAccess = true -- Special marketplace options
}
```

**Purpose:**
- Group provinces for mission scripting (UFO scripts target regions)
- Accumulate regional score/fame
- Control marketplace availability
- Regional-specific events/missions

**Estimated time:** 6 hours

---

### Phase 4: Craft & Travel System (20 hours)

#### Step 4.1: Craft Data Structure (4 hours)
**Description:** Craft entity with stats, position, fuel  
**Files to create:**
- `engine/geoscape/logic/craft.lua`
- `engine/data/crafts.toml`

**Craft Structure:**
```lua
Craft = {
    id = "craft_001",
    typeId = "interceptor",
    name = "Raven-1",
    baseId = "base_alpha",
    provinceId = "province_042",
    fuel = 100, -- Current fuel
    maxFuel = 100,
    travelPoints = 3, -- Travels per turn
    usedTravelPoints = 0,
    craftType = "air", -- "land", "air", "water"
    speed = 5, -- Max hex range per travel
    radarRange = 10 -- Mission detection range
}
```

**Craft Types:**
- **Land**: Limited to land paths, cost 1-3 per tile
- **Air**: Can cross water, ignores terrain cost
- **Water**: Limited to water paths, cost 1 per tile

**Estimated time:** 4 hours

---

#### Step 4.2: Travel System & Pathfinding (8 hours)
**Description:** Craft movement with hex A* pathfinding  
**Files to create:**
- `engine/geoscape/systems/travel_system.lua`
- `engine/geoscape/logic/pathfinding.lua`
- `engine/geoscape/tests/test_travel_system.lua`

**Implementation:**
```lua
TravelSystem:canTravel(craftId, targetProvinceId) -- Check range, fuel, travel points
TravelSystem:getOperationalRange(craftId) -- All reachable provinces
TravelSystem:calculatePath(craftId, targetProvinceId) -- Hex path
TravelSystem:travel(craftId, targetProvinceId) -- Execute travel
```

**Pathfinding:**
- A* on hex grid with terrain costs
- Respect craft type (land/air/water restrictions)
- Calculate fuel cost based on distance
- Travel points limit travels per turn

**Cost Calculation:**
```lua
fuelCost = distance * fuelPerHex
travelPointCost = 1 -- One travel point per journey
```

**Estimated time:** 8 hours

---

#### Step 4.3: Radar & Mission Detection (4 hours)
**Description:** Automatic mission scanning when craft enters province  
**Files to create:**
- `engine/geoscape/systems/radar_system.lua`

**Implementation:**
```lua
RadarSystem:scan(craftId) -- Scan province for missions
RadarSystem:getDetectedMissions(provinceId) -- List missions
RadarSystem:autoScanOnArrival(craftId) -- Triggered by travel
```

**Radar Mechanics:**
- Each craft has radarRange (default 10 hexes)
- Scans own province + adjacent provinces within range
- Reveals missions in scanned provinces
- Better radar = more mission details revealed

**Estimated time:** 4 hours

---

#### Step 4.4: Auto-Return System (4 hours)
**Description:** Crafts automatically return to base after interception phase  
**Files to create:**
- `engine/geoscape/systems/craft_return.lua`

**Implementation:**
```lua
CraftReturn:endInterceptionPhase() -- Return all deployed crafts
CraftReturn:returnCraft(craftId) -- Move craft to base province
CraftReturn:refuel(craftId) -- Refuel at base
```

**Mechanics:**
- Triggered after user completes all interceptions
- Crafts move to their base's province
- Refuel from base stockpile
- Reset travelPoints for next turn

**Estimated time:** 4 hours

---

### Phase 5: Base Management (10 hours)

#### Step 5.1: Base Data Structure (4 hours)
**Description:** Base entity with facilities, storage, crafts  
**Files to create:**
- `engine/geoscape/logic/base.lua`
- `engine/data/bases.toml`

**Base Structure:**
```lua
Base = {
    id = "base_alpha",
    name = "Alpha Base",
    provinceId = "province_042",
    countryId = "usa",
    constructionCost = 2000000,
    fuel = 500, -- Fuel stockpile
    maxFuel = 1000,
    crafts = {}, -- List of craft IDs stationed here
    facilities = {} -- Base facilities (future)
}
```

**Estimated time:** 4 hours

---

#### Step 5.2: Base Construction System (6 hours)
**Description:** Build new bases with cost modifiers  
**Files to create:**
- `engine/geoscape/systems/base_construction.lua`

**Implementation:**
```lua
BaseConstruction:canBuild(provinceId) -- Check if province available
BaseConstruction:getCost(provinceId) -- Calculate cost (biome, country, region)
BaseConstruction:build(provinceId, name) -- Create base
```

**Cost Modifiers:**
- **Biome**: Desert +0%, Forest +20%, Arctic +50%
- **Country Relations**: Hostile +100%, Neutral +0%, Allied -25%
- **Region**: Strategic regions +30%

**Restrictions:**
- One base per province
- Must have permission from country (relations ≥ -1)

**Estimated time:** 6 hours

---

### Phase 6: Universe & Portal System (12 hours)

#### Step 6.1: Universe Manager (6 hours)
**Description:** Multi-world container and portal travel  
**Files to create:**
- `engine/geoscape/logic/universe.lua`
- `engine/data/universe.toml`

**Universe Structure:**
```lua
Universe = {
    worlds = {}, -- world_id → World object
    currentWorldId = "earth",
    portals = {} -- List of inter-world portals
}

Universe:addWorld(world)
Universe:getWorld(worldId)
Universe:switchWorld(worldId) -- Change active world
Universe:canTravel(craftId, portalId) -- Check portal access
```

**Estimated time:** 6 hours

---

#### Step 6.2: Portal System (6 hours)
**Description:** Inter-world travel connections  
**Files to create:**
- `engine/geoscape/logic/portal.lua`
- `engine/data/portals.toml`

**Portal Structure:**
```lua
Portal = {
    id = "earth_mars_portal",
    name = "Mars Gateway",
    fromWorldId = "earth",
    fromProvinceId = "province_polar_01",
    toWorldId = "mars",
    toProvinceId = "mars_landing_zone",
    travelCost = 100, -- Fuel cost
    accessible = false -- Unlocked via research
}
```

**Portal Travel:**
- Portals connect provinces across different worlds
- High fuel cost for inter-world travel
- May require research/technology to unlock
- One-way or two-way connections

**Estimated time:** 6 hours

---

### Phase 7: UI Implementation (30 hours)

#### Step 7.1: World Map Renderer (10 hours)
**Description:** Render 80×40 hex world map with provinces  
**Files to create:**
- `engine/geoscape/rendering/world_renderer.lua`
- `engine/geoscape/ui/world_map.lua`

**Features:**
- Hex grid rendering (outline mode or filled)
- Province highlighting (selected, hovered)
- Day/night overlay
- Craft icons at province positions
- Mission indicators
- Base icons
- Province names on hover

**Grid Snapping:** All UI elements must snap to 24×24 pixel grid

**Estimated time:** 10 hours

---

#### Step 7.2: Province Info Panel (6 hours)
**Description:** Selected province details widget  
**Files to create:**
- `engine/geoscape/ui/province_panel.lua`

**Display:**
- Province name, country, region
- Biome type
- Missions in province (count and types)
- Crafts in province
- Player base (if present)
- Cities list

**Grid Snapping:** Panel size and position must be multiples of 24 pixels

**Estimated time:** 6 hours

---

#### Step 7.3: Craft Deployment UI (8 hours)
**Description:** Select base → craft → target province flow  
**Files to create:**
- `engine/geoscape/ui/craft_selector.lua`
- `engine/geoscape/ui/range_highlighter.lua`

**Flow:**
1. User clicks base → Shows craft list
2. User selects craft → Shows operational range (highlighted provinces)
3. User clicks target province → Confirms travel
4. System executes travel, deducts fuel

**Highlighting:**
- Green: Reachable provinces
- Yellow: At edge of range
- Red: Out of range

**Grid Snapping:** All UI elements must snap to 24×24 pixel grid

**Estimated time:** 8 hours

---

#### Step 7.4: Calendar & Country Panel (6 hours)
**Description:** Display time, country relations, funding  
**Files to create:**
- `engine/geoscape/ui/calendar_widget.lua`
- `engine/geoscape/ui/country_relations_panel.lua`

**Calendar Widget:**
- Current date display
- "End Turn" button
- Turn counter

**Country Panel:**
- List of major countries
- Relations (-2 to +2) with color coding
- Funding amount per month
- Score in their territory

**Grid Snapping:** All widgets must snap to 24×24 pixel grid

**Estimated time:** 6 hours

---

### Phase 8: Integration & Polish (14 hours)

#### Step 8.1: State Manager Integration (4 hours)
**Description:** Add Geoscape as a state in game  
**Files to modify:**
- `engine/core/state_manager.lua`
- `engine/geoscape/init.lua`

**Implementation:**
```lua
-- In geoscape/init.lua
local Geoscape = {}

function Geoscape:load()
    -- Initialize world, calendar, crafts, bases
end

function Geoscape:update(dt)
    -- Update day/night cycle
end

function Geoscape:draw()
    -- Render world map, UI
end

function Geoscape:endTurn()
    -- Advance calendar, update countries, process events
end

return Geoscape
```

**Estimated time:** 4 hours

---

#### Step 8.2: Turn Processing (6 hours)
**Description:** End turn logic for all systems  
**Files to create:**
- `engine/geoscape/systems/turn_processor.lua`

**Turn Processing Order:**
1. Advance calendar (+1 day)
2. Update day/night cycle
3. Reset craft travel points
4. Process missions (spawning, expiration)
5. Update country funding (monthly)
6. Process economy
7. Trigger region events
8. Save game state

**Estimated time:** 6 hours

---

#### Step 8.3: Testing & Debugging (4 hours)
**Description:** Comprehensive testing with Love2D console  
**Files to create:**
- `engine/geoscape/tests/test_geoscape_integration.lua`

**Test Cases:**
- World map renders correctly
- Craft travel with pathfinding
- Fuel deduction from base stockpile
- Calendar advances properly
- Country relations update based on score
- Day/night cycle visual movement
- Portal travel between worlds
- Mission detection via radar

**Run with:** `lovec "engine"` (console enabled)

**Estimated time:** 4 hours

---

### Phase 9: Documentation (10 hours)

#### Step 9.1: API Documentation (4 hours)
**Files to update:**
- `wiki/API.md`

**Document:**
- Universe, World, Province, Country, Region, Biome
- Craft, Base, Portal
- HexGrid, Calendar, TravelSystem, RadarSystem
- All public functions with parameters and return values

**Estimated time:** 4 hours

---

#### Step 9.2: FAQ & Development Guide (4 hours)
**Files to update:**
- `wiki/FAQ.md`
- `wiki/DEVELOPMENT.md`

**FAQ Additions:**
- "How does the Geoscape work?"
- "How do I deploy crafts?"
- "What is the calendar system?"
- "How do country relations affect gameplay?"

**Development Guide:**
- Adding new worlds
- Creating province maps
- Defining biomes and terrains
- Configuring portals

**Estimated time:** 4 hours

---

#### Step 9.3: User Guide (2 hours)
**Files to create:**
- `wiki/GEOSCAPE_GUIDE.md`

**Contents:**
- Overview of Geoscape layer
- How to read the world map
- Deploying crafts for missions
- Managing bases
- Understanding country relations
- Calendar and turn progression

**Estimated time:** 2 hours

---

## Total Time Estimate

| Phase | Hours |
|-------|-------|
| Phase 1: Core Data Structures & World Grid | 18h |
| Phase 2: Calendar & Time System | 10h |
| Phase 3: Geographic & Political Systems | 16h |
| Phase 4: Craft & Travel System | 20h |
| Phase 5: Base Management | 10h |
| Phase 6: Universe & Portal System | 12h |
| Phase 7: UI Implementation | 30h |
| Phase 8: Integration & Polish | 14h |
| Phase 9: Documentation | 10h |
| **Total** | **140 hours** |

**Estimated Duration:** 17-18 days (8 hours/day) or 3.5-4 weeks

---

## Implementation Details

### Architecture

**Pattern:** Component-based with clear separation of concerns
- **Logic Layer**: World, Province, Craft, Base, Country entities
- **Systems Layer**: Travel, Radar, Calendar, TurnProcessor
- **Rendering Layer**: WorldRenderer, DayNightOverlay
- **UI Layer**: Panels, selectors, widgets (grid-snapped)
- **Data Layer**: TOML files for worlds, provinces, countries

**State Machine:**
- Geoscape is a top-level game state
- Sub-states: Normal, CraftSelection, TravelMode, EndTurn

**Data Flow:**
```
User Input → UI Widgets → Systems → Logic Entities → Data Storage
                ↑                                          ↓
                └──────────── State Changes ───────────────┘
```

### Key Components

#### 1. HexGrid System
- **Purpose:** Coordinate system and spatial calculations
- **Math:** Axial coordinates (q, r), cube for distance
- **Integration:** Used by World, Travel, Pathfinding

#### 2. Province Graph
- **Purpose:** Strategic node network
- **Structure:** Adjacency list with weighted edges
- **Pathfinding:** A* with terrain cost modifiers

#### 3. Calendar System
- **Purpose:** Turn-based time progression
- **Triggers:** End turn events, monthly funding, mission spawning
- **Display:** Date widget in UI

#### 4. Travel System
- **Purpose:** Craft movement between provinces
- **Dependencies:** HexGrid, Pathfinding, Fuel management
- **Restrictions:** TravelPoints, Fuel, CraftType

#### 5. Country/Region System
- **Purpose:** Political simulation and economy
- **Mechanics:** Relations affect funding, hostile countries spawn threats
- **Scoring:** Performance-based relation changes

#### 6. Universe Manager
- **Purpose:** Multi-world container
- **Features:** Portal travel, world switching
- **Scalability:** Support Earth, Mars, Moon, alien worlds

### Dependencies

**Internal:**
- `core/state_manager.lua` - State management
- `widgets/` - UI components (grid system)
- `shared/pathfinding.lua` - May need hex-specific variant

**External:**
- Love2D graphics for rendering
- Love2D input for mouse/keyboard
- TOML parser for data files

**Data Files:**
- `data/worlds/earth.toml` - World definition
- `data/worlds/earth_provinces.toml` - Province data
- `data/countries.toml` - Country definitions
- `data/regions.toml` - Region definitions
- `data/biomes.toml` - Biome configurations
- `data/crafts.toml` - Craft types
- `data/portals.toml` - Inter-world portals

---

## Testing Strategy

### Unit Tests

#### Hex Grid Tests (`test_hex_grid.lua`)
- Test distance calculation (multiple hex pairs)
- Test neighbor finding (center, edge, corner hexes)
- Test ring/area functions
- Test pixel-to-hex conversion accuracy

#### Calendar Tests (`test_calendar.lua`)
- Test turn advancement (day/week/month/year rollover)
- Test date formatting
- Test leap calculations (if any)

#### Pathfinding Tests (`test_travel_system.lua`)
- Test A* path finding on hex grid
- Test terrain cost modifiers
- Test craft type restrictions (land/air/water)
- Test operational range calculation

#### Country Relations Tests (`test_country.lua`)
- Test funding calculation based on relations
- Test score-based relation changes
- Test hostility threshold

### Integration Tests

#### World Loading Test
- Load earth.toml
- Verify 80×40 tile grid
- Verify all provinces loaded
- Verify province graph connectivity

#### Craft Deployment Test
- Select base → craft → target province
- Verify pathfinding calculates correct route
- Verify fuel deduction
- Verify craft moves to target

#### Calendar Integration Test
- Advance 30 turns (1 month)
- Verify monthly funding triggers
- Verify day/night cycle completes

#### Portal Travel Test
- Travel craft through portal
- Verify world switch
- Verify craft appears in target world

### Manual Testing Steps

1. **Run game:** `lovec "engine"`
2. **Navigate to Geoscape** from main menu
3. **Verify world map display:**
   - Check hex grid visible
   - Check provinces render
   - Check day/night overlay
4. **Test craft deployment:**
   - Click on base
   - Select craft
   - Verify range highlighting
   - Click target province
   - Verify craft moves
5. **Test calendar:**
   - Click "End Turn"
   - Verify date advances
   - Verify day/night moves 4 tiles
6. **Test mission detection:**
   - Deploy craft to province with mission
   - Verify radar scan auto-triggers
   - Verify mission appears in UI
7. **Test country relations:**
   - Complete missions in country's provinces
   - Verify score increases
   - Verify funding changes monthly
8. **Test portal travel:**
   - Move craft to portal province
   - Select portal destination
   - Verify world switches

### Expected Results

- ✅ World map renders at 960×720 (40 columns × 30 rows)
- ✅ All UI elements snap to 24×24 grid
- ✅ Hex pathfinding finds optimal routes
- ✅ Craft travel costs fuel from base
- ✅ Calendar advances correctly
- ✅ Day/night cycle visually moves
- ✅ Country relations affect funding
- ✅ Mission detection works on craft arrival
- ✅ Portal travel switches worlds
- ✅ No console errors or warnings

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: **"Run XCOM Simple Game"** (Ctrl+Shift+P > Run Task)

### Debugging

**Console Output:**
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print("[Geoscape] Debug message: " .. tostring(value))` for debugging
- Check console window for errors and debug messages

**On-Screen Debug:**
```lua
-- In geoscape/rendering/world_renderer.lua
love.graphics.print("Craft Position: " .. craftX .. ", " .. craftY, 10, 10)
love.graphics.print("Selected Province: " .. selectedProvinceId, 10, 30)
```

**Debug Keys:**
- **F9**: Toggle hex grid overlay (essential for development)
- **F12**: Toggle fullscreen
- **F1**: Show debug info (craft positions, provinces, calendar)

**Error Handling:**
```lua
local success, error = pcall(TravelSystem.travel, craftId, targetProvinceId)
if not success then
    print("[ERROR] Travel failed: " .. error)
end
```

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- Never create temp files in project directories

**Example:**
```lua
local tempDir = os.getenv("TEMP")
local savePath = tempDir .. "\\geoscape_save.dat"
```

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add Geoscape API documentation
- [x] `wiki/FAQ.md` - Add Geoscape FAQ section
- [x] `wiki/DEVELOPMENT.md` - Add Geoscape development workflow
- [ ] `wiki/GEOSCAPE_GUIDE.md` - Create user guide
- [ ] Code comments - Add inline documentation for all modules

### API Documentation Sections

**Add to `wiki/API.md`:**

```markdown
## Geoscape API

### Universe
- `Universe:addWorld(world)` - Add world to universe
- `Universe:getWorld(worldId)` - Get world by ID
- `Universe:switchWorld(worldId)` - Change active world

### World
- `World:getProvince(provinceId)` - Get province by ID
- `World:getTile(q, r)` - Get tile at hex coordinates
- `World:getDayNightCoverage()` - Get current day/night split

### Province
- `Province:addCraft(craftId)` - Add craft to province
- `Province:removeCraft(craftId)` - Remove craft
- `Province:getMissions()` - Get active missions
- `Province:hasBase()` - Check if player has base

### HexGrid
- `HexGrid:distance(q1, r1, q2, r2)` - Calculate hex distance
- `HexGrid:neighbors(q, r)` - Get 6 adjacent hexes
- `HexGrid:toPixel(q, r)` - Convert hex to screen coordinates

### TravelSystem
- `TravelSystem:getOperationalRange(craftId)` - Get reachable provinces
- `TravelSystem:travel(craftId, targetProvinceId)` - Move craft
- `TravelSystem:calculateFuelCost(craftId, targetProvinceId)` - Get fuel cost

### Calendar
- `Calendar:advanceTurn()` - Advance 1 day
- `Calendar:getDate()` - Get formatted date string
- `Calendar:getDayOfYear()` - Get day number (1-360)

### Country
- `Country:updateRelations(scoreDelta)` - Change relations
- `Country:calculateFunding()` - Get monthly funding amount
- `Country:isHostile()` - Check if relations < -1
```

---

## Notes

### Design Decisions

1. **Hex Grid vs Square Grid:**
   - Hex chosen for more realistic movement ranges
   - Better for strategic pathfinding (6 neighbors vs 8)
   - More organic province shapes

2. **Turn-Based vs Real-Time:**
   - Turn-based ensures player control
   - Aligns with X-COM design philosophy
   - 1 turn = 1 day keeps pace manageable

3. **Province Graph vs Continuous Map:**
   - Graph simplifies pathfinding and data structure
   - Easier to balance operational ranges
   - Clearer for player to understand strategic zones

4. **Calendar System:**
   - 360-day year (divisible by 30, 90, 120) simplifies calculations
   - 6-day week keeps weeks short
   - 30-day month aligns with real-world approximation

5. **Multi-World Support:**
   - Extensibility for Mars, Moon, alien worlds
   - Portals add strategic depth (unlock via research)
   - Each world can have unique day/night cycles

### Performance Considerations

- **Province Count:** ~100-200 provinces for Earth (manageable)
- **Pathfinding:** Cache operational ranges, only recalculate on craft stat changes
- **Rendering:** Render only visible hexes (viewport culling)
- **Day/Night:** Pre-calculate affected hexes per turn, not per frame

### Future Enhancements

- **Weather System:** Storms, fog affecting missions
- **Political Events:** Coups, wars, alliances changing province ownership
- **Trade Routes:** Economy simulation between provinces
- **Alien Activity:** UFO bases in provinces, escalating threat
- **Dynamic Biomes:** Terraforming, climate change over years
- **Multi-Base Operations:** Coordinate multiple bases strategically

---

## Blockers

### Prerequisites
- **Widget System:** Must be stable (Phase 7 depends on it)
- **State Manager:** Must support Geoscape state
- **Data Loader:** Must parse TOML files

### External Dependencies
- **Province Data:** Need Earth province definitions (can start with subset)
- **Art Assets:** World map background image (800×400 pixels)
- **Country Flags:** Flag images for countries

### Technical Risks
- **Hex Pathfinding Performance:** May need optimization for 100+ provinces
- **UI Complexity:** Craft selection flow must be intuitive
- **Data Volume:** Large world data files may need compression

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] All UI elements snap to 24×24 pixel grid
- [ ] Hex grid math verified with unit tests
- [ ] Pathfinding handles edge cases (unreachable, no fuel)
- [ ] Calendar calculations tested (day/week/month/year rollover)
- [ ] Country relations system balanced
- [ ] Travel system deducts fuel correctly
- [ ] Radar detection triggers automatically
- [ ] Day/night cycle visually correct
- [ ] Portal system works between worlds
- [ ] All systems use `print()` for debug output
- [ ] No temporary files in project directories (use `os.getenv("TEMP")`)
- [ ] API documentation complete
- [ ] FAQ updated with Geoscape info
- [ ] User guide created
- [ ] All tests pass
- [ ] No console errors or warnings when running with `lovec "engine"`

---

## What Worked Well

*(To be filled after completion)*

---

## Lessons Learned

*(To be filled after completion)*

---

## Additional Resources

- **Hex Grid Math:** https://www.redblobgames.com/grids/hexagons/
- **A* Pathfinding:** https://www.redblobgames.com/pathfinding/a-star/
- **X-COM Geoscape:** https://www.ufopaedia.org/index.php/Geoscape
- **Turn-Based Strategy Patterns:** Various GDC talks on XCOM, Civilization design

---

**End of Task Document**
