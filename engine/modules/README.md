# Modules

Game screen modules implementing different game modes and interfaces.

## Overview

The modules folder contains the main game screens and modes that make up XCOM Simple. Each module represents a distinct game state (menu, geoscape, battlescape, etc.) with its own update/render logic and user interface.

Modules follow a consistent lifecycle pattern with enter(), update(), draw(), and leave() methods for state management.

## Files

### basescape.lua
Base management screen. Handles facility placement, research, manufacturing, and soldier management on a 6x6 grid.

### battlescape.lua
Tactical combat screen. Manages turn-based battles with unit movement, combat, and environmental effects.

### geoscape.lua
Strategic world map screen. Shows provinces, tracks UFO activity, and manages global operations.

### map_editor.lua
Map editing tool for creating and modifying battle maps. Provides terrain painting and unit placement.

### menu.lua
Main menu screen with navigation to different game modes and settings.

### tests_menu.lua
Test menu providing access to various testing and debugging features.

### widget_showcase.lua
UI widget demonstration screen. Shows all available UI components and their usage.

## Subfolders

### battlescape/
Battlescape-specific modules and utilities.

### geoscape/
Geoscape-specific modules and utilities.

## Usage

Modules are loaded by the state manager:

```lua
local StateManager = require("systems.state_manager")
local Menu = require("modules.menu")
local Battlescape = require("modules.battlescape")

-- Register modules
stateManager:registerState("menu", Menu)
stateManager:registerState("battlescape", Battlescape)

-- Switch states
stateManager:switchTo("battlescape")
```

## Architecture

- **State Pattern**: Each module encapsulates a complete game state
- **Love2D Callbacks**: Modules implement Love2D event handlers
- **Resource Management**: Modules handle their own asset loading/cleanup
- **UI Integration**: Modules create and manage their UI widgets

## Module Lifecycle

1. **enter()**: Called when entering the module, initialize state
2. **update(dt)**: Called each frame, update game logic
3. **draw()**: Called each frame, render the module
4. **leave()**: Called when leaving, cleanup resources

## Dependencies

- **StateManager**: Module registration and switching
- **UI System**: Widget creation and management
- **Asset System**: Resource loading and caching
- **Game Systems**: Access to core game functionality