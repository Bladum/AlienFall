# Hex Rendering Guide

## Overview

AlienFall uses a **hexagonal grid** for tactical combat maps instead of the traditional square grid. This provides:
- **6-directional movement** (N, NE, SE, S, SW, NW)
- **More natural terrain flow**
- **Better tactical positioning**
- **Easier diagonal movement**

This guide explains how the hex grid system works and how to use the HexRenderer.

---

## Hex Grid Basics

### Flat-Top Hexagons

We use **flat-top hexagons** with the flat edge on top/bottom:

```
    ___
   /   \
  /     \
  \     /
   \___/
```

### Coordinate System

We use an **odd-column offset** system:
- Even columns (x=0, 2, 4...): Standard height
- Odd columns (x=1, 3, 5...): Offset down by half a hex height

```
Even Column (x=0):    Odd Column (x=1):
  ┌───┐                 ┌───┐
  │0,0│               ← │1,0│ (offset down)
  └───┘                 └───┘
  ┌───┐                 ┌───┐
  │0,1│                 │1,1│
  └───┘                 └───┘
```

---

## HexRenderer API

### Creating a Renderer

```lua
local HexRenderer = require("battlescape.rendering.hex_renderer")

local renderer = HexRenderer.new(24)  -- 24-pixel hex size
```

### Core Methods

#### Coordinate Conversion

**Hex to Pixel:**
```lua
local pixelX, pixelY = renderer:hexToPixel(hexX, hexY)
```

Converts hex grid coordinates to screen pixel coordinates.

**Pixel to Hex:**
```lua
local hexX, hexY = renderer:pixelToHex(pixelX, pixelY)
```

Converts screen pixel coordinates to hex grid coordinates (for mouse picking).

---

### Rendering Tiles

#### Render Single Map Tile

```lua
renderer:renderMapTile(
    tileKey,      -- "tileset:tileId"
    hexX, hexY,   -- Hex grid position
    zoom,         -- Zoom level (1.0 = normal)
    brightness,   -- Brightness 0.0-1.0
    map           -- Optional: full map grid for autotile
)
```

**Example:**
```lua
renderer:renderMapTile("urban:floor_01", 5, 5, 1.0, 1.0)
```

This automatically handles:
- Multi-tile modes (variants, animation, autotile, multi-cell, damage)
- Hex coordinate conversion
- Proper layering (Z-order)

---

### Neighbor System

#### Get 6 Neighbors

```lua
local neighbors = renderer:getHexNeighbors(hexX, hexY)
```

Returns array of 6 neighbors in order: N, NE, SE, S, SW, NW

**Neighbor Order:**
```
     [N]
[NW]  *  [NE]
[SW]  *  [SE]
     [S]
```

**Example:**
```lua
local neighbors = renderer:getHexNeighbors(5, 5)
for i, n in ipairs(neighbors) do
    print(string.format("Neighbor %d: (%d, %d)", i, n.x, n.y))
end
```

---

### Autotile System

#### Calculate Hex Autotile Mask

```lua
local mask = renderer:calculateHexAutotile(map, hexX, hexY, matchKey)
```

Returns a **6-bit bitmask** (0-63) representing which of the 6 neighbors match the given tile KEY.

**Bit Mapping:**
- Bit 0 (value 1): North
- Bit 1 (value 2): Northeast
- Bit 2 (value 4): Southeast
- Bit 3 (value 8): South
- Bit 4 (value 16): Southwest
- Bit 5 (value 32): Northwest

**Examples:**
```
Mask 0  (000000) = No neighbors match
Mask 1  (000001) = Only North matches
Mask 3  (000011) = North + NE match
Mask 63 (111111) = All 6 neighbors match
```

**Usage:**
```lua
local map = {
    ["5_5"] = "urban:floor_01",
    ["5_4"] = "urban:floor_01",  -- North
    ["6_4"] = "urban:floor_01",  -- NE
    ["6_5"] = "urban:floor_01",  -- SE
    -- ...
}

local mask = renderer:calculateHexAutotile(map, 5, 5, "urban:floor_01")
-- Returns integer 0-63 representing neighbor matches
```

---

### Grid Overlay

#### Toggle Grid Display

```lua
renderer:toggleGrid()
```

Shows/hides hex grid overlay for debugging.

#### Draw Grid

```lua
renderer:drawHexGrid(startX, startY, width, height, zoom)
```

Draws hex grid lines from (startX, startY) for width×height hexes.

**Example:**
```lua
renderer:drawHexGrid(0, 0, 20, 15, 1.0)
```

---

### Multi-Cell Tiles

#### Check if Multi-Cell

```lua
local isMulti = renderer:isMultiCell(tileKey)
```

Returns true if the tile occupies multiple hex cells.

#### Render Multi-Cell Tile

```lua
renderer:renderMultiCellTile(tileKey, hexX, hexY, zoom, brightness)
```

Renders a multi-cell tile starting at (hexX, hexY).

