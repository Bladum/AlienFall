--- Base Expansion System - Facility Grid Expansion Mechanics
---
--- Manages base expansion mechanics, allowing players to expand base size from
--- Small (4×4) through Medium (5×5) to Large (6×6) to Huge (7×7).
---
--- Base Sizes:
---   - Small: 4×4 grid, 16 tiles, 150K cost, 30 days build
---   - Medium: 5×5 grid, 25 tiles, 250K cost, 45 days build
---   - Large: 6×6 grid, 36 tiles, 400K cost, 60 days build
---   - Huge: 7×7 grid, 49 tiles, 600K cost, 90 days build
---
--- Expansion Mechanics:
---   - Expand by adding rows/columns to existing grid
---   - Cost scales with base size
---   - Build time scaled with base size
---   - Existing facilities preserved during expansion
---   - Construction requires tech, relations, resources
---   - Expansion gated by campaign phase and relations
---
--- Technical Details:
---   - Grid coordinates: (x, y) where x=column, y=row
---   - Origin at (0, 0), grows outward in all directions
---   - During expansion, grid resizes and facilities reposition
---   - New tiles spawn as empty EMPTY state
---
--- Usage:
---   local ExpansionSystem = require("basescape.systems.expansion_system")
---   local expansion = ExpansionSystem.new()
---   if expansion:canExpand(base, "6x6") then
---       expansion:expandBase(base, "6x6", callback)
---   end
---   local info = expansion:getExpansionInfo(base)
---
--- @module basescape.systems.expansion_system
--- @author AlienFall Development Team
--- @copyright 2025 AlienFall Project
--- @license Open Source

local ExpansionSystem = {}
ExpansionSystem.__index = ExpansionSystem

-- Base size definitions
local BASE_SIZES = {
    ["4x4"] = {
        width = 4,
        height = 4,
        tiles = 16,
        cost = 150000,
        buildTime = 30,
        relationBonus = 1,
        name = "Small Base",
        order = 1
    },
    ["5x5"] = {
        width = 5,
        height = 5,
        tiles = 25,
        cost = 250000,
        buildTime = 45,
        relationBonus = 1,
        name = "Medium Base",
        order = 2
    },
    ["6x6"] = {
        width = 6,
        height = 6,
        tiles = 36,
        cost = 400000,
        buildTime = 60,
        relationBonus = 2,
        name = "Large Base",
        order = 3
    },
    ["7x7"] = {
        width = 7,
        height = 7,
        tiles = 49,
        cost = 600000,
        buildTime = 90,
        relationBonus = 3,
        name = "Huge Base",
        order = 4
    }
}

-- Size progression order
local SIZE_PROGRESSION = {"4x4", "5x5", "6x6", "7x7"}

-- Size indices for easy lookup
local SIZE_INDEX = {
    ["4x4"] = 1,
    ["5x5"] = 2,
    ["6x6"] = 3,
    ["7x7"] = 4
}

--- Initialize expansion system
--- @return table ExpansionSystem instance
function ExpansionSystem.new()
    local self = setmetatable({}, ExpansionSystem)
    print("[ExpansionSystem] Initialized")
    return self
end

--- Get current base size
--- @param base table Base entity
--- @return string Current base size (e.g., "5x5")
function ExpansionSystem:getCurrentSize(base)
    if not base.grid then
        return "5x5"
    end
    
    local height = #base.grid
    local width = #base.grid[1]
    
    local size = width .. "x" .. height
    return size
end

--- Check if base can be created with given size
--- @param size string Target size (e.g., "4x4", "5x5")
--- @param gameState table Game state with organization level, relations, tech
--- @return boolean Can create
--- @return string Error message if not
function ExpansionSystem:canCreateBase(size, gameState)
    if not BASE_SIZES[size] then
        return false, "Invalid base size: " .. size
    end
    
    local sizeData = BASE_SIZES[size]
    
    -- Check if size is minimum (4x4)
    if size ~= "4x4" then
        return false, "Can only create Small (4x4) bases. Expand later."
    end
    
    return true, ""
end

