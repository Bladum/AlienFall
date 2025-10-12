# TASK-001: Battle System Improvements - Hex Grid, FOW, and Enhanced Mechanics

**Status:** TODO  
**Priority:** High  
**Created:** 2025-10-11  
**Estimated Time:** 20-30 hours  

---

## Overview and Purpose

Major overhaul of the battle system to implement:
1. **Hexagonal grid system** (visual rect, logical hex)
2. **Enhanced Fog of War** with proper rendering and F8 toggle
3. **Minimap improvements** with FOW and click fixes
4. **Unit facing indicators** with directional vision cones
5. **Debug tools** (F9 grid, F8 FOW toggle)
6. **Comprehensive test suite** for all battle logic

This will transform the current rectangular grid into a hex-based tactical system while maintaining visual compatibility.

---

## Requirements

### Functional Requirements

#### FR-1: Minimap Fixes
- [ ] Fix minimap click calculation (ensure camera position is correct)
- [ ] Display only terrain and units visible to current player
- [ ] Show fog of war on minimap for current player's team
- [ ] Verify minimap viewport rectangle matches actual camera view

#### FR-2: Fog of War System
- [ ] F8 key toggles FOW on/off for debugging
- [ ] FOW calculated based on all units' sight/sense ranges for all teams
- [ ] Only current team's FOW state is displayed
- [ ] FOW rendered OVER terrain and units (semi-transparent overlay)
- [ ] Three states: hidden (black), explored (dark), visible (full brightness)

#### FR-3: Unit Facing and Vision
- [ ] Each unit has facing direction (0-5 for hex, 0-7 currently)
- [ ] Small rectangle/arrow drawn showing unit's facing direction
- [ ] Vision cone: 120° from unit facing (3 hex tiles in front)
- [ ] Line of sight calculated from unit face direction

#### FR-4: Hexagonal Grid System
- [ ] Convert map from rectangular to hexagonal logic
- [ ] Keep rectangular graphics but shift alternating columns 50% up
- [ ] Hex neighbors: 6 adjacent tiles (NE, E, SE, SW, W, NW)
- [ ] Movement: 1 tile = 2 MP, rotation 60° = 1 MP
- [ ] Terrain costs: tough terrain 3-6 MP
- [ ] Unit faces move direction when moving
- [ ] LOS recalculated every step during movement

#### FR-5: Debug Tools
- [ ] F9: Toggle grid overlay (show hex boundaries)
- [ ] F8: Toggle fog of war rendering
- [ ] Console output for debug events

### Technical Requirements

#### TR-1: Hex Coordinate System
- Implement cube coordinates for hex grid (q, r, s where q+r+s=0)
- Conversion functions: pixel ↔ cube ↔ offset (even-q vertical layout)
- Neighbor calculation for 6 directions
- Distance calculation using cube coordinates

#### TR-2: Pathfinding for Hex Grid
- Update A* pathfinding to use hex neighbors
- Movement cost calculation per hex terrain
- Path validation and smoothing

#### TR-3: Line of Sight for Hex Grid
- Bresenham-style algorithm adapted for hex grid
- Vision cone calculation (120° from facing)
- Sight cost accumulation through tiles
- FOW state updates based on LOS results

#### TR-4: Rendering Pipeline
- Layer order: Terrain → FOW (explored) → Units → FOW (hidden) → Selection → Grid
- Camera-aware culling for performance
- Minimap rendering with FOW
- Unit facing indicator graphics

### Acceptance Criteria

1. **Hex Grid**: Units move on hex grid with proper neighbor detection
2. **Movement**: Moving 1 hex costs 2 MP, rotating costs 1 MP
3. **Vision**: Units see 120° cone from facing direction
4. **FOW**: Three-state FOW (hidden/explored/visible) renders correctly
5. **Minimap**: Clicking minimap centers camera on correct position
6. **Minimap FOW**: Minimap shows only what current player can see
7. **Debug**: F9 shows hex grid overlay, F8 toggles FOW
8. **Facing**: Unit facing direction visible as small arrow
9. **Tests**: All battle logic has test coverage >80%

---

## Detailed Implementation Plan

### Phase 0: Refactoring and ECS Setup (4-6 hours)

#### Step 0.1: Create Component Architecture
**Files:** `engine/systems/battle/components/*.lua`

Create pure data components:

**transform.lua**
```lua
--- Transform Component
-- Stores position and orientation data
-- @module components.transform

local Transform = {}

--- Create new transform component
-- @param x number X coordinate (tile position)
-- @param y number Y coordinate (tile position)
-- @param facing number Facing direction (0-5 for hex)
-- @return table Transform component
function Transform.new(x, y, facing)
    return {
        x = x or 0,
        y = y or 0,
        facing = facing or 0,
        hexCache = nil  -- Cached hex coordinates for performance
    }
end

return Transform
```

**movement.lua**
```lua
--- Movement Component
-- Stores movement-related data
-- @module components.movement

local Movement = {}

function Movement.new(maxMP, speed)
    return {
        maxMovementPoints = maxMP or 24,
        currentMovementPoints = maxMP or 24,
        speed = speed or 1.0,
        terrainModifiers = {
            floor = 0,
            rough = 1,
            water = 4,
            -- etc.
        }
    }
end

return Movement
```

**vision.lua**, **health.lua**, **team.lua** - Similar structure

**Time:** 2 hours  
**Test:** Load components and verify structure

#### Step 0.2: Create System Architecture
**Files:** `engine/systems/battle/systems/*.lua`

**hex_system.lua** - Delegates to pure hex_math
```lua
--- Hex System
-- Coordinates hex grid operations
-- @module systems.hex_system

local HexSystem = {}
local HexMath = require("systems.battle.utils.hex_math")

function HexSystem.new()
    local self = setmetatable({}, {__index = HexSystem})
    return self
end

--- Convert world tile to hex coordinates
function HexSystem:toHex(x, y)
    return HexMath.offsetToCube(x, y)
end

--- Get all 6 hex neighbors
function HexSystem:getNeighbors(x, y)
    local hex = self:toHex(x, y)
    local neighbors = HexMath.neighbors(hex)
    
    local result = {}
    for _, neighborHex in ipairs(neighbors) do
        local nx, ny = HexMath.cubeToOffset(neighborHex)
        table.insert(result, {x = nx, y = ny})
    end
    
    return result
end

--- Calculate hex distance
function HexSystem:distance(x1, y1, x2, y2)
    local a = self:toHex(x1, y1)
    local b = self:toHex(x2, y2)
    return HexMath.distance(a, b)
end

return HexSystem
```

**vision_system.lua**, **movement_system.lua**, **render_system.lua** - System logic

**Time:** 2 hours  
**Test:** Create systems and verify basic operations

#### Step 0.3: Create Entity Definitions
**Files:** `engine/systems/battle/entities/*.lua`

**unit_entity.lua**
```lua
--- Unit Entity
-- Composite entity with components
-- @module entities.unit_entity

local Transform = require("systems.battle.components.transform")
local Movement = require("systems.battle.components.movement")
local Vision = require("systems.battle.components.vision")
local Health = require("systems.battle.components.health")
local TeamComp = require("systems.battle.components.team")

local UnitEntity = {}
UnitEntity.__index = UnitEntity
UnitEntity._idCounter = 0

--- Create new unit entity
-- @param unitType string Type of unit ("soldier", "sectoid", etc.)
-- @param teamId string Team identifier
-- @param x number Starting X position
-- @param y number Starting Y position
-- @return UnitEntity New unit instance
function UnitEntity.new(unitType, teamId, x, y)
    local self = setmetatable({}, UnitEntity)
    
    -- Generate unique ID
    UnitEntity._idCounter = UnitEntity._idCounter + 1
    self.id = UnitEntity._idCounter
    
    -- Metadata
    self.name = unitType .. "_" .. self.id
    self.type = unitType
    self.alive = true
    
    -- Components (composition not inheritance)
    self.transform = Transform.new(x, y, 0)
    self.movement = Movement.new(24, 1.0)
    self.vision = Vision.new(10, 120)
    self.health = Health.new(100, 100)
    self.team = TeamComp.new(teamId)
    
    -- Visual
    self.sprite = nil  -- Set by asset loader
    
    return self
end

--- Get unit position
-- @return number, number X and Y coordinates
function UnitEntity:getPosition()
    return self.transform.x, self.transform.y
end

--- Get unit facing
-- @return number Facing direction (0-5)
function UnitEntity:getFacing()
    return self.transform.facing
end

--- Set unit facing
-- @param facing number New facing direction
function UnitEntity:setFacing(facing)
    self.transform.facing = facing % 6
end

--- Check if unit can move
-- @return boolean True if unit has movement points
function UnitEntity:canMove()
    return self.movement.currentMovementPoints > 0
end

--- Refresh unit for new turn
function UnitEntity:refresh()
    self.movement.currentMovementPoints = self.movement.maxMovementPoints
end

return UnitEntity
```

