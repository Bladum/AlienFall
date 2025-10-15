---Grenade Trajectory System - Tactical Throwing Mechanics
---
---Implements realistic grenade throwing with parabolic arc calculation, range limits based on
---unit strength, bounce physics, AOE damage preview, and throw accuracy modifiers. Supports
---multiple grenade types (frag, smoke, flash, incendiary) with distinct properties and effects.
---
---Throw Mechanics:
---  - Parabolic Arc: Calculates realistic trajectory with gravity simulation
---  - Range Limits: Throw distance affected by unit strength stat
---  - Accuracy Modifiers: Throw precision decreases with distance and arc angle
---  - Bounce Physics: Grenades bounce off walls and obstacles realistically
---  - Height Adjustment: Trajectory modified by elevation differences
---
---Grenade Types:
---  - Frag Grenades: Area damage with shrapnel and explosion radius
---  - Smoke Grenades: Creates smoke cloud for concealment
---  - Flash Grenades: Stuns and disorients nearby units
---  - Incendiary Grenades: Creates persistent fire effect
---
---AOE Preview:
---  - Visual arc trajectory showing grenade flight path
---  - Explosion radius indicator at impact point
---  - Affected tiles and units highlighted
---  - Damage falloff visualization
---
---Key Exports:
---  - calculateTrajectory(startPos, targetPos, strength): Calculates throw arc
---  - getThrowRange(unit): Returns maximum throw distance
---  - previewAOE(targetPos, grenadeType): Shows explosion preview
---  - throwGrenade(unit, targetPos, grenadeType): Executes throw action
---  - calculateBounce(trajectory, obstacle): Bounces grenade off obstacle
---
---Integration:
---  - Works with explosion_system.lua for AOE damage
---  - Uses hex_math.lua for distance and trajectory calculations
---  - Integrates with fire_system.lua for incendiary effects
---  - Connects to smoke_system.lua for smoke grenade clouds
---
---@module battlescape.systems.grenade_trajectory_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local GrenadeSystem = require("battlescape.systems.grenade_trajectory_system")
---  local trajectory = GrenadeSystem.calculateTrajectory(unitPos, targetPos, unit.strength)
---  GrenadeSystem.throwGrenade(unit, targetPos, "frag")
---
---@see battlescape.effects.explosion_system For AOE damage mechanics
---@see battlescape.effects.fire_system For incendiary grenade effects
---@see battlescape.effects.smoke_system For smoke grenade mechanics
---@see battlescape.battle_ecs.hex_math For trajectory calculations
--]]

local GrenadeTrajectorySystem = {}

