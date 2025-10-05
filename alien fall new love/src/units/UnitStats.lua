--- UnitStats.lua
-- Unit stats calculation system for Alien Fall
-- Handles stat modifiers, calculations, and derived values

-- GROK: UnitStats manages stat calculations with modifiers from equipment, traits, and class
-- GROK: Used by unit_system for combat calculations, UI display, and stat validation
-- GROK: Key methods: calculateEffectiveStats(), applyModifiers(), getDerivedValues()
-- GROK: Handles stat ranges, modifiers stacking, and derived stat calculations

local class = require 'lib.Middleclass'

UnitStats = class('UnitStats')

--- Initialize a new unit stats calculator
function UnitStats:initialize()
    -- No initialization needed - this is a utility class
end

--- Calculate effective stats for a unit
-- @param unit The unit to calculate stats for
-- @param context Optional context (equipment, traits, etc.)
-- @return Table of effective stats
function UnitStats.calculateEffectiveStats(unit, context)
    context = context or {}

    local effective = {}

    -- Start with base stats
    for stat, value in pairs(unit.stats) do
        effective[stat] = value
    end

    -- Apply class bonuses
    if unit.class_id and context.class_data then
        local class_bonuses = context.class_data:calculateStatBonuses(unit.rank)
        for stat, bonus in pairs(class_bonuses) do
            effective[stat] = (effective[stat] or 0) + bonus
        end
    end

    -- Apply trait modifiers
    if unit.traits and context.trait_data then
        for _, trait_id in ipairs(unit.traits) do
            local trait = context.trait_data[trait_id]
            if trait then
                local modifiers = trait:getStatModifiers()
                for stat, modifier in pairs(modifiers) do
                    if type(modifier) == "number" then
                        effective[stat] = (effective[stat] or 0) + modifier
                    end
                end
            end
        end
    end

    -- Apply equipment modifiers
    if unit.equipment and context.equipment_data then
        for slot, item_id in pairs(unit.equipment) do
            if item_id and context.equipment_data[item_id] then
                local item = context.equipment_data[item_id]
                if item.stat_modifiers then
                    for stat, modifier in pairs(item.stat_modifiers) do
                        effective[stat] = (effective[stat] or 0) + modifier
                    end
                end
            end
        end
    end

    -- Apply medal bonuses
    if unit.medals and context.medal_data then
        for _, medal_record in ipairs(unit.medals) do
            local medal = context.medal_data[medal_record.id]
            if medal then
                local bonuses = medal:getStatBonuses()
                for stat, bonus in pairs(bonuses) do
                    effective[stat] = (effective[stat] or 0) + bonus
                end
            end
        end
    end

    -- Apply status effects (wounds, fatigue, etc.)
    effective = UnitStats.applyStatusEffects(effective, unit)

    -- Clamp stats to valid ranges
    effective = UnitStats.clampStats(effective)

    return effective
end

--- Apply status effect modifiers
-- @param stats The stats table to modify
-- @param unit The unit with status information
-- @return Modified stats table
function UnitStats.applyStatusEffects(stats, unit)
    local modified = {}
    for stat, value in pairs(stats) do
        modified[stat] = value
    end

    -- Wounded penalty
    if unit:isWounded() then
        modified.accuracy = math.floor(modified.accuracy * 0.8)
        modified.reflexes = math.floor(modified.reflexes * 0.9)
        modified.strength = math.floor(modified.strength * 0.85)
    end

    -- Fatigued penalty
    if unit:isFatigued() then
        modified.accuracy = math.floor(modified.accuracy * 0.9)
        modified.reflexes = math.floor(modified.reflexes * 0.8)
        modified.mind = math.floor(modified.mind * 0.9)
    end

    -- Low morale penalty
    if unit:hasLowMorale() then
        modified.accuracy = math.floor(modified.accuracy * 0.85)
        modified.mind = math.floor(modified.mind * 0.9)
    end

    -- Low sanity penalty
    if unit.current_sanity < 50 then
        modified.psi = math.floor(modified.psi * 0.7)
        modified.mind = math.floor(modified.mind * 0.8)
    end

    return modified
end

