--- ItemUnitWeapon Class
-- Represents weapons that can be equipped by units
--
-- @classmod domain.items.ItemUnitWeapon

local class = require 'lib.Middleclass'
local ItemUnit = require 'items.ItemUnit'

ItemUnitWeapon = class('ItemUnitWeapon', ItemUnit)

--- Weapon slots
ItemUnitWeapon.SLOT_PRIMARY = "primary"
ItemUnitWeapon.SLOT_SECONDARY = "secondary"

--- Create a new unit weapon instance
-- @param data Weapon data from TOML configuration
-- @return ItemUnitWeapon instance
function ItemUnitWeapon:initialize(data)
    -- Initialize parent class
    ItemUnit.initialize(self, data)

    -- Weapon-specific properties
    self.weapon_category = data.weapon_category or "rifle"

    -- Combat statistics
    self.damage = data.damage or {}
    self.base_damage = self.damage.base or 30
    self.damage_type = self.damage.type or "kinetic"
    self.armor_pierce = self.damage.armor_pierce or 0
    self.critical_multiplier = self.damage.critical_multiplier or 1.5

    -- Range and accuracy
    self.range = data.range or {}
    self.min_range = self.range.min or 0
    self.max_range = self.range.max or 20
    self.optimal_range = self.range.optimal or 15
    self.accuracy_profile = self.range.accuracy_profile or {}

    -- Energy and resource consumption
    self.energy_cost = data.energy_cost or 3
    self.ammo_capacity = data.ammo_capacity or 0  -- 0 = unlimited within energy constraints

    -- Special properties
    self.properties = data.properties or {}
    self.tags = self.properties.tags or {}
    self.special_effects = self.properties.special_effects or {}

    -- Compatibility and restrictions
    self.compatibility = data.compatibility or {}
    self.allowed_races = self.compatibility.allowed_races or {}
    self.restricted_races = self.compatibility.restricted_races or {}
    self.required_traits = self.compatibility.required_traits or {}

    -- Tactical role integration
    self.tactical_role = data.tactical_role or "general"
    self.role_bonus = data.role_bonus or {}

    -- Visual and UI properties
    self.visual = data.visual or {}
    self.icon = self.visual.icon or "default_weapon_icon"
    self.model = self.visual.model or "default_weapon_model"
end

--- Calculate damage output based on range and conditions
-- @param distance Distance to target
-- @param target_armor Target armor rating
-- @param critical_hit Whether this is a critical hit
-- @return number Final damage value
function ItemUnitWeapon:calculateDamage(distance, target_armor, critical_hit)
    local damage = self.base_damage

    -- Apply range modifiers
    local range_modifier = self:getRangeModifier(distance)
    damage = damage * range_modifier

    -- Apply armor penetration
    local effective_armor = math.max(0, target_armor - self.armor_pierce)
    local armor_reduction = effective_armor * 0.1  -- 10% damage reduction per armor point
    damage = damage * (1.0 - math.min(0.8, armor_reduction))  -- Max 80% reduction

    -- Apply critical multiplier
    if critical_hit then
        damage = damage * self.critical_multiplier
    end

    return math.floor(damage)
end

--- Get range modifier for accuracy/damage at given distance
-- @param distance Distance to target
-- @return number Range modifier (0.0 to 1.0)
function ItemUnitWeapon:getRangeModifier(distance)
    if distance < self.min_range then
        return 0.5  -- Penalty for too close
    elseif distance > self.max_range then
        return 0.0  -- Cannot fire beyond max range
    elseif distance <= self.optimal_range then
        return 1.0  -- Optimal range
    else
        -- Linear falloff beyond optimal range
        local falloff_distance = self.max_range - self.optimal_range
        local distance_beyond_optimal = distance - self.optimal_range
        local falloff_ratio = distance_beyond_optimal / falloff_distance
        return 1.0 - (falloff_ratio * 0.5)  -- 50% reduction at max range
    end
end

--- Get accuracy modifier at given distance
-- @param distance Distance to target
-- @param unit_accuracy Base unit accuracy
-- @return number Accuracy modifier
function ItemUnitWeapon:getAccuracyModifier(distance, unit_accuracy)
    local range_modifier = self:getRangeModifier(distance)
    local base_accuracy = unit_accuracy or 50

    -- Apply range-based accuracy falloff
    local accuracy_modifier = range_modifier

    -- Apply weapon-specific accuracy profile
    if self.accuracy_profile[distance] then
        accuracy_modifier = accuracy_modifier * self.accuracy_profile[distance]
    end

    return accuracy_modifier
