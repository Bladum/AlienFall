# Task: Tactical Battlescape Combat System Expansion

**Status:** TODO  
**Priority:** High  
**Created:** 2025-10-10  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a comprehensive tactical turn-based combat system for the Battlescape module, featuring advanced unit stats, movement mechanics, line of sight (LOS), fog of war (FOW), terrain system, action points, and team-based gameplay. This transforms the basic placeholder battlescape into a full-featured tactical combat engine inspired by X-COM.

---

## Purpose

The current battlescape implementation is a minimal prototype. This expansion creates a complete tactical combat system with:
- Deep unit customization (12 stats per unit)
- Class-based unit system with equipment
- Sophisticated movement with AP/MP mechanics
- Directional line of sight and fog of war per team
- Terrain variety affecting movement and sight
- Multi-tile unit sizes (1x1, 2x2)
- Environmental effects (smoke, fire)
- Ground objects and loot system
- Team-based visibility sharing
- Tactical positioning and cover mechanics

This is the foundation for X-COM-style tactical gameplay.

---

## Requirements

### Functional Requirements

#### Unit System
- [x] Define 12 unit stats: strength, health, energy, armour, aim, react, speed, will, morale, sanity, psi, sight, sense, cover, size
- [x] Implement unit class system that defines base stats
- [x] Units can equip up to 2 weapons and 1 armour
- [x] Support 1x1 and 2x2 unit sizes affecting movement, LOS, and collision
- [x] Units have 8-directional facing (N, NE, E, SE, S, SW, W, NW)
- [x] Units belong to teams, teams belong to sides (player, ally, enemy, neutral)

#### Movement System
- [x] Action Points (AP) system: Fixed 4 AP per turn per unit
- [x] Movement Points (MP) system: MP = AP_left × unit.speed (typically 24-48 MP)
- [x] AP and MP are linked: using one recalculates the other
- [x] Movement costs:
  - Rotate 90° = 1 MP
  - Move normal tile = 2 MP
  - Move tough terrain = 4 MP
  - Move slope (high to low) = 6 MP
  - Diagonal movement = 50% more MP
- [x] Display movement range (very light green) when unit selected
- [x] Display path (light green) when hovering over destination
- [x] LMB to move: animate fast movement along path
- [x] Units auto-rotate to face movement direction while moving
- [x] RMB on ground: rotate unit to face that direction

#### Battle Tile System
- [x] Each battle tile contains:
  - Unit reference (if unit occupies it)
  - Map tile (floor/wall type)
  - List of objects on ground
  - Smoke level (0-10)
  - Fire level (0-10)
  - Fog of war per team (visible/explored/hidden)
- [x] Map tiles have properties:
  - Movement cost (0 = impassable wall, 2 = normal, 4 = tough, 6 = slope)
  - Sight cost (1 = normal, 3 = smoke, 5 = bushes, 1000 = wall)
- [x] Some tiles block movement but not sight (low walls, windows)
- [x] Some tiles block sight but not movement (smoke, fog)
- [x] Some tiles block both (solid walls)

#### Line of Sight (LOS) System
- [x] Directional vision: 90° cone + 1 tile in facing direction
- [x] Sight range defined by unit.sight stat (e.g., 20 tiles)
- [x] Omnidirectional sense range (unit.sense, e.g., 3 tiles)
- [x] Ray-casting algorithm for LOS calculation
- [x] Sight cost accumulation: blocks when cost exceeds threshold
- [x] Last blocking tile is still visible (shows walls)
- [x] Teams share visibility of all units
- [x] Recalculate LOS on unit move or rotate

#### Fog of War (FOW) System
- [x] Three visibility states per team:
  - Hidden: Never seen (black)
  - Explored: Previously seen (dark gray)
  - Visible: Currently visible (full brightness)
- [x] Per-team FOW tracking (each team has own visibility map)
- [x] Space bar: Temporarily switch active team view (debug feature)
- [x] FOW recalculates every turn start and after each action

#### Turn System
- [x] Team-based turns (not individual unit initiative)
- [x] All units of active team can act in any order
- [x] Turn ends manually or when all units exhausted
- [x] New turn: Reset all units' AP/MP to maximum
- [x] Turn order: Player → Ally → Enemy → Neutral → repeat

#### Combat System (Basic)
- [x] Select unit with LMB (if on player team)
- [x] Select different unit to switch selection
- [x] Show unit stats panel when selected
- [x] Show movement range overlay
- [x] Show path preview on hover
- [x] Move unit with LMB on valid tile
- [x] Rotate unit with RMB on ground

### Technical Requirements

#### Architecture
- [x] Modular design: Separate files for units, tiles, LOS, movement, combat
- [x] Data-driven unit classes (JSON or Lua tables in `engine/data/`)
- [x] Efficient LOS algorithm (avoid O(n²) per unit)
- [x] Pathfinding: A* algorithm for movement
- [x] State management for turn phases
- [x] Event system for combat actions
- [x] Grid-aligned rendering (24x24 pixel tiles)

#### Performance
- [x] LOS calculations optimized with bresenham/DDA algorithm
- [x] Cache movement ranges until unit moves
- [x] Only recalculate FOW when necessary
- [x] Efficient collision detection for multi-tile units
- [x] Object pooling for temporary calculations

#### Data Structures
- [x] Unit class definitions in `engine/data/unit_classes.lua`
- [x] Weapon definitions in `engine/data/weapons.lua`
- [x] Armour definitions in `engine/data/armours.lua`
- [x] Terrain tile definitions in `engine/data/terrain_types.lua`
- [x] Map generation templates

### Acceptance Criteria

#### Core Gameplay
- [ ] Can select player units and see their stats
- [ ] Can move units using displayed movement range
- [ ] Movement costs AP/MP correctly based on terrain
- [ ] Units auto-rotate during movement
- [ ] Can manually rotate units with RMB
- [ ] Units have proper 8-directional facing
- [ ] FOW correctly hides unexplored areas
- [ ] Explored areas visible but darker
- [ ] Currently visible areas bright
- [ ] LOS respects directional 90° cone
- [ ] Walls and obstacles block LOS correctly
- [ ] Smoke/fire reduce visibility
- [ ] Multiple teams have independent FOW
- [ ] Space bar switches team view for debugging
- [ ] Turn system works: player → enemy → player
- [ ] All units reset AP/MP on new turn
- [ ] 2x2 units occupy correct tiles
- [ ] 2x2 units cannot move through 1-tile gaps

