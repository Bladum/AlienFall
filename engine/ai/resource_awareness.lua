--- Resource Awareness System - Ammo, energy, budget, and research awareness
---
--- Monitors and evaluates resource constraints in combat and strategic decisions.
--- Helps AI make smart choices about ammunition conservation, energy management,
--- budget constraints, and research technology state.
---
--- Key Features:
--- - Ammo checking before aggressive action
--- - Energy conservation and management
--- - Research state evaluation
--- - Budget consideration in decisions
--- - Conservation scoring
---
--- Usage:
---   local Resources = require("engine.ai.resource_awareness")
---   local res = Resources:new()
---   local canShoot, reason = res:checkAmmoBeforeShoot(unit, weapon)
---   local score = res:getAmmoConservationScore(unit, battle_state)
---
--- @module engine.ai.resource_awareness
--- @author AlienFall Development Team

local ResourceAwareness = {}
ResourceAwareness.__index = ResourceAwareness

--- Initialize Resource Awareness
---@return table ResourceAwareness instance
function ResourceAwareness:new()
    local self = setmetatable({}, ResourceAwareness)
    print("[ResourceAwareness] Initialized")
    return self
end

--- Check if unit has enough ammo before shooting
---
---@param unit table Unit attempting to shoot
---@param weapon table Weapon to check
---@return boolean Can shoot or not
---@return string Reason
function ResourceAwareness:checkAmmoBeforeShoot(unit, weapon)
    weapon = weapon or {}
    
    -- Get ammo for this weapon type
    local weapon_type = weapon.type or "ballistic"
    local ammo_cost = weapon.cost_per_shot or 1
    local current_ammo = unit.ammo and unit.ammo[weapon_type] or 0
    
    if current_ammo < ammo_cost then
        return false, "Insufficient ammo"
    end
    
    -- Check if we should conserve ammo
    local max_ammo = unit.max_ammo or 100
    local low_ammo_threshold = max_ammo * 0.2  -- 20% = low
    
    if current_ammo < low_ammo_threshold then
        return true, "Low ammo - consider conserving"
    end
    
    return true, "Ammo OK"
end

--- Calculate ammo conservation score (0-100)
---
--- Higher score = lower ammo, need to conserve more
---
---@param unit table Unit to evaluate
---@param battleState table Current battle state
---@return number Conservation score (0-100)
function ResourceAwareness:getAmmoConservationScore(unit, battleState)
    battleState = battleState or {}
    
    local score = 0
    
    -- Estimate turns remaining in battle
    local estimated_turns = battleState.turns_remaining or 5
    
    -- Estimate shots per turn (average)
    local avg_shots_per_turn = 3
    local ammo_needed = avg_shots_per_turn * estimated_turns
    
    -- Get current ammo (assume default weapon)
    local current_ammo = (unit.ammo and unit.ammo.primary) or 100
    local max_ammo = unit.max_ammo or 100
    
    -- Calculate conservation need
    if current_ammo < (ammo_needed * 50) then
        -- Low ammo: 50-100 conservation score
        local ratio = current_ammo / (ammo_needed * 50)
        score = 50 + ((1 - ratio) * 50)
    else
        -- Plenty of ammo: 0-50 conservation score
        local ratio = ammo_needed / (current_ammo / 50)
        score = math.min(ratio * 50, 50)
    end
    
    print(string.format("[ResourceAwareness] Ammo conservation: %d/100 (need %d shots, have %d ammo)",
        score, ammo_needed, current_ammo))
    
    return math.min(100, math.max(0, score))
end

--- Should unit switch to melee to conserve ammo?
---
---@param unit table Unit to evaluate
---@param target table Target to attack
---@param battleState table Battle state
---@return boolean Should use melee
function ResourceAwareness:shouldUseMelee(unit, target, battleState)
    battleState = battleState or {}
    
    local conservation_score = self:getAmmoConservationScore(unit, battleState)
    
    -- Get distance to target
    local distance = 1
    if unit.x and target and target.x then
        distance = math.sqrt((unit.x - target.x) ^ 2 + (unit.y - target.y) ^ 2)
    end
    
    -- Use melee if:
    -- 1. Close to target (distance < 2) AND
    -- 2. Ammo is running low (conservation_score > 60)
    
    if distance < 2 and conservation_score > 60 then
        print("[ResourceAwareness] Switching to melee to conserve ammo")
        return true
    end
    
    return false
end

