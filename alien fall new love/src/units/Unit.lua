--- Unit.lua
-- Main unit entity for Alien Fall
-- Represents soldiers, agents, and other personnel with stats, traits, and progression

-- GROK: Unit represents individual personnel with comprehensive stat system, traits, and progression
-- GROK: Used by unit_system for tactical gameplay, base management, and campaign progression
-- GROK: Key methods: takeDamage(), gainExperience(), assignToMission(), isOperational()
-- GROK: Handles stats, equipment, traits, experience, morale, and operational status

local class = require 'lib.Middleclass'
local EquipmentCalculator = require 'units.equipment_calculator'

Unit = class('Unit')

--- Initialize a new unit
-- @param data Unit creation data
function Unit:initialize(data)
    -- Basic identity
    self.id = data.id or tostring(math.random(1000000, 9999999))
    self.name = data.name or "Unnamed Soldier"
    self.nickname = data.nickname or ""

    -- Class and progression
    self.class_id = data.class_id or "recruit"
    self.rank = data.rank or 0
    self.level = data.level or 1

    -- Experience and progression
    self.experience = data.experience or 0
    self.experience_to_next = data.experience_to_next or 100

    -- Core stats (base values)
    self.stats = {
        health = data.health or 100,
        stamina = data.stamina or 100,
        accuracy = data.accuracy or 50,
        reflexes = data.reflexes or 50,
        strength = data.strength or 50,
        mind = data.mind or 50,
        morale = data.morale or 80,
        sanity = data.sanity or 100,
        psi = data.psi or 0,
        sight = data.sight or 15,
        sense = data.sense or 10,
        cover = data.cover or 0,
        size = data.size or 1,
        armor = data.armor or 0
    }

    -- Current status
    self.current_health = self.stats.health
    self.current_stamina = self.stats.stamina
    self.current_morale = self.stats.morale
    self.current_sanity = self.stats.sanity

    -- Action Points and Energy
    self.action_points = data.action_points or 10
    self.max_action_points = self.action_points
    self.energy = data.energy or 50
    self.max_energy = self.energy

    -- Equipment and inventory
    self.equipment = {
        primary_weapon = nil,
        secondary_weapon = nil,
        armor = nil,
        accessory = nil
    }
    self.inventory = data.inventory or {}
    self.encumbrance = 0
    self.max_encumbrance = self:calculateMaxEncumbrance()

    -- Traits and abilities
    self.traits = data.traits or {}
    self.abilities = data.abilities or {}
    self.medals = data.medals or {}

    -- Mission and combat status
    self.status = "barracks" -- barracks, en_route, in_combat, wounded, kia
    self.current_mission = nil
    self.mission_eta = 0

    -- Combat statistics
    self.combat_stats = {
        missions_completed = 0,
        kills = 0,
        shots_fired = 0,
        shots_hit = 0,
        damage_dealt = 0,
        damage_taken = 0,
        missions_survived = 0,
        times_wounded = 0,
        times_panicked = 0
    }

    -- Background and history
    self.origin = data.origin or "military" -- military, scientist, engineer, resistance
    self.recruitment_date = data.recruitment_date or os.date("%Y-%m-%d")
    self.time_served = data.time_served or 0 -- in days

    -- Salary and maintenance
    self.salary = data.salary or 0
    self.maintenance_cost = data.maintenance_cost or 0

    -- Special flags
    self.is_hero = data.is_hero or false
    self.is_veteran = data.is_veteran or false
    self.can_promote = true

    -- Validate data
    self:_validate()
end

--- Validate unit data
function Unit:_validate()
    assert(self.id, "Unit must have an id")
    assert(self.name, "Unit must have a name")
    assert(self.class_id, "Unit must have a class_id")

    -- Validate stats are within reasonable ranges
    for stat, value in pairs(self.stats) do
        assert(type(value) == "number", string.format("Stat %s must be a number", stat))
        assert(value >= 0, string.format("Stat %s must be non-negative", stat))
    end
end

--- Calculate maximum encumbrance based on strength
function Unit:calculateMaxEncumbrance()
    return self.stats.strength * 2 + 20
end

--- Get current health percentage
-- @return Health percentage (0-100)
function Unit:getHealthPercentage()
    return math.floor((self.current_health / self.stats.health) * 100)
