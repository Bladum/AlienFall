--- UnitService.lua
-- High-level unit service for Alien Fall
-- Provides unified interface for unit operations following service pattern

-- GROK: UnitService provides high-level unit operations and data loading
-- GROK: Used by game systems for unit management and service integration
-- GROK: Key methods: createUnit(), assignToMission(), getUnitStatus()
-- GROK: Handles service registration and cross-system coordination

local class = require 'lib.Middleclass'

UnitService = class('UnitService')

--- Initialize the unit service
function UnitService:initialize()
    self.unit_system = nil
    self.unit_manager = nil
    self.data_loaded = false

    -- Register service
    local service_registry = require 'core.services.registry'
    service_registry:registerService('unit_service', self)
end

--- Load unit data and initialize subsystems
function UnitService:loadData()
    if self.data_loaded then return end

    -- Initialize subsystems
    local UnitSystem = require 'units.UnitSystem'
    local UnitManager = require 'units.UnitManager'

    self.unit_system = UnitSystem()
    self.unit_manager = UnitManager()

    -- Load unit data
    self.unit_system:loadUnitData()

    self.data_loaded = true
    print("Unit service initialized")
end

--- Create a new unit
-- @param class_id The unit class ID
-- @param name The unit name
-- @param base_id The base to assign to
-- @param additional_data Additional unit data
-- @return The created unit or nil on failure
function UnitService:createUnit(class_id, name, base_id, additional_data)
    self:loadData()

    -- Validate class exists
    local unit_class = self.unit_system:getUnitClass(class_id)
    if not unit_class then
        print(string.format("Unknown unit class: %s", class_id))
        return nil
    end

    -- Create unit data
    local unit_data = additional_data or {}
    unit_data.class_id = class_id
    unit_data.name = name or string.format("%s %s", unit_class.name, tostring(math.random(1000, 9999)))

    -- Create unit
    local unit = self.unit_system:createUnit(unit_data)

    -- Assign to base
    if base_id then
        local success = self.unit_manager:assignToBase(unit.id, base_id)
        if not success then
            print(string.format("Failed to assign unit %s to base %s", unit.name, base_id))
        end
    end

    -- Add to manager
    self.unit_manager:addUnit(unit)

    return unit
end

--- Get a unit by ID
-- @param unit_id The unit ID
-- @return The unit object or nil
function UnitService:getUnit(unit_id)
    self:loadData()
    return self.unit_system:getUnitById(unit_id)
end

--- Get all units
-- @return Table of all units
function UnitService:getAllUnits()
    self:loadData()
    return self.unit_system:getAllUnits()
end

--- Get units at a specific base
-- @param base_id The base ID
-- @return Array of units at the base
function UnitService:getUnitsAtBase(base_id)
    self:loadData()
    return self.unit_manager:getUnitsAtBase(base_id)
end

--- Get operational units at a base
-- @param base_id The base ID
-- @return Array of operational units
function UnitService:getOperationalUnitsAtBase(base_id)
    self:loadData()
    return self.unit_manager:getOperationalUnitsAtBase(base_id)
end

--- Assign a unit to a mission
-- @param unit_id The unit ID
-- @param mission_id The mission ID
-- @param eta_hours ETA in hours
-- @return true if assigned successfully
function UnitService:assignUnitToMission(unit_id, mission_id, eta_hours)
    self:loadData()

    local unit = self:getUnit(unit_id)
    if not unit then
        return false, "Unit not found"
    end

    unit:assignToMission(mission_id, eta_hours)
    return true
end

--- Complete a unit's mission
-- @param unit_id The unit ID
-- @param success Whether the mission was successful
-- @param experience_gained Experience points gained
-- @return true if completed successfully
function UnitService:completeUnitMission(unit_id, success, experience_gained)
    self:loadData()

    local unit = self:getUnit(unit_id)
    if not unit then
        return false, "Unit not found"
    end

    unit:completeMissionAssignment()

    if success and experience_gained then
        unit:gainExperience(experience_gained)
    end

    return true
end

--- Transfer a unit between bases
-- @param unit_id The unit ID
-- @param target_base_id The destination base ID
-- @param distance The distance between bases
-- @return true if transfer initiated
function UnitService:transferUnit(unit_id, target_base_id, distance)
    self:loadData()
    return self.unit_manager:transferUnit(unit_id, target_base_id, distance)
end

--- Get unit status information
-- @param unit_id The unit ID
-- @return Table with unit status or nil
function UnitService:getUnitStatus(unit_id)
    local unit = self:getUnit(unit_id)
    if not unit then return nil end

    return {
        id = unit.id,
        name = unit.name,
        status = unit.status,
        health_percentage = unit:getHealthPercentage(),
        stamina_percentage = unit:getStaminaPercentage(),
        morale = unit.current_morale,
        sanity = unit.current_sanity,
        is_operational = unit:isOperational(),
        is_wounded = unit:isWounded(),
        is_fatigued = unit:isFatigued(),
        has_low_morale = unit:hasLowMorale(),
        current_mission = unit.current_mission,
        mission_eta = unit.mission_eta,
        base_id = self.unit_manager:_getUnitBase(unit_id)
    }
end

--- Get available units for a mission
-- @param base_id The base ID
-- @param mission_requirements Mission requirements
-- @return Array of available units
function UnitService:getAvailableUnitsForMission(base_id, mission_requirements)
    self:loadData()
    return self.unit_manager:getAvailableUnitsForMission(base_id, mission_requirements)
end

