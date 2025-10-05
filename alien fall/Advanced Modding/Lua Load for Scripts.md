# Lua Load for Scripts

## Overview
Lua script loading enables mods to execute custom logic and behaviors that extend core game functionality. Mod scripts can hook into game events, modify mechanics, add new features, and create entirely new gameplay experiences. This system provides powerful modding capabilities while maintaining game stability.

## Mechanics
- Script execution during game initialization and runtime
- Event hooking system for game state changes
- API access for game systems modification
- Error handling and sandboxing for security
- Load order management for script dependencies
- Hot reloading support for development

## Examples
| Script Type | Purpose | Hook Points | Example Use |
|-------------|---------|-------------|-------------|
| Unit Mod | Custom unit behaviors | Combat events | New special abilities |
| UI Mod | Interface modifications | Render events | Custom HUD elements |
| Balance Mod | Stat adjustments | Initialization | Difficulty tweaks |

## References
- World of Warcraft - Lua scripting system
- Garry's Mod - Lua modding framework
- See also: Mod Validation, Mod Dependencies, Core Engine