--- UnitClass.lua
-- Unit class system for Alien Fall
-- Defines soldier archetypes with stats, abilities, and progression paths

-- GROK: UnitClass defines soldier archetypes with base stats, abilities, and progression
-- GROK: Used by unit_system for class selection, stat calculation, and advancement
-- GROK: Key methods: getBaseStats(), getAbilitiesForRank(), canPromoteTo()
-- GROK: Handles class compatibility, promotion trees, and specialization paths

local class = require 'lib.Middleclass'

UnitClass = class('UnitClass')

--- Initialize a new unit class
-- @param data The TOML data for this class
function UnitClass:initialize(data)
    self.id = data.id
    self.name = data.name
    self.description = data.description or ""

    -- Class category
    self.category = data.category or "infantry"

    -- Base stats
    self.base_stats = data.base_stats or {}

    -- Abilities by rank
    self.abilities = data.abilities or {}

    -- Promotion paths
    self.promotion_paths = data.promotion_paths or {}

    -- Equipment restrictions
    self.equipment_restrictions = data.equipment_restrictions or {}

    -- Stat growth modifiers
    self.stat_growth = data.stat_growth or {}

    -- Special properties
    self.properties = data.properties or {}

    -- Requirements
    self.requirements = data.requirements or {}

    -- Validate data
    self:_validate()
end

--- Validate the class data
function UnitClass:_validate()
    assert(self.id, "Unit class must have an id")
    assert(self.name, "Unit class must have a name")

    -- Validate base stats
    local required_stats = {"health", "stamina", "accuracy", "reflexes", "strength", "mind", "morale"}
    for _, stat in ipairs(required_stats) do
        assert(self.base_stats[stat], string.format("Class %s missing base stat: %s", self.id, stat))
        assert(type(self.base_stats[stat]) == "number", string.format("Base stat %s must be a number", stat))
    end
end

--- Get base stats for this class
-- @return Table of base stats
function UnitClass:getBaseStats()
    return self.base_stats
end

--- Get a specific base stat
-- @param stat The stat name
-- @return Base stat value
function UnitClass:getBaseStat(stat)
    return self.base_stats[stat] or 0
end

--- Get abilities available at a specific rank
-- @param rank The rank level
-- @return Array of ability IDs
function UnitClass:getAbilitiesForRank(rank)
    local abilities = {}

    -- Add abilities for all ranks up to current
    for r = 0, rank do
        if self.abilities[r] then
            for _, ability in ipairs(self.abilities[r]) do
                table.insert(abilities, ability)
            end
        end
    end

    return abilities
end

--- Get all abilities for this class
-- @return Array of all ability IDs
function UnitClass:getAllAbilities()
    local all_abilities = {}
    local seen = {}

    for _, rank_abilities in pairs(self.abilities) do
        for _, ability in ipairs(rank_abilities) do
            if not seen[ability] then
                table.insert(all_abilities, ability)
                seen[ability] = true
            end
        end
    end

    return all_abilities
end

--- Get promotion paths from this class
-- @return Array of class IDs this can promote to
function UnitClass:getPromotionPaths()
    return self.promotion_paths
end

--- Check if this class can promote to another class
-- @param target_class_id The target class ID
-- @return true if promotion is possible
function UnitClass:canPromoteTo(target_class_id)
    -- Handle both array format and table format
    if type(self.promotion_paths) == "table" then
        if self.promotion_paths[target_class_id] then
            return true
        end
        for _, path in ipairs(self.promotion_paths) do
            if path == target_class_id then
                return true
            end
        end
    end
    return false
end

--- Get equipment restrictions
-- @return Table of equipment restrictions
function UnitClass:getEquipmentRestrictions()
    return self.equipment_restrictions
end

--- Check if class can use specific equipment type
-- @param equipment_type The equipment type (weapon, armor, etc.)
-- @param equipment_id The specific equipment ID
-- @return true if equipment is allowed
function UnitClass:canUseEquipment(equipment_type, equipment_id)
    local restrictions = self.equipment_restrictions[equipment_type]
    if not restrictions then return true end

    -- Check allowed list
    if restrictions.allowed then
        for _, allowed in ipairs(restrictions.allowed) do
            if allowed == equipment_id then
                return true
            end
        end
        return false
    end

    -- Check forbidden list
    if restrictions.forbidden then
        for _, forbidden in ipairs(restrictions.forbidden) do
            if forbidden == equipment_id then
                return false
            end
        end
    end

    return true
