-- Interception Altitude Mechanics System
-- Handles 3D positioning, altitude advantages, and vertical combat

local AltitudeMechanics = {}
AltitudeMechanics.__index = AltitudeMechanics

-- Initialize altitude system
function AltitudeMechanics.new()
    local self = setmetatable({}, AltitudeMechanics)
    
    -- Altitude levels
    self.MIN_ALTITUDE = 0
    self.MAX_ALTITUDE = 30000 -- meters
    self.CRUISE_ALTITUDE = 10000
    
    -- Altitude bands for tactical advantage
    self.ALTITUDE_BANDS = {
        { min = 0, max = 5000, name = "LOW", advantage = "speed" },
        { min = 5000, max = 10000, name = "MEDIUM", advantage = "balanced" },
        { min = 10000, max = 20000, name = "HIGH", advantage = "defense" },
        { min = 20000, max = 30000, name = "EXTREME", advantage = "altitude" }
    }
    
    return self
end

-- Calculate altitude-based tactical advantage
function AltitudeMechanics:getAltitudeAdvantage(craft1Altitude, craft2Altitude)
    local difference = craft1Altitude - craft2Altitude
    
    -- Advantage breakdown:
    -- > 5000m higher: +3 advantage (significant)
    -- 2000-5000m higher: +2 advantage (moderate)
    -- 0-2000m higher: +1 advantage (slight)
    -- Within 0m: 0 (neutral)
    
    local advantage = 0
    if difference > 5000 then
        advantage = 3
    elseif difference > 2000 then
        advantage = 2
    elseif difference > 0 then
        advantage = 1
    elseif difference < -5000 then
        advantage = -3
    elseif difference < -2000 then
        advantage = -2
    elseif difference < 0 then
        advantage = -1
    end
    
    return advantage, difference
end

-- Get altitude band for given altitude
function AltitudeMechanics:getAltitudeBand(altitude)
    for _, band in ipairs(self.ALTITUDE_BANDS) do
        if altitude >= band.min and altitude <= band.max then
            return band
        end
    end
    
    return self.ALTITUDE_BANDS[2] -- Default to medium
end

-- Calculate altitude disadvantages (overheating, oxygen, etc.)
function AltitudeMechanics:getAltitudeStressors(altitude)
    local stressors = {
        oxygenThin = 0,
        thermalStress = 0,
        pressureDamage = 0,
        visibilityImpairment = 0
    }
    
    -- Extreme altitude oxygen thinness (above 20km)
    if altitude > 20000 then
        stressors.oxygenThin = (altitude - 20000) / 10000
        stressors.oxygenThin = math.min(1, stressors.oxygenThin)
    end
    
    -- Very low altitude atmospheric pressure damage (below 500m)
    if altitude < 500 then
        stressors.pressureDamage = (500 - altitude) / 500
        stressors.pressureDamage = math.min(1, stressors.pressureDamage)
    end
    
    -- High speed at low altitude creates thermal stress
    if altitude < 5000 then
        stressors.thermalStress = 0.2 * (5000 - altitude) / 5000
    end
    
    return stressors
end

-- Modify craft performance based on altitude
function AltitudeMechanics:applyAltitudeModifiers(craft, deltaTime)
    local altitude = craft.altitude or self.CRUISE_ALTITUDE
    local stressors = self:getAltitudeStressors(altitude)
    
    -- Apply oxygen damage at extreme altitudes
    if stressors.oxygenThin > 0 then
        craft.health = craft.health - (stressors.oxygenThin * 0.1 * deltaTime)
        craft.engineEfficiency = (craft.engineEfficiency or 1.0) * (1 - stressors.oxygenThin * 0.3)
    end
    
    -- Apply pressure damage at very low altitudes
    if stressors.pressureDamage > 0 then
        craft.armor = craft.armor - (stressors.pressureDamage * 0.05 * deltaTime)
    end
    
    -- Apply thermal stress
    if stressors.thermalStress > 0 then
        craft.systemsIntegrity = (craft.systemsIntegrity or 1.0) * (1 - stressors.thermalStress * 0.1 * deltaTime)
    end
end

-- Climb to new altitude
function AltitudeMechanics:climbAltitude(craft, targetAltitude, deltaTime)
    local maxClimbRate = 500 -- meters per second
    local altitudeChange = maxClimbRate * deltaTime
    
    if targetAltitude > craft.altitude then
        craft.altitude = math.min(craft.altitude + altitudeChange, targetAltitude)
    else
        craft.altitude = math.max(craft.altitude - altitudeChange, targetAltitude)
    end
    
    -- Fuel consumption increases with altitude changes
    craft.fuel = craft.fuel - (math.abs(altitudeChange) / 100)
    
    return craft.altitude
end

-- Descend to new altitude (faster than climbing)
function AltitudeMechanics:descentAltitude(craft, targetAltitude, deltaTime)
    local maxDescentRate = 700 -- meters per second (faster than climb)
    local altitudeChange = maxDescentRate * deltaTime
    
    craft.altitude = math.max(craft.altitude - altitudeChange, targetAltitude)
    
    return craft.altitude
end

-- Calculate hit modifier based on altitude differential
function AltitudeMechanics:getAltitudeHitModifier(craft, target)
    local advantage, difference = self:getAltitudeAdvantage(craft.altitude, target.altitude)
    
    -- Hit probability modifier from altitude advantage
    -- Each advantage point = 10% better hit chance
    local modifier = 1.0 + (advantage * 0.1)
    
    return modifier, advantage
end

