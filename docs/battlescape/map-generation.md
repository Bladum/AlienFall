# Battlescape Map Generation System

> **Implementation**: `engine/battlescape/mission_map_generator.lua`, `engine/battlescape/mapscripts/`
> **Configuration**: `mods/core/generation/`
> **Tests**: `tests/battlescape/`
> **Related**: `docs/geoscape/`, `docs/battlescape/maps.md`

The Map Generation System bridges strategic Geoscape missions to tactical Battlescape combat. It procedurally generates unique battlefields based on mission type, location biome, mission objectives, and map scripts.

## 🗺️ Generation Pipeline

### Step 1: Mission Context
Input from Geoscape mission defines generation parameters:
- **Mission Type**: Crash site, terror mission, base defense, etc.
- **Location Biome**: Forest, urban, desert, arctic, water, industrial
- **Mission Size**: Small (4×4), Medium (5×5), Large (6×6), Huge (7×7)
- **Objectives**: Primary and secondary goals to mark on map

### Step 2: Terrain Selection  
Biome-weighted random terrain selection:
- **Forest Biome**: 50% trees, 30% grass, 20% water features
- **Urban Biome**: 60% buildings, 25% pavement, 15% foliage
- **Desert Biome**: 70% sand, 20% rocks, 10% vegetation
- **Arctic Biome**: 50% snow, 30% ice, 20% rocks
- **Industrial**: 50% structures, 30% metal, 20% hazards

Mission can override terrain (e.g., force "ufo_crash" terrain for landing zones).

### Step 3: MapBlock Selection
Filter available MapBlocks by:
- Selected terrain type
- Difficulty rating (matches campaign difficulty)
- Special tags (ufo_landing, bridge, tower, etc.)
- Size compatibility (fits within mission dimensions)

### Step 4: MapScript Execution
Select MapScript (placement template) from available scripts:
- **City Crossroads**: Urban combat map with intersections
- **Forest River**: Terrain split by water feature
- **UFO Landing**: Landing zone with central UFO
- **Alien Base**: Multi-room facility layout
- **Rural Settlement**: Scattered buildings with fields

MapScript places MapBlocks in a grid pattern (4×4 to 7×7 blocks).

### Step 5: MapBlock Transformations
Apply random transformations for variety:
- **Rotation**: 0°, 90°, 180°, 270°
- **Mirror**: Horizontal, vertical, or both
- **Variation**: Select variant if MapBlock has multiple

Creates unique maps from limited MapBlock set.

### Step 6: Tile Assembly
Combine all transformed MapBlocks into single battlefield:
- Each MapBlock = 15×15 tiles
- 4×4 grid = 60×60 tiles total
- 7×7 grid = 105×105 tiles total
- Track which block each tile belongs to (for block-based rules)

### Step 7: Landing Zone Placement
Mark 1-4 landing zones based on map size:
- **Small (4×4)**: 1 landing zone
- **Medium (5×5)**: 2 landing zones
- **Large (6×6)**: 3 landing zones
- **Huge (7×7)**: 4 landing zones

Landing zones placed at edges or strategic locations.

### Step 8: Team & Unit Placement
Deploy units for all sides:
- **Player Units**: Random placement in landing zones
- **Ally Units**: Placed with player or at secondary zones
- **Enemy Units**: Placed at strategic positions (high ground, cover)
- **Neutral Units**: If applicable (civilians, wildlife)

Each team assigned color-coded designation (Red, Green, Blue, Yellow, etc.).

### Step 9: Environmental Effects
Optional environmental features:
- **Fire/Explosions**: Crash site remnants (UFO crash missions)
- **Hazards**: Acid pools, radiation zones (alien base missions)
- **Weather**: Rain, fog, snow effects affecting visibility
- **Collapsing Terrain**: Damaged structures (base defense)

### Step 10: Validation
Final validation before returning battlefield:
- All spawn points accessible (no unreachable terrain)
- Line of sight verified for objective areas
- No overlapping units
- Team spawn zones separated by minimum distance
- Memory check for large maps

## 🎮 Mission Types

### Crash Site Mission
- **Terrain**: Biome-appropriate (crash site has wreckage)
- **MapScript**: UFO Crash layout with central wreckage
- **Objectives**: Investigate crash, gather salvage
- **Size**: Medium (5×5)
- **Special**: Fire hazards, salvageable UFO components

