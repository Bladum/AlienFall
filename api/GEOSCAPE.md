# Geoscape API Reference

**System:** Strategic Layer (Global Strategy / World Management)  
**Module:** `engine/geoscape/`  
**Latest Update:** 2025-10-27  
**Status:** ✅ Core Complete | ⚠️ Some features in progress

---

## 📋 Scope & Related Systems

**This API covers:**
- World structure (hexagonal grid, provinces, regions)
- Map rendering and visualization
- Time progression (calendar, day/night cycles)
- Craft movement and travel systems
- Mission deployment mechanics
- Radar detection systems
- Supply line management

**For related systems, see:**
- **[COUNTRIES.md](COUNTRIES.md)** - Country entities, diplomatic relations, funding, panic mechanics
- **[MISSIONS.md](MISSIONS.md)** - Mission generation, objectives, and types
- **[CRAFTS.md](CRAFTS.md)** - Craft specifications and interception
- **[INTERCEPTION.md](INTERCEPTION.md)** - Air combat and UFO engagement
- **[POLITICS.md](POLITICS.md)** - Faction relations and diplomatic events

---

## Overview

The Geoscape system manages the global strategic layer where players control world operations, craft deployment, mission detection, and geographic management. It organizes the game world as hexagonal grid provinces, handles turn-based calendar progression, manages craft travel, and coordinates with all other systems for mission generation and threat assessment.

**Key Responsibilities:**
- World definition and management with hexagonal grid system
- Province creation and tracking (90×45 grid on Earth)
- Hexagonal coordinate system for precise positioning
- Calendar and time progression (1 turn = 1 day)
- Day/night cycle management and visibility
- Biome classification and terrain mechanics
- Geographic regions and regional grouping
- Radar coverage detection and mission detection
- Universe management for multi-world connectivity
- Craft travel and interception routing
- Supply line management between bases
- Map rendering with multiple display modes

**Integration Points:**
- **Countries** (via [COUNTRIES.md](COUNTRIES.md)): Territory ownership, country funding
- **Basescape**: Base locations, facility management, craft inventory
- **Battlescape**: Mission generation, mission parameters, squad deployment  
- **Interception**: Craft combat, UFO tracking
- **Politics**: Territory control, diplomatic events
- **Economy**: Resource availability by province, trade agreements
- **Calendar**: Time progression and turn advancement
- **Analytics**: Strategic metrics and intelligence reporting

---

## Implementation Status

### IN DESIGN (Exists in engine/geoscape/)
- World management with hexagonal grid provinces and regions
- Province system with ownership, biomes, and threat levels
- Hexagonal coordinate system for precise positioning
- Calendar and time progression (turns = days)
- Day/night cycle affecting visibility and mission mechanics
- Craft travel and deployment system
- Mission generation and tracking
- Radar coverage detection system
- UFO registry and threat assessment
- Supply line management between bases
- World renderer with multiple display modes
- Travel system for craft routing and movement
- Biome system with terrain properties

### FUTURE IDEAS (Not in engine/geoscape/)
- Multi-world connectivity with portals
- Dynamic province ownership changes
- Advanced weather systems
- Real-time craft movement animations
- Satellite network for enhanced detection
- Orbital mechanics for space-based assets
- Dynamic population migration
- Environmental disasters and events
- Advanced AI for UFO behavior patterns
- Networked multiplayer geoscape synchronization

---

## Architecture

### System Components

1. **Universe Manager** - Handles multi-world connectivity and portals
2. **World Manager** - Manages individual world grids and provinces
3. **Province System** - Individual territorial units with ownership and missions
4. **Region System** - Geographic groupings of provinces
5. **Hexagonal Grid System** - Coordinate management and pathfinding
6. **Calendar System** - Time progression and temporal tracking
7. **Day/Night Cycle** - Visual and mechanical lighting
8. **Craft System** - Spacecraft deployment and movement
9. **Mission System** - Mission generation and tracking
10. **Radar Coverage System** - Detection capability and coverage zones
11. **UFO Registry & Tracking** - Alien activity and threat assessment
12. **Supply Line Manager** - Inter-base logistics
13. **World Renderer** - Map visualization and display modes
14. **Travel System** - Craft routing and movement calculation
15. **Biome System** - Environmental properties and terrain types

### Data Flow Diagram

```
┌──────────────────────────────────────────────────────────┐
│           GEOSCAPE SYSTEM ARCHITECTURE                   │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  Universe ──┐                                             │
│  Worlds ────├──> World Manager ──> Map Display          │
│  Portals ───┤                                             │
│             └──> Portal System ──> Inter-World Travel    │
│                                                           │
│  Provinces ──> Province System ──> Territory Display    │
│  Regions ───> Region Manager ──> Regional Status       │
│  Biomes ────> Biome System ──> Terrain Properties      │
│                                                           │
│  Hexagons ──> HexCoordinate ──> Path Calculation       │
│  Paths ─────> Travel System ──> Route Optimization     │
│                                                           │
│  Calendar ──> Time Progression ──> Turn Advancement    │
│  DayNight ──> Cycle Calculation ──> Visibility Range   │
│                                                           │
│  Crafts ────> Craft System ──> Deployment & Movement   │
│  Missions ──> Mission System ──> Generation & Tracking │
│  Bases ─────> Base Integration ──> Facility Effects    │
│                                                           │
│  Radar ─────> Detection Engine ──> Coverage Zones      │
│  UFOs ──────> Tracking System ──> Threat Analysis      │
│  Regions ───> Logistics Mgr ──> Supply Lines           │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

---

## Core Entities

### Entity: Universe

Container for all worlds and inter-world connectivity. Manages multiple independent worlds operating simultaneously.

**Properties:**
```lua
Universe = {
  id = string,                    -- "universe_main"
  worlds = World[],               -- All active worlds
  portals = Portal[],             -- Inter-world connection points
  
  -- Time Management
  calendar = Calendar,            -- Synchronized calendar across worlds
  current_turn = number,          -- Global turn counter
  
  -- Status
  is_initialized = boolean,       -- Initialization flag
}
```

**Functions:**
```lua
-- Creation and retrieval
Universe.create() → Universe
Universe.addWorld(world: World) → void
Universe.getWorld(world_id: string) → World | nil
Universe.getAllWorlds() → World[]
Universe.getWorldList() → table  -- Array of world IDs
Universe.getActiveWorlds() → table  -- Worlds with ongoing operations
Universe.getPortals() → Portal[]

-- Time management
universe:nextTurn() → void
universe:getCurrentTurn() → number
universe:getDate() → Date (year, month, day)

-- Multi-world queries
Universe.getWorldDistance(worldId1, worldId2) → number
Universe.switchWorld(worldId) → boolean
```

**Integration:**
- Inputs from: Calendar system (time updates)
- Outputs to: All world systems (turn processing)
- Dependencies: World, Portal, Calendar

---

### Entity: World

A complete strategic map represented as hexagonal grid with provinces. Container for all game content in a single world instance.

**Properties:**
```lua
World = {
  id = string,                    -- "earth", "alien_homeworld"
  name = string,                  -- "Earth", "Zeta Reticuli Prime"
  universe = Universe,            -- Parent universe
  
  -- Grid Information
  grid_width = number,            -- 90 for Earth (hexes)
  grid_height = number,           -- 45 for Earth (hexes)
  scale_km_per_hex = number,      -- Physical scale (500 km/hex typical)
  provinces = Province[],         -- All provinces on this world
  province_graph = ProvinceGraph, -- Navigation network
  
  -- Content
  biomes = Biome[],               -- Available biome types
  regions = Region[],             -- Geographic regions
  bases = Base[],                 -- Player/enemy bases
  missions = Mission[],           -- Active missions
  portals = Portal[],             -- Local portals
  
  -- Status
  accessibility = string,         -- "restricted", "exploration", "unlocked"
  discovered_provinces = number,  -- Fog of war tracking
  
  -- Day/Night Cycle
  daynight_cycle = DayNightCycle, -- Visual and mechanical day/night
  
  -- Time
  time_of_day = number,           -- 0.0-1.0 (0=midnight, 0.5=noon)
}
```

**Functions:**
```lua
-- World management
World.create(name: string, width: number, height: number) → World
WorldSystem.createWorld(config: table) → World, error
-- config: {id, name, width, height, scale_km_per_hex}

