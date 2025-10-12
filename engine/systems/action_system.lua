-- Action System
-- Manages Action Points (AP) and Movement Points (MP) for units

local HexMath = require("battle.utils.hex_math")

local ActionSystem = {}
ActionSystem.__index = ActionSystem

-- Constants
ActionSystem.AP_PER_TURN = 4  -- Fixed AP per unit per turn

-- Movement costs (MP) - removed rotation cost
ActionSystem.MOVEMENT_COSTS = {
    MOVE_NORMAL = 2,    -- Normal tile movement
    MOVE_ROUGH = 4,     -- Rough terrain
    MOVE_SLOPE = 6,     -- Slope/elevation change
}

-- Create action system
function ActionSystem.new()
    local self = setmetatable({}, ActionSystem)
    return self
end

-- Reset unit for new turn
function ActionSystem:resetUnit(unit)
    unit.actionPointsLeft = ActionSystem.AP_PER_TURN
    unit.movementPoints = unit:calculateMP()
    unit.hasActed = false
    print(string.format("[ActionSystem] Reset %s: AP=%d, MP=%d",
          unit.name, unit.actionPointsLeft, unit.movementPoints))
end

-- Spend action points
function ActionSystem:spendAP(unit, amount)
    if unit.actionPointsLeft >= amount then
        unit:spendAP(amount)
        print(string.format("[ActionSystem] %s spent %d AP, remaining: AP=%d, MP=%d",
              unit.name, amount, unit.actionPointsLeft, unit.movementPoints))
        return true
    end
    return false
end

-- Spend movement points
function ActionSystem:spendMP(unit, amount)
    if unit.movementPoints >= amount then
        unit:spendMP(amount)
        print(string.format("[ActionSystem] %s spent %d MP, remaining: AP=%d, MP=%d",
              unit.name, amount, unit.actionPointsLeft, unit.movementPoints))
        return true
    end
    return false
end

-- Check if unit can perform action requiring AP
function ActionSystem:canSpendAP(unit, amount)
    return unit.actionPointsLeft >= amount
end

-- Check if unit can spend MP
function ActionSystem:canSpendMP(unit, amount)
    return unit.movementPoints >= amount
end

