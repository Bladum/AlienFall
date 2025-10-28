--- Facility Adjacency Bonus System - Facility Placement Efficiency
---
--- Manages facility adjacency bonuses that provide strategic depth to base management.
--- Players can optimize their base layout to gain efficiency bonuses through careful
--- facility placement.
---
--- Adjacency Bonuses:
---   1. Lab + Workshop: +10% research & manufacturing speed (adjacent)
---   2. Workshop + Storage: -10% material cost (adjacent)
---   3. Hospital + Barracks: +1 HP/week & +1 Sanity/week (adjacent)
---   4. Garage + Hangar: +15% craft repair speed (adjacent)
---   5. Power + Lab/Workshop: +10% efficiency (within 2-hex)
---   6. Radar + Turret: +10% targeting accuracy (adjacent)
---   7. Academy + Barracks: +1 XP/week (adjacent)
---
--- Technical Details:
---   - Adjacency: Directly touching neighbors (4-way on square grid)
---   - Range bonuses: Within N tiles
---   - Stacking: Maximum 3-4 bonuses per facility (stacking limit)
---   - Recalculation: When facility built/destroyed/modified
---   - UI Display: Shows bonus icons and percentages
---
--- Usage:
---   local AdjacencySystem = require("basescape.systems.adjacency_bonus_system")
---   local bonuses = AdjacencySystem.new()
---   local labBonus = bonuses:calculateBonus(base, "lab", 2, 2)
---   bonuses:updateAllBonuses(base)
---   local info = bonuses:getAdjacencyInfo(base, "lab", 2, 2)
---
--- @module basescape.systems.adjacency_bonus_system
--- @author AlienFall Development Team
--- @copyright 2025 AlienFall Project
--- @license Open Source

local AdjacencySystem = {}
AdjacencySystem.__index = AdjacencySystem

-- Adjacency bonus definitions
local ADJACENCY_BONUSES = {
    -- Lab + Workshop: +10% research & manufacturing speed
    lab_workshop = {
        id = "lab_workshop",
        name = "Research Partnership",
        description = "Lab adjacent to Workshop",
        bonusTypes = {"research_speed", "manufacturing_speed"},
        bonusValue = 0.10,
        range = 1,
        facilities = {"laboratory", "workshop"},
        icon = "icon_lab_workshop"
    },
    
    -- Workshop + Storage: -10% material cost
    workshop_storage = {
        id = "workshop_storage",
        name = "Material Proximity",
        description = "Workshop adjacent to Storage",
        bonusTypes = {"material_cost"},
        bonusValue = -0.10,  -- Negative = reduction/improvement
        range = 1,
        facilities = {"workshop", "storage"},
        icon = "icon_workshop_storage"
    },
    
    -- Hospital + Barracks: +1 HP/week & +1 Sanity/week
    hospital_barracks = {
        id = "hospital_barracks",
        name = "Medical Support",
        description = "Hospital adjacent to Barracks",
        bonusTypes = {"hp_recovery", "sanity_recovery"},
        bonusValue = 1,  -- per week
        range = 1,
        facilities = {"medical_bay", "barracks"},
        icon = "icon_hospital_barracks"
    },
    
    -- Garage + Hangar: +15% craft repair speed
    garage_hangar = {
        id = "garage_hangar",
        name = "Maintenance Efficiency",
        description = "Garage adjacent to Hangar",
        bonusTypes = {"repair_speed"},
        bonusValue = 0.15,
        range = 1,
        facilities = {"garage", "hangar"},
        icon = "icon_garage_hangar"
    },
    
    -- Power + Lab/Workshop: +10% efficiency (within 2-hex)
    power_efficiency = {
        id = "power_efficiency",
        name = "Power Proximity",
        description = "Lab/Workshop within 2 hexes of Power Plant",
        bonusTypes = {"research_speed", "manufacturing_speed"},
        bonusValue = 0.10,
        range = 2,
        facilities = {"power_plant", "laboratory", "workshop"},
        icon = "icon_power_proximity"
    },
    
    -- Radar + Turret: +10% targeting accuracy
    radar_turret = {
        id = "radar_turret",
        name = "Fire Control System",
        description = "Radar adjacent to Defense Turret",
        bonusTypes = {"targeting_accuracy"},
        bonusValue = 0.10,
        range = 1,
        facilities = {"radar", "turret"},
        icon = "icon_radar_turret"
    },
    
    -- Academy + Barracks: +1 XP/week
    academy_barracks = {
        id = "academy_barracks",
        name = "Training Program",
        description = "Academy adjacent to Barracks",
        bonusTypes = {"xp_generation"},
        bonusValue = 1,  -- per week
        range = 1,
        facilities = {"academy", "barracks"},
        icon = "icon_academy_barracks"
    }
}