WorldSystem.getWorld(id) → World | nil
WorldSystem.getAllWorlds() → World[]
world:getWidth() → number
world:getHeight() → number
world:getScale() → number

-- Province management
world:addProvince(province) → bool
world:removeProvince(provinceId) → bool
world:getProvinces() → Province[]
world:getProvinceAt(q, r) → Province | nil
world:getProvinceById(id) → Province | nil
world:getProvincesByRegion(regionId) → Province[]
world:getProvincesByBiome(biome_type: string) → Province[]
world:getTotalProvinces() → number

-- Region management
world:addRegion(region) → bool
world:getRegions() → Region[]

-- Faction management
world:addFaction(factionId) → bool
world:removeFaction(factionId) → bool
world:getFactions() → string[]

-- Queries
world:getTotalPopulation() → number
world:getDiscoveredProvinces() → Province[]
world:getHighThreatProvinces() → Province[]  -- mission_level > 5
world:getBasedProvinces() → Province[]       -- Has player base
world:isValidHex(q, r) → bool
world:isAccessible() → boolean

-- Path finding
world:findPath(start: Province, goal: Province, craft_type: string) → Province[]
world:getDistance(start: Province, goal: Province) → number
world:getTravelCost(start: Province, goal: Province, craft: Craft) → (time: number, fuel: number)
world:hasBase(x: number, y: number) → boolean
world:getBasesAt(x: number, y: number) → Base | nil

-- Time and visibility
world:updateDayNightCycle() → void
world:isDayTime() → boolean
world:getVisibilityRange() → number (hex range by time of day)
```

**TOML Configuration:**
```toml
[worlds.earth]
id = "earth"
name = "Earth"
width = 90
height = 45
scale_km_per_hex = 500
accessibility = "unlocked"

biomes = ["forest", "desert", "urban", "arctic", "ocean", "mountain", "grassland", "volcanic"]
regions = [
  { name = "North America", countries = ["USA", "Canada", "Mexico"] },
  { name = "South America", countries = ["Brazil", "Argentina"] },
  { name = "Europe", countries = ["UK", "France", "Germany", "Russia"] },
  { name = "Africa", countries = ["Egypt", "South Africa"] },
  { name = "Asia", countries = ["China", "Japan", "India"] },
  { name = "Oceania", countries = ["Australia"] },
]

[worlds.earth.daynight_cycle]
turns_per_day = 30
day_start_turn = 6
dusk_start_turn = 20
night_start_turn = 24
day_visibility_range = 20
dusk_visibility_range = 15
night_visibility_range = 10

[[portals]]
name = "Earth Portal A"
location = { q = 45, r = 22 }
destination_world = "alien_homeworld"
requires_research = "Dimensional Travel"

[[worlds.alien_homeworld]]
name = "Zeta Reticuli Prime"
width = 80
height = 40
accessibility = "restricted"
biomes = ["alien_forest", "alien_desert", "alien_volcanic"]
```

**Integration:**
- Used by: Basescape (location), Battlescape (mission origin), Politics (territory), UI (rendering)
- Uses: Calendar, DayNightCycle, Region, Biome, Province

---

### Entity: Province

Individual hexagonal territorial unit on the world map. Each province is a graph node capable of containing bases, missions, and craft.

**Properties:**
```lua
Province = {
  id = string,                    -- "earth_q30_r20" or "california"
  name = string,                  -- Display name
  world = World,                  -- Parent world
  
  -- Position
  q = number,                     -- Hex Q coordinate (axial)
  r = number,                     -- Hex R coordinate (axial)
  
  -- Ownership & Politics
  owner = string | nil,           -- Country/faction ID or nil
  contested = bool,               -- Multiple claimants?
  
  -- Geography
  biome = string,                 -- "forest", "desert", "urban", etc.
  region = string,                -- Regional grouping
  terrain_features = {string, ...}, -- ["mountain", "river"]
  elevation = number,             -- -1 to 10 (relative)
  
  -- Population & Resources
  population = number,            -- Civilian count
  resources = ResourcePool,       -- {alloy: 50, electronics: 100}
  morale = number,                -- 0-100, public sentiment
  
  -- Military Threat
  threat_level = number,          -- 0-10, mission difficulty
  active_missions = Mission[],    -- Current operations
  
  -- Detection
  detected = bool,                -- Known to player?
  detected_turn = number,         -- When discovered
  radar_level = number,           -- Detection confidence (0-100)
  
  -- Infrastructure
  base = Base | nil,              -- Player base if present
  facilities_owned = number,      -- Strategic installations
  
  -- State
  status = string,                -- "peaceful", "threatened", "occupied"
  
  -- Content
  neighbors = Province[],         -- Adjacent 6 provinces
  graph_node = GraphNode,         -- Navigation graph entry
}
```

**Functions:**
```lua
-- Creation and retrieval
ProvinceSystem.createProvince(config) → Province, error
-- config: {id, name, world, q, r, biome, region, population, resources}

ProvinceSystem.getProvince(id) → Province | nil
ProvinceSystem.getProvinceAt(world, q, r) → Province | nil
ProvinceSystem.getProvincesByOwner(world, ownerId) → Province[]
ProvinceSystem.getProvincesByRegion(world, regionId) → Province[]
ProvinceSystem.getProvincesByBiome(world, biomeType) → Province[]
ProvinceSystem.getProvincesByThreat(world, minThreat) → Province[]
Province.create(world: World, q: number, r: number, biome: Biome) → Province

-- Ownership
province:setOwner(newOwnerId) → bool
province:getOwner() → string | nil
province:isOwned() → bool
province:isContested() → bool
province:setContested(bool) → void

-- Threat & Missions
province:setThreatLevel(level) → bool  -- 0-10
province:getThreatLevel() → number
province:addMission(mission) → bool
province:removeMission(missionId) → bool
province:getMissions() → Mission[]
province:hasActiveMission() → bool
province:getMissionCount() → number

-- Detection
province:setDetected(detected) → void
province:isDetected() → boolean
province:getDetectionConfidence() → number  -- 0-100
province:updateRadarLevel(confidence) → void

-- Base Management
province:hasBase() → bool
province:getBase() → Base | nil
province:setBase(base) → bool
province:removeBase() → void

-- Resources
province:addResources(resourceId, amount) → bool
province:removeResources(resourceId, amount) → bool
province:getResources() → ResourcePool
province:hasResources(resourceId, amount) → bool

-- Population & Morale
province:getPopulation() → number
province:setPopulation(amount) → void
province:getMorale() → number
province:setMorale(level) → void
province:adjustMorale(delta) → void

-- Geography
province:getBiome() → string
province:getRegion() → string
province:getTerrainFeatures() → string[]
province:getElevation() → number
province:hasFeature(featureName) → bool

