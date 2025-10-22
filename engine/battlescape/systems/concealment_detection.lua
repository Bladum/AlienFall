---Concealment & Detection System for Battlescape
---
---Implements visible/hidden unit detection with formula-based probability,
---environmental factors, concealment tracking, and sight point costs.
---
---Features:
---  - Detection chance formula with weighted components
---  - Environmental factors (day/night, weather, terrain)
---  - Concealment level tracking and regain mechanics
---  - Sight point costs for observing actions
---  - Stealth abilities (smokescreen, silent move, camouflage, etc.)
---  - Integration with line of sight system
---
---Detection Formula:
---  detection_chance = base_rate × distance_mod × (1 - concealment) × 
---                     light_mod × size_mod × noise_mod
---  Result clamped to [0.05, 0.95] (5-95% minimum range)
---
---Key Exports:
---  - ConcealmentDetection.new(battle_system)
---  - calculateDetectionChance(observer, target)
---  - getConcealmentLevel(unit)
---  - applySightPointCost(observer, action_type)
---
---Integration:
---  - Battlescape combat system
---  - Line of sight system
---  - Unit action system
---  - Environmental system
---
---@module battlescape.systems.concealment_detection
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local ConcealmentDetection = {}
ConcealmentDetection.__index = ConcealmentDetection

---Create new concealment detection system
---@param battleSystem table Battle system reference
---@param losSystem table Line of sight system reference
---@return table New ConcealmentDetection instance
function ConcealmentDetection.new(battleSystem, losSystem)
    local self = setmetatable({}, ConcealmentDetection)
    
    self.battleSystem = battleSystem
    self.losSystem = losSystem
    
    -- Unit concealment tracking
    self.unitConcealmentLevel = {}  -- {unitId: 0.0-1.0}
    self.concealmentBreakTimer = {}  -- {unitId: turns_remaining}
    self.concealmentsource = {}  -- {unitId: "terrain", "smoke", "stealth", etc.}
    
    -- Configuration
    self.config = {
        -- Detection ranges by visibility type (in hexes)
        detectionRanges = {
            fullyExposed = 25,   -- Day visibility
            partiallyHidden = 15, -- Dusk/medium cover
            wellHidden = 8,      -- Night/heavy cover
            smokeScreened = 3,   -- Dense smoke/deep concealment
        },
        
        -- Concealment sources (additive modifiers)
        concealmentSources = {
            terrain = 0.2,       -- Light brush, terrain variation
            combatCover = 0.3,   -- Behind sandbags, crates
            stealth = 0.45,      -- Stealth suit passive
            smoke = 0.6,         -- Smoke grenade/smokescreen
            invisibility = 0.95, -- Invisibility spell/tech
        },
        
        -- Regain mechanics
        concealmentRegainTurns = 3,  -- Turns to regain after break
        regainMinimumMovement = 1,   -- Hex movement to regain
        
        -- Base detection rates by observer quality
        baseDetectionRates = {
            rookie = 0.60,
            experienced = 0.70,
            veteran = 0.80,
            elite = 0.85,
        },
        
        -- Light modifiers (time of day)
        lightModifiers = {
            daylight = 1.0,      -- Full visibility
            dusk = 0.85,         -- Reduced light
            night = 0.70,        -- Darkness
            dawn = 0.80,         -- Early light
        },
        
        -- Unit size modifiers
        sizeModifiers = {
            small = 0.85,        -- Scout-class, harder to see
            medium = 1.0,        -- Standard units
            large = 1.15,        -- Tank/heavy units, easier to see
        },
        
        -- Sight point costs per action
        sightPointCosts = {
            move = {min = 1, max = 3},
            fire = {min = 5, max = 10},
            ability = {min = 3, max = 5},
            throw = {min = 2, max = 3},
            melee = {min = 4, max = 6},
        },
        
        -- Stealth abilities
        stealthAbilities = {
            smokescreen = {cost = 1, duration = 2, concealmentBonus = 0.3},
            silentMove = {cost = 2, duration = 1, concealmentBonus = 0.2},
            camouflage = {cost = 1, duration = 3, concealmentBonus = 0.25},
            invisibility = {cost = 5, duration = 2, concealmentBonus = 0.8},
            radarJammer = {cost = 2, duration = 1, concealmentBonus = 0.15},
        },
    }
    
    print("[ConcealmentDetection] Initialized concealment detection system")
    
    return self
end

