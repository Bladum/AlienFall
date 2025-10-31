---@class TraitSystem
---@field traits table<string, TraitDefinition>
---@field synergies table<string, table>
local TraitSystem = {}

--- Trait definition structure
---@class TraitDefinition
---@field id string Unique identifier
---@field name string Display name
---@field description string Effect description
---@field type "positive"|"negative"|"neutral"
---@field category "combat"|"physical"|"mental"|"support"
---@field balance_cost number Balance point value
---@field acquisition "birth"|"achievement"|"perk"
---@field requirements table Prerequisites for acquisition
---@field conflicts table<string> Incompatible trait IDs
---@field synergies table<string> Beneficial trait combinations
---@field effects table Stat and ability modifiers

-- Initialize trait system
function TraitSystem:init()
    self.traits = {}
    self.synergies = {}
    self:loadTraitDefinitions()
end

-- Load all trait definitions
function TraitSystem:loadTraitDefinitions()
    -- Combat Traits
    self:addTrait({
        id = "quick_reflexes",
        name = "Quick Reflexes",
        description = "+2 Reaction stat",
        type = "positive",
        category = "combat",
        balance_cost = 2,
        acquisition = "birth",
        requirements = {},
        conflicts = {"slow_reflexes"},
        synergies = {"steady_hand"},
        effects = {reaction = 2}
    })

    self:addTrait({
        id = "sharp_eyes",
        name = "Sharp Eyes",
        description = "+1 Aim stat",
        type = "positive",
        category = "combat",
        balance_cost = 1,
        acquisition = "birth",
        requirements = {},
        conflicts = {"poor_vision"},
        synergies = {"marksman"},
        effects = {aim = 1}
    })

    self:addTrait({
        id = "steady_hand",
        name = "Steady Hand",
        description = "+5% accuracy",
        type = "positive",
        category = "combat",
        balance_cost = 1,
        acquisition = "birth",
        requirements = {},
        conflicts = {},
        synergies = {"marksman", "quick_reflexes"},
        effects = {accuracy_bonus = 5}
    })

    self:addTrait({
        id = "marksman",
        name = "Marksman",
        description = "+1 Aim, +1 weapon accuracy",
        type = "positive",
        category = "combat",
        balance_cost = 2,
        acquisition = "achievement",
        requirements = {kills_with_rifle = 20, rank_min = 3},
        conflicts = {},
        synergies = {"sharp_eyes", "steady_hand"},
        effects = {aim = 1, weapon_accuracy = 1}
    })

    self:addTrait({
        id = "close_combat_expert",
        name = "Close Combat Expert",
        description = "+2 Melee, +2 damage",
        type = "positive",
        category = "combat",
        balance_cost = 2,
        acquisition = "achievement",
        requirements = {melee_kills = 15, rank_min = 4},
        conflicts = {},
        synergies = {},
        effects = {melee = 2, melee_damage = 2}
    })

    -- Physical Traits
    self:addTrait({
        id = "strong_build",
        name = "Strong Build",
        description = "+2 Strength stat",
        type = "positive",
        category = "physical",
        balance_cost = 2,
        acquisition = "birth",
        requirements = {},
        conflicts = {"weak_lungs"},
        synergies = {},
        effects = {strength = 2}
    })

    self:addTrait({
        id = "marathon_runner",
        name = "Marathon Runner",
        description = "+2 Speed stat",
        type = "positive",
        category = "physical",
        balance_cost = 2,
        acquisition = "birth",
        requirements = {},
        conflicts = {"disabled"},
        synergies = {"scout"},
        effects = {speed = 2}
    })

    self:addTrait({
        id = "heavy_build",
        name = "Heavy Build",
        description = "+1 Strength, +1 Health",
        type = "positive",
        category = "physical",
        balance_cost = 2,
        acquisition = "birth",
        requirements = {},
        conflicts = {},
        synergies = {},
        effects = {strength = 1, health = 1}
    })

    self:addTrait({
        id = "superhuman_strength",
        name = "Superhuman Strength",
        description = "+3 Strength permanently",
        type = "positive",
        category = "physical",
        balance_cost = 3,
        acquisition = "perk",
        requirements = {rank = 8},
        conflicts = {},
        synergies = {},
        effects = {strength = 3}
    })

    -- Mental Traits
    self:addTrait({
        id = "iron_will",
        name = "Iron Will",
        description = "+2 Bravery stat",
        type = "positive",
        category = "mental",
        balance_cost = 2,
        acquisition = "birth",
        requirements = {},
        conflicts = {},
        synergies = {},
        effects = {bravery = 2}
    })

    self:addTrait({
        id = "calm_under_pressure",
        name = "Calm Under Pressure",
        description = "+1 Sanity, -1 panic chance",
        type = "positive",
        category = "mental",
        balance_cost = 1,
        acquisition = "birth",
        requirements = {},
        conflicts = {},
        synergies = {},
        effects = {sanity = 1, panic_reduction = 1}
    })

    self:addTrait({
        id = "natural_leader",
        name = "Natural Leader",
        description = "+1 nearby unit morale",
        type = "positive",
        category = "mental",
        balance_cost = 1,
        acquisition = "birth",
        requirements = {},
        conflicts = {"loner"},
        synergies = {"commanding_officer"},
        effects = {nearby_morale = 1}
    })

    self:addTrait({
        id = "battle_hardened",
        name = "Battle Hardened",
        description = "Immune to suppression",
        type = "positive",
        category = "mental",
        balance_cost = 2,
        acquisition = "achievement",
        requirements = {missions_completed = 50, rank_min = 5},
        conflicts = {},
        synergies = {},
        effects = {suppression_immunity = true}
    })

    self:addTrait({
        id = "commanding_officer",
        name = "Commanding Officer",
        description = "+2 nearby unit morale",
        type = "positive",
        category = "mental",
        balance_cost = 3,
        acquisition = "perk",
        requirements = {rank = 8},
        conflicts = {},
        synergies = {"natural_leader"},
        effects = {nearby_morale = 2}
    })

    -- Support Traits
    self:addTrait({
        id = "natural_medic",
        name = "Natural Medic",
        description = "+1 heal per bandage",
        type = "positive",
        category = "support",
        balance_cost = 1,
        acquisition = "birth",
        requirements = {},
        conflicts = {"hemophobic"},
        synergies = {"healer"},
        effects = {healing_per_bandage = 1}
    })

    self:addTrait({
        id = "healer",
        name = "Healer",
        description = "+50% recovery speed",
        type = "positive",
        category = "support",
        balance_cost = 2,
        acquisition = "achievement",
        requirements = {damage_healed = 100, rank_min = 4},
        conflicts = {},
        synergies = {"natural_medic"},
        effects = {recovery_speed_bonus = 50}
    })

    self:addTrait({
        id = "resourceful",
        name = "Resourceful",
        description = "+1 extra ammo per clip",
        type = "positive",
        category = "support",
        balance_cost = 1,
        acquisition = "birth",
        requirements = {},
        conflicts = {},
        synergies = {},
        effects = {ammo_per_clip = 1}
    })

    self:addTrait({
        id = "field_engineer",
        name = "Field Engineer",
        description = "Can repair equipment in field",
        type = "positive",
        category = "support",
        balance_cost = 2,
        acquisition = "achievement",
        requirements = {equipment_repaired = 10, rank_min = 5},
        conflicts = {},
        synergies = {},
        effects = {can_repair_equipment = true}
    })

    -- Negative Traits
    self:addTrait({
        id = "weak_lungs",
        name = "Weak Lungs",
        description = "-1 Sanity stat",
        type = "negative",
        category = "physical",
        balance_cost = -1,
        acquisition = "birth",
        requirements = {},
        conflicts = {"strong_build"},
        synergies = {},
        effects = {sanity = -1}
    })

    self:addTrait({
        id = "poor_vision",
        name = "Poor Vision",
        description = "-1 Aim stat",
        type = "negative",
        category = "combat",
        balance_cost = -1,
        acquisition = "birth",
        requirements = {},
        conflicts = {"sharp_eyes"},
        synergies = {},
        effects = {aim = -1}
    })

    self:addTrait({
        id = "clumsy",
        name = "Clumsy",
        description = "-1 accuracy",
        type = "negative",
        category = "physical",
        balance_cost = -1,
        acquisition = "birth",
        requirements = {},
        conflicts = {},
        synergies = {},
        effects = {accuracy_penalty = 1}
    })

    self:addTrait({
        id = "hemophobic",
        name = "Hemophobic",
        description = "-2 morale if bleeding",
        type = "negative",
        category = "mental",
        balance_cost = -2,
        acquisition = "birth",
        requirements = {},
        conflicts = {"natural_medic"},
        synergies = {},
        effects = {morale_penalty_bleeding = 2}
    })

    self:addTrait({
        id = "loner",
        name = "Loner",
        description = "-1 squad cohesion",
        type = "negative",
        category = "mental",
        balance_cost = -1,
        acquisition = "birth",
        requirements = {},
        conflicts = {"natural_leader"},
        synergies = {},
        effects = {squad_cohesion = -1}
    })

    self:addTrait({
        id = "slow_reflexes",
        name = "Slow Reflexes",
        description = "-1 Reaction stat",
        type = "negative",
        category = "combat",
        balance_cost = -1,
        acquisition = "birth",
        requirements = {},
        conflicts = {"quick_reflexes"},
        synergies = {},
        effects = {reaction = -1}
    })

    -- Injury Traits (Permanent)
    self:addTrait({
        id = "disabled",
        name = "Disabled",
        description = "-2 Speed, mobility penalty",
        type = "negative",
        category = "physical",
        balance_cost = -2,
        acquisition = "injury",
        requirements = {},
        conflicts = {"marathon_runner"},
        synergies = {},
        effects = {speed = -2, mobility_penalty = true}
    })

    self:addTrait({
        id = "scarred",
        name = "Scarred",
        description = "-1 Bravery stat",
        type = "negative",
        category = "mental",
        balance_cost = -1,
        acquisition = "injury",
        requirements = {},
        conflicts = {},
        synergies = {},
        effects = {bravery = -1}
    })

    -- Rare/Legendary Traits
    self:addTrait({
        id = "unscarred",
        name = "Unscarred",
        description = "+1 XP per mission",
        type = "positive",
        category = "mental",
        balance_cost = 1,
        acquisition = "achievement",
        requirements = {missions_completed = 100, never_injured = true},
        conflicts = {},
        synergies = {},
        effects = {xp_per_mission = 1}
    })

    self:addTrait({
        id = "war_hero",
        name = "War Hero",
        description = "+2 to all stats",
        type = "positive",
        category = "combat",
        balance_cost = 4,
        acquisition = "achievement",
        requirements = {total_kills = 1000, rank_min = 8},
        conflicts = {},
        synergies = {},
        effects = {aim = 2, melee = 2, reaction = 2, speed = 2, bravery = 2, sanity = 2, strength = 2}
    })