-- Queries
province:getCoordinates() → {q: number, r: number}
province:getDistanceTo(otherProvince) → number  -- Hex distance
province:getVisibleProvinces(range) → Province[]
province:getAdjacentProvinces() → Province[]  -- 6 neighbors in hex
province:getStatus() → string
province:getNeighbors() → Province[]
province:canUnitTraverse(unit_type: string) → boolean
province:getEconomy() → number  -- Monthly output
```

**TOML Configuration:**
```toml
[[provinces]]
id = "california"
name = "California"
world = "earth"
hex_q = 10
hex_r = 15
biome = "desert"
region = "north_america"
population = 35000000
starting_owner = "usa"
resources = {alloy = 50, electronics = 100}
threat_level = 3
terrain_features = ["mountain", "desert_valley"]

[[provinces]]
id = "london"
name = "London"
world = "earth"
hex_q = 20
hex_r = 12
biome = "urban"
region = "europe"
population = 8000000
starting_owner = "uk"
resources = {electronics = 200}
threat_level = 2
```

---

### Entity: HexCoordinate

Represents a position on the hexagonal grid using axial coordinates. Core positioning system for all map operations.

**Properties:**
```lua
HexCoordinate = {
  q = number,    -- Column (axial)
  r = number,    -- Row (axial)
}
```

**Functions:**
```lua
-- Creation
HexCoordinate.new(q, r) → HexCoordinate
HexCoordinate.fromOffset(x, y) → HexCoordinate  -- Convert from offset coords

-- Queries
hex:getQ() → number
hex:getR() → number
hex:getS() → number  -- Derived cube coordinate (-(q+r))

-- Distance calculations
hex:distanceTo(other) → number  -- Hex distance
hex:getNeighbors() → HexCoordinate[]  -- 6 adjacent hexes
hex:getRange(distance) → HexCoordinate[]  -- All hexes within distance
hex:getLine(other) → HexCoordinate[]  -- Path between hexes

-- Rotation
hex:rotateAround(center, steps) → HexCoordinate  -- Rotate 60° increments

-- Conversion
hex:toOffset() → {x: number, y: number}
hex:toPixel(hexSize) → {x: number, y: number}
hex:toString() → string  -- "Q10R15"
```

---

### Entity: WorldRenderer

Manages visualization of the geoscape map with multiple information display overlays. Handles map rendering, zoom levels, province highlighting, and information display modes inspired by Europa Universalis.

**Properties:**
```lua
WorldRenderer = {
  world = World,                      -- World being rendered
  current_display_mode = string,      -- Current overlay mode
  zoom_level = number,                -- 0.5-3.0 (0.5=zoomed out, 3.0=zoomed in)
  pan_offset = {x: number, y: number},-- Map pan position
  
  -- Display settings
  show_grid = boolean,                -- Show hex grid
  show_labels = boolean,              -- Show province names
  show_regions = boolean,             -- Highlight regions
  animation_enabled = boolean,        -- Smooth transitions
  
  -- Selected elements
  selected_province = Province | nil,
  highlighted_provinces = Province[], -- For path display
  
  -- Performance
  render_distance = number,           -- Only render visible hexes
  cached_textures = table,            -- Sprite cache
}
```

**Display Modes:**

The WorldRenderer supports 8 distinct information overlay modes, each highlighting different strategic information:

#### 1. **Political Mode** (Default)
Displays country borders, capital cities, and regional control.
- **Color Scheme**: Nations colored by faction (player=blue, allies=green, neutral=gray, enemies=red)
- **Information**: Country names, capital cities, border demarcation lines
- **UI Elements**: Legend showing faction colors, current political alignment
- **Use Case**: Strategic overview of world control and alliances
- **Configuration**: Via `geoscape.toml` [display_modes.political]

#### 2. **Relations Mode**
Shows diplomatic relationships and trading partners with relationship strength visualization.
- **Color Scheme**: Gradient from dark red (hostile) through gray (neutral) to dark green (allied)
- **Information**: Relationship levels, trade agreement status, dispute indicators
- **UI Elements**: Relationship strength legend, trading partner icons
- **Use Case**: Diplomatic planning and relation tracking
- **Configuration**: Via `geoscape.toml` [display_modes.relations]

#### 3. **Resources Mode**
Highlights resource distribution, availability, and resource density by region.
- **Color Scheme**: Resource-specific (electronics=cyan, minerals=gray, rare_earth=purple, energy=yellow)
- **Information**: Resource type markers, density indicators, supply line visualization
- **UI Elements**: Resource legend, scarcity warnings
- **Use Case**: Economic planning and trade route optimization
- **Configuration**: Via `geoscape.toml` [display_modes.resources]

#### 4. **Bases Mode**
Military overview showing all bases, craft locations, and strategic infrastructure.
- **Color Scheme**: Player bases=bright blue, allied bases=green, enemy bases=red, facilities highlighted
- **Information**: Base IDs, facility types, craft deployed, garrison strength
- **UI Elements**: Base status indicators (healthy, damaged, under construction), garrison size bars
- **Use Case**: Military deployment planning and base status overview
- **Configuration**: Via `geoscape.toml` [display_modes.bases]

#### 5. **Missions Mode**
Active threat display showing all missions, their types, and priority levels.
- **Color Scheme**: Crash site=orange, Terror site=red, Base assault=dark red, UFO sighting=yellow, Other=gray
- **Information**: Mission type icons, difficulty levels, time remaining, UFO threat icons
- **UI Elements**: Mission priority indicators, UFO classification, turn deadline warnings
- **Use Case**: Threat assessment and mission prioritization
- **Configuration**: Via `geoscape.toml` [display_modes.missions]

#### 6. **Score Mode**
Regional performance tracking showing regional control progress, panic levels, and funding influence.
- **Color Scheme**: Green (high score) → yellow (medium) → red (low score)
- **Information**: Regional score bars, panic percentage, funding tier, population influence
- **UI Elements**: Progress bars, percentage indicators, league table ranking
- **Use Case**: Campaign progress tracking and regional performance analysis
- **Configuration**: Via `geoscape.toml` [display_modes.score]

#### 7. **Biome Mode**
Environmental classification showing terrain types, climate zones, and environmental features.
- **Color Scheme**: Forest=green, desert=tan, urban=gray, tundra=light blue, ocean=blue, mountain=brown, volcanic=orange
- **Information**: Terrain type labels, climate classification, special features (resources, hazards)
- **UI Elements**: Biome legend, environmental modifier indicators
- **Use Case**: Terrain analysis for battlescape predictions and mission planning
- **Configuration**: Via `geoscape.toml` [display_modes.biome]

#### 8. **Radar Coverage Mode** (Advanced)
Displays detection capability, radar coverage zones, and surveillance effectiveness.
- **Color Scheme**: Covered=green shading, partial coverage=yellow, uncovered=red, blind spots=dark
- **Information**: Radar range circles, detection confidence levels, gap analysis
- **UI Elements**: Coverage percentage by region, sensor strength indicators, gap warnings
- **Use Case**: Defensive planning and early warning optimization
- **Configuration**: Via `geoscape.toml` [display_modes.radar_coverage]

**Functions:**
```lua
-- Initialization and setup
WorldRenderer.create(world: World) → WorldRenderer
WorldRenderer.setDisplayMode(mode: string) → bool
  -- mode: "political", "relations", "resources", "bases", "missions", "score", "biome", "radar"

