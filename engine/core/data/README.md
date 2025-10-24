# Core Data

## Goal / Purpose
Stores core configuration data and lookup tables for the engine including global settings, facility definitions, terrain properties, and core game rules.

## Content
- **Core game settings** - Global configuration parameters
- **Facility definitions** - Base facility data
- **Terrain properties** - Terrain types and costs
- **Balance parameters** - Game difficulty and balance settings
- **Default values** - System default configurations
- **Reference tables** - Lookup tables and enumerations

## Features
- TOML-based configuration
- Centralized settings
- Easy balance adjustments
- Modular data organization
- Fallback defaults

## Integrations with Other Folders / Systems
- **engine/core/data_loader.lua** - Data loading system
- **engine/battlescape/data** - Battle-specific data
- **engine/basescape/data** - Base-specific data
- **engine/core/** - All core systems reference data
- **mods/core** - Modded data extensions
