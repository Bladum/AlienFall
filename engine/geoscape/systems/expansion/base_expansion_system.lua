--[[
    Base Expansion System

    Manages base growth and infrastructure expansion as threat level increases.
    As the campaign progresses, new facilities become available, the base grid expands,
    and infrastructure capacity increases with corresponding vulnerabilities.

    The system tracks:
    - Available facility types by threat level
    - Base grid expansion thresholds
    - Infrastructure capacity growth
    - Supply line vulnerabilities
    - Base size impact on campaign logistics
]]

local BaseExpansionSystem = {}
BaseExpansionSystem.__index = BaseExpansionSystem

---
-- Initialize base expansion system
-- @param base_data: Base data table
-- @return: New BaseExpansionSystem instance
function BaseExpansionSystem.new(base_data)
    local self = setmetatable({}, BaseExpansionSystem)
    self.baseData = base_data
    self.threatLevel = 0
    self.baseSize = 1  -- Grid multiplier (1 = 10x10, 2 = 15x15, etc)
    self.facilitiesUnlocked = {}
    self.infrastructureCapacity = self:_initializeCapacity()
    self.expansionMilestones = {}
    return self
end

---
-- Initialize base infrastructure capacity
-- @return: Capacity table
function BaseExpansionSystem:_initializeCapacity()
    return {
        hangar_slots = 2,
        soldier_barracks = 50,
        workshop_capacity = 5,
        laboratory_capacity = 3,
        power_output = 100,
        storage_capacity = 1000,
        research_rate_modifier = 1.0,
        defense_rating = 1.0,
        supply_line_efficiency = 1.0
    }
end

---
-- Define facility unlock thresholds by threat level
-- @return: Facility definitions with unlock requirements
function BaseExpansionSystem:_getAvailableFacilities()
    return {
        -- Tier 1: Starting facilities (always available)
        barracks = {
            name = "Barracks",
            threat_unlock = 0,
            capacity_bonus = { soldier_barracks = 50 },
            power_cost = 10,
            cost = 500,
            unlock_tier = 1,
            description = "Training and housing for soldiers"
        },

        hangar = {
            name = "Hangar",
            threat_unlock = 0,
            capacity_bonus = { hangar_slots = 2 },
            power_cost = 15,
            cost = 800,
            unlock_tier = 1,
            description = "Storage and maintenance for combat aircraft"
        },

        -- Tier 2: Mid-game facilities (threat 15+)
        workshop = {
            name = "Engineering Workshop",
            threat_unlock = 15,
            capacity_bonus = { workshop_capacity = 3 },
            power_cost = 20,
            cost = 1200,
            unlock_tier = 2,
            description = "Weapons and equipment manufacturing"
        },

        laboratory = {
            name = "Research Laboratory",
            threat_unlock = 15,
            capacity_bonus = { laboratory_capacity = 2, research_rate_modifier = 1.1 },
            power_cost = 25,
            cost = 1500,
            unlock_tier = 2,
            description = "Scientific research and analysis"
        },

        -- Tier 2: Communications and intelligence
        communications = {
            name = "Communications Center",
            threat_unlock = 20,
            capacity_bonus = { supply_line_efficiency = 1.2 },
            power_cost = 15,
            cost = 1000,
            unlock_tier = 2,
            description = "Satellite and signal communication network"
        },

        -- Tier 3: Advanced facilities (threat 35+)
        advanced_lab = {
            name = "Advanced Research Lab",
            threat_unlock = 35,
            capacity_bonus = { laboratory_capacity = 3, research_rate_modifier = 1.25 },
            power_cost = 35,
            cost = 2000,
            unlock_tier = 3,
            description = "Alien technology analysis and reverse engineering"
        },

        defense_grid = {
            name = "Defense Grid",
            threat_unlock = 35,
            capacity_bonus = { defense_rating = 1.5 },
            power_cost = 40,
            cost = 2500,
            unlock_tier = 3,
            description = "Enhanced base defenses against assault"
        },

        -- Tier 3: Manufacturing and production
        production = {
            name = "Production Facility",
            threat_unlock = 40,
            capacity_bonus = { workshop_capacity = 5, supply_line_efficiency = 1.1 },
            power_cost = 30,
            cost = 2200,
            unlock_tier = 3,
            description = "Large-scale manufacturing and assembly"
        },

        -- Tier 4: Late-game facilities (threat 55+)
        power_plant = {
            name = "Nuclear Power Plant",
            threat_unlock = 55,
            capacity_bonus = { power_output = 200 },
            power_cost = -50,  -- Generates power
            cost = 3500,
            unlock_tier = 4,
            description = "Advanced nuclear power generation"
        },

        vault = {
            name = "Secure Vault",
            threat_unlock = 55,
            capacity_bonus = { storage_capacity = 2000 },
            power_cost = 20,
            cost = 3000,
            unlock_tier = 4,
            description = "Secure storage for critical materials"
        },

        -- Tier 5: End-game facilities (threat 70+)
        command_center = {
            name = "Command Center",
            threat_unlock = 70,
            capacity_bonus = { research_rate_modifier = 1.4, supply_line_efficiency = 1.3 },
            power_cost = 50,
            cost = 5000,
            unlock_tier = 5,
            description = "Advanced command and control operations"
        },

        gateway = {
            name = "Dimensional Gateway",
            threat_unlock = 80,
            capacity_bonus = { defense_rating = 2.5 },
            power_cost = 75,
            cost = 8000,
            unlock_tier = 5,
            description = "Ultimate defensive barrier technology"
        }
    }
