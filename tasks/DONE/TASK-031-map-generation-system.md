# Task: Complete Map Generation System - Biome, MapScript, and Battlefield Assembly

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a comprehensive procedural map generation system that transforms strategic-level mission data into playable tactical battlefields. The system flows from **Province Biome** → **Terrain Selection** → **MapScript Execution** → **MapBlock Grid Assembly** → **Team Placement** → **Battlefield Creation** with full support for multiple battle sides (player, ally, enemy, neutral) and up to 8 color-coded teams.

This creates the bridge between Geoscape strategic missions and Battlescape tactical combat.

---

## Purpose

**Why is this needed?**
- Connects strategic mission selection (Geoscape) to tactical combat (Battlescape)
- Provides infinite replayability through procedural battlefield generation
- Enables mission-specific map requirements (UFO crashes, XCOM base defense, special objectives)
- Supports scalable difficulty (4×4 to 7×7 maps with 1-4 landing zones)
- Creates thematic consistency (urban missions look urban, forest missions have trees)
- Enables team-based tactical gameplay (player, allies, enemies, neutrals)

**What problem does it solve?**
- Currently no connection between mission type and map generation
- No biome/terrain system for thematic consistency
- No MapScript system for structured layouts (roads, UFOs, rivers)
- No team placement algorithm for multi-faction battles
- No transformation system for MapBlock variety (rotation, mirroring)
- Battlefield generation is disconnected from strategic context

---

## System Architecture

### Complete Generation Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. MISSION CONTEXT (from Geoscape)                                 │
│    - Province → Biome (forest, urban, industrial, etc.)            │
│    - Mission Type (site, UFO crash, base defense)                  │
│    - Mission Size (small=4×4, medium=5×5, large=6×6, huge=7×7)    │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 2. TERRAIN SELECTION (weighted by biome)                           │
│    - Biome defines available terrains with weights                 │
│    - Example: Forest biome → 50% trees, 30% grass, 20% water      │
│    - Mission can override terrain (e.g., force "ufo_crash" terrain)│
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 3. MAPBLOCK POOL FILTERING                                         │
│    - Get all MapBlocks matching selected terrain                   │
│    - Filter by difficulty, tags, special requirements              │
│    - Example: "urban_road" terrain → 23 eligible MapBlocks         │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 4. MAPSCRIPT SELECTION & EXECUTION                                 │
│    - Choose MapScript from terrain (weighted random)               │
│    - MapScript defines block placement order and positions         │
│    - Examples: "city_crossroads", "forest_river", "ufo_landing"   │
│    - Builds MapBlock Grid (4×4 to 7×7 2D array)                   │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 5. MISSION OBJECTIVES MAPPING                                      │
│    - Mark landing zones (1-4 based on map size)                    │
│    - Mark objective sectors (defend, capture, critical)            │
│    - Mark high-value positions for AI teams                        │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 6. MAPBLOCK TRANSFORMATIONS                                        │
│    - Apply random transformations to MapBlocks                     │
│    - Operations: Mirror (horizontal/vertical), Rotate (90/180/270) │
│    - Creates variety from same MapBlocks                           │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 7. BATTLEFIELD TILE ASSEMBLY                                       │
│    - Copy tiles from all MapBlocks to single 2D array              │
│    - Track sector ownership (which MapBlock each tile belongs to)  │
│    - Size: 60×60 (4×4) to 105×105 (7×7) tiles                     │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 8. OBJECTS & ITEMS PLACEMENT                                       │
│    - Place MapBlock-defined objects (weapons, crates, furniture)   │
│    - Add UFO components if crash/landing mission                   │
│    - Add destructible terrain elements                             │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 9. TEAM & UNIT PLACEMENT                                           │
│    - 4 Battle Sides: Player, Ally, Enemy, Neutral                  │
│    - Up to 8 Teams: Red, Green, Blue, Yellow, Cyan, Violet, White, │
│      Gray (each team belongs to a side)                            │
│    - Player units → Landing Zones                                  │
│    - Enemy/AI units → High-value MapBlocks                         │
│    - Each team color-codes their units                             │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 10. FOG OF WAR & VISIBILITY                                        │
│     - Calculate initial fog of war per team                        │
│     - Set random unit facing directions                            │
│     - Initialize visibility state                                  │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 11. ENVIRONMENTAL EFFECTS (Optional)                               │
│     - Random explosions (site crash missions)                      │
│     - Pre-battle damage (elerium explosion effects)                │
│     - Weather effects (rain, fog, snow)                            │
└────────────────────┬────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 12. FINAL BATTLEFIELD                                              │
│     - Complete BattleTile 2D array                                 │
│     - BattleTile = MapTile + Unit + Objects + Smoke/Fire + FoW    │
│     - Ready for Battlescape tactical combat                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Requirements

### Functional Requirements

