---ActionSystem - Action and Movement Point Management
---
---Manages Action Points (AP) and Movement Points (MP) for units in tactical combat.
---Handles point allocation, spending, restoration, and validation. Core system for
---turn-based tactical gameplay in the battlescape layer.
---
---Features:
---  - Fixed AP per turn (4 AP per unit)
---  - Movement point (MP) tracking and spending
---  - Movement cost calculation by terrain type
---  - AP/MP validation before actions
---  - Point restoration at turn end
---  - Cost modifiers (encumbrance, injury)
---
---Action Points (AP):
---  - Fixed allocation: 4 AP per unit per turn
---  - Used for: Shooting, reloading, crouching, using items
---  - Cannot be carried over between turns
---
---Movement Points (MP):
---  - Dynamic allocation: Based on unit stats
---  - Used for: Walking, running, turning
---  - Terrain-dependent costs
---  - Cannot be carried over between turns
---
---Movement Costs (MP):
---  - Normal terrain: 2 MP per tile
---  - Rough terrain: 4 MP per tile
---  - Slope/elevation: 6 MP per tile
---
---Key Exports:
---  - ActionSystem.new(losSystem, animationSystem): Creates action system
---  - spendAP(unit, amount): Deducts AP from unit
---  - spendMP(unit, amount): Deducts MP from unit
---  - canAfford(unit, ap, mp): Validates if unit has enough points
---  - restorePoints(unit): Restores AP/MP at turn start
---  - getMovementCost(fromHex, toHex, map): Calculates MP cost for move
---  - hasEnoughAP(unit, amount): Checks AP availability
---  - hasEnoughMP(unit, amount): Checks MP availability
---
---Dependencies:
---  - battlescape.battle_ecs.hex_math: Hex coordinate math
---
---@module battlescape.combat.action_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ActionSystem = require("battlescape.combat.action_system")
---  local actionSys = ActionSystem.new(losSystem, animationSystem)
---  if actionSys:canAfford(unit, 2, 4) then
---    actionSys:spendAP(unit, 2)
---    actionSys:spendMP(unit, 4)
---  end
---
---@see battlescape.combat.combat_3d For combat logic

-- Action System
-- Manages Action Points (AP) and Movement Points (MP) for units

local HexMath = require("battlescape.battle_ecs.hex_math")

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
function ActionSystem.new(losSystem, animationSystem)
    local self = setmetatable({}, ActionSystem)
    self.losSystem = losSystem
    self.animationSystem = animationSystem
    self.notificationPanel = nil
    return self
end

-- Set notification panel reference
function ActionSystem:setNotificationPanel(notificationPanel)
    self.notificationPanel = notificationPanel
end

-- Reset unit for new turn
function ActionSystem:resetUnit(unit)
    unit.actionPointsLeft = ActionSystem.AP_PER_TURN
    
    -- Apply morale/sanity AP modifiers
    local MoraleSystem = require("battlescape.systems.morale_system")
    local apModifier = MoraleSystem.getAPModifier(unit.id)
    unit.actionPointsLeft = math.max(0, unit.actionPointsLeft + apModifier)
    
    -- Check if unit is panicked (cannot act at all)
    local canAct, reason = MoraleSystem.canAct(unit.id)
    if not canAct then
        unit.actionPointsLeft = 0
        print(string.format("[ActionSystem] %s cannot act: %s", unit.name, reason))
    end
    
    unit.movementPoints = unit:calculateMP()
    unit.hasActed = false
    print(string.format("[ActionSystem] Reset %s: AP=%d (modifier: %d), MP=%d",
          unit.name, unit.actionPointsLeft, apModifier, unit.movementPoints))
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
        local movementInterrupted = false
        animationSystem:startPathMovement(unit, path, 
            function(unit, tileX, tileY) 
                -- Called when unit reaches each tile
                local continueMovement = self:updateUnitPosition(unit, tileX, tileY, battlefield)
                if not continueMovement then
                    movementInterrupted = true
                end
            end,
            function()
                -- Animation complete callback - only run if movement wasn't interrupted
                if not movementInterrupted then
                    self:completeUnitMovement(unit, path[#path].x, path[#path].y, battlefield)
                    -- Update visibility after movement completes
                    if onVisibilityUpdate then
                        onVisibilityUpdate()
                    end
                else
                    print(string.format("[ActionSystem] Movement completion skipped for %s - was interrupted", unit.name))
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
    
    -- Check for enemy spotting during movement
    if self.losSystem then
        local spottedEnemies = self:checkForEnemySpotting(unit, battlefield)
        if #spottedEnemies > 0 then
            -- Interrupt movement animation
            if self.animationSystem then
                self.animationSystem:clear()
                print(string.format("[ActionSystem] Movement interrupted for %s - enemies spotted!", unit.name))
            end
            
            -- Trigger enemy spotted notification
            self:onEnemiesSpotted(unit, spottedEnemies, battlefield)
            return false  -- Movement interrupted
        end
    end
    
    print(string.format("[ActionSystem] %s position updated to (%d,%d) during movement",
          unit.name, tileX, tileY))
    return true  -- Movement continues
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

-- Check for enemy units that can be seen from the unit's current position
function ActionSystem:checkForEnemySpotting(unit, battlefield)
    local spottedEnemies = {}
    
    -- Get all units on the battlefield
    for _, tile in ipairs(battlefield.tiles) do
        if tile.unit and tile.unit.teamId ~= unit.teamId then
            -- Check if this enemy unit can be seen by the moving unit
            if self.losSystem:canSeeUnit(unit, tile.unit, battlefield) then
                table.insert(spottedEnemies, tile.unit)
                print(string.format("[ActionSystem] %s spotted enemy %s at (%d,%d)",
                      unit.name, tile.unit.name, tile.unit.x, tile.unit.y))
            end
        end
    end
    
    return spottedEnemies
end

-- Handle enemy spotting notification and interruption
function ActionSystem:onEnemiesSpotted(unit, spottedEnemies, battlefield)
    print(string.format("[ActionSystem] %s spotted %d enemy unit(s) during movement!",
          unit.name, #spottedEnemies))
    
    -- For now, just log the spotted enemies
    -- Notification system integration is implemented
    for i, enemy in ipairs(spottedEnemies) do
        print(string.format("  [%d] %s (team %s) at (%d,%d)",
              i, enemy.name, enemy.teamId, enemy.x, enemy.y))
        
        -- Add notification to panel if available
        if self.notificationPanel then
            self.notificationPanel:addNotification(
                "enemy_spotted",
                string.format("Enemy %s spotted!", enemy.name),
                {x = enemy.x, y = enemy.y}
            )
        end
    end
end

-- Add notification for ally unit taking damage
function ActionSystem:addAllyWoundedNotification(unit, damage, battlefield)
    if self.notificationPanel then
        self.notificationPanel:addNotification(
            "ally_wounded",
            string.format("Ally %s wounded! (-%d HP)", unit.name, damage),
            {x = unit.x, y = unit.y}
        )
    end
end

-- Add notification for enemy unit in firing range
function ActionSystem:addEnemyInRangeNotification(unit, enemy, battlefield)
    if self.notificationPanel then
        self.notificationPanel:addNotification(
            "enemy_in_range",
            string.format("Enemy %s in range!", enemy.name),
            {x = enemy.x, y = enemy.y}
        )
    end
end

return ActionSystem
























