--- Enhanced Threat Assessment - Multi-factor combat threat evaluation
---
--- Evaluates threats from enemies based on multiple factors:
--- - Damage potential (50% weight)
--- - Position advantage including flanking (30% weight)
--- - Range consideration (10% weight)
--- - Weapon effectiveness vs target armor (10% weight)
---
--- Provides prioritized threat lists for combat decision-making.
---
--- Usage:
---   local ThreatAssess = require("engine.ai.threat_assessment")
---   local assess = ThreatAssess:new()
---   local threat = assess:calculateThreat(attacker, target, battlefield)
---   local priority = assess:getPriorityTargets(unit, enemies, battlefield)
---
--- @module engine.ai.threat_assessment
--- @author AlienFall Development Team

local ThreatAssessment = {}
ThreatAssessment.__index = ThreatAssessment

--- Initialize Threat Assessment
---@return table ThreatAssessment instance
function ThreatAssessment:new()
    local self = setmetatable({}, ThreatAssessment)
    print("[ThreatAssessment] Initialized")
    return self
end

--- Calculate threat from attacker to target
---
--- Combines multiple factors into single threat score (0-100).
---
---@param attacker table Attacking unit
---@param target table Target unit
---@param battlefield table Battlefield data
---@return number Threat score (0-100, higher = more dangerous)
function ThreatAssessment:calculateThreat(attacker, target, battlefield)
    attacker = attacker or {}
    target = target or {}
    battlefield = battlefield or {}
    
    local threat = 0
    
    -- Factor 1: Damage Potential (50% weight)
    local damage_potential = self:estimateDamage(attacker, target)
    threat = threat + (damage_potential * 0.50)
    
    -- Factor 2: Position Advantage (30% weight)
    -- Includes flanking, high ground, cover
    local position_advantage = self:calculatePositionAdvantage(attacker, target, battlefield)
    threat = threat + (position_advantage * 0.30)
    
    -- Factor 3: Range Advantage (10% weight)
    local range_advantage = self:calculateRangeAdvantage(attacker, target)
    threat = threat + (range_advantage * 0.10)
    
    -- Factor 4: Weapon vs Armor (10% weight)
    local weapon_advantage = self:calculateWeaponAdvantage(attacker, target)
    threat = threat + (weapon_advantage * 0.10)
    
    -- Apply urgency multiplier if target is in cover
    if target.in_cover then
        threat = threat * 1.2  -- 20% more urgent to engage covered target
    end
    
    -- Apply awareness modifier
    if target.is_aware == false then
        threat = threat * 1.5  -- 50% more dangerous if unaware target exists
    end
    
    -- Clamp to 0-100
    threat = math.max(0, math.min(100, threat))
    
    print(string.format("[ThreatAssessment] Threat from attacker to target: %d/100", threat))
    
    return threat
end

--- Estimate damage from attacker's attack
---
--- Returns 0-100 scale representing expected damage.
---
---@param attacker table Attacking unit
---@param target table Target unit
---@return number Damage potential (0-100)
function ThreatAssessment:estimateDamage(attacker, target)
    local weapon = attacker.weapon or {}
    local base_damage = weapon.damage or 30
    
    -- Hit chance from attacker's accuracy
    local accuracy = attacker.accuracy or 50
    local hit_chance = accuracy / 100
    
    -- Armor reduction from target
    local armor = target.armor or 0
    local armor_reduction = armor / 100
    
    -- Expected damage after armor
    local expected_damage = base_damage * hit_chance * (1 - armor_reduction)
    
    -- Scale to 0-100: assume 50 is max expected damage
    local scaled_damage = math.min((expected_damage / 50) * 100, 100)
    
    print(string.format("[ThreatAssessment] Damage potential: base=%d, hit=%.0f%%, armor=%.0f%% → %d/100",
        base_damage, hit_chance * 100, armor_reduction * 100, scaled_damage))
    
    return scaled_damage
end

