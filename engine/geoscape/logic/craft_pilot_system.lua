---Craft Pilot Bonus System
---
---Calculates and applies bonuses to craft from pilot stats.
---Pilot abilities directly enhance craft performance.
---
---Key Features:
---  - Pilot stat to craft bonus mapping
---  - Multi-pilot stacking
---  - Dynamic bonus calculation
---  - Bonus application system
---
---Key Exports:
---  - CraftPilotSystem.calculateBonuses() - Calculate all bonuses
---  - CraftPilotSystem.applyBonuses() - Apply to craft stats
---  - CraftPilotSystem.getBonus() - Get specific bonus
---
---Dependencies:
---  - None (standalone system)
---
---@module CraftPilotSystem
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local CraftPilotSystem = {}

---Pilot stat to craft bonus mapping
---Maps pilot stats to affected craft stats
CraftPilotSystem.STAT_MAPPING = {
    -- Pilot SPEED affects craft speed
    speed = {
        craft_stat = "speed",
        bonus_per_point = 1,  -- 1% per 1 point
        max_bonus = 30,  -- Cap at 30%
    },
    
    -- Pilot AIM affects craft accuracy
    aim = {
        craft_stat = "accuracy",
        bonus_per_point = 1,
        max_bonus = 25,
    },
    
    -- Pilot REACTION affects craft evasion/dodge
    reaction = {
        craft_stat = "evasion",
        bonus_per_point = 1,
        max_bonus = 25,
    },
    
    -- Pilot STRENGTH affects weapon damage
    strength = {
        craft_stat = "damage",
        bonus_per_point = 0.5,
        max_bonus = 20,
    },
    
    -- Pilot ENERGY affects craft energy pool
    energy = {
        craft_stat = "energy",
        bonus_per_point = 2,  -- 2% per 1 point
        max_bonus = 25,
    },
    
    -- Pilot WISDOM affects sensor range
    wisdom = {
        craft_stat = "sensor_range",
        bonus_per_point = 5,  -- 5% per 1 point
        max_bonus = 30,
    },
    
    -- Pilot PSI affects psionic defense
    psi = {
        craft_stat = "psi_defense",
        bonus_per_point = 0.5,
        max_bonus = 15,
    },
}

---Calculate bonuses from a single pilot
---@param pilotStats table - Pilot stats {speed, aim, reaction, strength, energy, wisdom, psi}
---@return table - Calculated bonuses {craft_stat -> percentage}
function CraftPilotSystem.calculatePilotBonuses(pilotStats)
    if not pilotStats or type(pilotStats) ~= "table" then
        return {}
    end
    
    local bonuses = {}
    
    for pilotStat, mapping in pairs(CraftPilotSystem.STAT_MAPPING) do
        if pilotStats[pilotStat] then
            local statValue = pilotStats[pilotStat]
            local baseBonus = (statValue - 5) * mapping.bonus_per_point  -- Base is 5
            local cappedBonus = math.min(baseBonus, mapping.max_bonus)
            
            if not bonuses[mapping.craft_stat] then
                bonuses[mapping.craft_stat] = 0
            end
            
            bonuses[mapping.craft_stat] = bonuses[mapping.craft_stat] + cappedBonus
        end
    end
    
    return bonuses
end

---Calculate combined bonuses from multiple pilots
---@param pilotsList table - Array of pilot stat tables
---@return table - Combined bonuses (stacked from all pilots)
function CraftPilotSystem.calculateCombinedBonuses(pilotsList)
    if not pilotsList or type(pilotsList) ~= "table" or #pilotsList == 0 then
        return {}
    end
    
    local combined = {}
    
    for _, pilotStats in ipairs(pilotsList) do
        local pilotBonuses = CraftPilotSystem.calculatePilotBonuses(pilotStats)
        
        for craftStat, bonus in pairs(pilotBonuses) do
            if not combined[craftStat] then
                combined[craftStat] = 0
            end
            combined[craftStat] = combined[craftStat] + bonus
        end
    end
    
    -- Calculate average (bonuses stack but with diminishing returns)
    for craftStat, total in pairs(combined) do
        local pilotCount = #pilotsList
        -- Apply diminishing returns: each pilot after the first contributes 50% as much
        local averageBonus = (total / pilotCount)
        
        -- Apply cap per stat
        local mapping = CraftPilotSystem.STAT_MAPPING[craftStat]
        if mapping and averageBonus > mapping.max_bonus then
            averageBonus = mapping.max_bonus
        end
        
        combined[craftStat] = averageBonus
    end
    
    return combined
end

---Apply bonuses to craft stats
---@param craftStats table - Craft stats table to modify
---@param bonuses table - Bonuses to apply {craft_stat -> percentage}
function CraftPilotSystem.applyBonuses(craftStats, bonuses)
    if not craftStats or not bonuses then
        return
    end
    
    for stat, bonus in pairs(bonuses) do
        if craftStats[stat] then
            -- Apply as percentage increase
            local originalValue = craftStats[stat]
            local increase = (originalValue * bonus) / 100
            craftStats[stat] = originalValue + increase
        end
    end
end

---Get bonus for specific craft stat
---@param bonuses table - Bonuses table
---@param craftStat string - Craft stat to check
---@return number - Bonus percentage for this stat
function CraftPilotSystem.getBonus(bonuses, craftStat)
    if not bonuses or not craftStat then
        return 0
    end
    
    return bonuses[craftStat] or 0
end

---Format bonuses for display
---@param bonuses table - Bonuses to format
---@return table - Formatted for UI display
function CraftPilotSystem.formatBonusesForDisplay(bonuses)
    if not bonuses or type(bonuses) ~= "table" then
        return {}
    end
    
    local display = {}
    
    for stat, bonus in pairs(bonuses) do
        if bonus ~= 0 then
            table.insert(display, {
                stat = stat,
                bonus = bonus,
                formatted = string.format("%s: %+.1f%%", stat, bonus),
                color = bonus > 0 and {0, 200, 0} or {200, 0, 0},  -- Green for positive, red for negative
            })
        end
    end
    
    return display
end

---Get bonus description for tooltip
---@param pilotCount number - Number of pilots
---@param bonuses table - Bonuses to describe
---@return string - Description text
function CraftPilotSystem.getBonusDescription(pilotCount, bonuses)
    if not bonuses or pilotCount <= 0 then
        return "No pilot bonuses"
    end
    
    local desc = string.format("Pilot bonus (%d pilot%s):\n", pilotCount, pilotCount > 1 and "s" or "")
    
    for stat, bonus in pairs(bonuses) do
        if bonus ~= 0 then
            desc = desc .. string.format("  %s: %+.1f%%\n", stat, bonus)
        end
    end
    
    return desc
end

return CraftPilotSystem