end

-- Add a trait definition
function TraitSystem:addTrait(traitDef)
    self.traits[traitDef.id] = traitDef
end

-- Get trait by ID
function TraitSystem:getTrait(traitId)
    return self.traits[traitId]
end

-- Get all traits
function TraitSystem:getAllTraits()
    return self.traits
end

-- Get traits by category
function TraitSystem:getTraitsByCategory(category)
    local categoryTraits = {}
    for id, trait in pairs(self.traits) do
        if trait.category == category then
            categoryTraits[id] = trait
        end
    end
    return categoryTraits
end

-- Get traits by type
function TraitSystem:getTraitsByType(traitType)
    local typeTraits = {}
    for id, trait in pairs(self.traits) do
        if trait.type == traitType then
            typeTraits[id] = trait
        end
    end
    return typeTraits
end

-- Get traits by acquisition method
function TraitSystem:getTraitsByAcquisition(method)
    local methodTraits = {}
    for id, trait in pairs(self.traits) do
        if trait.acquisition == method then
            methodTraits[id] = trait
        end
    end
    return methodTraits
end

-- Check if unit meets trait requirements
function TraitSystem:meetsRequirements(unit, traitId)
    local trait = self:getTrait(traitId)
    if not trait then return false end

    for req, value in pairs(trait.requirements) do
        if req == "rank" and unit.rank < value then
            return false
        elseif req == "rank_min" and unit.rank < value then
            return false
        elseif req == "kills_with_rifle" and (unit.stats.kills_with_rifle or 0) < value then
            return false
        elseif req == "melee_kills" and (unit.stats.melee_kills or 0) < value then
            return false
        elseif req == "missions_completed" and (unit.stats.missions_completed or 0) < value then
            return false
        elseif req == "damage_healed" and (unit.stats.damage_healed or 0) < value then
            return false
        elseif req == "equipment_repaired" and (unit.stats.equipment_repaired or 0) < value then
            return false
        elseif req == "total_kills" and (unit.stats.total_kills or 0) < value then
            return false
        elseif req == "never_injured" and unit.stats.times_injured > 0 then
            return false
        end
    end

    return true