**Note:** `renderMapTile()` automatically calls this for multi-cell tiles.

---

## Hex Coordinate Math

### Hex Dimensions

For a hex with size `tileSize`:
```lua
local hexWidth = tileSize * math.sqrt(3)
local hexHeight = tileSize * 2
```

For `tileSize = 24`:
- `hexWidth` ≈ 41.57 pixels
- `hexHeight` = 48 pixels

### Pixel to Hex Conversion

```lua
function pixelToHex(pixelX, pixelY)
    local hexWidth = tileSize * math.sqrt(3)
    local hexHeight = tileSize * 2
    
    local x = math.floor(pixelX / hexWidth)
    local y = math.floor(pixelY / hexHeight)
    
    -- Adjust for odd-column offset
    if x % 2 == 1 then
        y = math.floor((pixelY - hexHeight * 0.5) / hexHeight)
    end
    
    return x, y
end
```

### Hex to Pixel Conversion

```lua
function hexToPixel(hexX, hexY)
    local hexWidth = tileSize * math.sqrt(3)
    local hexHeight = tileSize * 2
    
    local x = hexX * hexWidth
    local y = hexY * hexHeight
    
    -- Offset odd columns
    if hexX % 2 == 1 then
        y = y + hexHeight * 0.5
    end
    
    return x, y
end
```

---

## Neighbor Calculation

### Even Column Neighbors

For even columns (x % 2 == 0):
```lua
neighbors = {
    {x, y - 1},     -- North
    {x + 1, y - 1}, -- NE
    {x + 1, y},     -- SE
    {x, y + 1},     -- South
    {x - 1, y},     -- SW
    {x - 1, y - 1}  -- NW
}
```

### Odd Column Neighbors

For odd columns (x % 2 == 1):
```lua
neighbors = {
    {x, y - 1},     -- North
    {x + 1, y},     -- NE
    {x + 1, y + 1}, -- SE
    {x, y + 1},     -- South
    {x - 1, y + 1}, -- SW
    {x - 1, y}      -- NW
}
```

**Visual:**
```
Even Column (x=0):        Odd Column (x=1):
     [0,-1]                    [1,-1]
[-1,-1]  [1,-1]           [-1, 0]  [1, 0]
     (0,0)                     (1,0)
[-1, 0]  [1, 0]           [-1,+1]  [1,+1]
     [0,+1]                    [1,+1]
```

---

## Integration with Map Tiles

### Rendering a Map Block on Hex Grid

```lua
local HexRenderer = require("battlescape.rendering.hex_renderer")
local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")

-- Load Map Block
MapBlockLoader.loadAll("mods/core/mapblocks")
local block = MapBlockLoader.get("urban_small_01")

-- Create renderer
local renderer = HexRenderer.new(24)

-- Render all tiles
for y = 0, block.height - 1 do
    for x = 0, block.width - 1 do
        local key = string.format("%d_%d", x, y)
        local tileKey = block.tiles[key]
        
        if tileKey and tileKey ~= "EMPTY" then
            renderer:renderMapTile(tileKey, x, y, 1.0, 1.0, block.tiles)
        end
    end
end

-- Draw grid overlay
renderer:toggleGrid()
renderer:drawHexGrid(0, 0, block.width, block.height, 1.0)
```

---

## Autotile Examples

### Floor Autotile

For seamless floor transitions, use autotile:

```lua
-- Map with floor tiles
local map = {}
for y = 0, 10 do
    for x = 0, 10 do
        map[string.format("%d_%d", x, y)] = "urban:floor_01"
    end
end

-- Render with autotile
for y = 0, 10 do
    for x = 0, 10 do
        local key = string.format("%d_%d", x, y)
        renderer:renderMapTile("urban:floor_01", x, y, 1.0, 1.0, map)
    end
end
```

The renderer will automatically select the correct autotile variant (0-63) based on neighbors.

### Wall Autotile

Walls connect based on adjacent walls:

```lua
-- Create room perimeter
local map = {}
for x = 0, 9 do
    map[string.format("%d_0", x)] = "urban:wall_01"  -- Top
    map[string.format("%d_9", x)] = "urban:wall_01"  -- Bottom
end
for y = 0, 9 do
    map[string.format("0_%d", y)] = "urban:wall_01"  -- Left
    map[string.format("9_%d", y)] = "urban:wall_01"  -- Right
end

-- Render with autotile (corners and connections automatic)
for key, tileKey in pairs(map) do
    local x, y = key:match("^(%d+)_(%d+)$")
    renderer:renderMapTile(tileKey, tonumber(x), tonumber(y), 1.0, 1.0, map)
end
```

---

## Performance Considerations

### Rendering Large Maps

For maps larger than 40×30:
1. **Cull off-screen tiles** - Only render visible hexes
2. **Batch rendering** - Group tiles by tileset
3. **Cache hex coordinates** - Pre-calculate for static maps