--- Check energy status
---
---@param unit table Unit to check
---@param max_actions number Maximum actions this turn
---@return string Status ("CRITICAL", "LOW", or "OK")
---@return string Reason text
function ResourceAwareness:checkEnergy(unit, max_actions)
    max_actions = max_actions or 5
    
    local current_energy = unit.action_points or 100
    local energy_per_action = 20  -- Each action costs 20 energy
    
    local actions_possible = math.floor(current_energy / energy_per_action)
    
    if actions_possible < 1 then
        return "CRITICAL", "No action points remaining"
    elseif actions_possible < max_actions / 2 then
        return "LOW", "Energy running low - " .. actions_possible .. " actions remaining"
    else
        return "OK", "Energy sufficient - " .. actions_possible .. " actions possible"
    end
end

--- Recommend rest/consolidation
---
---@param unit table Unit to evaluate
---@param squad table Squad object (optional)
---@return boolean Should rest
---@return string Reason text
function ResourceAwareness:recommendRest(unit, squad)
    local reasons = {}
    
    -- Check ammo
    local ammo_score = self:getAmmoConservationScore(unit, {})
    if ammo_score > 70 then
        table.insert(reasons, "Low ammo - rest to recover")
    end
    
    -- Check energy
    local energy_status, _ = self:checkEnergy(unit, 5)
    if energy_status == "CRITICAL" then
        table.insert(reasons, "Energy critical - rest immediately")
    elseif energy_status == "LOW" then
        table.insert(reasons, "Energy low - consider resting")
    end
    
    -- Check health
    if unit.hp and unit.max_hp then
        local hp_ratio = unit.hp / unit.max_hp
        if hp_ratio < 0.3 then
            table.insert(reasons, "Heavily wounded - rest and heal")
        elseif hp_ratio < 0.6 then
            table.insert(reasons, "Damaged - seek cover")
        end
    end
    
    -- Check if squad has medic
    if squad and squad.roles and squad.roles.medic and squad.roles.medic > 0 then
        table.insert(reasons, "Medic available - get healing")
    end
    
    if #reasons > 0 then
        return true, table.concat(reasons, "; ")
    end
    
    return false, "Resources sufficient - continue combat"
end

--- Evaluate budget impact of decision
---
---@param base table Base object
---@param decision table Decision with cost field
---@return boolean Can afford
---@return string Reason
function ResourceAwareness:considerBudgetImpact(base, decision)
    decision = decision or {}
    
    if not decision.cost or decision.cost <= 0 then
        return true, "No cost associated"
    end
    
    local current_budget = base.credits or 100000
    local safety_margin = 5000  -- Keep 5000 credit reserve
    
    if decision.cost > current_budget - safety_margin then
        return false, string.format("Cost %d exceeds budget safety margin", decision.cost)
    end
    
    -- Warn if significant portion of budget
    if decision.cost > current_budget * 0.3 then
        return true, string.format("High cost (%d) - risky but affordable", decision.cost)
    end
    
    return true, "Budget OK"
end

--- Check if research state affects combat effectiveness
---
---@param unit table Unit to evaluate
---@param base table Base object with tech tree
---@param techType string Type of tech to check (armor, weapons, etc)
---@return number Armor bonus (0-20)
---@return number Damage bonus (0-20)
function ResourceAwareness:getResearchBonus(unit, base, techType)
    base = base or {}
    techType = techType or "general"
    
    local armor_bonus = 0
    local damage_bonus = 0
    
    -- Mock tech tree check if not available
    local researched_techs = base.researched_techs or {}
    
    -- Armor bonuses
    if researched_techs.advanced_armor or techType == "armor" then
        armor_bonus = armor_bonus + 10
    end
    if researched_techs.combat_armor then
        armor_bonus = armor_bonus + 5
    end
    
    -- Damage bonuses
    if researched_techs.advanced_weapons then
        damage_bonus = damage_bonus + 10
    end
    if researched_techs.plasma_weapons then
        damage_bonus = damage_bonus + 5
    end
    if researched_techs.weapon_upgrade_1 then
        damage_bonus = damage_bonus + 3
    end
    
    return armor_bonus, damage_bonus
end

