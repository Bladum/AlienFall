# Alien Fall - Procedural Map Generation System

## Overview

This system generates tactical battlescape maps inspired by X-COM: UFO Enemy Unknown (1994). The approach uses **modular map blocks** that can be assembled into larger battlefields, ensuring variety while maintaining tactical gameplay integrity.

### X-COM Map Block Philosophy

X-COM used a **map block system** where:
- Each block is a self-contained section that tiles seamlessly
- Blocks create 60x60 to 120x120+ tile battlefields
- Each block has consistent scale (1 tile = 1 meter)
- Blocks contain complete structures (no cut-off buildings)
- Different terrain types have specialized block sets

### Critical Differences from X-COM

**SINGLE LEVEL ONLY**: Unlike X-COM which had multi-floor buildings (floor 0, 1, 2, 3), this system uses **one level only**. All structures are represented on a single 2D plane.

**ONE TILE, ONE ELEMENT**: Each tile position contains **exactly one element** - either floor, wall, object, vehicle, etc. There is no separate floor/wall/roof layering like X-COM. If a tile is a wall, it's a wall (not a wall on top of a floor).

## Available Terrains

The following terrain types are available for map generation:

### Natural Terrains
- arctic_outpost
- autumn_forest
- badlands
- beach_tropical
- caves_underground
- desert
- desert_mountain
- desert_pyramids
- farmland
- forest
- forest_mountain
- forest_water
- jungle_dense
- marsh_swamp
- mountain
- mountains
- mountain_passage
- ocean_deep
- ocean_shallow
- rice_farm
- savannah
- sea_volcano
- tundra
- winter_forest

### Urban/Man-made Terrains
- base_alien
- base_destroyed
- base_xcom
- chemical_plant
- cult_safehouse
- labyrinth
- mummy_temple_grounds
- native_urban
- port_urban
- postindustrial
- ruins_ancient
- ruins_urban
- underground_complex
- urban_commercial
- urban_industrial
- urban_low
- urban_residential
- vehicles_xcom
- village_grassland
- village_jungle

### Special/Otherworldly Terrains
- atlantis_temple
- cargo_ship
- cruise_liner
- mars_cydonia
- moon_lunar
- ship_cargo
- ship_cruise
- space_station
- ufos_alien
- uac_moon_lab
- zombie_catacombs

### Potential Duplicates
- **ship_cargo** and **cargo_ship**: Same concept, different naming order (merged - keeping ship_cargo)
- **mountain** and **mountains**: Similar concepts, singular vs plural (merged - keeping mountain)
- **urban_commercial** and **commercial**: Urban commercial terrain vs generic commercial (kept urban_commercial, removed generic commercial)

## Core Principles

### 1. Scale Consistency
- **1 tile = 1 meter** (approximately)
- A car is 4-5 tiles long, 2 tiles wide
- A door is 1 tile wide
- A room is minimum 3x3 tiles (small) to 8x8 tiles (large)
- Roads are 2-4 tiles wide (not 1 tile)
- Paths can be 1 tile wide

### 2. Map Block Standard Sizes
- **Primary Standard**: 15x15 tiles (most common - ~80% of blocks)
- **Double Standard**: 30x30 tiles (large structures)
- **Extended Standard**: 45x30 tiles (long structures like convoys)
- **Triple Standard**: 45x45 tiles (very rare, massive structures)

**Block Size Rules**:
- Width and height must be **multiples of 15** (15, 30, 45, 60...)
- Square blocks are preferred but rectangular is allowed (30x15, 45x30, etc.)
- **Never use non-standard sizes** like 20x15, 25x20, or 17x13
- If a structure is 20 tiles wide, place it in a 30x30 block with spacing
- If a structure is 16 tiles long, place it in a 30x15 or 30x30 block

**Border Spacing Requirements**:
- **Mandatory**: Leave at least 1 tile of walkable space on 2+ sides of major structures
- **Recommended**: Leave 1 tile border on all 4 sides when possible
- This ensures units can move around structures and flank enemies
- Example: For a 12x10 building in a 15x15 block, center it leaving 1-2 tiles on each side

