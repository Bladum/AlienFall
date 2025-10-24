# Battlescape Entities

## Goal / Purpose
Manages individual unit entities during combat including their state, inventory, statistics, and entity lifecycle. Provides the entity component system (ECS) interface for units.

## Content
- **Entity definitions** - Unit entity class and structure
- **Unit inventory** - Equipment and item management for units
- **Unit state** - Health, morale, actions points, status
- **Stat calculations** - Derived statistics and modifiers
- **Entity lifecycle** - Creation, updates, destruction
- **Component system** - ECS components and properties
- **Unit behavior state** - AI state and decision data

## Features
- ECS-based entity system
- Inventory management
- Stat calculation and tracking
- Status effect management
- State serialization
- Efficient entity queries

## Integrations with Other Folders / Systems
- **engine/battlescape/battle_ecs** - ECS system core
- **engine/battlescape/combat** - Unit damage and effects
- **engine/battlescape/battlefield** - Entity positioning
- **engine/battlescape/rendering** - Entity visualization
- **engine/content/units** - Unit definitions
- **engine/content/items** - Unit equipment
- **engine/battlescape/systems** - Entity management