end

-- Apply trait effects to unit
function TraitSystem:applyTraitEffects(unit, traitId)
    local trait = self:getTrait(traitId)
    if not trait then return end

    -- Initialize trait bonuses if not exists
    unit.trait_bonuses = unit.trait_bonuses or {}

    -- Apply stat modifiers
    for stat, modifier in pairs(trait.effects) do
        if stat == "reaction" or stat == "aim" or stat == "melee" or stat == "speed" or stat == "bravery" or stat == "sanity" or stat == "strength" then
            unit.trait_bonuses[stat] = (unit.trait_bonuses[stat] or 0) + modifier
            -- Cap bonuses at +3 per stat
            if unit.trait_bonuses[stat] > 3 then
                unit.trait_bonuses[stat] = 3
            end
        elseif stat == "health" then
            unit.trait_bonuses.health = (unit.trait_bonuses.health or 0) + modifier
        elseif stat == "accuracy_bonus" then
            unit.trait_bonuses.accuracy_percent = (unit.trait_bonuses.accuracy_percent or 0) + modifier
        elseif stat == "weapon_accuracy" then
            unit.trait_bonuses.weapon_accuracy = (unit.trait_bonuses.weapon_accuracy or 0) + modifier
        elseif stat == "melee_damage" then
            unit.trait_bonuses.melee_damage = (unit.trait_bonuses.melee_damage or 0) + modifier
        elseif stat == "nearby_morale" then
            unit.trait_bonuses.nearby_morale = (unit.trait_bonuses.nearby_morale or 0) + modifier
        elseif stat == "healing_per_bandage" then
            unit.trait_bonuses.healing_per_bandage = (unit.trait_bonuses.healing_per_bandage or 0) + modifier
        elseif stat == "recovery_speed_bonus" then
            unit.trait_bonuses.recovery_speed_percent = (unit.trait_bonuses.recovery_speed_percent or 0) + modifier
        elseif stat == "ammo_per_clip" then
            unit.trait_bonuses.ammo_per_clip = (unit.trait_bonuses.ammo_per_clip or 0) + modifier
        elseif stat == "xp_per_mission" then
            unit.trait_bonuses.xp_per_mission = (unit.trait_bonuses.xp_per_mission or 0) + modifier
        elseif stat == "panic_reduction" then
            unit.trait_bonuses.panic_reduction = (unit.trait_bonuses.panic_reduction or 0) + modifier
        elseif stat == "morale_penalty_bleeding" then
            unit.trait_bonuses.morale_penalty_bleeding = (unit.trait_bonuses.morale_penalty_bleeding or 0) + modifier
        elseif stat == "squad_cohesion" then
            unit.trait_bonuses.squad_cohesion = (unit.trait_bonuses.squad_cohesion or 0) + modifier
        elseif stat == "accuracy_penalty" then
            unit.trait_bonuses.accuracy_penalty = (unit.trait_bonuses.accuracy_penalty or 0) + modifier
        elseif stat == "suppression_immunity" then
            unit.trait_bonuses.suppression_immunity = true
        elseif stat == "can_repair_equipment" then
            unit.trait_bonuses.can_repair_equipment = true
        elseif stat == "mobility_penalty" then
            unit.trait_bonuses.mobility_penalty = true
        end
    end
