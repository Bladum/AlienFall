# Systems

Specialized battle systems for the Entity Component System.

## Overview

The systems folder contains specialized systems that operate on entities with specific components. Each system handles a particular aspect of gameplay (movement, vision, hex grid management) and processes entities that have the required components.

Systems follow the ECS pattern where they iterate over entities and perform operations based on component data.

## Files

### hex_system.lua
Hexagonal grid management system. Handles coordinate conversions, neighbor calculations, and spatial queries on the hex battlefield.

### movement_system.lua
Unit movement and pathfinding system. Calculates movement costs, validates paths, and executes unit movement with AP consumption.

### vision_system.lua
Fog of war and line-of-sight system. Calculates visibility, updates fog of war, and manages vision cones for all units.

## Usage

Systems are initialized and updated in the battle loop:

```lua
local HexSystem = require("battle.systems.hex_system")
local MovementSystem = require("battle.systems.movement_system")
local VisionSystem = require("battle.systems.vision_system")

-- Initialize systems
hexSystem = HexSystem.new(60, 60, 24)
movementSystem = MovementSystem.new()
visionSystem = VisionSystem.new()

-- Update each frame
function love.update(dt)
    MovementSystem.update(hexSystem, dt)
    VisionSystem.update(hexSystem, dt)
end
```

## Architecture

- **Component Queries**: Systems find entities with required components
- **Update Loops**: Systems process entities in update methods
- **Event-Driven**: Systems respond to game events and user input
- **Performance Optimized**: Efficient algorithms for real-time updates

## System Categories

- **Spatial Systems**: Handle positioning and movement (hex_system, movement_system)
- **Perception Systems**: Manage visibility and awareness (vision_system)
- **Combat Systems**: Handle damage and effects (future: combat_system)

## Dependencies

- **ECS Framework**: Entity and component management
- **HexMath**: Mathematical utilities for hex coordinates
- **Battlefield**: Map data and terrain information