-- Display control
renderer:setZoomLevel(level: number) → void  -- 0.5 to 3.0
renderer:getZoomLevel() → number
renderer:pan(deltaX: number, deltaY: number) → void
renderer:toggleGrid(show: boolean) → void
renderer:toggleLabels(show: boolean) → void
renderer:toggleAnimations(enable: boolean) → void

-- Information display
renderer:getDisplayMode() → string
renderer:getDisplayModeDescription() → string
renderer:highlightProvince(province: Province) → void
renderer:highlightPath(provinces: Province[]) → void  -- Show path between provinces
renderer:clearHighlight() → void

-- Rendering
renderer:render(canvas: Canvas, deltaTime: number) → void
renderer:getVisibleProvinces() → Province[]  -- For culling
renderer:getProvinceAtPixel(x: number, y: number) → Province | nil

-- Mode-specific data
renderer:getPoliticalData() → table  -- Color map, borders, capitals
renderer:getRelationsData() → table  -- Relationship strengths, icons
renderer:getResourcesData() → table  -- Resource locations, density
renderer:getBasesData() → table      -- Base locations, statuses
renderer:getMissionsData() → table   -- Mission markers, types, icons
renderer:getScoreData() → table      -- Regional scores, panic levels
renderer:getBiomeData() → table      -- Terrain types, features
renderer:getRadarData() → table      -- Coverage zones, detection levels

-- Configuration
renderer:loadDisplayModeConfig(configTable: table) → void
renderer:getColorScheme(mode: string) → table
renderer:setColorScheme(mode: string, colors: table) → void

-- Performance
renderer:preloadTextures() → void
renderer:clearCache() → void
renderer:optimizeForLowEnd() → void  -- Reduce visual effects for performance
```

**TOML Configuration:**
```toml
[display_modes.political]
name = "Political"
description = "Country borders and alliances"
icon = "political.png"
colors = {
  player = [0, 100, 200],      # Blue
  ally = [0, 200, 0],           # Green
  neutral = [100, 100, 100],    # Gray
  enemy = [200, 0, 0],          # Red
}
show_capitals = true
show_borders = true

[display_modes.relations]
name = "Relations"
description = "Diplomatic relationships and trade"
icon = "relations.png"
hostile_color = [200, 0, 0]
neutral_color = [100, 100, 100]
allied_color = [0, 200, 0]
show_trade_lines = true
show_agreements = true

[display_modes.resources]
name = "Resources"
description = "Resource distribution"
icon = "resources.png"
colors = {
  electronics = [0, 255, 255],
  minerals = [100, 100, 100],
  rare_earth = [200, 0, 200],
  energy = [255, 255, 0],
}
show_density = true
show_scarcity_warnings = true

[display_modes.bases]
name = "Bases"
description = "Military infrastructure"
icon = "bases.png"
player_base_color = [0, 100, 255]
allied_base_color = [0, 200, 0]
enemy_base_color = [200, 0, 0]
show_garrison_strength = true
show_facilities = true
show_damage_status = true

[display_modes.missions]
name = "Missions"
description = "Active threats and missions"
icon = "missions.png"
colors = {
  crash_site = [255, 165, 0],
  terror_site = [255, 0, 0],
  base_assault = [139, 0, 0],
  ufo_sighting = [255, 255, 0],
}
show_difficulty = true
show_countdown = true
show_ufo_classification = true

[display_modes.score]
name = "Score"
description = "Regional performance"
icon = "score.png"
high_score_color = [0, 200, 0]
medium_score_color = [255, 255, 0]
low_score_color = [200, 0, 0]
show_panic_levels = true
show_funding_tier = true
show_regional_ranking = true

[display_modes.biome]
name = "Biome"
description = "Terrain and climate"
icon = "biome.png"
colors = {
  forest = [0, 150, 0],
  desert = [210, 180, 140],
  urban = [100, 100, 100],
  tundra = [173, 216, 230],
  ocean = [0, 100, 200],
  mountain = [139, 69, 19],
  volcanic = [255, 100, 0],
}
show_terrain_modifiers = true
show_hazards = true

[display_modes.radar_coverage]
name = "Radar Coverage"
description = "Detection capability"
icon = "radar.png"
covered_color = [0, 200, 0]
partial_color = [255, 255, 0]
uncovered_color = [200, 0, 0]
blind_spot_color = [50, 50, 50]
show_coverage_percentage = true
show_blind_spots = true
show_sensor_strength = true
```

**Integration:**
- Used by: Main UI renderer, map display, overlay system
- Uses: World, Province, Biome, HexCoordinate
- Renders: Political data, military info, economic data, mission status

---

### Entity: Calendar

Tracks in-game time progression. One turn = one in-game day. Central to all time-based mechanics.

**Properties:**
```lua
Calendar = {
  current_turn = number,    -- Total turns since game start
  current_day = number,     -- 1-30 (day of month)
  current_month = number,   -- 1-12 (month number)
  current_year = number,    -- Starting year (typically 1996+)
  hour_of_day = number,     -- 0-23
  total_days = number,      -- Total days since game start
}
```

**Functions:**
```lua
-- Time queries
CalendarSystem.getCurrentTurn() → number
CalendarSystem.getCurrentDate() → {day, month, year}
CalendarSystem.getCurrentDateString() → string  -- "Jan 5, 1996"
CalendarSystem.getFormattedTime() → string  -- "14:32"
CalendarSystem.getTurnsPerDay() → number

-- Time progression
CalendarSystem.nextTurn() → void  -- Advance 1 turn (1 day)
CalendarSystem.advanceDays(count) → void
CalendarSystem.skipToDate(day, month, year) → bool
CalendarSystem.skipToMonth(month) → void

-- Time queries
CalendarSystem.getTurnsElapsed() → number
CalendarSystem.getDaysElapsed() → number
CalendarSystem.getMonthsElapsed() → number
CalendarSystem.getYearsElapsed() → number
CalendarSystem.getSeason() → string  -- "spring", "summer", "fall", "winter"
CalendarSystem.getQuarter() → number  -- 1-4
CalendarSystem.getMonthName(month) → string
CalendarSystem.getDayName(dayOfWeek) → string
Calendar.getTimeOfDay() → "day" | "dusk" | "night"

-- Milestone queries
CalendarSystem.isNewMonth() → bool
CalendarSystem.isNewYear() → bool
CalendarSystem.isNight() → bool
CalendarSystem.isDay() → bool
Calendar.daysElapsed() → number

-- Duration calculations
CalendarSystem.getTurnsUntilDate(day, month, year) → number
CalendarSystem.getTurnsUntilMonth(month) → number
CalendarSystem.getTurnsUntilSeason(season) → number

-- Time multipliers
CalendarSystem.getTimeMultiplier() → number  -- Game speed
CalendarSystem.setTimeMultiplier(speed) → void
```

**TOML Configuration:**
```toml
[calendar]
starting_year = 1996
starting_month = 3
starting_day = 1
starting_hour = 8

months = ["January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November", "December"]

seasons = [
  {name = "spring", months = [3, 4, 5]},
  {name = "summer", months = [6, 7, 8]},
  {name = "fall", months = [9, 10, 11]},
  {name = "winter", months = [12, 1, 2]},
]
```

---

### Entity: DayNightCycle

Manages visual lighting system based on time of day. Controls day/night transitions and affects visibility ranges and mission mechanics.

**Properties:**
```lua
DayNightCycle = {
  sunrise_hour = number,    -- Hour cycle starts (6)
  sunset_hour = number,     -- Hour cycle ends (18)
  transition_duration = number,  -- Minutes for transition
  current_phase = string,   -- "dawn", "day", "dusk", "night"
  light_intensity = number, -- 0.0-1.0
  day_length = number,      -- Turns per day (30 typical)
}
```

**Functions:**
```lua
-- Queries
DayNightCycle.isDay() → bool
DayNightCycle.isNight() → bool
DayNightCycle.isDawn() → bool
DayNightCycle.isDusk() → bool
DayNightCycle.getPhase() → string
DayNightCycle.getLightIntensity() → number  -- 0.0-1.0
DayNightCycle.getAmbientColor() → {r, g, b}

