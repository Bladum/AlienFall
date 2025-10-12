# ECS Battle System API Documentation

## Overview

The ECS (Entity Component System) battle system provides hexagonal grid-based tactical combat with advanced movement, vision, and pathfinding capabilities.

**Location:** `engine/systems/battle/`

**Key Features:**
- Hexagonal grid coordinate system (even-Q vertical offset layout)
- Action Point-based movement (2 AP/hex, 1 AP/rotation)
- 120° directional vision cones with line-of-sight
- A* pathfinding with obstacle avoidance
- Component-based entity composition
- Debug visualization tools (F8/F9/F10 toggles)

---

## Architecture

### Components (Pure Data)
- `components/transform.lua` - Position (q, r) + facing (0-5)
- `components/movement.lua` - AP system + path tracking
- `components/vision.lua` - Vision range, arc, visibility cache
- `components/health.lua` - HP, armor, damage tracking
- `components/team.lua` - Team affiliation + colors

### Systems (Logic Processors)
- `systems/hex_system.lua` - Grid management
- `systems/movement_system.lua` - Movement + pathfinding
- `systems/vision_system.lua` - LOS + FOW

### Entities (Composition)
- `entities/unit_entity.lua` - Units with all components

### Utilities (Pure Functions)
- `utils/hex_math.lua` - Hex coordinate mathematics
- `utils/debug.lua` - Debug visualization

---

## Hex Coordinate System

### Coordinate Types

**Offset Coordinates (col, row)**
- Display/rendering coordinates
- Used for tile storage
- Range: 0 to mapSize-1

**Axial Coordinates (q, r)**
- Internal storage format
- Used by hex math functions
- Derived from offset coordinates

**Cube Coordinates (q, r, s)**
- Used for distance calculations
- Constraint: q + r + s = 0
- Converted from axial as needed

### Direction Encoding (0-5)

```
     2 (NW)   1 (NE)
          \ /
    3 (W)--●--> 0 (E)
          / \
     4 (SW)   5 (SE)
```

---

## HexMath API (`utils/hex_math.lua`)

### Coordinate Conversion

**`HexMath.offsetToAxial(col, row)`**
- Convert offset coordinates to axial
- **Parameters:** col, row (numbers)
- **Returns:** q, r (numbers)
- **Example:**
```lua
local q, r = HexMath.offsetToAxial(10, 20)
```

**`HexMath.axialToOffset(q, r)`**
- Convert axial coordinates to offset
- **Parameters:** q, r (numbers)
- **Returns:** col, row (numbers)
- **Example:**
```lua
local col, row = HexMath.axialToOffset(5, 8)
```

**`HexMath.axialToCube(q, r)`**
- Convert axial to cube coordinates
- **Parameters:** q, r (numbers)
- **Returns:** q, r, s (numbers)

**`HexMath.cubeToAxial(q, r, s)`**
- Convert cube to axial coordinates
- **Parameters:** q, r, s (numbers)
- **Returns:** q, r (numbers)

### Neighbor Operations

**`HexMath.neighbor(q, r, direction)`**
- Get neighbor in specific direction
- **Parameters:** q, r (numbers), direction (0-5)
- **Returns:** neighborQ, neighborR (numbers)
- **Example:**
```lua
local eastQ, eastR = HexMath.neighbor(5, 5, 0)  -- East neighbor
```

**`HexMath.getNeighbors(q, r)`**
- Get all 6 neighbors of a hex
- **Parameters:** q, r (numbers)
- **Returns:** array of {q, r} tables
- **Example:**
```lua
local neighbors = HexMath.getNeighbors(10, 10)
for _, n in ipairs(neighbors) do
    print(n.q, n.r)
end
```

### Distance & Direction

**`HexMath.distance(q1, r1, q2, r2)`**
- Calculate hex distance between two positions
- **Parameters:** q1, r1, q2, r2 (numbers)
- **Returns:** distance (number, in hexes)
- **Example:**
```lua
local dist = HexMath.distance(0, 0, 5, 5)  -- Returns 5
```

