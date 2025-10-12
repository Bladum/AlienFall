# Components

Entity Component System (ECS) components for battle entities.

## Overview

The components folder contains modular components that define the properties and behaviors of battle entities. Each component represents a specific aspect of an entity (health, movement, vision, etc.) and can be mixed and matched to create different types of units and objects.

This follows the Entity Component System architecture where entities are composed of multiple components rather than inheriting from base classes.

## Files

### health.lua
Health and damage tracking component. Manages hit points, damage application, and death states.

### movement.lua
Movement capabilities component. Defines movement speed, action point costs, and terrain movement modifiers.

### team.lua
Team affiliation component. Handles team relationships, enemy detection, and multi-team gameplay.

### transform.lua
Position and orientation component. Manages entity position, rotation, and coordinate transformations.

### vision.lua
Vision and sight component. Controls sight range, fog of war visibility, and line-of-sight calculations.

## Usage

Components are attached to entities in the ECS system:

```lua
local UnitEntity = require("battle.entities.unit_entity")

-- Create entity with components
local unit = UnitEntity.new({
    position = {q = 5, r = 3},
    teamId = 1,
    maxHP = 100,
    movementRange = 6,
    visionRange = 12
})
```

## Architecture

- **Composability**: Entities can have any combination of components
- **Data-Driven**: Component properties loaded from configuration files
- **Performance**: Efficient data structures for fast access
- **Modularity**: Components can be added/removed at runtime

## Dependencies

- **ECS Framework**: Entity management system
- **DataLoader**: Component configuration loading
- **HexMath**: Coordinate system for positioning