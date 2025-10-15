# Unit System Improvements for 3D Maze Demo

## Current Implementation Analysis

### Current State
- **Enemy Units**: 30 randomly placed enemies stored in `enemyUnits` table
- **Player Units**: 5 controllable units stored in `playerUnits` table
- **Rendering**: Each unit has its own G3D model with separate vertices
- **Duplication**: Similar code for enemy and player unit creation, rendering, and updates
- **Texture Handling**: Enemy and player textures loaded separately but could share
- **No Unit Base Class**: Direct table manipulation without proper OOP structure

### Issues Identified
1. **Code Duplication**: `createEnemyUnit()` and `createPlayerUnit()` are nearly identical
2. **Separate Update Logic**: Enemy and player unit lighting updates are duplicated
3. **No Shared Visual System**: Units recreate vertices and models independently
4. **Inefficient Rendering**: Each unit creates a new G3D model on lighting changes
5. **Limited Unit Properties**: Basic properties only (position, scale, visibility)
6. **No Unit State Management**: No health, actions, or status effects
7. **Hard to Extend**: Adding new unit types requires duplicating code

## Proposed Improvements

### 1. Unified Unit Class System

Create a base `Unit` class that both allies and enemies inherit from:

```lua
-- Base Unit class
local Unit = {}
Unit.__index = Unit

function Unit:new(x, y, z, faction, unitType)
    local unit = setmetatable({}, Unit)
    
    -- Position and orientation
    unit.x = x
    unit.y = y or 0.25  -- Default height
    unit.z = z
    unit.gridX = math.floor(x + 0.5)
    unit.gridY = math.floor(z + 0.5)
    unit.angle = 0  -- Facing direction
    
    -- Visual properties
    unit.scaleX = 1.0
    unit.scaleY = 1.0
    unit.scaleZ = 1.0
    unit.visible = true
    unit.model = nil
    
    -- Unit properties
    unit.faction = faction  -- "player", "enemy", "neutral"
    unit.unitType = unitType  -- "soldier", "alien", "civilian", etc.
    unit.health = 100
    unit.maxHealth = 100
    unit.armor = 0
    
    -- Game state
    unit.isSelected = false
    unit.actionPoints = 2
    unit.maxActionPoints = 2
    unit.hasActed = false
    
    -- Visual customization
    unit.tint = {r = 1, g = 1, b = 1}  -- Default white
    unit.texture = nil  -- Will be set by faction/type
    
    return unit
end

function Unit:updateGridPosition()
    self.gridX = math.floor(self.x + 0.5)
    self.gridY = math.floor(self.z + 0.5)
end

function Unit:setPosition(x, y, z)
    self.x = x
    self.y = y
    self.z = z
    self:updateGridPosition()
    if self.model then
        self.model:setTranslation(x, y, z)
    end
end

function Unit:getFactionColor()
    if self.faction == "player" then
        return {r = 0.3, g = 0.3, b = 1.0}  -- Blue
    elseif self.faction == "enemy" then
        return {r = 1.0, g = 0.3, b = 0.3}  -- Red
    else
        return {r = 0.7, g = 0.7, b = 0.7}  -- Gray for neutral
    end
end

function Unit:isAlive()
    return self.health > 0
end

function Unit:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
    return self:isAlive()
end

function Unit:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
end
```

### 2. Unit Manager System

Centralized management for all units:

```lua
-- Unit Manager
local UnitManager = {
    units = {},  -- All units in the game
    playerUnits = {},  -- References to player units
    enemyUnits = {},   -- References to enemy units
    activeUnit = nil,  -- Currently controlled unit
    selectedUnit = nil -- Unit selected by mouse
}

function UnitManager:addUnit(unit)
    table.insert(self.units, unit)
    
    -- Add to faction-specific list
    if unit.faction == "player" then
        table.insert(self.playerUnits, unit)
    elseif unit.faction == "enemy" then
        table.insert(self.enemyUnits, unit)
    end
    
    return unit
end

function UnitManager:removeUnit(unit)
    -- Remove from main list
    for i, u in ipairs(self.units) do
        if u == unit then
            table.remove(self.units, i)
            break
        end
    end
    
    -- Remove from faction lists
    local factionList = unit.faction == "player" and self.playerUnits or self.enemyUnits
    for i, u in ipairs(factionList) do
        if u == unit then
            table.remove(factionList, i)
            break
        end
    end
end

function UnitManager:getUnitsInRadius(x, z, radius)
    local unitsInRange = {}
    for _, unit in ipairs(self.units) do
        local dx = unit.x - x
        local dz = unit.z - z
        local dist = math.sqrt(dx*dx + dz*dz)
        if dist <= radius then
            table.insert(unitsInRange, {unit = unit, distance = dist})
        end
    end
    return unitsInRange
end

function UnitManager:getVisibleUnits(fromX, fromZ, maxRange)
    local visibleUnits = {}
    for _, unit in ipairs(self.units) do
        if unit.visible and unit:isAlive() then
            local dx = unit.x - fromX
            local dz = unit.z - fromZ
            local dist = math.sqrt(dx*dx + dz*dz)
            
            if dist <= maxRange and hasLineOfSight(fromX, fromZ, unit.x, unit.z) then
                table.insert(visibleUnits, {unit = unit, distance = dist})
            end
        end
    end
    return visibleUnits
end

function UnitManager:updateAll(dt)
    -- Update all units
    for i = #self.units, 1, -1 do
        local unit = self.units[i]
        
        -- Remove dead units
        if not unit:isAlive() then
            self:removeUnit(unit)
        end
    end
end
```

### 3. Shared Rendering System

Single rendering pipeline for all units:

```lua
-- Unit Renderer
local UnitRenderer = {
    sharedTextures = {},  -- Texture cache by unit type
    vertexTemplate = nil, -- Shared vertex structure
    modelCache = {}       -- Cached models by lighting/faction
}

function UnitRenderer:init()
    -- Create shared vertex template (will be copied and modified)
    self.vertexTemplate = {
        {-0.4, 0.75, 0, 0, 0},    -- top left
        {0.4, 0.75, 0, 1, 0},     -- top right
        {0.4, -0.25, 0, 1, 1},    -- bottom right
        {-0.4, -0.25, 0, 0, 1},   -- bottom left
        {-0.4, 0.75, 0, 0, 0},    -- top left (repeat)
        {0.4, -0.25, 0, 1, 1}     -- bottom right (repeat)
    }
    
    -- Load shared textures
    self.sharedTextures["default"] = love.graphics.newImage("tiles/player.png")
    self.sharedTextures["enemy"] = love.graphics.newImage("tiles/enemy.png")
end

function UnitRenderer:loadTexture(name, path)
    if not self.sharedTextures[name] then
        self.sharedTextures[name] = love.graphics.newImage(path)
        print("Loaded shared texture: " .. name)
    end
    return self.sharedTextures[name]
end

function UnitRenderer:createUnitModel(unit, cameraUnit, isNight)
    -- Calculate lighting based on distance
    local dx = unit.x - cameraUnit.x
    local dz = unit.z - cameraUnit.z
    local dist = math.sqrt(dx*dx + dz*dz)
    
    local brightness = self:calculateBrightness(dist, isNight)
    
    -- Apply faction color tint
    local factionColor = unit:getFactionColor()
    local r = brightness * factionColor.r
    local g = brightness * factionColor.g
    local b = brightness * factionColor.b
    
    -- Night effect
    if isNight then
        r = r * 0.7
        g = g * 0.7
    end
    
    -- Create vertices with lighting
    local vertices = {}
    for i, v in ipairs(self.vertexTemplate) do
        vertices[i] = {v[1], v[2], v[3], v[4], v[5], r, g, b, 1.0}
    end
    
    -- Get texture based on faction and type
    local textureName = unit.faction == "enemy" and "enemy" or "default"
    local texture = self.sharedTextures[textureName] or self.sharedTextures["default"]
    
    -- Create G3D model
    return g3d.newModel(
        vertices,
        texture,
        {unit.x, unit.y, unit.z},
        nil,
        {unit.scaleX, unit.scaleY, unit.scaleZ}
    )
end

function UnitRenderer:calculateBrightness(distance, isNight)
    if isNight then
        if distance < 5 then
            return 1.0
        elseif distance < 10 then
            return 1.0 - ((distance - 5) / 5)
        else
            return 0.1
        end
    else
        if distance < 10 then
            return 1.0
        elseif distance < 20 then
            return 1.0 - ((distance - 10) / 10)
        else
            return 0.1
        end
    end
end

function UnitRenderer:updateAllModels(cameraUnit, isNight)
    -- Update models for all units with current lighting
    for _, unit in ipairs(UnitManager.units) do
        if unit.visible and unit:isAlive() then
            unit.model = self:createUnitModel(unit, cameraUnit, isNight)
        end
    end
end

function UnitRenderer:drawUnits(cameraUnit)
    -- Get visible units sorted by distance
    local visibleUnits = UnitManager:getVisibleUnits(cameraUnit.x, cameraUnit.z, 50)
    
    -- Sort by distance (farthest first)
    table.sort(visibleUnits, function(a, b) return a.distance > b.distance end)
    
    -- Draw all visible units
    for _, unitData in ipairs(visibleUnits) do
        local unit = unitData.unit
        
        -- Skip drawing the active camera unit (don't draw self)
        if unit ~= cameraUnit and unit.model then
            unit.model:draw()
        end
    end
end
```