### 3. Block Modularity
- Each block is self-contained and complete
- Blocks connect at edges seamlessly
- Edge tiles should allow connection (roads align, terrain flows)
- Structures are **never cut in half** between blocks
- Battlefield assembly examples:
  - 4x4 grid of 15x15 blocks = 60x60 tiles
  - 2x2 grid of 30x30 blocks = 60x60 tiles
  - Mix of 15x15 and 30x30 blocks = variable battlefield size

## Map Block System

### Block Classification

Blocks are classified by:
1. **Terrain Type**: Urban, Forest, Desert, etc.
2. **Function**: Residential, Commercial, Industrial, Natural, Military, etc.
3. **Size**: 15x15, 30x30, 45x30, etc.
4. **Connectivity**: Edge features (roads, paths, terrain transitions)

### Block Connection Rules

**Road Alignment**:
```
Block A edge:        Block B edge:
···········R         R···········
···········R    +    R···········
···········R         R···········
```
Roads must align at same Y-coordinate

**Terrain Blending**:
```
Block A (Forest):    Block B (Clearing):
TTTTTT····           ·····TTTTT
TTTTTT····           ·····TTTTT
```
Gradual transition prevents jarring edges

**Building Placement**:
- Buildings should be 2+ tiles from block edge
- Allows for sidewalks, yards, or open space
- Prevents half-building artifacts

## General Tile System

### Base Terrain Tiles (Universal)
```
' ' = Empty/Void
'.' = Dirt/Ground/Floor (walkable)
',' = Grass/Light vegetation
';' = Sparse grass/scrubland
':' = Sand/desert floor/asphalt
'~' = Deep water (impassable)
'≈' = Shallow water (walkable, slow)
'░' = Rough terrain/rubble
'▒' = Dense rubble/debris
'▓' = Very dense debris/blocked
```

### Wall Tiles (Universal - Critical for Buildings)
```
'#' = Basic wall (generic)
'█' = Solid wall block
'║' = Vertical wall segment
'═' = Horizontal wall segment
'╔' = Wall corner (top-left)
'╗' = Wall corner (top-right)
'╚' = Wall corner (bottom-left)
'╝' = Wall corner (bottom-right)
'╠' = Wall T-junction (left)
'╣' = Wall T-junction (right)
'╦' = Wall T-junction (top)
'╩' = Wall T-junction (bottom)
'╬' = Wall cross/intersection
'│' = Thin vertical wall
'─' = Thin horizontal wall
'┌' = Thin corner (top-left)
'┐' = Thin corner (top-right)
'└' = Thin corner (bottom-left)
'┘' = Thin corner (bottom-right)
```

### Building Materials (Universal)
```
'=' = Metal wall/reinforced
'≡' = Industrial wall/plating
'∏' = Concrete wall
'□' = Window (closed)
'▢' = Window (broken)
'◊' = Glass door/window
```

### Doors & Openings (Universal)
```
'+' = Closed door
'D' = Double door
'/' = Door (open, left)
'\' = Door (open, right)
'G' = Gate/large door
'○' = Round door (UFO style)
```

### Terrain Features (Common)
```
'^' = Mountain/cliff
'∧' = Hill slope
'v' = Valley/depression
'≋' = Water ripples
'w' = Puddle/shallow water
'*' = Crystal/special terrain
'○' = Crater
'⌂' = Rock/boulder
```

### Interior Objects (Common)
```
'□' = Table
'■' = Chair/seat
'◘' = Bed
'Ω' = Computer/terminal
'∞' = Machinery
'⌂' = Cabinet/storage
'♪' = Equipment/device
'☼' = Light source
'$' = Loot/item
'!' = Objective marker
'@' = Spawn point
```

## Generation Algorithms

### 1. Room-Based Generation (BSP - Binary Space Partitioning)
**Used for**: Houses, shops, offices, bunkers, base facilities

**Algorithm**:
1. Start with outer walls (15x15 boundary)
2. Divide into rooms using BSP recursively
3. Ensure minimum room size (3x3)
4. Place doors between rooms (1-tile wide)
5. Add furniture based on room type
6. Add windows on outer walls

### 2. Cellular Automata (Caves, Natural Formations)
**Used for**: Caves, natural formations, ruins, erosion

**Algorithm**:
1. Initialize grid with 50% random walls
2. For 4-6 iterations:
   - Count wall neighbors for each tile
   - If wall tile has <4 wall neighbors → becomes floor
   - If floor tile has >4 wall neighbors → becomes wall
