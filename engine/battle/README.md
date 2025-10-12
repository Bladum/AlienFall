# Battle

Tactical combat systems for turn-based battlescape gameplay.

## Overview

The battle folder contains all systems related to tactical combat in XCOM Simple. This includes unit movement, combat mechanics, environmental effects (fire/smoke), map generation, and rendering systems. The battle system uses a hex-based grid with fog of war, line-of-sight calculations, and turn-based mechanics.

The architecture follows an ECS (Entity Component System) pattern with separate systems for different aspects of combat (animation, fire, smoke, etc.).

## Files

### Core Systems

#### animation_system.lua
Smooth animation system for unit movement and rotation. Handles path-based movement animations with configurable timing.

#### battlefield.lua
Battlefield map management with terrain generation and unit placement. Provides spatial queries and tile manipulation.

#### battlescape_integration.lua
Integration guide and status for migrating to the hex-based battle system. Contains step-by-step migration instructions.

#### fire_system.lua
Fire propagation and damage system. Manages fire spreading, unit damage, and smoke production with configurable probabilities.

#### map_generator.lua
Unified map generation interface supporting both procedural and mapblock-based generation. Configurable through TOML files.

#### map_saver.lua
Map export system saving battlefields as PNG images. Each pixel represents terrain type with color coding.

#### mapblock_system.lua
Map block management for procedural generation. Handles loading and arranging pre-designed 15x15 terrain blocks.

#### smoke_system.lua
Smoke dissipation and spreading system. Manages 3-level smoke with sight penalties and natural dissipation.

#### turn_manager.lua
Turn-based combat management. Handles turn order, action points, and team-based gameplay.

### Rendering & Camera

#### camera.lua
Camera control system with zoom, pan, and coordinate conversion. Handles viewport management and screen-to-world transformations.

#### renderer.lua
Battlefield rendering system. Draws tiles, units, effects, and UI with viewport optimization.

#### unit_selection.lua
Unit selection and path preview system. Handles mouse input, selection highlighting, and movement path visualization.

### Map Management

#### grid_map.lua
Grid-based map assembly system. Arranges map blocks into larger battlefields with biome theming.

#### map_block.lua
Individual map block template system. Defines 15x15 tile patterns that can be combined for larger maps.

### Subsystems

#### components/
Entity components for the ECS architecture:
- `health.lua` - Health and damage tracking
- `movement.lua` - Movement capabilities and AP costs
- `team.lua` - Team affiliation and relationships
- `transform.lua` - Position and orientation
- `vision.lua` - Sight range and visibility

#### entities/
Game entity definitions:
- `unit_entity.lua` - Complete unit entity with all components

#### systems/
Specialized battle systems:
- `hex_system.lua` - Hex grid coordinate management
- `movement_system.lua` - Unit movement and pathfinding
- `vision_system.lua` - Fog of war and line-of-sight

#### tests/
Battle system test suites:
- `test_all_systems.lua` - Comprehensive system testing
- `test_battlescape_systems.lua` - Battlescape integration tests
- `test_ecs_components.lua` - Component testing
- `test_mapblock_integration.lua` - Map block validation
- `test_performance.lua` - Performance benchmarking

#### utils/
Battle utility functions:
- `debug.lua` - Debug visualization and logging
- `hex_math.lua` - Hex coordinate mathematics

## Usage

Battle systems are initialized in the battlescape module:

```lua
-- Load battle systems
local Battlefield = require("battle.battlefield")
local TurnManager = require("battle.turn_manager")
local AnimationSystem = require("battle.animation_system")

-- Initialize battle
function Battlescape:enter()
    self.battlefield = Battlefield.new(60, 60)
    self.turnManager = TurnManager.new()
    self.animationSystem = AnimationSystem.new()
end
```

## Architecture

- **Hex Grid**: All positioning uses hexagonal coordinates for tactical gameplay
- **Turn-Based**: All actions consume Action Points (AP) with turn limits
- **Fog of War**: Vision system provides realistic line-of-sight
- **Environmental Effects**: Fire and smoke affect movement and visibility
- **Modular Design**: Systems can be enabled/disabled independently

## Dependencies

- **HexMath**: Coordinate conversion utilities
- **DataLoader**: Terrain and unit data loading
- **Love2D**: Graphics and input APIs
- **TOML**: Configuration file parsing

## Performance Considerations

- **Spatial Hashing**: Efficient collision detection
- **Viewport Culling**: Only render visible tiles
- **Animation Batching**: Smooth 60 FPS animations
- **LOS Caching**: Pre-calculated visibility for performance

## Testing

Run battle system tests:

```bash
love engine --test battle
```

Key test scenarios:
- Unit movement and pathfinding
- Fire spread and smoke dissipation
- Vision cone calculations
- Turn management and AP costs