**`HexMath.getDirection(q1, r1, q2, r2)`**
- Get direction from hex1 to hex2 (if adjacent)
- **Parameters:** q1, r1, q2, r2 (numbers)
- **Returns:** direction (0-5) or -1 if not adjacent
- **Example:**
```lua
local dir = HexMath.getDirection(5, 5, 6, 5)  -- Returns 0 (East)
```

### Vision & Line of Sight

**`HexMath.isInFrontArc(sourceQ, sourceR, sourceFacing, targetQ, targetR)`**
- Check if target is in 120° front arc
- **Parameters:** source position + facing, target position
- **Returns:** boolean
- **Example:**
```lua
local inArc = HexMath.isInFrontArc(10, 10, 0, 11, 10)  -- true (directly ahead)
```

**`HexMath.hexLine(q1, r1, q2, r2)`**
- Generate line of hexes from start to end (for LOS)
- **Parameters:** q1, r1, q2, r2 (numbers)
- **Returns:** array of {q, r} tables
- **Example:**
```lua
local line = HexMath.hexLine(0, 0, 5, 0)
for i, hex in ipairs(line) do
    print("Hex", i, ":", hex.q, hex.r)
end
```

**`HexMath.hexesInRange(centerQ, centerR, range)`**
- Get all hexes within circular range
- **Parameters:** centerQ, centerR, range (numbers)
- **Returns:** array of {q, r} tables
- **Example:**
```lua
local hexes = HexMath.hexesInRange(10, 10, 3)  -- All hexes within 3 range
```

### Rendering Conversion

**`HexMath.hexToPixel(q, r, hexSize)`**
- Convert hex coordinates to pixel position
- **Parameters:** q, r (numbers), hexSize (pixels, default 24)
- **Returns:** x, y (numbers, pixels)
- **Example:**
```lua
local x, y = HexMath.hexToPixel(10, 10, 24)
```

**`HexMath.pixelToHex(x, y, hexSize)`**
- Convert pixel position to hex coordinates
- **Parameters:** x, y (pixels), hexSize (pixels, default 24)
- **Returns:** q, r (numbers)
- **Example:**
```lua
local q, r = HexMath.pixelToHex(240, 240, 24)
```

### Rotation

**`HexMath.rotationToFace(currentFacing, targetFacing)`**
- Calculate rotation needed to change facing
- **Parameters:** currentFacing, targetFacing (0-5)
- **Returns:** rotation amount (-3 to 3, in 60° steps)
- **Example:**
```lua
local rotations = HexMath.rotationToFace(0, 3)  -- East to West = 3 rotations
```

---

## HexSystem API (`systems/hex_system.lua`)

### Creation

**`HexSystem.new(width, height, hexSize)`**
- Create a new hex grid system
- **Parameters:** 
  - width, height (numbers, in hexes)
  - hexSize (number, pixels per hex, default 24)
- **Returns:** hexSystem table
- **Example:**
```lua
local hexSystem = HexSystem.new(60, 60, 24)
```

### Tile Access

**`HexSystem.getTile(hexSystem, q, r)`**
- Get tile at hex coordinates
- **Parameters:** hexSystem, q, r (numbers)
- **Returns:** tile table or nil
- **Example:**
```lua
local tile = HexSystem.getTile(hexSystem, 10, 10)
if tile then
    print("Terrain:", tile.terrain)
    print("Blocking:", tile.blocking)
end
```

**`HexSystem.getTileOffset(hexSystem, col, row)`**
- Get tile at offset coordinates
- **Parameters:** hexSystem, col, row (numbers)
- **Returns:** tile table or nil

### Validation

**`HexSystem.isValidHex(hexSystem, q, r)`**
- Check if hex coordinates are within grid bounds
- **Parameters:** hexSystem, q, r (numbers)
- **Returns:** boolean
- **Example:**
```lua
if HexSystem.isValidHex(hexSystem, 10, 10) then
    -- Position is valid
end
```

**`HexSystem.isWalkable(hexSystem, q, r)`**
- Check if hex is walkable (not blocking)
- **Parameters:** hexSystem, q, r (numbers)
- **Returns:** boolean
- **Example:**
```lua
if HexSystem.isWalkable(hexSystem, targetQ, targetR) then
    -- Can move to this hex
end
```