--- Promote a unit
-- @param unit_id The unit ID
-- @param new_class_id The new class ID
-- @return true if promoted successfully
function UnitService:promoteUnit(unit_id, new_class_id)
    self:loadData()
    return self.unit_system:promoteUnit(unit_id, new_class_id)
end

--- Apply experience to a unit
-- @param unit_id The unit ID
-- @param experience Amount of experience
-- @return true if applied successfully
function UnitService:addExperienceToUnit(unit_id, experience)
    local unit = self:getUnit(unit_id)
    if not unit then return false end

    unit:gainExperience(experience)
    return true
end

--- Heal a unit
-- @param unit_id The unit ID
-- @param healing Amount of healing
-- @return true if healed successfully
function UnitService:healUnit(unit_id, healing)
    local unit = self:getUnit(unit_id)
    if not unit then return false end

    unit:heal(healing)
    return true
end

--- Damage a unit
-- @param unit_id The unit ID
-- @param damage Amount of damage
-- @param damage_type Type of damage
-- @return true if damaged successfully
function UnitService:damageUnit(unit_id, damage, damage_type)
    local unit = self:getUnit(unit_id)
    if not unit then return false end

    unit:takeDamage(damage, damage_type)
    return true
end

--- Record combat action for a unit
-- @param unit_id The unit ID
-- @param action_type Type of action
-- @param value Value associated with action
-- @return true if recorded successfully
function UnitService:recordCombatAction(unit_id, action_type, value)
    local unit = self:getUnit(unit_id)
    if not unit then return false end

    unit:recordCombatAction(action_type, value)
    return true
end

--- Award a medal to a unit
-- @param unit_id The unit ID
-- @param medal_id The medal ID
-- @return true if awarded successfully
function UnitService:awardMedal(unit_id, medal_id)
    self:loadData()
    return self.unit_system:awardMedalToUnit(unit_id, medal_id)
end

--- Apply a trait to a unit
-- @param unit_id The unit ID
-- @param trait_id The trait ID
-- @return true if applied successfully
function UnitService:applyTrait(unit_id, trait_id)
    self:loadData()
    return self.unit_system:applyTraitToUnit(unit_id, trait_id)
end

--- Equip an item on a unit
-- @param unit_id The unit ID
-- @param slot Equipment slot
-- @param item_id Item ID
-- @return true if equipped successfully
function UnitService:equipItem(unit_id, slot, item_id)
    local unit = self:getUnit(unit_id)
    if not unit then return false end

    return unit:equipItem(slot, item_id)
end

--- Add item to unit inventory
-- @param unit_id The unit ID
-- @param item_id Item ID
-- @param quantity Quantity to add
-- @return true if added successfully
function UnitService:addItemToUnit(unit_id, item_id, quantity)
    local unit = self:getUnit(unit_id)
    if not unit then return false end

    unit:addItem(item_id, quantity)
    return true
end

--- Calculate effective stats for a unit
-- @param unit_id The unit ID
-- @return Table of effective stats
function UnitService:calculateEffectiveStats(unit_id)
    self:loadData()
    return self.unit_system:calculateEffectiveStats(unit_id)
end

--- Get unit statistics summary
-- @return Table with unit statistics
function UnitService:getUnitStatistics()
    self:loadData()

    local system_stats = self.unit_system:getUnitStatistics()
    local manager_stats = self.unit_manager:getStatistics()

    -- Combine statistics
    return {
        total_units = system_stats.total_units,
        operational_units = system_stats.operational_units,
        wounded_units = system_stats.wounded_units,
        kia_units = system_stats.kia_units,
        transferring_units = manager_stats.transferring_units,
        by_class = system_stats.by_class,
        by_status = system_stats.by_status,
        by_base = manager_stats.units_by_base,
        average_level = system_stats.average_level,
        total_experience = system_stats.total_experience
    }
end

--- Update all units (called daily)
function UnitService:updateDaily()
    self:loadData()
    self.unit_system:updateDaily()
end

--- Update transfers (called hourly)
function UnitService:updateHourly()
    self:loadData()
    self.unit_manager:updateTransfers()
end

--- Get unit classes
-- @return Table of all unit classes
function UnitService:getUnitClasses()
    self:loadData()
    return self.unit_system:getAllUnitClasses()
end

--- Get unit traits
-- @return Table of all unit traits
function UnitService:getUnitTraits()
    self:loadData()
    return self.unit_system.unit_traits
end

--- Get unit medals
-- @return Table of all unit medals
function UnitService:getUnitMedals()
    self:loadData()
    return self.unit_system.unit_medals
end

--- Remove a unit
-- @param unit_id The unit ID
-- @return true if removed successfully
function UnitService:removeUnit(unit_id)
    self:loadData()
    return self.unit_manager:removeUnit(unit_id)
end

--- Serialize service data
-- @return Table with serializable data
function UnitService:serialize()
    self:loadData()

    return {
        unit_system = self.unit_system:serialize(),
        unit_manager = self.unit_manager:serialize(),
        data_loaded = self.data_loaded
    }
end

--- Deserialize service data
-- @param data The serialized data
function UnitService:deserialize(data)
    if not data then return end

    self.data_loaded = data.data_loaded or false

    if data.unit_system then
        self.unit_system = self.unit_system or require('units.UnitSystem')()
        self.unit_system:deserialize(data.unit_system)
    end

    if data.unit_manager then
        self.unit_manager = self.unit_manager or require('units.UnitManager')()
        self.unit_manager:deserialize(data.unit_manager, self.unit_system)
    end
end

return UnitService
