-- Unit System Module for 3D Maze Demo
-- Unified management for player units, enemy units, and other entities
-- Follows XCOM-inspired design with turn-based mechanics

local g3d = require "g3d.g3d"

-- ============================================================================
-- Unit Base Class
-- ============================================================================

local Unit = {}
Unit.__index = Unit

function Unit:new(x, y, z, faction, unitType)
    local unit = setmetatable({}, Unit)
    
    -- Position and orientation
    unit.x = x
    unit.y = y or 0.25  -- Default height for sprites
    unit.z = z
    unit.gridX = math.floor(x + 0.5)
    unit.gridY = math.floor(z + 0.5)
    unit.angle = 0  -- Facing direction in radians
    
    -- Visual properties
    unit.scaleX = 1.0
    unit.scaleY = 1.0
    unit.scaleZ = 1.0
    unit.visible = true
    unit.model = nil  -- G3D model for rendering
    
    -- Unit identification
    unit.faction = faction  -- "player", "enemy", "neutral"
    unit.unitType = unitType  -- "soldier", "alien", "civilian", etc.
    unit.name = unitType or "Unit"
    unit.id = tostring(unit)  -- Unique ID
    
    -- Combat stats
    unit.health = 100
    unit.maxHealth = 100
    unit.armor = 0
    unit.damage = 10
    
    -- Turn-based mechanics
    unit.actionPoints = 2
    unit.maxActionPoints = 2
    unit.hasActed = false
    unit.canMove = true
    
    -- Game state
    unit.isSelected = false
    unit.isDead = false
    
    -- Visual customization
    unit.tint = {r = 1, g = 1, b = 1}  -- Base tint color
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
        return {r = 0.3, g = 0.3, b = 1.0}  -- Blue for player
    elseif self.faction == "enemy" then
        return {r = 1.0, g = 0.3, b = 0.3}  -- Red for enemy
    else
        return {r = 0.7, g = 0.7, b = 0.7}  -- Gray for neutral
    end
end

function Unit:isAlive()
    return self.health > 0 and not self.isDead
end

function Unit:takeDamage(amount)
    local actualDamage = math.max(0, amount - self.armor)
    self.health = math.max(0, self.health - actualDamage)
    
    if self.health <= 0 then
        self.isDead = true
    end
    
    return actualDamage, self:isAlive()
end

function Unit:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
end

function Unit:resetActionPoints()
    self.actionPoints = self.maxActionPoints
    self.hasActed = false
    self.canMove = true
end

function Unit:useActionPoint(cost)
    cost = cost or 1
    if self.actionPoints >= cost then
        self.actionPoints = self.actionPoints - cost
        return true
    end
    return false
end

function Unit:hasActionPoints(cost)
    cost = cost or 1
    return self.actionPoints >= cost
end

function Unit:getHealthPercentage()
    return self.health / self.maxHealth
end

-- ============================================================================
-- Unit Manager
-- ============================================================================

local UnitManager = {
    units = {},  -- All units in the game
    playerUnits = {},  -- References to player faction units
    enemyUnits = {},   -- References to enemy faction units
    neutralUnits = {}, -- References to neutral faction units
    activeUnit = nil,  -- Currently controlled unit
    selectedUnit = nil -- Unit selected by mouse/cursor
}

function UnitManager:init()
    self.units = {}
    self.playerUnits = {}
    self.enemyUnits = {}
    self.neutralUnits = {}
    self.activeUnit = nil
    self.selectedUnit = nil
end

function UnitManager:addUnit(unit)
    table.insert(self.units, unit)
    
    -- Add to faction-specific list
    if unit.faction == "player" then
        table.insert(self.playerUnits, unit)
        -- Set first player as active if none set
        if not self.activeUnit then
            self.activeUnit = unit
        end
    elseif unit.faction == "enemy" then
        table.insert(self.enemyUnits, unit)
    else
        table.insert(self.neutralUnits, unit)
    end
    
    return unit