--- Clamp stats to valid ranges
-- @param stats The stats table to clamp
-- @return Clamped stats table
function UnitStats.clampStats(stats)
    local clamped = {}
    local ranges = {
        health = {min = 1, max = 200},
        stamina = {min = 1, max = 200},
        accuracy = {min = 1, max = 100},
        reflexes = {min = 1, max = 100},
        strength = {min = 1, max = 100},
        mind = {min = 1, max = 100},
        morale = {min = 0, max = 100},
        sanity = {min = 0, max = 100},
        psi = {min = 0, max = 100},
        sight = {min = 1, max = 50},
        sense = {min = 0, max = 50},
        cover = {min = 0, max = 100},
        size = {min = 0.5, max = 3.0},
        armor = {min = 0, max = 50}
    }

    for stat, value in pairs(stats) do
        local range = ranges[stat]
        if range then
            clamped[stat] = math.max(range.min, math.min(range.max, value))
        else
            clamped[stat] = value
        end
    end

    return clamped
end

--- Calculate derived values from stats
-- @param stats The effective stats
-- @return Table of derived values
function UnitStats.calculateDerivedValues(stats)
    local derived = {}

    -- Combat effectiveness
    derived.hit_chance_modifier = stats.accuracy / 50.0 -- Base 50 = 1.0 modifier
    derived.damage_modifier = stats.strength / 50.0
    derived.evasion_modifier = stats.reflexes / 50.0

    -- Movement and action
    derived.movement_speed = 4 + (stats.stamina / 50) -- Base 4 tiles + stamina bonus
    derived.action_efficiency = stats.mind / 50.0 -- Mental focus affects AP efficiency

    -- Perception
    derived.detection_range = stats.sight
    derived.passive_detection = stats.sense / 2 -- Sense contributes to passive detection
    derived.stealth_modifier = stats.cover / 100.0 -- Cover affects stealth

    -- Resilience
    derived.wound_threshold = stats.health * 0.25 -- Quarter health for wound status
    derived.fatigue_threshold = stats.stamina * 0.2 -- 20% stamina for fatigue
    derived.morale_breakpoint = 30 -- Fixed morale breakpoint
    derived.sanity_breakpoint = 25 -- Fixed sanity breakpoint

    -- Special abilities
    derived.psi_power = stats.psi / 50.0 -- Psi effectiveness modifier
    derived.leadership_radius = math.floor(stats.mind / 20) + 1 -- Tiles of leadership influence

    return derived
end

--- Calculate combat modifiers between attacker and defender
-- @param attacker_stats Attacker's effective stats
-- @param defender_stats Defender's effective stats
-- @param combat_context Table with combat context (range, cover, etc.)
-- @return Table of combat modifiers
function UnitStats.calculateCombatModifiers(attacker_stats, defender_stats, combat_context)
    local modifiers = {
        hit_chance = 0,
        damage = 0,
        evasion = 0,
        critical_chance = 0
    }

    -- Range modifiers
    local range = combat_context.range or 1
    if range > attacker_stats.sight then
        modifiers.hit_chance = modifiers.hit_chance - 30 -- Long range penalty
    elseif range <= 3 then
        modifiers.hit_chance = modifiers.hit_chance + 10 -- Close range bonus
    end

    -- Cover modifiers
    local cover = combat_context.cover or 0
    modifiers.hit_chance = modifiers.hit_chance - cover
    modifiers.evasion = modifiers.evasion + (cover / 2)

    -- Accuracy vs Reflexes
    local accuracy_diff = attacker_stats.accuracy - defender_stats.reflexes
    modifiers.hit_chance = modifiers.hit_chance + (accuracy_diff / 2)

    -- Strength vs Armor
    local armor_diff = attacker_stats.strength - defender_stats.armor
    if armor_diff > 0 then
        modifiers.damage = modifiers.damage + (armor_diff / 5)
    else
        modifiers.damage = modifiers.damage + armor_diff -- Penalty for low strength
    end

    -- Critical chance based on mind difference
    local mind_diff = attacker_stats.mind - defender_stats.mind
    modifiers.critical_chance = modifiers.critical_chance + (mind_diff / 10)

    -- Status effect modifiers
    if combat_context.attacker_wounded then
        modifiers.hit_chance = modifiers.hit_chance - 15
        modifiers.damage = modifiers.damage - 10
    end

    if combat_context.defender_wounded then
        modifiers.evasion = modifiers.evasion - 10
    end

    return modifiers
end