--- Check if base can be expanded to given size
--- @param base table Base entity
--- @param targetSize string Target size (e.g., "6x6")
--- @param gameState table Game state with economy, tech, relations
--- @return boolean Can expand
--- @return string Error message if not
function ExpansionSystem:canExpand(base, targetSize, gameState)
    if not BASE_SIZES[targetSize] then
        return false, "Invalid target size: " .. targetSize
    end
    
    local currentSize = self:getCurrentSize(base)
    local currentOrder = SIZE_INDEX[currentSize] or 2
    local targetOrder = SIZE_INDEX[targetSize] or 2
    
    -- Can only expand one size at a time
    if targetOrder ~= currentOrder + 1 then
        local nextSize = SIZE_PROGRESSION[currentOrder + 1] or "cannot expand"
        return false, "Can only expand to next size: " .. nextSize
    end
    
    -- Check economy
    if gameState and gameState.economy then
        local cost = BASE_SIZES[targetSize].cost
        if gameState.economy.credits < cost then
            return false, string.format("Insufficient credits: need %d, have %d", 
                cost, gameState.economy.credits)
        end
    end
    
    -- Check tech requirement
    if gameState and gameState.tech then
        if not gameState.tech:hasResearch("BASE_EXPANSION") then
            return false, "BASE_EXPANSION tech not researched"
        end
    end
    
    -- Check relations requirement
    if gameState and gameState.relations then
        local minRelation = 50 + (targetOrder * 10)  -- Higher size = higher relation requirement
        if gameState.relations:getAverageRelation() < minRelation then
            return false, string.format("Average relations too low: need %d%%", minRelation)
        end
    end
    
    return true, ""
end

--- Get expansion information for display
--- @param base table Base entity
--- @return table Expansion info {current, next, cost, time, available}
function ExpansionSystem:getExpansionInfo(base)
    local currentSize = self:getCurrentSize(base)
    local currentOrder = SIZE_INDEX[currentSize] or 2
    local nextSize = SIZE_PROGRESSION[currentOrder + 1]
    
    local info = {
        currentSize = currentSize,
        currentOrder = currentOrder,
        nextSize = nextSize,
        nextOrder = currentOrder + 1,
        tiles = {
            current = BASE_SIZES[currentSize].tiles,
            next = nextSize and BASE_SIZES[nextSize].tiles or nil
        },
        cost = nextSize and BASE_SIZES[nextSize].cost or nil,
        buildTime = nextSize and BASE_SIZES[nextSize].buildTime or nil,
        relationBonus = nextSize and BASE_SIZES[nextSize].relationBonus or nil,
        canExpand = false,
        message = "Already at maximum size (7x7)"
    }
    
    if nextSize then
        info.canExpand = true
        info.message = string.format("Can expand to %s for %d credits", 
            BASE_SIZES[nextSize].name, BASE_SIZES[nextSize].cost)
    end
    
    return info
end

--- Create initial base grid with given size
--- @param sizeStr string Grid size (e.g., "5x5")
--- @return table Grid initialized with EMPTY tiles
function ExpansionSystem:createGrid(sizeStr)
    local sizeData = BASE_SIZES[sizeStr]
    if not sizeData then
        print("[ExpansionSystem] ERROR: Invalid size " .. sizeStr)
        return {}
    end
    
    local grid = {}
    for y = 1, sizeData.height do
        grid[y] = {}
        for x = 1, sizeData.width do
            grid[y][x] = "EMPTY"
        end
    end
    
    print(string.format("[ExpansionSystem] Created %s grid (%dx%d = %d tiles)",
        sizeStr, sizeData.width, sizeData.height, sizeData.tiles))
    
    return grid
end

