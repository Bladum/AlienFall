# Utils

Utility functions and helpers for battle systems.

## Overview

The utils folder contains utility functions and helper modules that support the battle systems. These provide common functionality like mathematical operations, debugging tools, and coordinate conversions that are used across multiple battle systems.

## Files

### debug.lua
Debug visualization and logging utilities. Provides debug overlays, performance monitoring, and diagnostic tools for battle system development.

### hex_math.lua
Hexagonal grid mathematics utilities. Handles coordinate conversions between different hex coordinate systems (axial, offset, cube) and neighbor calculations.

## Usage

Utilities are imported as needed by battle systems:

```lua
local HexMath = require("battle.utils.hex_math")
local Debug = require("battle.utils.debug")

-- Convert coordinates
local axial = HexMath.offsetToAxial(10, 5)
local offset = HexMath.axialToOffset(axial.q, axial.r)

-- Debug visualization
if Debug.enabled then
    Debug.drawHexGrid(camera)
end
```

## Architecture

- **Pure Functions**: Utilities are stateless and side-effect free
- **Performance Critical**: Optimized for frequent use in game loops
- **Debug Support**: Optional debug features that can be disabled
- **Modular Design**: Each utility focuses on a specific domain

## Utility Categories

- **Mathematics**: Coordinate conversions and geometric calculations
- **Debugging**: Development tools and visualization
- **Serialization**: Data conversion and persistence helpers
- **Validation**: Input validation and error checking

## Dependencies

- **Love2D**: Graphics APIs for debug rendering
- **Math Library**: Standard Lua mathematical functions
- **Battle Systems**: Access to battle state for debugging