#### Biome & Terrain System
- [ ] Province has biome property (forest, urban, industrial, water, rural, mixed, desert, arctic)
- [ ] Each biome defines available terrains with weights (e.g., forest: 50% trees, 30% grass, 20% water)
- [ ] Mission type can override terrain selection (e.g., base defense forces "xcom_base" terrain)
- [ ] Terrain determines which MapBlocks are eligible for selection

#### MapScript System
- [ ] Each terrain has multiple MapScripts (templates for MapBlock placement)
- [ ] MapScript defines:
  - Grid size (4×4, 5×5, 6×6, 7×7)
  - Block placement order and positions
  - Special features (roads, rivers, UFO landing sites)
  - Landing zone positions
  - Objective sector markers
- [ ] MapScript examples:
  - `urban_crossroads`: City with intersecting roads
  - `forest_clearing`: Dense forest with central clearing
  - `ufo_crash_site`: Crash site with debris field
  - `xcom_base_defense`: XCOM facility layout

#### MapBlock Grid Assembly
- [ ] MapScript execution creates MapBlock Grid (2D array of MapBlock references)
- [ ] Grid size: 4×4 (small) to 7×7 (huge) MapBlocks
- [ ] Each grid position contains reference to selected MapBlock
- [ ] MapBlocks selected from filtered pool (terrain + biome matching)

#### Objective & Team Setup
- [ ] Landing zones marked in MapBlock Grid (1-4 zones based on size)
- [ ] Objective sectors marked (defend, capture, critical, high-value for AI)
- [ ] Team distribution across MapBlocks
- [ ] 4 battle sides: PLAYER, ALLY, ENEMY, NEUTRAL
- [ ] 8 team colors: Red, Green, Blue, Yellow, Cyan, Violet, White, Gray

#### MapBlock Transformations
- [ ] Random transformations applied to MapBlocks before tile copy
- [ ] Transformations: Mirror Horizontal, Mirror Vertical, Rotate 90°, Rotate 180°, Rotate 270°
- [ ] Creates variety from limited MapBlock pool
- [ ] Preserves MapBlock functionality (doors still work, etc.)

#### Battlefield Assembly
- [ ] Copy all MapBlock tiles to single 2D battlefield array
- [ ] Size: 60×60 tiles (4×4 grid) to 105×105 tiles (7×7 grid)
- [ ] Track which sector (MapBlock) each tile belongs to
- [ ] Maintain terrain properties (passable, cover, sight cost)

#### Objects & Items
- [ ] MapBlocks can define object spawn positions
- [ ] Objects: Weapons, grenades, medkits, ammo crates
- [ ] Furniture: Tables, chairs, crates, barrels
- [ ] Mission-specific: UFO components, alien artifacts
- [ ] Objects placed during battlefield assembly

#### Unit Placement
- [ ] Player units spawn at landing zone MapBlocks
- [ ] Enemy/AI units spawn at high-priority MapBlocks
- [ ] Neutral units (civilians) spawn at designated sectors
- [ ] Each team color-codes their units
- [ ] Unit facing direction randomized initially

#### Fog of War & Visibility
- [ ] Calculate initial fog of war for each team
- [ ] Each team has independent visibility state
- [ ] Fog updates as units move and gain line of sight

#### Environmental Effects (Optional)
- [ ] Random explosions for crash site missions
- [ ] Pre-battle damage (destroyed walls, craters)
- [ ] Weather effects (rain, fog, snow reduce visibility)
- [ ] Mission-specific events (elerium explosion damage)

### Technical Requirements
- [ ] Biome data structure with terrain weights
- [ ] Terrain registry with MapBlock associations
- [ ] MapScript data format (Lua or TOML)
- [ ] MapScript execution engine
- [ ] MapBlock transformation functions (rotate, mirror)
- [ ] Efficient tile copying (avoid redundant operations)
- [ ] Team management system (sides, colors, unit lists)
- [ ] Object spawn system integrated with battlefield
- [ ] Fog of war calculation per team
- [ ] Performance: Generate 7×7 map in <3 seconds

### Acceptance Criteria
- [ ] Mission in urban province generates urban-themed map
- [ ] Mission in forest province generates forest-themed map
- [ ] UFO crash missions have UFO MapBlocks with debris
- [ ] Base defense missions use XCOM facility MapBlocks
- [ ] Landing zones positioned according to map size (1-4 zones)
- [ ] Enemy units spawn in logical positions (not in player landing zone)
- [ ] All 4 battle sides (player, ally, enemy, neutral) supported
- [ ] Up to 8 teams with distinct colors functional
- [ ] MapBlock transformations create visual variety
- [ ] Generated battlefield is fully playable in Battlescape
- [ ] Objects and items spawn correctly on battlefield
- [ ] Fog of war correctly initialized per team

---

## Plan

### Phase 1: Biome & Terrain System (12 hours)

#### Step 1.1: Biome Data Structure (3 hours)
**Description:** Define biome system with terrain weights

**Files to create:**
- `engine/geoscape/data/biomes.lua` - Biome definitions
- `engine/battlescape/data/terrains.lua` - Terrain definitions