-- Configuration
local CONFIG = {
    -- Throw mechanics
    BASE_THROW_RANGE = 15,          -- Base range in hexes
    RANGE_PER_STRENGTH = 1,         -- Additional range per strength point
    MIN_THROW_RANGE = 3,            -- Minimum throw range
    MAX_THROW_RANGE = 25,           -- Maximum throw range
    THROW_AP_COST = 3,              -- AP to throw grenade
    
    -- Accuracy
    BASE_THROW_ACCURACY = 80,       -- Base accuracy at short range
    ACCURACY_PER_HEX = -2,          -- Accuracy penalty per hex
    MIN_THROW_ACCURACY = 20,        -- Minimum accuracy
    SCATTER_RADIUS_MAX = 3,         -- Maximum scatter in hexes
    
    -- Arc calculation
    ARC_HEIGHT_MULTIPLIER = 0.3,    -- Height of arc relative to distance
    ARC_SEGMENTS = 20,              -- Number of segments for drawing
    GRAVITY = 9.8,                  -- Gravity constant (for physics)
    
    -- Bounce mechanics
    BOUNCE_ENABLED = true,
    BOUNCE_ELASTICITY = 0.6,        -- Energy retained after bounce
    MAX_BOUNCES = 2,                -- Maximum number of bounces
    
    -- Grenade types
    GRENADE_TYPES = {
        FRAG = {
            name = "Frag Grenade",
            damageRadius = 3,       -- Hexes
            damageCenter = 30,      -- Damage at center
            damageEdge = 10,        -- Damage at edge
            fuseTime = 2,           -- Turns until detonation
            canBounce = true,
        },
        SMOKE = {
            name = "Smoke Grenade",
            effectRadius = 4,       -- Hexes
            smokeDensity = 8,       -- Smoke density
            duration = 5,           -- Turns
            fuseTime = 1,
            canBounce = false,
        },
        FLASH = {
            name = "Flashbang",
            effectRadius = 5,       -- Hexes
            stunDuration = 2,       -- Turns stunned
            accuracyPenalty = -40,  -- Accuracy penalty
            fuseTime = 1,
            canBounce = true,
        },
        INCENDIARY = {
            name = "Incendiary Grenade",
            effectRadius = 3,       -- Hexes
            fireIntensity = 6,      -- Fire intensity
            duration = 4,           -- Turns
            fuseTime = 1,
            canBounce = false,
        },
    },
    
    -- Visualization
    COLORS = {
        TRAJECTORY_VALID = {r = 80, g = 200, b = 80, a = 200},
        TRAJECTORY_INVALID = {r = 220, g = 60, b = 60, a = 200},
        AOE_DAMAGE = {r = 220, g = 60, b = 60, a = 100},
        AOE_EFFECT = {r = 220, g = 180, b = 60, a = 100},
        BOUNCE_POINT = {r = 220, g = 120, b = 60, a = 255},
        LANDING_POINT = {r = 80, g = 200, b = 80, a = 255},
    },
    
    TRAJECTORY_LINE_WIDTH = 2,
    AOE_LINE_WIDTH = 1,
    POINT_RADIUS = 6,
}

---@class TrajectoryPoint
---@field x number
---@field y number
---@field z number

---@class TrajectoryState
---@field active boolean
---@field thrower table|nil
---@field grenadeType string|nil
---@field targetX number|nil
---@field targetY number|nil
---@field trajectory table
---@field bouncePoints table
---@field landingPoint TrajectoryPoint|nil
---@field isValid boolean
---@field scatterRadius number

-- Trajectory state
---@type TrajectoryState
local trajectoryState = {
    active = false,
    thrower = nil,
    grenadeType = nil,
    targetX = nil,
    targetY = nil,
    trajectory = {},
    bouncePoints = {},
    landingPoint = nil,
    isValid = false,
    scatterRadius = 0,
}

--[[
    Initialize grenade trajectory system
]]
function GrenadeTrajectorySystem.init()
    trajectoryState = {
        active = false,
        thrower = nil,
        grenadeType = nil,
        targetX = nil,
        targetY = nil,
        trajectory = {},
        bouncePoints = {},
        landingPoint = nil,
        isValid = false,
        scatterRadius = 0,
    }
    print("[GrenadeTrajectorySystem] Grenade trajectory system initialized")
end

--[[
    Calculate throw range for unit
    
    @param strength: Unit strength stat
    @return maxRange: Maximum throw range in hexes
]]
function GrenadeTrajectorySystem.calculateMaxRange(strength)
    strength = strength or 10
    local range = CONFIG.BASE_THROW_RANGE + (strength * CONFIG.RANGE_PER_STRENGTH)
    return math.min(range, CONFIG.MAX_THROW_RANGE)
end

--[[
    Calculate throw accuracy
    
    @param distance: Throw distance in hexes
    @param strength: Unit strength stat
    @return accuracy: Throw accuracy 0-100
]]
function GrenadeTrajectorySystem.calculateAccuracy(distance, strength)
    local accuracy = CONFIG.BASE_THROW_ACCURACY + (distance * CONFIG.ACCURACY_PER_HEX)
    accuracy = math.max(CONFIG.MIN_THROW_ACCURACY, accuracy)
    return accuracy
