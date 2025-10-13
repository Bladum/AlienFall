-- accuracy_system.lua
-- Accuracy calculation system for battlescape
-- Calculates accuracy modifiers based on range and weapon properties

local RangeSystem = require("battle.systems.range_system")

local AccuracySystem = {}

-- Calculate accuracy multiplier based on distance and weapon range
-- @param distance number: Distance in tiles
-- @param maxRange number: Weapon's maximum range
-- @param baseAccuracy number: Weapon's base accuracy (0.0 to 1.0)
-- @return number: Effective accuracy multiplier (0.0 to 1.0), or nil if out of range
function AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, baseAccuracy)
    if not distance or not maxRange or not baseAccuracy then
        print("[ERROR] AccuracySystem.calculateAccuracyMultiplier: Invalid parameters")
        return nil
    end

    -- Check if target is in range
    if not RangeSystem.isInRange(distance, maxRange) then
        return nil  -- Cannot shoot
    end

    local rangeRatio = distance / maxRange
    local rangeMultiplier = 1.0

    if rangeRatio <= 0.75 then
        -- Optimal range: 100% accuracy
        rangeMultiplier = 1.0
    elseif rangeRatio <= 1.0 then
        -- Effective range: Linear drop from 100% to 50%
        -- At 75% range: 100% accuracy
        -- At 100% range: 50% accuracy
        local t = (rangeRatio - 0.75) / 0.25  -- Normalize to 0-1
        rangeMultiplier = 1.0 - (t * 0.5)  -- Drop from 1.0 to 0.5
    elseif rangeRatio <= 1.25 then
        -- Long range: Linear drop from 50% to 0%
        -- At 100% range: 50% accuracy
        -- At 125% range: 0% accuracy
        local t = (rangeRatio - 1.0) / 0.25  -- Normalize to 0-1
        rangeMultiplier = 0.5 - (t * 0.5)  -- Drop from 0.5 to 0.0
    else
        -- Out of range
        return nil
    end

    -- Apply range multiplier to base accuracy
    return baseAccuracy * rangeMultiplier
end

-- Calculate effective accuracy percentage for display
-- @param distance number: Distance in tiles
-- @param maxRange number: Weapon's maximum range
-- @param baseAccuracy number: Weapon's base accuracy (0.0 to 1.0)
-- @return number: Effective accuracy as percentage (0-100), or nil if out of range
function AccuracySystem.calculateEffectiveAccuracy(distance, maxRange, baseAccuracy)
    local multiplier = AccuracySystem.calculateAccuracyMultiplier(distance, maxRange, baseAccuracy)
    if not multiplier then
        return nil
    end

    return math.floor(multiplier * 100 + 0.5)  -- Round to nearest percent
end

-- Get accuracy zone description for UI
-- @param distance number: Distance in tiles
-- @param maxRange number: Weapon's maximum range
-- @return string: Human-readable accuracy zone description
function AccuracySystem.getAccuracyZoneDescription(distance, maxRange)
    local zone = RangeSystem.getRangeZone(distance, maxRange)

    if zone == "optimal" then
        return "Optimal Range"
    elseif zone == "effective" then
        return "Effective Range"
    elseif zone == "long" then
        return "Long Range"
    else
        return "Out of Range"
    end
end

-- Get accuracy color for UI display
-- @param distance number: Distance in tiles
-- @param maxRange number: Weapon's maximum range
-- @return table: RGB color values {r, g, b} for accuracy zone
function AccuracySystem.getAccuracyZoneColor(distance, maxRange)
    local zone = RangeSystem.getRangeZone(distance, maxRange)

    if zone == "optimal" then
        return {0.2, 0.8, 0.2}  -- Green
    elseif zone == "effective" then
        return {0.8, 0.8, 0.2}  -- Yellow
    elseif zone == "long" then
        return {0.8, 0.4, 0.2}  -- Orange
    else
        return {0.8, 0.2, 0.2}  -- Red
    end
end

return AccuracySystem