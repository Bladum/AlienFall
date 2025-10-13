# Map Generation System - Task Analysis & Existing Work

**Created:** October 13, 2025  
**Purpose:** Compare new map generation requirements with existing tasks and codebase

---

## Executive Summary

The new **TASK-031** (Complete Map Generation System) builds upon existing work but adds critical missing pieces:

✅ **Already Implemented:**
- MapBlock system with 15×15 tile templates
- TOML-based MapBlock definitions
- Basic GridMap for block arrangement
- MapBlock loading and validation
- Procedural generation fallback

❌ **Missing (NEW in TASK-031):**
- **Biome → Terrain selection** (weighted system)
- **MapScript templates** (structured layouts)
- **MapBlock transformations** (rotate/mirror)
- **Team system** (4 sides, 8 colors)
- **Object placement** from MapBlocks
- **Per-team fog of war**
- **Mission-to-battlefield pipeline**

---

## Existing Map Generation Tasks

### TASK-029: Mission Deployment & Planning Screen
**Status:** TODO  
**Overlap with TASK-031:**
- Landing zone selection (1-4 based on map size)
- MapBlock grid visualization
- Objective sector marking
- Unit assignment to landing zones

**Integration:**
TASK-029 provides the **deployment planning UI** that shows the MapBlock grid created by TASK-031. The two tasks work together:
- TASK-031 generates MapBlock grid + battlefield
- TASK-029 shows grid to player for unit assignment
- Player assigns units → TASK-031 places them on battlefield

**No Conflicts:** Complementary systems

---

### TASK-030: Mission Salvage & Victory/Defeat
**Status:** TODO  
**Overlap with TASK-031:**
- Landing zone detection for unit survival
- MapBlock sector tracking

**Integration:**
TASK-030 uses landing zone data from TASK-031 to determine:
- Which units survive on defeat (those in landing zones)
- Salvage collection area

**No Conflicts:** Uses TASK-031 output

---

### TASK-025: Geoscape Master Implementation
**Status:** TODO  
**Overlap with TASK-031:**
- Province biome system
- Mission detection and deployment

**Integration:**
TASK-025 provides **province biome** property that TASK-031 uses for terrain selection:
```lua
-- TASK-025 creates province with biome
Province = {
    biome = "forest" -- TASK-031 uses this
}

-- TASK-031 uses biome to generate map
MissionToBattlefield.generate({
    provinceId = province.id, -- Gets biome from here
    size = "medium"
})
```

**Dependency:** TASK-031 requires TASK-025 Phase 1 (Province system)

---

## Existing Codebase Analysis

### Already Implemented

#### 1. MapBlock System (`engine/battlescape/map/map_block.lua`)
✅ **Working:**
- 15×15 tile templates
- TOML file loading
- Metadata (id, name, biome, difficulty, tags)
- Tile coordinate mapping

**Example:**
```lua
MapBlock = {
    id = "urban_street_01",
    name = "City Street",
    width = 15,
    height = 15,
    tiles = {}, -- [y][x] = terrainId
    metadata = {
        biome = "urban",
        difficulty = 2,
        tags = {"urban", "road", "buildings"}
    }
}
```

#### 2. GridMap System (`engine/battlescape/map/grid_map.lua`)
✅ **Working:**
- 4×4 to 7×7 MapBlock grid
- Block placement at grid positions
- World-to-block coordinate conversion
- Tile lookup by world coordinates

**Example:**
```lua
local gridMap = GridMap.new(5, 5) -- 5×5 blocks
gridMap:setBlock(2, 3, mapBlock) -- Place block
local terrain = gridMap:getTileAt(35, 47) -- World coords
```

#### 3. MapBlock Library (`mods/core/mapblocks/*.toml`)
✅ **Working:**
- ~15 MapBlock definitions
- Urban, forest, industrial themes
- Proper TOML format

**Example MapBlock:**
```toml
[metadata]
id = "urban_crossroads_01"
name = "City Crossroads"
biome = "urban"
difficulty = 2
tags = ["urban", "road", "intersection"]

[tiles]
"7_7" = "road"
"7_8" = "road"
# ... etc
```

#### 4. Procedural Generation (`engine/battlescape/map/map_generator.lua`)
✅ **Working:**
- Fallback procedural generation
- Cellular automata smoothing
- Random terrain placement

**Used when:** MapBlock system fails or for quick testing

---

### Missing Components (New in TASK-031)

#### 1. Biome System
❌ **Not Implemented**

**Needed:**
```lua
-- engine/geoscape/data/biomes.lua
Biome = {
    id = "forest",
    name = "Forest",
    terrains = {
        {id = "dense_forest", weight = 50},
        {id = "light_forest", weight = 30},
        {id = "grassland", weight = 15},
        {id = "water", weight = 5}
    }
}
```

**Current State:** Province has biome string, but no terrain weighting system

---

#### 2. MapScript System
❌ **Not Implemented**