end

-- Remove trait effects from unit
function TraitSystem:removeTraitEffects(unit, traitId)
    local trait = self:getTrait(traitId)
    if not trait then return end

    -- Remove stat modifiers
    for stat, modifier in pairs(trait.effects) do
        if unit.trait_bonuses and unit.trait_bonuses[stat] then
            unit.trait_bonuses[stat] = unit.trait_bonuses[stat] - modifier
        end
    end
end

-- Calculate synergy bonuses
function TraitSystem:calculateSynergyBonuses(unit)
    local bonuses = {}

    -- Marksman + Steady Hand synergy
    if self:hasTrait(unit, "marksman") and self:hasTrait(unit, "steady_hand") then
        bonuses.accuracy_percent = (bonuses.accuracy_percent or 0) + 3
    end

    -- Natural Medic + Healer synergy
    if self:hasTrait(unit, "natural_medic") and self:hasTrait(unit, "healer") then
        bonuses.healing_per_bandage = (bonuses.healing_per_bandage or 0) + 1
    end

    -- Leader + Commanding Officer synergy
    if self:hasTrait(unit, "natural_leader") and self:hasTrait(unit, "commanding_officer") then
        bonuses.nearby_morale = (bonuses.nearby_morale or 0) + 2
    end

    -- Marathon Runner + Scout synergy (assuming scout trait exists)
    if self:hasTrait(unit, "marathon_runner") and self:hasTrait(unit, "scout") then
        bonuses.speed = (bonuses.speed or 0) + 1
    end

    -- Quick Reflexes + Gymnast synergy (assuming gymnast trait exists)
    if self:hasTrait(unit, "quick_reflexes") and self:hasTrait(unit, "gymnast") then
        bonuses.dodge_chance = (bonuses.dodge_chance or 0) + 2
    end

    return bonuses
