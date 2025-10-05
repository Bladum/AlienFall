--- ItemCraftAddon Class
-- Represents addon equipment that can be equipped on craft
--
-- @classmod domain.items.ItemCraftAddon

local class = require 'lib.Middleclass'
local ItemCraft = require 'items.ItemCraft'

ItemCraftAddon = class('ItemCraftAddon', ItemCraft)

--- Addon types
ItemCraftAddon.TYPE_PASSIVE = "passive"
ItemCraftAddon.TYPE_ACTIVE = "active"
ItemCraftAddon.TYPE_ENERGY = "energy"

--- Create a new craft addon instance
-- @param data Addon data from TOML configuration
-- @return ItemCraftAddon instance
function ItemCraftAddon:initialize(data)
    -- Initialize parent class
    ItemCraft.initialize(self, data)

    -- Addon-specific properties
    self.addon_category = data.addon_category or "utility"

    -- Addon type and activation
    self.addon_type = data.addon_type or ItemCraftAddon.TYPE_PASSIVE
    self.activation_cost = data.activation_cost or {}
    self.ap_cost = self.activation_cost.ap or 0
    self.energy_cost = self.activation_cost.energy or 0
    self.cooldown = data.cooldown or 0

    -- Effects and bonuses
    self.effects = data.effects or {}
    self.passive_bonuses = self.effects.passive_bonuses or {}
    self.active_effects = self.effects.active_effects or {}
    self.energy_bonus = self.effects.energy_bonus or 0

    -- Special properties
    self.properties = data.properties or {}
    self.tags = self.properties.tags or {}
    self.special_abilities = self.properties.special_abilities or {}

    -- Compatibility and restrictions
    self.compatibility = data.compatibility or {}
    self.allowed_craft_types = self.compatibility.allowed_craft_types or {}
    self.restricted_craft_types = self.compatibility.restricted_craft_types or {}
    self.mutual_exclusions = self.compatibility.mutual_exclusions or {}

    -- Tactical role integration
    self.tactical_role = data.tactical_role or "general"

    -- Visual and UI properties
    self.visual = data.visual or {}
    self.icon = self.visual.icon or "default_craft_addon_icon"
    self.model = self.visual.model or "default_craft_addon_model"

    -- State tracking
    self.is_active = false
    self.cooldown_remaining = 0
end

--- Get passive bonuses provided by this addon
-- @return table Passive bonuses
function ItemCraftAddon:getPassiveBonuses()
    return self.passive_bonuses
end

--- Get energy bonus provided by this addon
-- @return number Energy bonus
function ItemCraftAddon:getEnergyBonus()
    return self.energy_bonus
end

--- Activate the addon's special ability (if active type)
-- @return boolean Success status
function ItemCraftAddon:activateAbility()
    if self.addon_type ~= ItemCraftAddon.TYPE_ACTIVE then
        return false, "Addon is not activatable"
    end

    if self.cooldown_remaining > 0 then
        return false, "Addon is on cooldown"
    end

    if self.ap_cost > 0 or self.energy_cost > 0 then
        -- Would check AP/energy availability here
        -- For now, assume activation succeeds
    end

    self.is_active = true
    self.cooldown_remaining = self.cooldown

    return true
end

--- Update addon state (called each turn)
function ItemCraftAddon:update()
    if self.cooldown_remaining > 0 then
        self.cooldown_remaining = self.cooldown_remaining - 1
    end

    -- Deactivate active effects after duration (simplified)
    if self.is_active and self.cooldown_remaining <= 0 then
        self.is_active = false
    end
end

--- Get active effects (if addon is currently active)
-- @return table Active effects or nil
function ItemCraftAddon:getActiveEffects()
    if not self.is_active then return nil end
    return self.active_effects
end

--- Check if addon is compatible with a craft
-- @param craft_type Craft type
-- @param equipped_addons Currently equipped addons
-- @param available_capacity Available capacity
-- @return boolean True if compatible
function ItemCraftAddon:isCompatible(craft_type, equipped_addons, available_capacity)
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

    -- Check mutual exclusions
    for _, excluded_addon in ipairs(self.mutual_exclusions) do
        for _, equipped_addon in ipairs(equipped_addons or {}) do
            if equipped_addon == excluded_addon then
                return false
            end
        end
    end

    return true
end

--- Get addon statistics for UI display
-- @return table Addon stats
function ItemCraftAddon:getAddonStats()
    return {
        addon_type = self.addon_type,
        size = self.size,
        energy_bonus = self.energy_bonus,
        ap_cost = self.ap_cost,
        energy_cost = self.energy_cost,
        cooldown = self.cooldown,
        passive_bonuses = self.passive_bonuses,
        active_effects = self.active_effects
    }
end

--- Get display information for UI
-- @return table Display data
function ItemCraftAddon:getDisplayInfo()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        category = self.category,
        tier = self.tier,
        size = self.size,
        weight = self.weight,
        icon = self.icon,
        addon_type = self.addon_type,
        tactical_role = self.tactical_role,
        tags = self.tags,
        stats = self:getAddonStats(),
        is_active = self.is_active,
        cooldown_remaining = self.cooldown_remaining
    }
end

--- Check if addon has a specific tag
-- @param tag Tag to check for
-- @return boolean True if addon has the tag
function ItemCraftAddon:hasTag(tag)
    for _, addon_tag in ipairs(self.tags) do
        if addon_tag == tag then
            return true
        end
    end
    return false
end

--- Get special abilities of this addon
-- @return table Special abilities
function ItemCraftAddon:getSpecialAbilities()
    return self.special_abilities
end

--- Check if addon can be activated
-- @return boolean True if can activate
function ItemCraftAddon:canActivate()
    return self.addon_type == ItemCraftAddon.TYPE_ACTIVE and
           self.cooldown_remaining <= 0
end

--- Get activation costs
-- @return table Cost data
function ItemCraftAddon:getActivationCosts()
    return {
        ap_cost = self.ap_cost,
        energy_cost = self.energy_cost
    }
end

--- Get item data for serialization (override parent)
-- @return table Item data
function ItemCraftAddon:getData()
    local data = ItemCraft.getData(self)

    -- Add addon-specific data
    data.addon_category = self.addon_category
    data.addon_type = self.addon_type
    data.activation_cost = {
        ap = self.ap_cost,
        energy = self.energy_cost
    }
    data.cooldown = self.cooldown
    data.effects = {
        passive_bonuses = self.passive_bonuses,
        active_effects = self.active_effects,
        energy_bonus = self.energy_bonus
    }
    data.properties = self.properties
    data.tags = self.tags
    data.special_abilities = self.special_abilities
    data.compatibility = {
        allowed_craft_types = self.allowed_craft_types,
        restricted_craft_types = self.restricted_craft_types,
        mutual_exclusions = self.mutual_exclusions
    }
    data.tactical_role = self.tactical_role
    data.visual = {
        icon = self.icon,
        model = self.model
    }
    data.state = {
        is_active = self.is_active,
        cooldown_remaining = self.cooldown_remaining
    }

    return data
end

return ItemCraftAddon