-- Configuration
DayNightCycle.setSunriseHour(hour) → void
DayNightCycle.setSunsetHour(hour) → void
DayNightCycle.setTransitionDuration(minutes) → void

-- Updates
DayNightCycle.update(deltaTime) → void
DayNightCycle.skipToHour(hour) → void
```

---

### Entity: Biome

Classification of provincial terrain and climate. Affects mission generation, travel times, resource availability, and battlescape terrain.

**Properties:**
```lua
Biome = {
  id = string,              -- "forest", "desert", "urban", "tundra"
  name = string,
  description = string,
  
  -- Modifiers
  movement_multiplier = number,  -- Travel time modifier (1.0 = standard)
  cost_multiplier = number,      -- Mission cost modifier
  difficulty_modifier = number,  -- Enemy strength modifier
  
  -- Terrain characteristics
  terrain_type = string,    -- "water", "land", "land_rough", "land_very_rough"
  fauna_flora = string,     -- Visual appearance descriptor
  
  -- Visual
  terrain_sprite = string,  -- Asset path
  color = {r, g, b},
  ambient_lighting = number,-- 0-1
  
  -- Resources
  rare_resources = {string, ...},
  resource_density = number,  -- 0-1 probability
  
  -- Mission Impact
  mission_type_weights = table,  -- {terror: 0.5, crash: 0.3, etc}
  mission_difficulty_base = number,
}
```

**Functions:**
```lua
BiomeSystem.getBiomeProperties(biomeType) → table
BiomeSystem.getTerrainOptions(biomeType) → table
BiomeSystem.getMissionTypeWeights(biomeType) → table
BiomeSystem.getMissionDifficultyModifier(biomeType) → number
BiomeSystem.getRecruitmentAvailability(biomeType) → table
```

**TOML Configuration:**
```toml
[[biomes]]
id = "forest"
name = "Forest"
terrain_type = "land"
movement_multiplier = 1.0
cost_multiplier = 1.0
difficulty_modifier = 0.0
rare_resources = ["rare_earth"]
resource_density = 0.3

[[biomes]]
id = "desert"
name = "Desert"
terrain_type = "land"
movement_multiplier = 1.1
cost_multiplier = 1.2
difficulty_modifier = 0.1
rare_resources = ["silicon"]
resource_density = 0.2

[[biomes]]
id = "urban"
name = "Urban"
terrain_type = "land"
movement_multiplier = 1.0
cost_multiplier = 1.3
difficulty_modifier = 0.3
rare_resources = ["electronics"]
resource_density = 0.5

[[biomes]]
id = "tundra"
name = "Tundra"
terrain_type = "land_rough"
movement_multiplier = 1.3
cost_multiplier = 1.4
difficulty_modifier = 0.2
rare_resources = []
resource_density = 0.1

[[biomes]]
id = "ocean"
name = "Ocean"
terrain_type = "water"
movement_multiplier = 1.5
cost_multiplier = 1.5
difficulty_modifier = 0.2
rare_resources = ["rare_minerals"]
resource_density = 0.1

[[biomes]]
id = "mountain"
name = "Mountain"
terrain_type = "land_very_rough"
movement_multiplier = 1.5
cost_multiplier = 1.3
difficulty_modifier = 0.2
rare_resources = ["minerals", "rare_earth"]
resource_density = 0.3

[[biomes]]
id = "volcanic"
name = "Volcanic"
terrain_type = "land_very_rough"
movement_multiplier = 1.4
cost_multiplier = 1.4
difficulty_modifier = 0.3
rare_resources = ["geothermal", "minerals"]
resource_density = 0.2
```

---

### Entity: Region

Geographic grouping of provinces. Used for politics, faction control, scoring, and strategic planning.

**Properties:**
```lua
Region = {
  id = string,              -- "north_america"
  name = string,
  provinces = Province[],   -- Member provinces (typically 4-12)
  owner = string | nil,     -- Controlling faction
  total_population = number,
  coverage = number,        -- Radar coverage % (0-100)
  panic_level = number,     -- Public panic (0-100)
  funding_level = number,   -- Monthly funding tier (0-10)
  active_threats = number,  -- Current UFO activity count
  missions_available = number, -- Pending missions
  supply_lines = {string, ...}, -- Connected base IDs
}
```

**Functions:**
```lua
RegionSystem.getRegionsByCountry(countryId) → table
RegionSystem.getRegionScore(regionId) → number
RegionSystem.calculateRegionEconomy(regionId) → number
RegionSystem.getRegionPopulation(regionId) → number
RegionSystem.getRegionMissionWeight(regionId) → number
Region.getStatus(regionId) → table
Region.updateThreatLevel(regionId, delta) → number
Region.deployMission(regionId, missionTemplate) → table
Region.get(regionId) → Region
Region.getAll() → Region[]
```

---

### Entity: Craft

Spacecraft for deployment, travel, and interception operations.

**Properties:**
```lua
Craft = {
  id = string,                    -- "craft_1"
  name = string,                  -- "Skyranger-01"
  type = string,                  -- "transport", "interceptor", "scout"
  
  -- Status
  current_location = Province,    -- Current province
  destination = Province | nil,   -- Where traveling to
  hp = number,                    -- Current health
  max_hp = number,                -- Max health (100-400 typical)
  fuel = number,                  -- Current fuel
  max_fuel = number,              -- Fuel tank size
  crew = Unit[],                  -- Units aboard
  
  -- Properties
  capacity = number,              -- Max crew size
  speed = number,                 -- Hexes per turn
  weapons = Weapon[],             -- Equipped weapons
  armor_class = number,           -- Defensive rating
  experience = number,            -- Pilot experience for interception
  
  -- Condition
  is_damaged = boolean,           -- Needs repair
  is_refueling = boolean,         -- At fuel station
  can_deploy = boolean,           -- Ready for mission
}
```

**Functions:**
```lua
-- Lifecycle
Craft.create(type: string, base: Base) → Craft
craft:getName() → string
craft:getType() → string

-- Movement
craft:travel(destination: Province) → (turns: number, fuel_cost: number)
craft:canTravel(destination: Province) → (can_travel: boolean, reason: string)
craft:getCurrentLocation() → Province
craft:getDestination() → Province | nil

-- Resource management
craft:consumeFuel(amount: number) → boolean
craft:refuel(amount: number) → void
craft:takeDamage(damage: number) → void
craft:repair(amount: number) → void

-- Crew and equipment
craft:addUnit(unit: Unit) → boolean
craft:removeUnit(unit_id: string) → void
craft:getUnits() → Unit[]
craft:equipWeapon(weapon: Weapon) → boolean

-- Interception
craft:canIntercept() → boolean (check hp, fuel, weapons)
craft:getInterceptionStats() → {hp, armor, weapons, experience}
```

**TOML Configuration:**
```toml
[[craft_types]]
id = "skyranger"
name = "Skyranger"
description = "Standard transport - slow but spacious"
max_hp = 200
max_fuel = 500
capacity = 10
speed = 2  # hexes/turn
armor_class = 10
base_cost = 50000
availability = "default"