**Biome Structure:**
```lua
Biome = {
    id = "forest",
    name = "Forest",
    terrains = {
        {id = "dense_forest", weight = 50},
        {id = "light_forest", weight = 30},
        {id = "grassland", weight = 15},
        {id = "water", weight = 5}
    },
    -- Visual theming
    backgroundColor = {r = 34, g = 139, b = 34},
    ambientLight = {r = 0.8, g = 1.0, b = 0.8}
}
```

**Terrain Structure:**
```lua
Terrain = {
    id = "dense_forest",
    name = "Dense Forest",
    description = "Heavy tree coverage",
    mapBlockTags = {"forest", "trees", "dense"},
    mapScripts = {
        {id = "forest_clearing", weight = 30},
        {id = "forest_river", weight = 20},
        {id = "forest_road", weight = 15},
        {id = "forest_random", weight = 35}
    }
}
```

**Estimated time:** 3 hours

---

#### Step 1.2: Terrain Weighting System (3 hours)
**Description:** Implement weighted random terrain selection

**Files to create:**
- `engine/battlescape/map/terrain_selector.lua`
- `engine/battlescape/tests/test_terrain_selector.lua`

**Key Functions:**
```lua
TerrainSelector.selectFromBiome(biome, missionOverride)
-- Returns terrain based on biome weights or mission override

TerrainSelector.getEligibleMapBlocks(terrain)
-- Returns MapBlocks matching terrain tags
```

**Test Cases:**
- Forest biome generates forest terrains 80%+ of the time
- Mission override forces specific terrain
- No terrain selection errors with missing biomes

**Estimated time:** 3 hours

---

#### Step 1.3: MapBlock Tagging & Filtering (6 hours)
**Description:** Add biome/terrain tags to MapBlock metadata, implement filtering

**Files to modify:**
- `engine/battlescape/map/map_block.lua` - Add tags property
- `mods/core/mapblocks/*.toml` - Add tags to existing MapBlocks

**MapBlock Metadata Extension:**
```toml
[metadata]
id = "urban_street_01"
name = "City Street"
biome = "urban"
tags = ["urban", "road", "buildings", "paved"]
difficulty = 2
```

**Files to create:**
- `engine/battlescape/map/mapblock_filter.lua` - Filtering logic

**Key Functions:**
```lua
MapBlockFilter.byTerrain(blockPool, terrain)
-- Returns blocks matching terrain tags

MapBlockFilter.byDifficulty(blockPool, minDiff, maxDiff)
-- Filter by difficulty range

MapBlockFilter.byTags(blockPool, requiredTags, excludedTags)
-- Advanced tag-based filtering
```

**Estimated time:** 6 hours

---

### Phase 2: MapScript System (18 hours)

#### Step 2.1: MapScript Data Format (4 hours)
**Description:** Define MapScript format and data structure

**Files to create:**
- `engine/battlescape/data/mapscripts/` - MapScript directory
- `engine/battlescape/data/mapscripts/urban_crossroads.lua` - Example MapScript
- `engine/battlescape/data/mapscripts/forest_clearing.lua` - Example MapScript
- `engine/battlescape/data/mapscripts/ufo_crash.lua` - Example MapScript

**MapScript Format:**
```lua
return {
    id = "urban_crossroads",
    name = "Urban Crossroads",
    description = "City intersection with buildings on corners",
    terrain = "urban_road",
    gridSize = {width = 5, height = 5}, -- 5×5 MapBlocks
    
    -- Block placement instructions
    blocks = {
        -- Road spine (north-south)
        {position = {x = 3, y = 1}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 3, y = 2}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 3, y = 3}, tags = {"road", "intersection"}, priority = 1},
        {position = {x = 3, y = 4}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 3, y = 5}, tags = {"road", "straight"}, priority = 1},
        
        -- Road spine (east-west)
        {position = {x = 1, y = 3}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 2, y = 3}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 4, y = 3}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 5, y = 3}, tags = {"road", "straight"}, priority = 1},
        
        -- Buildings (corners)
        {position = {x = 1, y = 1}, tags = {"building", "urban"}, priority = 2},
        {position = {x = 5, y = 1}, tags = {"building", "urban"}, priority = 2},
        {position = {x = 1, y = 5}, tags = {"building", "urban"}, priority = 2},
        {position = {x = 5, y = 5}, tags = {"building", "urban"}, priority = 2},
        
        -- Filler blocks (remaining positions)
        {position = {x = 2, y = 1}, tags = {"urban", "any"}, priority = 3},
        {position = {x = 4, y = 1}, tags = {"urban", "any"}, priority = 3},
        -- ... etc
    },
    
    -- Landing zones
    landingZones = {
        {mapBlockPosition = {x = 1, y = 1}}, -- NW corner
        {mapBlockPosition = {x = 5, y = 5}}, -- SE corner (if medium+)
    },
    
    -- Objective markers
    objectives = {
        {mapBlockPosition = {x = 3, y = 3}, type = "capture"}, -- Center intersection
        {mapBlockPosition = {x = 5, y = 1}, type = "defend"}, -- NE building
    },
    
    -- AI high-value positions
    aiPriority = {
        {mapBlockPosition = {x = 3, y = 3}, value = 10}, -- Center control
        {mapBlockPosition = {x = 1, y = 5}, value = 7},  -- SW building
    }
}
```