end

--- Get current stamina percentage
-- @return Stamina percentage (0-100)
function Unit:getStaminaPercentage()
    return math.floor((self.current_stamina / self.stats.stamina) * 100)
end

--- Get current morale level
-- @return Morale level (0-100)
function Unit:getMorale()
    return self.current_morale
end

--- Get current sanity level
-- @return Sanity level (0-100)
function Unit:getSanity()
    return self.current_sanity
end

--- Check if unit is operational (able to fight)
-- @return true if operational
function Unit:isOperational()
    return self.status == "barracks" or self.status == "en_route" or self.status == "in_combat"
end

--- Check if unit is wounded
-- @return true if wounded
function Unit:isWounded()
    return self.current_health < self.stats.health * 0.5
end

--- Check if unit is fatigued
-- @return true if fatigued
function Unit:isFatigued()
    return self.current_stamina < self.stats.stamina * 0.3
end

--- Check if unit has low morale
-- @return true if low morale
function Unit:hasLowMorale()
    return self.current_morale < 40
end

--- Take damage
-- @param damage Amount of damage
-- @param damage_type Type of damage (default "physical")
-- @return Actual damage taken
function Unit:takeDamage(damage, damage_type)
    damage_type = damage_type or "physical"

    -- Apply armor reduction
    local actual_damage = damage
    if damage_type == "physical" and self.stats.armor > 0 then
        actual_damage = math.max(1, damage - self.stats.armor)
    end

    -- Apply damage
    self.current_health = math.max(0, self.current_health - actual_damage)
    self.combat_stats.damage_taken = self.combat_stats.damage_taken + actual_damage

    -- Check for death
    if self.current_health <= 0 then
        self.status = "kia"
        self.combat_stats.times_wounded = self.combat_stats.times_wounded + 1
    elseif self:isWounded() then
        self.status = "wounded"
    end

    return actual_damage
end

--- Heal damage
-- @param healing Amount of healing
-- @return Actual healing applied
function Unit:heal(healing)
    local old_health = self.current_health
    self.current_health = math.min(self.stats.health, self.current_health + healing)
    local actual_healing = self.current_health - old_health

    -- Update status if no longer wounded
    if self.status == "wounded" and not self:isWounded() then
        self.status = "barracks"
    end

    return actual_healing
end

--- Restore stamina
-- @param amount Amount to restore
function Unit:restoreStamina(amount)
    self.current_stamina = math.min(self.stats.stamina, self.current_stamina + amount)
end

--- Consume stamina
-- @param amount Amount to consume
function Unit:consumeStamina(amount)
    self.current_stamina = math.max(0, self.current_stamina - amount)
end

--- Modify morale
-- @param change Morale change (positive or negative)
function Unit:modifyMorale(change)
    self.current_morale = math.max(0, math.min(100, self.current_morale + change))
end

--- Modify sanity
-- @param change Sanity change (positive or negative)
function Unit:modifySanity(change)
    self.current_sanity = math.max(0, math.min(100, self.current_sanity + change))
end

--- Gain experience
-- @param xp Amount of experience gained
function Unit:gainExperience(xp)
    self.experience = self.experience + xp

    -- Check for level up
    while self.experience >= self.experience_to_next do
        self:levelUp()
    end
end

--- Level up the unit
function Unit:levelUp()
    self.level = self.level + 1
    self.experience = self.experience - self.experience_to_next
    self.experience_to_next = self.level * 100 + 50 -- Simple progression formula

    -- Restore some health and stamina on level up
    self:heal(math.floor(self.stats.health * 0.25))
    self:restoreStamina(math.floor(self.stats.stamina * 0.5))
end

--- Calculate effective stats including level bonuses
-- @return Table of effective stats
function Unit:calculateEffectiveStats()
    local effective = {}
    
    -- Start with base stats
    for stat, value in pairs(self.stats) do
        effective[stat] = value
    end
    
    -- Apply level bonuses (simple linear progression)
    local level_bonus = (self.level - 1) * 2 -- +2 per level
    effective.health = effective.health + level_bonus
    effective.stamina = effective.stamina + level_bonus
    effective.accuracy = effective.accuracy + level_bonus
    effective.reflexes = effective.reflexes + level_bonus
    effective.strength = effective.strength + level_bonus
    effective.mind = effective.mind + level_bonus
    
    return effective