**Time:** 2 hours  
**Test:** Create unit entities and verify component access

---

### Phase 1: Hex Coordinate System (4-6 hours)

#### Step 1.1: Create Hex Math Module (Pure Functions)
**File:** `engine/systems/battle/utils/hex_math.lua`

```lua
--- Hex Math Utilities
-- Pure functional hex coordinate system
-- Uses "even-q" vertical layout with cube coordinates
-- All functions are stateless and side-effect free
-- @module utils.hex_math

local HexMath = {}

--- Hex directions (cube coordinates)
HexMath.DIRECTIONS = {
    E  = {q = 1, r = 0},   -- East
    NE = {q = 1, r = -1},  -- Northeast
    NW = {q = 0, r = -1},  -- Northwest
    W  = {q = -1, r = 0},  -- West
    SW = {q = -1, r = 1},  -- Southwest
    SE = {q = 0, r = 1}    -- Southeast
}

--- Create cube coordinate
-- @param q number Q coordinate
-- @param r number R coordinate
-- @return table Hex in cube coordinates {q, r, s}
function HexMath.cube(q, r)
    return {q = q, r = r, s = -q - r}
end

--- Convert offset (column, row) to cube coordinates
-- Even-q vertical layout: even columns offset down
-- @param col number Column (X coordinate)
-- @param row number Row (Y coordinate)
-- @return table Hex in cube coordinates
function HexMath.offsetToCube(col, row)
    local q = col
    local r = row - math.floor((col + (col % 2)) / 2)
    return HexMath.cube(q, r)
end

--- Convert cube coordinates to offset (column, row)
-- @param hex table Hex in cube coordinates {q, r, s}
-- @return number, number Column and row
function HexMath.cubeToOffset(hex)
    local col = hex.q
    local row = hex.r + math.floor((hex.q + (hex.q % 2)) / 2)
    return col, row
end

--- Get all 6 hex neighbors in cube coordinates
-- @param hex table Hex in cube coordinates
-- @return table Array of 6 neighbor hexes
function HexMath.neighbors(hex)
    local result = {}
    for _, dir in pairs(HexMath.DIRECTIONS) do
        table.insert(result, HexMath.cube(hex.q + dir.q, hex.r + dir.r))
    end
    return result
end

--- Get neighbor in specific direction
-- @param hex table Hex in cube coordinates
-- @param direction number Direction index (0-5)
-- @return table Neighbor hex in cube coordinates
function HexMath.neighbor(hex, direction)
    local dirs = {
        HexMath.DIRECTIONS.E,
        HexMath.DIRECTIONS.NE,
        HexMath.DIRECTIONS.NW,
        HexMath.DIRECTIONS.W,
        HexMath.DIRECTIONS.SW,
        HexMath.DIRECTIONS.SE
    }
    local dir = dirs[(direction % 6) + 1]
    return HexMath.cube(hex.q + dir.q, hex.r + dir.r)
end

--- Calculate distance between two hexes (cube coordinates)
-- @param a table First hex
-- @param b table Second hex
-- @return number Distance in hex tiles
function HexMath.distance(a, b)
    return (math.abs(a.q - b.q) + math.abs(a.r - b.r) + math.abs(a.s - b.s)) / 2
end

--- Convert hex to pixel coordinates for rendering
-- Even-q vertical layout with pointy-top hexes
-- @param hex table Hex in cube coordinates
-- @param size number Tile size (radius of hex)
-- @return number, number Pixel X and Y
function HexMath.hexToPixel(hex, size)
    local col, row = HexMath.cubeToOffset(hex)
    local x = size * math.sqrt(3) * (col + 0.5 * (row % 2))
    local y = size * 3/2 * row
    return x, y
end

--- Convert pixel coordinates to hex
-- @param x number Pixel X
-- @param y number Pixel Y
-- @param size number Tile size
-- @return table Hex in cube coordinates
function HexMath.pixelToHex(x, y, size)
    -- Fractional cube coordinates
    local q = (x * math.sqrt(3)/3 - y / 3) / size
    local r = y * 2/3 / size
    return HexMath.cubeRound(q, r)
end

--- Round fractional cube coordinates to nearest hex
-- @param q number Fractional Q
-- @param r number Fractional R
-- @return table Rounded hex in cube coordinates
function HexMath.cubeRound(q, r)
    local s = -q - r
    
    local rq = math.floor(q + 0.5)
    local rr = math.floor(r + 0.5)
    local rs = math.floor(s + 0.5)
    
    local q_diff = math.abs(rq - q)
    local r_diff = math.abs(rr - r)
    local s_diff = math.abs(rs - s)
    
    if q_diff > r_diff and q_diff > s_diff then
        rq = -rr - rs
    elseif r_diff > s_diff then
        rr = -rq - rs
    else
        rs = -rq - rr
    end
    
    return {q = rq, r = rr, s = rs}
end

--- Get hex line from A to B (for line of sight)
-- @param a table Start hex
-- @param b table End hex
-- @return table Array of hexes from A to B
function HexMath.line(a, b)
    local distance = HexMath.distance(a, b)
    local results = {}
    
    for i = 0, distance do
        local t = i / distance
        local q = a.q + (b.q - a.q) * t
        local r = a.r + (b.r - a.r) * t
        table.insert(results, HexMath.cubeRound(q, r))
    end
    
    return results
end

--- Get all hexes within range of a center hex
-- @param center table Center hex
-- @param range number Maximum distance
-- @return table Array of hexes within range
function HexMath.hexesInRange(center, range)
    local results = {}
    
    for q = -range, range do
        for r = math.max(-range, -q - range), math.min(range, -q + range) do
            local hex = HexMath.cube(center.q + q, center.r + r)
            table.insert(results, hex)
        end
    end
    
    return results
end

return HexMath
```

**Time:** 3 hours  
**Test:** Create `tests/test_hex_math.lua` with comprehensive tests

#### Step 1.2: Update Battlefield for Hex Grid
**File:** `engine/systems/battle/battlefield.lua`

- Add `self.hexGrid = true` flag
- Store tiles with hex coordinates
- Update `getTile()` to accept hex coordinates
- Update `getNeighbors()` to return 6 hex neighbors

**Time:** 2 hours  
**Test:** Verify neighbor calculation returns 6 tiles

#### Step 1.3: Update Pathfinding for Hex
**File:** `engine/systems/pathfinding.lua`

- Modify A* to use hex neighbors
- Update distance heuristic to use hex distance
- Movement cost: base 2 MP per hex + terrain modifier

**Time:** 2 hours  
**Test:** Test pathfinding across hex grid

---

### Phase 2: Hex Rendering (3-4 hours)

#### Step 2.1: Update Renderer for Hex Layout
**File:** `engine/systems/battle/renderer.lua`

- Modify tile drawing to offset even columns up by 50%
- Update screen coordinate calculation
- Add hex grid overlay drawing (for F9 debug)

