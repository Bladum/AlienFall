# Migration Guide: Integrating the New Unit System

This guide shows how to migrate from the current unit system to the new unified `unit_system.lua` module.

## Step 1: Add the Unit System Module

The new `unit_system.lua` file is already created in your project. It provides:
- `Unit` - Base class for all units
- `UnitManager` - Centralized unit management
- `UnitRenderer` - Shared rendering system
- `UnitFactory` - Factory pattern for creating units

## Step 2: Update main.lua - Add Require Statement

At the top of `main.lua`, add:

```lua
local g3d = require "g3d.g3d"
local UnitSystem = require "unit_system"
local Unit = UnitSystem.Unit
local UnitManager = UnitSystem.UnitManager
local UnitRenderer = UnitSystem.UnitRenderer
local UnitFactory = UnitSystem.UnitFactory
```

## Step 3: Replace Global Unit Variables

### OLD CODE (lines ~100-110):
```lua
-- Enemy units system
local enemyUnits = {}
local enemyTexture = nil

-- Player units system (similar to enemy units but controllable)
local playerUnits = {}
local currentPlayerIndex = 1
local playerTexture = nil

-- Get current active player unit
local function getCurrentPlayer()
    return playerUnits[currentPlayerIndex]
end
```

### NEW CODE:
```lua
-- Unit system (now managed by UnitManager)
local enemyTexture = nil  -- Keep for compatibility during migration
local playerTexture = nil  -- Keep for compatibility during migration

-- Get current active player unit (now uses UnitManager)
local function getCurrentPlayer()
    return UnitManager.activeUnit or {x=30, y=0.5, z=30, angle=0, gridX=30, gridY=30}
end
```

## Step 4: Remove Old Unit Creation Functions

### DELETE these functions (lines ~399-430):
```lua
-- Simple enemy unit class
local function createEnemyUnit(x, y, z)
    return {
        x = x,
        y = y,
        z = z,
        gridX = math.floor(x + 0.5),
        gridY = math.floor(z + 0.5),
        model = nil,
        visible = true,
        scaleX = 1.0,
        scaleY = 1.0,
        scaleZ = 1.0
    }
end

-- Simple player unit class (similar to enemy but controllable)
local function createPlayerUnit(x, y, z, angle)
    return {
        x = x,
        y = y,
        z = z,
        angle = angle or 0,
        gridX = math.floor(x + 0.5),
        gridY = math.floor(z + 0.5),
        model = nil,
        visible = true,
        scaleX = 1.0,
        scaleY = 1.0,
        scaleZ = 1.0
    }
end
```

These are replaced by `UnitFactory` functions.

## Step 5: Update love.load() - Initialize New System

### Find this section (around line 1300):
```lua
function love.load()
    -- ... existing code ...
    
    -- Initialize player units (5 units in different locations)
    local playerUnitPositions = {
        {x = 10, z = 10, angle = 0},
        {x = 50, z = 10, angle = math.pi/2},
        {x = 50, z = 50, angle = math.pi},
        {x = 10, z = 50, angle = -math.pi/2},
        {x = 30, z = 30, angle = math.pi/4}
    }
    
    for i, pos in ipairs(playerUnitPositions) do
        -- ... old unit creation code ...
        local playerUnit = createPlayerUnit(finalX, 0.25, finalZ, pos.angle)
        -- ... more old code ...
        table.insert(playerUnits, playerUnit)
    end
```