**Estimated time:** 4 hours

---

#### Step 2.2: MapScript Execution Engine (8 hours)
**Description:** Implement MapScript interpreter and MapBlock Grid builder

**Files to create:**
- `engine/battlescape/map/mapscript_engine.lua`
- `engine/battlescape/tests/test_mapscript_engine.lua`

**Key Functions:**
```lua
MapScriptEngine.execute(mapScript, mapBlockPool)
-- Executes MapScript instructions
-- Returns MapBlockGrid (2D array of MapBlock references)

MapScriptEngine._selectBlockForPosition(instruction, pool)
-- Selects best MapBlock matching tags and priority

MapScriptEngine._fillRemainingPositions(grid, pool)
-- Fills empty grid positions with any eligible blocks
```

**MapBlockGrid Structure:**
```lua
MapBlockGrid = {
    width = 5,  -- Grid dimensions
    height = 5,
    blocks = {}, -- [y][x] = MapBlock reference
    landingZones = {}, -- Landing zone positions
    objectives = {}, -- Objective markers
    aiPriority = {} -- AI high-value positions
}
```

**Test Cases:**
- MapScript with 5×5 grid generates 25 MapBlock grid
- Priority 1 blocks placed before priority 2
- Tag filtering selects correct MapBlocks
- Missing blocks filled with fallback selections

**Estimated time:** 8 hours

---

#### Step 2.3: MapScript Library Creation (6 hours)
**Description:** Create 8-12 standard MapScripts covering common scenarios

**Files to create:**
- `urban_crossroads.lua` - City intersection
- `urban_downtown.lua` - Dense city blocks
- `forest_clearing.lua` - Forest with central open area
- `forest_river.lua` - Forest split by river
- `industrial_warehouse.lua` - Warehouse district
- `rural_farmland.lua` - Farms and fields
- `ufo_crash_forest.lua` - UFO crash in forest
- `ufo_crash_urban.lua` - UFO crash in city
- `ufo_landing_field.lua` - UFO landed in field
- `xcom_base_small.lua` - Small XCOM base layout
- `xcom_base_large.lua` - Large XCOM base layout
- `generic_random.lua` - Fallback random placement

**Estimated time:** 6 hours (30min each)

---

### Phase 3: MapBlock Transformations (8 hours)

#### Step 3.1: Transformation Functions (4 hours)
**Description:** Implement rotate and mirror operations for MapBlocks

**Files to create:**
- `engine/battlescape/map/mapblock_transform.lua`
- `engine/battlescape/tests/test_mapblock_transform.lua`

**Key Functions:**
```lua
MapBlockTransform.rotate90(mapBlock)
-- Rotates MapBlock 90° clockwise
-- Returns new MapBlock with rotated tiles

MapBlockTransform.rotate180(mapBlock)
MapBlockTransform.rotate270(mapBlock)

MapBlockTransform.mirrorHorizontal(mapBlock)
-- Mirrors MapBlock left-right

MapBlockTransform.mirrorVertical(mapBlock)
-- Mirrors MapBlock top-bottom

MapBlockTransform.applyRandom(mapBlock, probability)
-- 50% chance to apply random transformation
```

**Tile Coordinate Transformations:**
```lua
-- Rotate 90° clockwise: (x, y) → (15-y, x)
-- Rotate 180°: (x, y) → (15-x, 15-y)
-- Rotate 270°: (x, y) → (y, 15-x)
-- Mirror H: (x, y) → (15-x, y)
-- Mirror V: (x, y) → (x, 15-y)
```

**Test Cases:**
- Rotate 90° four times returns to original
- Mirror H twice returns to original
- All tiles accounted for after transformation
- Edge tiles placed correctly

**Estimated time:** 4 hours

---

#### Step 3.2: Integration with MapScript Engine (4 hours)
**Description:** Apply transformations during MapBlock Grid assembly

**Files to modify:**
- `engine/battlescape/map/mapscript_engine.lua`

**Integration Logic:**
```lua
function MapScriptEngine._selectBlockForPosition(instruction, pool)
    -- Select base MapBlock
    local block = selectFromPool(pool, instruction.tags)
    
    -- Apply random transformation (50% chance)
    if math.random() < 0.5 then
        local transforms = {
            MapBlockTransform.rotate90,
            MapBlockTransform.rotate180,
            MapBlockTransform.rotate270,
            MapBlockTransform.mirrorHorizontal,
            MapBlockTransform.mirrorVertical
        }
        local transform = transforms[math.random(#transforms)]
        block = transform(block)
    end
    
    return block
end
```

**Test Cases:**
- Generated grids show transformation variety
- Same MapBlock appears different in different positions
- Transformations don't break MapBlock functionality

**Estimated time:** 4 hours

---

