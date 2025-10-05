--- Size.lua
-- Unit size system for Alien Fall
-- Defines different unit sizes and their gameplay implications

-- GROK: Size defines unit physical dimensions with combat, movement, and visibility modifiers
-- GROK: Used by unit_system and battle_system for tactical gameplay mechanics
-- GROK: Key methods: calculateEffectiveStats(), getCombatModifiers(), canEnterTerrain()
-- GROK: Handles size-based bonuses, restrictions, and special abilities

local class = require 'lib.Middleclass'

Size = class('Size')

--- Initialize a new size
-- @param data The TOML data for this size
function Size:initialize(data)
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""

    -- Size category
    self.category = data.category or "medium"

    -- Combat modifiers
    self.combat_modifiers = data.combat_modifiers or {}

    -- Movement modifiers
    self.movement_modifiers = data.movement_modifiers or {}

    -- Visibility modifiers
    self.visibility_modifiers = data.visibility_modifiers or {}

    -- Resource costs
    self.resource_costs = data.resource_costs or {}

    -- Special abilities
    self.special_abilities = data.special_abilities or {}

    -- Restrictions
    self.restrictions = data.restrictions or {}

    -- Validate data
    self:_validate()
end

--- Validate the size data
function Size:_validate()
    assert(self.id, "Size must have an id")
    assert(self.name, "Size must have a name")

    -- Validate category
    local validCategories = {
        tiny = true, small = true, medium = true, large = true, huge = true,
        colossal = true, swarm = true, ethereal = true
    }
    assert(validCategories[self.category], "Invalid size category: " .. tostring(self.category))
end

--- Get the size category
-- @return Size category string
function Size:getCategory()
    return self.category
end

--- Check if this is a small size (tiny/small)
-- @return true if small
function Size:isSmall()
    return self.category == "tiny" or self.category == "small"
end

--- Check if this is a medium size
-- @return true if medium
function Size:isMedium()
    return self.category == "medium"
end

--- Check if this is a large size (large/huge/colossal)
-- @return true if large
function Size:isLarge()
    return self.category == "large" or self.category == "huge" or self.category == "colossal"
end

--- Check if this is a special size (swarm/ethereal)
-- @return true if special
function Size:isSpecial()
    return self.category == "swarm" or self.category == "ethereal"
end

--- Get combat modifiers
-- @return Table of combat modifiers {modifier_type = value}
function Size:getCombatModifiers()
    return self.combat_modifiers
end

--- Get accuracy modifier
-- @return Accuracy modifier (positive for bonus, negative for penalty)
function Size:getAccuracyModifier()
    return self.combat_modifiers.accuracy or 0
end

--- Get defense modifier
-- @return Defense modifier (positive for bonus, negative for penalty)
function Size:getDefenseModifier()
    return self.combat_modifiers.defense or 0
end

--- Get damage modifier
-- @return Damage modifier (positive for bonus, negative for penalty)
function Size:getDamageModifier()
    return self.combat_modifiers.damage or 0
end

--- Get critical hit modifier
-- @return Critical hit modifier (positive for bonus, negative for penalty)
function Size:getCriticalModifier()
    return self.combat_modifiers.critical or 0
end

--- Get movement modifiers
-- @return Table of movement modifiers {terrain_type = modifier}
function Size:getMovementModifiers()
    return self.movement_modifiers
end

--- Get movement cost modifier for a terrain type
-- @param terrainType The terrain type
-- @return Movement cost modifier (multiplier)
function Size:getMovementCostModifier(terrainType)
    return self.movement_modifiers[terrainType] or 1.0
end

--- Get visibility modifiers
-- @return Table of visibility modifiers {condition = modifier}
function Size:getVisibilityModifiers()
    return self.visibility_modifiers
end

--- Get visibility range modifier
-- @return Visibility range modifier (positive for bonus, negative for penalty)
function Size:getVisibilityRangeModifier()
    return self.visibility_modifiers.range or 0