---Calculate detection chance for observer seeing target
---
---Formula: detection = base × distance_mod × (1 - concealment) × light_mod × size_mod × noise_mod
---
---@param observer table Observer unit
---@param target table Target unit
---@param distance number Distance in hexes
---@param environment table Environment data {time_of_day, weather, terrain}
---@return number Detection chance (0.05-0.95, clamped)
function ConcealmentDetection:calculateDetectionChance(observer, target, distance, environment)
    assert(observer and target, "Observer and target required")
    assert(distance, "Distance required")
    
    -- Base detection rate from observer unit quality
    local baseRate = self:_getBaseDetectionRate(observer)
    
    -- Distance modifier (closer = higher detection chance)
    local distanceMod = self:_getDistanceModifier(distance)
    
    -- Concealment level of target (0.0 = no concealment, 1.0 = invisible)
    local targetConcealmentLevel = self:getConcealmentLevel(target)
    local concealmentFactor = 1.0 - targetConcealmentLevel
    
    -- Light modifier based on time of day
    environment = environment or {}
    local timeOfDay = environment.timeOfDay or "daylight"
    local lightMod = self.config.lightModifiers[timeOfDay] or 1.0
    
    -- Size modifier (easier to see large units)
    local unitSize = target.size or "medium"
    local sizeMod = self.config.sizeModifiers[unitSize] or 1.0
    
    -- Noise modifier (movement, actions increase detectability)
    local noiseMod = self:_getNoiseModifier(target)
    
    -- Combined formula
    local detectionChance = baseRate * distanceMod * concealmentFactor * lightMod * sizeMod * noiseMod
    
    -- Clamp to minimum and maximum
    detectionChance = math.max(0.05, math.min(0.95, detectionChance))
    
    return detectionChance
end

---Get current concealment level for unit
---@param unit table Unit to check
---@return number Concealment level (0.0-1.0), 0 = visible, 1.0 = invisible
function ConcealmentDetection:getConcealmentLevel(unit)
    assert(unit and unit.id, "Unit with id required")
    
    return self.unitConcealmentLevel[unit.id] or 0.0
end

---Set concealment level for unit
---@param unit table Unit to modify
---@param level number Concealment level (0.0-1.0)
---@param source string Concealment source ("terrain", "smoke", "stealth", etc.)
function ConcealmentDetection:setConcealmentLevel(unit, level, source)
    assert(unit and unit.id, "Unit with id required")
    assert(level >= 0 and level <= 1.0, "Level must be 0.0-1.0")
    
    self.unitConcealmentLevel[unit.id] = level
    self.concealmentsource[unit.id] = source or "unknown"
    
    print(string.format("[ConcealmentDetection] Unit %s concealment set to %.2f (%s)",
        unit.id, level, source))
end

---Add concealment break (reset concealment timer and reduce level)
---
---Concealment breaks when unit fires, takes damage, or moves significantly.
---Regain is gradual (3-5 turns) with reduced movement.
---
---@param unit table Unit that broke concealment
---@param severity string "minor" (move), "major" (fire), "complete" (hit)
function ConcealmentDetection:breakConcealment(unit, severity)
    assert(unit and unit.id, "Unit with id required")
    
    severity = severity or "major"
    
    -- Determine impact
    local impactFactor = {
        minor = 0.5,     -- Movement breaks half concealment
        major = 0.8,     -- Firing breaks most concealment
        complete = 1.0,  -- Hit breaks all concealment
    }
    
    local impact = impactFactor[severity] or 0.8
    
    -- Reduce concealment level
    local currentLevel = self:getConcealmentLevel(unit)
    self.unitConcealmentLevel[unit.id] = currentLevel * (1.0 - impact)
    
    -- Set regain timer
    self.concealmentBreakTimer[unit.id] = self.config.concealmentRegainTurns
    
    print(string.format("[ConcealmentDetection] Unit %s concealment broken (%s severity)",
        unit.id, severity))
end

---Regain concealment level (called each turn)
---
---@param unit table Unit to update
---@param hasMovedSignificantly boolean True if unit moved more than 1 hex
---@return boolean True if concealment fully regained
function ConcealmentDetection:updateConcealmentRegain(unit, hasMovedSignificantly)
    assert(unit and unit.id, "Unit with id required")
    
    local unitId = unit.id
    local timer = self.concealmentBreakTimer[unitId] or 0
    
    -- Only regain if not moved too much
    if hasMovedSignificantly then
        self.concealmentBreakTimer[unitId] = self.config.concealmentRegainTurns
        return false
    end
    
    -- Decrement timer
    if timer > 0 then
        self.concealmentBreakTimer[unitId] = timer - 1
        
        -- Gradually increase concealment as timer counts down
        local regainRate = (self.config.concealmentRegainTurns - timer) / 
                          self.config.concealmentRegainTurns
        
        -- Regain up to previous level (before break)
        self.unitConcealmentLevel[unitId] = math.min(self.unitConcealmentLevel[unitId], regainRate)
        
        return timer == 1  -- True when fully regained
    end
    
    return false
end

---Apply sight point cost to observer for action
---
---Sight points represent observer's perception/attention budget.
---Once depleted, observer cannot detect new threats.
---
---@param observer table Observer unit
---@param actionType string "move", "fire", "ability", "throw", "melee"
---@return number Sight points remaining
function ConcealmentDetection:applySightPointCost(observer, actionType)
    assert(observer and observer.id, "Observer unit required")
    
    observer.sightPoints = observer.sightPoints or 10  -- Start with 10 points
    
    local costRange = self.config.sightPointCosts[actionType] or {min = 1, max = 3}
    local baseCost = math.floor((costRange.min + costRange.max) / 2)
    
    -- Apply cost
    observer.sightPoints = math.max(0, observer.sightPoints - baseCost)
    
    print(string.format("[ConcealmentDetection] Observer sight points: %d (after %s)",
        observer.sightPoints, actionType))
    
    return observer.sightPoints