### Phase 4: Battlefield Assembly (14 hours)

#### Step 4.1: Tile Copying System (6 hours)
**Description:** Copy MapBlock tiles to single battlefield array

**Files to create:**
- `engine/battlescape/map/battlefield_assembler.lua`
- `engine/battlescape/tests/test_battlefield_assembler.lua`

**Key Functions:**
```lua
BattlefieldAssembler.assemble(mapBlockGrid)
-- Returns Battlefield with all tiles copied

BattlefieldAssembler._copyBlockTiles(battlefield, block, startX, startY)
-- Copies 15×15 tiles from MapBlock to battlefield at position

BattlefieldAssembler._calculateSize(gridWidth, gridHeight)
-- Returns battlefield size (60-105 tiles per dimension)
```

**Battlefield Structure:**
```lua
Battlefield = {
    width = 75,  -- Total tiles (5×15)
    height = 75,
    tiles = {}, -- [y][x] = BattleTile
    sectors = {}, -- [y][x] = mapBlockIndex (which sector)
    landingZones = {}, -- From MapBlockGrid
    objectives = {}, -- From MapBlockGrid
}
```

**Test Cases:**
- 4×4 grid produces 60×60 battlefield
- 7×7 grid produces 105×105 battlefield
- All MapBlock tiles copied correctly
- Sector tracking accurate

**Estimated time:** 6 hours

---

#### Step 4.2: Object Placement System (8 hours)
**Description:** Place objects defined in MapBlocks onto battlefield

**Files to modify:**
- `engine/battlescape/map/map_block.lua` - Add objects array to MapBlock

**MapBlock Object Definition:**
```toml
[[objects]]
position = {x = 7, y = 7}
type = "weapon"
itemId = "plasma_rifle"

[[objects]]
position = {x = 8, y = 8}
type = "furniture"
itemId = "crate_large"

[[objects]]
position = {x = 3, y = 5}
type = "interactive"
itemId = "door_locked"
```

**Files to create:**
- `engine/battlescape/map/object_placer.lua`
- `engine/battlescape/logic/battlefield_object.lua`

**Key Functions:**
```lua
ObjectPlacer.placeAll(battlefield, mapBlockGrid)
-- Iterates through all MapBlocks and places their objects

ObjectPlacer._placeObject(battlefield, worldX, worldY, objectDef)
-- Places single object at world coordinates

BattlefieldObject.new(x, y, type, itemId)
-- Creates battlefield object entity
```

**Test Cases:**
- Objects placed at correct world coordinates
- Multiple objects on same tile handled correctly
- Object types correctly categorized (weapon, furniture, interactive)

**Estimated time:** 8 hours

---

### Phase 5: Team & Unit Placement (12 hours)

#### Step 5.1: Battle Sides & Teams System (4 hours)
**Description:** Define 4 battle sides and 8 team colors

**Files to create:**
- `engine/battlescape/logic/battle_sides.lua`
- `engine/battlescape/logic/battle_team.lua`

**Battle Sides:**
```lua
BattleSide = {
    PLAYER = 1,
    ALLY = 2,
    ENEMY = 3,
    NEUTRAL = 4
}
```

**Team Colors:**
```lua
TeamColor = {
    RED = {r = 255, g = 0, b = 0, name = "Red"},
    GREEN = {r = 0, g = 255, b = 0, name = "Green"},
    BLUE = {r = 0, g = 100, b = 255, name = "Blue"},
    YELLOW = {r = 255, g = 255, b = 0, name = "Yellow"},
    CYAN = {r = 0, g = 255, b = 255, name = "Cyan"},
    VIOLET = {r = 200, g = 0, b = 255, name = "Violet"},
    WHITE = {r = 255, g = 255, b = 255, name = "White"},
    GRAY = {r = 128, g = 128, b = 128, name = "Gray"}
}
```

**BattleTeam Structure:**
```lua
BattleTeam = {
    id = "team_001",
    name = "XCOM Squad Alpha",
    side = BattleSide.PLAYER,
    color = TeamColor.GREEN,
    units = {}, -- Unit IDs
    ai = nil -- AI controller (if not player)
}
```

**Estimated time:** 4 hours

---

#### Step 5.2: Unit Placement Algorithm (5 hours)
**Description:** Place units at landing zones and high-value sectors

**Files to create:**
- `engine/battlescape/map/unit_placer.lua`
- `engine/battlescape/tests/test_unit_placer.lua`

**Key Functions:**
```lua
UnitPlacer.placePlayerUnits(battlefield, units, landingZones)
-- Places player units at landing zone MapBlocks

UnitPlacer.placeEnemyUnits(battlefield, units, aiPriorityPositions)
-- Places enemy units at high-value MapBlocks

UnitPlacer._findSpawnPoints(battlefield, mapBlockX, mapBlockY, count)
-- Finds valid spawn positions within MapBlock
-- Prefers edges, avoids blocking doorways

UnitPlacer._randomizeFacing(unit)
-- Sets random initial facing direction (0-5 for hex)
```