end

--- Get stealth modifier
-- @return Stealth modifier (positive for bonus, negative for penalty)
function Size:getStealthModifier()
    return self.visibility_modifiers.stealth or 0
end

--- Get resource costs
-- @return Table of resource costs {resource_name = amount}
function Size:getResourceCosts()
    return self.resource_costs
end

--- Get special abilities
-- @return Array of special ability IDs
function Size:getSpecialAbilities()
    return self.special_abilities
end

--- Get restrictions
-- @return Table of restrictions {restriction_type = value}
function Size:getRestrictions()
    return self.restrictions
end

--- Check if this size can use certain equipment
-- @param equipmentType The equipment type to check
-- @return true if can use
function Size:canUseEquipment(equipmentType)
    local restricted = self.restrictions.equipment_types or {}
    for _, restrictedType in ipairs(restricted) do
        if restrictedType == equipmentType then
            return false
        end
    end
    return true
end

--- Check if this size can enter certain terrain
-- @param terrainType The terrain type to check
-- @return true if can enter
function Size:canEnterTerrain(terrainType)
    local restricted = self.restrictions.terrain_types or {}
    for _, restrictedType in ipairs(restricted) do
        if restrictedType == terrainType then
            return false
        end
    end
    return true
end

--- Get the maximum number of units that can occupy a tile
-- @return Maximum units per tile
function Size:getMaxUnitsPerTile()
    return self.restrictions.max_units_per_tile or 1
end

--- Check if this size has a special ability
-- @param abilityId The ability ID to check
-- @return true if has ability
function Size:hasSpecialAbility(abilityId)
    for _, ability in ipairs(self.special_abilities) do
        if ability == abilityId then
            return true
        end
    end
    return false
end

--- Get size-based cover bonus
-- @return Cover bonus value
function Size:getCoverBonus()
    if self:isSmall() then
        return 20  -- Small units get cover bonus
    elseif self:isLarge() then
        return -10  -- Large units get cover penalty
    end
    return 0
end

--- Get size-based flanking bonus
-- @return Flanking bonus value
function Size:getFlankingBonus()
    if self:isSmall() then
        return 15  -- Small units good at flanking
    elseif self:isLarge() then
        return -15  -- Large units bad at flanking
    end
    return 0
end

--- Calculate effective stats for a unit with this size
-- @param baseStats The base unit stats
-- @return Modified stats table
function Size:calculateEffectiveStats(baseStats)
    local effective = {}

    -- Copy base stats
    for k, v in pairs(baseStats) do
        effective[k] = v
    end

    -- Apply size modifiers
    effective.accuracy = (effective.accuracy or 0) + self:getAccuracyModifier()
    effective.defense = (effective.defense or 0) + self:getDefenseModifier()
    effective.damage = (effective.damage or 0) + self:getDamageModifier()
    effective.critical = (effective.critical or 0) + self:getCriticalModifier()

    return effective
end

--- Get a human-readable description of the size
-- @return String description
function Size:getDescription()
    local desc = self.name
    if self.description and self.description ~= "" then
        desc = desc .. " - " .. self.description
    end

    desc = desc .. string.format(" (%s)", self.category)

    local mods = {}
    if self:getAccuracyModifier() ~= 0 then
        table.insert(mods, string.format("Accuracy %+d", self:getAccuracyModifier()))
    end
    if self:getDefenseModifier() ~= 0 then
        table.insert(mods, string.format("Defense %+d", self:getDefenseModifier()))
    end
    if self:getDamageModifier() ~= 0 then
        table.insert(mods, string.format("Damage %+d", self:getDamageModifier()))
    end

    if #mods > 0 then
        desc = desc .. " - " .. table.concat(mods, ", ")
    end

    return desc
end

--- Convert to string representation
-- @return String representation
function Size:__tostring()
    return string.format("Size{id='%s', name='%s', category='%s'}",
                        self.id, self.name, self.category)
end

return Size
