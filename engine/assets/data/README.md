# Data

Game data files and configuration.

## Overview

The data directory contains configuration files, game data, and settings that define game behavior and content.

## Files

### mapgen_config.lua
Map generation configuration and parameters for procedural terrain creation.

## Usage

Data files are loaded by the data_loader system:

```lua
local DataLoader = require("systems.data_loader")
local config = DataLoader:loadConfig("data/mapgen_config.lua")
```

## Configuration Types

- **Map Generation**: Terrain, features, and layout parameters
- **Game Balance**: Unit stats, weapon properties, difficulty settings
- **UI Configuration**: Layout parameters and theme settings

## Dependencies

- **Data Loader**: TOML and Lua configuration loading
- **Game Systems**: Systems that consume configuration data
- **Mod System**: Data files can be overridden by mods