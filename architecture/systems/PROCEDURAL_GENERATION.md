# Procedural Map Generation Architecture - Hex-Based

**System:** Map & Content Generation  
**Date:** 2025-10-28  
**Status:** Complete  
**Coordinate System:** Vertical Axial (Flat-Top Hexagons)

---

## Overview

The procedural generation system creates unique tactical maps, missions, and content using mapscripts, mapblocks, and biome-based rules. **All maps are generated using vertical axial hex grid system.**

### Hex-Based Map Generation

**Map structure:**
- **Grid:** 4×4 to 7×7 map blocks
- **Block Size:** 15 hexes per block (ring pattern)
- **Total Size:** 60×60 to 105×105 hexes
- **Coordinates:** All positions use axial `{q, r}`
- **Placement:** HexMath for block positioning and transformations

**Design Reference:** `design/mechanics/hex_vertical_axial_system.md`  
**Core Module:** `engine/battlescape/battle_ecs/hex_math.lua`

---

## Map Generation Pipeline

```mermaid
graph TD
    Start[Mission Deployment] --> Input[Mission Parameters]
    
    Input --> MissionType[Mission Type<br/>crash_site/terror/base_defense]
    Input --> Location[Province Location<br/>Hex Coordinates]
    Input --> Difficulty[Difficulty Level 1-5]
    Input --> Faction[Enemy Faction]
    
    MissionType --> Biome[Stage 1: Biome Selection]
    Location --> Biome
    
    Biome --> BiomeMap{Province → Biome}
    
    BiomeMap -->|Desert| BiomeDesert[Desert Biome]
    BiomeMap -->|Forest| BiomeForest[Forest Biome]
    BiomeMap -->|Urban| BiomeUrban[Urban Biome]
    BiomeMap -->|Tundra| BiomeTundra[Tundra Biome]
    
    BiomeDesert --> Terrain[Stage 2: Terrain Selection]
    BiomeForest --> Terrain
    BiomeUrban --> Terrain
    BiomeTundra --> Terrain
    
    Terrain --> TerrainRules[Terrain Rules<br/>Based on Biome]
    
    TerrainRules --> Mapscript[Stage 3: Mapscript Selection]
    
    Mapscript --> Script{Select Script}
    
    Script -->|Forest| ForestScript[dense_forest.lua]
    Script -->|Desert| DesertScript[sand_dunes.lua]
    Script -->|Urban| UrbanScript[city_block.lua]
    
    ForestScript --> Assembly[Stage 4: Hex MapBlock Assembly]
    DesertScript --> Assembly
    UrbanScript --> Assembly
    
    Assembly --> Grid[Generate Hex Grid 4×4 to 7×7 blocks]
    Grid --> PlaceTiles[Place Hex Terrain Tiles<br/>Axial Coordinates]
    PlaceTiles --> AddFeatures[Add Features & Obstacles<br/>Hex Positions]
    AddFeatures --> CalcCover[Calculate Cover Values<br/>HexMath.getDirection]
    
    CalcCover --> Transform[Stage 5: Hex Transformations<br/>Rotation via HexMath]
    
    Transform --> Rotate[Rotate 0°/90°/180°/270°]
    Transform --> Mirror[Mirror H/V/Both]
    Transform --> Scale[Scale 1x/1.5x/2x]
    
    Rotate --> Placement[Stage 6: Entity Placement]
    Mirror --> Placement
    Scale --> Placement
    
    Placement --> PlayerSpawn[Player Spawn Zone]
    Placement --> EnemySpawn[Enemy Spawn Zones]
    Placement --> Items[Item Placement]
    Placement --> Objectives[Objective Placement]
    
    PlayerSpawn --> Validate[Stage 7: Validation]
    EnemySpawn --> Validate
    Items --> Validate
    Objectives --> Validate
    
    Validate --> PathCheck{All Areas Accessible?}
    
    PathCheck -->|No| Regenerate[Regenerate Problem Areas]
    PathCheck -->|Yes| Complete[Map Ready]
    
    Regenerate --> Assembly
    
    style Start fill:#90EE90
    style Complete fill:#87CEEB
    style PathCheck fill:#FFD700
```

---

## Mapscript System

```mermaid
graph LR
    Mapscript[Mapscript File] --> Metadata[Metadata]
    Mapscript --> BlockPools[Block Pools]
    Mapscript --> Rules[Placement Rules]
    Mapscript --> Spawn[Spawn Zones]
    
    Metadata --> Name[name: 'Dense Forest']
    Metadata --> Biome[biome: 'forest']
    Metadata --> Size[size: '6x6']
    
    BlockPools --> Pool1[ground_blocks]
    BlockPools --> Pool2[building_blocks]
    BlockPools --> Pool3[feature_blocks]
    
    Rules --> Border[border: wall_blocks]
    Rules --> Fill[fill: ground_blocks]
    Rules --> Density[density: 0.7]
    
    Spawn --> Player[player_spawn: north]
    Spawn --> Enemy[enemy_spawn: south]
    Spawn --> Objective[objective: center]
    
    style Mapscript fill:#FFD700
```