--- Calculate position advantage (flanking, high ground, cover)
---
--- Returns 0-100 scale.
---
---@param attacker table Attacking unit
---@param target table Target unit
---@param battlefield table Battlefield data
---@return number Position advantage (0-100)
function ThreatAssessment:calculatePositionAdvantage(attacker, target, battlefield)
    local advantage = 0
    
    -- Check if attacker is flanking target (30 points max)
    if self:isFlanking(attacker, target) then
        advantage = advantage + 30
    end
    
    -- Check if attacker is on high ground (20 points max)
    if attacker.elevation and target.elevation then
        if attacker.elevation > target.elevation then
            advantage = advantage + 20
        end
    end
    
    -- Check if target is surrounded (50 points max)
    local nearby_enemies = self:countNearbyEnemies(target, 3, battlefield)
    if nearby_enemies > 1 then
        advantage = advantage + math.min(nearby_enemies * 15, 50)
    end
    
    -- Check if attacker has cover (reduce advantage slightly)
    if attacker.in_cover then
        advantage = advantage + 10
    end
    
    return math.min(advantage, 100)
end

--- Check if attacker is flanking target
---
---@param attacker table Attacker position
---@param target table Target unit
---@return boolean Is flanking
function ThreatAssessment:isFlanking(attacker, target)
    if not attacker.x or not target.x or not target.facing then
        return false
    end
    
    -- Calculate relative angle
    local dx = attacker.x - target.x
    local dy = attacker.y - target.y
    local angle = math.atan2(dy, dx) * (180 / math.pi)
    
    -- Normalize angle to 0-360
    if angle < 0 then angle = angle + 360 end
    
    -- Get angle relative to target's facing direction
    local target_facing = (target.facing or 0) * (180 / math.pi)
    if target_facing < 0 then target_facing = target_facing + 360 end
    
    local relative_angle = math.abs(angle - target_facing)
    if relative_angle > 180 then
        relative_angle = 360 - relative_angle
    end
    
    -- Flanking if 45-135 degrees off to the side (not behind or in front)
    return relative_angle >= 45 and relative_angle <= 135
end

--- Count nearby enemies for cumulative threat
---
---@param unit table Unit to evaluate
---@param distance number Search distance
---@param battlefield table Battlefield data
---@return number Count of nearby enemies
function ThreatAssessment:countNearbyEnemies(unit, distance, battlefield)
    distance = distance or 3
    battlefield = battlefield or {}
    
    local count = 0
    
    if battlefield.enemies then
        for _, enemy in ipairs(battlefield.enemies) do
            if enemy ~= unit and enemy.x and unit.x then
                local dist = math.sqrt((enemy.x - unit.x) ^ 2 + (enemy.y - unit.y) ^ 2)
                if dist <= distance then
                    count = count + 1
                end
            end
        end
    end
    
    return count
end

--- Calculate range advantage
---
--- Returns 0-100 scale: higher = better range advantage.
---
---@param attacker table Attacking unit
---@param target table Target unit
---@return number Range advantage (0-100)
function ThreatAssessment:calculateRangeAdvantage(attacker, target)
    if not attacker.x or not target.x then
        return 50  -- Unknown range
    end
    
    local weapon = attacker.weapon or {}
    local distance = math.sqrt((attacker.x - target.x) ^ 2 + (attacker.y - target.y) ^ 2)
    local optimal_range = weapon.optimal_range or 5
    local max_range = weapon.max_range or 15
    
    -- Out of range
    if distance > max_range then
        return 0
    end
    
    -- Optimal range
    if distance <= optimal_range then
        return 100
    end
    
    -- Beyond optimal but within max
    local range_penalty = (distance - optimal_range) / (max_range - optimal_range)
    local advantage = 100 * (1.0 - (range_penalty * 0.5))
    
    return math.max(0, advantage)
end

