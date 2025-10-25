-- UFO AI Behavior System
-- Governs UFO combat tactics, evasion patterns, and adaptive intelligence

local UFOAIBehavior = {}
UFOAIBehavior.__index = UFOAIBehavior

-- Initialize UFO AI
function UFOAIBehavior.new()
    local self = setmetatable({}, UFOAIBehavior)
    
    -- UFO intelligence levels
    self.INTELLIGENCE_LEVELS = {
        SCOUT = { tactics = "aggressive", adaptability = 0.3, reactions = 0.4 },
        FIGHTER = { tactics = "tactical", adaptability = 0.6, reactions = 0.7 },
        LEADER = { tactics = "strategic", adaptability = 0.8, reactions = 0.9 },
        HARVESTER = { tactics = "evasive", adaptability = 0.5, reactions = 0.5 }
    }
    
    -- Behavior states
    self.STATES = {
        SCANNING = "scanning",
        ENGAGING = "engaging",
        PURSUING = "pursuing",
        EVADING = "evading",
        RETREATING = "retreating",
        CHARGING = "charging"
    }
    
    return self
end

-- Get UFO intelligence profile
function UFOAIBehavior:getUFOIntelligence(ufoClass)
    local classUpper = string.upper(ufoClass or "SCOUT")
    return self.INTELLIGENCE_LEVELS[classUpper] or self.INTELLIGENCE_LEVELS.SCOUT
end

-- Determine next UFO action based on combat state
function UFOAIBehavior:decideAction(ufo, craft, deltaTime)
    local intelligence = self:getUFOIntelligence(ufo.class)
    local action = {}
    
    -- Evaluate current situation
    local threat = self:evaluateThreat(ufo, craft)
    local opportunity = self:evaluateOpportunity(ufo, craft)
    
    -- State machine for UFO behavior
    if ufo.state == self.STATES.SCANNING then
        if threat > 0.5 then
            ufo.state = self.STATES.ENGAGING
        elseif opportunity > 0.7 then
            ufo.state = self.STATES.ENGAGING
        end
        
    elseif ufo.state == self.STATES.ENGAGING then
        action = self:engagementAction(ufo, craft, intelligence)
        
        if ufo.health < ufo.maxHealth * 0.3 then
            ufo.state = self.STATES.EVADING
        end
        
    elseif ufo.state == self.STATES.PURSUING then
        action = self:pursuitAction(ufo, craft, intelligence)
        
        if ufo.distance > 15000 then
            ufo.state = self.STATES.SCANNING
        end
        
    elseif ufo.state == self.STATES.EVADING then
        action = self:evasionAction(ufo, craft, intelligence)
        
        if ufo.health > ufo.maxHealth * 0.6 then
            ufo.state = self.STATES.ENGAGING
        elseif ufo.distance > 20000 then
            ufo.state = self.STATES.RETREATING
        end
        
    elseif ufo.state == self.STATES.RETREATING then
        action = self:retreatAction(ufo, craft)
        
    elseif ufo.state == self.STATES.CHARGING then
        action = self:chargeAction(ufo, craft, intelligence)
    end
    
    return action
end

-- Evaluate threat level from craft
function UFOAIBehavior:evaluateThreat(ufo, craft)
    local threat = 0.5 -- Base threat
    
    -- Distance factor (closer = more threat)
    local distanceFactor = 1 - math.min(1, ufo.distance / 20000)
    threat = threat + (distanceFactor * 0.3)
    
    -- Craft weapons factor
    local weaponThreat = (craft.activeWeapons or 0) / 4
    threat = threat + (weaponThreat * 0.2)
    
    -- Damage factor (more damage = more threat)
    local damageFactor = 1 - (craft.health / craft.maxHealth)
    threat = threat - (damageFactor * 0.1)
    
    return math.min(1, threat)
end

-- Evaluate opportunity for attack
function UFOAIBehavior:evaluateOpportunity(ufo, craft)
    local opportunity = 0.5
    
    -- Altitude advantage
    local altitudeDiff = ufo.altitude - craft.altitude
    if math.abs(altitudeDiff) > 5000 then
        opportunity = opportunity + 0.2
    elseif math.abs(altitudeDiff) < 1000 then
        opportunity = opportunity - 0.1
    end
    
    -- Range advantage
    if ufo.distance < 3000 then
        opportunity = opportunity + 0.3
    elseif ufo.distance > 10000 then
        opportunity = opportunity - 0.2
    end
    
    -- Shields status
    if ufo.shieldsIntegrity > 0.8 then
        opportunity = opportunity + 0.1
    elseif ufo.shieldsIntegrity < 0.3 then
        opportunity = opportunity - 0.2
    end
    
    return math.min(1, opportunity)
end

-- Engagement tactics - attack the craft
function UFOAIBehavior:engagementAction(ufo, craft, intelligence)
    local action = {
        type = "ENGAGE",
        moveTowards = true,
        fireWeapons = true,
        targetComponent = nil
    }
    
    -- Intelligent targeting based on intelligence level
    local adaptability = intelligence.adaptability or 0.5
    
    if math.random() < adaptability then
        -- Target weak points
        if craft.armor < 50 then
            action.targetComponent = "ENGINES"
        elseif craft.systems < 0.7 then
            action.targetComponent = "SYSTEMS"
        else
            action.targetComponent = "HULL"
        end
    else
        -- Generic targeting
        action.targetComponent = "HULL"
    end
    
    -- Positioning tactics
    if intelligence.tactics == "aggressive" then
        action.desiredRange = 2000
        action.desiredAltitude = craft.altitude + 2000
    elseif intelligence.tactics == "tactical" then
        action.desiredRange = 5000
        action.desiredAltitude = craft.altitude + 1000
    elseif intelligence.tactics == "strategic" then
        action.desiredRange = 3000
        action.desiredAltitude = craft.altitude + 3000
    elseif intelligence.tactics == "evasive" then
        action.desiredRange = 8000
        action.desiredAltitude = craft.altitude - 2000
    end
    
    return action