end

function UnitManager:removeUnit(unit)
    -- Remove from main list
    for i = #self.units, 1, -1 do
        if self.units[i] == unit then
            table.remove(self.units, i)
            break
        end
    end
    
    -- Remove from faction lists
    local factionList = self:getFactionList(unit.faction)
    for i = #factionList, 1, -1 do
        if factionList[i] == unit then
            table.remove(factionList, i)
            break
        end
    end
    
    -- Clear references if needed
    if self.activeUnit == unit then
        self.activeUnit = self.playerUnits[1] or nil
    end
    if self.selectedUnit == unit then
        self.selectedUnit = nil
    end
end

function UnitManager:getFactionList(faction)
    if faction == "player" then
        return self.playerUnits
    elseif faction == "enemy" then
        return self.enemyUnits
    else
        return self.neutralUnits
    end
end

function UnitManager:getUnitAt(gridX, gridY)
    for _, unit in ipairs(self.units) do
        if unit:isAlive() and unit.gridX == gridX and unit.gridY == gridY then
            return unit
        end
    end
    return nil
end

function UnitManager:getUnitsInRadius(x, z, radius, excludeUnit)
    local unitsInRange = {}
    for _, unit in ipairs(self.units) do
        if unit ~= excludeUnit and unit:isAlive() then
            local dx = unit.x - x
            local dz = unit.z - z
            local dist = math.sqrt(dx*dx + dz*dz)
            if dist <= radius then
                table.insert(unitsInRange, {unit = unit, distance = dist})
            end
        end
    end
    
    -- Sort by distance
    table.sort(unitsInRange, function(a, b) return a.distance < b.distance end)
    
    return unitsInRange
end

function UnitManager:getVisibleUnits(fromX, fromZ, maxRange, hasLineOfSightFunc)
    local visibleUnits = {}
    for _, unit in ipairs(self.units) do
        if unit.visible and unit:isAlive() then
            local dx = unit.x - fromX
            local dz = unit.z - fromZ
            local dist = math.sqrt(dx*dx + dz*dz)
            
            -- Check if in range and line of sight
            local inLineOfSight = true
            if hasLineOfSightFunc and dist > 0.1 then
                inLineOfSight = hasLineOfSightFunc(fromX, fromZ, unit.x, unit.z)
            end
            
            if dist <= maxRange and inLineOfSight then
                table.insert(visibleUnits, {unit = unit, distance = dist})
            end
        end
    end
    
    return visibleUnits
end

function UnitManager:updateAll(dt)
    -- Update all units and remove dead ones
    for i = #self.units, 1, -1 do
        local unit = self.units[i]
        
        -- Remove dead units (can be delayed for animation)
        if unit.isDead and not unit:isAlive() then
            -- Could add death animation here
            self:removeUnit(unit)
        end
    end
end

function UnitManager:selectUnit(unit)
    -- Deselect current
    if self.selectedUnit then
        self.selectedUnit.isSelected = false
    end
    
    -- Select new
    self.selectedUnit = unit
    if unit then
        unit.isSelected = true
    end
end

function UnitManager:setActiveUnit(unit)
    if unit and unit.faction == "player" then
        self.activeUnit = unit
    end
end