end

--- Add a trait
-- @param trait_id The trait ID to add
function Unit:addTrait(trait_id)
    if not self:hasTrait(trait_id) then
        table.insert(self.traits, trait_id)
    end
end

--- Check if unit has a trait
-- @param trait_id The trait ID to check
-- @return true if unit has the trait
function Unit:hasTrait(trait_id)
    for _, trait in ipairs(self.traits) do
        if trait == trait_id then
            return true
        end
    end
    return false
end

--- Add an ability
-- @param ability_id The ability ID to add
function Unit:addAbility(ability_id)
    if not self:hasAbility(ability_id) then
        table.insert(self.abilities, ability_id)
    end
end

--- Check if unit has an ability
-- @param ability_id The ability ID to check
-- @return true if unit has the ability
function Unit:hasAbility(ability_id)
    for _, ability in ipairs(self.abilities) do
        if ability == ability_id then
            return true
        end
    end
    return false
end

--- Equip an item
-- @param slot Equipment slot
-- @param item_id Item ID to equip
-- @return true if equipped successfully
function Unit:equipItem(slot, item_id)
    if self.equipment[slot] then
        -- Unequip current item first
        self:unequipItem(slot)
    end

    self.equipment[slot] = item_id
    
    -- Update equipment-based stats
    self:_updateEquipmentModifiers()
    
    return true
end

--- Unequip an item
-- @param slot Equipment slot
-- @return The unequipped item ID or nil
function Unit:unequipItem(slot)
    local item_id = self.equipment[slot]
    if item_id then
        self.equipment[slot] = nil
        
        -- Update equipment-based stats
        self:_updateEquipmentModifiers()
    end
    return item_id
end

--- Add item to inventory
-- @param item_id Item ID to add
-- @param quantity Quantity to add (default 1)
function Unit:addItem(item_id, quantity)
    quantity = quantity or 1
    self.inventory[item_id] = (self.inventory[item_id] or 0) + quantity
    
    -- Update encumbrance from inventory
    self:_updateEncumbrance()
end

--- Remove item from inventory
-- @param item_id Item ID to remove
-- @param quantity Quantity to remove (default 1)
-- @return true if removed successfully
function Unit:removeItem(item_id, quantity)
    quantity = quantity or 1
    if (self.inventory[item_id] or 0) >= quantity then
        self.inventory[item_id] = self.inventory[item_id] - quantity
        if self.inventory[item_id] <= 0 then
            self.inventory[item_id] = nil
        end
        
        -- Update encumbrance from inventory
        self:_updateEncumbrance()
        return true
    end
    return false
end

--- Assign unit to mission
-- @param mission_id Mission ID
-- @param eta_hours ETA in hours
function Unit:assignToMission(mission_id, eta_hours)
    self.current_mission = mission_id
    self.mission_eta = eta_hours
    self.status = "en_route"
end

--- Complete mission assignment
function Unit:completeMissionAssignment()
    self.current_mission = nil
    self.mission_eta = 0
    self.status = "barracks"
    self.combat_stats.missions_completed = self.combat_stats.missions_completed + 1
    self.combat_stats.missions_survived = self.combat_stats.missions_survived + 1
end

--- Record combat action
-- @param action_type Type of action (kill, shot_fired, shot_hit, etc.)
-- @param value Value associated with action
function Unit:recordCombatAction(action_type, value)
    if action_type == "kill" then
        self.combat_stats.kills = self.combat_stats.kills + (value or 1)
    elseif action_type == "shot_fired" then
        self.combat_stats.shots_fired = self.combat_stats.shots_fired + (value or 1)
    elseif action_type == "shot_hit" then
        self.combat_stats.shots_hit = self.combat_stats.shots_hit + (value or 1)
    elseif action_type == "damage_dealt" then
        self.combat_stats.damage_dealt = self.combat_stats.damage_dealt + (value or 0)
    end
end

--- Get accuracy percentage
-- @return Accuracy percentage
function Unit:getAccuracyPercentage()
    if self.combat_stats.shots_fired == 0 then return 0 end
    return math.floor((self.combat_stats.shots_hit / self.combat_stats.shots_fired) * 100)
