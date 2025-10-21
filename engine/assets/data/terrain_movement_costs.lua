---Terrain Movement Costs - Tactical Movement Cost System
---
---Defines movement cost multipliers for different terrain types in tactical combat.
---Used by pathfinding systems to calculate Time Unit (TU) consumption for movement.
---Affects unit mobility, flanking opportunities, and tactical positioning.
---
---Cost Multipliers:
---  - 1.0 = Normal speed (4 TUs per tile)
---  - 2.0 = Half speed (8 TUs per tile)
---  - 4.0 = Quarter speed (16 TUs per tile)
---  - math.huge = Impassable terrain
---
---Terrain Categories:
---  - Normal: Floor, grass, dirt, sand, concrete, metal
---  - Fast: Roads, paths (reduced TU cost)
---  - Slow: Rough terrain, rubble, mud (increased TU cost)
---  - Obstacles: Walls, doors, heavy objects (impassable)
---  - Special: Water, lava, toxic areas (situational)
---
---@module assets.data.terrain_movement_costs
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local costs = require("assets.data.terrain_movement_costs")
---  local moveCost = costs.COSTS.grass  -- Returns 1.0
---  local tuCost = moveCost * 4  -- 4 TUs for grass
---
---@see ai.pathfinding.tactical_pathfinding For TU calculation implementation
---@see battlescape.combat.unit For unit movement mechanics

-- Terrain Movement Costs
-- Defines movement cost multipliers for different terrain types
-- Used by pathfinding system to calculate Time Unit (TU) consumption

local TerrainMovementCosts = {}

--- Movement cost multipliers
--- 1.0 = normal speed (4 TUs per tile)
--- 2.0 = half speed (8 TUs per tile)
--- 4.0 = quarter speed (16 TUs per tile)
--- math.huge = impassable
TerrainMovementCosts.COSTS = {
    -- Normal terrain (1.0 = 4 TUs per tile)
    floor = 1.0,
    grass = 1.0,
    dirt = 1.0,
    sand = 1.0,
    concrete = 1.0,
    metal = 1.0,
    
    -- Fast terrain (0.75 = 3 TUs per tile)
    road = 0.75,
    path = 0.75,
    
    -- Slow terrain (2.0 = 8 TUs per tile)
    rough = 2.0,
    rubble = 2.0,
    gravel = 2.0,
    mud = 2.0,
    
    -- Very slow terrain (4.0 = 16 TUs per tile)
    very_rough = 4.0,
    deep_mud = 4.0,
    water = 4.0,
    swamp = 4.0,
    snow_deep = 4.0,
    
    -- Doors
    door_closed = 2.0,   -- Takes time to open
    door_open = 1.0,     -- Normal passage
    
    -- Impassable terrain
    wall = math.huge,
    rock = math.huge,
    void = math.huge,
    lava = math.huge,
    chasm = math.huge,
    
    -- Special terrain
    ice = 1.5,           -- Slightly slower
    snow = 1.25,         -- Slightly slower
    hill = 1.5,          -- Uphill movement
    stairs_up = 1.5,     -- Climbing
    stairs_down = 1.0,   -- Normal descent
    ramp = 1.25,         -- Gentle slope
    
    -- Hazardous (slow but passable)
    fire = 2.0,          -- Slow due to avoiding flames
    smoke = 1.5,         -- Reduced visibility
    acid = 4.0,          -- Very slow, dangerous
}

--- Get movement cost for a terrain type
-- @param terrainType string Terrain type identifier
-- @return number Movement cost multiplier
function TerrainMovementCosts.getCost(terrainType)
    return TerrainMovementCosts.COSTS[terrainType] or 1.0
end

--- Check if terrain is passable
-- @param terrainType string Terrain type identifier
-- @return boolean True if passable (cost < math.huge)
function TerrainMovementCosts.isPassable(terrainType)
    local cost = TerrainMovementCosts.getCost(terrainType)
    return cost < math.huge
end

--- Calculate TU cost for moving through terrain
-- @param terrainType string Terrain type
-- @param baseTUCost number Base TU cost (default 4)
-- @return number Total TU cost
function TerrainMovementCosts.calculateTUCost(terrainType, baseTUCost)
    baseTUCost = baseTUCost or 4
    local multiplier = TerrainMovementCosts.getCost(terrainType)
    
    if multiplier >= math.huge then
        return math.huge  -- Impassable
    end
    
    return math.ceil(baseTUCost * multiplier)
end

--- Get terrain speed category for UI display
-- @param terrainType string Terrain type
-- @return string Speed category: "fast", "normal", "slow", "very_slow", "impassable"
function TerrainMovementCosts.getSpeedCategory(terrainType)
    local cost = TerrainMovementCosts.getCost(terrainType)
    
    if cost >= math.huge then
        return "impassable"
    elseif cost >= 4.0 then
        return "very_slow"
    elseif cost >= 2.0 then
        return "slow"
    elseif cost >= 1.0 then
        return "normal"
    else
        return "fast"
    end
end

--- Get color for terrain cost visualization
-- @param terrainType string Terrain type
-- @return table RGB color {r, g, b}
function TerrainMovementCosts.getCostColor(terrainType)
    local category = TerrainMovementCosts.getSpeedCategory(terrainType)
    
    local colors = {
        fast = {100, 255, 100},        -- Green
        normal = {200, 200, 200},      -- White/gray
        slow = {255, 255, 100},        -- Yellow
        very_slow = {255, 150, 50},    -- Orange
        impassable = {255, 50, 50}     -- Red
    }
    
    return colors[category] or {255, 255, 255}
end

--- Create a custom terrain cost table
-- @param baseTable table Optional base table to extend
-- @return table New terrain cost table
function TerrainMovementCosts.createCustomTable(baseTable)
    local costs = {}
    
    -- Copy base costs
    for terrain, cost in pairs(TerrainMovementCosts.COSTS) do
        costs[terrain] = cost
    end
    
    -- Apply overrides
    if baseTable then
        for terrain, cost in pairs(baseTable) do
            costs[terrain] = cost
        end
    end
    
    return costs
end

--- Get all terrain types
-- @return table Array of terrain type names
function TerrainMovementCosts.getAllTerrainTypes()
    local types = {}
    for terrainType, _ in pairs(TerrainMovementCosts.COSTS) do
        table.insert(types, terrainType)
    end
    table.sort(types)
    return types
end

--- Unit-specific movement modifier
-- Unit types may have different movement capabilities
TerrainMovementCosts.UNIT_MODIFIERS = {
    infantry = 1.0,      -- Normal movement
    scout = 0.75,        -- Faster movement
    heavy = 1.25,        -- Slower movement
    flying = 0.5,        -- Much faster, ignores terrain
    hovering = 0.75,     -- Faster, reduced terrain impact
}

--- Get movement cost for a specific unit type
-- @param terrainType string Terrain type
-- @param unitType string Unit type
-- @return number Effective movement cost
function TerrainMovementCosts.getCostForUnit(terrainType, unitType)
    local baseCost = TerrainMovementCosts.getCost(terrainType)
    local unitModifier = TerrainMovementCosts.UNIT_MODIFIERS[unitType] or 1.0
    
    -- Flying units ignore most terrain
    if unitType == "flying" then
        if baseCost >= math.huge then
            return math.huge  -- Still can't pass through walls
        else
            return 0.5  -- Fast movement
        end
    end
    
    return baseCost * unitModifier
end

return TerrainMovementCosts

