**Example Culling:**
```lua
local camera = {x = 0, y = 0, width = 20, height = 15}

for y = camera.y, camera.y + camera.height do
    for x = camera.x, camera.x + camera.width do
        -- Only render visible tiles
        renderer:renderMapTile(tileKey, x, y, 1.0, 1.0, map)
    end
end
```

### Autotile Caching

Calculate autotile masks once and cache:

```lua
local autotileCache = {}

for y = 0, height - 1 do
    for x = 0, width - 1 do
        local key = string.format("%d_%d", x, y)
        local tileKey = map[key]
        if tileKey then
            autotileCache[key] = renderer:calculateHexAutotile(map, x, y, tileKey)
        end
    end
end
```

---

## Common Patterns

### Mouse Picking

Convert mouse position to hex coordinates:

```lua
function love.mousepressed(x, y, button)
    local hexX, hexY = renderer:pixelToHex(x, y)
    print(string.format("Clicked hex: (%d, %d)", hexX, hexY))
    
    -- Get tile at hex
    local key = string.format("%d_%d", hexX, hexY)
    local tileKey = map[key]
    print("Tile: " .. (tileKey or "EMPTY"))
end
```

### Pathfinding on Hex Grid

Use 6-neighbor system for A*:

```lua
function getNeighbors(node)
    local neighbors = renderer:getHexNeighbors(node.x, node.y)
    local validNeighbors = {}
    
    for _, n in ipairs(neighbors) do
        local key = string.format("%d_%d", n.x, n.y)
        if map[key] and isWalkable(map[key]) then
            table.insert(validNeighbors, {x = n.x, y = n.y})
        end
    end
    
    return validNeighbors
end
```

### Line of Sight (LOS)

Calculate LOS between hexes:

```lua
function hasLineOfSight(fromX, fromY, toX, toY)
    -- Bresenham line algorithm adapted for hexes
    local current = {x = fromX, y = fromY}
    
    while current.x ~= toX or current.y ~= toY do
        -- Move toward target
        local neighbors = renderer:getHexNeighbors(current.x, current.y)
        local best = findClosestNeighbor(neighbors, toX, toY)
        
        -- Check for blocking tiles
        local key = string.format("%d_%d", best.x, best.y)
        if map[key] and blocksLOS(map[key]) then
            return false  -- Blocked
        end
        
        current = best
    end
    
    return true  -- Clear LOS
end
```

---

## Debugging

### Visualize Hex Grid

Enable grid overlay:
```lua
renderer:toggleGrid()  -- Press F9 in game
```

Green lines show hex boundaries.

### Visualize Neighbors

Draw neighbor connections:
```lua
function drawNeighbors(hexX, hexY)
    local neighbors = renderer:getHexNeighbors(hexX, hexY)
    local cx, cy = renderer:hexToPixel(hexX, hexY)
    
    for _, n in ipairs(neighbors) do
        local nx, ny = renderer:hexToPixel(n.x, n.y)
        love.graphics.line(cx, cy, nx, ny)
    end
end
```

### Visualize Autotile Mask

Print autotile as binary:
```lua
local mask = renderer:calculateHexAutotile(map, x, y, tileKey)
print(string.format("Mask: %d (binary: %06b)", mask, mask))
```

---

## Comparison: Square vs Hex Grid

### Square Grid (4 neighbors)
```
  [N]
[W] * [E]
  [S]
```
- 4 cardinal directions
- 8 with diagonals
- Unequal movement costs (diagonal = 1.41×)

### Hex Grid (6 neighbors)
```
    [N]
[NW] * [NE]
[SW] * [SE]
    [S]
```
- 6 equal directions
- All neighbors equidistant
- Natural diagonal movement
- Better terrain flow

---

## Further Reading

- **[Map Tile Reference](MAP_TILE_KEY_REFERENCE.md)** - All available tiles
- **[Map Editor Guide](MAP_EDITOR_GUIDE.md)** - Creating Map Blocks
- **[Tileset System](TILESET_SYSTEM.md)** - Tile organization
- **[Map Block Guide](MAPBLOCK_GUIDE.md)** - Map Block format

---

## API Quick Reference

```lua
-- Create renderer
local renderer = HexRenderer.new(tileSize)

-- Coordinate conversion
local px, py = renderer:hexToPixel(hexX, hexY)
local hx, hy = renderer:pixelToHex(pixelX, pixelY)

-- Get neighbors (6 hexes)
local neighbors = renderer:getHexNeighbors(hexX, hexY)

-- Calculate autotile (0-63)
local mask = renderer:calculateHexAutotile(map, hexX, hexY, matchKey)

-- Render tile
renderer:renderMapTile(tileKey, hexX, hexY, zoom, brightness, map)

-- Grid overlay
renderer:toggleGrid()
renderer:drawHexGrid(startX, startY, width, height, zoom)

-- Multi-cell
local isMulti = renderer:isMultiCell(tileKey)
renderer:renderMultiCellTile(tileKey, hexX, hexY, zoom, brightness)
```

---

**Happy Hex Rendering!** 🔷
