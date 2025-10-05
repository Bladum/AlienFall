--- ItemCraftWeapon Class
-- Represents weapons that can be equipped on craft
--
-- @classmod domain.items.ItemCraftWeapon

local class = require 'lib.Middleclass'
local ItemCraft = require 'items.ItemCraft'

ItemCraftWeapon = class('ItemCraftWeapon', ItemCraft)

--- Weapon targeting types
ItemCraftWeapon.TARGET_AIR_TO_AIR = "air_to_air"
ItemCraftWeapon.TARGET_AIR_TO_GROUND = "air_to_ground"
ItemCraftWeapon.TARGET_GROUND_TO_AIR = "ground_to_air"
ItemCraftWeapon.TARGET_GROUND_TO_GROUND = "ground_to_ground"

--- Create a new craft weapon instance
-- @param data Weapon data from TOML configuration
-- @return ItemCraftWeapon instance
function ItemCraftWeapon:initialize(data)
    -- Initialize parent class
    ItemCraft.initialize(self, data)

    -- Weapon-specific properties
    self.weapon_category = data.weapon_category or "laser"

    -- Combat statistics
    self.damage = data.damage or {}
    self.base_damage = self.damage.base or 50
    self.damage_type = self.damage.type or "energy"
    self.armor_pierce = self.damage.armor_pierce or 0

    -- Targeting and range
    self.targeting = data.targeting or {}
    self.target_type = self.targeting.type or ItemCraftWeapon.TARGET_AIR_TO_AIR
    self.range = self.targeting.range or 20
    self.min_range = self.targeting.min_range or 0

    -- Resource consumption
    self.ap_cost = data.ap_cost or 2
    self.energy_cost = data.energy_cost or 10
    self.cooldown = data.cooldown or 1

    -- Accuracy and reliability
    self.accuracy = data.accuracy or {}
    self.base_accuracy = self.accuracy.base or 60
    self.accuracy_modifiers = self.accuracy.modifiers or {}

    -- Special properties
    self.properties = data.properties or {}
    self.tags = self.properties.tags or {}
    self.special_effects = self.properties.special_effects or {}

    -- Compatibility and restrictions
    self.compatibility = data.compatibility or {}
    self.allowed_craft_types = self.compatibility.allowed_craft_types or {}
    self.restricted_craft_types = self.compatibility.restricted_craft_types or {}
    self.required_addons = self.compatibility.required_addons or {}

    -- Tactical role integration
    self.tactical_role = data.tactical_role or "general"

    -- Visual and UI properties
    self.visual = data.visual or {}
    self.icon = self.visual.icon or "default_craft_weapon_icon"
    self.model = self.visual.model or "default_craft_weapon_model"
end

--- Calculate hit chance against a target
-- @param distance Distance to target
-- @param target_evasion Target evasion rating
-- @param craft_accuracy Craft's base accuracy
-- @param conditions Combat conditions (weather, etc.)
-- @return number Hit chance percentage (0-100)
function ItemCraftWeapon:calculateHitChance(distance, target_evasion, craft_accuracy, conditions)
    local hit_chance = self.base_accuracy + (craft_accuracy or 0)

    -- Apply range modifiers
    if distance > self.range then
        return 0  -- Out of range
    elseif distance < self.min_range then
        hit_chance = hit_chance * 0.5  -- Too close penalty
    end

    -- Apply distance falloff
    local optimal_range = self.range * 0.6
    if distance > optimal_range then
        local falloff_ratio = (distance - optimal_range) / (self.range - optimal_range)
        hit_chance = hit_chance * (1.0 - falloff_ratio * 0.3)  -- 30% reduction at max range
    end

    -- Apply target evasion
    hit_chance = hit_chance - target_evasion

    -- Apply accuracy modifiers
    for condition, modifier in pairs(self.accuracy_modifiers) do
        if conditions and conditions[condition] then
            hit_chance = hit_chance * modifier
        end
    end

    -- Apply condition modifiers
    if conditions then
        if conditions.weather == "storm" then
            hit_chance = hit_chance * 0.7
        elseif conditions.weather == "clear" then
            hit_chance = hit_chance * 1.1
        end
    end

    return math.max(5, math.min(95, hit_chance))  -- Clamp between 5% and 95%
end

--- Calculate travel time for projectile to reach target
-- @param distance Distance to target
-- @return number Travel time in turns
function ItemCraftWeapon:getTravelTime(distance)
    if distance <= 0 then return 0 end

    -- Simple calculation: distance / weapon range * base travel time
    local base_travel_time = 1
    local travel_ratio = distance / self.range

    return math.max(1, math.ceil(travel_ratio * base_travel_time))
end