end

--- Get stat growth modifiers
-- @return Table of stat growth modifiers
function UnitClass:getStatGrowthModifiers()
    return self.stat_growth
end

--- Get stat growth modifier for specific stat
-- @param stat The stat name
-- @return Growth modifier (default 1.0)
function UnitClass:getStatGrowthModifier(stat)
    return self.stat_growth[stat] or 1.0
end

--- Get class properties
-- @return Table of special properties
function UnitClass:getProperties()
    return self.properties
end

--- Check if class has a specific property
-- @param property The property name
-- @return true if class has the property
function UnitClass:hasProperty(property)
    return self.properties[property] == true
end

--- Get requirements for this class
-- @return Table of requirements
function UnitClass:getRequirements()
    return self.requirements
end

--- Check if requirements are met
-- @param context Table with requirement context (research, facilities, etc.)
-- @return true if requirements are met
function UnitClass:meetsRequirements(context)
    if not self.requirements then return true end

    -- Check research requirements
    if self.requirements.research then
        for _, research_id in ipairs(self.requirements.research) do
            if not (context.researched and context.researched[research_id]) then
                return false
            end
        end
    end

    -- Check facility requirements
    if self.requirements.facilities then
        for _, facility_id in ipairs(self.requirements.facilities) do
            if not (context.facilities and context.facilities[facility_id]) then
                return false
            end
        end
    end

    return true
end

--- Calculate stat bonuses for a unit of this class at given rank
-- @param rank The unit's rank
-- @return Table of stat bonuses
function UnitClass:calculateStatBonuses(rank)
    local bonuses = {}

    -- Base stat bonuses from rank
    local rank_bonuses = {
        health = rank * 5,
        stamina = rank * 3,
        accuracy = rank * 2,
        reflexes = rank * 2,
        strength = rank * 1,
        mind = rank * 1
    }

    -- Apply class-specific growth modifiers
    for stat, base_bonus in pairs(rank_bonuses) do
        local modifier = self:getStatGrowthModifier(stat)
        bonuses[stat] = math.floor(base_bonus * modifier)
    end

    return bonuses
end

--- Calculate stat growth over levels
-- @param levels Number of levels to grow
-- @return Table of stat growth values
function UnitClass:calculateStatGrowth(levels)
    local growth = {}
    
    -- Start with base stats
    local base_stats = self:getBaseStats()
    for stat, value in pairs(base_stats) do
        growth[stat] = value
    end
    
    -- Apply level growth
    for i = 1, levels do
        local bonuses = self:calculateStatBonuses(i)
        for stat, bonus in pairs(bonuses) do
            growth[stat] = (growth[stat] or 0) + bonus
        end
    end
    
    return growth
end

--- Get class category
-- @return Category string
function UnitClass:getCategory()
    return self.category
end

--- Check if this is a combat class
-- @return true if combat class
function UnitClass:isCombatClass()
    return self.category == "infantry" or self.category == "support" or self.category == "heavy"
end

--- Check if this is a specialist class
-- @return true if specialist class
function UnitClass:isSpecialistClass()
    return self.category == "psi" or self.category == "technical"
end

--- Get a human-readable description of the class
-- @return String description
function UnitClass:getDescription()
    local desc = self.name
    if self.description and self.description ~= "" then
        desc = desc .. " - " .. self.description
    end

    desc = desc .. string.format(" (%s)", self.category)

    -- Add key stats
    local key_stats = {}
    if self.base_stats.accuracy > 60 then table.insert(key_stats, "Accurate") end
    if self.base_stats.health > 120 then table.insert(key_stats, "Durable") end
    if self.base_stats.strength > 60 then table.insert(key_stats, "Strong") end
    if self.base_stats.mind > 60 then table.insert(key_stats, "Intelligent") end

    if #key_stats > 0 then
        desc = desc .. " - " .. table.concat(key_stats, ", ")
    end

    return desc
end

--- Convert to string representation
-- @return String representation
function UnitClass:__tostring()
    return string.format("UnitClass{id='%s', name='%s', category='%s'}",
                        self.id, self.name, self.category)
end

return UnitClass