end

--- Calculate salary based on rank and class
function Unit:calculateSalary()
    -- Base salary calculation - can be overridden by data
    local base_salary = 50
    local rank_multiplier = 1 + (self.rank * 0.2)
    local class_multiplier = 1.0 -- Could vary by class

    self.salary = math.floor(base_salary * rank_multiplier * class_multiplier)
    return self.salary
end

--- Calculate maintenance cost
function Unit:calculateMaintenanceCost()
    local EquipmentCalculator = require 'src.units.equipment_calculator'
    
    -- Base maintenance cost
    local base_cost = 10
    local health_penalty = (self.stats.health - self.current_health) / self.stats.health
    
    -- Calculate equipment maintenance penalty
    local equipment_penalty = 0
    if self.equipment then
        equipment_penalty = EquipmentCalculator.calculateMaintenancePenalty(self.equipment)
    end

    self.maintenance_cost = math.floor(base_cost + (base_cost * health_penalty) + equipment_penalty)
    return self.maintenance_cost
end

--- Update unit status (called daily)
function Unit:updateDaily()
    self.time_served = self.time_served + 1

    -- Natural healing when in barracks
    if self.status == "barracks" and self.current_health < self.stats.health then
        self:heal(5) -- Slow natural healing
    end

    -- Stamina recovery
    if self.status == "barracks" then
        self:restoreStamina(20)
    end

    -- Morale recovery
    if self.status == "barracks" and self.current_morale < 80 then
        self:modifyMorale(2)
    end
end

--- Get unit summary for UI display
-- @return Table with unit summary data
function Unit:getSummary()
    return {
        id = self.id,
        name = self.name,
        nickname = self.nickname,
        class_id = self.class_id,
        rank = self.rank,
        level = self.level,
        health_percentage = self:getHealthPercentage(),
        stamina_percentage = self:getStaminaPercentage(),
        morale = self.current_morale,
        sanity = self.current_sanity,
        status = self.status,
        is_operational = self:isOperational(),
        is_wounded = self:isWounded(),
        is_fatigued = self:isFatigued(),
        has_low_morale = self:hasLowMorale()
    }
end

--- Update equipment modifiers (internal)
-- Recalculates all stat modifiers from equipped items
function Unit:_updateEquipmentModifiers()
    -- Calculate modifiers from all equipment
    local modifiers = EquipmentCalculator.calculateModifiers(self.equipment)
    
    -- Apply modifiers to base stats
    self.effective_stats = EquipmentCalculator.applyToStats(self.stats, modifiers)
    
    -- Update encumbrance
    self.encumbrance = EquipmentCalculator.calculateWeight(self.equipment)
end

--- Update encumbrance from inventory (internal)
function Unit:_updateEncumbrance()
    -- Start with equipment weight
    local totalWeight = EquipmentCalculator.calculateWeight(self.equipment)
    
    -- Add inventory weight (if items have weight property)
    for item_id, quantity in pairs(self.inventory) do
        -- This would need item registry to get weight
        -- For now, just recalculate equipment
    end
    
    self.encumbrance = totalWeight
end

--- Get effective stats (with equipment modifiers applied)
-- @return table: Effective stat values
function Unit:getEffectiveStats()
    -- Lazy recalculation if needed
    if not self.effective_stats then
        self:_updateEquipmentModifiers()
    end
    
    return self.effective_stats or self.stats
end

--- Get equipment summary
-- @return table: Equipment summary with modifiers
function Unit:getEquipmentSummary()
    return EquipmentCalculator.getSummary(self.equipment)
end

--- Validate current equipment loadout
-- @param classRestrictions table: Optional class-specific restrictions
-- @return boolean: Whether loadout is valid
-- @return string: Error message if invalid
function Unit:validateEquipment(classRestrictions)
    return EquipmentCalculator.validateEquipment(self.equipment, self.class_id, classRestrictions)
end

--- Convert to string representation
-- @return String representation
function Unit:__tostring()
    return string.format("Unit{id='%s', name='%s', class='%s', level=%d, status='%s'}",
                        self.id, self.name, self.class_id, self.level, self.status)
end

return Unit
