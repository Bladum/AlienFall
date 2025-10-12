# Utils

General utility functions and helpers.

## Overview

The utils directory contains shared utility functions used across the game engine.

## Files

### scaling.lua
Resolution scaling and viewport management utilities.

### verify_assets.lua
Asset validation and loading verification.

### viewport.lua
Camera and viewport calculation functions.

## Usage

```lua
local Scaling = require("utils.scaling")

-- Scale UI element for current resolution
local scaledX = Scaling:scaleX(100)
local scaledY = Scaling:scaleY(50)

-- Verify asset loading
local VerifyAssets = require("utils.verify_assets")
local success, missing = VerifyAssets:checkAll()
if not success then
    print("Missing assets:", table.concat(missing, ", "))
end
```

## Utility Categories

### Graphics Utils
- **Scaling**: Resolution-independent positioning
- **Viewport**: Camera calculations and bounds
- **Color**: Color manipulation and conversion

### Asset Utils
- **Verification**: Asset existence and integrity checks
- **Loading**: Centralized asset loading with error handling
- **Caching**: Asset caching and memory management

### Math Utils
- **Vector**: 2D/3D vector operations
- **Geometry**: Shape calculations and collision detection
- **Interpolation**: Smooth value transitions

## Performance Considerations

- **Caching**: Expensive operations cached where possible
- **Pooling**: Object pooling for frequently created objects
- **Optimization**: Math operations optimized for performance

## Dependencies

- **Love2D APIs**: Graphics, filesystem, and math functions
- **Game Config**: Resolution and display settings
- **Asset System**: Access to game assets