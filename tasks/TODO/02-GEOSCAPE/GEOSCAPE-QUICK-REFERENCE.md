# Geoscape System - Quick Reference

**Task ID:** TASK-025  
**Status:** TODO  
**Priority:** Critical  
**Time Estimate:** 140 hours (17-18 days)

---

## System Overview

The **Geoscape** is the strategic layer connecting all game modes. It manages:

- **Universe**: Multi-world container
- **World**: 80×40 hex grid map (1 tile = 500km)
- **Provinces**: Strategic nodes with biomes, economy, bases, crafts, missions
- **Countries**: Political entities with relations and funding
- **Regions**: Geographical grouping for missions and scoring
- **Crafts**: Deployment via hex pathfinding with fuel costs
- **Calendar**: Turn-based time (1 turn = 1 day, 360 days/year)
- **Travel**: Hex A* pathfinding with terrain costs
- **Bases**: Player operations centers
- **Portals**: Inter-world travel

---

## Core Mechanics

### Hex Grid System
- **Grid:** 80 columns × 40 rows
- **Scale:** 1 tile = 500km
- **Coordinates:** Axial (q, r) or Cube (x, y, z)
- **Distance:** Manhattan distance on cube coordinates
- **Pathfinding:** A* with terrain cost modifiers

### Calendar System
- **1 turn** = 1 day
- **6 days** = 1 week
- **5 weeks** = 1 month (30 days)
- **3 months** = 1 quarter (90 days)
- **4 quarters** = 1 year (360 days)
- **Only Geoscape can advance turns**

### Day/Night Cycle
- **Coverage:** 50% day, 50% night
- **Movement:** 4 tiles per day (left to right)
- **Full Cycle:** 20 days (80 tiles / 4 tiles per day)

### Province System
```lua
Province = {
    id = "province_001",
    position = {q = 40, r = 20}, -- Hex coordinates
    biomeId = "temperate_forest",
    countryId = "germany",
    regionId = "central_europe",
    isLand = true,
    connections = {}, -- Adjacent province IDs
    playerBase = nil,
    crafts = {}, -- Max 4
    missions = {},
    cities = {"Berlin", "Munich"}
}
```

### Craft System
```lua
Craft = {
    id = "craft_001",
    provinceId = "province_042",
    fuel = 100,
    travelPoints = 3, -- Travels per turn
    craftType = "air", -- "land", "air", "water"
    speed = 5, -- Max hex range per travel
    radarRange = 10 -- Mission detection range
}
```

### Travel Mechanics
1. **Select Base** → Shows stationed crafts
2. **Select Craft** → Shows operational range (hex pathfinding)
3. **Select Target Province** → Confirm travel
4. **System Executes:**
   - Deduct fuel from base stockpile
   - Use 1 travel point
   - Move craft to province
   - Auto-scan for missions (radar)
5. **After Interception Phase:**
   - All crafts auto-return to bases
   - Refuel from base stockpile

### Country Relations
- **Scale:** -2 (hostile) to +2 (allied)
- **Affects:** Monthly funding amount
- **Score-Based:** Performance in country's provinces
- **Funding Formula:** `funding = base * (1 + relations * 0.5) * (score / 100)`
- **Hostile Countries:** May generate enemy missions

### Biome System
```lua
Biome = {
    id = "temperate_forest",
    name = "Temperate Forest",
    interceptionBackground = "forest_interception.png",
    terrainTypes = ["forest", "plains", "urban"],
    baseConstructionCost = 1000000
}
```

### Portal System
```lua
Portal = {
    id = "earth_mars_portal",
    fromWorldId = "earth",
    fromProvinceId = "province_polar_01",
    toWorldId = "mars",
    toProvinceId = "mars_landing_zone",
    travelCost = 100, -- Fuel
    accessible = false -- Unlocked via research
}
```

---

## Implementation Phases

### Phase 1: Core Data Structures & World Grid (18h)
- Hex grid system (axial/cube coordinates)
- World data structure (80×40 tiles)
- Province graph with adjacency list

**Key Files:**
- `geoscape/systems/hex_grid.lua`
- `geoscape/logic/world.lua`
- `geoscape/logic/province.lua`
- `geoscape/logic/province_graph.lua`

---

### Phase 2: Calendar & Time System (10h)
- Turn-based calendar (1 day/turn)
- Day/night cycle (visual overlay)

**Key Files:**
- `geoscape/systems/calendar.lua`
- `geoscape/systems/daynight_cycle.lua`

---

### Phase 3: Geographic & Political Systems (16h)
- Biome definitions
- Country system (relations, funding)
- Region system (grouping, scoring)

**Key Files:**
- `geoscape/logic/biome.lua`
- `geoscape/logic/country.lua`
- `geoscape/logic/region.lua`
- `data/biomes.toml`
- `data/countries.toml`
- `data/regions.toml`

---

### Phase 4: Craft & Travel System (20h)
- Craft data structure
- Hex A* pathfinding for travel
- Fuel management
- Radar detection system
- Auto-return after interceptions

**Key Files:**
- `geoscape/logic/craft.lua`
- `geoscape/systems/travel_system.lua`
- `geoscape/logic/pathfinding.lua`
- `geoscape/systems/radar_system.lua`
- `geoscape/systems/craft_return.lua`