end

---Reset sight points for observer (usually per turn)
---@param observer table Observer unit
---@param newMax number New sight point maximum (default: 10)
function ConcealmentDetection:resetSightPoints(observer, newMax)
    assert(observer and observer.id, "Observer unit required")
    
    observer.sightPoints = newMax or 10
end

---Get detection range based on visibility conditions
---@param visibilityType string "fullyExposed", "partiallyHidden", "wellHidden", "smokeScreened"
---@return number Detection range in hexes
function ConcealmentDetection:getDetectionRange(visibilityType)
    visibilityType = visibilityType or "fullyExposed"
    return self.config.detectionRanges[visibilityType] or 15
end

---Get detection range based on time of day
---@param timeOfDay string "daylight", "dusk", "night", "dawn"
---@return number Detection range in hexes
function ConcealmentDetection:getDetectionRangeByTime(timeOfDay)
    local ranges = {
        daylight = 25,
        dusk = 15,
        night = 8,
        dawn = 12,
    }
    return ranges[timeOfDay] or 15
end

---Get light modifier for time of day
---@param timeOfDay string Time period
---@return number Light modifier (0.0-1.0+)
function ConcealmentDetection:getLightModifier(timeOfDay)
    timeOfDay = timeOfDay or "daylight"
    return self.config.lightModifiers[timeOfDay] or 1.0
end

---Activate stealth ability for unit
---@param unit table Unit using ability
---@param abilityName string "smokescreen", "silentMove", etc.
---@return boolean Success
function ConcealmentDetection:activateStealthAbility(unit, abilityName)
    assert(unit and unit.id, "Unit required")
    assert(abilityName, "Ability name required")
    
    local ability = self.config.stealthAbilities[abilityName]
    if not ability then
        print(string.format("[ConcealmentDetection] Unknown stealth ability: %s", abilityName))
        return false
    end
    
    -- Apply concealment bonus
    local currentLevel = self:getConcealmentLevel(unit)
    local newLevel = math.min(1.0, currentLevel + ability.concealmentBonus)
    
    self:setConcealmentLevel(unit, newLevel, abilityName)
    
    -- Store duration
    unit.stealthAbilityActive = abilityName
    unit.stealthAbilityDuration = ability.duration
    
    print(string.format("[ConcealmentDetection] Unit %s activated %s (concealment: %.2f)",
        unit.id, abilityName, newLevel))
    
    return true
end

---Update stealth ability timers (called each turn)
---@param unit table Unit to update
function ConcealmentDetection:updateStealthAbilityDuration(unit)
    if unit.stealthAbilityActive and unit.stealthAbilityDuration then
        unit.stealthAbilityDuration = unit.stealthAbilityDuration - 1
        
        if unit.stealthAbilityDuration <= 0 then
            self:setConcealmentLevel(unit, 0.0, "none")
            unit.stealthAbilityActive = nil
            unit.stealthAbilityDuration = nil
            
            print(string.format("[ConcealmentDetection] Unit %s stealth ability expired",
                unit.id))
        end
    end
end

-- PRIVATE METHODS

---Get base detection rate for observer
---@param observer table Observer unit
---@return number Base detection rate (0.0-1.0)
function ConcealmentDetection:_getBaseDetectionRate(observer)
    observer = observer or {}
    
    -- Determine observer quality tier
    local experience = observer.experience or 0
    local tier
    
    if experience >= 100 then
        tier = "elite"
    elseif experience >= 50 then
        tier = "veteran"
    elseif experience >= 20 then
        tier = "experienced"
    else
        tier = "rookie"
    end
    
    return self.config.baseDetectionRates[tier] or 0.70
end

---Get distance modifier for detection
---
---Closer targets are easier to detect.
---Modifier: 1.0 at 0 hexes, 0.0 at detection range.
---
---@param distance number Distance in hexes
---@return number Distance modifier (0.0-1.0)
function ConcealmentDetection:_getDistanceModifier(distance)
    distance = distance or 0
    
    local maxRange = 25  -- Maximum meaningful detection
    
    if distance >= maxRange then
        return 0.0
    end
    
    -- Linear falloff: closer = higher chance
    return 1.0 - (distance / maxRange)
end

---Get noise modifier (movement/action increase detectability)
---@param unit table Unit to check
---@return number Noise modifier (0.5-2.0)
function ConcealmentDetection:_getNoiseModifier(unit)
    unit = unit or {}
    
    local baseNoise = 1.0
    
    -- Moving units are easier to detect
    if unit.isMoving then
        baseNoise = baseNoise + 0.3
    end
    
    -- Firing makes unit very visible
    if unit.justFired then
        baseNoise = baseNoise + 0.5
    end
    
    -- Recent damage
    if unit.recentlyDamaged then
        baseNoise = baseNoise + 0.2
    end
    
    return math.min(2.0, baseNoise)
end

return ConcealmentDetection