**Spawn Point Selection Logic:**
- Landing zones: Prefer MapBlock edges (top/bottom rows)
- High-value: Prefer center or cover positions
- Avoid: Impassable terrain, other units, doorways
- Spacing: Minimum 2 tiles between units

**Test Cases:**
- All player units placed at landing zones
- Enemy units don't spawn in landing zones
- Units don't overlap
- All units have valid facing direction

**Estimated time:** 5 hours

---

#### Step 5.3: Team Assignment Integration (3 hours)
**Description:** Assign units to teams and apply color coding

**Files to modify:**
- `engine/battlescape/logic/battlefield.lua` - Add teams array
- `engine/battlescape/entities/unit.lua` - Add teamId property

**Integration:**
```lua
function Battlefield:initializeTeams(missionConfig)
    -- Create player team
    local playerTeam = BattleTeam.new("player", BattleSide.PLAYER, TeamColor.GREEN)
    table.insert(self.teams, playerTeam)
    
    -- Assign player units
    for _, unit in ipairs(missionConfig.playerUnits) do
        unit.teamId = playerTeam.id
        unit.color = playerTeam.color
        playerTeam.units[unit.id] = unit
    end
    
    -- Create enemy teams
    for i, enemyGroup in ipairs(missionConfig.enemyGroups) do
        local color = self:_getNextEnemyColor(i)
        local enemyTeam = BattleTeam.new("enemy_" .. i, BattleSide.ENEMY, color)
        table.insert(self.teams, enemyTeam)
        
        for _, unit in ipairs(enemyGroup.units) do
            unit.teamId = enemyTeam.id
            unit.color = enemyTeam.color
            enemyTeam.units[unit.id] = unit
        end
    end
end
```

**Estimated time:** 3 hours

---

### Phase 6: Fog of War & Final Setup (10 hours)

#### Step 6.1: Per-Team Fog of War (6 hours)
**Description:** Calculate initial fog of war for each team

**Files to create:**
- `engine/battlescape/logic/fog_of_war_manager.lua`
- `engine/battlescape/tests/test_fog_of_war_manager.lua`

**Key Functions:**
```lua
FogOfWarManager.initialize(battlefield, teams)
-- Creates fog of war state for each team

FogOfWarManager.calculateVisibility(team, battlefield)
-- Calculates visible tiles for team based on unit positions

FogOfWarManager.getTileVisibility(teamId, x, y)
-- Returns visibility state: HIDDEN, EXPLORED, VISIBLE
```

**Fog of War State:**
```lua
FogOfWarState = {
    teamId = "team_001",
    tiles = {}, -- [y][x] = {state, lastSeenTurn}
    visibleUnits = {}, -- Enemy units currently visible
    knownUnits = {} -- Enemy units seen previously
}
```

**Test Cases:**
- Each team has independent fog of war
- Units can see tiles in their sight range
- Walls block line of sight
- Fog updates when units move

**Estimated time:** 6 hours

---

#### Step 6.2: Environmental Effects (4 hours)
**Description:** Add optional mission-specific effects

**Files to create:**
- `engine/battlescape/map/environmental_effects.lua`

**Effect Types:**
```lua
EnvironmentalEffects.applyCrashDamage(battlefield, crashSiteBlocks)
-- Random explosions, destroyed walls, craters

EnvironmentalEffects.applyEleriumExplosion(battlefield, epicenter)
-- Large explosion with fire and smoke

EnvironmentalEffects.applyWeatherEffects(battlefield, weatherType)
-- Rain, fog, snow (visibility modifiers)
```

**Crash Site Damage:**
- 10-20 random tiles with destroyed terrain
- 5-10 fire tiles
- 3-5 smoke clouds

**Estimated time:** 4 hours

---

### Phase 7: Integration & Testing (16 hours)

#### Step 7.1: Mission-to-Battlefield Pipeline (8 hours)
**Description:** Connect mission selection to battlefield generation

**Files to create:**
- `engine/battlescape/logic/mission_to_battlefield.lua`
- `engine/battlescape/tests/test_mission_to_battlefield.lua`

**Complete Pipeline:**
```lua
function MissionToBattlefield.generate(missionConfig)
    -- 1. Get biome from province
    local biome = Geoscape.getProvinceBiome(missionConfig.provinceId)
    
    -- 2. Select terrain
    local terrain = TerrainSelector.selectFromBiome(biome, missionConfig.terrainOverride)
    
    -- 3. Filter MapBlocks
    local mapBlockPool = MapBlockFilter.byTerrain(MapBlock.getAll(), terrain)
    
    -- 4. Select and execute MapScript
    local mapScript = TerrainSelector.selectMapScript(terrain, missionConfig.size)
    local mapBlockGrid = MapScriptEngine.execute(mapScript, mapBlockPool)
    
    -- 5. Apply transformations (done in engine)
    
    -- 6. Assemble battlefield
    local battlefield = BattlefieldAssembler.assemble(mapBlockGrid)
    
    -- 7. Place objects
    ObjectPlacer.placeAll(battlefield, mapBlockGrid)
    
    -- 8. Place units
    UnitPlacer.placePlayerUnits(battlefield, missionConfig.playerUnits, mapBlockGrid.landingZones)
    UnitPlacer.placeEnemyUnits(battlefield, missionConfig.enemyUnits, mapBlockGrid.aiPriority)
    
    -- 9. Initialize teams
    battlefield:initializeTeams(missionConfig)
    
    -- 10. Setup fog of war
    FogOfWarManager.initialize(battlefield, battlefield.teams)
    
    -- 11. Apply environmental effects
    if missionConfig.environmentalEffects then
        EnvironmentalEffects.apply(battlefield, missionConfig.environmentalEffects)
    end
    
    return battlefield
end
```

