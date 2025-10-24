# Battlescape Data

## Goal / Purpose
Stores configuration data for battlescape systems including unit definitions, weapon specifications, terrain properties, and battle rules.

## Content
- **Unit data** - Base unit statistics and properties
- **Weapon data** - Weapon definitions and effects
- **Armor data** - Armor types and properties
- **Terrain data** - Terrain properties and costs
- **Battle rules** - Game balance parameters
- **Effect definitions** - Status effects and visual effects
- **Combat modifiers** - Difficulty and rule adjustments

## Features
- TOML-based configuration
- Modular definitions
- Easy balance adjustments
- Mod-friendly structure
- Reference data tables

## Integrations with Other Folders / Systems
- **engine/core/data_loader.lua** - Data loading system
- **engine/battlescape/combat** - Combat mechanics data
- **engine/battlescape/entities** - Unit data
- **engine/battlescape/battlefield** - Terrain data
- **engine/content/** - Content definitions
- **mods/core/rules** - Modded definitions