### 4. Factory Pattern for Unit Creation

```lua
-- Unit Factory
local UnitFactory = {}

function UnitFactory.createPlayerSoldier(x, z)
    local unit = Unit:new(x, 0.25, z, "player", "soldier")
    unit.health = 100
    unit.maxHealth = 100
    unit.armor = 20
    unit.actionPoints = 2
    unit.texture = UnitRenderer:loadTexture("player_soldier", "tiles/player.png")
    return unit
end

function UnitFactory.createEnemy(x, z, enemyType)
    local unit = Unit:new(x, 0.25, z, "enemy", enemyType or "alien")
    unit.health = 80
    unit.maxHealth = 80
    unit.armor = 10
    unit.actionPoints = 2
    unit.texture = UnitRenderer:loadTexture("enemy_alien", "tiles/enemy.png")
    return unit
end

function UnitFactory.createCivilian(x, z)
    local unit = Unit:new(x, 0.25, z, "neutral", "civilian")
    unit.health = 50
    unit.maxHealth = 50
    unit.armor = 0
    unit.actionPoints = 1
    unit.texture = UnitRenderer:loadTexture("civilian", "tiles/player.png")
    return unit
end
```

### 5. Integration Example

How to use the new system in `love.load()`:

```lua
function love.load()
    -- Initialize systems
    UnitRenderer:init()
    
    -- Create player units using factory
    local playerPositions = {
        {x = 10, z = 10},
        {x = 50, z = 10},
        {x = 50, z = 50},
        {x = 10, z = 50},
        {x = 30, z = 30}
    }
    
    for _, pos in ipairs(playerPositions) do
        local unit = UnitFactory.createPlayerSoldier(pos.x, pos.z)
        UnitManager:addUnit(unit)
    end
    
    -- Create enemy units
    for i = 1, 30 do
        local x = math.random(5, mazeSize - 5)
        local z = math.random(5, mazeSize - 5)
        
        if isWalkable(maze[z][x].terrain) then
            local enemy = UnitFactory.createEnemy(x, z)
            UnitManager:addUnit(enemy)
        end
    end
    
    -- Set active unit
    UnitManager.activeUnit = UnitManager.playerUnits[1]
    
    -- Update all unit models
    UnitRenderer:updateAllModels(UnitManager.activeUnit, isNight)
end

function love.update(dt)
    UnitManager:updateAll(dt)
    -- ... rest of update logic
end

function love.draw()
    -- ... draw terrain and walls
    
    -- Draw all units with unified system
    UnitRenderer:drawUnits(UnitManager.activeUnit)
    
    -- ... rest of draw logic
end
```