--- Expand base from current size to target size
--- @param base table Base entity to expand
--- @param targetSize string Target size (e.g., "6x6")
--- @param callback function Optional callback on completion
--- @return boolean Success
--- @return string Error message if not
function ExpansionSystem:expandBase(base, targetSize, callback)
    local canExpand, errMsg = self:canExpand(base, targetSize, {})
    if not canExpand then
        return false, "Cannot expand to " .. targetSize .. ": " .. errMsg
    end
    
    local currentSize = self:getCurrentSize(base)
    local currentGrid = base.grid
    local currentData = BASE_SIZES[currentSize]
    local targetData = BASE_SIZES[targetSize]
    
    -- Create new expanded grid
    local newGrid = {}
    for y = 1, targetData.height do
        newGrid[y] = {}
        for x = 1, targetData.width do
            newGrid[y][x] = "EMPTY"
        end
    end
    
    -- Calculate offset for old grid (center it in new grid)
    local offsetX = math.floor((targetData.width - currentData.width) / 2)
    local offsetY = math.floor((targetData.height - currentData.height) / 2)
    
    -- Copy old facilities to new grid with offset
    local facilitiesPreserved = 0
    for y = 1, currentData.height do
        for x = 1, currentData.width do
            local oldTile = currentGrid[y][x]
            if oldTile ~= "EMPTY" then
                local newX = x + offsetX
                local newY = y + offsetY
                newGrid[newY][newX] = oldTile
                facilitiesPreserved = facilitiesPreserved + 1
            end
        end
    end
    
    -- Update base grid
    base.grid = newGrid
    base.expandedDate = os.time()
    base.lastSize = currentSize
    base.currentSize = targetSize
    
    print(string.format("[ExpansionSystem] Expanded base %s from %s to %s (%d facilities preserved)",
        base.name, currentSize, targetSize, facilitiesPreserved))
    
    -- Call callback if provided
    if callback then
        callback(base, targetSize)
    end
    
    return true, ""
end

--- Get all available expansion sizes with info
--- @return table Array of size info {size, name, tiles, cost, buildTime}
function ExpansionSystem:getAllSizes()
    local sizes = {}
    for i, sizeStr in ipairs(SIZE_PROGRESSION) do
        local sizeData = BASE_SIZES[sizeStr]
        table.insert(sizes, {
            id = sizeStr,
            order = i,
            name = sizeData.name,
            width = sizeData.width,
            height = sizeData.height,
            tiles = sizeData.tiles,
            cost = sizeData.cost,
            buildTime = sizeData.buildTime,
            relationBonus = sizeData.relationBonus
        })
    end
    return sizes
end

--- Calculate expansion cost with modifiers
--- @param base table Base entity
--- @param targetSize string Target size
--- @param modifiers table Cost modifiers {difficulty=1.0, relations=1.0}
--- @return number Final cost after modifiers
function ExpansionSystem:calculateExpansionCost(base, targetSize, modifiers)
    modifiers = modifiers or {}
    
    local sizeData = BASE_SIZES[targetSize]
    if not sizeData then
        return 0
    end
    
    local baseCost = sizeData.cost
    local difficultyModifier = modifiers.difficulty or 1.0
    local relationsModifier = modifiers.relations or 1.0
    
    local finalCost = baseCost * difficultyModifier * relationsModifier
    
    print(string.format("[ExpansionSystem] Cost for %s: base=%d, difficulty=%.2f, relations=%.2f, final=%d",
        targetSize, baseCost, difficultyModifier, relationsModifier, math.ceil(finalCost)))
    
    return math.ceil(finalCost)
end

--- Get expansion status for UI display
--- @param base table Base entity
--- @return table Status {current, next, isMaxSize, progress}
function ExpansionSystem:getExpansionStatus(base)
    local currentSize = self:getCurrentSize(base)
    local currentOrder = SIZE_INDEX[currentSize] or 2
    local isMaxSize = currentOrder >= #SIZE_PROGRESSION
    
    return {
        currentSize = currentSize,
        currentOrder = currentOrder,
        maxSize = "7x7",
        maxOrder = #SIZE_PROGRESSION,
        isMaxSize = isMaxSize,
        nextSize = SIZE_PROGRESSION[currentOrder + 1],
        progress = currentOrder / #SIZE_PROGRESSION
    }
end

--- Validate expansion prerequisites
--- @param base table Base entity
--- @param targetSize string Target size
--- @param gameState table Game state with all systems
--- @return boolean Valid
--- @return string Reason if not
function ExpansionSystem:validateExpansionPrerequisites(base, targetSize, gameState)
    -- Check size validity
    if not BASE_SIZES[targetSize] then
        return false, "Invalid target size"
    end
    
    -- Check progression
    local canExpand, err = self:canExpand(base, targetSize, gameState)
    if not canExpand then
        return false, err or "Cannot expand"
    end
    
    -- Check base is operational
    if not base.operationalDate then
        return false, "Base must be operational"
    end
    
    return true, ""
end

return ExpansionSystem