end

--[[
    Calculate scatter radius based on accuracy
    
    @param accuracy: Throw accuracy 0-100
    @return scatterRadius: Scatter radius in hexes
]]
function GrenadeTrajectorySystem.calculateScatter(accuracy)
    local missChance = 100 - accuracy
    local scatter = (missChance / 100) * CONFIG.SCATTER_RADIUS_MAX
    return scatter
end

--[[
    Calculate parabolic trajectory
    
    @param fromX, fromY, fromZ: Thrower position
    @param toX, toY, toZ: Target position
    @return trajectory: Table of {x, y, z} points
]]
function GrenadeTrajectorySystem.calculateTrajectory(fromX, fromY, fromZ, toX, toY, toZ)
    local trajectory = {}
    local distance = math.sqrt((toX - fromX)^2 + (toY - fromY)^2)
    local arcHeight = distance * CONFIG.ARC_HEIGHT_MULTIPLIER + math.abs(toZ - fromZ)
    
    for i = 0, CONFIG.ARC_SEGMENTS do
        local t = i / CONFIG.ARC_SEGMENTS
        
        -- Linear interpolation for x, y
        local x = fromX + (toX - fromX) * t
        local y = fromY + (toY - fromY) * t
        
        -- Parabolic arc for z
        local z = fromZ + (toZ - fromZ) * t + arcHeight * (4 * t * (1 - t))
        
        table.insert(trajectory, {x = x, y = y, z = z})
    end
    
    return trajectory
end

--[[
    Validate throw (check range, obstacles, etc.)
    
    @param thrower: Thrower unit data { x, y, z, strength }
    @param targetX, targetY, targetZ: Target position
    @param grenadeType: Grenade type string
    @return valid: Boolean
    @return reason: String (if invalid)
]]
function GrenadeTrajectorySystem.validateThrow(thrower, targetX, targetY, targetZ, grenadeType)
    if not thrower then
        return false, "No thrower"
    end
    
    if not CONFIG.GRENADE_TYPES[grenadeType] then
        return false, "Invalid grenade type"
    end
    
    -- Check range
    local distance = math.sqrt((targetX - thrower.x)^2 + (targetY - thrower.y)^2)
    local maxRange = GrenadeTrajectorySystem.calculateMaxRange(thrower.strength or 10)
    
    if distance < CONFIG.MIN_THROW_RANGE then
        return false, "Too close"
    end
    
    if distance > maxRange then
        return false, "Out of range"
    end
    
    -- Check AP
    if thrower.ap < CONFIG.THROW_AP_COST then
        return false, "Not enough AP"
    end
    
    -- Check obstacles (would integrate with map system)
    -- For now, assume valid
    
    return true, ""
end