3. Result: Organic cave-like structures

**Application**: Underground tunnels, eroded ruins, crater patterns

### 3. Drunkard's Walk (Paths, Roads)
**Used for**: Paths, roads, trenches, tunnels

**Algorithm**:
1. Start at random point
2. Take random direction (N/S/E/W)
3. Move and carve path tile
4. Repeat for desired length
5. Can widen by carving adjacent tiles

**Variation**: **Directed Drunkard** - bias toward target destination

### 4. Maze Generation (Corridors)
**Used for**: Alien ship interiors, facilities, labyrinths

**Algorithm** (Recursive Backtracker):
1. Start at cell (1,1)
2. Mark current cell as visited
3. While there are unvisited neighbors:
   - Choose random unvisited neighbor
   - Remove wall between current and chosen cell
   - Recursively visit that neighbor
4. Backtrack when stuck

**Result**: Perfect mazes with single solution (can add loops by removing walls)

### 5. Prefab Placement (Structures)
**Used for**: Pre-designed buildings, UFOs, vehicles

**Algorithm**:
1. Select prefab from library
2. Find valid placement location:
   - Check if area is clear
   - Respect block edges (no cut-offs)
   - Respect map block edges (no cut-offs)
3. Place prefab tiles
4. Adjust surrounding terrain if needed

**Placement Rules**:
- UFOs: Center of block
- Buildings: Near edges for street access
- Vehicles: On roads or parking areas
- Trees: Random distribution avoiding structures

### 6. Terrain Flow (Natural Features)
**Used for**: Rivers, roads, elevation changes

**Algorithm** (Perlin-like Noise):
1. Generate heightmap for block
2. Threshold values determine terrain type:
   - High values → mountains/hills
   - Medium values → forests/grassland
   - Low values → water/valleys
3. Smooth transitions between levels

### 7. Scatter Distribution (Vegetation, Debris)
**Used for**: Trees, rocks, debris, items

**Algorithm**:
1. Define scatter parameters:
   - Density (% of tiles)
   - Minimum distance between items
   - Clustering probability
2. For each spawn attempt:
   - Random location
   - Check minimum distance from other items
   - Place tile if valid
3. Optional: Use Poisson Disk Sampling for even distribution

### 8. Destructive Generation (Ruins, Damage)
**Used for**: Damaged buildings, crash sites, ruins

**Algorithm**:
1. Start with intact structure
2. Apply destruction passes:
   - Remove random wall sections
   - Add rubble around impact points
   - Scatter debris around impact point
3. Ensure structural integrity (at least some walls remain)

**Application**: UFO crash sites, bombed buildings, ancient ruins

### 9. Voronoi Diagram (Territory Division)
**Used for**: Property boundaries, district division, natural clustering

**Algorithm**:
1. Place seed points randomly across map
2. For each tile, calculate distance to all seed points
3. Assign tile to nearest seed point
4. Result: Organic regions with irregular boundaries

**Application**: Urban lot division, farm field separation, tribal territories

### 10. L-System (Organic Growth)
**Used for**: Trees, road networks, river branching

**Algorithm**:
1. Define grammar rules (e.g., F → FF+F-F)
2. Start with axiom string (e.g., "F")
3. Apply rules iteratively
4. Interpret string as drawing commands

**Application**: River tributaries, tree branch structures, road expansion

### 11. Wave Function Collapse (Tile-Based)
**Used for**: Complex tile patterns, consistent aesthetic

**Algorithm**:
1. Define tile adjacency rules (which tiles can be neighbors)
2. Start with all tiles in superposition (any possibility)
3. Collapse one tile to specific type
4. Propagate constraints to neighbors
5. Repeat until all tiles resolved

**Application**: Urban building facades, intricate floor patterns, wall decorations

### 12. Flood Fill (Area Definition)
**Used for**: Room identification, water bodies, connected regions

**Algorithm**:
1. Start at seed point
2. If current tile matches criteria, mark it
3. Recursively check 4 neighbors (N/S/E/W)
4. Stop when boundaries reached

**Application**: Identifying room sizes, water extent, connected areas

### 13. Perlin/Simplex Noise (Natural Variation)
**Used for**: Height maps, density maps, natural randomness