### Terror Mission  
- **Terrain**: Urban or rural settlements
- **MapScript**: Settlement layout (houses, streets, fields)
- **Objectives**: Protect civilians, eliminate invaders
- **Size**: Large (6×6)
- **Special**: Civilian units, panic system, buildings

### Base Defense
- **Terrain**: Underground base facility
- **MapScript**: Base layout (corridors, rooms, hangars)
- **Objectives**: Defend base, eliminate intruders
- **Size**: Large (6×6)
- **Special**: Fixed structures, limited entry points, defense towers

### Alien Base Assault
- **Terrain**: Alien facility interior
- **MapScript**: Alien base layout (chambers, tunnels)
- **Objectives**: Rescue prisoners, steal research, destroy facility
- **Size**: Huge (7×7)
- **Special**: Alien structures, hazardous environment, multiple objectives

### UFO Landing Site
- **Terrain**: Biome-appropriate landing zone
- **MapScript**: UFO landing template
- **Objectives**: Contain UFO, prevent escape
- **Size**: Large (6×6)
- **Special**: UFO as centerpiece, landing crew spawning

## 📊 Biome System

Each biome defines:
- **Available Terrains**: Which terrain types appear (with weights)
- **Default MapScript**: Primary script if not overridden
- **Environmental Features**: Biome-specific hazards/features
- **Aesthetic Traits**: Color palette, vegetation, structures

### Biome Examples

**Forest Biome**
- Terrains: Trees (50%), Grass (30%), Water (20%)
- Features: Dense foliage (blocks vision), rivers
- Default Script: Forest River crossing

**Urban Biome**
- Terrains: Buildings (60%), Pavement (25%), Foliage (15%)
- Features: Building interiors, rooftops
- Default Script: City Crossroads intersection

**Desert Biome**
- Terrains: Sand (70%), Rocks (20%), Vegetation (10%)
- Features: Rocky outcrops, minimal cover
- Default Script: Desert Ruins scattered structures

## 🔧 MapBlock System

### MapBlock Definition
Each MapBlock is 15×15 tiles defining:
- **Tiles**: Terrain type, height, walkability
- **Objects**: Static structures (walls, furniture)
- **Decoration**: Non-functional visual elements
- **Spawn Points**: Optional unit spawn locations
- **Connections**: Links to adjacent MapBlocks (for seam matching)

### MapBlock Variants
MapBlocks can have multiple variants:
- **Variation A/B/C**: Different layout/decoration while maintaining connections
- **Clean/Damaged**: Different states (battle-worn vs pristine)
- **Day/Night**: Different lighting (for environmental effects)

### MapBlock Transformation Rules
- **Rotation**: Must maintain valid connections when rotated
- **Mirroring**: Some MapBlocks cannot be mirrored (one-way connections)
- **Seaming**: Adjacent blocks must align at boundaries

## 📋 Implementation Details

**Key Files:**
- `mission_map_generator.lua`: Main generation entry point
- `mapscript_selector.lua`: Selects appropriate MapScript
- `mapscript_executor.lua`: Executes MapScript commands
- `terrain_selector.lua`: Selects terrain by biome/mission
- `mapblock_loader.lua`: Loads MapBlock data files

**Configuration in mods/core/generation/:**
- `biomes.toml`: Biome definitions
- `terrains.toml`: Terrain types and weights
- `mapscripts.toml`: MapScript definitions
- `mapblocks/`: Directory of MapBlock TOML files
- `missions/`: Mission type definitions

**Data Flow:**
1. Geoscape → mission parameters
2. MissionMapGenerator → interpret parameters
3. Select terrain → MapBlocks → MapScript
4. Execute script → assemble tiles
5. Battlescape ← complete battlefield

## 🎯 Design Goals

- **Replayability**: Procedural generation creates unique maps
- **Thematic Consistency**: Biome + terrain creates logical environments
- **Tactical Variety**: Multiple MapScripts per terrain prevent repetition
- **Performance**: Reasonable generation time (<1 second)
- **Scalability**: Support multiple map sizes (4×4 to 7×7)
- **Moddability**: All generation parameters configurable via TOML

## 🔗 Cross-System Integration

### With Geoscape
- Mission parameters provide generation seed
- Campaign phase affects mission type availability
- Strategic location determines biome selection

### With Battlescape
- Generated map data passed to battle system
- Unit placement coordinates determined by generation
- Environmental effects carried through to battle

### With Campaign/Lore
- Mission type evolves through campaign phases
- Alien base structures reflect faction technology level
- Environmental hazards reflect campaign progression