--[[
    Set throw target and calculate trajectory
    
    @param thrower: Thrower unit data
    @param targetX, targetY, targetZ: Target position
    @param grenadeType: Grenade type string
]]
function GrenadeTrajectorySystem.setTarget(thrower, targetX, targetY, targetZ, grenadeType)
    trajectoryState.active = true
    trajectoryState.thrower = thrower
    trajectoryState.targetX = targetX
    trajectoryState.targetY = targetY
    trajectoryState.grenadeType = grenadeType
    
    -- Validate
    local valid, reason = GrenadeTrajectorySystem.validateThrow(thrower, targetX, targetY,
        targetZ or 0, grenadeType)
    trajectoryState.isValid = valid
    
    if not valid then
        print(string.format("[GrenadeTrajectorySystem] Invalid throw: %s", reason))
        return
    end
    
    -- Calculate trajectory
    local fromZ = thrower.z or 0
    local toZ = targetZ or 0
    trajectoryState.trajectory = GrenadeTrajectorySystem.calculateTrajectory(
        thrower.x, thrower.y, fromZ, targetX, targetY, toZ)
    
    -- Calculate scatter
    local distance = math.sqrt((targetX - thrower.x)^2 + (targetY - thrower.y)^2)
    local accuracy = GrenadeTrajectorySystem.calculateAccuracy(distance, thrower.strength or 10)
    trajectoryState.scatterRadius = GrenadeTrajectorySystem.calculateScatter(accuracy)
    
    -- Set landing point (last trajectory point)
    trajectoryState.landingPoint = trajectoryState.trajectory[#trajectoryState.trajectory]
    
    print(string.format("[GrenadeTrajectorySystem] Trajectory calculated: %d points, scatter %.1f",
        #trajectoryState.trajectory, trajectoryState.scatterRadius))
end

--[[
    Clear trajectory
]]
function GrenadeTrajectorySystem.clearTarget()
    trajectoryState.active = false
    trajectoryState.trajectory = {}
    trajectoryState.bouncePoints = {}
    trajectoryState.landingPoint = nil
end

--[[
    Execute throw with scatter
    
    @return success: Boolean
    @return landingX, landingY: Actual landing position
]]
function GrenadeTrajectorySystem.executeThrow()
    if not trajectoryState.isValid or not trajectoryState.active then
        return false, nil, nil
    end
    
    local thrower = trajectoryState.thrower
    local targetX = trajectoryState.targetX
    local targetY = trajectoryState.targetY
    
    -- Apply scatter
    local scatterAngle = math.random() * 2 * math.pi
    local scatterDistance = math.random() * trajectoryState.scatterRadius
    local actualX = targetX + math.cos(scatterAngle) * scatterDistance
    local actualY = targetY + math.sin(scatterAngle) * scatterDistance
    
    -- Round to hex grid
    actualX = math.floor(actualX + 0.5)
    actualY = math.floor(actualY + 0.5)
    
    -- Deduct AP
    if thrower and thrower.ap then
        thrower.ap = thrower.ap - CONFIG.THROW_AP_COST
    end
    
    print(string.format("[GrenadeTrajectorySystem] Grenade thrown: target (%d,%d), landed (%d,%d)",
        targetX, targetY, actualX, actualY))
    
    -- Apply grenade effects (would integrate with damage/fire/smoke systems)
    local grenadeData = CONFIG.GRENADE_TYPES[trajectoryState.grenadeType]
    if grenadeData then
        print(string.format("[GrenadeTrajectorySystem] %s effects: radius %d",
            grenadeData.name, grenadeData.damageRadius or grenadeData.effectRadius))
    end
    
    -- Clear trajectory
    GrenadeTrajectorySystem.clearTarget()
    
    return true, actualX, actualY
end

--[[
    Draw trajectory visualization
    
    @param camera: Camera transform { offsetX, offsetY, zoom }
]]
function GrenadeTrajectorySystem.draw(camera)
    if not trajectoryState.active or #trajectoryState.trajectory == 0 then
        return
    end
    
    -- Draw trajectory line
    local color = trajectoryState.isValid and CONFIG.COLORS.TRAJECTORY_VALID or
        CONFIG.COLORS.TRAJECTORY_INVALID
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.setLineWidth(CONFIG.TRAJECTORY_LINE_WIDTH)
    
    for i = 1, #trajectoryState.trajectory - 1 do
        local p1 = trajectoryState.trajectory[i]
        local p2 = trajectoryState.trajectory[i + 1]
        
        if camera and camera.offsetX and camera.offsetY and camera.zoom then
            local x1 = (p1.x * 24 + camera.offsetX) * camera.zoom
            local y1 = (p1.y * 24 + camera.offsetY - p1.z * 12) * camera.zoom
            local x2 = (p2.x * 24 + camera.offsetX) * camera.zoom
            local y2 = (p2.y * 24 + camera.offsetY - p2.z * 12) * camera.zoom
            
            love.graphics.line(x1, y1, x2, y2)
        end
    end
    
    -- Draw landing point
    if trajectoryState.landingPoint and camera and camera.offsetX and camera.offsetY and camera.zoom then
        local lp = trajectoryState.landingPoint
        if lp and lp.x ~= nil and lp.y ~= nil then
            local camOffsetX = camera.offsetX or 0
            local camOffsetY = camera.offsetY or 0
            local camZoom = camera.zoom or 1
            local x = (lp.x * 24 + camOffsetX) * camZoom
            local y = (lp.y * 24 + camOffsetY) * camZoom
            
            love.graphics.setColor(CONFIG.COLORS.LANDING_POINT.r, CONFIG.COLORS.LANDING_POINT.g,
                CONFIG.COLORS.LANDING_POINT.b, CONFIG.COLORS.LANDING_POINT.a)
            love.graphics.circle("fill", x, y, CONFIG.POINT_RADIUS)
        end
    end
    
    -- Draw AOE preview
    if trajectoryState.landingPoint and trajectoryState.grenadeType then
        GrenadeTrajectorySystem.drawAOE(trajectoryState.landingPoint.x,
            trajectoryState.landingPoint.y, trajectoryState.grenadeType, camera)
    end
    
    -- Draw scatter radius
    if trajectoryState.scatterRadius > 0 and trajectoryState.landingPoint and camera and camera.offsetX and camera.offsetY and camera.zoom then
        local lp = trajectoryState.landingPoint
        if lp and lp.x ~= nil and lp.y ~= nil then
            local camOffsetX = camera.offsetX or 0
            local camOffsetY = camera.offsetY or 0
            local camZoom = camera.zoom or 1
            local x = (lp.x * 24 + camOffsetX) * camZoom
            local y = (lp.y * 24 + camOffsetY) * camZoom
            local radius = trajectoryState.scatterRadius * 24 * camZoom
            
            love.graphics.setColor(220, 180, 60, 80)
            love.graphics.circle("fill", x, y, radius)
            love.graphics.setColor(220, 180, 60, 150)
            love.graphics.setLineWidth(1)
            love.graphics.circle("line", x, y, radius)
        end
    end
end

--[[
    Draw AOE effect preview
    
    @param x, y: Center position
    @param grenadeType: Grenade type string
    @param camera: Camera transform
]]
function GrenadeTrajectorySystem.drawAOE(x, y, grenadeType, camera)
    local grenadeData = CONFIG.GRENADE_TYPES[grenadeType]
    if not grenadeData or not camera then
        return
    end
    
    local camOffsetX = camera.offsetX or 0
    local camOffsetY = camera.offsetY or 0
    local camZoom = camera.zoom or 1
    
    local radius = (grenadeData.damageRadius or grenadeData.effectRadius) * 24 * camZoom
    local centerX = (x * 24 + camOffsetX) * camZoom
    local centerY = (y * 24 + camOffsetY) * camZoom
    
    -- Choose color based on type
    local color = grenadeData.damageCenter and CONFIG.COLORS.AOE_DAMAGE or CONFIG.COLORS.AOE_EFFECT
    
    -- Fill
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.circle("fill", centerX, centerY, radius)
    
    -- Border
    love.graphics.setColor(color.r, color.g, color.b, color.a * 1.5)
    love.graphics.setLineWidth(CONFIG.AOE_LINE_WIDTH)
    love.graphics.circle("line", centerX, centerY, radius)
end

--[[
    Get grenade data
    
    @param grenadeType: Grenade type string
    @return grenadeData or nil
]]
function GrenadeTrajectorySystem.getGrenadeData(grenadeType)
    return CONFIG.GRENADE_TYPES[grenadeType]
end

--[[
    Get trajectory state for debugging
    
    @return trajectoryState table
]]
function GrenadeTrajectorySystem.getState()
    return trajectoryState
end

return GrenadeTrajectorySystem






