**`HexSystem.getValidNeighbors(hexSystem, q, r)`**
- Get all valid neighbors (within bounds)
- **Parameters:** hexSystem, q, r (numbers)
- **Returns:** array of {q, r} tables
- **Example:**
```lua
local neighbors = HexSystem.getValidNeighbors(hexSystem, 10, 10)
```

### Unit Management

**`HexSystem.addUnit(hexSystem, unitId, unit)`**
- Add unit to hex system
- **Parameters:** hexSystem, unitId (string), unit (table)
- **Returns:** None
- **Example:**
```lua
HexSystem.addUnit(hexSystem, "unit_001", unit)
```

**`HexSystem.removeUnit(hexSystem, unitId)`**
- Remove unit from hex system
- **Parameters:** hexSystem, unitId (string)
- **Returns:** None

**`HexSystem.getUnitAt(hexSystem, q, r)`**
- Get unit at hex position
- **Parameters:** hexSystem, q, r (numbers)
- **Returns:** unit (table), unitId (string) or nil
- **Example:**
```lua
local unit, unitId = HexSystem.getUnitAt(hexSystem, 10, 10)
if unit then
    print("Unit found:", unit.name)
end
```

### Coordinate Conversion

**`HexSystem.screenToHex(hexSystem, screenX, screenY)`**
- Convert screen coordinates to hex
- **Parameters:** hexSystem, screenX, screenY (pixels)
- **Returns:** q, r (numbers)

**`HexSystem.hexToScreen(hexSystem, q, r)`**
- Convert hex coordinates to screen
- **Parameters:** hexSystem, q, r (numbers)
- **Returns:** x, y (pixels)

### Rendering

**`HexSystem.drawHexGrid(hexSystem, camera)`**
- Draw hex grid overlay (debug visualization)
- **Parameters:** hexSystem, camera (table with x, y position)
- **Returns:** None
- **Note:** Only draws if `Debug.showHexGrid` is true
- **Toggle:** Press F9 key in game
- **Example:**
```lua
if Debug.showHexGrid then
    HexSystem.drawHexGrid(hexSystem, camera)
end
```

---

## MovementSystem API (`systems/movement_system.lua`)

### Cost Calculation

**`MovementSystem.getMovementCost(hexSystem, fromQ, fromR, toQ, toR)`**
- Calculate AP cost to move between adjacent hexes
- **Parameters:** hexSystem, from/to coordinates
- **Returns:** cost (number, 2 AP) or nil if invalid
- **Example:**
```lua
local cost = MovementSystem.getMovementCost(hexSystem, 5, 5, 6, 5)
if cost then
    print("Move costs", cost, "AP")  -- Prints: Move costs 2 AP
end
```

**`MovementSystem.getRotationCost(currentFacing, targetFacing)`**
- Calculate AP cost to rotate
- **Parameters:** currentFacing, targetFacing (0-5)
- **Returns:** cost (number, 1 AP per 60°)
- **Example:**
```lua
local cost = MovementSystem.getRotationCost(0, 2)  -- East to NW = 2 AP
```

### Unit Movement

**`MovementSystem.tryMove(unit, hexSystem, toQ, toR)`**
- Attempt to move unit to new position
- **Parameters:** unit (table), hexSystem, toQ, toR (numbers)
- **Returns:** success (boolean)
- **Side Effects:** Spends AP, updates position if successful
- **Example:**
```lua
local moved = MovementSystem.tryMove(unit, hexSystem, 10, 10)
if moved then
    print("Unit moved successfully")
    print("AP remaining:", unit.movement.currentAP)
else
    print("Move failed (insufficient AP or blocked)")
end
```

**`MovementSystem.tryRotate(unit, targetFacing)`**
- Attempt to rotate unit
- **Parameters:** unit (table), targetFacing (0-5)
- **Returns:** success (boolean)
- **Side Effects:** Spends AP, updates facing if successful
- **Example:**
```lua
local rotated = MovementSystem.tryRotate(unit, 3)  -- Face west
if rotated then
    print("Unit rotated")
end
```

### Pathfinding

