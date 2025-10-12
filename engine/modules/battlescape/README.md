# Battlescape

Battlescape screen implementation split into logical components.

## Overview

The battlescape submodule contains the tactical combat screen implementation, organized into separate files for different concerns (input, logic, rendering, UI). This modular structure improves maintainability and allows for focused development on specific aspects of the battlescape.

## Files

### init.lua
Battlescape module initialization and main entry point. Sets up the battle state, loads systems, and coordinates between submodules.

### input.lua
Input handling for battlescape interactions. Processes mouse clicks, keyboard input, and translates them into game actions.

### logic.lua
Game logic and state management. Handles turn progression, unit actions, AI decisions, and battle state updates.

### render.lua
Rendering and drawing systems. Handles battlefield visualization, unit sprites, effects, and camera management.

### ui.lua
User interface components specific to battlescape. Manages tactical UI elements like action buttons, unit info panels, and turn indicators.

## Usage

The battlescape module is loaded as a single unit but delegates to submodules:

```lua
local Battlescape = require("modules.battlescape")

function Battlescape:enter()
    self:init()  -- Initialize battle state
end

function Battlescape:update(dt)
    self:logic(dt)  -- Update game logic
end

function Battlescape:draw()
    self:render()  -- Draw battlefield
    self:ui()      -- Draw UI overlay
end
```

## Architecture

- **Separation of Concerns**: Each file handles a specific aspect
- **Clean Interfaces**: Submodules communicate through well-defined APIs
- **Performance**: Rendering and logic can be optimized independently
- **Testability**: Individual components can be unit tested

## Dependencies

- **Battle Systems**: All battle/ folder systems
- **UI Framework**: Widget system for interface elements
- **Input System**: Love2D input handling
- **Asset System**: Sprites and visual resources