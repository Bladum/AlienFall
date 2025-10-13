-- range_system.lua
-- Range calculation system for battlescape
-- Calculates distances between units on hex grid

local HexMath = require("battle.utils.hex_math")

local RangeSystem = {}

-- Calculate distance between two positions in tiles
-- @param shooterPos table: {q, r} or {x, y} position of shooter
-- @param targetPos table: {q, r} or {x, y} position of target
-- @return number: Distance in tiles
function RangeSystem.calculateDistance(shooterPos, targetPos)
    if not shooterPos or not targetPos then
        print("[ERROR] RangeSystem.calculateDistance: Invalid positions")
        return 0
    end

    -- Handle both axial (q,r) and offset (x,y) coordinates
    local shooterQ, shooterR
    local targetQ, targetR

    if shooterPos.q and shooterPos.r then
        shooterQ, shooterR = shooterPos.q, shooterPos.r
    elseif shooterPos.x and shooterPos.y then
        shooterQ, shooterR = HexMath.offsetToAxial(shooterPos.x, shooterPos.y)
    else
        print("[ERROR] RangeSystem.calculateDistance: Invalid shooter position format")
        return 0
    end

    if targetPos.q and targetPos.r then
        targetQ, targetR = targetPos.q, targetPos.r
    elseif targetPos.x and targetPos.y then
        targetQ, targetR = HexMath.offsetToAxial(targetPos.x, targetPos.y)
    else
        print("[ERROR] RangeSystem.calculateDistance: Invalid target position format")
        return 0
    end

    return HexMath.distance(shooterQ, shooterR, targetQ, targetR)
end

-- Check if target is within weapon range
-- @param distance number: Distance in tiles
-- @param maxRange number: Weapon's maximum range
-- @return boolean: True if within range
function RangeSystem.isInRange(distance, maxRange)
    if not distance or not maxRange then
        return false
    end

    -- Allow shooting up to 125% of max range
    return distance <= maxRange * 1.25
end

-- Get range zone for accuracy calculation
-- @param distance number: Distance in tiles
-- @param maxRange number: Weapon's maximum range
-- @return string: "optimal" (0-75%), "effective" (75-100%), "long" (100-125%), "out_of_range" (>125%)
function RangeSystem.getRangeZone(distance, maxRange)
    if not distance or not maxRange or maxRange <= 0 then
        return "out_of_range"
    end

    local rangeRatio = distance / maxRange

    if rangeRatio <= 0.75 then
        return "optimal"  -- 0-75% of max range
    elseif rangeRatio <= 1.0 then
        return "effective"  -- 75-100% of max range
    elseif rangeRatio <= 1.25 then
        return "long"  -- 100-125% of max range
    else
        return "out_of_range"  -- >125% of max range
    end
end

return RangeSystem