-- Bonus type groups
local BONUS_CATEGORIES = {
    research_speed = "Research",
    manufacturing_speed = "Manufacturing",
    material_cost = "Economy",
    hp_recovery = "Health",
    sanity_recovery = "Morale",
    repair_speed = "Maintenance",
    targeting_accuracy = "Defense",
    xp_generation = "Experience"
}

-- Maximum stacking limits per facility type
local MAX_BONUSES_PER_FACILITY = {
    laboratory = 4,
    workshop = 4,
    storage = 3,
    medical_bay = 3,
    barracks = 3,
    garage = 2,
    hangar = 2,
    power_plant = 3,
    radar = 2,
    turret = 2,
    academy = 2,
    default = 3
}

--- Initialize adjacency system
--- @return table AdjacencySystem instance
function AdjacencySystem.new()
    local self = setmetatable({}, AdjacencySystem)
    self.bonusCache = {}  -- Cache for performance
    print("[AdjacencySystem] Initialized")
    return self
end

--- Get neighbors of a facility position
--- @param base table Base entity
--- @param x number Column (0-indexed)
--- @param y number Row (0-indexed)
--- @param range number Max distance (default 1)
--- @return table Array of neighbor info {x, y, facility, distance}
function AdjacencySystem:getNeighbors(base, x, y, range)
    range = range or 1
    local neighbors = {}
    
    if not base.grid then
        return neighbors
    end
    
    local height = #base.grid
    local width = base.grid[1] and #base.grid[1] or 0
    
    -- Check all positions within range
    for dy = -range, range do
        for dx = -range, range do
            if not (dx == 0 and dy == 0) then  -- Skip self
                local nx = x + dx
                local ny = y + dy
                
                -- Check bounds
                if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
                    local facility = base.grid[ny][nx]
                    if facility and facility ~= "EMPTY" then
                        local distance = math.max(math.abs(dx), math.abs(dy))
                        table.insert(neighbors, {
                            x = nx - 1,
                            y = ny - 1,
                            facility = facility,
                            distance = distance
                        })
                    end
                end
            end
        end
    end
    
    return neighbors
end

--- Calculate bonuses for a facility at given position
--- @param base table Base entity
--- @param facilityType string Type of facility (e.g., "laboratory")
--- @param x number Column (0-indexed)
--- @param y number Row (0-indexed)
--- @return table Array of active bonuses
function AdjacencySystem:calculateBonus(base, facilityType, x, y)
    local activeBonuses = {}
    local neighbors = self:getNeighbors(base, x + 1, y + 1, 2)
    
    -- Check each adjacency bonus rule
    for bonusId, bonusRule in pairs(ADJACENCY_BONUSES) do
        -- Check if current facility is part of this bonus rule
        local isInvolvedFacility = false
        for _, fac in ipairs(bonusRule.facilities) do
            if fac == facilityType then
                isInvolvedFacility = true
                break
            end
        end
        
        if isInvolvedFacility then
            -- Check for required adjacent facility
            for _, neighbor in ipairs(neighbors) do
                if neighbor.distance <= bonusRule.range then
                    for _, requiredFac in ipairs(bonusRule.facilities) do
                        if requiredFac ~= facilityType and requiredFac == neighbor.facility then
                            -- Bonus condition met
                            table.insert(activeBonuses, {
                                id = bonusId,
                                name = bonusRule.name,
                                description = bonusRule.description,
                                types = bonusRule.bonusTypes,
                                value = bonusRule.bonusValue,
                                range = bonusRule.range,
                                icon = bonusRule.icon
                            })
                            break
                        end
                    end
                end
            end
        end
    end
    
    return activeBonuses
end