```lua
function BattlefieldRenderer:drawHexGrid(battlefield, camera)
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    for y = 1, battlefield.height do
        for x = 1, battlefield.width do
            local hex = Hex.offsetToCube(x, y)
            local px, py = Hex.hexToPixel(hex, self.tileSize)
            local screenX = px * camera.zoom + camera.x
            local screenY = py * camera.zoom + camera.y
            
            -- Draw hex outline (6 sides)
            self:drawHexOutline(screenX, screenY, self.tileSize, camera.zoom)
        end
    end
end

function BattlefieldRenderer:drawHexOutline(cx, cy, size, zoom)
    local points = {}
    for i = 0, 5 do
        local angle = 60 * i * math.pi / 180
        local x = cx + size * zoom * math.cos(angle)
        local y = cy + size * zoom * math.sin(angle)
        table.insert(points, x)
        table.insert(points, y)
    end
    table.insert(points, points[1])  -- Close the hex
    table.insert(points, points[2])
    love.graphics.line(points)
end
```

**Time:** 2 hours  
**Test:** Visual verification of hex grid overlay

#### Step 2.2: Add F9 Grid Toggle
**File:** `engine/modules/battlescape.lua`

- Add `keypressed` handler for F9
- Toggle `self.renderer.showHexGrid` flag
- Draw hex grid overlay when enabled

**Time:** 1 hour  
**Test:** Press F9 and verify grid appears/disappears

---

### Phase 3: Unit Facing and Vision Cone (4-5 hours)

#### Step 3.1: Add Facing to Units
**File:** `engine/systems/unit.lua`

- Add `self.facing = 0` (0-5 for hex directions: E, NE, NW, W, SW, SE)
- Update rotation to cost 1 MP per 60° turn
- Add `getFacingDirection()` method

**Time:** 1 hour  
**Test:** Rotate unit and verify facing updates

#### Step 3.2: Draw Facing Indicator
**File:** `engine/systems/battle/renderer.lua`

```lua
function BattlefieldRenderer:drawUnitFacingIndicator(unit, camera)
    local centerX = ((unit.x - 1) * self.tileSize) * camera.zoom + camera.x
    local centerY = ((unit.y - 1) * self.tileSize) * camera.zoom + camera.y
    
    -- Facing direction (60° per step)
    local angle = unit.facing * 60 * math.pi / 180
    local length = self.tileSize * 0.6 * camera.zoom
    
    love.graphics.setColor(1, 1, 0, 0.9)
    love.graphics.setLineWidth(2)
    
    -- Draw arrow
    local endX = centerX + length * math.cos(angle)
    local endY = centerY + length * math.sin(angle)
    love.graphics.line(centerX, centerY, endX, endY)
    
    -- Arrow head
    local arrowSize = 4 * camera.zoom
    local leftAngle = angle + 2.5
    local rightAngle = angle - 2.5
    love.graphics.line(endX, endY, 
        endX - arrowSize * math.cos(leftAngle), 
        endY - arrowSize * math.sin(leftAngle))
    love.graphics.line(endX, endY,
        endX - arrowSize * math.cos(rightAngle),
        endY - arrowSize * math.sin(rightAngle))
    
    love.graphics.setLineWidth(1)
end
```

**Time:** 2 hours  
**Test:** Visual verification of facing arrows

#### Step 3.3: Implement 120° Vision Cone
**File:** `engine/systems/los_system.lua`

```lua
function LOS:calculateHexVisionCone(battlefield, unit, maxRange)
    local visibleTiles = {}
    local centerHex = Hex.offsetToCube(unit.x, unit.y)
    
    -- 120° cone = 3 directions from facing
    -- Facing 0 (E) sees: E, NE, SE
    -- Facing 1 (NE) sees: NE, NW, E
    -- etc.
    local facingDirs = {
        [0] = {0, 1, 5},  -- E: E, NE, SE
        [1] = {1, 2, 0},  -- NE: NE, NW, E
        [2] = {2, 3, 1},  -- NW: NW, W, NE
        [3] = {3, 4, 2},  -- W: W, SW, NW
        [4] = {4, 5, 3},  -- SW: SW, SE, W
        [5] = {5, 0, 4}   -- SE: SE, E, SW
    }
    
    local directions = facingDirs[unit.facing]
    
    -- Check each hex in vision cone
    for _, dirIndex in ipairs(directions) do
        for range = 1, maxRange do
            -- Calculate hex in direction
            local targetHex = self:getHexInDirection(centerHex, dirIndex, range)
            local col, row = Hex.cubeToOffset(targetHex)
            
            -- Check LOS
            if self:hasHexLOS(battlefield, unit.x, unit.y, col, row) then
                table.insert(visibleTiles, {x = col, y = row})
            end
        end
    end
    
    return visibleTiles
end
```

**Time:** 2 hours  
**Test:** Verify unit sees only 120° cone in facing direction

---

### Phase 4: Fog of War Improvements (4-5 hours)

#### Step 4.1: Add FOW Toggle (F8)
**File:** `engine/modules/battlescape.lua`

```lua
function Battlescape:enter()
    -- ... existing code ...
    self.debugFOWDisabled = false  -- F8 toggle
end

function Battlescape:keypressed(key, scancode, isrepeat)
    -- ... existing handlers ...
    
    if key == "f8" then
        self.debugFOWDisabled = not self.debugFOWDisabled
        print(string.format("[Battlescape] FOW debug mode: %s", 
            self.debugFOWDisabled and "DISABLED" or "ENABLED"))
        return
    end
    
    if key == "f9" then
        self.renderer:toggleHexGrid()
        return
    end
end
```

**Time:** 1 hour  
**Test:** Press F8 and verify FOW toggles on/off

#### Step 4.2: Render FOW Overlay Properly
**File:** `engine/modules/battlescape.lua`

```lua
function Battlescape:drawFogOfWar(team)
    if self.debugFOWDisabled then
        return  -- Skip FOW when debugging
    end
    
    -- Draw FOW OVER everything else
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local visibility = team:getVisibility(x, y)
            local screenX = ((x - 1) * TILE_SIZE) * self.camera.zoom + self.camera.x
            local screenY = ((y - 1) * TILE_SIZE) * self.camera.zoom + self.camera.y
            
            if visibility == "hidden" then
                -- Completely black
                love.graphics.setColor(0, 0, 0, 1.0)
                love.graphics.rectangle("fill", screenX, screenY, 
                    TILE_SIZE * self.camera.zoom, TILE_SIZE * self.camera.zoom)
            elseif visibility == "explored" then
                -- Dark overlay (50% opacity)
                love.graphics.setColor(0, 0, 0, 0.5)
                love.graphics.rectangle("fill", screenX, screenY,
                    TILE_SIZE * self.camera.zoom, TILE_SIZE * self.camera.zoom)
            end
            -- "visible" tiles: no overlay
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)  -- Reset
end
```

**Time:** 2 hours  
**Test:** Verify FOW renders over terrain/units, F8 disables it

#### Step 4.3: Update FOW Calculation
**File:** `engine/systems/team.lua`

- Ensure FOW updated for all teams each turn
- Only current team's FOW displayed
- Explored tiles remain explored even when not visible

**Time:** 1-2 hours  
**Test:** Verify FOW states update correctly per team

---

### Phase 5: Minimap Improvements (3-4 hours)

#### Step 5.1: Fix Minimap Click Calculation
**File:** `engine/modules/battlescape.lua`

Current issue: Camera positioning may be inverted or scaled incorrectly.

```lua
function Battlescape:handleMinimapClick(x, y)
    -- Convert minimap pixel to relative position [0-1]
    local relX = (x - self.minimapContentX) / self.minimapContentWidth
    local relY = (y - self.minimapContentY) / self.minimapContentHeight
    
    -- Convert to world tile coordinates
    local tileX = math.floor(relX * MAP_WIDTH) + 1
    local tileY = math.floor(relY * MAP_HEIGHT) + 1
    
    -- Clamp to valid range
    tileX = math.max(1, math.min(MAP_WIDTH, tileX))
    tileY = math.max(1, math.min(MAP_HEIGHT, tileY))
    
    -- Center camera on tile
    local viewportW = (960 - GUI_WIDTH) / TILE_SIZE
    local viewportH = 720 / TILE_SIZE
    
    self.camera.x = -((tileX - viewportW / 2) * TILE_SIZE)
    self.camera.y = -((tileY - viewportH / 2) * TILE_SIZE)
    
    print(string.format("[Minimap] Clicked tile (%d, %d), camera: (%.1f, %.1f)", 
        tileX, tileY, self.camera.x, self.camera.y))
end
```

