--- ItemUnitArmour Class
-- Represents armor that can be equipped by units
--
-- @classmod domain.items.ItemUnitArmour

local class = require 'lib.Middleclass'
local ItemUnit = require 'items.ItemUnit'

ItemUnitArmour = class('ItemUnitArmour', ItemUnit)

--- Armor slots
ItemUnitArmour.SLOT_BODY = "body"
ItemUnitArmour.SLOT_HEAD = "head"
ItemUnitArmour.SLOT_LEGS = "legs"

--- Create a new unit armor instance
-- @param data Armor data from TOML configuration
-- @return ItemUnitArmour instance
function ItemUnitArmour:initialize(data)
    -- Initialize parent class
    ItemUnit.initialize(self, data)

    -- Armor-specific properties
    self.armor_category = data.armor_category or "medium"

    -- Defensive statistics
    self.defense = data.defense or {}
    self.armor_rating = self.defense.armor_rating or 30
    self.damage_resistances = self.defense.damage_resistances or {}
    self.weaknesses = self.defense.weaknesses or {}

    -- Special properties
    self.properties = data.properties or {}
    self.movement_penalty = self.properties.movement_penalty or 0
    self.stealth_penalty = self.properties.stealth_penalty or 0
    self.passive_effects = self.properties.passive_effects or {}

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
    self.icon = self.visual.icon or "default_armor_icon"
    self.model = self.visual.model or "default_armor_model"
end

--- Calculate damage reduction against incoming damage
-- @param incoming_damage Raw damage amount
-- @param damage_type Type of damage (kinetic, energy, plasma, etc.)
-- @param armor_pierce Attacker's armor piercing value
-- @return number Reduced damage amount
function ItemUnitArmour:getDamageReduction(incoming_damage, damage_type, armor_pierce)
    local effective_armor = math.max(0, self.armor_rating - armor_pierce)

    -- Apply damage type resistances/weaknesses
    local type_modifier = 1.0

    if self.damage_resistances[damage_type] then
        type_modifier = type_modifier * (1.0 - self.damage_resistances[damage_type])
    end

    if self.weaknesses[damage_type] then
        type_modifier = type_modifier * (1.0 + self.weaknesses[damage_type])
    end

    -- Calculate reduction
    local reduction = effective_armor * 0.1 * type_modifier  -- 10% per armor point, modified by type
    local reduced_damage = incoming_damage * (1.0 - math.min(0.8, reduction))  -- Max 80% reduction

    -- Ensure minimum damage gets through
    local minimum_damage = math.max(1, incoming_damage * 0.1)  -- At least 10% of original damage

    return math.max(minimum_damage, reduced_damage)
end

--- Get armor rating against specific damage type
-- @param damage_type Type of damage
-- @return number Effective armor rating
function ItemUnitArmour:getEffectiveArmor(damage_type)
    local base_armor = self.armor_rating

    -- Apply type-specific modifiers
    if self.damage_resistances[damage_type] then
        base_armor = base_armor * (1.0 + self.damage_resistances[damage_type])
    end

    if self.weaknesses[damage_type] then
        base_armor = base_armor * (1.0 - self.weaknesses[damage_type])
    end

    return math.floor(base_armor)
end

--- Check if armor is compatible with a unit
-- @param unit_race Unit race
-- @param unit_traits Unit traits
-- @param unit_strength Unit strength for weight limits
-- @return boolean True if compatible
function ItemUnitArmour:isCompatible(unit_race, unit_traits, unit_strength)
    -- Check weight limits
    if unit_strength and self.weight > unit_strength then
        return false
    end

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

--- Get movement penalty from this armor
-- @return number Movement penalty (AP cost increase)
function ItemUnitArmour:getMovementPenalty()
    return self.movement_penalty
end

--- Get stealth penalty from this armor
-- @return number Stealth penalty (detection increase)
function ItemUnitArmour:getStealthPenalty()
    return self.stealth_penalty
end

--- Get passive effects provided by this armor
-- @return table Passive effects
function ItemUnitArmour:getPassiveEffects()
    return self.passive_effects
end

--- Get tactical role information
-- @return table Role data
function ItemUnitArmour:getTacticalRoleInfo()
    return {
        role = self.tactical_role,
        bonuses = self.role_bonus
    }
end

--- Get armor statistics for UI display
-- @return table Armor stats
function ItemUnitArmour:getArmorStats()
    return {
        armor_rating = self.armor_rating,
        weight = self.weight,
        movement_penalty = self.movement_penalty,
        stealth_penalty = self.stealth_penalty,
        damage_resistances = self.damage_resistances,
        weaknesses = self.weaknesses
    }
end

--- Get display information for UI
-- @return table Display data
function ItemUnitArmour:getDisplayInfo()
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
        stats = self:getArmorStats(),
        passive_effects = self.passive_effects
    }
end

--- Check if armor provides resistance to a damage type
-- @param damage_type Type of damage
-- @return number Resistance value (0.0 to 1.0, where 1.0 is immune)
function ItemUnitArmour:getResistance(damage_type)
    return self.damage_resistances[damage_type] or 0.0
end

--- Check if armor has weakness to a damage type
-- @param damage_type Type of damage
-- @return number Weakness value (0.0 to 1.0, where 1.0 doubles damage)
function ItemUnitArmour:getWeakness(damage_type)
    return self.weaknesses[damage_type] or 0.0
end

--- Get item data for serialization (override parent)
-- @return table Item data
function ItemUnitArmour:getData()
    local data = ItemUnit.getData(self)

    -- Add armor-specific data
    data.armor_category = self.armor_category
    data.defense = {
        armor_rating = self.armor_rating,
        damage_resistances = self.damage_resistances,
        weaknesses = self.weaknesses
    }
    data.properties = {
        movement_penalty = self.movement_penalty,
        stealth_penalty = self.stealth_penalty,
        passive_effects = self.passive_effects
    }
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

return ItemUnitArmour