[[craft_types]]
id = "interceptor"
name = "Lightning"
description = "High-speed interceptor - optimal for air combat"
max_hp = 150
max_fuel = 800
capacity = 2
speed = 4  # hexes/turn (fastest)
armor_class = 15
base_cost = 75000
availability = "research:plasma_tech"

[[craft_types]]
id = "assault_craft"
name = "Avenger"
description = "Armed transport with combat capability"
max_hp = 250
max_fuel = 600
capacity = 8
speed = 2.5  # hexes/turn
armor_class = 18
base_cost = 100000
weapons = ["plasma_cannon", "missile_launcher"]
availability = "research:advanced_combat_craft"
```

---

### Entity: Mission

Instance of active threat or objective on map.

**Properties:**
```lua
Mission = {
  id = string,                    -- "mission_42"
  type = string,                  -- "ufo_crash", "terror_site", "base_assault"
  
  -- Location & Status
  location = Province,            -- Where the mission occurs
  state = string,                 -- "active", "completed", "failed"
  discovered = boolean,           -- Player knows about it
  
  -- Content
  objectives = Objective[],       -- Mission goals
  enemy_squad = Squad,            -- Enemy force
  rewards = {                     -- On completion
    xp = number,
    items = ItemStack[],
    intel = string,
    relations_change = number,
  },
  
  -- Timing
  turn_appeared = number,         -- When first detected
  turns_remaining = number | nil, -- Deadline if applicable (-1 = no deadline)
  
  -- Metadata
  difficulty = number,            -- 1-5 scale
  threat_level = number,          -- Player perception
}
```

**Functions:**
```lua
-- Lifecycle
Mission.create(type: string, location: Province) → Mission
mission:getId() → string
mission:getType() → string
mission:getLocation() → Province

-- Discovery and visibility
mission:discover() → void
mission:isDiscovered() → boolean
mission:getVisibilityRange() → number

-- State management
mission:start() → void
mission:complete(victory: boolean) → void
mission:getRewards() → {xp, items, intel, relations}

-- Timing
mission:getRemainingTurns() → number
mission:hasDeadline() → boolean
mission:isExpired() → boolean
mission:processNewTurn() → void
```

**TOML Configuration:**
```toml
[[mission_types]]
id = "terror_site"
name = "Terror Site"
description = "Alien forces are attacking a city"
difficulty_base = 2
reward_xp = 500
reward_intel = 5
reward_relations = 10
enemy_count = 12
turns_until_expiry = 15
mapblock_type = "urban_terror"

[[mission_types]]
id = "ufo_crash"
name = "UFO Crash Site"
description = "Crashed UFO with salvage opportunity"
difficulty_base = 3
reward_xp = 750
reward_intel = 10
reward_relations = 15
reward_loot = ["plasma_rifle", "alien_armor", "power_source"]
enemy_count = 8
turns_until_expiry = 7
mapblock_type = "crash_site"

[[mission_types]]
id = "base_assault"
name = "Alien Base Assault"
description = "Assault on enemy stronghold"
difficulty_base = 4
reward_xp = 1500
reward_intel = 20
reward_relations = 30
reward_loot = ["advanced_alloy", "rare_tech"]
enemy_count = 20
turns_until_expiry = 30
mapblock_type = "alien_base"
```

---

### Entity: UFO

Unidentified Flying Object representing alien threats in the world.

**Properties:**
```lua
UFO = {
  id = string,                    -- "ufo_012"
  type = string,                  -- Scout|Fighter|Transport|Battleship
  region_id = string,             -- Current region
  status = string,                -- "active"|"landed"|"destroyed"
  strength = number,              -- Combat strength (0-100)
  detected = boolean,             -- Visible to player
  heading = number,               -- Direction (degrees)
  speed = number,                 -- Hex/turn
  threat_level = string,          -- "low"|"medium"|"high"|"critical"
  activity = string,              -- "scouting"|"attacking"|"infiltrating"
}
```

**Functions:**
```lua
UFO.create(type: string, region: Region) → UFO
UFO.updatePosition(ufo: UFO, turns: number) → UFO
UFO.getActive() → UFO[]
```

---

## Services & Functions

### World Management Service

```lua
-- World initialization and updates
GeoManager.createWorld(config: table) → World
GeoManager.loadWorld(world_id: string) → World
GeoManager.saveWorld(world: World) → void
GeoManager.getCurrentWorld() → World
GeoManager.switchWorld(world_id: string) → void

-- Province queries
GeoManager.getProvinceAt(world: World, q: number, r: number) → Province | nil
GeoManager.getVisibleProvinces(radius: number) → Province[]
GeoManager.discoverProvince(province: Province) → void

-- Threat assessment
GeoManager.assessThreatLevel(province: Province) → number
GeoManager.getThreatProvinces() → Province[] (all > threat_level 30)
GeoManager.getHotspots() → Province[] (top 10 threat provinces)
```

### Craft Service

```lua
-- Craft deployment
CraftSystem.deployCraft(craft: Craft, mission: Mission) → boolean
CraftSystem.travelCraft(craft: Craft, destination: Province) → number (turns_required)
CraftSystem.getCraftsAt_Base(base: Base) → Craft[]
CraftSystem.getReadyCrafts(base: Base) → Craft[] (ready to deploy)

-- Craft status
CraftSystem.isCraftReady(craft: Craft) → boolean
CraftSystem.repairCraft(craft: Craft, amount: number) → void
CraftSystem.refuelCraft(craft: Craft, amount: number) → void
CraftSystem.getCraftStats(craft: Craft) → {hp, fuel, crew_count, weapons}

-- Combat integration
CraftSystem.engageUFO(craft: Craft, mission: Mission) → InterceptionResult
CraftSystem.handleCraftCrash(craft: Craft, location: Province) → void
```

### Mission Service

```lua
-- Mission generation
MissionSystem.generateMission(type: string, location: Province, difficulty: number) → Mission
MissionSystem.activateMission(mission: Mission) → void
MissionSystem.completeMission(mission: Mission, victory: boolean) → void

-- Mission queries
MissionSystem.getActiveMissions() → Mission[]
MissionSystem.getDiscoveredMissions() → Mission[]
MissionSystem.getMissionsInProvince(province: Province) → Mission[]

-- Mission timers
MissionSystem.processNewTurn() → void  (run mission timers, expiry checks)
MissionSystem.getUrgentMissions() → Mission[] (deadline < 3 turns)
```

### Radar Coverage System

```lua
RadarSystem.getRadarCoverage(baseId) → table  -- {power, range, coverageZone}
RadarSystem.getDetectedMissions(baseId) → table  -- Missions within coverage
RadarSystem.calculateDetectionProbability(baseId, missionId) → number  -- 0-100
RadarSystem.performActiveDetection(baseId, province) → boolean  -- Enhanced scan
RadarSystem.updateRadarCoverage(baseId) → void
RadarSystem.buildRadar(baseId, radarType) → boolean
```

### Region System

```lua
Region.getStatus(regionId) → table
Region.updateThreatLevel(regionId, delta) → number
Region.deployMission(regionId, missionTemplate) → table
Region.getProvincesWithBases(worldId) → table
Region.getProvincesWithMissions(worldId) → table
Region.getProvinceEconomy(provinceId) → number
Region.setProvinceOwner(provinceId, countryId) → void
```

### Travel System

```lua
TravelSystem.calculateTravelTime(craftId, fromProvince, toProvince) → number
TravelSystem.initiateTravel(craftId, toProvince) → boolean
TravelSystem.getTravelStatus(craftId) → table  -- {current, destination, daysRemaining}
TravelSystem.cancelTravel(craftId) → void
TravelSystem.calculateReachableProvinces(craftId) → table
```

### Portal System

```lua
PortalSystem.getPortals(worldId) → table
PortalSystem.hasPortalAccess(provinceId) → boolean
PortalSystem.teleportCraft(craftId, originProvince, destProvince) → boolean
PortalSystem.getPortalDestinations(provinceId) → table
```

---

## Working Examples

### Example 1: Initialize Geoscape

```lua
-- Create world
local world = WorldSystem.createWorld({
  id = "earth",
  name = "Earth",
  width = 90,
  height = 45,
  scale_km_per_hex = 500,
})