--- Calculate movement cost
-- @param unit_stats Unit's effective stats
-- @param terrain_type Terrain type
-- @param terrain_data Table with terrain movement costs
-- @return Movement cost in AP
function UnitStats.calculateMovementCost(unit_stats, terrain_type, terrain_data)
    local base_cost = terrain_data[terrain_type] or 1

    -- Apply stamina modifier (higher stamina = lower cost)
    local stamina_modifier = 1 - (unit_stats.stamina - 50) / 100 -- ±0.5 modifier
    local cost = base_cost * stamina_modifier

    -- Apply strength modifier for heavy terrain
    if terrain_type == "rough" or terrain_type == "woods" then
        local strength_modifier = 1 - (unit_stats.strength - 50) / 200 -- ±0.25 modifier
        cost = cost * strength_modifier
    end

    -- Minimum cost of 1
    return math.max(1, math.floor(cost + 0.5))
end

--- Calculate action point recovery
-- @param unit_stats Unit's effective stats
-- @param time_units Time units passed
-- @return AP recovered
function UnitStats.calculateActionPointRecovery(unit_stats, time_units)
    -- Base recovery per time unit
    local base_recovery = 5

    -- Mind affects AP recovery efficiency
    local mind_modifier = unit_stats.mind / 50.0 -- Base 50 = 1.0
    local recovery = base_recovery * mind_modifier * time_units

    return math.floor(recovery + 0.5)
end

--- Calculate energy recovery
-- @param unit_stats Unit's effective stats
-- @param time_units Time units passed
-- @return Energy recovered
function UnitStats.calculateEnergyRecovery(unit_stats, time_units)
    -- Base recovery per time unit
    local base_recovery = 10

    -- Morale affects energy recovery
    local morale_modifier = unit_stats.morale / 50.0 -- Base 50 = 1.0
    local recovery = base_recovery * morale_modifier * time_units

    return math.floor(recovery + 0.5)
end

--- Validate stat values
-- @param stats Table of stats to validate
-- @return true if valid, false and error message if invalid
function UnitStats.validateStats(stats)
    local required_stats = {
        "health", "stamina", "accuracy", "reflexes",
        "strength", "mind", "morale", "sanity"
    }

    for _, stat in ipairs(required_stats) do
        if not stats[stat] then
            return false, string.format("Missing required stat: %s", stat)
        end
        if type(stats[stat]) ~= "number" then
            return false, string.format("Stat %s must be a number", stat)
        end
        if stats[stat] < 0 then
            return false, string.format("Stat %s cannot be negative", stat)
        end
    end

    return true
end

--- Get stat display information
-- @param stat_name The stat name
-- @return Table with display info (name, description, icon, etc.)
function UnitStats.getStatDisplayInfo(stat_name)
    local display_info = {
        health = {
            name = "Health",
            short_name = "HP",
            description = "Physical vitality and resistance to damage",
            icon = "health_icon",
            color = {255, 100, 100}
        },
        stamina = {
            name = "Stamina",
            short_name = "STA",
            description = "Physical endurance and movement efficiency",
            icon = "stamina_icon",
            color = {100, 255, 100}
        },
        accuracy = {
            name = "Accuracy",
            short_name = "ACC",
            description = "Precision with ranged weapons and attacks",
            icon = "accuracy_icon",
            color = {255, 255, 100}
        },
        reflexes = {
            name = "Reflexes",
            short_name = "REF",
            description = "Reaction speed and evasion ability",
            icon = "reflexes_icon",
            color = {100, 255, 255}
        },
        strength = {
            name = "Strength",
            short_name = "STR",
            description = "Physical power and carrying capacity",
            icon = "strength_icon",
            color = {255, 150, 100}
        },
        mind = {
            name = "Mind",
            short_name = "MND",
            description = "Mental acuity and willpower",
            icon = "mind_icon",
            color = {150, 100, 255}
        },
        morale = {
            name = "Morale",
            short_name = "MOR",
            description = "Psychological state and combat willingness",
            icon = "morale_icon",
            color = {255, 100, 255}
        },
        sanity = {
            name = "Sanity",
            short_name = "SAN",
            description = "Mental stability and resistance to trauma",
            icon = "sanity_icon",
            color = {100, 100, 255}
        },
        psi = {
            name = "Psi",
            short_name = "PSI",
            description = "Psionic power and mental abilities",
            icon = "psi_icon",
            color = {255, 100, 150}
        }
    }

    return display_info[stat_name] or {
        name = stat_name,
        short_name = string.upper(stat_name:sub(1, 3)),
        description = "Unknown stat",
        icon = "unknown_icon",
        color = {128, 128, 128}
    }
end

return UnitStats