### REPLACE with:
```lua
function love.load()
    -- ... existing code up to unit initialization ...
    
    -- Initialize new unit system
    UnitManager:init()
    UnitRenderer:init(g3d)
    
    -- Load shared textures
    enemyTexture = love.graphics.newImage("tiles/enemy.png")
    playerTexture = love.graphics.newImage("tiles/player.png")
    
    UnitRenderer:loadTexture("default", "tiles/player.png")
    UnitRenderer:loadTexture("player", "tiles/player.png")
    UnitRenderer:loadTexture("enemy", "tiles/enemy.png")
    
    -- Create player units using factory
    local playerUnitPositions = {
        {x = 10, z = 10, angle = 0},
        {x = 50, z = 10, angle = math.pi/2},
        {x = 50, z = 50, angle = math.pi},
        {x = 10, z = 50, angle = -math.pi/2},
        {x = 30, z = 30, angle = math.pi/4}
    }
    
    for i, pos in ipairs(playerUnitPositions) do
        -- Ensure player unit is placed on a walkable tile
        local finalX, finalZ = pos.x, pos.z
        if not (finalX >= 1 and finalX <= mazeSize and finalZ >= 1 and finalZ <= mazeSize and isWalkable(maze[finalZ][finalX].terrain)) then
            -- Find nearest walkable tile
            local found = false
            for radius = 1, 10 do
                for dx = -radius, radius do
                    for dz = -radius, radius do
                        if math.abs(dx) == radius or math.abs(dz) == radius then
                            local testX = pos.x + dx
                            local testZ = pos.z + dz
                            if testX >= 1 and testX <= mazeSize and testZ >= 1 and testZ <= mazeSize and isWalkable(maze[testZ][testX].terrain) then
                                finalX, finalZ = testX, testZ
                                found = true
                                break
                            end
                        end
                    end
                    if found then break end
                end
                if found then break end
            end
            -- If still no walkable tile found, use default
            if not found then
                finalX, finalZ = 30, 30
            end
        end
        
        -- Create unit using factory
        local playerUnit = UnitFactory.createPlayerSoldier(finalX, finalZ)
        playerUnit.angle = pos.angle
        playerUnit.texture = playerTexture
        UnitManager:addUnit(playerUnit)
    end
    
    -- Initialize enemy units (30 units randomly placed)
    for i = 1, 30 do
        local x, y
        local attempts = 0
        repeat
            x = math.random(5, mazeSize - 5)
            y = math.random(5, mazeSize - 5)
            attempts = attempts + 1
        until (isWalkable(maze[y][x].terrain) and math.random() > 0.5) or attempts > 100
        
        if isWalkable(maze[y][x].terrain) then
            local enemy = UnitFactory.createEnemy(x, y)
            enemy.texture = enemyTexture
            UnitManager:addUnit(enemy)
        end
    end
    
    -- Set up camera using first player unit
    if UnitManager.activeUnit then
        local currentPlayer = UnitManager.activeUnit
        g3d.camera.position = {currentPlayer.x, currentPlayer.y + 0.5, currentPlayer.z}
        g3d.camera.target = {currentPlayer.x + math.sin(currentPlayer.angle), currentPlayer.y + 0.5, currentPlayer.z - math.cos(currentPlayer.angle)}
        g3d.camera.up = {0, 1, 0}
        g3d.camera:updateViewMatrix()
        g3d.camera.fov = math.pi / 3
        g3d.camera.nearClip = 0.01
        g3d.camera.farClip = 10000
    end
    
    -- Update unit models with initial lighting
    UnitRenderer:updateAllModels(UnitManager.activeUnit, isNight)
    
    -- ... rest of love.load ...
end
```

## Step 6: Replace updateEnemyModels() Function

### Find this function (around line 1000):
```lua
function updateEnemyModels()
    local currentPlayer = getCurrentPlayer()
    for _, enemy in ipairs(enemyUnits) do
        -- ... lots of code ...
    end
    
    for _, playerUnit in ipairs(playerUnits) do
        -- ... lots of code ...
    end
end
```

### REPLACE with:
```lua
function updateEnemyModels()
    -- Now handled by unified UnitRenderer
    local currentPlayer = getCurrentPlayer()
    if currentPlayer then
        UnitRenderer:updateAllModels(currentPlayer, isNight)
    end
end
```

This simplifies from ~120 lines to just 5 lines!

## Step 7: Update love.draw() - Use New Renderer

### Find the unit drawing section (around line 2020):
```lua
function love.draw()
    -- ... draw floor, sky, walls ...
    
    -- Draw player units (always visible, sorted by distance)
    local currentPlayer = getCurrentPlayer()
    local sortedPlayerUnits = {}
    for i, playerUnit in ipairs(playerUnits) do
        -- ... sorting code ...
    end
    
    -- ... draw player units ...
    
    -- Draw enemy units sorted by distance
    local sortedEnemies = {}
    for _, enemy in ipairs(enemyUnits) do
        -- ... sorting code ...
    end
    
    -- ... draw enemies ...
```

### REPLACE with:
```lua
function love.draw()
    -- ... draw floor, sky, walls ...
    
    -- Draw all units with unified renderer
    local currentPlayer = getCurrentPlayer()
    if currentPlayer then
        UnitRenderer:drawUnits(currentPlayer, hasLineOfSight)
    end
```

This simplifies from ~60 lines to just 5 lines!

## Step 8: Update Mouse Picking for Enemy Selection

### Find rayIntersectEnemies function (around line 290):
```lua
local function rayIntersectEnemies(rayOrigin, rayDir)
    for _, enemy in ipairs(enemyUnits) do
        -- ... old code ...
    end
end
```

### REPLACE with:
```lua
local function rayIntersectEnemies(rayOrigin, rayDir)
    local closestHit = nil
    local closestT = math.huge
    
    -- Use UnitManager to get all units
    for _, unit in ipairs(UnitManager.units) do
        if unit.visible and unit.model and unit:isAlive() then
            -- ... existing intersection code, but use 'unit' instead of 'enemy' ...
            -- At the end, store: closestHit = {unit = unit, ...}
        end
    end
    
    return closestHit
end
```

### Update updateMousePicking() to use new system:
```lua
local function updateMousePicking()
    local rayOrigin, rayDir = screenToWorldRay(mouseX, mouseY)
    
    -- ... wall checks ...
    
    -- Check unit intersections (renamed from enemy)
    local unitHit = rayIntersectEnemies(rayOrigin, rayDir)
    if unitHit then
        selectedEnemy = unitHit.unit  -- Now works for any unit type
        selectedTile = nil
        return
    end
    
    -- ... rest of function ...
end
```