**Needed:**
```lua
-- engine/battlescape/data/mapscripts/urban_crossroads.lua
MapScript = {
    id = "urban_crossroads",
    terrain = "urban_road",
    gridSize = {width = 5, height = 5},
    blocks = {
        {position = {x = 3, y = 3}, tags = {"intersection"}, priority = 1},
        {position = {x = 3, y = 1}, tags = {"road"}, priority = 2},
        -- ... etc
    },
    landingZones = {{x = 1, y = 1}},
    objectives = {{x = 3, y = 3, type = "capture"}}
}
```

**Current State:** MapBlocks selected randomly without structure

---

#### 3. MapBlock Transformations
❌ **Not Implemented**

**Needed:**
```lua
-- engine/battlescape/map/mapblock_transform.lua
MapBlockTransform.rotate90(mapBlock)
MapBlockTransform.mirrorHorizontal(mapBlock)
```

**Current State:** MapBlocks used as-is, no variety from same block

---

#### 4. Team System (4 Sides, 8 Colors)
❌ **Not Implemented**

**Needed:**
```lua
BattleSide = {PLAYER = 1, ALLY = 2, ENEMY = 3, NEUTRAL = 4}
TeamColor = {RED, GREEN, BLUE, YELLOW, CYAN, VIOLET, WHITE, GRAY}

BattleTeam = {
    side = BattleSide.PLAYER,
    color = TeamColor.GREEN,
    units = {}
}
```

**Current State:** Simple player vs enemy, no multi-team support

---

#### 5. Object Placement from MapBlocks
❌ **Not Implemented**

**Needed:**
```lua
-- In MapBlock TOML:
[[objects]]
position = {x = 7, y = 7}
type = "weapon"
itemId = "plasma_rifle"

-- Placement system:
ObjectPlacer.placeAll(battlefield, mapBlockGrid)
```

**Current State:** Objects manually added, not from MapBlock definitions

---

#### 6. Per-Team Fog of War
❌ **Not Implemented**

**Needed:**
```lua
FogOfWarManager.initialize(battlefield, teams)
FogOfWarManager.getTileVisibility(teamId, x, y)
```

**Current State:** Single fog of war for player only

---

#### 7. Mission-to-Battlefield Pipeline
❌ **Not Implemented**

**Needed:**
```lua
function MissionToBattlefield.generate(missionConfig)
    -- Province → Biome → Terrain → MapBlocks → MapScript → Battlefield
end
```

**Current State:** Manual map generation, no mission integration

---

## Task Dependencies

### Critical Path

```
TASK-025 (Geoscape - Province Biome)
    ↓
TASK-031 (Map Generation System)
    ↓
TASK-029 (Deployment Planning UI)
    ↓
TASK-030 (Salvage System)
```

### Recommended Implementation Order

1. **TASK-025 Phase 1-2** (Province + Biome system) - 10 hours
2. **TASK-031 Phase 1** (Biome & Terrain System) - 12 hours
3. **TASK-031 Phase 2** (MapScript System) - 18 hours
4. **TASK-031 Phase 3-4** (Transformations + Assembly) - 22 hours
5. **TASK-029** (Deployment Planning UI) - 54 hours (parallel with TASK-031 Phase 5-6)
6. **TASK-031 Phase 5-7** (Teams, Fog, Integration) - 38 hours
7. **TASK-030** (Salvage System) - 50 hours

**Total Time:** ~204 hours (25-26 days)

---

## Integration Points

### Province → Map Generation
```lua
-- In Geoscape mission selection
local missionConfig = {
    provinceId = selectedProvince.id,
    size = "medium", -- 5×5 grid
    type = "ufo_crash",
    playerUnits = squadUnits,
    enemyUnits = generateEnemies(difficulty)
}

-- Generate battlefield
local battlefield = MissionToBattlefield.generate(missionConfig)

-- Transition to deployment planning (TASK-029)
StateManager.push("deployment_planning", {
    battlefield = battlefield,
    missionConfig = missionConfig
})
```

### Deployment Planning → Battlescape
```lua
-- After player assigns units in TASK-029
function DeploymentPlanning:startBattle()
    -- Finalize unit placement using TASK-031 system
    UnitPlacer.placePlayerUnits(
        self.battlefield,
        self.assignedUnits,
        self.landingZones
    )
    
    -- Transition to battlescape
    StateManager.push("battlescape", {
        battlefield = self.battlefield
    })
end
```

### Battlescape → Salvage
```lua
-- After battle ends in Battlescape
function Battlescape:endBattle(outcome)
    local salvageData = {
        outcome = outcome, -- "victory" or "defeat"
        battlefield = self.battlefield,
        landingZones = self.landingZones, -- From TASK-031
        units = self.units
    }
    
    -- Transition to salvage screen (TASK-030)
    StateManager.push("salvage_screen", salvageData)
end
```

---

## Content Requirements

### MapBlock Library Expansion

**Current:** ~15 MapBlocks  
**Needed:** 100+ MapBlocks