---

### Phase 5: Base Management (10h)
- Base data structure
- Base construction system (cost modifiers)

**Key Files:**
- `geoscape/logic/base.lua`
- `geoscape/systems/base_construction.lua`

---

### Phase 6: Universe & Portal System (12h)
- Universe manager (multi-world)
- Portal travel between worlds

**Key Files:**
- `geoscape/logic/universe.lua`
- `geoscape/logic/portal.lua`
- `data/universe.toml`
- `data/portals.toml`

---

### Phase 7: UI Implementation (30h)
- World map renderer (hex grid)
- Province info panel
- Craft deployment UI (range highlighting)
- Calendar & country relations widgets

**Key Files:**
- `geoscape/rendering/world_renderer.lua`
- `geoscape/ui/world_map.lua`
- `geoscape/ui/province_panel.lua`
- `geoscape/ui/craft_selector.lua`
- `geoscape/ui/range_highlighter.lua`
- `geoscape/ui/calendar_widget.lua`
- `geoscape/ui/country_relations_panel.lua`

**Grid Snapping:** All UI elements MUST snap to 24×24 pixel grid

---

### Phase 8: Integration & Polish (14h)
- State manager integration
- Turn processing system
- End turn logic
- Testing & debugging

**Key Files:**
- `geoscape/init.lua`
- `geoscape/systems/turn_processor.lua`
- `geoscape/tests/test_geoscape_integration.lua`

---

### Phase 9: Documentation (10h)
- API documentation
- FAQ updates
- User guide

**Key Files:**
- `wiki/API.md`
- `wiki/FAQ.md`
- `wiki/GEOSCAPE_GUIDE.md`

---

## Key APIs

### HexGrid
```lua
HexGrid.new(width, height) -- Create 80×40 grid
HexGrid:distance(q1, r1, q2, r2) -- Hex distance
HexGrid:neighbors(q, r) -- 6 adjacent hexes
HexGrid:toPixel(q, r) -- Hex to screen coords
HexGrid:toHex(x, y) -- Screen to hex coords
```

### TravelSystem
```lua
TravelSystem:canTravel(craftId, targetProvinceId) -- Check if travel possible
TravelSystem:getOperationalRange(craftId) -- Get all reachable provinces
TravelSystem:calculatePath(craftId, targetProvinceId) -- Get hex path
TravelSystem:travel(craftId, targetProvinceId) -- Execute travel
```

### Calendar
```lua
Calendar:advanceTurn() -- +1 day
Calendar:getDate() -- Formatted date string
Calendar:getDayOfYear() -- 1-360
```

### Universe
```lua
Universe:addWorld(world) -- Add world
Universe:switchWorld(worldId) -- Change active world
Universe:canTravel(craftId, portalId) -- Check portal access
```

---

## Data File Structure

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

[[tiles]]
q = 0
r = 0
terrain = "grassland"
cost = 1
isLand = true
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

### Biome Definition (biomes.toml)
```toml
[[biome]]
id = "temperate_forest"
name = "Temperate Forest"
interceptionBackground = "forest_interception.png"
terrainTypes = ["forest", "plains", "urban", "industrial"]
baseConstructionCost = 1000000
```

---

## Testing Checklist

### Unit Tests
- [x] Hex distance calculations
- [x] Hex neighbor finding
- [x] Calendar advancement (day/week/month/year)
- [x] A* pathfinding on hex grid
- [x] Craft type restrictions (land/air/water)
- [x] Funding calculation based on relations

### Integration Tests
- [ ] World loading from TOML
- [ ] Province graph connectivity
- [ ] Craft deployment flow
- [ ] Fuel deduction
- [ ] Calendar triggers (monthly funding)
- [ ] Portal travel between worlds

### Manual Tests
1. Run: `lovec "engine"`
2. Navigate to Geoscape
3. Verify hex grid renders
4. Test craft deployment
5. Test calendar advancement
6. Test mission detection
7. Test country relations
8. Test portal travel

---

## Debug Commands

```lua
-- Print craft position
print("[Geoscape] Craft " .. craftId .. " at province " .. provinceId)

-- Print operational range
local range = TravelSystem:getOperationalRange(craftId)
print("[Geoscape] Operational range: " .. #range .. " provinces")

-- Print calendar
print("[Calendar] " .. Calendar:getDate())

-- Print fuel status
print("[Fuel] Base: " .. base.fuel .. "/" .. base.maxFuel)
```

### Debug Keys
- **F9**: Toggle hex grid overlay
- **F12**: Toggle fullscreen
- **F1**: Show debug info (crafts, provinces, calendar)

---

## Performance Notes

- **Province Count:** ~100-200 for Earth (manageable)
- **Pathfinding:** Cache operational ranges per craft
- **Rendering:** Viewport culling for hex tiles
- **Day/Night:** Pre-calculate affected hexes per turn

---

## Future Enhancements

- Weather system (storms, fog)
- Political events (coups, wars)
- Trade routes between provinces
- UFO bases in provinces
- Terraforming over time
- Multi-base operations

---

**Full Task Document:** [TASK-025-geoscape-master-implementation.md](TASK-025-geoscape-master-implementation.md)