**Estimated time:** 8 hours

---

#### Step 7.2: Integration Testing (8 hours)
**Description:** End-to-end testing of complete system

**Test Cases:**
1. **Urban Mission Test**
   - Province with urban biome
   - Generates city map with buildings and roads
   - Player spawns at landing zone
   - Enemies spawn in buildings

2. **Forest Mission Test**
   - Province with forest biome
   - Generates forest map with trees and clearings
   - MapBlock transformations visible
   - Units placed in valid positions

3. **UFO Crash Test**
   - Crash mission with terrain override
   - UFO MapBlocks present
   - Crash damage applied
   - Fire and smoke effects visible

4. **Multi-Team Battle Test**
   - 4 teams (player, 2 enemy factions, civilians)
   - Each team has distinct color
   - Independent fog of war per team
   - Team AI targets enemies correctly

5. **Large Map Test**
   - 7×7 MapBlock grid (huge map)
   - 4 landing zones
   - 100+ units across all teams
   - Performance acceptable (<3 seconds generation)

6. **MapScript Variety Test**
   - Same biome generates different MapScripts
   - Same MapScript uses different MapBlocks
   - Transformations create visual variety

**Estimated time:** 8 hours

---

### Phase 8: Documentation (6 hours)

#### Step 8.1: Developer Documentation (3 hours)
**Description:** Document map generation system for developers

**Files to create:**
- `wiki/MAP_GENERATION_SYSTEM.md` - Complete system guide
- `wiki/MAPSCRIPT_CREATION_GUIDE.md` - How to create MapScripts
- `wiki/BIOME_AND_TERRAIN_GUIDE.md` - Biome/terrain system

**Estimated time:** 3 hours

---

#### Step 8.2: Content Creator Documentation (3 hours)
**Description:** Guide for creating MapBlocks and MapScripts

**Files to create:**
- `wiki/CREATING_MAPBLOCKS.md` - Updated guide
- `wiki/CREATING_MAPSCRIPTS.md` - MapScript authoring
- `mods/core/mapblocks/README.md` - MapBlock examples

**Estimated time:** 3 hours

---

## Implementation Details

### Architecture

**Layer 1: Strategic Context (Geoscape)**
- Province provides biome
- Mission provides type and size
- Feeds into generation pipeline

**Layer 2: Terrain Selection**
- Biome → Weighted terrain selection
- Mission override option
- Terrain → MapBlock pool filtering

**Layer 3: MapScript Execution**
- MapScript defines structure
- Selects MapBlocks from pool
- Builds MapBlock Grid

**Layer 4: Transformation & Assembly**
- Random transformations applied
- MapBlocks copied to battlefield
- Objects placed

**Layer 5: Battle Setup**
- Teams created (4 sides, 8 colors)
- Units placed at zones
- Fog of war initialized

**Layer 6: Final Battlefield**
- Complete BattleTile array
- Ready for Battlescape

### Key Components

- **BiomeSystem**: Manages biome definitions and terrain weights
- **TerrainSelector**: Weighted random terrain selection
- **MapBlockFilter**: Filters MapBlocks by tags and properties
- **MapScriptEngine**: Executes MapScript instructions
- **MapBlockTransform**: Rotate and mirror operations
- **BattlefieldAssembler**: Copies tiles to final battlefield
- **ObjectPlacer**: Places MapBlock-defined objects
- **UnitPlacer**: Positions units at landing zones and priority sectors
- **FogOfWarManager**: Per-team visibility calculation
- **EnvironmentalEffects**: Mission-specific effects

### Dependencies

**Existing Systems:**
- `engine/geoscape/logic/province.lua` - Province biome property
- `engine/battlescape/map/map_block.lua` - MapBlock loading
- `engine/battlescape/logic/battlefield.lua` - Battlefield structure
- `engine/battlescape/entities/unit.lua` - Unit entities
- `engine/core/data_loader.lua` - Data loading

**New Dependencies:**
- TOML parser for MapScript files (use existing `libs/toml.lua`)
- Weighted random selection utility
- Graph pathfinding (for future province-based travel)

---

## Testing Strategy

