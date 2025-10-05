# Mod Loader

## Overview
The Mod Loader is a core system responsible for loading and managing mods that extend the game's content and functionality. It supports a data-driven design approach using TOML files for content definition and Lua scripting for complex behaviors, enabling extensive moddability while maintaining game stability.

## Mechanics
- **Mod Discovery**: Scans designated mod directories for valid mod packages
- **Dependency Resolution**: Checks and resolves mod dependencies before loading
- **Conflict Detection**: Identifies potential conflicts between mods and base game content
- **Load Order Management**: Determines the correct loading sequence based on dependencies
- **Hot Reload Support**: Allows reloading mods during development without restarting the game
- **Validation**: Performs integrity checks on mod files and configurations
- **Error Handling**: Provides detailed error reporting for failed mod loads

## Examples
| Mod Type | Description | Dependencies |
|----------|-------------|--------------|
| Content Mod | Adds new units, items, or maps | None |
| Balance Mod | Modifies game balance values | Base game |
| UI Mod | Changes interface elements | GUI Widgets |
| Script Mod | Adds new gameplay mechanics | Lua runtime |

## References
- XCOM: Extensive modding community with similar loading systems
- Civilization series: Data-driven mod support
- See Mod Validator for validation mechanics
- See Mod Dependencies for dependency management