end

---
-- Update base expansion based on threat level
-- @param threat_level: Current campaign threat (0-100)
-- @param days_passed: Number of days for expansion progress
function BaseExpansionSystem:updateBaseExpansion(threat_level, days_passed)
    if not threat_level then
        print("[BaseExpansionSystem] Invalid threat level for expansion update")
        return
    end

    self.threatLevel = threat_level
    days_passed = days_passed or 1

    -- Unlock facilities based on threat threshold
    local available_facilities = self:_getAvailableFacilities()
    for facility_id, facility_data in pairs(available_facilities) do
        if facility_data and threat_level >= (facility_data.threat_unlock or 0) then
            if not self.facilitiesUnlocked[facility_id] then
                self.facilitiesUnlocked[facility_id] = {
                    unlocked_at = os.time(),
                    threat_level = threat_level,
                    available = true
                }
            end
        end
    end

    -- Calculate base expansion milestones
    self:_updateBaseGridExpansion(threat_level)
end

---
-- Update base grid size based on threat and progress
-- @param threat_level: Current threat level
function BaseExpansionSystem:_updateBaseGridExpansion(threat_level)
    local new_size = 1

    if threat_level >= 25 then
        new_size = 2  -- 15x15 grid
    end

    if threat_level >= 50 then
        new_size = 3  -- 20x20 grid
    end

    if threat_level >= 75 then
        new_size = 4  -- 25x25 grid
    end

    if new_size > self.baseSize then
        self.baseSize = new_size
        table.insert(self.expansionMilestones, {
            size = new_size,
            threat_when_expanded = threat_level,
            timestamp = os.time()
        })
    end
end

---
-- Get available facilities for construction
-- @return: Table of constructable facilities
function BaseExpansionSystem:getAvailableFacilities()
    local available = {}
    local all_facilities = self:_getAvailableFacilities()

    for facility_id, facility_data in pairs(all_facilities) do
        if facility_data and self.threatLevel >= (facility_data.threat_unlock or 0) then
            available[facility_id] = {
                name = facility_data.name,
                tier = facility_data.unlock_tier,
                power_cost = facility_data.power_cost,
                construction_cost = facility_data.cost,
                description = facility_data.description,
                unlocked = true
            }
        end
    end

    return available
end

