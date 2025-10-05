--- UnitSystem.lua
-- Main unit management system for Alien Fall
-- Coordinates unit creation, management, and operations

-- GROK: UnitSystem manages all unit-related operations and data loading
-- GROK: Used by game systems for unit operations, UI, and campaign management
-- GROK: Key methods: createUnit(), loadUnitData(), getUnitById()
-- GROK: Handles data registry integration and unit lifecycle management

local class = require 'lib.Middleclass'

UnitSystem = class('UnitSystem')

--- Initialize the unit system
function UnitSystem:initialize()
    self.units = {} -- Unit ID -> Unit object
    self.unit_classes = {} -- Class ID -> UnitClass object
    self.unit_traits = {} -- Trait ID -> Trait object
    self.unit_levels = {} -- Level ID -> UnitLevel object
    self.unit_medals = {} -- Medal ID -> Medal object
    self.unit_sizes = {} -- Size ID -> Size object
    self.unit_transformations = {} -- Transformation ID -> Transformation object

    -- Data loaded flag
    self.data_loaded = false
end

--- Load all unit data from the data registry
function UnitSystem:loadUnitData()
    if self.data_loaded then return end

    local data_registry = require 'services.data_registry'

    -- Load unit classes
    local class_data = data_registry:getData('unit_classes')
    if class_data then
        for _, class_def in ipairs(class_data) do
            local unit_class = require('units.UnitClass')(class_def)
            self.unit_classes[unit_class.id] = unit_class
        end
    end

    -- Load unit traits
    local trait_data = data_registry:getData('unit_traits')
    if trait_data then
        for _, trait_def in ipairs(trait_data) do
            local trait = require('units.Trait')(trait_def)
            self.unit_traits[trait.id] = trait
        end
    end

    -- Load unit levels
    local level_data = data_registry:getData('unit_levels')
    if level_data then
        for _, level_def in ipairs(level_data) do
            local level = require('units.UnitLevel')(level_def)
            self.unit_levels[level.id] = level
        end
    end

    -- Load unit medals
    local medal_data = data_registry:getData('unit_medals')
    if medal_data then
        for _, medal_def in ipairs(medal_data) do
            local medal = require('units.Medal')(medal_def)
            self.unit_medals[medal.id] = medal
        end
    end

    -- Load unit sizes
    local size_data = data_registry:getData('unit_sizes')
    if size_data then
        for _, size_def in ipairs(size_data) do
            local size = require('units.Size')(size_def)
            self.unit_sizes[size.id] = size
        end
    end

    -- Load unit transformations
    local transformation_data = data_registry:getData('unit_transformations')
    if transformation_data then
        for _, transformation_def in ipairs(transformation_data) do
            local transformation = require('units.Transformation')(transformation_def)
            self.unit_transformations[transformation.id] = transformation
        end
    end

    self.data_loaded = true
    print("Unit system data loaded successfully")
end

--- Create a new unit
-- @param unit_data Unit creation data
-- @return The created Unit object
function UnitSystem:createUnit(unit_data)
    self:loadUnitData()

    -- Validate class exists
    if unit_data.class_id and not self.unit_classes[unit_data.class_id] then
        error(string.format("Unknown unit class: %s", unit_data.class_id))
    end

    -- Apply class base stats if not specified
    if unit_data.class_id then
        local class_data = self.unit_classes[unit_data.class_id]
        if class_data then
            local base_stats = class_data:getBaseStats()
            unit_data.stats = unit_data.stats or {}
            for stat, value in pairs(base_stats) do
                unit_data.stats[stat] = unit_data.stats[stat] or value
            end
        end
    end

    -- Create unit
    local Unit = require 'units.Unit'
    local unit = Unit(unit_data)

    -- Store unit
    self.units[unit.id] = unit

    -- Apply traits
    if unit_data.traits then
        for _, trait_id in ipairs(unit_data.traits) do
            self:applyTraitToUnit(unit.id, trait_id)
        end
    end

    -- Apply abilities from class and rank
    if unit.class_id then
        self:updateUnitAbilities(unit.id)
    end

    print(string.format("Created unit: %s", unit.name))
    return unit
end

--- Get a unit by ID
-- @param unit_id The unit ID
-- @return The Unit object or nil
function UnitSystem:getUnitById(unit_id)
    return self.units[unit_id]
end

--- Get all units
-- @return Table of all units (ID -> Unit)
function UnitSystem:getAllUnits()
    return self.units
