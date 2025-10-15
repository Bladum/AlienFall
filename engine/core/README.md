# Systems

Core game systems providing fundamental functionality for XCOM Simple.

## Overview

The systems folder contains all core game logic modules that provide essential functionality across different game modes (Geoscape, Battlescape, Basescape). These systems handle data management, game state, UI, assets, and various utility functions that are used throughout the application.

Each system is designed to be modular and reusable, with clear separation of concerns. Systems communicate through well-defined interfaces and can be initialized independently.

## Files

### action_system.lua
Manages unit actions and combat mechanics in tactical battles. Handles action execution, validation, and turn-based action limits.

### assets.lua
Central asset management system for loading and caching game resources (images, sounds, fonts). Provides optimized asset loading with error handling.

### battle_tile.lua
Defines the BattleTile class representing individual map tiles in tactical combat. Contains terrain data, unit references, and tile effects.

### data_loader.lua
TOML-based data loading system for game configuration. Loads terrain types, unit stats, weapons, and other game data from external files.

### los_optimized.lua
Optimized line-of-sight calculations for tactical combat. Provides fast visibility checking with caching for performance.

### los_system.lua
Line-of-sight system for determining what units can see on the battlefield. Handles fog of war and vision cones.

### mapblock_validator.lua
Validation system for map block data. Ensures map blocks are properly formatted and contain valid terrain references.

### mod_manager.lua
Mod loading and management system. Handles loading custom content from the mods/ directory with dependency resolution.

### pathfinding.lua
A* pathfinding algorithm implementation for unit movement. Finds optimal paths around obstacles on the battlefield.

### spatial_hash.lua
Spatial partitioning system for efficient collision detection and proximity queries. Organizes objects in 2D space for fast lookups.

### state_manager.lua
Game state management system. Handles transitions between different game screens (menu, geoscape, battlescape, etc.).

### team.lua
Team and faction management system. Handles team relationships, visibility, and multi-team gameplay.

### ui.lua
User interface management system. Provides widget creation, layout, and event handling for the game's UI.

### unit.lua
Unit entity system defining character classes, stats, and combat capabilities. Core unit management for all game modes.

## Usage

Systems are typically loaded and initialized in main.lua or module entry points:

```lua
-- Load core systems
local StateManager = require("systems.state_manager")
local Assets = require("systems.assets")
local DataLoader = require("systems.data_loader")

-- Initialize in love.load()
function love.load()
    stateManager = StateManager.new()
    assets = Assets.new()
    dataLoader = DataLoader.new()
end
```

## Dependencies

- **Love2D Framework**: Graphics, input, filesystem APIs
- **TOML Library**: For configuration file parsing
- **Hex Math Utilities**: For coordinate conversions in battle systems

## Architecture Notes

- **Singleton Pattern**: Most systems follow singleton pattern with .new() constructors
- **Event-Driven**: Systems communicate through callbacks and state changes
- **Performance Optimized**: Heavy calculations use caching and spatial partitioning
- **Moddable**: All systems support extension through the mod system

## Testing

Unit tests for systems are located in `engine/tests/systems/`. Run tests with:

```bash
love engine --test systems
```