--- Get all active bonuses for entire base
--- @param base table Base entity
--- @return table Map of {x_y => array of bonuses}
function AdjacencySystem:getAllBonuses(base)
    local allBonuses = {}
    
    if not base.grid then
        return allBonuses
    end
    
    local height = #base.grid
    local width = base.grid[1] and #base.grid[1] or 0
    
    -- Calculate bonuses for each facility
    for y = 1, height do
        for x = 1, width do
            local facility = base.grid[y][x]
            if facility and facility ~= "EMPTY" then
                local bonuses = self:calculateBonus(base, facility, x - 1, y - 1)
                if #bonuses > 0 then
                    allBonuses[(x - 1) .. "_" .. (y - 1)] = bonuses
                end
            end
        end
    end
    
    return allBonuses
end

--- Get bonus information for display
--- @param base table Base entity
--- @param facilityType string Type of facility
--- @param x number Column (0-indexed)
--- @param y number Row (0-indexed)
--- @return table Bonus info {hasBonus, count, details}
function AdjacencySystem:getAdjacencyInfo(base, facilityType, x, y)
    local bonuses = self:calculateBonus(base, facilityType, x, y)
    
    -- Group by category
    local byCategory = {}
    for _, bonus in ipairs(bonuses) do
        for _, bonusType in ipairs(bonus.types) do
            local category = BONUS_CATEGORIES[bonusType] or "Other"
            if not byCategory[category] then
                byCategory[category] = {}
            end
            table.insert(byCategory[category], bonus)
        end
    end
    
    return {
        hasBonus = #bonuses > 0,
        count = #bonuses,
        total = bonuses,
        byCategory = byCategory,
        summary = self:generateSummary(bonuses)
    }
end

--- Generate human-readable bonus summary
--- @param bonuses table Array of bonuses
--- @return string Summary text
function AdjacencySystem:generateSummary(bonuses)
    if #bonuses == 0 then
        return "No adjacency bonuses"
    end
    
    local summaries = {}
    for _, bonus in ipairs(bonuses) do
        local typeStr = table.concat(bonus.types, ", ")
        local valStr = string.format("%+.0f%%", bonus.value * 100)
        table.insert(summaries, string.format("%s: %s", bonus.name, valStr))
    end
    
    return table.concat(summaries, "; ")
end

--- Calculate efficiency multiplier for a facility
--- @param bonuses table Array of bonuses for facility
--- @param bonusType string Type to calculate (e.g., "research_speed")
--- @return number Efficiency multiplier (1.0 = no bonus)
function AdjacencySystem:getEfficiencyMultiplier(bonuses, bonusType)
    local multiplier = 1.0
    
    for _, bonus in ipairs(bonuses) do
        for _, bType in ipairs(bonus.types) do
            if bType == bonusType then
                multiplier = multiplier * (1.0 + bonus.value)
            end
        end
    end
    
    return math.max(0.5, math.min(2.0, multiplier))  -- Clamp 0.5x to 2.0x
end

--- Update all bonuses when base changes
--- @param base table Base entity
function AdjacencySystem:updateAllBonuses(base)
    self.bonusCache = self:getAllBonuses(base)
    print(string.format("[AdjacencySystem] Updated bonuses for base %s (%d positions with bonuses)",
        base.name, self:countBonusedFacilities()))
end

--- Count how many facilities have bonuses
--- @return number Count of facilities with bonuses
function AdjacencySystem:countBonusedFacilities()
    local count = 0
    for _ in pairs(self.bonusCache) do
        count = count + 1
    end
    return count
end

--- Get all bonus types
--- @return table Array of {id, name, description}
function AdjacencySystem:getAllBonusTypes()
    local types = {}
    for id, bonus in pairs(ADJACENCY_BONUSES) do
        table.insert(types, {
            id = id,
            name = bonus.name,
            description = bonus.description,
            facilities = bonus.facilities,
            range = bonus.range
        })
    end
    return types
end

--- Validate if placement would exceed stacking limit
--- @param base table Base entity
--- @param facilityType string Type of facility to check
--- @param x number Column (0-indexed)
--- @param y number Row (0-indexed)
--- @return boolean Is valid placement
function AdjacencySystem:isValidPlacement(base, facilityType, x, y)
    local bonuses = self:calculateBonus(base, facilityType, x, y)
    local maxAllowed = MAX_BONUSES_PER_FACILITY[facilityType] or MAX_BONUSES_PER_FACILITY.default
    
    return #bonuses <= maxAllowed
end

return AdjacencySystem