**Time:** 2 hours  
**Test:** Click minimap and verify camera centers correctly

#### Step 5.2: Add FOW to Minimap
**File:** `engine/modules/battlescape.lua`

```lua
function Battlescape:drawMinimap()
    local contentX = self.minimapContentX
    local contentY = self.minimapContentY
    local contentW = self.minimapContentWidth
    local contentH = self.minimapContentHeight
    
    local scaleX = contentW / (MAP_WIDTH * TILE_SIZE)
    local scaleY = contentH / (MAP_HEIGHT * TILE_SIZE)
    
    local activeTeam = self.turnManager:getCurrentTeam()
    
    -- Draw terrain with FOW
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local visibility = activeTeam:getVisibility(x, y)
            local mx = contentX + (x - 1) * TILE_SIZE * scaleX
            local my = contentY + (y - 1) * TILE_SIZE * scaleY
            
            if visibility == "visible" then
                love.graphics.setColor(0.3, 0.3, 0.3, 1)  -- Visible terrain
            elseif visibility == "explored" then
                love.graphics.setColor(0.15, 0.15, 0.15, 1)  -- Explored (darker)
            else
                love.graphics.setColor(0, 0, 0, 1)  -- Hidden (black)
            end
            
            love.graphics.rectangle("fill", mx, my, 
                TILE_SIZE * scaleX, TILE_SIZE * scaleY)
        end
    end
    
    -- Draw only visible units
    for _, unit in pairs(self.units) do
        if activeTeam:getVisibility(unit.x, unit.y) == "visible" then
            local mx = contentX + (unit.x - 1) * TILE_SIZE * scaleX
            local my = contentY + (unit.y - 1) * TILE_SIZE * scaleY
            
            -- Color by team
            local teamColors = {
                player = {0, 0.7, 1},
                ally = {0, 1, 0},
                enemy = {1, 0, 0},
                neutral = {1, 1, 0}
            }
            local color = teamColors[unit.team] or {1, 1, 1}
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.circle("fill", mx, my, 2)
        end
    end
    
    -- Draw viewport rectangle
    -- ... existing code ...
end
```

**Time:** 2 hours  
**Test:** Verify minimap shows only visible content

---

### Phase 6: Movement and Rotation Updates (3-4 hours)

#### Step 6.1: Update Movement Costs
**File:** `engine/systems/unit.lua`

```lua
function Unit:moveToTile(targetX, targetY, battlefield)
    -- Calculate hex distance
    local startHex = Hex.offsetToCube(self.x, self.y)
    local endHex = Hex.offsetToCube(targetX, targetY)
    local distance = Hex.distance(startHex, endHex)
    
    -- Base cost: 2 MP per hex
    local baseCost = 2 * distance
    
    -- Terrain modifier
    local tile = battlefield:getTile(targetX, targetY)
    local terrainCost = tile.terrain.moveCost or 0
    local totalCost = baseCost + terrainCost
    
    if self.movementPointsLeft >= totalCost then
        -- Update facing to movement direction
        self.facing = self:calculateFacingToTarget(targetX, targetY)
        
        -- Move
        self.x = targetX
        self.y = targetY
        self.movementPointsLeft = self.movementPointsLeft - totalCost
        
        -- Recalculate LOS
        return true, totalCost
    end
    
    return false, totalCost
end

function Unit:calculateFacingToTarget(targetX, targetY)
    local startHex = Hex.offsetToCube(self.x, self.y)
    local endHex = Hex.offsetToCube(targetX, targetY)
    local dq = endHex.q - startHex.q
    local dr = endHex.r - startHex.r
    
    -- Map direction to facing (0-5)
    if dq > 0 and dr == 0 then return 0 end      -- E
    if dq > 0 and dr < 0 then return 1 end       -- NE
    if dq == 0 and dr < 0 then return 2 end      -- NW
    if dq < 0 and dr == 0 then return 3 end      -- W
    if dq < 0 and dr > 0 then return 4 end       -- SW
    if dq == 0 and dr > 0 then return 5 end      -- SE
    
    return self.facing  -- No change if same position
end
```

**Time:** 2 hours  
**Test:** Verify movement costs 2 MP per hex + terrain

#### Step 6.2: Update Rotation Costs
**File:** `engine/modules/battlescape.lua`

```lua
function Battlescape:keypressed(key, scancode, isrepeat)
    -- ... existing code ...
    
    -- Rotation: Q (CCW) / E (CW)
    if (key == "q" or key == "e") and self.selection.selectedUnit then
        local unit = self.selection.selectedUnit
        
        if unit.movementPointsLeft >= 1 then
            local direction = (key == "q") and -1 or 1
            unit.facing = (unit.facing + direction) % 6  -- 0-5 for hex
            unit.movementPointsLeft = unit.movementPointsLeft - 1
            
            -- Recalculate LOS after rotation
            self:updateVisibilityForUnit(unit)
            
            print(string.format("[Battlescape] %s rotated to facing %d (MP: %d)",
                unit.name, unit.facing, unit.movementPointsLeft))
        else
            print(string.format("[Battlescape] %s has no MP to rotate", unit.name))
        end
        return
    end
end
```

**Time:** 1 hour  
**Test:** Verify rotation costs 1 MP per 60° turn

#### Step 6.3: LOS Recalculation During Movement
**File:** `engine/systems/action_system.lua`

```lua
function ActionSystem:executeMove(unit, path, battlefield, teamManager, losSystem)
    for i, step in ipairs(path) do
        -- Move to step
        unit.x = step.x
        unit.y = step.y
        
        -- Update facing
        if i < #path then
            local nextStep = path[i + 1]
            unit.facing = unit:calculateFacingToTarget(nextStep.x, nextStep.y)
        end
        
        -- Recalculate LOS at each step
        local visibleTiles = losSystem:calculateHexVisionCone(battlefield, unit, unit.stats.sightRange)
        local team = teamManager:getTeam(unit.team)
        team:updateFromUnitLOS(unit, visibleTiles)
        
        -- Could trigger reactions/overwatch here
    end
    
    return true
end
```

**Time:** 1-2 hours  
**Test:** Verify LOS updates each movement step

---

### Phase 7: Comprehensive Testing (4-6 hours)

#### Step 7.1: Hex Coordinate Tests
**File:** `engine/tests/test_hex_math.lua`

```lua
local HexMath = require("systems.battle.utils.hex_math")

function testOffsetToCube()
    local hex = HexMath.offsetToCube(0, 0)
    assert(hex.q == 0 and hex.r == 0 and hex.s == 0, "Origin conversion failed")
    
    local hex2 = HexMath.offsetToCube(1, 0)
    assert(hex2.q == 1 and hex2.r == 0, "Column 1 conversion failed")
    
    print("[TEST] Offset to cube conversion: PASS")
end

function testHexDistance()
    local a = HexMath.cube(0, 0)
    local b = HexMath.cube(3, 0)
    assert(HexMath.distance(a, b) == 3, "Distance calculation failed")
    
    print("[TEST] Hex distance: PASS")
end

function testHexNeighbors()
    local center = HexMath.cube(0, 0)
    local neighbors = HexMath.neighbors(center)
    assert(#neighbors == 6, "Should have 6 neighbors")
    
    print("[TEST] Hex neighbors: PASS")
end

function testHexLine()
    local a = HexMath.cube(0, 0)
    local b = HexMath.cube(3, 0)
    local line = HexMath.line(a, b)
    assert(#line == 4, "Line should have 4 hexes")  -- Including start
    
    print("[TEST] Hex line: PASS")
end

-- Run all tests
testOffsetToCube()
testHexDistance()
testHexNeighbors()
testHexLine()
```

**Time:** 2 hours