**`MovementSystem.findPath(hexSystem, startQ, startR, endQ, endR)`**
- Find shortest path using A* algorithm
- **Parameters:** hexSystem, start/end coordinates
- **Returns:** path (array of {q, r}) or nil if no path
- **Example:**
```lua
local path = MovementSystem.findPath(hexSystem, 0, 0, 10, 10)
if path then
    print("Path found with", #path, "steps")
    for i, step in ipairs(path) do
        print("Step", i, ":", step.q, step.r)
    end
end
```

### Turn Management

**`MovementSystem.resetAllAP(units)`**
- Reset AP for all units (new turn)
- **Parameters:** units (table/array of units)
- **Returns:** None
- **Example:**
```lua
MovementSystem.resetAllAP(teamUnits)
```

---

## VisionSystem API (`systems/vision_system.lua`)

### Line of Sight

**`VisionSystem.hasLineOfSight(hexSystem, fromQ, fromR, toQ, toR)`**
- Check if there's clear LOS between two hexes
- **Parameters:** hexSystem, from/to coordinates
- **Returns:** boolean
- **Example:**
```lua
local hasLOS = VisionSystem.hasLineOfSight(hexSystem, 5, 5, 10, 10)
if hasLOS then
    print("Clear line of sight")
end
```

### Vision Updates

**`VisionSystem.updateUnitVision(unit, hexSystem)`**
- Calculate and cache visible tiles/units for one unit
- **Parameters:** unit (with transform + vision), hexSystem
- **Returns:** None
- **Side Effects:** Updates unit.vision.visibleTiles and canSeeUnits
- **Example:**
```lua
VisionSystem.updateUnitVision(unit, hexSystem)
-- Now unit.vision contains updated visibility data
local canSee = unit.vision:canSeeTile(10, 10)
```

**`VisionSystem.updateTeamVision(units, hexSystem)`**
- Update vision for all units in a team
- **Parameters:** units (array/table), hexSystem
- **Returns:** None
- **Example:**
```lua
VisionSystem.updateTeamVision(playerTeam.units, hexSystem)
```

### Team Visibility

**`VisionSystem.getTeamVisibleTiles(units)`**
- Get all tiles visible to any unit in team
- **Parameters:** units (array/table)
- **Returns:** table of {q_r = true} visible hexes
- **Example:**
```lua
local visible = VisionSystem.getTeamVisibleTiles(teamUnits)
for tileKey, _ in pairs(visible) do
    print("Visible:", tileKey)
end
```

### Debug Rendering

**`VisionSystem.drawVisionCones(units, hexSystem, camera)`**
- Draw vision cones and visible tiles (debug)
- **Parameters:** units (array), hexSystem, camera
- **Returns:** None
- **Note:** Only draws if `Debug.showVisionCones` is true
- **Example:**
```lua
if Debug.showVisionCones then
    VisionSystem.drawVisionCones(units, hexSystem, camera)
end
```

---

## UnitEntity API (`entities/unit_entity.lua`)

### Creation

**`UnitEntity.new(params)`**
- Create a new unit with all components
- **Parameters:** params (table) with fields:
  - `q`, `r` (numbers) - Hex position
  - `facing` (0-5) - Direction facing
  - `teamId` (number) - Team identifier
  - `teamName` (string, optional) - Team display name
  - `maxHP`, `armor` (numbers) - Health stats
  - `maxAP`, `moveCost`, `turnCost` (numbers) - Movement stats
  - `visionRange`, `visionArc` (numbers) - Vision stats
  - `name` (string, optional) - Unit name
  - `id` (string, optional) - Unit ID
- **Returns:** unit (table with all components)
- **Example:**
```lua
local unit = UnitEntity.new({
    q = 10, r = 10,
    facing = 0,  -- East
    teamId = 1,  -- Player
    maxHP = 100,
    armor = 10,
    maxAP = 10,
    visionRange = 8,
    name = "Soldier Alpha"
})

-- Access components
print("Position:", unit.transform.q, unit.transform.r)
print("HP:", unit.health.currentHP, "/", unit.health.maxHP)
print("AP:", unit.movement.currentAP, "/", unit.movement.maxAP)
```

### Component Access

All units have the following components:
- `unit.transform` - Position and facing
- `unit.movement` - AP and movement data
- `unit.vision` - Vision range and visible tiles
- `unit.health` - HP, armor, damage history
- `unit.team` - Team affiliation