end

--- Get units by status
-- @param status The status to filter by
-- @return Array of units with the specified status
function UnitSystem:getUnitsByStatus(status)
    local units = {}
    for _, unit in pairs(self.units) do
        if unit.status == status then
            table.insert(units, unit)
        end
    end
    return units
end

--- Get operational units
-- @return Array of operational units
function UnitSystem:getOperationalUnits()
    local units = {}
    for _, unit in pairs(self.units) do
        if unit:isOperational() then
            table.insert(units, unit)
        end
    end
    return units
end

--- Get unit class by ID
-- @param class_id The class ID
-- @return The UnitClass object or nil
function UnitSystem:getUnitClass(class_id)
    self:loadUnitData()
    return self.unit_classes[class_id]
end

--- Get all unit classes
-- @return Table of all unit classes (ID -> UnitClass)
function UnitSystem:getAllUnitClasses()
    self:loadUnitData()
    return self.unit_classes
end

--- Get unit trait by ID
-- @param trait_id The trait ID
-- @return The Trait object or nil
function UnitSystem:getUnitTrait(trait_id)
    self:loadUnitData()
    return self.unit_traits[trait_id]
end

--- Apply a trait to a unit
-- @param unit_id The unit ID
-- @param trait_id The trait ID
-- @return true if applied successfully
function UnitSystem:applyTraitToUnit(unit_id, trait_id)
    local unit = self:getUnitById(unit_id)
    local trait = self:getUnitTrait(trait_id)

    if not unit or not trait then
        return false
    end

    -- Check compatibility
    if not trait:isCompatibleWithTraits(unit.traits) then
        return false
    end

    -- Apply trait
    unit:addTrait(trait_id)

    -- Apply trait effects
    local context = { unit_state = {
        health = unit.current_health,
        morale = unit.current_morale,
        sanity = unit.current_sanity
    }}
    trait:applyEffects(unit, context)

    return true
end

--- Update unit abilities based on class and rank
-- @param unit_id The unit ID
function UnitSystem:updateUnitAbilities(unit_id)
    local unit = self:getUnitById(unit_id)
    if not unit or not unit.class_id then return end

    local class_data = self:getUnitClass(unit.class_id)
    if not class_data then return end

    -- Get abilities for current rank
    local rank_abilities = class_data:getAbilitiesForRank(unit.rank)

    -- Add new abilities
    for _, ability_id in ipairs(rank_abilities) do
        unit:addAbility(ability_id)
    end
end

--- Promote a unit to a new class
-- @param unit_id The unit ID
-- @param new_class_id The new class ID
-- @return true if promotion successful
function UnitSystem:promoteUnit(unit_id, new_class_id)
    local unit = self:getUnitById(unit_id)
    if not unit then return false end

    local current_class = self:getUnitClass(unit.class_id)
    local new_class = self:getUnitClass(new_class_id)

    if not current_class or not new_class then
        return false
    end

    -- Check if promotion is allowed
    if not current_class:canPromoteTo(new_class_id) then
        return false
    end

    -- Update unit class
    unit.class_id = new_class_id
    unit.rank = unit.rank + 1

    -- Update abilities
    self:updateUnitAbilities(unit_id)

    -- Update stats (keep current values but adjust maxes)
    local new_base_stats = new_class:getBaseStats()
    for stat, value in pairs(new_base_stats) do
        if unit.stats[stat] then
            -- Adjust current value proportionally
            local ratio = unit.current_health / unit.stats.health
            unit.stats[stat] = value
            if stat == "health" then
                unit.current_health = math.floor(value * ratio)
            elseif stat == "stamina" then
                unit.current_stamina = math.min(unit.current_stamina, value)
            end
        end
    end

    print(string.format("Promoted unit %s to %s", unit.name, new_class.name))
    return true
end

--- Award a medal to a unit
-- @param unit_id The unit ID
-- @param medal_id The medal ID
-- @return true if awarded successfully
function UnitSystem:awardMedalToUnit(unit_id, medal_id)
    local unit = self:getUnitById(unit_id)
    local medal = self:getUnitMedal(medal_id)

    if not unit or not medal then
        return false
    end

    -- Check if unit already has this medal
    if medal:unitHasMedal(unit) then
        return false
    end

    -- Check requirements
    if not medal:meetsRequirements(unit.combat_stats) then
        return false
    end

    -- Award medal
    medal:awardToUnit(unit)

    print(string.format("Awarded medal %s to unit %s", medal.name, unit.name))
    return true