-- Create provinces
for q = 0, 89 do
  for r = 0, 44 do
    if (q + r) % 3 == 0 then  -- Sparse province placement
      local province = ProvinceSystem.createProvince({
        id = "prov_" .. q .. "_" .. r,
        name = "Province " .. q .. "," .. r,
        world = world,
        q = q,
        r = r,
        biome = BiomeSystem.selectRandomBiome(),
        population = 5000000 + math.random(0, 5000000),
      })
      
      world:addProvince(province)
    end
  end
end

-- Initialize calendar
CalendarSystem.initialize({year = 1996, month = 3, day = 1})

-- Start game
print("World initialized: " .. world:getTotalProvinces() .. " provinces")
```

### Example 2: Detect Province

```lua
local province = world:getProvinceAt(10, 15)

if province and not province:isDetected() then
  province:setDetected(true)
  province:updateRadarLevel(100)
  
  print("Discovered: " .. province:getName())
end
```

### Example 3: Manage Threat Level

```lua
local province = world:getProvinceById("california")

-- Generate mission
if province:getThreatLevel() < 10 then
  local newThreat = province:getThreatLevel() + 1
  province:setThreatLevel(newThreat)
  
  local mission = MissionSystem.generateMission(province)
  province:addMission(mission)
  
  print("Threat increased to " .. newThreat)
end
```

### Example 4: Time Progression

```lua
-- Simulate multiple turns
for turn = 1, 30 do
  CalendarSystem.nextTurn()
  
  local dateStr = CalendarSystem.getCurrentDateString()
  print("Turn " .. CalendarSystem.getCurrentTurn() .. ": " .. dateStr)
  
  -- Update all provinces
  for _, province in ipairs(world:getProvinces()) do
    province:setThreatLevel(math.min(10, province:getThreatLevel() + 0.1))
  end
end
```

### Example 5: Deploy Craft

```lua
-- Get craft from base
local base = BaseManager.getBaseById("main_base")
local crafts = CraftSystem.getCraftsAt_Base(base)
local craft = crafts[1]

-- Check if can travel
local can_travel, reason = craft:canTravel(mission_province)
if not can_travel then
  print("Cannot travel: " .. reason)
  return
end

-- Deploy craft
local turns_required = CraftSystem.travelCraft(craft, mission_province)
print("Craft deploying. ETA: " .. turns_required .. " turns")

-- On arrival, launch interception
CraftSystem.engageUFO(craft, mission)
```

### Example 6: Display Regions and UFOs

```lua
local Geoscape = require("engine.geoscape.geoscape")

