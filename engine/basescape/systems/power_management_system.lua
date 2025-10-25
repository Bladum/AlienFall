--- Power Management System - Facility Power Distribution
---
--- Manages power generation, distribution, and shortage mechanics.
--- Facilities require power to operate; power shortages cause temporary offline state.
--- Power plants generate power; deficiencies cause operational challenges.
---
--- Power Mechanics:
---   - Power Plants generate power
---   - Each facility consumes power when operational
---   - Power capacity limits total operational facilities
---   - Power shortage = automatic facility offline state
---   - Manual facility disable available for conservation
---   - UI shows power status and bottlenecks
---
--- Power States:
---   1. OPERATIONAL: Facility running at 100% (full power)
---   2. OFFLINE_POWER: Facility powered down (insufficient power)
---   3. OFFLINE_PLAYER: Facility manually disabled (player choice)
---   4. DAMAGED: Facility damaged, reduced power draw
---
--- Technical Details:
---   - Power calculated per-facility based on type
---   - Priority system: Strategic facilities prioritized
---   - Power distribution algorithm ensures critical systems stay online
---   - UI display: Power bar, shortage warnings, efficiency penalties
---
--- Usage:
---   local PowerSystem = require("basescape.systems.power_management_system")
---   local power = PowerSystem.new()
---   power:calculatePowerBudget(base)
---   local powerStatus = power:getPowerStatus(base)
---   power:updatePowerStates(base)
---   power:toggleFacilityPower(base, x, y)
---
--- @module basescape.systems.power_management_system
--- @author AlienFall Development Team
--- @copyright 2025 AlienFall Project
--- @license Open Source

local PowerSystem = {}
PowerSystem.__index = PowerSystem

-- Power consumption by facility type (watts / arbitrary units)
local POWER_CONSUMPTION = {
    power_plant = 0,       -- Generates power
    headquarters = 50,     -- Command center
    barracks = 40,         -- Personnel housing
    laboratory = 150,      -- Research power-hungry
    workshop = 120,        -- Manufacturing power-hungry
    storage = 30,          -- Simple storage
    radar = 200,           -- Radar power-hungry
    medical_bay = 80,      -- Medical equipment
    training_center = 50,  -- Training facilities
    garage = 60,           -- Craft maintenance
    hangar = 100,          -- Aircraft hangar
    academy = 50,          -- Academy
    corridor = 10,         -- Structural
    turret = 80,           -- Defense turret
    prison = 40,           -- Prison block
    temple = 30,           -- Temple/morale facility
}

-- Power generation by power plant type
local POWER_GENERATION = {
    power_plant_small = 300,
    power_plant_medium = 600,
    power_plant_large = 1000,
}

-- Facility priority for power distribution (higher = prioritized)
local POWER_PRIORITY = {
    power_plant = 100,     -- Always on first
    headquarters = 90,     -- Command center critical
    medical_bay = 80,      -- Medical emergencies
    barracks = 70,         -- Personnel safety
    hangar = 60,           -- Craft operations
    workshop = 50,         -- Manufacturing important
    laboratory = 50,       -- Research important
    radar = 40,            -- Detection important
    garage = 35,           -- Maintenance
    storage = 30,          -- Storage
    academy = 25,          -- Training
    turret = 20,           -- Defense
    prison = 15,           -- Prison
    training_center = 10,  -- Training
    corridor = 5,          -- Structural
}

--- Initialize power management system
--- @return table PowerSystem instance
function PowerSystem.new()
    local self = setmetatable({}, PowerSystem)
    self.powerCache = {}
    print("[PowerSystem] Initialized")
    return self
end

--- Calculate total power generation for base
--- @param base table Base entity with grid
--- @return number Total power generation
function PowerSystem:calculatePowerGeneration(base)
    if not base.grid then
        return 0
    end
    
    local totalPower = 0
    local height = #base.grid
    local width = base.grid[1] and #base.grid[1] or 0
    
    -- Sum power from all power plants
    for y = 1, height do
        for x = 1, width do
            local facility = base.grid[y][x]
            if facility and facility:match("power_plant") then
                local generation = POWER_GENERATION[facility] or 300
                totalPower = totalPower + generation
            end
        end
    end
    
    print(string.format("[PowerSystem] Total generation: %d units", totalPower))
    return totalPower
