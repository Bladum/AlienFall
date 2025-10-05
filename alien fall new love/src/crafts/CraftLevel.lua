--- CraftLevel.lua
-- Craft/aircraft level progression system for Alien Fall
-- Defines experience-based advancement and capability upgrades

-- GROK: CraftLevel manages aircraft progression with XP requirements and stat modifiers
-- GROK: Used by craft_system for level advancement and capability upgrades
-- GROK: Key methods: meetsRequirements(), applyCapabilities(), calculateMaintenanceCost()
-- GROK: Handles experience-based leveling with capability multipliers and upgrade unlocks

local class = require 'lib.Middleclass'

CraftLevel = class('CraftLevel')

--- Initialize a new craft level
-- @param data The TOML data for this level
function CraftLevel:initialize(data)
    self.id = data.id
    self.name = data.name
    self.level = data.level
    self.experience_required = data.experience_required or 0

    -- Capability modifiers (multipliers)
    self.capabilities = data.capabilities or {}

    -- Available upgrades at this level
    self.upgrades = data.upgrades or {}

    -- Requirements to reach this level
    self.requirements = data.requirements or {}

    -- Maintenance modifiers
    self.maintenance = data.maintenance or {}

    -- Validate data
    self:_validate()
end

--- Validate the craft level data
function CraftLevel:_validate()
    assert(self.id, "Craft level must have an id")
    assert(self.name, "Craft level must have a name")
    assert(self.level and self.level > 0, "Craft level must have a valid level number")

    -- Validate capabilities are numbers
    for capability, value in pairs(self.capabilities) do
        assert(type(value) == "number", string.format("Capability %s must be a number", capability))
        assert(value >= 0, string.format("Capability %s must be non-negative", capability))
    end

    -- Validate maintenance modifiers
    if self.maintenance then
        for modifier, value in pairs(self.maintenance) do
            assert(type(value) == "number", string.format("Maintenance modifier %s must be a number", modifier))
        end
    end
end

--- Get the capability value for a specific capability
-- @param capability The capability name (e.g., "speed", "armor")
-- @return The capability value (default 1.0 if not specified)
function CraftLevel:getCapability(capability)
    return self.capabilities[capability] or 1.0
end

--- Get the maintenance modifier for a specific aspect
-- @param aspect The maintenance aspect (e.g., "cost_multiplier", "repair_time")
-- @return The modifier value (default 1.0 if not specified)
function CraftLevel:getMaintenanceModifier(aspect)
    if not self.maintenance then return 1.0 end
    return self.maintenance[aspect] or 1.0
end

--- Get available upgrades at this level
-- @return Array of available upgrade IDs
function CraftLevel:getAvailableUpgrades()
    return self.upgrades.available or {}
end

--- Get pre-installed upgrades at this level
-- @return Array of installed upgrade IDs
function CraftLevel:getInstalledUpgrades()
    return self.upgrades.installed or {}
end

--- Check if a specific upgrade is available at this level
-- @param upgradeId The upgrade ID to check
-- @return true if the upgrade is available
function CraftLevel:hasUpgradeAvailable(upgradeId)
    local available = self:getAvailableUpgrades()
    for _, upgrade in ipairs(available) do
        if upgrade == upgradeId then
            return true
        end
    end
    return false
end

--- Check if a craft meets the requirements for this level
-- @param craft The craft to check requirements against
-- @return true if requirements are met
function CraftLevel:meetsRequirements(craft)
    if not self.requirements then return true end

    -- Check experience requirement
    if self.requirements.experience and craft.experience < self.requirements.experience then
        return false
    end

    -- Check mission requirement
    if self.requirements.missions and craft.missions_completed < self.requirements.missions then
        return false
    end

    -- Check damage repairs requirement
    if self.requirements.damage_repairs and craft.damage_repairs < self.requirements.damage_repairs then
        return false
    end

    -- Check successful missions requirement
    if self.requirements.successful_missions and craft.successful_missions < self.requirements.successful_missions then
        return false
    end

    return true
end

--- Apply level capabilities to a craft
-- @param craft The craft to apply capabilities to
function CraftLevel:applyCapabilities(craft)
    -- Apply capability modifiers
    for capability, modifier in pairs(self.capabilities) do
        craft[capability] = (craft.base_stats[capability] or 1.0) * modifier
    end

    -- Install pre-installed upgrades
    local installed = self:getInstalledUpgrades()
    for _, upgradeId in ipairs(installed) do
        craft:installUpgrade(upgradeId)
    end
end

--- Calculate maintenance cost for this craft at this level
-- @param baseCost The base maintenance cost
-- @return The modified maintenance cost
function CraftLevel:calculateMaintenanceCost(baseCost)
    local multiplier = self:getMaintenanceModifier("cost_multiplier")
    return baseCost * multiplier
end

--- Calculate repair time for this craft at this level
-- @param baseTime The base repair time
-- @return The modified repair time
function CraftLevel:calculateRepairTime(baseTime)
    local multiplier = self:getMaintenanceModifier("repair_time")
    return baseTime * multiplier
end

--- Calculate fuel efficiency for this craft at this level
-- @param baseEfficiency The base fuel efficiency
-- @return The modified fuel efficiency
function CraftLevel:calculateFuelEfficiency(baseEfficiency)
    local modifier = self:getMaintenanceModifier("fuel_efficiency")
    return baseEfficiency * modifier
end

--- Get a human-readable description of this level
-- @return String description
function CraftLevel:getDescription()
    local desc = string.format("%s (Level %d)", self.name, self.level)

    if self.experience_required > 0 then
        desc = desc .. string.format(" - %d XP required", self.experience_required)
    end

    local caps = {}
    if self.capabilities.speed and self.capabilities.speed > 1.0 then
        table.insert(caps, string.format("Speed +%.0f%%", (self.capabilities.speed - 1.0) * 100))
    end
    if self.capabilities.armor and self.capabilities.armor > 1.0 then
        table.insert(caps, string.format("Armor +%.0f%%", (self.capabilities.armor - 1.0) * 100))
    end
    if self.capabilities.weapons_capacity then
        table.insert(caps, string.format("Weapons: %d", self.capabilities.weapons_capacity))
    end

    if #caps > 0 then
        desc = desc .. " - " .. table.concat(caps, ", ")
    end

    return desc
end

--- Convert to string representation
-- @return String representation
function CraftLevel:__tostring()
    return string.format("CraftLevel{id='%s', name='%s', level=%d}",
                        self.id, self.name, self.level)
end

return CraftLevel
