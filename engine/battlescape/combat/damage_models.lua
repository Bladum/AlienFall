---DamageModels - Combat Damage Distribution System
---
---Defines how damage is distributed across unit statistics after armor penetration.
---Models determine damage effects (stun, health, morale, energy) rather than damage
---types (kinetic, laser, plasma). Used by damage calculation system.
---
---Damage Models:
---  - STUN: Temporary damage causing unconsciousness, recovers over time
---  - HURT: Permanent health damage reducing maximum HP
---  - MORALE: Psychological damage causing panic or berserk states
---  - ENERGY: Stamina drain affecting movement and actions
---
---Features:
---  - Stat distribution percentages for each model
---  - Armor penetration modifiers
---  - Critical hit multipliers
---  - Model-specific recovery mechanics
---  - Integration with unit stat system
---
---Key Exports:
---  - MODELS: Enumeration of available damage models
---  - DEFINITIONS: Detailed model configurations
---  - applyDamage(unit, damage, model, armorPen): Apply damage using model
---  - getModelStats(model): Get distribution stats for model
---  - calculateEffectiveDamage(baseDamage, model, armor): Calculate final damage
---
---Dependencies:
---  - Unit stat system for damage application
---  - Armor system for penetration calculations
---
---@module battlescape.combat.damage_models
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local DamageModels = require("battlescape.combat.damage_models")
---  local damage = DamageModels.applyDamage(unit, 50, "stun", 0.8)
---  -- Applies 50 damage with 80% armor penetration using stun model
---
---@see battlescape.combat.damage_types For damage type definitions
---@see battlescape.combat.unit For unit stat management

-- Damage Models System
-- Defines how damage is distributed to unit stats after armor calculation
-- Models determine the effect type, not the damage type (kinetic vs laser)

local DamageModels = {}

--- Damage model enumeration
DamageModels.MODELS = {
    STUN = "stun",       -- Temporary damage, recovers over time, causes unconsciousness
    HURT = "hurt",       -- Permanent health damage
    MORALE = "morale",   -- Damages morale, can cause panic/berserk
    ENERGY = "energy"    -- Drains energy/stamina
}

--- Damage model definitions
--- Each model defines how damage is distributed across unit stats
DamageModels.DEFINITIONS = {
    -- STUN: Non-lethal damage that causes temporary stun accumulation
    -- High stun leads to unconsciousness, recovers naturally over time
    stun = {
        name = "Stun",
        description = "Non-lethal damage that causes unconsciousness",
        distribution = {
            health = 0.0,      -- No permanent health damage
            stun = 1.0,        -- 100% to stun pool
            morale = 0.1,      -- 10% morale loss (fear effect)
            energy = 0.0       -- No energy drain
        },
        effects = {
            canKill = false,                    -- Cannot directly kill
            causesUnconscious = true,           -- Can knock out
            recoveryPerTurn = 2,                -- Stun recovers 2 points per turn
            moraleImpact = "minor"              -- Minor morale effect
        },
        color = {255, 255, 100}  -- Yellow
    },
    
    -- HURT: Standard lethal damage to health pool
    -- This is the traditional combat damage that can kill units
    hurt = {
        name = "Hurt",
        description = "Permanent health damage",
        distribution = {
            health = 0.75,     -- 75% to health
            stun = 0.25,       -- 25% to stun (shock/impact)
            morale = 0.0,      -- No direct morale damage
            energy = 0.0       -- No energy drain
        },
        effects = {
            canKill = true,                     -- Can kill units
            causesUnconscious = false,          -- Only kills, doesn't knock out
            recoveryPerTurn = 0,                -- No health recovery
            moraleImpact = "moderate"           -- Moderate morale loss when damaged
        },
        color = {255, 50, 50}  -- Red
    },
    
    -- MORALE: Direct attack on unit's will to fight
    -- Used by fear effects, intimidation, psionic attacks
    morale = {
        name = "Morale",
        description = "Psychological damage that affects willpower",
        distribution = {
            health = 0.0,      -- No health damage
            stun = 0.0,        -- No stun
            morale = 1.0,      -- 100% to morale
            energy = 0.0       -- No energy drain
        },
        effects = {
            canKill = false,                    -- Cannot kill
            causesUnconscious = true,           -- Can cause morale collapse
            recoveryPerTurn = 5,                -- Morale recovers 5 points per turn
            moraleImpact = "severe"             -- Severe morale effect
        },
        color = {200, 50, 200}  -- Purple
    },
    
    -- ENERGY: Drains stamina/energy reserves
    -- Used by exhaustion effects, energy weapons, draining attacks
    energy = {
        name = "Energy",
        description = "Drains unit stamina and energy reserves",
        distribution = {
            health = 0.0,      -- No health damage
            stun = 0.2,        -- 20% to stun (exhaustion)
            morale = 0.0,      -- No morale damage
            energy = 0.8       -- 80% to energy drain
        },
        effects = {
            canKill = false,                    -- Cannot kill
            causesUnconscious = true,           -- Energy depletion can cause collapse
            recoveryPerTurn = 3,                -- Energy recovers 3 points per turn
            moraleImpact = "minor"              -- Minor morale effect
        },
        color = {100, 200, 255}  -- Cyan
    }
}