end

--- Calculate total power consumption for base
--- @param base table Base entity with grid
--- @return number Total power consumption
function PowerSystem:calculatePowerConsumption(base)
    if not base.grid then
        return 0
    end
    
    local totalConsumption = 0
    local height = #base.grid
    local width = base.grid[1] and #base.grid[1] or 0
    
    -- Sum consumption from operational facilities
    for y = 1, height do
        for x = 1, width do
            local facility = base.grid[y][x]
            if facility and facility ~= "EMPTY" then
                local consumption = POWER_CONSUMPTION[facility] or 0
                
                -- Check facility status
                local facilityState = base.facilities[facility] or {}
                if facilityState.status == "operational" then
                    totalConsumption = totalConsumption + consumption
                elseif facilityState.status == "damaged" then
                    -- Damaged facilities use only 50% power
                    totalConsumption = totalConsumption + (consumption * 0.5)
                end
            end
        end
    end
    
    print(string.format("[PowerSystem] Total consumption: %d units", totalConsumption))
    return totalConsumption
end

--- Get power status for base
--- @param base table Base entity
--- @return table Power status {available, consumed, shortage, ratio}
function PowerSystem:getPowerStatus(base)
    local available = self:calculatePowerGeneration(base)
    local consumed = self:calculatePowerConsumption(base)
    local shortage = math.max(0, consumed - available)
    local ratio = available > 0 and (available / consumed) or 1.0
    
    return {
        available = available,
        consumed = consumed,
        shortage = shortage,
        ratio = ratio,
        isPowered = shortage == 0,
        surplus = math.max(0, available - consumed)
    }
end

--- Update power states for all facilities
--- Determines which facilities go offline due to power shortage
--- @param base table Base entity
function PowerSystem:updatePowerStates(base)
    if not base.grid then
        return
    end
    
    local powerStatus = self:getPowerStatus(base)
    
    if not powerStatus.isPowered then
        -- Power shortage: Offline facilities by priority
        self:distributePowerByPriority(base, powerStatus.available)
    else
        -- Sufficient power: All facilities online
        self:restoreAllFacilities(base)
    end
    
    self.powerCache = powerStatus
    print(string.format("[PowerSystem] Power update: %d/%d (%.0f%% available)",
        powerStatus.available, powerStatus.consumed, powerStatus.ratio * 100))
end

--- Distribute limited power by facility priority
--- @param base table Base entity
--- @param availablePower number Power available
function PowerSystem:distributePowerByPriority(base, availablePower)
    if not base.grid then
        return
    end
    
    local facilities = {}
    local height = #base.grid
    local width = base.grid[1] and #base.grid[1] or 0
    
    -- Collect all facilities with priority
    for y = 1, height do
        for x = 1, width do
            local facility = base.grid[y][x]
            if facility and facility ~= "EMPTY" then
                local priority = POWER_PRIORITY[facility] or 0
                local consumption = POWER_CONSUMPTION[facility] or 0
                
                table.insert(facilities, {
                    x = x,
                    y = y,
                    facility = facility,
                    priority = priority,
                    consumption = consumption
                })
            end
        end
    end
    
    -- Sort by priority (highest first)
    table.sort(facilities, function(a, b)
        return a.priority > b.priority
    end)
    
    -- Distribute power
    local powerUsed = 0
    for _, fac in ipairs(facilities) do
        if powerUsed + fac.consumption <= availablePower then
            -- Facility stays powered
            powerUsed = powerUsed + fac.consumption
            if base.facilities[fac.facility] then
                base.facilities[fac.facility].status = "operational"
            end
        else
            -- Facility goes offline (power shortage)
            if base.facilities[fac.facility] then
                base.facilities[fac.facility].status = "offline_power"
            end
        end
    end
    
    print(string.format("[PowerSystem] Priority distribution complete: %d/%d available",
        powerUsed, availablePower))
end