### Utility Functions

**`UnitEntity.isActive(unit)`**
- Check if unit is alive and active
- **Parameters:** unit
- **Returns:** boolean
- **Example:**
```lua
if UnitEntity.isActive(unit) then
    -- Unit can still act
end
```

**`UnitEntity.getDisplayName(unit)`**
- Get unit name with HP percentage
- **Parameters:** unit
- **Returns:** string (e.g., "Soldier [75%]")
- **Example:**
```lua
local name = UnitEntity.getDisplayName(unit)
print(name)  -- "Soldier Alpha [85%]"
```

**`UnitEntity.getColor(unit)`**
- Get unit's team color
- **Parameters:** unit
- **Returns:** {r, g, b} table
- **Example:**
```lua
local color = UnitEntity.getColor(unit)
love.graphics.setColor(color.r/255, color.g/255, color.b/255)
```

### Serialization

**`UnitEntity.serialize(unit)`**
- Convert unit to saveable data
- **Parameters:** unit
- **Returns:** table with core data
- **Example:**
```lua
local data = UnitEntity.serialize(unit)
-- Save data to file
```

**`UnitEntity.deserialize(data)`**
- Restore unit from saved data
- **Parameters:** data (table)
- **Returns:** unit
- **Example:**
```lua
local unit = UnitEntity.deserialize(savedData)
```

---

## Debug API (`utils/debug.lua`)

### Debug Flags

- `Debug.enabled` - Master debug switch
- `Debug.showHexGrid` - Show hex grid overlay (F9)
- `Debug.showFOW` - Show fog of war (F8)
- `Debug.showVisionCones` - Show vision cones
- `Debug.showPaths` - Show pathfinding paths
- `Debug.logVerbose` - Verbose logging

### Toggle Functions

**`Debug.toggle()`**
- Toggle master debug mode
- **Shortcut:** F10 key
- **Example:**
```lua
Debug.toggle()  -- Enables/disables all debug features
```

**`Debug.toggleHexGrid()`**
- Toggle hex grid overlay
- **Shortcut:** F9 key
- **Example:**
```lua
Debug.toggleHexGrid()
```

**`Debug.toggleFOW()`**
- Toggle fog of war display
- **Shortcut:** F8 key
- **Example:**
```lua
Debug.toggleFOW()
```

### Logging

**`Debug.print(module, message)`**
- Print with module prefix
- **Parameters:** module (string), message (string)
- **Example:**
```lua
Debug.print("HexSystem", "Grid initialized")
-- Output: [HexSystem] Grid initialized
```

**`Debug.error(module, message)`**
- Log error with stack trace
- **Parameters:** module (string), message (string)

**`Debug.warn(module, message)`**
- Log warning
- **Parameters:** module (string), message (string)

**`Debug.log(module, message)`**
- Verbose logging (only if logVerbose enabled)
- **Parameters:** module (string), message (string)

---

## Integration Examples

### Basic Setup

```lua
-- In battlescape.lua enter() function
local HexSystem = require("systems.battle.systems.hex_system")
local MovementSystem = require("systems.battle.systems.movement_system")
local VisionSystem = require("systems.battle.systems.vision_system")
local UnitEntity = require("systems.battle.entities.unit_entity")
local Debug = require("systems.battle.utils.debug")

function Battlescape:enter()
    -- Initialize hex system
    self.hexSystem = HexSystem.new(60, 60, 24)
    
    -- Enable debug
    Debug.enabled = true
    Debug.showHexGrid = false
    
    -- Create units
    self.units = {}
    local unit = UnitEntity.new({
        q = 10, r = 10,
        facing = 0,
        teamId = 1,
        maxHP = 100,
        maxAP = 10
    })
    HexSystem.addUnit(self.hexSystem, "unit1", unit)
    table.insert(self.units, unit)
end
```

### Handling Unit Movement