---

## MapBlock Structure

```mermaid
erDiagram
    MAPBLOCK {
        string id PK
        string name
        int width
        int height
        string biome
        table tiles
        table spawn_points
        table cover_data
    }
    
    TILE {
        int x
        int y
        string type
        int elevation
        boolean walkable
        int cover_value
    }
    
    SPAWN_POINT {
        string id PK
        int x
        int y
        string type
        int priority
    }
    
    FEATURE {
        string id PK
        int x
        int y
        string feature_type
        boolean destructible
    }
    
    MAPBLOCK ||--o{ TILE : "contains"
    MAPBLOCK ||--o{ SPAWN_POINT : "defines"
    MAPBLOCK ||--o{ FEATURE : "includes"
```

---

## Biome System

```mermaid
graph TD
    Biomes[Biome Types] --> Forest[Forest Biome]
    Biomes --> Desert[Desert Biome]
    Biomes --> Urban[Urban Biome]
    Biomes --> Tundra[Tundra Biome]
    Biomes --> Mountain[Mountain Biome]
    
    Forest --> FTerrain[Terrain: Grass, Dirt, Mud]
    Forest --> FFeatures[Features: Trees, Rocks, Streams]
    Forest --> FCover[Cover: Dense vegetation]
    
    Desert --> DTerrain[Terrain: Sand, Rock, Dunes]
    Desert --> DFeatures[Features: Cacti, Rocks, Ruins]
    Desert --> DCover[Cover: Sparse rocks]
    
    Urban --> UTerrain[Terrain: Concrete, Asphalt]
    Urban --> UFeatures[Features: Buildings, Cars, Fences]
    Urban --> UCover[Cover: Walls, vehicles]
    
    Tundra --> TTerrain[Terrain: Snow, Ice, Rock]
    Tundra --> TFeatures[Features: Trees, Ice formations]
    Tundra --> TCover[Cover: Snow drifts, rocks]
    
    Mountain --> MTerrain[Terrain: Rock, Cliff, Gravel]
    Mountain --> MFeatures[Features: Boulders, Caves]
    Mountain --> MCover[Cover: Rock formations]
    
    style Biomes fill:#FFD700
    style Forest fill:#90EE90
    style Desert fill:#FFE5B4
    style Urban fill:#87CEEB
    style Tundra fill:#E0E0FF
    style Mountain fill:#A9A9A9
```

---

## Terrain Types

| Terrain | Movement Cost | Cover Bonus | Visual | Biome |
|---------|--------------|-------------|--------|-------|
| **Grass** | 1.0 | +0 | Green tiles | Forest, Tundra |
| **Dirt** | 1.1 | +0 | Brown tiles | Forest, Desert |
| **Sand** | 1.3 | +0 | Yellow tiles | Desert |
| **Rock** | 1.5 | +10 | Gray tiles | Mountain, Desert |
| **Snow** | 1.4 | +5 | White tiles | Tundra |
| **Concrete** | 0.9 | +0 | Gray tiles | Urban |
| **Water** | 2.0 | -10 | Blue tiles | Forest, Tundra |
| **Mud** | 1.8 | +0 | Dark brown | Forest |

---

## Cover Generation

```mermaid
graph TD
    Generate[Generate Cover] --> Scan[Scan Map Tiles]
    
    Scan --> CheckType{Tile Type?}
    
    CheckType -->|Wall| FullCover[Full Cover<br/>+40 Defense]
    CheckType -->|Rock| HighCover[High Cover<br/>+30 Defense]
    CheckType -->|Fence| LowCover[Low Cover<br/>+20 Defense]
    CheckType -->|Open| NoCover[No Cover<br/>+0 Defense]
    
    FullCover --> Direction[Calculate Direction]
    HighCover --> Direction
    LowCover --> Direction
    
    Direction --> North[North Cover]
    Direction --> South[South Cover]
    Direction --> East[East Cover]
    Direction --> West[West Cover]
    
    North --> StoreCover[Store Cover Data]
    South --> StoreCover
    East --> StoreCover
    West --> StoreCover
    NoCover --> StoreCover
    
    StoreCover --> Complete[Cover Map Ready]
    
    style Generate fill:#90EE90
    style Complete fill:#87CEEB
    style FullCover fill:#FF6B6B
```

---

## Entity Placement

