--- UnitLevel.lua
-- Unit level progression system for Alien Fall
-- Defines experience-based advancement and stat modifiers

-- GROK: UnitLevel manages soldier progression with XP requirements and ability unlocks
-- GROK: Used by unit_system for character advancement and skill development
-- GROK: Key methods: meetsRequirements(), applyRewards(), getStatModifier()
-- GROK: Handles experience thresholds, stat multipliers, and ability progression

local class = require 'lib.Middleclass'

UnitLevel = class('UnitLevel')

--- Initialize a new unit level
-- @param data The TOML data for this level
function UnitLevel:initialize(data)
    self.id = data.id
    self.name = data.name
    self.level = data.level
    self.experience_required = data.experience_required or 0

    -- Stat modifiers (multipliers)
    self.stat_modifiers = data.stat_modifiers or {}

    -- Abilities unlocked at this level
    self.abilities = data.abilities or {}

    -- Requirements to reach this level
    self.requirements = data.requirements or {}

    -- Rewards for reaching this level
    self.rewards = data.rewards or {}

    -- Validate data
    self:_validate()
end

--- Validate the unit level data
function UnitLevel:_validate()
    assert(self.id, "Unit level must have an id")
    assert(self.name, "Unit level must have a name")
    assert(self.level and self.level > 0, "Unit level must have a valid level number")

    -- Validate stat modifiers are numbers
    for stat, modifier in pairs(self.stat_modifiers) do
        assert(type(modifier) == "number", string.format("Stat modifier for %s must be a number", stat))
        assert(modifier >= 0, string.format("Stat modifier for %s must be non-negative", stat))
    end

    -- Validate abilities
    if self.abilities then
        for _, ability in ipairs(self.abilities) do
            assert(ability.id, "Ability must have an id")
            assert(ability.name, "Ability must have a name")
        end
    end
end

--- Get the stat modifier for a specific stat
-- @param stat The stat name (e.g., "health", "accuracy")
-- @return The modifier value (default 1.0 if not specified)
function UnitLevel:getStatModifier(stat)
    return self.stat_modifiers[stat] or 1.0
end

--- Check if this level unlocks a specific ability
-- @param abilityId The ability ID to check
-- @return true if the ability is unlocked at this level
function UnitLevel:hasAbility(abilityId)
    if not self.abilities then return false end

    for _, ability in ipairs(self.abilities) do
        if ability.id == abilityId then
            return true
        end
    end
    return false
end

--- Get all abilities unlocked at this level
-- @return Array of ability definitions
function UnitLevel:getAbilities()
    return self.abilities or {}
end

--- Check if a unit meets the requirements for this level
-- @param unit The unit to check requirements against
-- @return true if requirements are met
function UnitLevel:meetsRequirements(unit)
    if not self.requirements then return true end

    -- Check experience requirement
    if self.requirements.experience and unit.experience < self.requirements.experience then
        return false
    end

    -- Check mission requirement
    if self.requirements.missions and unit.missions_completed < self.requirements.missions then
        return false
    end

    -- Check kills requirement
    if self.requirements.kills and unit.kills < self.requirements.kills then
        return false
    end

    -- Check time requirement (in days)
    if self.requirements.time_served and unit.time_served < self.requirements.time_served then
        return false
    end

    return true
end

--- Apply level rewards to a unit
-- @param unit The unit to apply rewards to
function UnitLevel:applyRewards(unit)
    if not self.rewards then return end

    -- Apply stat bonuses
    if self.rewards.stat_bonuses then
        for stat, bonus in pairs(self.rewards.stat_bonuses) do
            unit[stat] = (unit[stat] or 0) + bonus
        end
    end

    -- Apply ability unlocks
    if self.rewards.abilities then
        for _, abilityId in ipairs(self.rewards.abilities) do
            unit:unlockAbility(abilityId)
        end
    end

    -- Apply item rewards
    if self.rewards.items then
        for _, itemId in ipairs(self.rewards.items) do
            unit:addItem(itemId)
        end
    end
end

--- Get a human-readable description of this level
-- @return String description
function UnitLevel:getDescription()
    local desc = string.format("%s (Level %d)", self.name, self.level)

    if self.experience_required > 0 then
        desc = desc .. string.format(" - %d XP required", self.experience_required)
    end

    if #self:getAbilities() > 0 then
        desc = desc .. " - Unlocks: "
        local abilityNames = {}
        for _, ability in ipairs(self:getAbilities()) do
            table.insert(abilityNames, ability.name)
        end
        desc = desc .. table.concat(abilityNames, ", ")
    end

    return desc
end

--- Convert to string representation
-- @return String representation
function UnitLevel:__tostring()
    return string.format("UnitLevel{id='%s', name='%s', level=%d}",
                        self.id, self.name, self.level)
end

return UnitLevel