--- Check if weapon can target a specific type of target
-- @param target_type Target type (air, ground, etc.)
-- @param weapon_altitude Current altitude
-- @param target_altitude Target altitude
-- @return boolean True if can target
function ItemCraftWeapon:canTarget(target_type, weapon_altitude, target_altitude)
    -- Check basic targeting type
    if self.target_type == ItemCraftWeapon.TARGET_AIR_TO_AIR then
        return target_type == "air" and weapon_altitude > 0 and target_altitude > 0
    elseif self.target_type == ItemCraftWeapon.TARGET_AIR_TO_GROUND then
        return target_type == "ground" and weapon_altitude > 0 and target_altitude <= 0
    elseif self.target_type == ItemCraftWeapon.TARGET_GROUND_TO_AIR then
        return target_type == "air" and weapon_altitude <= 0 and target_altitude > 0
    elseif self.target_type == ItemCraftWeapon.TARGET_GROUND_TO_GROUND then
        return target_type == "ground" and weapon_altitude <= 0 and target_altitude <= 0
    end

    return false
end

--- Check if weapon is in range of target
-- @param distance Distance to target
-- @return boolean True if in range
function ItemCraftWeapon:isInRange(distance)
    return distance >= self.min_range and distance <= self.range
end

--- Get AP cost for using this weapon
-- @return number AP cost
function ItemCraftWeapon:getAPCost()
    return self.ap_cost
end

--- Get energy cost for using this weapon
-- @return number Energy cost
function ItemCraftWeapon:getEnergyCost()
    return self.energy_cost
end

--- Get cooldown after using this weapon
-- @return number Cooldown in turns
function ItemCraftWeapon:getCooldown()
    return self.cooldown
end

--- Check if weapon is compatible with a craft
-- @param craft_type Craft type
-- @param equipped_addons Currently equipped addons
-- @param available_capacity Available capacity
-- @return boolean True if compatible
function ItemCraftWeapon:isCompatible(craft_type, equipped_addons, available_capacity)
    -- Check capacity
    if self.size > available_capacity then
        return false
    end

    -- Check craft type restrictions
    if #self.restricted_craft_types > 0 then
        for _, restricted_type in ipairs(self.restricted_craft_types) do
            if restricted_type == craft_type then
                return false
            end
        end
    end

    -- Check craft type allowances (if specified)
    if #self.allowed_craft_types > 0 then
        local type_allowed = false
        for _, allowed_type in ipairs(self.allowed_craft_types) do
            if allowed_type == craft_type then
                type_allowed = true
                break
            end
        end
        if not type_allowed then
            return false
        end
    end

    -- Check required addons
    for _, required_addon in ipairs(self.required_addons) do
        local has_addon = false
        for _, equipped_addon in ipairs(equipped_addons or {}) do
            if equipped_addon == required_addon then
                has_addon = true
                break
            end
        end
        if not has_addon then
            return false
        end
    end

    return true
end

--- Get weapon statistics for UI display
-- @return table Weapon stats
function ItemCraftWeapon:getWeaponStats()
    return {
        damage = self.base_damage,
        damage_type = self.damage_type,
        armor_pierce = self.armor_pierce,
        range = self.range,
        min_range = self.min_range,
        target_type = self.target_type,
        ap_cost = self.ap_cost,
        energy_cost = self.energy_cost,
        cooldown = self.cooldown,
        base_accuracy = self.base_accuracy,
        size = self.size
    }
end

--- Get display information for UI
-- @return table Display data
function ItemCraftWeapon:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        category = self.category,
        tier = self.tier,
        size = self.size,
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
function ItemCraftWeapon:hasTag(tag)
    for _, weapon_tag in ipairs(self.tags) do
        if weapon_tag == tag then
            return true
        end
    end
    return false
end

--- Get special effects of this weapon
-- @return table Special effects
function ItemCraftWeapon:getSpecialEffects()
    return self.special_effects
end

--- Get item data for serialization (override parent)
-- @return table Item data
function ItemCraftWeapon:getData()
    local data = ItemCraft.getData(self)

    -- Add weapon-specific data
    data.weapon_category = self.weapon_category
    data.damage = {
        base = self.base_damage,
        type = self.damage_type,
        armor_pierce = self.armor_pierce
    }
    data.targeting = {
        type = self.target_type,
        range = self.range,
        min_range = self.min_range
    }
    data.ap_cost = self.ap_cost
    data.energy_cost = self.energy_cost
    data.cooldown = self.cooldown
    data.accuracy = {
        base = self.base_accuracy,
        modifiers = self.accuracy_modifiers
    }
    data.properties = self.properties
    data.tags = self.tags
    data.special_effects = self.special_effects
    data.compatibility = {
        allowed_craft_types = self.allowed_craft_types,
        restricted_craft_types = self.restricted_craft_types,
        required_addons = self.required_addons
    }
    data.tactical_role = self.tactical_role
    data.visual = {
        icon = self.icon,
        model = self.model
    }

    return data
end

return ItemCraftWeapon