end

--- Get unit medal by ID
-- @param medal_id The medal ID
-- @return The Medal object or nil
function UnitSystem:getUnitMedal(medal_id)
    self:loadUnitData()
    return self.unit_medals[medal_id]
end

--- Calculate effective stats for a unit
-- @param unit_id The unit ID
-- @return Table of effective stats
function UnitSystem:calculateEffectiveStats(unit_id)
    local unit = self:getUnitById(unit_id)
    if not unit then return {} end

    local UnitStats = require 'units.UnitStats'
    local context = {
        class_data = self:getUnitClass(unit.class_id),
        trait_data = self.unit_traits,
        equipment_data = {}, -- TODO: Add equipment data
        medal_data = self.unit_medals
    }

    return UnitStats.calculateEffectiveStats(unit, context)
end

--- Update all units (called daily)
function UnitSystem:updateDaily()
    for _, unit in pairs(self.units) do
        unit:updateDaily()
    end
end

--- Get unit statistics summary
-- @return Table with unit statistics
function UnitSystem:getUnitStatistics()
    local stats = {
        total_units = 0,
        operational_units = 0,
        wounded_units = 0,
        kia_units = 0,
        by_class = {},
        by_status = {},
        average_level = 0,
        total_experience = 0
    }

    local total_level = 0

    for _, unit in pairs(self.units) do
        stats.total_units = stats.total_units + 1
        stats.total_experience = stats.total_experience + unit.experience
        total_level = total_level + unit.level

        -- Status counts
        if unit.status == "kia" then
            stats.kia_units = stats.kia_units + 1
        elseif unit:isWounded() then
            stats.wounded_units = stats.wounded_units + 1
        elseif unit:isOperational() then
            stats.operational_units = stats.operational_units + 1
        end

        -- Class counts
        stats.by_class[unit.class_id] = (stats.by_class[unit.class_id] or 0) + 1

        -- Status counts
        stats.by_status[unit.status] = (stats.by_status[unit.status] or 0) + 1
    end

    if stats.total_units > 0 then
        stats.average_level = total_level / stats.total_units
    end

    return stats
end

--- Remove a unit from the system
-- @param unit_id The unit ID to remove
-- @return true if removed successfully
function UnitSystem:removeUnit(unit_id)
    if self.units[unit_id] then
        self.units[unit_id] = nil
        return true
    end
    return false
end

--- Serialize unit data for saving
-- @return Table with serializable unit data
function UnitSystem:serialize()
    local data = {
        units = {},
        data_loaded = self.data_loaded
    }

    for id, unit in pairs(self.units) do
        data.units[id] = {
            id = unit.id,
            name = unit.name,
            nickname = unit.nickname,
            class_id = unit.class_id,
            rank = unit.rank,
            level = unit.level,
            experience = unit.experience,
            experience_to_next = unit.experience_to_next,
            stats = unit.stats,
            current_health = unit.current_health,
            current_stamina = unit.current_stamina,
            current_morale = unit.current_morale,
            current_sanity = unit.current_sanity,
            action_points = unit.action_points,
            max_action_points = unit.max_action_points,
            energy = unit.energy,
            max_energy = unit.max_energy,
            equipment = unit.equipment,
            inventory = unit.inventory,
            encumbrance = unit.encumbrance,
            traits = unit.traits,
            abilities = unit.abilities,
            medals = unit.medals,
            status = unit.status,
            current_mission = unit.current_mission,
            mission_eta = unit.mission_eta,
            combat_stats = unit.combat_stats,
            origin = unit.origin,
            recruitment_date = unit.recruitment_date,
            time_served = unit.time_served,
            salary = unit.salary,
            maintenance_cost = unit.maintenance_cost,
            is_hero = unit.is_hero,
            is_veteran = unit.is_veteran,
            can_promote = unit.can_promote
        }
    end

    return data
end

--- Deserialize unit data from save
-- @param data The serialized unit data
function UnitSystem:deserialize(data)
    if not data or not data.units then return end

    self.units = {}
    for id, unit_data in pairs(data.units) do
        -- Recreate unit object
        local Unit = require 'units.Unit'
        local unit = Unit(unit_data)
        self.units[id] = unit
    end

    self.data_loaded = data.data_loaded or false
end

return UnitSystem