-- Calculate movement cost between two adjacent tiles
function ActionSystem:calculateMovementCost(unit, fromTile, toTile, battlefield)
    if not fromTile or not toTile then return 0 end

    -- Convert to axial coordinates for hex distance check
    local fromQ, fromR = HexMath.offsetToAxial(fromTile.x, fromTile.y)
    local toQ, toR = HexMath.offsetToAxial(toTile.x, toTile.y)
    
    -- Must be adjacent (hex distance = 1)
    local distance = HexMath.distance(fromQ, fromR, toQ, toR)
    if distance > 1 then return 0 end

    -- Check for fire - blocks movement completely
    if toTile.effects and toTile.effects.fire then
        return 0  -- Impassable - fire blocks movement
    end

    -- Get terrain cost
    local terrainCost = toTile:getMoveCost()

    -- Check for unit collision (can't move through other units)
    if toTile.unit and toTile.unit ~= unit then
        return 0  -- Impassable
    end

    -- Check if multi-tile unit can fit
    if unit.stats.size > 1 then
        -- For multi-tile units, check all tiles they would occupy
        for oy = 0, unit.stats.size - 1 do
            for ox = 0, unit.stats.size - 1 do
                local checkX = toTile.x + ox
                local checkY = toTile.y + oy

                -- Out of bounds?
                if checkX < 1 or checkX > battlefield.mapWidth or
                   checkY < 1 or checkY > battlefield.mapHeight then
                    return 0  -- Can't move out of bounds
                end

                local checkTile = battlefield.map[checkY][checkX]
                
                -- Fire blocks movement
                if checkTile.effects and checkTile.effects.fire then
                    return 0  -- Impassable - fire blocks movement
                end

                -- Terrain must be passable
                if checkTile:getMoveCost() == 0 then
                    return 0  -- Impassable terrain
                end

                -- No other units in the way
                if checkTile.unit and checkTile.unit ~= unit then
                    return 0  -- Blocked by unit
                end
            end
        end
    end

    return terrainCost
end

-- Attempt to move unit along path
function ActionSystem:moveUnitAlongPath(unit, path, battlefield, animationSystem, onVisibilityUpdate)
    if not path or #path < 2 then return false end

    local totalCost = 0

    -- Calculate total movement cost (no rotation costs)
    for i = 1, #path - 1 do
        local fromTile = battlefield:getTile(path[i].x, path[i].y)
        local toTile = battlefield:getTile(path[i + 1].x, path[i + 1].y)

        if not fromTile or not toTile then
            print("[ActionSystem] Invalid path: tile not found")
            return false
        end

        local moveCost = self:calculateMovementCost(unit, fromTile, toTile, battlefield)
        if moveCost == 0 then
            print("[ActionSystem] Invalid path: impassable tile")
            return false
        end

        totalCost = totalCost + moveCost
    end

    -- Check if unit has enough MP
    if not self:canSpendMP(unit, totalCost) then
        print(string.format("[ActionSystem] Not enough MP: need %d, have %d", totalCost, unit.movementPoints))
        return false
    end

    -- Spend MP
    self:spendMP(unit, totalCost)

    -- Use animation system for per-tile movement
    if animationSystem then
        -- Start path-based movement animation
        animationSystem:startPathMovement(unit, path, 
            function(unit, tileX, tileY) 
                -- Called when unit reaches each tile
                self:updateUnitPosition(unit, tileX, tileY, battlefield)
                -- Note: Visibility update removed - only update when movement completes
            end,
            function()
                -- Animation complete callback
                self:completeUnitMovement(unit, path[#path].x, path[#path].y, battlefield)
                -- Update visibility after movement completes
                if onVisibilityUpdate then
                    onVisibilityUpdate()
                end
            end
        )
        
        print(string.format("[ActionSystem] Started path-based animated movement for %s (%d tiles), cost %d MP",
              unit.name, #path - 1, totalCost))
        return true
    else
        -- Fallback to instant movement if no animation system
        self:completeUnitMovement(unit, path[#path].x, path[#path].y, battlefield)
        print(string.format("[ActionSystem] %s moved to (%d,%d), cost %d MP",
              unit.name, path[#path].x, path[#path].y, totalCost))
        return true
    end
end

-- Complete unit movement (called after animation finishes)
function ActionSystem:completeUnitMovement(unit, finalX, finalY, battlefield)
    -- Remove unit from old tiles
    for _, tile in ipairs(unit:getOccupiedTiles()) do
        local oldTile = battlefield:getTile(tile.x, tile.y)
        if oldTile then
            oldTile.unit = nil
        end
    end

    -- Update unit position (no facing)
    unit:moveTo(finalX, finalY)

    -- Place unit on new tiles
    for _, tile in ipairs(unit:getOccupiedTiles()) do
        local newTile = battlefield:getTile(tile.x, tile.y)
        if newTile then
            newTile.unit = unit
        end
    end

    print(string.format("[ActionSystem] %s movement completed to (%d,%d)",
          unit.name, finalX, finalY))
end

-- Update unit position during movement (called for each tile)
function ActionSystem:updateUnitPosition(unit, tileX, tileY, battlefield)
    -- Update unit's logical position (but don't update battlefield tiles yet)
    unit.x = tileX
    unit.y = tileY
    
    -- Update animation position to match
    unit.animX = tileX
    unit.animY = tileY
    
    print(string.format("[ActionSystem] %s position updated to (%d,%d) during movement",
          unit.name, tileX, tileY))
end

-- Attempt rotation
function ActionSystem:rotateUnit(unit, targetFacing)
    local cost = self:calculateRotationCost(unit.facing, targetFacing)

    if self:canSpendMP(unit, cost) then
        self:spendMP(unit, cost)
        unit.facing = targetFacing
        print(string.format("[ActionSystem] %s rotated to facing %d, cost %d MP",
              unit.name, targetFacing, cost))
        return true
    end

    return false
end

-- Rotate unit with animation
function ActionSystem:rotateUnitAnimated(unit, targetFacing, animationSystem, onComplete)
    local cost = self:calculateRotationCost(unit.facing, targetFacing)

    if self:canSpendMP(unit, cost) then
        self:spendMP(unit, cost)
        
        -- Start rotation animation
        if animationSystem then
            animationSystem:startRotation(unit, targetFacing, function()
                -- Update LOS after rotation completes
                if onComplete then
                    onComplete()
                end
            end)
        else
            -- No animation system, rotate immediately
            unit.facing = targetFacing
            unit.animFacing = targetFacing
            if onComplete then
                onComplete()
            end
        end
        
        print(string.format("[ActionSystem] %s started rotation to facing %d, cost %d MP",
              unit.name, targetFacing, cost))
        return true
    end

    return false
end

-- Calculate total cost of a path including movement and rotations
function ActionSystem:calculatePathCost(unit, path, battlefield)
    if not path or #path < 2 then return 0 end

    local totalCost = 0
    local currentFacing = unit.facing

    -- Calculate total movement cost
    for i = 1, #path - 1 do
        local fromTile = battlefield:getTile(path[i].x, path[i].y)
        local toTile = battlefield:getTile(path[i + 1].x, path[i + 1].y)

        if not fromTile or not toTile then
            return math.huge  -- Invalid path
        end

        local moveCost = self:calculateMovementCost(unit, fromTile, toTile, battlefield)
        if moveCost == 0 then
            return math.huge  -- Impassable
        end

        totalCost = totalCost + moveCost

        -- Calculate facing for this move
        local dx = toTile.x - fromTile.x
        local dy = toTile.y - fromTile.y
        local targetFacing = unit:getFacingFromDirection(dx, dy)

        -- Add rotation cost if needed
        if targetFacing ~= currentFacing then
            local rotateCost = self:calculateRotationCost(currentFacing, targetFacing)
            totalCost = totalCost + rotateCost
            currentFacing = targetFacing
        end
    end

    return totalCost
end

-- Get movement range for unit (flood fill)
function ActionSystem:calculateMovementRange(unit, battlefield, team)
    if not unit or not unit.x or not unit.y then
        print("[ActionSystem] ERROR: Invalid unit or coordinates")
        return {}
    end
    
    local range = {}
    local visited = {}
    local queue = {}

    -- Initialize with unit's current position (convert to axial coordinates)
    local startQ, startR = HexMath.offsetToAxial(unit.x, unit.y)
    if not startQ or not startR then
        print(string.format("[ActionSystem] ERROR: offsetToAxial returned nil for (%d, %d)", unit.x, unit.y))
        return {}
    end
    local startKey = string.format("%d,%d", startQ, startR)
    visited[startKey] = true
    table.insert(queue, {q = startQ, r = startR, cost = 0})

    while #queue > 0 do
        local current = table.remove(queue, 1)

        -- Add to range if not starting position
        if current.cost > 0 then
            local col, row = HexMath.axialToOffset(current.q, current.r)
            table.insert(range, {x = col, y = row, cost = current.cost})
        end

        -- Check hex neighbors
        local neighbors = HexMath.getNeighbors(current.q, current.r)
        for _, neighbor in ipairs(neighbors) do
            local neighborCol, neighborRow = HexMath.axialToOffset(neighbor.q, neighbor.r)
            if neighborCol and neighborRow then
                local key = string.format("%d,%d", neighbor.q, neighbor.r)
                if not visited[key] then
                    -- Check fog of war - can only move to explored tiles
                    if team and team:isTileExplored(neighborCol, neighborRow) then
                        -- Get the target tile
                        local targetTile = battlefield:getTile(neighborCol, neighborRow)
                        
                        -- Calculate actual movement cost (checks terrain and unit collision)
                        local currentCol, currentRow = HexMath.axialToOffset(current.q, current.r)
                        local moveCost = self:calculateMovementCost(unit, battlefield:getTile(currentCol, currentRow), targetTile, battlefield)
                        
                        if moveCost > 0 then
                            local newCost = current.cost + moveCost
                            
                            if newCost <= unit.movementPoints then
                                visited[key] = true
                                table.insert(queue, {
                                    q = neighbor.q, 
                                    r = neighbor.r, 
                                    x = neighborCol,
                                    y = neighborRow,
                                    cost = newCost
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    return range
end

-- Get debug info
function ActionSystem:getDebugInfo()
    local info = "Action System:\n"
    info = info .. string.format("AP per turn: %d\n", ActionSystem.AP_PER_TURN)
    info = info .. "Movement costs:\n"
    for name, cost in pairs(ActionSystem.MOVEMENT_COSTS) do
        info = info .. string.format("  %s: %s\n", name, tostring(cost))
    end
    return info
end

return ActionSystem