**Algorithm**:
1. Generate gradient grid
2. Interpolate values between grid points
3. Multiple octaves for detail at different scales
4. Threshold values to create features

**Application**: Mountain elevation, forest density, sand dune patterns

### 14. Convex Hull (Boundary Detection)
**Used for**: UFO crash perimeters, building lot boundaries

**Algorithm**:
1. Input set of points (e.g., UFO parts)
2. Find outermost points
3. Connect them to form convex polygon
4. Use as boundary for features

**Application**: Scorch mark extent, debris field boundary, property lines

## Map Block Assembly

### Battlefield Construction

#### Assembly Process
1. **Define battlefield size**: e.g., 4x4 blocks = 60x60 tiles
2. **Select terrain theme**: Urban, Forest, Desert, etc.
3. **Choose block types**:
   - Core blocks (UFO landing site if applicable)
   - Transition blocks (terrain blending)
   - Fill blocks (varied to maintain interest)
4. **Validate connections**:
   - Roads align across block boundaries
   - Terrain types flow naturally
   - No floating disconnected areas
5. **Post-process**:
   - Add linking elements (paths between buildings)
   - Place spawn points and objectives
   - Add ambient details

### Example Battlefield Layout (4x4 blocks = 60x60)

```
┌─────────┬─────────┬─────────┬─────────┐
│ Street  │ Store   │ Parking │ Alley   │
│ Corner  │ Front   │ Lot     │ Section │
├─────────┼─────────┼─────────┼─────────┤
│ Urban   │ UFO     │ UFO     │ Park    │
│ Houses  │ Crash   │ Crash   │ Area    │
├─────────┼─────────┼─────────┼─────────┤
│ Gas     │ UFO     │ UFO     │ Forest  │
│ Station │ Crash   │ Crash   │ Edge    │
├─────────┼─────────┼─────────┼─────────┤
│ Street  │ Debris  │ Debris  │ Forest  │
│ Section │ Field   │ Field   │ Dense   │
└─────────┴─────────┴─────────┴─────────┘
```

Central 2x2 = UFO crash site (30x30)  
Surrounding blocks = Urban terrain transitioning to forest

## Technical Specifications

### Critical Architecture Notes

**SINGLE LEVEL ONLY**:
- Unlike X-COM which had multi-floor buildings (levels 0, 1, 2, 3), this system uses **one level only**
- All structures exist on a single 2D plane
- No vertical stacking of floors
- Buildings are represented by their ground-level footprint only
- Multi-story buildings are abstracted to single-level representation

**ONE ELEMENT PER TILE**:
- Each tile position contains **exactly one element**
- No layering of floor + wall + roof like X-COM
- If a tile is a wall ('#'), it's ONLY a wall (not a wall on top of a floor)
- If a tile is a floor ('.'), it's ONLY a floor
- Objects (tables, crates) replace the floor tile at that position
- This simplifies rendering: tile[y][x] = single character

**BLOCK SIZE REQUIREMENTS**:
- Width and height MUST be multiples of 15 (15, 30, 45, 60...)
- Square blocks preferred but rectangular allowed (30x15, 45x30)
- NEVER use non-standard sizes (20x15, 25x20, 17x13, etc.)
- If structure is 20 tiles wide, use 30x30 block and center it

**BORDER SPACING REQUIREMENTS**:
- Leave at least 1 tile of walkable space on 2+ sides of structures
- Recommended: 1 tile border on all 4 sides
- Ensures unit movement around structures
- Example: 12x10 building in 15x15 block = 1-2 tile borders

**NO CUT STRUCTURES**:
- Structures must NEVER be cut in half between blocks
- Each block is completely self-contained
- Buildings, UFOs, vehicles must fit entirely within one block (with borders)
- If a structure doesn't fit, use a larger block size

### Map Block Data Structure
```lua
MapBlock = {
    size = {width = 15, height = 15},  -- Must be multiples of 15
    tiles = {},  -- 2D array of single characters
    metadata = {
        terrain_type = "urban",
        function_type = "residential",
        connectivity = {
            north = "road",
            south = "forest",
            east = "building",
            west = "open"
        }
    }
}
```