## Step 9: Update Player Unit Switching

### Find key handling for Tab key (player switching):
```lua
function love.keypressed(key, scancode, isrepeat)
    if key == "tab" then
        -- Switch to next player unit
        currentPlayerIndex = currentPlayerIndex + 1
        if currentPlayerIndex > #playerUnits then
            currentPlayerIndex = 1
        end
        
        -- ... camera update code ...
    end
end
```

### REPLACE with:
```lua
function love.keypressed(key, scancode, isrepeat)
    if key == "tab" then
        -- Switch to next player unit using manager
        UnitManager:nextPlayerUnit()
        
        -- Update camera for new active unit
        local currentPlayer = UnitManager.activeUnit
        if currentPlayer then
            g3d.camera.position = {currentPlayer.x, currentPlayer.y + 0.5, currentPlayer.z}
            g3d.camera.target = {
                currentPlayer.x + math.sin(currentPlayer.angle),
                currentPlayer.y + 0.5,
                currentPlayer.z - math.cos(currentPlayer.angle)
            }
            g3d.camera:updateViewMatrix()
            
            -- Update lighting from new perspective
            updateEnemyModels()
            rebuildModels()
        end
    end
end
```

## Step 10: Update love.update()

Add unit system update:

```lua
function love.update(dt)
    -- Update unit manager
    UnitManager:updateAll(dt)
    
    -- ... rest of existing update code ...
end
```

## Benefits After Migration

### Before:
- Enemy units: ~60 lines of creation code
- Player units: ~80 lines of creation code  
- Update lighting: ~120 lines (duplicated for enemies and players)
- Rendering: ~60 lines (separate for enemies and players)
- **Total: ~320 lines of unit-specific code**

### After:
- Unit creation: ~10 lines using factory
- Update lighting: ~5 lines (calls UnitRenderer)
- Rendering: ~5 lines (calls UnitRenderer)
- **Total: ~20 lines of unit-specific code**

### Reduction: **93% less code** for unit management!

## Additional Features Now Available

### 1. Health System
```lua
-- Damage a unit
local damage, stillAlive = unit:takeDamage(25)

-- Heal a unit
unit:heal(50)

-- Check health percentage
if unit:getHealthPercentage() < 0.3 then
    print("Unit critically wounded!")
end
```

### 2. Action Points (Turn-Based)
```lua
-- Use action points
if unit:hasActionPoints(1) then
    unit:useActionPoint(1)
    -- Perform action
end

-- Reset at end of turn
UnitManager:startNewTurn()
```

### 3. Unit Selection
```lua
-- Select a unit
UnitManager:selectUnit(unit)

-- Get selected unit
if UnitManager.selectedUnit then
    print("Selected:", UnitManager.selectedUnit.name)
end
```

### 4. Spatial Queries
```lua
-- Find units within radius
local nearbyUnits = UnitManager:getUnitsInRadius(x, z, 5)

-- Get visible units
local visibleUnits = UnitManager:getVisibleUnits(x, z, 20, hasLineOfSight)

-- Get unit at grid position
local unit = UnitManager:getUnitAt(gridX, gridY)
```

### 5. Multiple Unit Types
```lua
-- Create different player unit types
local soldier = UnitFactory.createPlayerSoldier(x, z)
local sniper = UnitFactory.createPlayerSniper(x, z)
local heavy = UnitFactory.createPlayerHeavy(x, z)

-- Create different enemy types
local alien = UnitFactory.createEnemy(x, z)
local elite = UnitFactory.createEnemyElite(x, z)

-- Create civilians
local civilian = UnitFactory.createCivilian(x, z)
```

## Testing Checklist

After migration, test:
- [ ] Game starts without errors
- [ ] Player units are visible and rendered correctly
- [ ] Enemy units are visible and rendered correctly
- [ ] Tab key switches between player units
- [ ] Camera follows active player unit
- [ ] Mouse selection highlights units (green boxes)
- [ ] Line of sight works (enemies behind walls are hidden)
- [ ] Day/night lighting affects all units
- [ ] Unit colors show faction (blue for player, red for enemy)

## Troubleshooting

### Units not visible?
Check that textures are loaded:
```lua
print("Player texture:", playerTexture)
print("Enemy texture:", enemyTexture)
```

### Camera not updating?
Ensure `getCurrentPlayer()` returns active unit:
```lua
local currentPlayer = getCurrentPlayer()
print("Active unit:", currentPlayer, currentPlayer.x, currentPlayer.z)
```

### Units all the same color?
Make sure faction is set correctly:
```lua
for _, unit in ipairs(UnitManager.units) do
    print("Unit faction:", unit.faction, "Type:", unit.unitType)
end
```

## Next Steps

After successful migration, you can:
1. Add health bars above units
2. Implement combat system
3. Add unit abilities
4. Create AI for enemy units
5. Add unit movement animations
6. Implement cover system
7. Add unit inventory system

The new unified system makes all of these features much easier to implement!