**Breakdown by Biome:**
- Urban: 20 blocks (buildings, roads, intersections, parks)
- Forest: 15 blocks (dense/light forest, clearings, streams)
- Industrial: 15 blocks (warehouses, yards, factories)
- Rural: 10 blocks (farms, barns, fields)
- Water: 8 blocks (lakes, rivers, shores, docks)
- Mixed: 10 blocks (transition zones)
- Desert: 10 blocks (sand, rocks, oasis)
- Arctic: 8 blocks (snow, ice, research stations)
- Special: 10 blocks (UFO crash, base defense, special missions)

**Creation Rate:** ~30 minutes per MapBlock  
**Total Time:** 50 hours (6-7 days)

### MapScript Library Creation

**Needed:** 12+ MapScripts

**By Terrain:**
- Urban: crossroads, downtown, residential, industrial_zone
- Forest: clearing, river, road, dense
- Industrial: warehouse_district, factory_complex, storage_yard
- Rural: farmland, village
- Special: ufo_crash_forest, ufo_crash_urban, ufo_landing, xcom_base_small, xcom_base_large

**Creation Rate:** ~30 minutes per MapScript  
**Total Time:** 6 hours

---

## Testing Strategy

### Unit Tests (Per Phase)
- Phase 1: Biome terrain selection (weighted random)
- Phase 2: MapScript execution (grid generation)
- Phase 3: MapBlock transformations (rotate/mirror correctness)
- Phase 4: Battlefield assembly (tile copying accuracy)
- Phase 5: Team and unit placement (no overlaps)
- Phase 6: Fog of war (per-team independence)

### Integration Tests
1. **Biome → Battlefield**: Urban province generates urban map
2. **Mission Override**: UFO crash forces UFO terrain
3. **MapScript Variety**: Same terrain uses different MapScripts
4. **Transformation Variety**: Same MapBlock looks different
5. **Multi-Team**: 4 sides, 8 colors all functional
6. **Performance**: 7×7 map in <3 seconds

### Manual Test Scenarios
1. Urban mission in New York → City map with skyscrapers
2. Forest mission in Amazon → Dense forest with clearings
3. UFO crash in desert → Crash site with debris and fire
4. XCOM base defense → Facility layout with landing zones
5. Multi-faction battle → Player + ally vs 2 enemy factions

---

## Risk Analysis

### High Risk
❌ **MapBlock library too small** (15 blocks)
- **Impact:** Repetitive maps, poor player experience
- **Mitigation:** Prioritize MapBlock creation, use transformations
- **Timeline:** +50 hours for content creation

❌ **Performance with 7×7 grids** (105×105 tiles)
- **Impact:** Long generation times, poor UX
- **Mitigation:** Profile and optimize tile copying, use caching
- **Timeline:** +8 hours for optimization

### Medium Risk
⚠️ **MapScript complexity**
- **Impact:** Hard to author, bugs in placement
- **Mitigation:** Good documentation, visual editor (future)
- **Timeline:** +6 hours for editor prototype

⚠️ **Multi-team AI coordination**
- **Impact:** Teams don't coordinate, poor AI behavior
- **Mitigation:** Team-aware AI (separate task)
- **Timeline:** No immediate impact, future enhancement

### Low Risk
✅ **Biome system extensibility**
- **Impact:** Hard to add new biomes
- **Mitigation:** Data-driven design from start
- **Timeline:** No impact

✅ **Fog of war performance**
- **Impact:** Slow with 8 teams
- **Mitigation:** Spatial hashing, caching
- **Timeline:** +4 hours if issues arise

---

## Success Metrics

### Quantitative
- ✅ Map generation time: <3 seconds for 7×7 grid
- ✅ MapBlock pool: 100+ blocks across 8 biomes
- ✅ MapScript library: 12+ templates
- ✅ Team support: 4 sides × 8 colors functional
- ✅ Fog of war: Per-team, <100ms calculation
- ✅ Battlefield size: 60×60 to 105×105 tiles
- ✅ Object placement: 20-50 objects per map

### Qualitative
- ✅ Maps feel thematically appropriate to province
- ✅ MapBlock transformations create visual variety
- ✅ MapScripts provide structured, interesting layouts
- ✅ Landing zones positioned logically
- ✅ Enemy spawns challenging but fair
- ✅ Multi-team battles visually distinct
- ✅ Fog of war creates tension and discovery

---

## Conclusion

**TASK-031** is a **critical expansion** of existing map generation work. While the foundation (MapBlocks, GridMap) exists, the new task adds the **strategic integration** and **content variety** needed for a complete system.

**Key Additions:**
1. **Biome → Terrain → MapScript** pipeline connects Geoscape to Battlescape
2. **MapScript templates** provide structured, interesting layouts
3. **MapBlock transformations** multiply content variety
4. **Team system** enables complex multi-faction battles
5. **Object placement** from MapBlocks adds tactical depth
6. **Per-team fog of war** supports multi-faction gameplay

**Dependencies:**
- TASK-025 (Province biome)
- MapBlock library expansion (50 hours content creation)

**Timeline:** 96 hours implementation + 50 hours content = 146 hours (18 days)

**Recommendation:** Start with TASK-025 Phase 1-2, then implement TASK-031 in parallel with content creation.
