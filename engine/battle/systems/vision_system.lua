-- vision_system.lua
-- Vision and line-of-sight processing system
-- Part of ECS architecture for battle system

local HexMath = require("battle.utils.hex_math")
local Debug = require("battle.utils.debug")

local VisionSystem = {}

-- Calculate line of sight between two hexes
-- @param hexSystem HexSystem: The hex grid
-- @param fromQ number: Source q coordinate
-- @param fromR number: Source r coordinate
-- @param toQ number: Target q coordinate
-- @param toR number: Target r coordinate
-- @return boolean: Whether there's clear LOS
function VisionSystem.hasLineOfSight(hexSystem, fromQ, fromR, toQ, toR)
    -- Get hex line
    local line = HexMath.hexLine(fromQ, fromR, toQ, toR)
    
    -- Check each hex in line (skip first, check last)
    for i = 2, #line do
        local hex = line[i]
        local tile = hexSystem:getTile(hex.q, hex.r)
        
        if not tile then
            return false  -- Out of bounds
        end
        
        if tile.blocking then
            -- Check if it's the last hex (target can be blocking)
            if i == #line then
                return true
            end
            return false
        end
    end
    
    return true
end

-- Update vision for a unit (marks visible tiles and units)
-- @param unit table: Unit with transform and vision components
-- @param hexSystem HexSystem: The hex grid
function VisionSystem.updateUnitVision(unit, hexSystem)
    if not unit.transform or not unit.vision then
        return
    end
    
    -- Clear previous vision
    unit.vision:clear()
    
    local sourceQ = unit.transform.q
    local sourceR = unit.transform.r
    local facing = unit.transform.facing
    
    -- Get hexes in range
    local hexesInRange = HexMath.hexesInRange(sourceQ, sourceR, unit.vision.range)
    
    for _, hex in ipairs(hexesInRange) do
        if hexSystem:isValidHex(hex.q, hex.r) then
            -- Check if in front arc (120°)
            local inArc = HexMath.isInFrontArc(sourceQ, sourceR, facing, hex.q, hex.r)
            
            if inArc then
                -- Check line of sight
                local hasLOS = VisionSystem.hasLineOfSight(hexSystem, sourceQ, sourceR, hex.q, hex.r)
                
                if hasLOS then
                    -- Mark tile as visible
                    unit.vision:markTileVisible(hex.q, hex.r)
                    
                    -- Check for units at this position
                    local targetUnit, targetId = hexSystem:getUnitAt(hex.q, hex.r)
                    if targetUnit and targetId then
                        unit.vision:markUnitVisible(targetId)
                    end
                end
            end
        end
    end
end

-- Update vision for all units in a team
-- @param units table: Array or map of units
-- @param hexSystem HexSystem: The hex grid
function VisionSystem.updateTeamVision(units, hexSystem)
    local count = 0
    for _, unit in pairs(units) do
        if unit.vision and unit.transform then
            VisionSystem.updateUnitVision(unit, hexSystem)
            count = count + 1
        end
    end
    Debug.log("VisionSystem", string.format("Updated vision for %d units", count))
end

-- Get all tiles visible to a team
-- @param units table: Array or map of units in the team
-- @return table: Set of visible tiles {q_r = true}
function VisionSystem.getTeamVisibleTiles(units)
    local visible = {}
    for _, unit in pairs(units) do
        if unit.vision then
            for tileKey, _ in pairs(unit.vision.visibleTiles) do
                visible[tileKey] = true
            end
        end
    end
    return visible
end

-- Draw vision cones (debug visualization)
-- @param units table: Array or map of units
-- @param hexSystem HexSystem: The hex grid
-- @param camera table: Camera for coordinate transformation
function VisionSystem.drawVisionCones(units, hexSystem, camera)
    if not Debug.showVisionCones then return end
    
    love.graphics.push()
    love.graphics.setColor(1, 1, 0, 0.2)  -- Yellow overlay
    
    for _, unit in pairs(units) do
        if unit.transform and unit.vision then
            local sourceQ = unit.transform.q
            local sourceR = unit.transform.r
            local facing = unit.transform.facing
            
            -- Draw visible tiles
            for tileKey, _ in pairs(unit.vision.visibleTiles) do
                local q, r = tileKey:match("([^_]+)_([^_]+)")
                q = tonumber(q)
                r = tonumber(r)
                
                if q and r then
                    local x, y = hexSystem:hexToScreen(q, r)
                    x = x - camera.x
                    y = y - camera.y
                    
                    -- Draw small circle at visible hex
                    love.graphics.circle("fill", x, y, 4)
                end
            end
            
            -- Draw facing indicator
            local x, y = hexSystem:hexToScreen(sourceQ, sourceR)
            x = x - camera.x
            y = y - camera.y
            
            love.graphics.setColor(1, 0, 0, 0.5)  -- Red facing arrow
            local angle = math.pi / 3 * facing
            local arrowLen = hexSystem.hexSize
            love.graphics.line(x, y, x + arrowLen * math.cos(angle), y + arrowLen * math.sin(angle))
        end
    end
    
    love.graphics.pop()
end

return VisionSystem