function UnitManager:nextPlayerUnit()
    if #self.playerUnits == 0 then return nil end
    
    local currentIndex = 1
    for i, unit in ipairs(self.playerUnits) do
        if unit == self.activeUnit then
            currentIndex = i
            break
        end
    end
    
    -- Move to next unit
    currentIndex = (currentIndex % #self.playerUnits) + 1
    self.activeUnit = self.playerUnits[currentIndex]
    
    -- Update global currentPlayerIndex for compatibility
    _G.currentPlayerIndex = currentIndex
    
    return self.activeUnit
end

function UnitManager:previousPlayerUnit()
    if #self.playerUnits == 0 then return nil end
    
    local currentIndex = 1
    for i, unit in ipairs(self.playerUnits) do
        if unit == self.activeUnit then
            currentIndex = i
            break
        end
    end
    
    -- Move to previous unit
    currentIndex = currentIndex - 1
    if currentIndex < 1 then
        currentIndex = #self.playerUnits
    end
    self.activeUnit = self.playerUnits[currentIndex]
    
    return self.activeUnit
end

function UnitManager:startNewTurn()
    -- Reset action points for all units
    for _, unit in ipairs(self.units) do
        unit:resetActionPoints()
    end
end

-- ============================================================================
-- Unit Renderer
-- ============================================================================

local UnitRenderer = {
    sharedTextures = {},  -- Texture cache by name
    vertexTemplate = nil, -- Shared vertex structure for billboards
    g3dModule = nil       -- Reference to g3d
}

function UnitRenderer:init(g3dRef)
    self.g3dModule = g3dRef or g3d
    
    -- Create shared vertex template for billboard sprites
    -- Centered at y=0.25 with height of 1.0 unit
    self.vertexTemplate = {
        {-0.4, 0.75, 0, 0, 0},    -- top left
        {0.4, 0.75, 0, 1, 0},     -- top right
        {0.4, -0.25, 0, 1, 1},    -- bottom right
        {-0.4, -0.25, 0, 0, 1},   -- bottom left
        {-0.4, 0.75, 0, 0, 0},    -- top left (repeat for triangle strip)
        {0.4, -0.25, 0, 1, 1}     -- bottom right (repeat)
    }
end

function UnitRenderer:loadTexture(name, path)
    if not self.sharedTextures[name] then
        local success, texture = pcall(love.graphics.newImage, path)
        if success then
            self.sharedTextures[name] = texture
            print("Loaded shared unit texture: " .. name .. " from " .. path)
        else
            print("Warning: Failed to load texture: " .. path)
            return nil
        end
    end
    return self.sharedTextures[name]
end

function UnitRenderer:createUnitModel(unit, cameraUnit, isNight)
    if not unit or not cameraUnit then return nil end
    
    -- Calculate lighting based on distance from camera/active unit
    local dx = unit.x - cameraUnit.x
    local dz = unit.z - cameraUnit.z
    local dist = math.sqrt(dx*dx + dz*dz)
    
    local brightness = self:calculateBrightness(dist, isNight)
    
    -- Apply faction color tint
    local factionColor = unit:getFactionColor()
    local r = brightness * factionColor.r * unit.tint.r
    local g = brightness * factionColor.g * unit.tint.g
    local b = brightness * factionColor.b * unit.tint.b
    
    -- Night effect (reduce red and green)
    if isNight then
        r = r * 0.7
        g = g * 0.7
    end
    
    -- Create vertices with lighting and color
    local vertices = {}
    for i, v in ipairs(self.vertexTemplate) do
        -- Format: x, y, z, u, v, r, g, b, a
        vertices[i] = {v[1], v[2], v[3], v[4], v[5], r, g, b, 1.0}
    end
    
    -- Get texture (use unit's texture or faction default)
    local texture = unit.texture or self.sharedTextures[unit.faction] or self.sharedTextures["default"]
    
    -- Create G3D model
    if texture then
        return self.g3dModule.newModel(
            vertices,
            texture,
            {unit.x, unit.y, unit.z},
            nil,  -- rotation (handled by billboarding)
            {unit.scaleX, unit.scaleY, unit.scaleZ}
        )
    end
    
    return nil
end

function UnitRenderer:calculateBrightness(distance, isNight)
    if isNight then
        -- Night visibility: full up to 5 tiles, fade 5-10, minimum beyond
        if distance < 5 then
            return 1.0
        elseif distance < 10 then
            return 1.0 - ((distance - 5) / 5)
        else
            return 0.1
        end
    else
        -- Day visibility: full up to 10 tiles, fade 10-20, minimum beyond
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
    -- Update models for all visible units with current lighting
    for _, unit in ipairs(UnitManager.units) do
        if unit.visible and unit:isAlive() then
            unit.model = self:createUnitModel(unit, cameraUnit, isNight)
        end
    end
end

function UnitRenderer:drawUnits(cameraUnit, hasLineOfSightFunc)
    if not cameraUnit then return end
    
    -- Get visible units sorted by distance
    local visibleUnits = UnitManager:getVisibleUnits(
        cameraUnit.x, 
        cameraUnit.z, 
        50,  -- Max view range
        hasLineOfSightFunc
    )
    
    -- Sort by distance (farthest first for proper depth rendering)
    table.sort(visibleUnits, function(a, b) return a.distance > b.distance end)
    
    -- Draw all visible units
    for _, unitData in ipairs(visibleUnits) do
        local unit = unitData.unit
        
        -- Skip drawing the active camera unit (don't draw self in first person)
        if unit ~= cameraUnit and unit.model then
            unit.model:draw()
        end
    end
end

function UnitRenderer:drawHealthBar(unit, cameraUnit)
    -- Simple 2D health bar above unit (can be enhanced)
    -- This would require 2D overlay rendering
    -- Placeholder for future implementation
end

-- ============================================================================
-- Unit Factory
-- ============================================================================

local UnitFactory = {}

function UnitFactory.createPlayerSoldier(x, z)
    local unit = Unit:new(x, 0.25, z, "player", "soldier")
    unit.name = "Soldier"
    unit.health = 100
    unit.maxHealth = 100
    unit.armor = 20
    unit.damage = 25
    unit.actionPoints = 2
    unit.maxActionPoints = 2
    return unit
end

function UnitFactory.createPlayerSniper(x, z)
    local unit = Unit:new(x, 0.25, z, "player", "sniper")
    unit.name = "Sniper"
    unit.health = 80
    unit.maxHealth = 80
    unit.armor = 10
    unit.damage = 40
    unit.actionPoints = 2
    unit.maxActionPoints = 2
    return unit
end

function UnitFactory.createPlayerHeavy(x, z)
    local unit = Unit:new(x, 0.25, z, "player", "heavy")
    unit.name = "Heavy"
    unit.health = 120
    unit.maxHealth = 120
    unit.armor = 30
    unit.damage = 20
    unit.actionPoints = 1
    unit.maxActionPoints = 1
    return unit
end

function UnitFactory.createEnemy(x, z, enemyType)
    enemyType = enemyType or "alien"
    local unit = Unit:new(x, 0.25, z, "enemy", enemyType)
    unit.name = "Alien"
    unit.health = 80
    unit.maxHealth = 80
    unit.armor = 10
    unit.damage = 20
    unit.actionPoints = 2
    unit.maxActionPoints = 2
    return unit
end

function UnitFactory.createEnemyElite(x, z)
    local unit = Unit:new(x, 0.25, z, "enemy", "elite")
    unit.name = "Elite Alien"
    unit.health = 120
    unit.maxHealth = 120
    unit.armor = 25
    unit.damage = 30
    unit.actionPoints = 3
    unit.maxActionPoints = 3
    unit.scaleX = 1.2
    unit.scaleY = 1.2
    unit.scaleZ = 1.2
    return unit
end

function UnitFactory.createCivilian(x, z)
    local unit = Unit:new(x, 0.25, z, "neutral", "civilian")
    unit.name = "Civilian"
    unit.health = 50
    unit.maxHealth = 50
    unit.armor = 0
    unit.damage = 0
    unit.actionPoints = 1
    unit.maxActionPoints = 1
    return unit
end

-- ============================================================================
-- Module Exports
-- ============================================================================

return {
    Unit = Unit,
    UnitManager = UnitManager,
    UnitRenderer = UnitRenderer,
    UnitFactory = UnitFactory
}






