end

-- Apply synergy bonuses to unit
function TraitSystem:applySynergyBonuses(unit)
    local synergies = self:calculateSynergyBonuses(unit)

    unit.synergy_bonuses = synergies

    -- Apply synergy bonuses to trait_bonuses
    for stat, bonus in pairs(synergies) do
        unit.trait_bonuses[stat] = (unit.trait_bonuses[stat] or 0) + bonus
    end
end

-- Check if unit has a specific trait
function TraitSystem:hasTrait(unit, traitId)
    if not unit.traits then return false end

    for _, trait in ipairs(unit.traits) do
        if trait.id == traitId then
            return true
        end
    end

    return false
end

-- Get trait slots available for unit rank
function TraitSystem:getTraitSlotsForRank(rank)
    if rank <= 3 then
        return 2  -- Birth traits only
    elseif rank <= 5 then
        return 3  -- Birth + 1 achievement
    elseif rank <= 7 then
        return 4  -- Birth + 2 achievements
    else
        return 5  -- Birth + 3 achievements + 1 perk
    end
end

-- Get total balance cost of unit's traits
function TraitSystem:getTotalBalanceCost(unit)
    local total = 0

    if unit.traits then
        for _, trait in ipairs(unit.traits) do
            total = total + trait.balance_cost
        end
    end

    return total
end

return TraitSystem