### Generator Function Interface
```lua
function generate_map_block(options)
    -- options = {
    --     terrain_type = "urban",
    --     function_type = "residential",
    --     size = {width = 15, height = 15},
    --     seed = 12345
    -- }
    return block
end
```

## Three-Phase Generation Specification

The "AI" in procedural generation is less about a massive model and more about a robust Rule Set and Design Specification that you feed to your algorithms (WFC, CA, etc.).

To ensure your blocks look human-made—with structure, intentional features, and fine details like scattered bushes—you need to write a highly detailed "prompt" that guides the generator.

### Phase 1: Macro-Structure (The Intent)
This defines the block's main purpose. A human designer never just puts down random tiles; they design a space for a reason (a battle, a shortcut, a resource).

| Specification Area | Example Rule (for a Forest Block) | Goal |
|-------------------|-----------------------------------|------|
| Block Type & Category | Category: Forest. Type: Ambush Corridor. | Forces the generator to prioritize specific features like choke points. |
| Major Feature Rule | Must contain ONE primary structural feature: a single, continuous, two-tile wide dirt path running from the North boundary to the South boundary. The path must be non-linear (i.e., use a randomized Bezier curve or drunkard's walk). | Enforces a sense of travel/flow and structure. |
| Point of Interest (POI) | Must contain ONE secondary feature: a small 3×3 clearing (grass tile only) or a single 1×1 large boulder. | Adds asymmetry and focal points, guiding player attention. |
| Density Budget | Tile Budget: Trees/Impassable must be between 30% and 40% of the total area. | Prevents blocks from becoming uniformly dense or empty. |

### Phase 2: Adjacency and Constraint (The Cohesion)
For your blocks to seamlessly tile together into a larger world, you need strict constraints on the edges. This is critical if you use Wave Function Collapse (WFC), as WFC operates entirely on these rules.

| Specification Area | Example Rule (for all blocks) | Goal |
|-------------------|-----------------------------------|------|
| Edge Tagging | Edge Tags (N, S, E, W): Each edge must be tagged with its dominant terrain type. If 50% or more of the edge is a road tile, tag it ROAD_A. Otherwise, tag it FOREST_DENSE. | Ensures that a ROAD_A block only connects to another ROAD_A block on that edge, preventing visual seams. |
| Neighbor Consistency | WFC Ruleset: The edge profiles of all input patterns must be perfectly complementary. (e.g., A Water tile pattern must only neighbor another Water tile pattern or a Beach transition pattern). | Guarantees local consistency and global coherence. |
| Forbidden States | Anti-Symmetry: No 4×4 area should be filled with identical tiles unless it is the pre-defined GRASS_CLEARED template. | Avoids the "stamped" look typical of simple noise generation. |

### Phase 3: Micro-Detail (The Scatter & Asymmetry)
This is how you achieve the "bushes here and there" effect, ensuring these small features feel natural and non-uniform, like a human placed them specifically.

Instead of random placement, you use a technique called Feature Masking or Noise-on-Noise.

| Specification Area | Example Rule (for adding Bushes) | Goal |
|-------------------|-----------------------------------|------|
| Fine-Grained Noise Pass | Bushes Placement Algorithm: For every grass tile, run a secondary, very high-frequency Perlin noise check. | Adds localized randomness that looks scattered, not tiled. |
| Masking/Exclusion | EXCLUDE Bushes/Small Rocks: from any tile within 2 tiles of a Major Feature (like the Dirt Path) or 1 tile of the block edge. | Keeps areas of interest clean and prevents visual clutter on structure edges, which is how a human would tidy up a path. |
| Cluster Probability | Small Group Rule: If a bush is placed, increase the probability (e.g., by 20%) that its immediate neighbors will also receive a bush decoration, up to a cluster size of 3 tiles. | Creates small, natural-looking clumps (clumps of bushes, small piles of pebbles) instead of purely scattered dots. |
| Variant Utilization | Detail Priority: Use the variant metadata (e.g., variant = math.random(1, 3) from your structure file) to assign different asset versions (e.g., Bush_Small, Bush_Medium, Bush_Dead). | Adds visual richness and avoids repetition without changing the tile functionality. |

By treating your procedural system as an "AI" that must adhere to this structured design prompt, you ensure the output is not just random, but intentional, connected, and rich in fine-grained detail.