#### Technical Quality
- [ ] No errors in Love2D console
- [ ] Runs at 60 FPS with 30x30 map + 20 units
- [ ] LOS calculations complete within 16ms
- [ ] Pathfinding finds path within 50ms
- [ ] Grid overlay works (F9 toggle)
- [ ] All positions snap to 24x24 grid
- [ ] Code follows Lua style guide
- [ ] All functions have docstring comments
- [ ] No global variables

#### Data Integration
- [ ] Unit classes loaded from data files
- [ ] At least 3 unit classes defined (soldier, alien, civilian)
- [ ] At least 5 terrain types defined
- [ ] Weapons and armour modify unit stats
- [ ] Equipment saved with unit data

---

## Plan

### Phase 1: Core Data Structures (8 hours)

#### Step 1.1: Unit Class System
**Description:** Create unit class definitions and stat system

**Files to create:**
- `engine/data/unit_classes.lua` - Unit class definitions
- `engine/systems/unit.lua` - Unit entity system
- `engine/data/weapons.lua` - Weapon definitions
- `engine/data/armours.lua` - Armour definitions

**Implementation:**
```lua
-- Unit class structure
UnitClass = {
    id = "soldier",
    name = "Soldier",
    baseStats = {
        strength = 8,
        health = 10,
        energy = 10,
        armour = 0,
        aim = 8,
        react = 7,
        speed = 6,
        will = 8,
        morale = 10,
        sanity = 10,
        psi = 2,
        sight = 20,
        sense = 3,
        cover = 0,
        size = 1  -- 1x1 or 2x2
    },
    defaultWeapon1 = "rifle",
    defaultWeapon2 = nil,
    defaultArmour = nil
}
```

**Estimated time:** 3 hours

#### Step 1.2: Battle Tile System
**Description:** Enhance tile structure with all required properties

**Files to modify:**
- `engine/modules/battlescape.lua` - Update initMap()

**Files to create:**
- `engine/systems/battle_tile.lua` - Battle tile entity
- `engine/data/terrain_types.lua` - Terrain definitions

**Implementation:**
```lua
-- Battle tile structure
BattleTile = {
    unit = nil,  -- Unit reference or nil
    terrain = {
        type = "floor",  -- "floor", "wall", "rough", etc.
        moveCost = 2,    -- MP cost to enter
        sightCost = 1    -- LOS cost to pass through
    },
    objects = {},  -- List of ground objects
    effects = {
        smoke = 0,  -- 0-10
        fire = 0    -- 0-10
    },
    fogOfWar = {
        -- Per team visibility
        player = "hidden",  -- "hidden", "explored", "visible"
        enemy = "hidden",
        -- ... more teams
    }
}
```

**Estimated time:** 2 hours

#### Step 1.3: Team System
**Description:** Implement team and side management

**Files to create:**
- `engine/systems/team.lua` - Team management system

**Implementation:**
```lua
Team = {
    id = "team1",
    name = "XCOM Squad Alpha",
    side = "player",  -- "player", "ally", "enemy", "neutral"
    units = {},       -- List of unit IDs
    visibility = {}   -- 2D array of visibility states
}
```

**Estimated time:** 1 hour

#### Step 1.4: Terrain Definitions
**Description:** Define various terrain types

**Files to create:**
- `engine/data/terrain_types.lua`

**Terrain types:**
- Floor (normal): moveCost=2, sightCost=1
- Wall (solid): moveCost=0, sightCost=1000
- Rough terrain: moveCost=4, sightCost=1
- Slope: moveCost=6, sightCost=1
- Smoke: moveCost=2, sightCost=3
- Bush: moveCost=2, sightCost=5
- Window: moveCost=0, sightCost=1
- Low wall: moveCost=0, sightCost=2

**Estimated time:** 2 hours

---

### Phase 2: Movement System (10 hours)

#### Step 2.1: Action Point / Movement Point System
**Description:** Implement linked AP/MP mechanics

**Files to modify:**
- `engine/systems/unit.lua` - Add AP/MP calculation

**Files to create:**
- `engine/systems/action_system.lua` - AP/MP management

**Implementation:**
```lua
-- AP/MP relationship
function Unit:calculateMP()
    return self.actionPointsLeft * self.stats.speed
end

function Unit:spendMP(amount)
    self.movementPoints = self.movementPoints - amount
    self.actionPointsLeft = math.floor(self.movementPoints / self.stats.speed)
end

function Unit:spendAP(amount)
    self.actionPointsLeft = self.actionPointsLeft - amount
    self.movementPoints = self:calculateMP()
end
```

**Estimated time:** 3 hours

#### Step 2.2: Pathfinding System (A*)
**Description:** Implement A* pathfinding with terrain costs

**Files to create:**
- `engine/systems/pathfinding.lua` - A* implementation

**Features:**
- Heap-based priority queue
- Movement cost calculation including terrain
- Diagonal movement cost (1.5x)
- Rotation cost consideration
- Multi-tile unit support (check all tiles occupied)

**Estimated time:** 4 hours

#### Step 2.3: Movement Visualization
**Description:** Display movement range and path

**Files to modify:**
- `engine/modules/battlescape.lua` - Enhance draw() and update()

**Features:**
- Flood-fill for movement range (very light green overlay)
- Real-time path display on hover (light green path)
- Show MP cost on hovered tile
- Animate unit movement along path

**Estimated time:** 2 hours

#### Step 2.4: Rotation System
**Description:** Implement 8-directional facing and rotation costs

**Files to modify:**
- `engine/systems/unit.lua` - Add facing direction

**Implementation:**
```lua
Unit.facing = 0  -- 0=E, 1=SE, 2=S, 3=SW, 4=W, 5=NW, 6=N, 7=NE

function Unit:rotateTo(targetFacing)
    local diff = math.abs(targetFacing - self.facing)
    if diff > 4 then diff = 8 - diff end
    local cost = diff * 1  -- 1 MP per 90° rotation
    self:spendMP(cost)
    self.facing = targetFacing
end

function Unit:getFacingFromDirection(dx, dy)
    -- Convert direction vector to facing index
    local angle = math.atan2(dy, dx)
    return math.floor((angle / (math.pi / 4) + 0.5) % 8)
end
```