## Benefits of These Improvements

### 1. **Code Reusability**
- Single codebase for all unit types
- Shared rendering pipeline
- Common texture management

### 2. **Maintainability**
- Changes to unit behavior apply to all units
- Single source of truth for unit properties
- Easier debugging and testing

### 3. **Extensibility**
- Easy to add new unit types via factory
- Simple to add new properties (inventory, abilities, etc.)
- Support for different factions and teams

### 4. **Performance**
- Texture caching reduces memory usage
- Efficient batch rendering
- Optimized distance calculations

### 5. **Game Design Flexibility**
- Support for multiple factions
- Easy to implement status effects
- Simple to add unit progression/leveling

### 6. **Better Organization**
- Clear separation of concerns
- Manager pattern for global state
- Renderer pattern for visual logic

## Implementation Roadmap

### Phase 1: Core Refactoring
1. Create `Unit` base class
2. Create `UnitManager` singleton
3. Create `UnitRenderer` module
4. Migrate existing enemy units

### Phase 2: Player Unit Migration
1. Convert player units to use `Unit` class
2. Update camera and control system
3. Test switching between units

### Phase 3: Factory Pattern
1. Implement `UnitFactory`
2. Create unit templates/presets
3. Add unit spawning system

### Phase 4: Enhanced Features
1. Add health bars above units
2. Implement selection indicators
3. Add unit status icons
4. Create minimap unit markers

### Phase 5: Game Mechanics
1. Add turn-based action points
2. Implement combat system
3. Add unit abilities
4. Create inventory system

## Code Quality Guidelines

### Naming Conventions
- Classes: `PascalCase` (e.g., `UnitManager`)
- Functions: `camelCase` (e.g., `updateAllModels`)
- Variables: `camelCase` (e.g., `activeUnit`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_UNITS`)

### Documentation
- Add function documentation with parameters and return values
- Document class properties and their purposes
- Include usage examples for complex systems

### Testing
- Create unit tests for `Unit` class methods
- Test boundary conditions (death, movement limits)
- Verify faction interactions

### Performance Considerations
- Batch unit updates when possible
- Cache frequently accessed data
- Use spatial partitioning for large unit counts
- Profile rendering performance

## Additional Feature Suggestions

### Unit Animations
```lua
function Unit:playAnimation(animName, duration)
    self.currentAnimation = animName
    self.animationTimer = 0
    self.animationDuration = duration
end
```

### Unit Equipment
```lua
function Unit:equipWeapon(weapon)
    self.weapon = weapon
    self.damage = weapon.baseDamage + self.strength
end
```

### Unit Abilities
```lua
function Unit:useAbility(abilityName, target)
    local ability = self.abilities[abilityName]
    if self.actionPoints >= ability.cost then
        ability:execute(self, target)
        self.actionPoints = self.actionPoints - ability.cost
    end
end
```

### Experience System
```lua
function Unit:gainExperience(amount)
    self.experience = self.experience + amount
    if self.experience >= self.nextLevelXP then
        self:levelUp()
    end
end
```

## Conclusion

This refactoring will create a more maintainable, extensible, and efficient unit system. The unified approach reduces code duplication, improves performance through shared resources, and makes it much easier to add new features and unit types in the future. The clear separation of concerns (Unit class for logic, UnitManager for state, UnitRenderer for visuals) follows best practices and will make the codebase more professional and easier to work with.
