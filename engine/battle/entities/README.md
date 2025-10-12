# Entities

Battle entity definitions for the Entity Component System.

## Overview

The entities folder contains complete entity definitions that combine multiple components to create functional game objects. Entities represent the actual objects in the game world (units, buildings, projectiles, etc.) and are composed of components that define their properties and behaviors.

## Files

### unit_entity.lua
Complete unit entity definition combining health, movement, team, transform, and vision components. Represents playable characters and AI units in tactical combat.

## Usage

Entities are created through factories or directly:

```lua
local UnitEntity = require("battle.entities.unit_entity")

-- Create a soldier unit
local soldier = UnitEntity.new({
    q = 10, r = 5,        -- Hex coordinates
    teamId = 1,           -- Player team
    maxHP = 100,          -- Health
    movementRange = 6,    -- AP cost per hex
    visionRange = 12      -- Sight distance
})

-- Add to battle system
HexSystem.addUnit(hexSystem, soldier.id, soldier)
```

## Architecture

- **Component Aggregation**: Entities combine multiple components
- **Unique IDs**: Each entity has a unique identifier
- **Runtime Modification**: Components can be added/removed dynamically
- **Serialization**: Entities can be saved/loaded from data files

## Entity Types

- **Units**: Playable characters with movement and combat capabilities
- **Buildings**: Static structures that may provide cover or objectives
- **Projectiles**: Temporary entities for bullet trajectories
- **Effects**: Visual effects like explosions or smoke clouds

## Dependencies

- **Components**: All component modules
- **HexSystem**: Entity registration and management
- **DataLoader**: Entity template loading