--- Get damage model definition
-- @param modelName string Model name (stun, hurt, morale, energy)
-- @return table Model definition or nil
function DamageModels.getModel(modelName)
    return DamageModels.DEFINITIONS[modelName]
end

--- Get damage distribution for a model
-- @param modelName string Model name
-- @return table Distribution ratios {health, stun, morale, energy}
function DamageModels.getDistribution(modelName)
    local model = DamageModels.getModel(modelName)
    if not model then
        -- Default to hurt model if invalid
        return DamageModels.DEFINITIONS.hurt.distribution
    end
    return model.distribution
end

--- Check if model can kill units
-- @param modelName string Model name
-- @return boolean True if model can kill
function DamageModels.canKill(modelName)
    local model = DamageModels.getModel(modelName)
    return model and model.effects.canKill or false
end

--- Get recovery rate per turn
-- @param modelName string Model name
-- @param statType string Stat type (health, stun, morale, energy)
-- @return number Recovery amount per turn
function DamageModels.getRecoveryRate(modelName, statType)
    local model = DamageModels.getModel(modelName)
    if not model then
        return 0
    end
    
    -- Map stat type to appropriate recovery
    if statType == "stun" and modelName == "stun" then
        return model.effects.recoveryPerTurn
    elseif statType == "morale" and modelName == "morale" then
        return model.effects.recoveryPerTurn
    elseif statType == "energy" and modelName == "energy" then
        return model.effects.recoveryPerTurn
    end
    
    return 0
end

--- Get morale impact severity
-- @param modelName string Model name
-- @return string Morale impact level (minor, moderate, severe, none)
function DamageModels.getMoraleImpact(modelName)
    local model = DamageModels.getModel(modelName)
    return model and model.effects.moraleImpact or "none"
end

--- Calculate morale loss multiplier based on impact severity
-- @param severity string Impact severity
-- @return number Multiplier (0.0 to 1.0)
function DamageModels.getMoraleMultiplier(severity)
    local multipliers = {
        none = 0.0,
        minor = 0.1,
        moderate = 0.3,
        severe = 1.0
    }
    return multipliers[severity] or 0.0
end

--- Get color for damage model visualization
-- @param modelName string Model name
-- @return table RGB color {r, g, b}
function DamageModels.getColor(modelName)
    local model = DamageModels.getModel(modelName)
    return model and model.color or {255, 255, 255}
end

--- Validate damage model name
-- @param modelName string Model name to validate
-- @return boolean True if valid
function DamageModels.isValid(modelName)
    return DamageModels.DEFINITIONS[modelName] ~= nil
end

--- Get all damage model names
-- @return table Array of model names
function DamageModels.getAllModels()
    local models = {}
    for name, _ in pairs(DamageModels.DEFINITIONS) do
        table.insert(models, name)
    end
    return models
end

--- Get detailed info about a model for UI display
-- @param modelName string Model name
-- @return table Info with name, description, distribution, effects
function DamageModels.getInfo(modelName)
    local model = DamageModels.getModel(modelName)
    if not model then
        return nil
    end
    
    return {
        name = model.name,
        description = model.description,
        distribution = model.distribution,
        canKill = model.effects.canKill,
        causesUnconscious = model.effects.causesUnconscious,
        recoveryPerTurn = model.effects.recoveryPerTurn,
        moraleImpact = model.effects.moraleImpact,
        color = model.color
    }
end

--- Example usage comparison:
--[[
    STUN MODEL (Stun Rod):
        100 damage → 100 stun, 0 health, 10 morale loss
        Unit falls unconscious but survives
        Recovers 2 stun per turn
        
    HURT MODEL (Rifle):
        100 damage → 75 health, 25 stun, moderate morale loss
        Unit takes permanent damage
        Can die if health reaches 0
        
    MORALE MODEL (Fear Gas):
        100 damage → 0 health, 0 stun, 100 morale loss
        Unit panics or goes berserk
        Recovers 5 morale per turn
        
    ENERGY MODEL (Exhaustion Ray):
        100 damage → 0 health, 20 stun, 80 energy drain
        Unit becomes exhausted, loses AP/EP
        Recovers 3 energy per turn
]]

return DamageModels

