#### Step 7.2: Pathfinding Tests
**File:** `engine/tests/test_pathfinding_hex.lua`

- Test pathfinding on hex grid
- Verify costs (2 MP base + terrain)
- Test blocked paths
- Test optimal path selection

**Time:** 2 hours

#### Step 7.3: LOS and FOW Tests
**File:** `engine/tests/test_los_hex.lua`

- Test 120° vision cone
- Test line of sight blocking
- Test FOW state transitions
- Test multi-team FOW isolation

**Time:** 2 hours

---

### Phase 8: File Cleanup and Reorganization (3-4 hours)

#### Step 8.1: Audit Existing Files
**Time:** 1 hour

Identify files to:
- **Keep** - Still needed, may need refactoring
- **Deprecate** - Mark as deprecated, will remove next phase
- **Delete** - No longer needed, safe to remove
- **Refactor** - Break into smaller modules

**Audit List:**
```
engine/systems/
├── unit.lua                    -- REFACTOR → entities/unit_entity.lua
├── team.lua                    -- KEEP (update for ECS)
├── action_system.lua           -- REFACTOR → systems/movement_system.lua
├── pathfinding.lua             -- REFACTOR → systems/pathfinding_system.lua
├── los_system.lua              -- REFACTOR → systems/vision_system.lua
├── state_manager.lua           -- KEEP (no changes)
├── ui.lua                      -- KEEP (no changes)
├── assets.lua                  -- KEEP (no changes)
└── battle_tile.lua             -- REFACTOR → entities/tile_entity.lua

engine/systems/battle/
├── battlefield.lua             -- REFACTOR (simplify to data structure)
├── camera.lua                  -- KEEP (maybe minor refactor)
├── renderer.lua                -- DEPRECATE → systems/render_system.lua
├── turn_manager.lua            -- REFACTOR → systems/turn_system.lua
└── unit_selection.lua          -- REFACTOR → systems/input_system.lua
```

#### Step 8.2: Create Migration Plan
**Time:** 30 minutes

Document which code moves where:

**Migration Map:**
```
OLD → NEW

systems/unit.lua
  → components/transform.lua (position, facing)
  → components/movement.lua (MP, speed)
  → components/vision.lua (sight, cone)
  → components/health.lua (HP)
  → entities/unit_entity.lua (composite)

systems/battle/renderer.lua
  → systems/render_system.lua (main rendering)
  → utils/debug.lua (debug rendering)

systems/action_system.lua
  → systems/movement_system.lua (movement logic)
  → systems/turn_system.lua (action points)

systems/pathfinding.lua
  → systems/pathfinding_system.lua (adapted for hex)

systems/los_system.lua
  → systems/vision_system.lua (FOW + LOS)
```

#### Step 8.3: Execute File Moves
**Time:** 1 hour

Systematically move and refactor files:

1. Create new directory structure
2. Copy files to new locations
3. Update `require` statements
4. Test after each move
5. Mark old files as deprecated

**Commands:**
```lua
-- Add deprecation notice to old files
print("[DEPRECATED] This file has been moved to systems/battle/systems/...")
print("[DEPRECATED] Please update your require() statements")
print("[DEPRECATED] This file will be removed in next release")
```

#### Step 8.4: Update All Require Statements
**Time:** 1 hour

Search and replace all `require()` calls:

```bash
# Find all require statements
grep -r "require.*unit" engine/

# Update systematically
systems.unit → systems.battle.entities.unit_entity
systems.battle.renderer → systems.battle.systems.render_system
```

**Create migration helper:**
```lua
-- engine/systems/battle/compat.lua
-- Compatibility layer for old require paths

return {
    unit = function()
        print("[COMPAT] systems.unit is deprecated, use systems.battle.entities.unit_entity")
        return require("systems.battle.entities.unit_entity")
    end,
    
    renderer = function()
        print("[COMPAT] systems.battle.renderer is deprecated, use systems.battle.systems.render_system")
        return require("systems.battle.systems.render_system")
    end
}
```

#### Step 8.5: Delete Deprecated Files
**Time:** 30 minutes

After ensuring all migrations work:

1. Run full test suite
2. Manually test game functionality
3. Delete old files
4. Remove compatibility layer
5. Final test pass

**Files to Delete:**
```
engine/systems/unit.lua                    -- REPLACED
engine/systems/action_system.lua           -- REPLACED
engine/systems/battle/renderer.lua         -- REPLACED
engine/systems/battle/unit_selection.lua   -- REPLACED
```

#### Step 8.6: Update Documentation
**Time:** 30 minutes

Update all documentation to reflect new structure:

- **API.md** - Update module paths
- **DEVELOPMENT.md** - Update architecture section
- **README.md** - Update file structure
- **Inline docs** - Update @module tags

---

### Phase 9: Code Quality Pass (2-3 hours)

#### Step 9.1: Linting and Formatting
**Time:** 1 hour

Run through all new files:

- Remove unused variables
- Check for global leaks
- Standardize indentation (4 spaces)
- Consistent naming (camelCase functions, PascalCase modules)
- Add missing `local` declarations

**Checklist per file:**
```
[ ] All variables are local
[ ] No unused variables
[ ] Consistent indentation
[ ] Docstrings on all public functions
[ ] Error handling where needed
[ ] No print() in production code (use logging system)
[ ] Return values documented
```

#### Step 9.2: Performance Profiling
**Time:** 1 hour

Profile key operations:

```lua
local function profileFunction(name, func, ...)
    local start = love.timer.getTime()
    local result = func(...)
    local duration = love.timer.getTime() - start
    print(string.format("[PROFILE] %s took %.4fms", name, duration * 1000))
    return result
end

-- Profile hex calculations
profileFunction("Hex Neighbors", function()
    for i = 1, 1000 do
        HexMath.neighbors(HexMath.cube(10, 10))
    end
end)
```

Optimize hot paths:
- Hex coordinate conversions (cache results)
- Vision cone calculations (spatial partitioning)
- Rendering (only visible tiles)

#### Step 9.3: Memory Leak Check
**Time:** 30 minutes

Check for circular references and leaks:

```lua
collectgarbage("collect")
local before = collectgarbage("count")

-- Run game loop for 1000 frames
for i = 1, 1000 do
    game:update(0.016)
    game:draw()
end

collectgarbage("collect")
local after = collectgarbage("count")

print(string.format("Memory delta: %.2f KB", after - before))
```

#### Step 9.4: Final Code Review
**Time:** 30 minutes

Review all new code against checklist:

**Code Quality Checklist:**
```
[ ] No hardcoded values (use config/constants)
[ ] Error messages are helpful
[ ] Debug logs use consistent prefixes
[ ] All systems have cleanup methods
[ ] No tight coupling between modules
[ ] Pure functions where possible
[ ] Components are data-only
[ ] Systems don't store state unnecessarily
[ ] All public APIs documented
[ ] Tests cover >80% of code paths
```

---

## Architecture and Components

### **ECS-Inspired Architecture**

Following best Lua practices and component-based design:

#### **Component Structure**
```
engine/systems/battle/
├── components/           -- Pure data components (ECS-like)
│   ├── transform.lua    -- Position, rotation (x, y, facing)
│   ├── movement.lua     -- Movement points, speed, terrain affinity
│   ├── vision.lua       -- Sight range, vision cone, night vision
│   ├── health.lua       -- HP, max HP, armor
│   └── team.lua         -- Team ID, side, color
├── systems/             -- Logic systems (ECS-like)
│   ├── hex_system.lua   -- Hex coordinate math and conversions
│   ├── movement_system.lua -- Movement validation and execution
│   ├── vision_system.lua   -- LOS and FOW calculations
│   ├── render_system.lua   -- Drawing logic
│   ├── input_system.lua    -- Mouse/keyboard handling
│   └── turn_system.lua     -- Turn order and state
├── entities/            -- Entity definitions
│   ├── unit_entity.lua  -- Unit with components
│   ├── tile_entity.lua  -- Tile with components
│   └── team_entity.lua  -- Team with components
└── utils/               -- Helper functions
    ├── hex_math.lua     -- Pure hex calculations
    ├── bresenham.lua    -- Line algorithms
    └── debug.lua        -- Debug rendering
```