**Estimated time:** 1 hour

---

### Phase 3: Line of Sight System (12 hours)

#### Step 3.1: Bresenham Line Algorithm
**Description:** Implement efficient line-of-sight ray casting

**Files to create:**
- `engine/systems/line_of_sight.lua` - LOS calculation system

**Implementation:**
```lua
function LOS:rayCast(x1, y1, x2, y2, maxCost)
    -- Bresenham algorithm
    -- Accumulate sight cost along ray
    -- Stop when cost exceeds maxCost
    -- Return: {visible=true/false, tiles={...}}
end

function LOS:bresenhamLine(x0, y0, x1, y1)
    -- Returns list of tiles along line
    local tiles = {}
    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    local err = dx - dy
    
    while true do
        table.insert(tiles, {x=x0, y=y0})
        if x0 == x1 and y0 == y1 then break end
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x0 = x0 + sx
        end
        if e2 < dx then
            err = err + dx
            y0 = y0 + sy
        end
    end
    
    return tiles
end
```

**Estimated time:** 4 hours

#### Step 3.2: Directional Vision Cone
**Description:** Implement 90° front cone + omnidirectional sense

**Files to modify:**
- `engine/systems/line_of_sight.lua` - Add cone calculation

**Implementation:**
```lua
function LOS:calculateVisibility(unit, battlefield)
    local visible = {}
    
    -- Directional cone (90° + 1 tile in facing direction)
    local coneRange = unit.stats.sight
    local facingAngle = unit.facing * (math.pi / 4)
    
    for dy = -coneRange, coneRange do
        for dx = -coneRange, coneRange do
            local targetX = unit.x + dx
            local targetY = unit.y + dy
            
            -- Check if in cone
            local angle = math.atan2(dy, dx)
            local angleDiff = math.abs(angle - facingAngle)
            if angleDiff > math.pi then angleDiff = 2*math.pi - angleDiff end
            
            local inCone = (angleDiff <= math.pi/4)  -- 90° cone
            local distance = math.sqrt(dx*dx + dy*dy)
            local inRange = distance <= coneRange
            
            if inCone and inRange then
                -- Ray cast to check visibility
                local result = self:rayCast(unit.x, unit.y, targetX, targetY, 100)
                if result.visible then
                    table.insert(visible, {x=targetX, y=targetY})
                end
            end
        end
    end
    
    -- Omnidirectional sense
    local senseRange = unit.stats.sense
    for dy = -senseRange, senseRange do
        for dx = -senseRange, senseRange do
            local distance = math.sqrt(dx*dx + dy*dy)
            if distance <= senseRange then
                local targetX = unit.x + dx
                local targetY = unit.y + dy
                -- Always visible within sense range (no ray cast)
                table.insert(visible, {x=targetX, y=targetY})
            end
        end
    end
    
    return visible
end
```

**Estimated time:** 4 hours

#### Step 3.3: Sight Cost System
**Description:** Terrain affects LOS with accumulating costs

**Files to modify:**
- `engine/systems/line_of_sight.lua` - Add cost accumulation

**Sight costs:**
- Normal tile: 1
- Smoke: +3
- Bushes: +5
- Wall: 1000 (blocks)
- Fire: +2
- Last blocking tile is still visible

**Estimated time:** 2 hours

#### Step 3.4: Multi-Tile Unit LOS
**Description:** Handle 2x2 units for LOS calculation

**Files to modify:**
- `engine/systems/line_of_sight.lua` - Check all occupied tiles

**Implementation:**
```lua
function LOS:calculateVisibilityForUnit(unit, battlefield)
    local allVisible = {}
    
    -- For each tile occupied by unit
    for oy = 0, unit.stats.size - 1 do
        for ox = 0, unit.stats.size - 1 do
            local unitX = unit.x + ox
            local unitY = unit.y + oy
            
            -- Calculate visibility from this tile
            local visible = self:calculateVisibility({
                x = unitX,
                y = unitY,
                facing = unit.facing,
                stats = unit.stats
            }, battlefield)
            
            -- Merge with total visible tiles
            for _, tile in ipairs(visible) do
                allVisible[tile.y * 1000 + tile.x] = tile
            end
        end
    end
    
    -- Convert hash map back to array
    local result = {}
    for _, tile in pairs(allVisible) do
        table.insert(result, tile)
    end
    
    return result
end
```

**Estimated time:** 2 hours

---

### Phase 4: Fog of War System (8 hours)

#### Step 4.1: Per-Team Visibility Tracking
**Description:** Each team maintains own FOW state

**Files to create:**
- `engine/systems/fog_of_war.lua` - FOW management

**Implementation:**
```lua
FogOfWar = {
    teams = {}  -- {teamId = {[y][x] = "hidden"|"explored"|"visible"}}
}

function FogOfWar:initialize(teams, mapWidth, mapHeight)
    for _, team in ipairs(teams) do
        self.teams[team.id] = {}
        for y = 1, mapHeight do
            self.teams[team.id][y] = {}
            for x = 1, mapWidth do
                self.teams[team.id][y][x] = "hidden"
            end
        end
    end
end

function FogOfWar:update(teamId, visibleTiles)
    -- Reset all to explored (if previously visible)
    for y, row in ipairs(self.teams[teamId]) do
        for x, state in ipairs(row) do
            if state == "visible" then
                self.teams[teamId][y][x] = "explored"
            end
        end
    end
    
    -- Mark currently visible tiles
    for _, tile in ipairs(visibleTiles) do
        if tile.x >= 1 and tile.y >= 1 then
            self.teams[teamId][tile.y][tile.x] = "visible"
        end
    end
end
```

**Estimated time:** 3 hours

#### Step 4.2: Team Shared Visibility
**Description:** All units in team share visibility

**Files to modify:**
- `engine/systems/fog_of_war.lua` - Aggregate unit visibility

