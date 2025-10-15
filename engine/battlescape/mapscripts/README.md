# MapScript System

Procedural map generation using TOML-based scripts.

## Overview

MapScript system generates tactical battlescape maps procedurally by placing MapBlocks according to rules defined in TOML files. Creates varied, balanced maps for missions.

## Architecture

```
engine/battlescape/mapscripts/
├── mapscript_selector.lua      -- Selects appropriate script for mission
├── mapscript_executor.lua      -- Executes script to build map
└── README.md                   -- This file

mods/*/content/mapscripts/
├── urban_small.toml            -- City mission scripts
├── farmland.toml               -- Rural mission scripts
├── ufo_crash_forest.toml       -- Forest crash sites
└── alien_base.toml             -- Base assault scripts
```

## MapScript TOML Format

```toml
[mapscript]
id = "urban_small"
name = "Small City Map"
description = "20×20 city block with streets and buildings"
width = 20
height = 20
terrain_type = "urban"

# Block categories
[blocks]
ground = ["street_01", "street_02", "sidewalk_01"]
buildings = ["shop_01", "apartment_01", "office_01"]
features = ["car_01", "fence_01", "lamppost_01"]

# Placement rules
[[rules]]
type = "fill"
category = "ground"
probability = 1.0

[[rules]]
type = "scatter"
category = "buildings"
count = 8
min_distance = 3

[[rules]]
type = "path"
category = "ground"
pattern = "street_*"
width = 2

[[rules]]
type = "spawn"
zones = ["north", "south"]
min_distance = 10
```

## Key Concepts

### MapBlocks
Reusable 10×10 hex terrain chunks loaded from TOML. Each block defines terrain tiles, objects, spawn points, and AI hints.

### Rules
Sequential instructions for block placement:
- **fill**: Cover entire map with blocks
- **scatter**: Place N blocks randomly
- **path**: Create roads/corridors
- **border**: Place walls around edges
- **spawn**: Mark deployment zones

### Categories
Blocks grouped by purpose (ground, walls, buildings, features) for organized placement.

## Usage

```lua
local MapScriptSelector = require("battlescape.mapscripts.mapscript_selector")
local MapScriptExecutor = require("battlescape.mapscripts.mapscript_executor")

-- Select script for mission
local script = MapScriptSelector.select({
    missionType = "crash_site",
    terrain = "forest",
    size = "medium"
})

-- Execute script to generate map
local map = MapScriptExecutor.execute(script)
-- Returns 2D array of terrain tiles ready for rendering
```

## Rule Types

### Fill Rule
```toml
[[rules]]
type = "fill"
category = "ground"
probability = 1.0  # 100% coverage
```

### Scatter Rule
```toml
[[rules]]
type = "scatter"
category = "buildings"
count = 12
min_distance = 2
probability = 0.8  # 80% chance each
```

### Path Rule
```toml
[[rules]]
type = "path"
start = {x = 0, y = 10}
end = {x = 20, y = 10}
category = "ground"
pattern = "road_*"
width = 2
```

### Border Rule
```toml
[[rules]]
type = "border"
category = "walls"
thickness = 1
```

## Integration

### From Mission System
```lua
-- Generate map for mission
function Mission:generateMap()
    local script = MapScriptSelector.select({
        missionType = self.type,
        terrain = self.terrain,
        difficulty = self.difficulty
    })
    
    self.map = MapScriptExecutor.execute(script)
end
```

### To Battlescape
```lua
-- Load generated map
function Battlescape:loadMap(mapData)
    self.tiles = mapData.tiles
    self.spawns = mapData.spawnZones
    self.objectives = mapData.objectives
end
```

## See Also

- [MAPBLOCK_GUIDE.md](../../wiki/MAPBLOCK_GUIDE.md) - MapBlock format
- [MAP_SCRIPT_REFERENCE.md](../../wiki/MAP_SCRIPT_REFERENCE.md) - Full rule reference
- [Battlescape README](../README.md) - Tactical combat overview