### New Components (ECS-Style)

#### 1. **Component Modules** (`systems/battle/components/`)

**transform.lua** - Position and orientation
```lua
local Transform = {}

function Transform.new(x, y, facing)
    return {
        x = x or 0,
        y = y or 0,
        facing = facing or 0,  -- 0-5 for hex
        hex = nil  -- Cached hex coordinates
    }
end

return Transform
```

**movement.lua** - Movement capabilities
```lua
local Movement = {}

function Movement.new(maxMP, speed)
    return {
        maxMovementPoints = maxMP or 24,
        currentMovementPoints = maxMP or 24,
        speed = speed or 1.0,
        terrainAffinity = {}  -- Terrain type modifiers
    }
end

return Movement
```

**vision.lua** - Sight capabilities
```lua
local Vision = {}

function Vision.new(range, coneAngle)
    return {
        sightRange = range or 10,
        visionConeAngle = coneAngle or 120,  -- Degrees
        nightVision = false,
        thermalVision = false,
        lastVisibleTiles = {}  -- Cache
    }
end

return Vision
```

#### 2. **System Modules** (`systems/battle/systems/`)

**hex_system.lua** - Hex coordinate operations
```lua
local HexSystem = {}
local HexMath = require("systems.battle.utils.hex_math")

function HexSystem:worldToHex(x, y)
    return HexMath.offsetToCube(x, y)
end

function HexSystem:getNeighbors(x, y)
    local hex = HexMath.offsetToCube(x, y)
    return HexMath.neighbors(hex)
end

function HexSystem:distance(x1, y1, x2, y2)
    local a = HexMath.offsetToCube(x1, y1)
    local b = HexMath.offsetToCube(x2, y2)
    return HexMath.distance(a, b)
end

return HexSystem
```

**vision_system.lua** - Vision and FOW processing
```lua
local VisionSystem = {}

function VisionSystem:calculateVisionCone(unit, battlefield)
    -- Uses unit's Vision component
    local vision = unit.vision
    local transform = unit.transform
    
    -- Calculate visible tiles based on facing and cone angle
    return self:_raycastCone(transform, vision, battlefield)
end

function VisionSystem:updateTeamFOW(team, units, battlefield)
    -- Aggregate vision from all team units
    local allVisible = {}
    
    for _, unit in ipairs(units) do
        if unit.team.id == team.id then
            local visible = self:calculateVisionCone(unit, battlefield)
            for _, tile in ipairs(visible) do
                allVisible[tile.x .. "," .. tile.y] = tile
            end
        end
    end
    
    team:updateFOW(allVisible)
end

return VisionSystem
```

**movement_system.lua** - Movement validation and execution
```lua
local MovementSystem = {}
local HexSystem = require("systems.battle.systems.hex_system")

function MovementSystem:canMoveTo(unit, targetX, targetY, battlefield)
    local distance = HexSystem:distance(
        unit.transform.x, unit.transform.y,
        targetX, targetY
    )
    
    local tile = battlefield:getTile(targetX, targetY)
    local cost = self:calculateMoveCost(unit, tile, distance)
    
    return unit.movement.currentMovementPoints >= cost, cost
end

function MovementSystem:executeMove(unit, path, battlefield, visionSystem)
    for i, step in ipairs(path) do
        -- Update position
        unit.transform.x = step.x
        unit.transform.y = step.y
        
        -- Update facing
        if i < #path then
            unit.transform.facing = self:calculateFacing(step, path[i + 1])
        end
        
        -- Deduct MP
        local cost = self:calculateMoveCost(unit, battlefield:getTile(step.x, step.y), 1)
        unit.movement.currentMovementPoints = unit.movement.currentMovementPoints - cost
        
        -- Update vision at each step
        visionSystem:calculateVisionCone(unit, battlefield)
    end
end

return MovementSystem
```

**render_system.lua** - All rendering logic
```lua
local RenderSystem = {}

function RenderSystem:drawBattlefield(battlefield, camera, teams, currentTeam)
    self:drawTerrain(battlefield, camera, currentTeam)
    self:drawFOW(battlefield, camera, currentTeam)
    self:drawUnits(battlefield.units, camera, currentTeam)
    
    if self.debugShowGrid then
        self:drawHexGrid(battlefield, camera)
    end
end

function RenderSystem:drawUnit(unit, camera)
    local screenX, screenY = self:worldToScreen(
        unit.transform.x, unit.transform.y, camera
    )
    
    -- Draw sprite
    self:drawSprite(unit.sprite, screenX, screenY, camera.zoom)
    
    -- Draw health bar
    if unit.health then
        self:drawHealthBar(unit.health, screenX, screenY, camera.zoom)
    end
    
    -- Draw facing indicator
    self:drawFacingIndicator(unit.transform, screenX, screenY, camera.zoom)
end

return RenderSystem
```

#### 3. **Entity Definitions** (`systems/battle/entities/`)

**unit_entity.lua** - Composite unit entity
```lua
local Transform = require("systems.battle.components.transform")
local Movement = require("systems.battle.components.movement")
local Vision = require("systems.battle.components.vision")
local Health = require("systems.battle.components.health")
local TeamComponent = require("systems.battle.components.team")

local UnitEntity = {}
UnitEntity.__index = UnitEntity

function UnitEntity.new(unitType, teamId, x, y)
    local self = setmetatable({}, UnitEntity)
    
    -- Core components
    self.id = self:generateId()
    self.name = unitType .. "_" .. self.id
    self.type = unitType
    
    -- Add components
    self.transform = Transform.new(x, y, 0)
    self.movement = Movement.new(24, 1.0)
    self.vision = Vision.new(10, 120)
    self.health = Health.new(100, 100)
    self.team = TeamComponent.new(teamId)
    
    -- Visual
    self.sprite = nil  -- Loaded by asset system
    
    -- State
    self.alive = true
    
    return self
end

function UnitEntity:generateId()
    UnitEntity._idCounter = (UnitEntity._idCounter or 0) + 1
    return UnitEntity._idCounter
end

-- Component accessors
function UnitEntity:getPosition()
    return self.transform.x, self.transform.y
end

function UnitEntity:getFacing()
    return self.transform.facing
end

function UnitEntity:setFacing(facing)
    self.transform.facing = facing % 6
end

return UnitEntity
```

### Modified Components (Following Best Practices)

#### 1. **Refactored Battlefield** (`systems/battle/battlefield.lua`)
- Split into smaller modules
- Pure data structure
- No rendering logic
- Uses systems for operations

#### 2. **Refactored Battlescape** (`modules/battlescape.lua`)
- Orchestrates systems
- Minimal logic (delegates to systems)
- Clean separation of concerns

#### 3. **Utility Modules** (`systems/battle/utils/`)

**hex_math.lua** - Pure hex calculations (no state)
```lua
local HexMath = {}

-- Pure functions only, no side effects
function HexMath.offsetToCube(col, row)
    local q = col
    local r = row - math.floor((col + (col % 2)) / 2)
    return {q = q, r = r, s = -q - r}
end

function HexMath.cubeToOffset(hex)
    local col = hex.q
    local row = hex.r + math.floor((hex.q + (hex.q % 2)) / 2)
    return col, row
end

-- ... more pure functions

return HexMath
```

**debug.lua** - Debug rendering utilities
```lua
local Debug = {}

function Debug.drawHexGrid(battlefield, camera, renderer)
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    love.graphics.setLineWidth(1)
    
    for y = 1, battlefield.height do
        for x = 1, battlefield.width do
            Debug._drawHexOutline(x, y, camera, renderer.tileSize)
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Debug._drawHexOutline(x, y, camera, tileSize)
    local HexMath = require("systems.battle.utils.hex_math")
    local hex = HexMath.offsetToCube(x, y)
    local px, py = HexMath.hexToPixel(hex, tileSize)
    
    -- Draw hex outline
    local points = {}
    for i = 0, 5 do
        local angle = 60 * i * math.pi / 180
        local hx = px + tileSize * math.cos(angle) * camera.zoom + camera.x
        local hy = py + tileSize * math.sin(angle) * camera.zoom + camera.y
        table.insert(points, hx)
        table.insert(points, hy)
    end
    table.insert(points, points[1])
    table.insert(points, points[2])
    
    love.graphics.line(points)
end

return Debug
```

