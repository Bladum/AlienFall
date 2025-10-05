--- Trait.lua
-- Unit traits system for Alien Fall
-- Defines persistent modifiers that give units personality and variance

-- GROK: Trait represents character modifiers with stat bonuses, abilities, and compatibility rules
-- GROK: Used by unit_system for soldier customization and personality-driven gameplay
-- GROK: Key methods: applyEffects(), isCompatibleWithTraits(), checkConditions()
-- GROK: Handles trait prerequisites, incompatibilities, and conditional activation

local class = require 'lib.Middleclass'

Trait = class('Trait')

--- Initialize a new trait
-- @param data The TOML data for this trait
function Trait:initialize(data)
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""

    -- Trait category
    self.category = data.category or "general"

    -- Rarity level
    self.rarity = data.rarity or "common"

    -- Stat modifiers
    self.stat_modifiers = data.stat_modifiers or {}

    -- Ability grants
    self.abilities = data.abilities or {}

    -- Compatibility rules
    self.compatibility = data.compatibility or {}

    -- Conditional activation
    self.conditions = data.conditions or {}

    -- Effects
    self.effects = data.effects or {}

    -- Validate data
    self:_validate()
end

--- Validate the trait data
function Trait:_validate()
    assert(self.id, "Trait must have an id")
    assert(self.name, "Trait must have a name")

    -- Validate rarity
    local validRarities = {common = true, uncommon = true, rare = true, epic = true, legendary = true}
    assert(validRarities[self.rarity], "Invalid rarity level: " .. tostring(self.rarity))
end

--- Get the trait's rarity level
-- @return Rarity string
function Trait:getRarity()
    return self.rarity
end

--- Get stat modifiers
-- @return Table of stat modifiers {stat_name = modifier_value}
function Trait:getStatModifiers()
    return self.stat_modifiers
end

--- Get a specific stat modifier
-- @param stat The stat name
-- @return Modifier value or 0 if not modified
function Trait:getStatModifier(stat)
    return self.stat_modifiers[stat] or 0
end

--- Get abilities granted by this trait
-- @return Array of ability IDs
function Trait:getAbilities()
    return self.abilities
end

--- Check if this trait grants a specific ability
-- @param abilityId The ability ID to check
-- @return true if the trait grants this ability
function Trait:hasAbility(abilityId)
    for _, ability in ipairs(self.abilities) do
        if ability == abilityId then
            return true
        end
    end
    return false
end

--- Get incompatible traits
-- @return Array of trait IDs that cannot be combined with this one
function Trait:getIncompatibleTraits()
    return self.compatibility.incompatible or {}
end

--- Get required traits (prerequisites)
-- @return Array of trait IDs required before this can be acquired
function Trait:getRequiredTraits()
    return self.compatibility.requires or {}
end

--- Get restricted races
-- @return Array of race IDs that cannot have this trait
function Trait:getRestrictedRaces()
    return self.compatibility.restricted_races or {}
end

--- Check if this trait is compatible with a race
-- @param raceId The race ID to check
-- @return true if compatible
function Trait:isCompatibleWithRace(raceId)
    local restricted = self:getRestrictedRaces()
    for _, restrictedRace in ipairs(restricted) do
        if restrictedRace == raceId then
            return false
        end
    end
    return true
end

--- Check if this trait meets its prerequisites
-- @param existingTraits Array of existing trait IDs
-- @return true if prerequisites are met
function Trait:meetsPrerequisites(existingTraits)
    local required = self:getRequiredTraits()
    for _, requiredTrait in ipairs(required) do
        local hasTrait = false
        for _, existingTrait in ipairs(existingTraits) do
            if existingTrait == requiredTrait then
                hasTrait = true
                break
            end
        end
        if not hasTrait then
            return false
        end
    end
    return true
end

--- Check if this trait can be combined with existing traits
-- @param existingTraits Array of existing trait IDs
-- @return true if compatible
function Trait:isCompatibleWithTraits(existingTraits)
    local incompatible = self:getIncompatibleTraits()
    for _, existingTrait in ipairs(existingTraits) do
        for _, incompatibleTrait in ipairs(incompatible) do
            if existingTrait == incompatibleTrait then
                return false
            end
        end
    end
    return true
end

--- Check if the trait's conditions are met
-- @param unitState Table with unit's current state (health, morale, etc.)
-- @return true if conditions are met
function Trait:checkConditions(unitState)
    if not self.conditions then return true end

    -- Health threshold
    if self.conditions.health_threshold then
        local currentHealth = unitState.health or 100
        local threshold = self.conditions.health_threshold
        if currentHealth > threshold then
            return false
        end
    end

    -- Morale threshold
    if self.conditions.morale_threshold then
        local currentMorale = unitState.morale or 80
        local threshold = self.conditions.morale_threshold
        if currentMorale < threshold then
            return false
        end
    end

    -- Time of day
    if self.conditions.time_of_day then
        local currentTime = unitState.time_of_day or "day"
        if currentTime ~= self.conditions.time_of_day then
            return false
        end
    end

    return true
end

--- Apply trait effects to a unit
-- @param unit The unit to apply effects to
-- @param unitState Current unit state for conditional effects
function Trait:applyEffects(unit, unitState)
    if not self:checkConditions(unitState) then
        return -- Conditions not met
    end

    -- Apply stat modifiers
    for stat, modifier in pairs(self.stat_modifiers) do
        unit[stat] = (unit[stat] or 0) + modifier
    end

    -- Grant abilities
    for _, abilityId in ipairs(self.abilities) do
        unit:addAbility(abilityId)
    end

    -- Apply special effects
    if self.effects.fear_resistance then
        unit.fear_resistance = (unit.fear_resistance or 0) + self.effects.fear_resistance
    end

    if self.effects.morale_modifier then
        unit.morale_modifier = (unit.morale_modifier or 0) + self.effects.morale_modifier
    end
end

--- Get a human-readable description of the trait
-- @return String description
function Trait:getDescription()
    local desc = self.name
    if self.description and self.description ~= "" then
        desc = desc .. " - " .. self.description
    end

    desc = desc .. string.format(" (%s)", self.rarity)

    if #self.abilities > 0 then
        desc = desc .. " - Grants: " .. table.concat(self.abilities, ", ")
    end

    return desc
end

--- Convert to string representation
-- @return String representation
function Trait:__tostring()
    return string.format("Trait{id='%s', name='%s', rarity='%s'}",
                        self.id, self.name, self.rarity)
end

return Trait