local regions = Geoscape.Region.getAll()
print("[GEOSCAPE] Total Regions: " .. #regions)

for _, region in ipairs(regions) do
  local status = Geoscape.Region.getStatus(region.id)
  print("[REGION] " .. region.name .. " - Panic: " .. region.panic_level .. "%, Coverage: " .. 
        region.coverage .. "%, Threats: " .. region.active_threats)
end

local ufos = Geoscape.UFO.getActive()
print("[UFO ALERT] Active UFOs: " .. #ufos)

for i, ufo in ipairs(ufos) do
  print("[UFO " .. i .. "] Type: " .. ufo.type .. ", Region: " .. ufo.region_id ..
        ", Strength: " .. ufo.strength)
end
```

---

## Integration & Workflows

### Standard Geoscape Gameplay Loop

1. **Observe Generated Missions**: Missions automatically spawn on map
2. **Detect via Radar**: Radar coverage reveals nearby missions
3. **Plan Response**: Evaluate threat and determine strategy
4. **Assign Craft**: Dispatch craft from base to mission province
5. **Execute Travel**: Craft moves via world path to target province
6. **Intercept or Defend**: Initiate interception with craft/base forces
7. **Resolve Engagement**: Interception succeeds/fails
8. **Escalate or Return**: Continue to Battlescape or return to Geoscape
9. **Manage Resources**: Repair craft, allocate personnel, process rewards

### Integration with Other Systems

**Called By:**
- Basescape: Location queries, territory ownership, facility effects
- Battlescape: Mission origin province, environmental modifiers
- Interception: UFO tracking, craft positioning
- Politics: Country territory, diplomatic relations
- Economy: Resource availability, trade routes
- UI: Map rendering, mission displays

**Calls:**
- Calendar: Time progression, turn advancement
- DayNightCycle: Lighting calculations, visibility
- Region: Geographic grouping, regional control
- Biome: Terrain classification, mission generation modifiers
- Analytics: Threat assessment, performance metrics

---

## Calendar & Time Progression System

### Day/Night Cycle Management

**Overview**
The Calendar System manages in-game time progression, day/night cycles, and temporal events affecting gameplay.

**Calendar Mechanics**
- **Turn Duration**: Each turn = 1 in-game day (24 hours)
- **Calendar Tracking**: Current year, month, day tracked globally
- **Day Cycle**: 24-hour cycle with day/night phases
- **Time Progression**: Automatic advancement at turn end
- **Seasonal Events**: Affected by time of year (weather, enemy activity)

**Day/Night Phases**
- **Dawn** (6:00): Transition to day, visibility increases
- **Day** (6:00-18:00): Full visibility, standard sight ranges apply
- **Dusk** (18:00): Transition to night, visibility decreases
- **Night** (18:00-6:00): Reduced visibility, night-specific mechanics apply

**Time Properties:**
```lua
Calendar = {
  turn = number,                  -- Current turn number
  year = number,                  -- Current year
  month = number,                 -- 1-12
  day = number,                   -- 1-28/30/31
  hour = number,                  -- 0-23
  day_name = string,              -- "Monday", etc.
  month_name = string,            -- "January", etc.
  is_day = boolean,               -- True if 6:00-18:00
  is_night = boolean,             -- True if 18:00-6:00
}
```

**Calendar Functions:**
```lua
Calendar.getCurrentDate() → {year, month, day}
Calendar.getCurrentTime() → {hour, minute}
Calendar.getTurn() → number
Calendar.getDayOfWeek() → string
Calendar.isDay() → boolean
Calendar.isNight() → boolean
Calendar.advanceTurn() → void
Calendar.addDays(days: number) → void
Calendar.getDaysElapsed() → number (total since campaign start)
```

### Day/Night Impact on Gameplay

**Visibility Changes**
- **Day sight**: Standard range (8-12 hexes typical)
- **Night sight**: Reduced range (3-6 hexes typical)
- **No dynamic lighting**: Uses fog-of-war system instead
- **Item modifiers**: Special items like flashlights extend night vision

**Unit Performance**
- **Day missions**: Standard unit performance, normal accuracy
- **Night missions**: Reduced accuracy (-20%), penalties to visibility
- **Sanity damage**: Night missions cause -1 sanity (atmospheric horror)
- **Fatigue mechanics**: Extended night missions increase fatigue

**Enemy Activity**
- **Day UFO missions**: Standard detection difficulty
- **Night UFO missions**: Reduced radar effectiveness (-20% detection range)
- **Night ambushes**: Aliens more likely to deploy at night
- **Activity patterns**: Some alien species prefer night operations

**Geoscape Mechanics**
- **Craft visibility**: Enemy can detect craft at night with reduced penalty
- **Base detection**: Enemy radar less effective at night
- **Supply deliveries**: Transfer systems slower at night (-25% speed)

**Mission Generation**
- **Mission type affected**: Infiltration missions favor night
- **Difficulty scaling**: Night missions considered +1 difficulty
- **Special events**: Some events only occur at specific times

### Calendar Configuration

```toml
# calendar/system.toml

[time_settings]
turns_per_day = 1
hours_per_turn = 24
days_per_month = 30
months_per_year = 12
starting_year = 2084
starting_month = 1
starting_day = 1

[day_night_cycle]
dawn_hour = 6
day_hour = 6
dusk_hour = 18
night_hour = 18

[visibility]
day_sight_range = 12
night_sight_range = 5
dawn_dusk_modifier = 0.8   # 80% of normal sight

[night_mechanics]
accuracy_penalty = -0.20
detection_penalty = -0.20
sanity_damage = 1
radar_effectiveness = 0.8
fatigue_increase_rate = 1.5
```

---

## UFO Registry & Tracking System

### UFO Tracking Overview

**Overview**
The UFO Registry manages all alien aircraft activity, tracking movements, threat assessment, and interception opportunities. The system maintains a database of all known/suspected UFO activity and calculates threat levels.

**UFO Properties:**
```lua
UFO = {
  id = string,                    -- "ufo_001"
  type = string,                  -- "fighter", "transport", "battleship"
  faction = string,               -- Owning alien faction
  
  -- Position & Movement
  current_province = Province,    -- Current location
  destination_province = Province | nil,
  path = Province[],              -- Planned travel route
  speed = number,                 -- Hexes per turn
  arrival_turn = number,          -- When reaches destination
  
  -- Status
  status = string,                -- "en_route", "on_patrol", "attacking", "retreating"
  health = number,                -- Current HP
  max_health = number,            -- Full HP
  
  -- Capability
  weapon_power = number,          -- Attack capability (0-100)
  armor = number,                 -- Defense rating
  crew_count = number,            -- Number of personnel
  
  -- Threat Assessment
  threat_level = number,          -- 0-100 (importance)
  is_detected = boolean,          -- Known to player
  detection_confidence = number,  -- 0-100% certainty
  radar_signature = number,       -- 0-100 (how visible)
  
  -- Activity
  mission_type = string,          -- "scout", "raid", "invasion", "transport"
  target_objective = string,      -- What mission is trying to accomplish
  detected_turn = number,         -- When first discovered
}
```

**UFO Functions:**
```lua
-- Registry access
UFORegistry.getUFO(ufo_id: string) → UFO | nil
UFORegistry.getUFOs() → UFO[]
UFORegistry.getDetectedUFOs() → UFO[]
UFORegistry.getUFOsByStatus(status: string) → UFO[]
UFORegistry.getUFOsInRegion(region: Region) → UFO[]
UFORegistry.getUFOsThreatening(base: Base) → UFO[]

-- Threat assessment
ufo:getThreatLevel() → number (0-100)
ufo:isDetected() → boolean
ufo:getDetectionConfidence() → number
ufo:getETA(destination: Province) → number (turns)
ufo:isInterceptable() → boolean
ufo:getPredictedPath() → Province[]

-- Status updates
ufo:updatePosition() → void
ufo:setDestination(province: Province) → void
ufo:takeDamage(amount: number) → void
ufo:completeAssignment() → void
ufo:retreat() → void

-- Player interaction
ufo:canIntercept(craft: Craft) → boolean
ufo:getInterceptionRoute(craft: Craft) → Province[]
```

**UFO Detection System**
```lua
-- Detect UFO via radar
UFORegistry.detectUFO(ufo: UFO, detection_power: number) → boolean
UFORegistry.confirmUFOSighting(ufo: UFO, confidence: number) → void

-- Calculate detection chance
local detection_chance = ufo:radar_signature - (detection_power * effectiveness)
if detection_chance <= 0 then
  -- UFO detected
  UFORegistry.registerDetection(ufo, detection_power)
end

-- Track over time
UFORegistry.updateDetectionStatus(ufo) → {
  is_detected: boolean,
  confidence: number,
  last_seen: turn_number,
  predicted_location: Province
}
```

**Threat Level Calculation:**
```lua
-- Threat = (Weapon Power × Crew Count) + (Distance Modifier) - (Defense Power)
-- 0-30: Low threat (scout/patrol)
-- 31-60: Medium threat (raid capable)
-- 61-100: High threat (invasion capable)

local threat = (ufo.weapon_power * ufo.crew_count / 100) + (100 - distance_to_base) - defense_rating
threat = math.max(0, math.min(100, threat))
```

**UFO Interception**
```lua
-- Check if craft can intercept
if ufo:isInterceptable() and craft:canReach(ufo:getCurrentLocation()) then
  -- Calculate intercept course
  local intercept_route = ufo:getInterceptionRoute(craft)
  
  -- Dispatch craft
  CraftSystem.setIntercourse(craft, intercept_route)
  print("Intercepting UFO: " .. ufo:getId())
end
```

**Mission Assignment**
- **Scout**: Gather intelligence on provinces, low threat
- **Raid**: Attack base/province, medium threat
- **Invasion**: Establish foothold, high threat
- **Transport**: Deliver cargo/reinforcements, variable threat
- **Research**: Collect samples/data, variable threat

**UFO Lifecycle**
1. Spawned in space (not yet detected)
2. Detected by radar (if in range)
3. Tracked throughout movement
4. Engages in mission (attacks, scouts, raids)
5. Completes mission or retreats
6. Despawns (leaves planet or destroyed)

---

## Performance Considerations

- Province graph uses A* pathfinding (O(n log n) complexity)
- Mission processing runs once per game turn (optimized for batching)
- World rendering uses viewport culling (only render visible provinces)
- Craft movement uses pre-calculated paths to reduce per-turn computation
- Radar coverage uses spatial indexing for fast region queries
- Cache world map data frequently (regions don't change frequently)
- Pre-calculate distance matrices for supply lines
- UFO updates only for detected units (detected UFOs)
- Calendar operations are O(1) (simple integer arithmetic)
- Day/Night calculations cached until turn advance

---

## Error Handling

Common errors and resolution:

```lua
-- Craft out of fuel
if not craft:canTravel(destination) then
  -- Refuel at base before traveling
  CraftSystem.refuelCraft(craft, craft:max_fuel - craft.fuel)
end

-- Mission expired
if mission:isExpired() then
  MissionSystem.completeMission(mission, false)  -- Mark as failed
  -- Generate new mission in region
end

-- Invalid province coordinates
local province = world:getProvince(q, r)
if not province then
  print("ERROR: No province at " .. q .. "," .. r)
end
```

---

## See Also

- **API_MISSIONS.md** - Mission deployment and generation
- **API_CRAFTS.md** - Craft statistics and capabilities
- **API_INTERCEPTION.md** - Combat mechanics
- **API_BASESCAPE.md** - Base operations and facilities
- **API_POLITICS.md** - Diplomatic effects and country relations
- **API_ECONOMY.md** - Resource systems and trade

---

**Last Updated:** October 22, 2025  
**API Status:** ✅ COMPLETE  
**Coverage:** 100% (All entities, functions, TOML, examples, integration documented)