### **Lua Best Practices Applied**

1. **Module Pattern**
   - All modules return a table
   - Use `local` for everything
   - Clear `require` statements at top

2. **Pure Functions Where Possible**
   - HexMath module is stateless
   - Easy to test and reason about
   - No side effects

3. **Component Composition**
   - Small, focused components
   - Entities composed of components
   - Systems operate on components

4. **Minimal Inheritance**
   - Prefer composition over inheritance
   - Only use `setmetatable` for entity constructors
   - No deep inheritance chains

5. **Error Handling**
```lua
local function safeOperation(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        print("[ERROR] " .. tostring(result))
        return nil
    end
    return result
end
```

6. **Resource Management**
```lua
function Battlescape:cleanup()
    -- Clear references
    self.units = {}
    self.battlefield = nil
    
    -- Systems can clean themselves
    if self.renderSystem then
        self.renderSystem:cleanup()
    end
end
```

7. **Configuration Over Code**
```lua
-- Instead of hardcoded values
local UNIT_CONFIG = {
    soldier = {
        movementPoints = 24,
        sightRange = 10,
        health = 100
    },
    sectoid = {
        movementPoints = 20,
        sightRange = 12,
        health = 60
    }
}
```

8. **Testing-Friendly Design**
   - Systems are independent
   - Components are data-only
   - Easy to mock dependencies

9. **Documentation Standards**
```lua
--- Calculate movement cost for a unit moving to a tile
-- @param unit UnitEntity The unit attempting to move
-- @param tile TileEntity The destination tile
-- @param distance number Hex distance to travel
-- @return number The total movement point cost
function MovementSystem:calculateMoveCost(unit, tile, distance)
    -- Implementation
end
```

10. **Performance Considerations**
    - Cache expensive calculations
    - Batch rendering operations
    - Only update what changed
    - Use local variables in hot loops

---

## Dependencies

- Love2D 12.0+
- Lua 5.1+
- Existing widget system
- Existing asset system

---

## Testing Strategy

### Unit Tests
- Hex coordinate conversions
- Distance calculations
- Neighbor detection
- Pathfinding on hex grid
- LOS calculations
- FOW state transitions

### Integration Tests
- Movement with rotation
- Vision cone updates
- Multi-team FOW
- Minimap synchronization

### Manual Tests
- Visual verification of hex grid (F9)
- FOW toggle (F8)
- Minimap click accuracy
- Unit facing indicators
- Movement and rotation costs
- Vision cone limitations

---

## How to Run and Debug

### Running Tests
```bash
cd c:\Users\tombl\Documents\Projects
lovec engine/tests/test_hex.lua
lovec engine/tests/test_pathfinding_hex.lua
lovec engine/tests/test_los_hex.lua
```

### Running Game
```bash
cd c:\Users\tombl\Documents\Projects
lovec "engine"
```

### Debug Controls
- **F4**: Toggle day/night
- **F8**: Toggle fog of war (NEW)
- **F9**: Toggle hex grid overlay (NEW)
- **Space**: Switch team
- **Q/E**: Rotate unit (costs 1 MP)
- **Click**: Select/move unit
- **Arrow keys**: Pan camera

### Console Output
Enable console in `conf.lua` (already enabled):
```lua
t.console = true
```

Watch for debug messages:
- `[Hex]` - Coordinate conversions
- `[FOW]` - Fog of war updates
- `[LOS]` - Line of sight calculations
- `[Minimap]` - Click events
- `[Movement]` - Movement costs and facing

---

## Documentation Updates

### Files to Update

1. **wiki/API.md**
   - Add Hex module documentation
   - Update Battlefield API for hex grid
   - Document FOW debug controls

2. **wiki/FAQ.md**
   - Add hex grid explanation
   - Add vision cone mechanics
   - Add debug key reference

3. **engine/systems/battle/hex.lua**
   - Extensive inline documentation
   - Usage examples

4. **README.md**
   - Update controls section with F8/F9

---

## Review Checklist

### Code Quality
- [ ] All functions have docstrings with @param and @return
- [ ] No magic numbers (use constants/config)
- [ ] Error handling with pcall where appropriate
- [ ] Console logging with consistent prefixes ([ModuleName])
- [ ] No global variables (run strict.lua check)
- [ ] All require() statements use correct paths
- [ ] Deprecated files removed
- [ ] No circular dependencies

### Architecture
- [ ] Components are pure data (no methods)
- [ ] Systems contain logic (no data storage beyond cache)
- [ ] Entities compose components correctly
- [ ] Clear separation of concerns
- [ ] Minimal coupling between modules
- [ ] Pure functions in utils/ (stateless, no side effects)
- [ ] No deep inheritance (prefer composition)

### Performance
- [ ] Camera culling implemented for rendering
- [ ] FOW overlay only for visible area
- [ ] Hex neighbor lookup uses cache where possible
- [ ] Path caching implemented
- [ ] No memory leaks (profiled with collectgarbage)
- [ ] Hot loops optimized (local variables)
- [ ] Batch rendering where possible

### Testing
- [ ] Unit tests for hex math (>90% coverage)
- [ ] Unit tests for pathfinding (>80% coverage)
- [ ] Unit tests for vision system (>80% coverage)
- [ ] Integration tests for movement + vision
- [ ] Manual test scenarios documented
- [ ] Edge cases handled (map boundaries, nil checks)
- [ ] All tests pass without errors

### Gameplay
- [ ] Movement costs feel balanced (2 MP per hex)
- [ ] Rotation costs feel right (1 MP per 60°)
- [ ] Vision cone provides tactical depth (120°)
- [ ] FOW creates exploration tension
- [ ] Minimap click accuracy verified
- [ ] Debug keys work (F8, F9)
- [ ] Unit facing indicators clear

### Visual
- [ ] Hex grid aligns properly (F9 to verify)
- [ ] Unit facing arrows visible and clear
- [ ] FOW overlay not too dark/light (adjustable)
- [ ] Minimap FOW readable
- [ ] Terrain sprites aligned to hex grid
- [ ] Unit sprites centered on hex
- [ ] Health bars aligned properly

### Documentation
- [ ] API.md updated with new modules
- [ ] FAQ.md updated with hex mechanics
- [ ] DEVELOPMENT.md updated with architecture
- [ ] README.md updated with new structure
- [ ] All module files have header docs
- [ ] Debug controls documented
- [ ] Migration guide created for old code

### File Organization
- [ ] New directory structure created
- [ ] All files in correct locations
- [ ] Old files deprecated/deleted
- [ ] No duplicate code
- [ ] Clear naming conventions
- [ ] Logical grouping of modules

---

## Lua Best Practices Summary

### 1. Module Pattern
```lua
-- Good: Clear module pattern
local MyModule = {}

function MyModule.publicFunction()
    return MyModule._privateFunction()
end

function MyModule._privateFunction()
    -- Implementation
end

return MyModule
```

### 2. Local Variables
```lua
-- Good: Everything local
local function helper()
    local x = 10
    return x * 2
end

-- Bad: Global leak
function globalFunction()
    y = 20  -- LEAK!
end
```

### 3. Error Handling
```lua
-- Good: Protected calls for risky operations
local success, result = pcall(function()
    return riskyOperation()
end)

if not success then
    print("[ERROR] Operation failed: " .. tostring(result))
    return nil
end

return result
```

### 4. Configuration Over Code
```lua
-- Good: Externalized config
local CONFIG = require("config.battle")

local function getCost(terrainType)
    return CONFIG.TERRAIN_COSTS[terrainType] or 2
end

-- Bad: Hardcoded
local function getCost(terrainType)
    if terrainType == "rough" then
        return 3
    elseif terrainType == "water" then
        return 6
    end
    return 2
end
```