end

-- Pursuit tactics - chase the craft
function UFOAIBehavior:pursuitAction(ufo, craft, intelligence)
    local action = {
        type = "PURSUE",
        moveTowards = true,
        fireWeapons = false,
        interceptCourse = true
    }
    
    -- Calculate intercept point
    local relativeBearing = math.atan2(craft.y - ufo.y, craft.x - ufo.x)
    action.heading = math.deg(relativeBearing)
    
    -- Speed adjustment based on intelligence
    if intelligence.adaptability > 0.7 then
        -- Use afterburners if available
        action.useAfterburners = true
    end
    
    return action
end

-- Evasion tactics - flee or dodge
function UFOAIBehavior:evasionAction(ufo, craft, intelligence)
    local action = {
        type = "EVADE",
        moveAway = true,
        fireWeapons = false,
        driftPattern = true
    }
    
    -- Evasion pattern based on intelligence
    local pattern = math.random(1, 3)
    
    if pattern == 1 then
        action.pattern = "ZIGZAG" -- Unpredictable side-to-side
    elseif pattern == 2 then
        action.pattern = "CLIMB" -- Rapidly gain altitude
    else
        action.pattern = "SPIRAL" -- Circular evasion
    end
    
    -- Intensity of evasion
    action.intensity = intelligence.reactions
    
    return action
end

-- Retreat tactics - leave combat
function UFOAIBehavior:retreatAction(ufo, craft)
    local action = {
        type = "RETREAT",
        moveAway = true,
        fireWeapons = false,
        hyperspace = true, -- Attempt faster-than-light escape
        heading = (ufo.entryHeading + 180) % 360 -- Head back the way it came
    }
    
    return action
end

-- Charge tactics - aggressive attack
function UFOAIBehavior:chargeAction(ufo, craft, intelligence)
    local action = {
        type = "CHARGE",
        moveTowards = true,
        fireWeapons = true,
        aggressive = true,
        allWeapons = true -- Use all available weapons
    }
    
    action.desiredRange = 1000
    action.desiredAltitude = craft.altitude
    
    return action
end

-- Adapt UFO tactics based on combat history
function UFOAIBehavior:adaptTactics(ufo, combatHistory)
    local intelligence = self:getUFOIntelligence(ufo.class)
    
    if intelligence.adaptability < 0.6 then
        return -- Low intelligence doesn't adapt
    end
    
    -- Analyze what's working
    local successRate = 0
    local totalAttempts = 0
    
    for _, action in ipairs(combatHistory) do
        totalAttempts = totalAttempts + 1
        if action.success then
            successRate = successRate + 1
        end
    end
    
    local successPercent = successRate / math.max(1, totalAttempts)
    
    -- Adapt tactics if success rate is low
    if successPercent < 0.3 then
        if ufo.tactic == "AGGRESSIVE" then
            ufo.tactic = "TACTICAL"
        elseif ufo.tactic == "TACTICAL" then
            ufo.tactic = "EVASIVE"
        end
    elseif successPercent > 0.7 then
        if ufo.tactic == "EVASIVE" then
            ufo.tactic = "TACTICAL"
        elseif ufo.tactic == "TACTICAL" then
            ufo.tactic = "AGGRESSIVE"
        end
    end
end

-- Get UFO weapon selection based on range
function UFOAIBehavior:selectWeapon(ufo, distance)
    local weapons = ufo.weapons or {}
    local bestWeapon = nil
    local bestScore = -1
    
    for _, weapon in ipairs(weapons) do
        if weapon.ammo > 0 and distance <= weapon.maxRange then
            -- Scoring: closer to optimal range = higher score
            local rangeScore = 1 - (math.abs(distance - weapon.optimalRange) / weapon.maxRange)
            local damageScore = weapon.damage / 100
            local accuracyScore = weapon.accuracy or 0.7
            
            local totalScore = (rangeScore * 0.4) + (damageScore * 0.4) + (accuracyScore * 0.2)
            
            if totalScore > bestScore then
                bestScore = totalScore
                bestWeapon = weapon
            end
        end
    end
    
    return bestWeapon
end

-- Calculate UFO evasion difficulty
function UFOAIBehavior:getEvasionDifficulty(ufo)
    local intelligence = self:getUFOIntelligence(ufo.class)
    
    local difficulty = 0.5 -- Base
    
    -- More intelligent = harder to hit
    difficulty = difficulty + (intelligence.adaptability * 0.3)
    
    -- Damaged UFO is easier to hit
    local damagePercent = 1 - (ufo.health / ufo.maxHealth)
    difficulty = difficulty - (damagePercent * 0.2)
    
    return math.max(0.1, math.min(1, difficulty))
end

-- Get UFO combat prediction
function UFOAIBehavior:predictUFOAction(ufo, craft, history)
    if #history == 0 then
        return self:decideAction(ufo, craft, 0.016) -- Default action
    end
    
    -- Look at last few actions
    local recentActions = {}
    for i = math.max(1, #history - 3), #history do
        table.insert(recentActions, history[i])
    end
    
    -- Pattern recognition
    local likelyNextAction = recentActions[#recentActions] or "ENGAGE"
    
    return likelyNextAction
end

return UFOAIBehavior