--- Calculate weapon vs armor effectiveness
---
--- Returns 0-100 scale: higher = better effectiveness.
---
---@param attacker table Attacking unit
---@param target table Target unit
---@return number Weapon advantage (0-100)
function ThreatAssessment:calculateWeaponAdvantage(attacker, target)
    local weapon = attacker.weapon or {}
    local weapon_type = weapon.type or "ballistic"
    local target_armor_type = target.armor_type or "light"
    
    -- Weapon effectiveness matrix (0.4 to 1.0 scale)
    local effectiveness = {
        plasma = {
            light = 1.0,
            medium = 0.8,
            heavy = 0.6
        },
        ballistic = {
            light = 0.8,
            medium = 1.0,
            heavy = 0.9
        },
        laser = {
            light = 0.9,
            medium = 0.9,
            heavy = 0.7
        },
        melee = {
            light = 1.0,
            medium = 0.7,
            heavy = 0.4
        }
    }
    
    local eff_table = effectiveness[weapon_type] or {light = 0.8, medium = 0.8, heavy = 0.8}
    local eff = eff_table[target_armor_type] or 0.8
    
    -- Scale to 0-100
    return eff * 100
end

--- Get priority targets ranked by threat
---
--- Returns sorted list of threats, highest first.
---
---@param unit table Unit assessing threats
---@param enemies table Array of enemy units
---@param battlefield table Battlefield data
---@return table Ranked threats [{target=unit, threat=score, reason=text}, ...]
function ThreatAssessment:getPriorityTargets(unit, enemies, battlefield)
    battlefield = battlefield or {}
    local threats = {}
    
    for _, enemy in ipairs(enemies or {}) do
        local threat = self:calculateThreat(enemy, unit, battlefield)
        
        -- Generate threat reason
        local reason = ""
        if threat >= 75 then
            reason = "CRITICAL - High threat"
        elseif threat >= 60 then
            reason = "HIGH - Significant threat"
        elseif threat >= 40 then
            reason = "MODERATE - Standard threat"
        else
            reason = "LOW - Minor threat"
        end
        
        table.insert(threats, {
            target = enemy,
            threat = threat,
            reason = reason
        })
    end
    
    -- Sort by threat descending (highest threat first)
    table.sort(threats, function(a, b) return a.threat > b.threat end)
    
    return threats
end

--- Get cumulative threat from multiple enemies
---
---@param unit table Unit being threatened
---@param enemies table Array of enemy units
---@param battlefield table Battlefield data
---@return number Cumulative threat
---@return table Threat breakdown by enemy
function ThreatAssessment:getCumulativeThreat(unit, enemies, battlefield)
    local cumulative = 0
    local breakdown = {}
    
    for _, enemy in ipairs(enemies or {}) do
        local threat = self:calculateThreat(enemy, unit, battlefield)
        cumulative = cumulative + threat
        table.insert(breakdown, {enemy = enemy, threat = threat})
    end
    
    -- Average cumulative threat
    if #(enemies or {}) > 0 then
        cumulative = cumulative / #enemies
    end
    
    return cumulative, breakdown
end

--- Determine threat level name
---
---@param threat_score number Threat value (0-100)
---@return string Threat level name
function ThreatAssessment:getThreatLevelName(threat_score)
    if threat_score >= 80 then
        return "EXTREME"
    elseif threat_score >= 60 then
        return "HIGH"
    elseif threat_score >= 40 then
        return "MODERATE"
    elseif threat_score >= 20 then
        return "LOW"
    else
        return "MINIMAL"
    end
end

--- Get threat assessment report for UI
---
---@param threats table Ranked threats from getPriorityTargets
---@return string Report text
function ThreatAssessment:getThreatReport(threats)
    if not threats or #threats == 0 then
        return "No threats detected"
    end
    
    local report = "THREAT ASSESSMENT:\n"
    
    for i, threat_data in ipairs(threats) do
        if i <= 5 then  -- Show top 5
            local level = self:getThreatLevelName(threat_data.threat)
            report = report .. string.format(
                "%d. %s (%d/100) - %s\n",
                i,
                threat_data.target.name or ("Enemy " .. i),
                threat_data.threat,
                level
            )
        end
    end
    
    return report
end

return ThreatAssessment



