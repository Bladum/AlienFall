-- Battle Tile System
-- Enhanced tile structure for tactical combat

local DataLoader = require("systems.data_loader")
local Assets = require("systems.assets")

local BattleTile = {}
BattleTile.__index = BattleTile

-- Create a new battle tile
function BattleTile.new(terrainId, x, y)
    local self = setmetatable({}, BattleTile)

    self.x = x
    self.y = y

    -- Terrain properties - store both ID and object
    self.terrainId = terrainId or "floor"
    self.terrain = DataLoader.terrainTypes.get(terrainId) or DataLoader.terrainTypes.get("floor")

    -- Random tile variation selection
    self.quadIndex = BattleTile:getRandomQuadIndex(terrainId)

    -- Unit reference (nil if no unit)
    self.unit = nil

    -- Ground objects (weapons, items, corpses, debris)
    self.objects = {}

    -- Environmental effects
    self.effects = {
        smoke = 0,  -- 0-10, reduces visibility
        fire = 0    -- 0-10, damages units
    }

    -- Fog of war per team
    self.fogOfWar = {}  -- {teamId = "hidden"|"explored"|"visible"}

    return self
end

-- Get random quad index for tile variations
function BattleTile:getRandomQuadIndex(terrainId)
    -- Map terrain ID to image name (same logic as in renderer)
    local imageName
    if terrainId == "floor" then
        imageName = "stone floor"
    elseif terrainId == "wall" then
        imageName = "stone wall"
    elseif terrainId == "wood_wall" then
        imageName = "wood wall"
    elseif terrainId == "tree" then
        imageName = "tree"
    elseif terrainId == "road" then
        imageName = "path"
    elseif terrainId == "door" then
        imageName = "stone door close"
    elseif terrainId == "bushes" then
        imageName = "plant small 01"
    else
        imageName = "stone floor" -- default
    end

    -- Check if asset has variations
    local asset = Assets and Assets.images and Assets.images["farmland"] and Assets.images["farmland"][imageName]
    if asset and asset.isTileVariation and asset.quads then
        -- Return random index (1-based)
        return math.random(1, #asset.quads)
    else
        -- No variations, use index 1 (or nil for single images)
        return 1
    end
end

-- Initialize fog of war for teams
function BattleTile:initializeFOW(teams)
    for _, team in ipairs(teams) do
        self.fogOfWar[team.id] = "hidden"
    end
end

-- Update fog of war for a team
function BattleTile:updateFOW(teamId, state)
    self.fogOfWar[teamId] = state
end

-- Get fog of war state for a team
function BattleTile:getFOW(teamId)
    return self.fogOfWar[teamId] or "hidden"
end

-- Check if tile is visible to a team
function BattleTile:isVisible(teamId)
    return self:getFOW(teamId) == "visible"
end

-- Check if tile is hidden from a team
function BattleTile:isHidden(teamId)
    return self:getFOW(teamId) == "hidden"
end

-- Add object to tile
function BattleTile:addObject(object)
    table.insert(self.objects, object)
end

-- Remove object from tile
function BattleTile:removeObject(objectId)
    for i, obj in ipairs(self.objects) do
        if obj.id == objectId then
            table.remove(self.objects, i)
            return true
        end
    end
    return false
end

-- Get objects of specific type
function BattleTile:getObjectsByType(objectType)
    local result = {}
    for _, obj in ipairs(self.objects) do
        if obj.type == objectType then
            table.insert(result, obj)
        end
    end
    return result
end

-- Check if tile blocks movement
function BattleTile:blocksMovement()
    -- Check terrain
    if self.terrain.blocksMovement then
        return true
    end

    -- Check for blocking objects
    for _, obj in ipairs(self.objects) do
        if obj.blocksMovement then
            return true
        end
    end

    return false
end

-- Check if tile blocks sight
function BattleTile:blocksSight()
    -- Check terrain
    if self.terrain.blocksSight then
        return true
    end

    -- Check environmental effects
    if self.effects.smoke >= 5 then
        return true
    end

    -- Check for blocking objects
    for _, obj in ipairs(self.objects) do
        if obj.blocksSight then
            return true
        end
    end

    return false
end

-- Get movement cost for this tile
function BattleTile:getMoveCost()
    local cost = self.terrain.moveCost

    -- Environmental modifiers
    if self.effects.fire > 0 then
        cost = cost + 1  -- Fire makes movement slightly harder
    end

    return cost
end

-- Get cover percentage for this tile
function BattleTile:getCover()
    return self.terrain.cover or 0
end

-- Get sight cost for this tile
function BattleTile:getSightCost()
    local cost = self.terrain.sightCost

    -- Environmental modifiers
    if self.effects.smoke > 0 then
        cost = cost + (self.effects.smoke * 0.3)  -- Each smoke level adds 0.3
    end

    if self.effects.fire > 0 then
        cost = cost + (self.effects.fire * 0.2)  -- Fire slightly reduces visibility
    end

    return cost
end

-- Apply environmental effects to units
function BattleTile:applyEffects(unit)
    if not unit or not unit.alive then return end

    -- Fire damage
    if self.effects.fire > 0 then
        local damage = self.effects.fire
        unit:takeDamage(damage)
        print(string.format("[BattleTile] %s took %d fire damage at (%d,%d)",
              unit.name, damage, self.x, self.y))
    end

    -- Smoke effects (reduced visibility handled in LOS system)
    -- Other effects can be added here
end

-- Update environmental effects
function BattleTile:updateEffects()
    -- Smoke dissipation
    if self.effects.smoke > 0 then
        self.effects.smoke = math.max(0, self.effects.smoke - 1)
    end

    -- Fire spread and dissipation
    if self.effects.fire > 0 then
        -- Chance to spread to adjacent tiles (handled by battlefield)
        -- Dissipate over time
        if math.random() < 0.3 then  -- 30% chance per turn
            self.effects.fire = math.max(0, self.effects.fire - 1)
        end
    end
end

-- Get tile info for debugging
function BattleTile:getDebugInfo()
    local info = string.format("Tile (%d,%d): %s\n", self.x, self.y, self.terrain.name)
    info = info .. string.format("Move Cost: %d, Sight Cost: %.1f\n", self:getMoveCost(), self:getSightCost())

    if self.unit then
        info = info .. string.format("Unit: %s\n", self.unit.name)
    end

    if #self.objects > 0 then
        info = info .. string.format("Objects: %d\n", #self.objects)
    end

    if self.effects.smoke > 0 then
        info = info .. string.format("Smoke: %d\n", self.effects.smoke)
    end

    if self.effects.fire > 0 then
        info = info .. string.format("Fire: %d\n", self.effects.fire)
    end

    info = info .. "FOW: "
    for teamId, state in pairs(self.fogOfWar) do
        info = info .. string.format("%s=%s ", teamId, state)
    end
    info = info .. "\n"

    return info
end

-- Create from legacy tile format (for migration)
function BattleTile.fromLegacy(legacyTile, x, y)
    local terrainId = "floor"  -- Default

    if legacyTile.type == "wall" then
        terrainId = "wall"
    elseif legacyTile.type == "floor" then
        terrainId = "floor"
    end

    local tile = BattleTile.new(terrainId, x, y)
    return tile
end

return BattleTile