```mermaid
sequenceDiagram
    participant Gen as Map Generator
    participant Spawn as Spawn Manager
    participant Valid as Validator
    participant Entity
    
    Gen->>Spawn: Request Player Spawn
    Spawn->>Spawn: Find spawn zone (north)
    Spawn->>Valid: Validate position
    
    Valid->>Valid: Check walkable
    Valid->>Valid: Check not blocked
    Valid->>Valid: Check minimum distance
    
    alt Valid Position
        Valid-->>Spawn: Position OK
        Spawn->>Entity: Place Unit at (x, y)
        Entity-->>Gen: Unit Placed
    else Invalid Position
        Valid-->>Spawn: Position Invalid
        Spawn->>Spawn: Find alternative
        Spawn->>Valid: Validate new position
    end
    
    Gen->>Spawn: Request Enemy Spawns
    
    loop For Each Enemy
        Spawn->>Spawn: Find spawn zone (south/east/west)
        Spawn->>Valid: Validate position
        Valid-->>Spawn: Position OK
        Spawn->>Entity: Place Enemy at (x, y)
    end
    
    Gen->>Spawn: Request Objective Placement
    Spawn->>Spawn: Find center area
    Spawn->>Valid: Validate objective position
    Valid-->>Spawn: Position OK
    Spawn->>Entity: Place Objective
```

---

## Random Seed System

```mermaid
graph LR
    Mission[Mission ID] --> Hash[Hash Function]
    
    Hash --> Seed[Random Seed]
    
    Seed --> RNG[Random Number Generator]
    
    RNG --> BiomeChoice[Biome Selection]
    RNG --> BlockChoice[Block Selection]
    RNG --> Rotation[Rotation/Mirror]
    RNG --> Placement[Entity Placement]
    
    BiomeChoice --> Deterministic[Deterministic Generation]
    BlockChoice --> Deterministic
    Rotation --> Deterministic
    Placement --> Deterministic
    
    Deterministic --> Replay[Same Seed = Same Map]
    
    style Mission fill:#90EE90
    style Seed fill:#FFD700
    style Replay fill:#87CEEB
```

---

## Mapscript Example

```lua
-- Example Mapscript: Dense Forest

return {
    metadata = {
        id = "dense_forest",
        name = "Dense Forest",
        biome = "forest",
        size = {width = 6, height = 6},
        difficulty_range = {1, 3}
    },
    
    block_pools = {
        ground = {
            "forest_ground_01",
            "forest_ground_02",
            "forest_clearing"
        },
        trees = {
            "tree_cluster_dense",
            "tree_cluster_sparse",
            "single_tree"
        },
        features = {
            "rock_formation",
            "stream",
            "fallen_log"
        }
    },
    
    placement_rules = {
        border = "tree_wall",
        fill = {
            ground = 0.4,
            trees = 0.4,
            features = 0.2
        },
        min_clear_path = true
    },
    
    spawn_zones = {
        player = {area = "north", count = 4},
        enemy = {area = "south", count = {6, 10}},
        objective = {area = "center", type = "ufo_crash"}
    }
}
```

---

## Validation System

```mermaid
graph TD
    Validate[Validate Map] --> PathFind[Check Pathfinding]
    
    PathFind --> PlayerToObjective{Path Exists?}
    
    PlayerToObjective -->|No| Invalid[Map Invalid]
    PlayerToObjective -->|Yes| EnemyToPlayer{Enemies Can Reach?}
    
    EnemyToPlayer -->|No| Invalid
    EnemyToPlayer -->|Yes| CheckCover[Check Cover Distribution]
    
    CheckCover --> CoverRatio{Cover Ratio OK?}
    
    CoverRatio -->|< 30%| TooOpen[Too Open - Regenerate]
    CoverRatio -->|30-70%| CoverOK[Cover Balanced]
    CoverRatio -->|> 70%| TooDense[Too Dense - Regenerate]
    
    CoverOK --> CheckSpawn[Check Spawn Distances]
    
    CheckSpawn --> MinDist{Min Distance OK?}
    
    MinDist -->|No| TooClose[Spawns Too Close]
    MinDist -->|Yes| Valid[Map Valid]
    
    Invalid --> Regenerate[Regenerate Map]
    TooOpen --> Regenerate
    TooDense --> Regenerate
    TooClose --> Regenerate
    
    Regenerate --> Validate
    
    style Validate fill:#90EE90
    style Valid fill:#87CEEB
    style Invalid fill:#FF6B6B
```

---

## Performance Considerations

| Component | Optimization | Impact |
|-----------|-------------|--------|
| **Map Generation** | Cached mapblocks | Fast generation (< 1s) |
| **Pathfinding** | Pre-calculated grid | Fast validation |
| **Cover Calculation** | Cached per tile | Instant lookups |
| **Seed-based RNG** | Reproducible maps | Consistent results |
| **Tile Culling** | Only render visible | 60 FPS stable |

---

**End of Procedural Map Generation Architecture**