--- Restore all facilities to operational (after power restored)
--- @param base table Base entity
function PowerSystem:restoreAllFacilities(base)
    if not base.grid then
        return
    end
    
    local height = #base.grid
    local width = base.grid[1] and #base.grid[1] or 0
    
    for y = 1, height do
        for x = 1, width do
            local facility = base.grid[y][x]
            if facility and facility ~= "EMPTY" then
                if base.facilities[facility] and base.facilities[facility].status == "offline_power" then
                    base.facilities[facility].status = "operational"
                end
            end
        end
    end
    
    print("[PowerSystem] All facilities restored to operational")
end

--- Manually toggle facility power (player control)
--- @param base table Base entity
--- @param x number Facility X coordinate
--- @param y number Facility Y coordinate
--- @return boolean Success
--- @return string Message
function PowerSystem:toggleFacilityPower(base, x, y)
    if not base.grid or not base.grid[y] or not base.grid[y][x] then
        return false, "Invalid facility location"
    end
    
    local facility = base.grid[y][x]
    if facility == "EMPTY" then
        return false, "No facility at location"
    end
    
    if not base.facilities[facility] then
        return false, "Facility data not found"
    end
    
    local facStatus = base.facilities[facility]
    
    -- Can't toggle if already offline due to power shortage
    if facStatus.status == "offline_power" then
        return false, "Cannot manually control - facility offline due to power shortage"
    end
    
    -- Toggle state
    if facStatus.status == "offline_player" then
        facStatus.status = "operational"
        return true, "Facility powered on"
    else
        facStatus.status = "offline_player"
        return true, "Facility powered down for conservation"
    end
end

--- Get power efficiency for facility
--- @param base table Base entity
--- @param facility string Facility type
--- @return number Efficiency 0.0-1.0
function PowerSystem:getFacilityEfficiency(base, facility)
    local powerStatus = self:getPowerStatus(base)
    
    -- Efficiency based on power ratio
    if powerStatus.isPowered then
        return 1.0  -- 100% efficiency with sufficient power
    else
        -- With shortage: Each facility at reduced efficiency
        return math.max(0.3, powerStatus.ratio)  -- Minimum 30% efficiency
    end
end

--- Calculate power cost of adding new facility
--- @param facilityType string Type of facility to add
--- @return number Power consumption
function PowerSystem:calculatePowerCost(facilityType)
    return POWER_CONSUMPTION[facilityType] or 50
end

--- Get list of facilities by power priority
--- @return table Array of {type, consumption, priority}
function PowerSystem:getPriorityList()
    local list = {}
    for facility, priority in pairs(POWER_PRIORITY) do
        table.insert(list, {
            facility = facility,
            consumption = POWER_CONSUMPTION[facility] or 0,
            priority = priority
        })
    end
    table.sort(list, function(a, b) return a.priority > b.priority end)
    return list
end

--- Get UI display text for power status
--- @param base table Base entity
--- @return string Display text
function PowerSystem:getDisplayText(base)
    local status = self:getPowerStatus(base)
    
    if status.isPowered then
        return string.format("Power: %d/%d units (+%d surplus)",
            status.available, status.consumed, status.surplus)
    else
        return string.format("POWER SHORTAGE: %d/%d units (-%d deficit)",
            status.available, status.consumed, status.shortage)
    end
end

--- Emergency power purge (offline all non-critical systems)
--- @param base table Base entity
function PowerSystem:emergencyPowerdown(base)
    if not base.grid then
        return
    end
    
    local height = #base.grid
    local width = base.grid[1] and #base.grid[1] or 0
    
    -- Offline all low-priority facilities
    for y = 1, height do
        for x = 1, width do
            local facility = base.grid[y][x]
            if facility and facility ~= "EMPTY" then
                local priority = POWER_PRIORITY[facility] or 0
                
                -- Keep only critical systems (priority 80+)
                if priority < 80 then
                    if base.facilities[facility] then
                        base.facilities[facility].status = "offline_player"
                    end
                end
            end
        end
    end
    
    print("[PowerSystem] Emergency power-down: Non-critical systems offline")
end

return PowerSystem