---
-- Add a facility to the base and update capacity
-- @param facility_id: ID of facility to add
-- @param quantity: Number of facilities to add (default 1)
-- @return: Success boolean and message
function BaseExpansionSystem:addFacility(facility_id, quantity)
    if not facility_id then
        print("[BaseExpansionSystem] Invalid facility ID")
        return false, "Invalid facility"
    end

    quantity = quantity or 1
    local all_facilities = self:_getAvailableFacilities()
    local facility = all_facilities[facility_id]

    if not facility then
        return false, "Facility not found"
    end

    if self.threatLevel < (facility.threat_unlock or 0) then
        return false, "Facility not yet available"
    end

    -- Update capacity bonuses
    if facility.capacity_bonus then
        for capacity_type, bonus in pairs(facility.capacity_bonus) do
            if self.infrastructureCapacity[capacity_type] then
                self.infrastructureCapacity[capacity_type] =
                    self.infrastructureCapacity[capacity_type] + (bonus * quantity)
            else
                self.infrastructureCapacity[capacity_type] = bonus * quantity
            end
        end
    end

    return true, "Facility added successfully"
end

---
-- Calculate supply line vulnerability based on base size
-- @return: Vulnerability rating (0.0-1.0, higher = more vulnerable)
function BaseExpansionSystem:calculateSupplyLineVulnerability()
    -- Larger bases are more vulnerable to supply disruption
    local base_size_factor = (self.baseSize / 4.0)  -- Normalized to 0.25-1.0

    -- Threat increases vulnerability
    local threat_factor = (self.threatLevel / 100.0)

    -- Supply line efficiency reduces vulnerability (if comm center built, etc)
    local efficiency = self.infrastructureCapacity.supply_line_efficiency or 1.0

    local vulnerability = (base_size_factor + threat_factor) / (efficiency * 2.0)
    return math.max(0.0, math.min(vulnerability, 1.0))
end

---
-- Get base defense rating against assault
-- @return: Defense rating (multiplier, 1.0 = baseline)
function BaseExpansionSystem:getBaseDefenseRating()
    local defense = self.infrastructureCapacity.defense_rating or 1.0

    -- Scale with base size (larger = harder to defend)
    defense = defense * (1.0 - (self.baseSize * 0.1))

    return math.max(0.5, defense)
end

---
-- Check if base is at capacity
-- @return: Boolean indicating if at capacity
function BaseExpansionSystem:isAtCapacity()
    -- Check soldier barracks capacity vs actual soldiers
    if self.baseData and self.baseData.soldiers then
        local soldier_count = #(self.baseData.soldiers or {})
        if soldier_count >= self.infrastructureCapacity.soldier_barracks then
            return true
        end
    end

    return false
end

---
-- Get current base status for UI
-- @return: Status table with key metrics
function BaseExpansionSystem:getBaseStatus()
    return {
        grid_size = self.baseSize,
        threat_level = self.threatLevel,
        hangar_slots = self.infrastructureCapacity.hangar_slots,
        barracks_capacity = self.infrastructureCapacity.soldier_barracks,
        workshop_capacity = self.infrastructureCapacity.workshop_capacity,
        laboratory_capacity = self.infrastructureCapacity.laboratory_capacity,
        power_output = self.infrastructureCapacity.power_output,
        storage_capacity = self.infrastructureCapacity.storage_capacity,
        research_rate = self.infrastructureCapacity.research_rate_modifier,
        defense_rating = self:getBaseDefenseRating(),
        supply_vulnerability = self:calculateSupplyLineVulnerability(),
        facilities_unlocked = #self.facilitiesUnlocked
    }
end

---
-- Serialize expansion state for save game
-- @return: Serializable table
function BaseExpansionSystem:serialize()
    return {
        baseSize = self.baseSize,
        threatLevel = self.threatLevel,
        infrastructureCapacity = self.infrastructureCapacity,
        facilitiesUnlocked = self.facilitiesUnlocked,
        expansionMilestones = self.expansionMilestones
    }
end

---
-- Deserialize expansion state from save game
-- @param data: Serialized data table
function BaseExpansionSystem:deserialize(data)
    if not data then return end

    self.baseSize = data.baseSize or 1
    self.threatLevel = data.threatLevel or 0
    self.infrastructureCapacity = data.infrastructureCapacity or self:_initializeCapacity()
    self.facilitiesUnlocked = data.facilitiesUnlocked or {}
    self.expansionMilestones = data.expansionMilestones or {}
end

return BaseExpansionSystem