--- Estimate tech impact on specific mission
---
---@param mission table Mission details
---@param base table Base object
---@return table Impact with bonus_to_hit, bonus_to_defense, equipment_available
function ResourceAwareness:techImpactOnMission(mission, base)
    base = base or {}
    mission = mission or {}
    
    local impact = {
        bonus_to_hit = 0,
        bonus_to_defense = 0,
        equipment_available = true,
        tech_readiness = "prepared"
    }
    
    local researched = base.researched_techs or {}
    
    -- Weapon tech bonuses
    if researched.plasma_weapons then
        impact.bonus_to_hit = impact.bonus_to_hit + 10
        impact.bonus_to_defense = impact.bonus_to_defense + 5
    end
    
    -- Armor tech bonuses
    if researched.combat_armor then
        impact.bonus_to_defense = impact.bonus_to_defense + 10
    end
    
    -- Advanced armor
    if researched.advanced_armor then
        impact.bonus_to_defense = impact.bonus_to_defense + 5
    end
    
    -- Check if mission requires specific tech
    if mission.requires_tech then
        impact.equipment_available = researched[mission.requires_tech] or false
        if not impact.equipment_available then
            impact.tech_readiness = "unprepared"
        end
    end
    
    -- Determine readiness level
    if impact.bonus_to_hit + impact.bonus_to_defense >= 20 then
        impact.tech_readiness = "well_prepared"
    elseif impact.bonus_to_hit + impact.bonus_to_defense >= 10 then
        impact.tech_readiness = "moderately_prepared"
    elseif impact.bonus_to_hit + impact.bonus_to_defense < 0 then
        impact.tech_readiness = "underprepared"
    end
    
    return impact
end

--- Get resource status summary
---
---@param unit table Unit to check
---@param base table Base object (optional)
---@param battleState table Battle state (optional)
---@return string Summary text
function ResourceAwareness:getResourceSummary(unit, base, battleState)
    base = base or {}
    battleState = battleState or {}
    
    local ammo_score = self:getAmmoConservationScore(unit, battleState)
    local energy_status, energy_msg = self:checkEnergy(unit, 5)
    
    local hp_text = "OK"
    if unit.hp and unit.max_hp then
        local hp_ratio = unit.hp / unit.max_hp
        if hp_ratio < 0.3 then
            hp_text = "CRITICAL"
        elseif hp_ratio < 0.6 then
            hp_text = "DAMAGED"
        end
    end
    
    local summary = string.format(
        "Resources: Ammo(%d) Energy(%s) Health(%s)",
        ammo_score,
        energy_status,
        hp_text
    )
    
    return summary
end

--- Evaluate overall combat readiness
---
---@param unit table Unit to evaluate
---@param squad table Squad (optional)
---@param base table Base (optional)
---@return string Readiness level (excellent/good/fair/poor/critical)
---@return string Details
function ResourceAwareness:evaluateCombatReadiness(unit, squad, base)
    base = base or {}
    
    local readiness_score = 0
    local factors = {}
    
    -- Ammo status (max 25 points)
    local ammo_score = self:getAmmoConservationScore(unit, {})
    if ammo_score < 30 then
        readiness_score = readiness_score + 25
        table.insert(factors, "Ammo: Full")
    elseif ammo_score < 60 then
        readiness_score = readiness_score + 15
        table.insert(factors, "Ammo: Moderate")
    else
        readiness_score = readiness_score + 5
        table.insert(factors, "Ammo: Low")
    end
    
    -- Energy status (max 25 points)
    local energy_status, _ = self:checkEnergy(unit, 5)
    if energy_status == "OK" then
        readiness_score = readiness_score + 25
        table.insert(factors, "Energy: Full")
    elseif energy_status == "LOW" then
        readiness_score = readiness_score + 10
        table.insert(factors, "Energy: Low")
    else
        readiness_score = readiness_score + 2
        table.insert(factors, "Energy: Critical")
    end
    
    -- Health status (max 25 points)
    if unit.hp and unit.max_hp then
        local hp_ratio = unit.hp / unit.max_hp
        if hp_ratio > 0.8 then
            readiness_score = readiness_score + 25
            table.insert(factors, "Health: Excellent")
        elseif hp_ratio > 0.5 then
            readiness_score = readiness_score + 15
            table.insert(factors, "Health: Good")
        elseif hp_ratio > 0.25 then
            readiness_score = readiness_score + 5
            table.insert(factors, "Health: Wounded")
        else
            readiness_score = readiness_score + 1
            table.insert(factors, "Health: Critical")
        end
    end
    
    -- Tech bonus (max 25 points)
    local armor, damage = self:getResearchBonus(unit, base, "general")
    local tech_bonus = armor + damage
    readiness_score = readiness_score + math.min(tech_bonus, 25)
    table.insert(factors, string.format("Tech: +%d", tech_bonus))
    
    -- Determine readiness level
    local readiness_level = "critical"
    if readiness_score >= 85 then
        readiness_level = "excellent"
    elseif readiness_score >= 70 then
        readiness_level = "good"
    elseif readiness_score >= 50 then
        readiness_level = "fair"
    elseif readiness_score >= 25 then
        readiness_level = "poor"
    end
    
    local details = string.format("Score %d/100 - %s", readiness_score, table.concat(factors, ", "))
    
    return readiness_level, details
end

return ResourceAwareness