```lua
function Battlescape:handleUnitClick(unit, targetQ, targetR)
    -- Find path
    local path = MovementSystem.findPath(
        self.hexSystem,
        unit.transform.q, unit.transform.r,
        targetQ, targetR
    )
    
    if path then
        -- Try to move along path
        for i = 2, #path do  -- Skip first (current position)
            local step = path[i]
            local moved = MovementSystem.tryMove(unit, self.hexSystem, step.q, step.r)
            if not moved then
                print("Movement stopped at step", i)
                break
            end
        end
        
        -- Update vision after movement
        VisionSystem.updateUnitVision(unit, self.hexSystem)
    end
end
```

### Rendering with Debug Overlays

```lua
function Battlescape:draw()
    -- Draw battlefield
    self.renderer:draw(self.battlefield, self.camera, ...)
    
    -- Draw hex grid overlay (F9 toggle)
    if Debug.showHexGrid then
        HexSystem.drawHexGrid(self.hexSystem, self.camera)
    end
    
    -- Draw vision cones (debug)
    if Debug.showVisionCones then
        VisionSystem.drawVisionCones(self.units, self.hexSystem, self.camera)
    end
end
```

### Key Handler Setup

```lua
function Battlescape:keypressed(key)
    -- F8: Toggle FOW
    if key == "f8" then
        Debug.toggleFOW()
        print("FOW:", Debug.showFOW and "ON" or "OFF")
        return
    end
    
    -- F9: Toggle hex grid
    if key == "f9" then
        Debug.toggleHexGrid()
        print("Hex Grid:", Debug.showHexGrid and "ON" or "OFF")
        return
    end
    
    -- F10: Toggle debug mode
    if key == "f10" then
        Debug.toggle()
        return
    end
end
```

---

## Performance Considerations

### Efficient Operations

**Fast (O(1)):**
- Hex coordinate conversion
- Distance calculation
- Neighbor lookup
- Tile access by coordinates

**Medium (O(n)):**
- Vision updates (n = hexes in range)
- LOS checks (n = distance)
- Valid neighbor filtering

**Slower (O(n log n)):**
- A* pathfinding (n = hexes searched)

### Optimization Tips

1. **Cache Vision:** Only update when units move
2. **Limit Range:** Keep vision range reasonable (8 hexes default)
3. **Cull Rendering:** Only draw visible hexes
4. **Batch Updates:** Update all team vision together
5. **Lazy Evaluation:** Calculate paths only when needed

---

## Debug Controls Reference

| Key | Action | Description |
|-----|--------|-------------|
| F8 | Toggle FOW | Show/hide fog of war overlay |
| F9 | Toggle Hex Grid | Show/hide green hex grid overlay |
| F10 | Toggle Debug | Enable/disable all debug features |

When debug mode is active:
- Console shows [Module] prefixed log messages
- Performance stats displayed on screen
- Green hex outlines visible (if F9 on)
- Vision cones can be visualized

---

## Common Patterns

### Creating a Unit

```lua
local unit = UnitEntity.new({
    q = 10, r = 10,
    facing = 0,
    teamId = 1,
    maxHP = 100,
    armor = 10,
    maxAP = 10,
    visionRange = 8,
    name = "Soldier"
})
HexSystem.addUnit(hexSystem, unit.id, unit)
```

### Moving a Unit

```lua
if MovementSystem.tryMove(unit, hexSystem, targetQ, targetR) then
    VisionSystem.updateUnitVision(unit, hexSystem)
    print("Moved to", targetQ, targetR)
end
```

### Checking Vision

```lua
VisionSystem.updateUnitVision(unit, hexSystem)
if unit.vision:canSeeTile(targetQ, targetR) then
    print("Can see target hex")
end
```

### Finding a Path

```lua
local path = MovementSystem.findPath(hexSystem, startQ, startR, endQ, endR)
if path then
    for i, step in ipairs(path) do
        print("Step", i, ":", step.q, step.r)
    end
end
```

### New Turn

```lua
MovementSystem.resetAllAP(allUnits)
VisionSystem.updateTeamVision(activeTeamUnits, hexSystem)
```

---

## See Also

- `DEVELOPMENT.md` - Development workflow and guidelines
- `FAQ.md` - Frequently asked questions
- `tasks/TODO/BATTLE-SYSTEM-COMPLETE.md` - Implementation details
- Source code: `engine/systems/battle/`