### 5. Pure Functions
```lua
-- Good: Pure function (no side effects)
local function calculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Bad: Side effects
local totalDistance = 0
local function calculateAndAccumulate(x1, y1, x2, y2)
    local dist = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    totalDistance = totalDistance + dist  -- SIDE EFFECT!
    return dist
end
```

### 6. Component Composition
```lua
-- Good: Composition
local Entity = {}
function Entity.new()
    return {
        transform = Transform.new(),
        health = Health.new(),
        movement = Movement.new()
    }
end

-- Bad: Deep inheritance
local Entity = {}
local Soldier = setmetatable({}, {__index = Entity})
local EliteSoldier = setmetatable({}, {__index = Soldier})  -- Too deep!
```

### 7. Documentation
```lua
--- Calculate hex distance between two points
-- Uses cube coordinate system for accurate hex distance
-- @param x1 number First hex X coordinate
-- @param y1 number First hex Y coordinate
-- @param x2 number Second hex X coordinate
-- @param y2 number Second hex Y coordinate
-- @return number Distance in hex tiles
-- @usage local dist = HexMath.distance(0, 0, 3, 0)  -- Returns 3
function HexMath.distance(x1, y1, x2, y2)
    -- Implementation
end
```

### 8. Performance (Hot Loops)
```lua
-- Good: Local loop variables
local function processUnits(units)
    local count = #units
    for i = 1, count do
        local unit = units[i]  -- Local copy
        processUnit(unit)
    end
end

-- Bad: Global access in loop
function processUnits(units)
    for i = 1, #units do
        processUnit(units[i])  -- Repeated table access
    end
end
```

### 9. Resource Cleanup
```lua
-- Good: Explicit cleanup
function Battlescape:cleanup()
    -- Clear references
    self.units = nil
    self.battlefield = nil
    
    -- Systems cleanup
    if self.renderSystem then
        self.renderSystem:cleanup()
    end
    
    -- Force garbage collection
    collectgarbage("collect")
end
```

### 10. Testing
```lua
-- Good: Testable design
local function calculateDamage(attack, defense)
    return math.max(0, attack - defense)
end

-- Test
assert(calculateDamage(10, 5) == 5, "Damage calculation failed")
assert(calculateDamage(5, 10) == 0, "Negative damage should be 0")
```

---

## Risks and Mitigations

### Risk 1: Hex Coordinate Complexity
**Impact:** High  
**Probability:** Medium  
**Mitigation:**
- Use well-tested cube coordinate system
- Extensive unit tests for conversions
- Visual debug overlay (F9) to verify

### Risk 2: Performance with FOW Overlay
**Impact:** Medium  
**Probability:** Low  
**Mitigation:**
- Only draw FOW for visible tiles (camera culling)
- Use batched drawing where possible
- Profile with Love2D profiler if issues arise

### Risk 3: Pathfinding on Hex Grid
**Impact:** High  
**Probability:** Low  
**Mitigation:**
- Adapt existing A* with hex neighbors
- Test extensively with various scenarios
- Fallback to rectangular if critical issues

### Risk 4: Breaking Existing Gameplay
**Impact:** High  
**Probability:** Medium  
**Mitigation:**
- Implement feature flags for hex mode
- Keep rectangular grid as fallback
- Incremental testing at each phase

---

## What Worked Well

*(To be filled after implementation)*

---

## Lessons Learned

*(To be filled after implementation)*

---

## Next Steps After Completion

1. Add unit animations for movement/rotation
2. Implement overwatch/reaction fire system
3. Add destructible terrain
4. Implement multi-level maps (Z-axis)
5. Add weather effects that modify vision
6. Implement sound effects for actions
7. Add particle effects for weapons

---

## References

- Hex Grid Guide: https://www.redblobgames.com/grids/hexagons/
- X-COM UFO Defense mechanics
- Love2D API: https://love2d.org/wiki/Main_Page
- Bresenham Line Algorithm for Hex Grids

---

**END OF TASK DOCUMENT**

---

## Quick Reference: New File Structure

```
engine/
├── systems/
│   ├── battle/
│   │   ├── components/              -- Pure data components
│   │   │   ├── transform.lua        -- Position, facing
│   │   │   ├── movement.lua         -- Movement points, speed
│   │   │   ├── vision.lua           -- Sight range, cone angle
│   │   │   ├── health.lua           -- HP, max HP, armor
│   │   │   └── team.lua             -- Team ID, side, color
│   │   ├── systems/                 -- Logic systems
│   │   │   ├── hex_system.lua       -- Hex coordinate operations
│   │   │   ├── movement_system.lua  -- Movement validation/execution
│   │   │   ├── vision_system.lua    -- LOS and FOW calculations
│   │   │   ├── render_system.lua    -- All rendering logic
│   │   │   ├── input_system.lua     -- Mouse/keyboard handling
│   │   │   ├── turn_system.lua      -- Turn order and state
│   │   │   └── pathfinding_system.lua -- A* for hex grid
│   │   ├── entities/                -- Composite entities
│   │   │   ├── unit_entity.lua      -- Unit with components
│   │   │   ├── tile_entity.lua      -- Tile with components
│   │   │   └── team_entity.lua      -- Team with components
│   │   ├── utils/                   -- Helper utilities
│   │   │   ├── hex_math.lua         -- Pure hex calculations
│   │   │   ├── bresenham.lua        -- Line algorithms
│   │   │   └── debug.lua            -- Debug rendering
│   │   ├── battlefield.lua          -- Battlefield data structure
│   │   └── camera.lua               -- Camera controller
│   ├── state_manager.lua            -- (unchanged)
│   ├── ui.lua                       -- (unchanged)
│   └── assets.lua                   -- (unchanged)
├── modules/
│   └── battlescape.lua              -- Main battle orchestrator
├── tests/
│   ├── test_hex_math.lua            -- Hex coordinate tests
│   ├── test_pathfinding_hex.lua     -- Pathfinding tests
│   ├── test_vision_system.lua       -- LOS and FOW tests
│   └── test_movement_system.lua     -- Movement tests
└── config/
    └── battle.lua                   -- Battle configuration

DEPRECATED (to be removed):
├── systems/unit.lua                 -- → entities/unit_entity.lua
├── systems/action_system.lua        -- → systems/movement_system.lua
├── systems/battle/renderer.lua      -- → systems/render_system.lua
└── systems/battle/unit_selection.lua -- → systems/input_system.lua
```

---

## Estimated Total Time: 28-40 hours

**Phase Breakdown:**
- Phase 0: ECS Setup (4-6 hours)
- Phase 1: Hex System (4-6 hours)
- Phase 2: Hex Rendering (3-4 hours)
- Phase 3: Unit Facing & Vision (4-5 hours)
- Phase 4: FOW Improvements (4-5 hours)
- Phase 5: Minimap Fixes (3-4 hours)
- Phase 6: Movement Updates (3-4 hours)
- Phase 7: Testing (4-6 hours)
- Phase 8: File Cleanup (3-4 hours)
- Phase 9: Code Quality (2-3 hours)

**Benefits of ECS Architecture:**
✅ **Testability** - Components and systems can be tested independently  
✅ **Maintainability** - Clear separation of data and logic  
✅ **Scalability** - Easy to add new components/systems  
✅ **Performance** - Cache-friendly data layouts  
✅ **Flexibility** - Mix and match components freely  
✅ **Debugging** - Easier to inspect component state  

**Key Deliverables:**
1. Fully functional hex grid system
2. ECS-inspired architecture
3. Enhanced FOW with debug toggle
4. Fixed minimap with FOW display
5. Unit facing indicators and vision cones
6. Comprehensive test suite (>80% coverage)
7. Clean, documented codebase
8. Migration guide for old code
9. Updated documentation

---

**Ready to begin implementation!** 🚀

Start with Phase 0 to establish the ECS foundation, then proceed through each phase systematically. Each phase is designed to be independently testable, so you can verify correctness before moving forward.

---

**END OF TASK DOCUMENT**