end

--- Check if weapon can be used at given distance
-- @param distance Distance to target
-- @return boolean True if in range
function ItemUnitWeapon:isInRange(distance)
    return distance >= self.min_range and distance <= self.max_range
end

--- Get energy cost for using this weapon
-- @param action_type Type of action (single, burst, etc.)
-- @return number Energy cost
function ItemUnitWeapon:getEnergyCost(action_type)
    local base_cost = self.energy_cost

    -- Apply action type modifiers
    if action_type == "burst" then
        base_cost = base_cost * 2
    elseif action_type == "auto" then
        base_cost = base_cost * 3
    elseif action_type == "suppressive" then
        base_cost = base_cost * 4
    end

    return base_cost
end

--- Check if weapon is compatible with a unit
-- @param unit_race Unit race
-- @param unit_traits Unit traits
-- @return boolean True if compatible
function ItemUnitWeapon:isCompatible(unit_race, unit_traits)
    -- Check race restrictions
    if #self.restricted_races > 0 then
        for _, restricted_race in ipairs(self.restricted_races) do
            if restricted_race == unit_race then
                return false
            end
        end
    end

    -- Check race allowances (if specified)
    if #self.allowed_races > 0 then
        local race_allowed = false
        for _, allowed_race in ipairs(self.allowed_races) do
            if allowed_race == unit_race then
                race_allowed = true
                break
            end
        end
        if not race_allowed then
            return false
        end
    end

    -- Check trait requirements
    for _, required_trait in ipairs(self.required_traits) do
        local has_trait = false
        for _, unit_trait in ipairs(unit_traits or {}) do
            if unit_trait == required_trait then
                has_trait = true
                break
            end
        end
        if not has_trait then
            return false
        end
    end

    return true
end

--- Get tactical role information
-- @return table Role data
function ItemUnitWeapon:getTacticalRoleInfo()
    return {
        role = self.tactical_role,
        bonuses = self.role_bonus,
        tags = self.tags
    }
end

--- Get weapon statistics for UI display
-- @return table Weapon stats
function ItemUnitWeapon:getWeaponStats()
    return {
        damage = self.base_damage,
        damage_type = self.damage_type,
        armor_pierce = self.armor_pierce,
        critical_multiplier = self.critical_multiplier,
        min_range = self.min_range,
        max_range = self.max_range,
        optimal_range = self.optimal_range,
        energy_cost = self.energy_cost,
        weight = self.weight
    }
end

--- Get display information for UI
-- @return table Display data
function ItemUnitWeapon:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        category = self.category,
        slot = self.slot,
        tier = self.tier,
        weight = self.weight,
        icon = self.icon,
        tactical_role = self.tactical_role,
        tags = self.tags,
        stats = self:getWeaponStats()
    }
end

--- Check if weapon has a specific tag
-- @param tag Tag to check for
-- @return boolean True if weapon has the tag
function ItemUnitWeapon:hasTag(tag)
    for _, weapon_tag in ipairs(self.tags) do
        if weapon_tag == tag then
            return true
        end
    end
    return false
end

--- Get special effects of this weapon
-- @return table Special effects
function ItemUnitWeapon:getSpecialEffects()
    return self.special_effects
end

--- Get item data for serialization (override parent)
-- @return table Item data
function ItemUnitWeapon:getData()
    local data = ItemUnit.getData(self)

    -- Add weapon-specific data
    data.weapon_category = self.weapon_category
    data.damage = {
        base = self.base_damage,
        type = self.damage_type,
        armor_pierce = self.armor_pierce,
        critical_multiplier = self.critical_multiplier
    }
    data.range = {
        min = self.min_range,
        max = self.max_range,
        optimal = self.optimal_range,
        accuracy_profile = self.accuracy_profile
    }
    data.energy_cost = self.energy_cost
    data.ammo_capacity = self.ammo_capacity
    data.properties = self.properties
    data.tags = self.tags
    data.special_effects = self.special_effects
    data.compatibility = {
        allowed_races = self.allowed_races,
        restricted_races = self.restricted_races,
        required_traits = self.required_traits
    }
    data.tactical_role = self.tactical_role
    data.role_bonus = self.role_bonus
    data.visual = {
        icon = self.icon,
        model = self.model
    }

    return data
end

return ItemUnitWeapon
