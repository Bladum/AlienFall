# Mods

Mod content and customization system.

## Overview

The mods directory contains user-created modifications and custom content for the game.

## Directory Structure

### new/
Directory for new mod development and testing.

## Mod System

Mods are loaded by the mod manager:

```lua
local ModManager = require("core.mod_manager")

-- Load all available mods
ModManager:loadMods()

-- Check if mod is active
if ModManager:isModActive("custom_units") then
    -- Use modded content
end
```

## Mod Types

- **Content Mods**: New units, weapons, maps
- **Balance Mods**: Changed stats and gameplay values
- **UI Mods**: Interface customization and themes
- **Total Conversions**: Complete gameplay overhauls

## Development

Mods are developed in the `mods/` directory:

```
mods/
├── my_mod/
│   ├── init.lua      -- Mod entry point
│   ├── data/         -- Mod data files
│   └── assets/       -- Mod assets
```

## Dependencies

- **Mod Manager**: Loads and manages mod lifecycle
- **Data Loader**: Processes mod configuration files
- **Asset System**: Loads mod-provided assets
- **Game Systems**: All systems support mod integration