**Implementation:**
```lua
function FogOfWar:updateTeamVisibility(team, units, battlefield, losSystem)
    local allVisible = {}
    
    -- Gather visibility from all units in team
    for _, unit in ipairs(units) do
        if unit.team == team.id and unit.alive then
            local visible = losSystem:calculateVisibilityForUnit(unit, battlefield)
            for _, tile in ipairs(visible) do
                allVisible[tile.y * 1000 + tile.x] = tile
            end
        end
    end
    
    -- Convert to array
    local visibleArray = {}
    for _, tile in pairs(allVisible) do
        table.insert(visibleArray, tile)
    end
    
    -- Update FOW for this team
    self:update(team.id, visibleArray)
end
```

**Estimated time:** 2 hours

#### Step 4.3: FOW Rendering
**Description:** Draw tiles based on visibility state

**Files to modify:**
- `engine/modules/battlescape.lua` - Update draw() method

**Rendering rules:**
- Hidden: Pure black (#000000)
- Explored: Dark gray (terrain color * 0.3)
- Visible: Full brightness (terrain color * 1.0)
- Units only visible if tile is currently visible
- Ground objects visible if explored

**Estimated time:** 2 hours

#### Step 4.4: Debug Team View Toggle
**Description:** Space bar to toggle between team views

**Files to modify:**
- `engine/modules/battlescape.lua` - Add keypressed handler

**Implementation:**
```lua
self.debugViewTeam = "player"  -- Current team view
self.debugTeamList = {"player", "enemy"}  -- All teams

function Battlescape:keypressed(key)
    if key == "space" then
        -- Cycle through teams
        local current = 1
        for i, team in ipairs(self.debugTeamList) do
            if team == self.debugViewTeam then
                current = i
                break
            end
        end
        current = (current % #self.debugTeamList) + 1
        self.debugViewTeam = self.debugTeamList[current]
        print("[Battlescape] Debug view: " .. self.debugViewTeam)
    end
end

function Battlescape:draw()
    -- Use debug view team for FOW rendering
    local viewTeam = self.debugViewTeam
    
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local visibility = self.fogOfWar.teams[viewTeam][y][x]
            -- Render based on visibility...
        end
    end
end
```

**Estimated time:** 1 hour

---

### Phase 5: Turn System Enhancement (6 hours)

#### Step 5.1: Team-Based Turns
**Description:** Implement team turn order system

**Files to create:**
- `engine/systems/turn_manager.lua` - Turn management

**Implementation:**
```lua
TurnManager = {
    teams = {},  -- List of teams in turn order
    currentTeamIndex = 1,
    turnNumber = 1
}

function TurnManager:initialize(teams)
    -- Sort teams by side priority: player, ally, enemy, neutral
    local sideOrder = {player=1, ally=2, enemy=3, neutral=4}
    table.sort(teams, function(a, b)
        return sideOrder[a.side] < sideOrder[b.side]
    end)
    self.teams = teams
end

function TurnManager:nextTeam()
    self.currentTeamIndex = self.currentTeamIndex + 1
    if self.currentTeamIndex > #self.teams then
        self.currentTeamIndex = 1
        self.turnNumber = self.turnNumber + 1
        print("[TurnManager] New turn: " .. self.turnNumber)
    end
    
    local team = self.teams[self.currentTeamIndex]
    print("[TurnManager] Team turn: " .. team.name)
    
    return team
end

function TurnManager:getCurrentTeam()
    return self.teams[self.currentTeamIndex]
end
```

**Estimated time:** 2 hours

#### Step 5.2: Unit AP/MP Reset
**Description:** Reset all units at turn start

**Files to modify:**
- `engine/systems/turn_manager.lua` - Add reset function
- `engine/systems/unit.lua` - Add resetForTurn() method

**Implementation:**
```lua
function Unit:resetForTurn()
    self.actionPointsLeft = 4  -- Fixed 4 AP
    self.movementPoints = self:calculateMP()  -- AP * speed
    self.hasActed = false
end

function TurnManager:startTeamTurn(team, units)
    -- Reset all units in team
    for _, unit in ipairs(units) do
        if unit.team == team.id and unit.alive then
            unit:resetForTurn()
        end
    end
end
```

**Estimated time:** 1 hour

#### Step 5.3: Turn UI
**Description:** Display current team, turn number, AP/MP

**Files to modify:**
- `engine/modules/battlescape.lua` - Enhance UI display

**UI elements:**
- Turn number (top center)
- Current team (top center)
- Selected unit AP/MP (info panel)
- End turn button (only for player team)

**Estimated time:** 2 hours

#### Step 5.4: Turn Phase Management
**Description:** Handle turn transitions and phases

**Phases:**
1. Turn start (reset units)
2. Action phase (units can act)
3. Turn end (cleanup)
4. Next team

**Estimated time:** 1 hour

---

### Phase 6: Multi-Tile Unit Support (8 hours)

#### Step 6.1: Unit Size Implementation
**Description:** Support 1x1 and 2x2 units

**Files to modify:**
- `engine/systems/unit.lua` - Add size property
- `engine/modules/battlescape.lua` - Update rendering

**Implementation:**
```lua
Unit.stats.size = 1  -- 1 or 2

-- Check if unit occupies tile
function Unit:occupiesTile(x, y)
    for oy = 0, self.stats.size - 1 do
        for ox = 0, self.stats.size - 1 do
            if self.x + ox == x and self.y + oy == y then
                return true
            end
        end
    end
    return false
end

-- Get all tiles occupied
function Unit:getOccupiedTiles()
    local tiles = {}
    for oy = 0, self.stats.size - 1 do
        for ox = 0, self.stats.size - 1 do
            table.insert(tiles, {x = self.x + ox, y = self.y + oy})
        end
    end
    return tiles
end
```

**Estimated time:** 2 hours

#### Step 6.2: Collision Detection
**Description:** Check collisions for all occupied tiles

**Files to modify:**
- `engine/systems/pathfinding.lua` - Update collision checks

**Implementation:**
```lua
function Pathfinding:isPassable(unit, targetX, targetY)
    -- Check all tiles unit would occupy
    for oy = 0, unit.stats.size - 1 do
        for ox = 0, unit.stats.size - 1 do
            local checkX = targetX + ox
            local checkY = targetY + oy
            
            -- Out of bounds?
            if checkX < 1 or checkX > MAP_WIDTH or 
               checkY < 1 or checkY > MAP_HEIGHT then
                return false
            end
            
            -- Blocked by terrain?
            local tile = battlefield.map[checkY][checkX]
            if tile.terrain.moveCost == 0 then
                return false
            end
            
            -- Blocked by another unit?
            if tile.unit and tile.unit ~= unit then
                return false
            end
        end
    end
    
    return true
end
```

**Estimated time:** 2 hours

#### Step 6.3: Movement Range Calculation
**Description:** Update movement range for multi-tile units

**Files to modify:**
- `engine/systems/pathfinding.lua` - Update flood fill

**Considerations:**
- All tiles must be passable
- Movement cost based on most expensive tile
- Cannot fit through 1-tile gaps

**Estimated time:** 2 hours

#### Step 6.4: Rendering Multi-Tile Units
**Description:** Draw larger units properly

**Files to modify:**
- `engine/modules/battlescape.lua` - Update draw() method

**Rendering:**
- 1x1 unit: Circle at center (12px radius)
- 2x2 unit: Larger circle or sprite (42px diameter centered across 2x2 tiles)

**Implementation:**
```lua
function Battlescape:drawUnit(unit)
    local centerX = (unit.x - 1 + unit.stats.size / 2) * TILE_SIZE + self.camera.x
    local centerY = (unit.y - 1 + unit.stats.size / 2) * TILE_SIZE + self.camera.y
    
    local radius = TILE_SIZE * unit.stats.size * 0.4
    love.graphics.circle("fill", centerX, centerY, radius)
end
```

**Estimated time:** 2 hours

---

### Phase 7: Environmental Effects (6 hours)

#### Step 7.1: Smoke System
**Description:** Implement smoke level and effects

**Files to modify:**
- `engine/systems/battle_tile.lua` - Add smoke property
- `engine/systems/line_of_sight.lua` - Smoke increases sight cost

**Smoke mechanics:**
- Level 0-10
- Each level adds +0.3 sight cost
- Smoke dissipates over turns (1 level per turn)
- Grenades/effects can create smoke

**Estimated time:** 2 hours

#### Step 7.2: Fire System
**Description:** Implement fire level and damage

**Files to modify:**
- `engine/systems/battle_tile.lua` - Add fire property
- `engine/modules/battlescape.lua` - Fire damage to units

**Fire mechanics:**
- Level 0-10
- Units on fire tile take damage (1 per level)
- Fire spreads to adjacent tiles (10% chance)
- Fire dissipates over turns (1 level per turn)
- Creates smoke as it burns

**Estimated time:** 2 hours

#### Step 7.3: Ground Objects
**Description:** Implement object list per tile

**Files to modify:**
- `engine/systems/battle_tile.lua` - Add objects array

**Object types:**
- Dropped weapons
- Dropped items
- Corpses
- Debris
- Loot

**Estimated time:** 1 hour

#### Step 7.4: Environmental Rendering
**Description:** Draw smoke, fire, objects

**Files to modify:**
- `engine/modules/battlescape.lua` - Update draw() method

**Rendering:**
- Smoke: Gray overlay (alpha based on level)
- Fire: Orange/red animation
- Objects: Small icons

**Estimated time:** 1 hour

---

### Phase 8: Integration & Polish (10 hours)

#### Step 8.1: Integrate All Systems
**Description:** Connect all systems in battlescape module

**Files to modify:**
- `engine/modules/battlescape.lua` - Wire up all systems

**Integration checklist:**
- Load unit classes from data
- Initialize teams and FOW
- Connect movement to pathfinding
- Connect LOS to FOW
- Connect turn system
- Handle multi-tile units

**Estimated time:** 4 hours

#### Step 8.2: UI Enhancement
**Description:** Improve UI for new features

**Files to modify:**
- `engine/modules/battlescape.lua` - Enhance UI panels

**New UI elements:**
- Unit stat panel (all 12 stats)
- Equipment display (weapons, armour)
- AP/MP display (graphical)
- Team indicator
- Turn order display
- Terrain info on hover

**Estimated time:** 3 hours

#### Step 8.3: Input Handling
**Description:** Complete input system for all features

**Files to modify:**
- `engine/modules/battlescape.lua` - Update input handlers

**Input features:**
- LMB: Select unit / Move unit
- RMB: Rotate unit to direction
- Space: Toggle team view (debug)
- Tab: Cycle through units
- End: End turn
- WASD: Pan camera
- Scroll: Zoom (future)

**Estimated time:** 2 hours

#### Step 8.4: Testing & Bug Fixes
**Description:** Test all features and fix bugs

**Test cases:**
- Unit movement on all terrain types
- LOS with obstacles
- FOW updates correctly
- Multi-tile units don't clip
- Turn system works
- AP/MP calculations correct
- Rotation costs correct
- Team visibility sharing
- Debug view toggle
- Environmental effects

**Estimated time:** 1 hour

---

### Phase 9: Documentation (4 hours)

#### Step 9.1: API Documentation
**Description:** Document all new systems

**Files to update:**
- `wiki/API.md` - Add battlescape systems

**Sections to add:**
- Unit System API
- Movement System API
- Line of Sight API
- Fog of War API
- Turn Manager API
- Pathfinding API

**Estimated time:** 2 hours

#### Step 9.2: Game Mechanics Documentation
**Description:** Document gameplay mechanics

**Files to update:**
- `wiki/FAQ.md` - Add tactical combat section

**Topics:**
- How movement works
- How LOS works
- How FOW works
- How turns work
- Unit stats explained
- Terrain types
- Environmental effects

**Estimated time:** 1 hour

#### Step 9.3: Code Comments
**Description:** Add docstring comments to all functions

**Files to update:**
- All new files in `engine/systems/`
- All new files in `engine/data/`
- Modified sections of `engine/modules/battlescape.lua`

**Estimated time:** 1 hour

---

## Total Estimated Time: 72 hours (9 working days)

---

## Implementation Details

### Architecture

**Modular System Design:**
```
engine/
├── modules/
│   └── battlescape.lua          -- Main battlescape state (coordinator)
├── systems/
│   ├── unit.lua                 -- Unit entity and behavior
│   ├── battle_tile.lua          -- Tile entity
│   ├── team.lua                 -- Team management
│   ├── action_system.lua        -- AP/MP management
│   ├── pathfinding.lua          -- A* pathfinding
│   ├── line_of_sight.lua        -- LOS ray casting
│   ├── fog_of_war.lua           -- FOW tracking
│   └── turn_manager.lua         -- Turn order system
└── data/
    ├── unit_classes.lua         -- Unit class definitions
    ├── weapons.lua              -- Weapon stats
    ├── armours.lua              -- Armour stats
    └── terrain_types.lua        -- Terrain definitions
```

**System Interactions:**
```
Battlescape (coordinator)
    ├── TurnManager (manages turn order)
    │   └── calls → Unit:resetForTurn()
    ├── ActionSystem (handles actions)
    │   ├── uses → Pathfinding
    │   └── updates → Unit AP/MP
    ├── LineOfSight (calculates visibility)
    │   └── uses → BattleTile sight costs
    ├── FogOfWar (tracks visibility)
    │   └── uses → LineOfSight results
    └── Teams (manages unit groups)
        └── owns → Units
```

### Key Components

**Component 1: Unit System**
- Unit entity with stats, equipment, state
- Unit class definitions (data-driven)
- Equipment modification of stats
- Multi-tile unit support (size 1x1, 2x2)

**Component 2: Movement System**
- AP/MP linked mechanics (MP = AP × speed)
- A* pathfinding with terrain costs
- Movement range visualization
- Path preview on hover
- Auto-rotation during movement
- Manual rotation with RMB

**Component 3: Line of Sight**
- Bresenham ray casting algorithm
- Directional 90° cone vision
- Omnidirectional sense range
- Sight cost accumulation
- Last visible tile rendering
- Multi-tile unit LOS calculation

**Component 4: Fog of War**
- Per-team visibility tracking
- Three states: hidden, explored, visible
- Team shared visibility
- Debug team view toggle
- Efficient update (only on action)

**Component 5: Turn System**
- Team-based turn order
- Turn phases (start, action, end)
- AP/MP reset on turn start
- Turn number tracking

**Component 6: Battle Tile**
- Terrain properties (move cost, sight cost)
- Environmental effects (smoke, fire)
- Ground objects list
- Per-team FOW state

### Dependencies

**Love2D Modules:**
- `love.graphics` - Rendering
- `love.mouse` - Input
- `love.keyboard` - Input
- `love.timer` - Delta time

**Game Systems:**
- `StateManager` - State switching
- `widgets` - UI components (if using widget system)
- `UI` - Legacy UI (if not using widgets)

**External Libraries:**
- None required (pure Lua/Love2D)

**Data Files:**
- Unit class definitions
- Weapon definitions
- Armour definitions
- Terrain type definitions

### Performance Considerations

**LOS Optimization:**
- Use Bresenham (integer math only)
- Early exit on blocked tiles
- Cache results until unit moves
- Spatial partitioning for large maps

**Pathfinding Optimization:**
- A* with proper heuristic
- Heap-based priority queue
- Cache movement ranges
- Limit search depth (max 30 tiles)

**FOW Optimization:**
- Only update on actions, not every frame
- Use lookup tables for visibility states
- Batch visibility updates per team

**Rendering Optimization:**
- Only render visible tiles
- Use sprite batches for terrain
- Cache rendered elements
- Frustum culling for off-screen tiles

---

## Testing Strategy

### Unit Tests

**Test 1: Unit Stat Calculation**
- Create unit from class
- Equip weapon and armour
- Verify stats modified correctly

**Test 2: AP/MP Relationship**
- Set AP to 4, speed to 6
- Verify MP = 24
- Spend 12 MP
- Verify AP = 2

**Test 3: Pathfinding**
- Create simple map
- Find path from A to B
- Verify path is optimal
- Verify path respects obstacles

**Test 4: Line of Sight**
- Place unit at position
- Place obstacle
- Calculate LOS
- Verify tiles blocked/visible correctly

**Test 5: Fog of War**
- Create two teams
- Update visibility
- Verify teams have independent FOW
- Verify shared visibility within team

**Test 6: Multi-Tile Units**
- Create 2x2 unit
- Check occupied tiles
- Verify collision detection
- Verify movement range

### Integration Tests

**Test 1: Complete Turn Cycle**
- Start player turn
- Move unit
- End turn
- Verify enemy turn starts
- Verify units reset

**Test 2: Movement with Rotation**
- Select unit
- Move to tile requiring rotation
- Verify MP spent on rotation + movement
- Verify unit faces correct direction

**Test 3: LOS Updates**
- Move unit
- Verify FOW updates
- Verify enemies revealed/hidden correctly
- Verify explored tiles remain visible

**Test 4: Multi-Tile Unit Movement**
- Create 2x2 unit
- Try to move through 1-tile gap (should fail)
- Move to open area (should succeed)
- Verify all tiles updated

**Test 5: Environmental Effects**
- Create smoke on tile
- Verify LOS reduced
- Verify smoke dissipates over turns
- Create fire
- Verify unit takes damage
- Verify fire spreads

### Manual Testing Steps

1. **Launch Game**
   - Run `lovec "engine"` with console enabled
   - Check for initialization messages
   - Verify no errors on startup

2. **Basic Movement**
   - Select player unit (LMB)
   - Verify movement range displayed (very light green)
   - Hover over valid tile
   - Verify path displayed (light green)
   - Click to move
   - Verify unit moves along path
   - Verify unit rotates to face movement direction
   - Verify AP/MP updated correctly

3. **Rotation**
   - Select unit
   - RMB on ground tile in different direction
   - Verify unit rotates to face that direction
   - Verify MP spent (1 per 90°)

4. **Line of Sight**
   - Move unit to position
   - Verify 90° cone visible in facing direction
   - Rotate unit
   - Verify FOW updates immediately
   - Check sense range (omnidirectional 3 tiles)

5. **Fog of War**
   - Move unit to unexplored area
   - Verify new tiles revealed
   - Move unit away
   - Verify tiles become "explored" (dark but visible)
   - Press Space
   - Verify view switches to enemy team
   - Verify enemy FOW different from player

6. **Turn System**
   - End turn (click button or press Space during player turn)
   - Verify turn switches to enemy team
   - Verify all enemy units have full AP/MP
   - End enemy turn
   - Verify turn switches back to player
   - Verify turn number incremented

7. **Multi-Tile Units**
   - Create 2x2 unit
   - Verify renders as larger unit
   - Try to move through 1-tile gap
   - Verify blocked (cannot move)
   - Move to open area
   - Verify movement successful

8. **Environmental Effects**
   - Create smoke on tile (spawn via debug command)
   - Verify smoke overlay visible
   - Verify LOS reduced through smoke
   - Wait several turns
   - Verify smoke dissipates
   - Create fire
   - Move unit onto fire
   - Verify unit takes damage
   - Verify fire spreads to adjacent tiles

9. **UI and Info**
   - Select various units
   - Verify stats displayed correctly
   - Verify equipment shown
   - Verify AP/MP shown
   - Hover over terrain
   - Verify terrain info shown

10. **Performance**
    - Create 30x30 map with 20 units
    - Move units, calculate LOS
    - Verify maintains 60 FPS
    - Check console for warnings
    - Monitor memory usage

### Expected Results

**Performance Targets:**
- FPS: 60 (16.6ms frame time)
- LOS calculation: <5ms per unit
- Pathfinding: <50ms per query
- FOW update: <10ms per team
- Turn transition: <100ms

**Functional Expectations:**
- All movement costs calculated correctly
- LOS accurately reflects terrain and obstacles
- FOW updates only on actions (not every frame)
- Multi-tile units cannot move through gaps
- Environmental effects apply correctly
- Turn system progresses player → enemy → player
- UI displays accurate information
- No memory leaks over 100 turns
- No console errors or warnings

---

## How to Run/Debug

### Running the Game

```bash
lovec "engine"
```

or use the VS Code task: **Run XCOM Simple Game** (Ctrl+Shift+P → Run Task)

or double-click: `run_xcom.bat` in project root

### Debugging

**Console Output:**
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print()` statements liberally for debugging
- Check console window for errors and stack traces

**Debug Commands:**

Add debug key handlers in `battlescape.lua`:

```lua
function Battlescape:keypressed(key)
    if key == "f1" then
        -- Spawn smoke at cursor
        if self.hoveredTile then
            self.map[self.hoveredTile.y][self.hoveredTile.x].effects.smoke = 5
            print("[DEBUG] Spawned smoke at (" .. self.hoveredTile.x .. ", " .. self.hoveredTile.y .. ")")
        end
    elseif key == "f2" then
        -- Spawn fire at cursor
        if self.hoveredTile then
            self.map[self.hoveredTile.y][self.hoveredTile.x].effects.fire = 5
            print("[DEBUG] Spawned fire at (" .. self.hoveredTile.x .. ", " .. self.hoveredTile.y .. ")")
        end
    elseif key == "f3" then
        -- Spawn 2x2 unit at cursor
        if self.hoveredTile then
            local newUnit = {
                id = #self.units + 1,
                name = "Tank " .. #self.units,
                team = "player",
                x = self.hoveredTile.x,
                y = self.hoveredTile.y,
                facing = 0,
                stats = {
                    size = 2,
                    speed = 4,
                    health = 100,
                    maxHealth = 100,
                    sight = 15,
                    sense = 3
                },
                alive = true
            }
            table.insert(self.units, newUnit)
            print("[DEBUG] Spawned 2x2 unit at (" .. self.hoveredTile.x .. ", " .. self.hoveredTile.y .. ")")
        end
    elseif key == "f9" then
        -- Toggle grid overlay
        self.showGrid = not self.showGrid
        print("[DEBUG] Grid overlay: " .. tostring(self.showGrid))
    elseif key == "f10" then
        -- Print debug info
        print("[DEBUG] Units: " .. #self.units)
        print("[DEBUG] Current team: " .. self.currentTurn)
        print("[DEBUG] Turn number: " .. self.turnNumber)
        if self.selectedUnit then
            print("[DEBUG] Selected unit: " .. self.selectedUnit.name .. " AP=" .. self.selectedUnit.actionPointsLeft .. " MP=" .. self.selectedUnit.movementPoints)
        end
    end
end
```

**On-Screen Debug Info:**

Add to `draw()` method:

```lua
-- Draw debug info
love.graphics.setColor(1, 1, 0)
love.graphics.setFont(love.graphics.newFont(12))
local debugY = 50
love.graphics.print("FPS: " .. love.timer.getFPS(), 10, debugY)
debugY = debugY + 15
love.graphics.print("Units: " .. #self.units, 10, debugY)
debugY = debugY + 15
love.graphics.print("Turn: " .. self.turnNumber, 10, debugY)
debugY = debugY + 15
if self.selectedUnit then
    love.graphics.print("Selected: " .. self.selectedUnit.name, 10, debugY)
    debugY = debugY + 15
    love.graphics.print("AP: " .. self.selectedUnit.actionPointsLeft .. "/4", 10, debugY)
    debugY = debugY + 15
    love.graphics.print("MP: " .. self.selectedUnit.movementPoints, 10, debugY)
end
```

**Temporary Files:**
- All temporary files MUST be created in: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- Never create temp files in project directories

**Common Issues:**

1. **LOS not updating:** Check if `updateVisibility()` called after rotation/movement
2. **Movement range wrong:** Verify AP/MP calculation in `calculateMP()`
3. **Units clipping:** Check multi-tile collision detection in `isPassable()`
4. **FOW not showing:** Verify FOW render code uses correct visibility state
5. **Performance slow:** Profile LOS and pathfinding functions, check for infinite loops

---

## Documentation Updates

### Files to Update

- [x] `wiki/API.md` - Add battlescape systems API
  - Unit system functions
  - Movement system functions
  - LOS system functions
  - FOW system functions
  - Turn manager functions
  - Pathfinding functions

- [x] `wiki/FAQ.md` - Add tactical combat section
  - "How does movement work?"
  - "What is the difference between AP and MP?"
  - "How does line of sight work?"
  - "What is fog of war?"
  - "How do turns work?"
  - "What do unit stats mean?"
  - "How do environmental effects work?"

- [x] `wiki/DEVELOPMENT.md` - Add battlescape development notes
  - How to add new unit classes
  - How to add new terrain types
  - How to add new weapons/armour
  - Performance profiling guide
  - Testing checklist

- [x] Code comments - Add inline documentation
  - Docstrings for all public functions
  - Comments for complex algorithms (A*, Bresenham)
  - Comments explaining stat calculations
  - Comments for multi-tile unit handling

---

## Notes

### Design Decisions

**Action Points vs Movement Points:**
- Fixed 4 AP per turn keeps turns predictable
- MP = AP × speed allows speed stat to matter
- Linked system encourages tactical AP spending

**Directional LOS:**
- 90° cone makes facing important
- Encourages flanking and positioning
- Sense range prevents total blindness behind unit

**Team-Based Turns:**
- Simpler than individual initiative
- Allows flexible turn order within team
- Easier to understand for players

**Multi-Tile Units:**
- Only 1x1 and 2x2 sizes (not 3x3, 4x4)
- Simplifies collision detection
- Still allows for variety (soldiers vs tanks)

**Fog of War States:**
- Three states (hidden/explored/visible) match X-COM
- Explored state shows terrain but hides units
- Creates tactical information gathering

### Future Enhancements

**Phase 10 (Future):**
- Combat actions (shoot, throw grenade)
- Reaction fire (overwatch)
- Cover system (half cover, full cover)
- Destructible terrain
- Interactive objects (doors, switches)
- Status effects (stunned, burning, bleeding)
- Inventory management
- Multi-level maps (Z-axis)
- Larger unit sizes (3x3, 4x4)
- Vehicles and ride-able units
- Line of fire vs line of sight
- Sound propagation system

**AI System (Future):**
- Enemy AI for tactical decisions
- Pathfinding to objectives
- Target selection
- Cover seeking behavior
- Flanking maneuvers
- Retreat when outnumbered

**Save System (Future):**
- Save battlefield state
- Resume mid-mission
- Replay system

---

## Blockers

**None currently identified.**

All required systems are implementable with current Love2D 12.0 and Lua 5.1.

**Potential Future Blockers:**
- Performance with maps >50x50 may require optimization
- LOS calculations for >50 units may need spatial partitioning
- Memory usage with large maps may need tile pooling

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written for all systems
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing complete
- [ ] Documentation updated
- [ ] API.md includes all new functions
- [ ] FAQ.md covers new features
- [ ] DEVELOPMENT.md updated
- [ ] Code reviewed by second developer (or AI)
- [ ] No warnings in Love2D console
- [ ] FPS maintains 60 on target hardware
- [ ] LOS calculations <5ms per unit
- [ ] Pathfinding <50ms per query
- [ ] No memory leaks over 100 turns
- [ ] Grid overlay works (F9)
- [ ] All debug keys work (F1-F10)
- [ ] Space toggles team view
- [ ] Multi-tile units render correctly
- [ ] Movement range accurate
- [ ] FOW updates correctly
- [ ] Turn system progresses properly

---

## Post-Completion

### What Worked Well

*(To be filled after implementation)*

### What Could Be Improved

*(To be filled after implementation)*

### Lessons Learned

*(To be filled after implementation)*

---

## Implementation Priority

**Must Have (MVP):**
1. Unit stat system
2. Movement with AP/MP
3. Basic LOS (circular, no directional yet)
4. Basic FOW (player team only)
5. Turn system
6. 1x1 units only

**Should Have (Full Feature):**
7. Directional LOS (90° cone)
8. Per-team FOW
9. Multi-tile units (2x2)
10. Pathfinding (A*)
11. Movement visualization
12. Rotation system

**Nice to Have (Polish):**
13. Environmental effects (smoke, fire)
14. Ground objects
15. Debug team view toggle
16. Enhanced UI
17. Terrain variety

**Future:**
18. Combat actions
19. AI system
20. Save/load

---

## Task Breakdown by System

### System 1: Data Layer (8 hours)
- Unit classes
- Weapons
- Armours
- Terrain types
- Battle tile structure

### System 2: Movement (10 hours)
- AP/MP mechanics
- Pathfinding (A*)
- Movement range
- Path visualization
- Rotation

### System 3: Vision (12 hours)
- LOS ray casting
- Directional cone
- Sight cost system
- Multi-tile LOS

### System 4: Fog of War (8 hours)
- Per-team tracking
- Visibility states
- Team sharing
- Debug toggle

### System 5: Turns (6 hours)
- Turn manager
- Team order
- AP/MP reset
- Turn UI

### System 6: Multi-Tile (8 hours)
- Size property
- Collision detection
- Movement range
- Rendering

### System 7: Environment (6 hours)
- Smoke system
- Fire system
- Ground objects
- Rendering

### System 8: Integration (10 hours)
- Connect all systems
- UI enhancement
- Input handling
- Bug fixes

### System 9: Documentation (4 hours)
- API docs
- Game mechanics docs
- Code comments

**Total: 72 hours**

---

## Success Criteria

This task is successful when:

1. ✅ All unit stats implemented and working
2. ✅ Movement uses AP/MP system correctly
3. ✅ Units can rotate and face directions
4. ✅ LOS calculates 90° directional cone
5. ✅ FOW has three states per team
6. ✅ Teams share visibility
7. ✅ Space toggles team view
8. ✅ Turns cycle through teams properly
9. ✅ 2x2 units work correctly
10. ✅ Environmental effects (smoke, fire) implemented
11. ✅ Performance targets met (60 FPS)
12. ✅ No console errors or warnings
13. ✅ Documentation complete
14. ✅ Tests pass

---

## Next Steps After Completion

1. Implement combat actions (shoot, throw, melee)
2. Add reaction fire system
3. Implement cover system
4. Add destructible terrain
5. Create AI system for enemy turns
6. Add status effects
7. Implement inventory system
8. Create mission objectives
9. Add victory/defeat conditions
10. Build mission generator

---

**END OF TASK DOCUMENT**