-- Calculate evasion modifier based on altitude
function AltitudeMechanics:getAltitudeEvasionModifier(craft)
    local altitude = craft.altitude or self.CRUISE_ALTITUDE
    local band = self:getAltitudeBand(altitude)
    
    local evasion = 1.0
    
    if band.advantage == "speed" then
        evasion = 1.2 -- Easier to evade at low altitude (more maneuverable)
    elseif band.advantage == "balanced" then
        evasion = 1.0
    elseif band.advantage == "defense" then
        evasion = 0.9 -- Harder to evade at high altitude
    elseif band.advantage == "altitude" then
        evasion = 0.8 -- Very hard to evade at extreme altitude
    end
    
    return evasion
end

-- Check if altitude change is possible given fuel
function AltitudeMechanics:canChangeAltitude(craft, targetAltitude)
    local fuelNeeded = math.abs(targetAltitude - craft.altitude) / 100
    
    return craft.fuel >= fuelNeeded, fuelNeeded
end

-- Get fuel consumption for altitude change
function AltitudeMechanics:getFuelConsumption(fromAltitude, toAltitude)
    local altitudeDifference = math.abs(toAltitude - fromAltitude)
    
    -- Climbing costs more fuel than descending
    if toAltitude > fromAltitude then
        return (altitudeDifference / 100) * 1.5 -- 1.5x multiplier for climbing
    else
        return altitudeDifference / 100 -- Normal cost for descending
    end
end

-- Maneuver based on altitude advantage
function AltitudeMechanics:performAltitudeManeuver(craft, maneuver, deltaTime)
    local success = false
    
    if maneuver == "ASCEND_TACTICAL" then
        -- Rapid climb to gain height advantage
        local targetAltitude = craft.altitude + 3000
        targetAltitude = math.min(targetAltitude, self.MAX_ALTITUDE)
        self:climbAltitude(craft, targetAltitude, deltaTime * 2) -- Accelerated
        success = true
        
    elseif maneuver == "DESCEND_EVASIVE" then
        -- Fast descent for evasion
        local targetAltitude = craft.altitude - 2000
        targetAltitude = math.max(targetAltitude, self.MIN_ALTITUDE)
        self:descentAltitude(craft, targetAltitude, deltaTime * 2) -- Accelerated
        success = true
        
    elseif maneuver == "LEVEL_FLIGHT" then
        -- Maintain current altitude
        success = true
        
    elseif maneuver == "CLIMB_TO_INTERCEPT" then
        -- Climb to intercept height of target
        local targetAltitude = craft.targetAltitude or self.CRUISE_ALTITUDE
        self:climbAltitude(craft, targetAltitude, deltaTime)
        success = true
    end
    
    return success
end

-- Get radar effectiveness modifier based on altitude differential
function AltitudeMechanics:getRadarModifier(craft, target)
    local difference = craft.altitude - target.altitude
    
    local modifier = 1.0
    
    -- Higher altitude generally better for radar
    if difference > 0 then
        modifier = 1.0 + math.min(0.3, difference / 10000)
    else
        modifier = 1.0 - math.min(0.3, math.abs(difference) / 10000)
    end
    
    return modifier
end

-- Get weapon effectiveness at altitude
function AltitudeMechanics:getWeaponAltitudeModifier(weapon, launchAltitude, targetAltitude)
    local altitudeDifference = targetAltitude - launchAltitude
    
    -- Different weapons have different altitude profiles
    local modifier = 1.0
    
    if weapon.type == "MISSILE" then
        -- Missiles work well from lower altitude shooting up
        if altitudeDifference > 0 then
            modifier = 1.2
        else
            modifier = 0.8
        end
    elseif weapon.type == "CANNON" then
        -- Cannons work better at close altitude ranges
        if math.abs(altitudeDifference) < 1000 then
            modifier = 1.0
        else
            modifier = 0.9 - (math.abs(altitudeDifference) / 10000) * 0.1
        end
    elseif weapon.type == "ENERGY" then
        -- Energy weapons less affected by altitude
        modifier = 1.0
    end
    
    return modifier
end

-- Provide detailed altitude analysis
function AltitudeMechanics:analyzeAltitudePosition(craft, target)
    local analysis = {}
    
    local difference = craft.altitude - target.altitude
    analysis.altitudeDifference = difference
    
    analysis.craftBand = self:getAltitudeBand(craft.altitude)
    analysis.targetBand = self:getAltitudeBand(target.altitude)
    
    local advantage, _ = self:getAltitudeAdvantage(craft.altitude, target.altitude)
    analysis.tacticalAdvantage = advantage
    
    analysis.hitModifier = self:getAltitudeHitModifier(craft, target)
    analysis.evasionModifier = self:getAltitudeEvasionModifier(craft)
    analysis.radarModifier = self:getRadarModifier(craft, target)
    
    analysis.stressors = self:getAltitudeStressors(craft.altitude)
    analysis.recommendation = self:getAltitudeRecommendation(craft, target)
    
    return analysis
end

-- Get tactical recommendation for altitude positioning
function AltitudeMechanics:getAltitudeRecommendation(craft, target)
    local advantage, difference = self:getAltitudeAdvantage(craft.altitude, target.altitude)
    
    if advantage > 0 then
        return "MAINTAIN_ALTITUDE"
    elseif difference < -5000 then
        return "CLIMB_RAPIDLY"
    elseif difference < -2000 then
        return "CLIMB_GRADUALLY"
    else
        return "BALANCED_POSITION"
    end
end

return AltitudeMechanics