### Unit Tests
- **BiomeSystem**: Terrain selection follows weights correctly
- **TerrainSelector**: Mission override works, fallback to default
- **MapBlockFilter**: Filtering by tags returns correct blocks
- **MapScriptEngine**: MapScript execution produces valid grid
- **MapBlockTransform**: All transformations reversible and correct
- **BattlefieldAssembler**: Tile copying accurate, sector tracking correct
- **ObjectPlacer**: Objects placed at correct coordinates
- **UnitPlacer**: Units don't overlap, spawn at valid tiles
- **FogOfWarManager**: Each team has independent visibility

### Integration Tests
- **Biome → Terrain → MapBlocks**: Thematic consistency
- **MapScript → MapBlock Grid → Battlefield**: Complete pipeline
- **Mission Config → Battlefield**: End-to-end generation
- **Multi-Team Setup**: All 4 sides and 8 colors functional
- **Performance**: 7×7 map generates in <3 seconds

### Manual Testing Steps
1. Start game with Love2D console enabled (`lovec "engine"`)
2. Navigate to Geoscape
3. Select province with urban biome
4. Start mission
5. **Verify:** Urban-themed map generated
6. **Verify:** Landing zones positioned correctly
7. **Verify:** Player units at landing zone, enemies elsewhere
8. **Verify:** Multiple teams have distinct colors
9. **Verify:** Fog of war hides unexplored areas
10. Repeat with forest, industrial, rural biomes

### Expected Results
- ✅ Map thematically matches province biome
- ✅ MapBlocks show transformation variety (rotated, mirrored)
- ✅ Landing zones accessible and logical
- ✅ Units spawn without overlapping
- ✅ All 4 battle sides functional
- ✅ Up to 8 teams with distinct colors
- ✅ Fog of war initialized correctly
- ✅ Objects placed on battlefield
- ✅ Environmental effects visible (if mission type requires)
- ✅ Generation completes in <3 seconds

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging Map Generation
```lua
-- Add to map generator
print("[MapGen] Biome: " .. biome.id)
print("[MapGen] Selected Terrain: " .. terrain.id)
print("[MapGen] MapBlocks available: " .. #mapBlockPool)
print("[MapGen] MapScript: " .. mapScript.id)
print("[MapGen] Grid size: " .. gridWidth .. "×" .. gridHeight)
print("[MapGen] Battlefield size: " .. battlefield.width .. "×" .. battlefield.height)
print("[MapGen] Teams: " .. #battlefield.teams)
print("[MapGen] Total units: " .. unitCount)
```

### Console Debugging
- Love2D console enabled in `conf.lua` (t.console = true)
- Check console for generation errors
- Monitor generation time (should be <3 seconds)

### Temporary Files
- All temp files MUST use: `os.getenv("TEMP")`
- Example: MapScript cache, MapBlock index

### Debug Visualization
Press **F9** in Battlescape to toggle debug overlay:
- MapBlock sector boundaries
- Landing zone markers
- Objective sector highlights
- Unit spawn points
- AI priority positions

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add map generation API
- [x] `wiki/FAQ.md` - Add "How does map generation work?" section
- [x] Create `wiki/MAP_GENERATION_SYSTEM.md` - Complete guide
- [x] Create `wiki/MAPSCRIPT_CREATION_GUIDE.md` - MapScript authoring
- [x] Create `wiki/BIOME_AND_TERRAIN_GUIDE.md` - Biome system
- [x] Update `wiki/MAPBLOCK_GUIDE.md` - Add tagging and transformation sections
- [x] Update `engine/battlescape/map/README.md` - Document new systems

---

## Notes

### Performance Considerations
- MapBlock pool filtering should be cached per terrain
- MapScript execution should reuse MapBlock instances (no deep copying)
- Tile copying is O(n²) where n = 60-105, acceptable
- Fog of war calculation per team is expensive, optimize with spatial hashing

### Content Requirements
- Need at least 50 MapBlocks per terrain type for variety
- Need 8-12 MapScripts per terrain type
- Each biome needs 3-5 terrain definitions
- Minimum 8 biomes for world coverage

### Future Enhancements
- Procedural MapBlock generation (no TOML files)
- Dynamic MapScript generation (AI-driven)
- Multi-level maps (buildings with interiors)
- Destructible MapScript elements (roads can be destroyed)
- Weather system integration (rain, snow, fog)

---

## Blockers

- **TASK-025** (Geoscape): Need province biome property
- **TASK-029** (Deployment Planning): Landing zone selection UI
- MapBlock library needs expansion (currently ~15 blocks, need 100+)

---

## Review Checklist

- [ ] Biome system data-driven and extensible
- [ ] Terrain selection weighted and configurable
- [ ] MapScript format clear and documented
- [ ] MapBlock transformations don't break functionality
- [ ] Battlefield assembly efficient (<3 seconds)
- [ ] All 4 battle sides implemented
- [ ] 8 team colors functional and distinct
- [ ] Unit placement logical and balanced
- [ ] Fog of war per-team and correct
- [ ] Environmental effects optional and modular
- [ ] Complete end-to-end integration
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall`
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation complete
- [ ] No warnings in Love2D console

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
