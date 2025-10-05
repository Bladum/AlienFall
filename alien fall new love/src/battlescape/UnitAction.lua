--- Unit Action
-- Defines actions that units can perform in battlescape
--
-- @classmod battlescape.UnitAction

-- GROK: UnitAction defines all possible unit actions with costs, requirements, and effects
-- GROK: Supports movement, combat, defensive, and utility actions with deterministic resolution
-- GROK: Key properties: cost, requirements, effects, validation logic
-- GROK: Used by ActionSystem for action validation and execution

local class = require 'lib.Middleclass'

--- UnitAction class
-- @type UnitAction
UnitAction = class('UnitAction')

--- Action types
-- @field MOVE Movement action
-- @field SHOOT Shooting action
-- @field OVERWATCH Overwatch action
-- @field RELOAD Reload action
-- @field COVER Take cover action
-- @field CROUCH Crouch action
-- @field STAND Stand action
-- @field ROTATE Rotate action
-- @field THROW Throw item action
-- @field USE_ITEM Use item action
-- @field REST Rest action
-- @field END_TURN End turn action
UnitAction.static.TYPES = {
    MOVE = "move",
    SHOOT = "shoot",
    OVERWATCH = "overwatch",
    RELOAD = "reload",
    COVER = "cover",
    CROUCH = "crouch",
    STAND = "stand",
    ROTATE = "rotate",
    THROW = "throw",
    USE_ITEM = "use_item",
    REST = "rest",
    END_TURN = "end_turn"
}

--- Create a new UnitAction instance
-- @param actionType Type of action
-- @param config Action configuration
-- @return UnitAction instance
function UnitAction:initialize(actionType, config)
    self.type = actionType
    self.name = config.name or actionType
    self.description = config.description or ""
    self.apCost = config.apCost or 0
    self.energyCost = config.energyCost or 0
    self.cooldown = config.cooldown or 0
    self.range = config.range or 0
    self.areaOfEffect = config.areaOfEffect or 1
    self.requirements = config.requirements or {}
    self.effects = config.effects or {}
    self.animation = config.animation
    self.sound = config.sound
    self.icon = config.icon

    -- Action-specific properties
    self:initializeActionSpecific(config)
end

--- Initialize action-specific properties
-- @param config Action configuration
function UnitAction:initializeActionSpecific(config)
    if self.type == self.TYPES.MOVE then
        self.maxDistance = config.maxDistance or 10
        self.terrainCosts = config.terrainCosts or {}
        self.diagonalCost = config.diagonalCost or 1.414

    elseif self.type == self.TYPES.SHOOT then
        self.weaponRequired = true
        self.ammoRequired = config.ammoRequired or 1
        self.accuracyModifier = config.accuracyModifier or 0
        self.damageModifier = config.damageModifier or 0

    elseif self.type == self.TYPES.OVERWATCH then
        self.duration = config.duration or 1 -- Turns
        self.reactionRange = config.reactionRange or 10

    elseif self.type == self.TYPES.THROW then
        self.throwRange = config.throwRange or 5
        self.throwAccuracy = config.throwAccuracy or 60

    elseif self.type == self.TYPES.USE_ITEM then
        self.itemRequired = config.itemRequired
        self.consumesItem = config.consumesItem ~= false
    end
end

--- Get action type
-- @return string Action type
function UnitAction:getType()
    return self.type
end

--- Get action name
-- @return string Action name
function UnitAction:getName()
    return self.name
end

--- Get action description
-- @return string Action description
function UnitAction:getDescription()
    return self.description
end

--- Get AP cost
-- @param unit Unit performing action (for modifiers)
-- @param context Action context
-- @return number AP cost
function UnitAction:getAPCost(unit, context)
    local cost = self.apCost

    -- Apply unit modifiers
    if unit then
        cost = cost * unit:getActionCostModifier(self.type)
    end

    -- Apply context modifiers
    if context then
        if context.terrain then
            cost = cost * (self.terrainCosts[context.terrain] or 1.0)
        end

        if context.distance and self.type == self.TYPES.MOVE then
            -- Movement cost scales with distance
            cost = cost * context.distance
        end
    end

    return math.ceil(cost)
end

--- Get energy cost
-- @param unit Unit performing action
-- @param context Action context
-- @return number Energy cost
function UnitAction:getEnergyCost(unit, context)
    local cost = self.energyCost

    -- Apply unit modifiers
    if unit then
        cost = cost * unit:getEnergyCostModifier(self.type)
    end

    return math.ceil(cost)
end

--- Check if action can be performed by unit
-- @param unit Unit attempting action
-- @param context Action context
-- @return boolean canPerform, string errorMessage
function UnitAction:canPerform(unit, context)
    -- Check basic requirements
    for _, requirement in ipairs(self.requirements) do
        if not self:checkRequirement(unit, requirement, context) then
            return false, requirement.description or "Requirement not met"
        end
    end

    -- Check action-specific requirements
    return self:canPerformSpecific(unit, context)
end

--- Check specific requirement
-- @param unit Unit
-- @param requirement Requirement data
-- @param context Action context
-- @return boolean Whether requirement is met
function UnitAction:checkRequirement(unit, requirement, context)
    local reqType = requirement.type

    if reqType == "has_weapon" then
        return unit:getWeapon() ~= nil

    elseif reqType == "has_ammo" then
        local required = requirement.amount or 1
        return unit:getAmmo() >= required

    elseif reqType == "has_item" then
        return unit:hasItem(requirement.itemType)

    elseif reqType == "not_suppressed" then
        return not unit:isSuppressed()

    elseif reqType == "not_panicked" then
        return unit:getMoraleState() ~= "panicked"

    elseif reqType == "has_ap" then
        return unit:getAP() >= self:getAPCost(unit, context)

    elseif reqType == "has_energy" then
        return unit:getEnergy() >= self:getEnergyCost(unit, context)

    elseif reqType == "in_range" then
        if context and context.target then
            local distance = unit:getDistanceTo(context.target)
            return distance <= self.range
        end
        return false

    elseif reqType == "line_of_sight" then
        if context and context.target then
            return unit:hasLineOfSightTo(context.target)
        end
        return false

    elseif reqType == "line_of_fire" then
        if context and context.target then
            return unit:hasLineOfFireTo(context.target)
        end
        return false
    end

    return true
end

--- Check action-specific requirements
-- @param unit Unit
-- @param context Action context
-- @return boolean canPerform, string errorMessage
function UnitAction:canPerformSpecific(unit, context)
    if self.type == self.TYPES.MOVE then
        if context and context.path then
            -- Check if path is valid
            return #context.path > 0, "No valid path"
        end

    elseif self.type == self.TYPES.SHOOT then
        if not unit:getWeapon() then
            return false, "No weapon equipped"
        end
        if unit:getAmmo() <= 0 then
            return false, "Out of ammunition"
        end

    elseif self.type == self.TYPES.OVERWATCH then
        if unit:isOnOverwatch() then
            return false, "Already on overwatch"
        end

    elseif self.type == self.TYPES.THROW then
        if not context or not context.item then
            return false, "No item to throw"
        end
        if not unit:hasItem(context.item) then
            return false, "Item not in inventory"
        end
    end

    return true
end

--- Execute the action
-- @param unit Unit performing action
-- @param context Action context
-- @return table Action results
function UnitAction:execute(unit, context)
    -- Apply costs
    unit:spendAP(self:getAPCost(unit, context))
    unit:spendEnergy(self:getEnergyCost(unit, context))

    -- Execute action-specific logic
    local results = self:executeSpecific(unit, context)

    -- Apply effects
    for _, effect in ipairs(self.effects) do
        self:applyEffect(unit, effect, context)
    end

    -- Set cooldown if applicable
    if self.cooldown > 0 then
        unit:setActionCooldown(self.type, self.cooldown)
    end

    return results
end

--- Execute action-specific logic
-- @param unit Unit
-- @param context Action context
-- @return table Results
function UnitAction:executeSpecific(unit, context)
    if self.type == self.TYPES.MOVE then
        if context and context.path then
            unit:setPosition(context.path[#context.path])
            return {moved = true, newPosition = unit:getPosition()}
        end

    elseif self.type == self.TYPES.SHOOT then
        if context and context.target then
            local hit, damage, effects = unit:attack(context.target)
            return {
                attacked = true,
                target = context.target,
                hit = hit,
                damage = damage,
                effects = effects
            }
        end

    elseif self.type == self.TYPES.OVERWATCH then
        unit:setOverwatch(true)
        return {overwatch = true}

    elseif self.type == self.TYPES.RELOAD then
        local ammoReloaded = unit:reload()
        return {reloaded = true, ammoReloaded = ammoReloaded}

    elseif self.type == self.TYPES.COVER then
        unit:setStance("cover")
        return {stance = "cover"}

    elseif self.type == self.TYPES.CROUCH then
        unit:setStance("crouch")
        return {stance = "crouch"}

    elseif self.type == self.TYPES.STAND then
        unit:setStance("stand")
        return {stance = "stand"}

    elseif self.type == self.TYPES.ROTATE then
        if context and context.direction then
            unit:setFacing(context.direction)
            return {rotated = true, facing = context.direction}
        end

    elseif self.type == self.TYPES.THROW then
        if context and context.target and context.item then
            local hit, effects = unit:throwItem(context.item, context.target)
            return {
                threw = true,
                item = context.item,
                target = context.target,
                hit = hit,
                effects = effects
            }
        end

    elseif self.type == self.TYPES.USE_ITEM then
        if context and context.item then
            local result = unit:useItem(context.item)
            if self.consumesItem then
                unit:removeItem(context.item)
            end
            return {usedItem = true, item = context.item, result = result}
        end

    elseif self.type == self.TYPES.REST then
        local energyRestored = unit:rest()
        return {rested = true, energyRestored = energyRestored}

    elseif self.type == self.TYPES.END_TURN then
        return {turnEnded = true}
    end

    return {executed = true}
end

--- Apply effect to unit
-- @param unit Unit
-- @param effect Effect data
-- @param context Action context
function UnitAction:applyEffect(unit, effect, context)
    local effectType = effect.type

    if effectType == "damage" then
        unit:takeDamage(effect.amount, effect.damageType)

    elseif effectType == "heal" then
        unit:heal(effect.amount)

    elseif effectType == "status" then
        unit:setStatusEffect(effect.status, true, effect.duration)

    elseif effectType == "morale" then
        if effect.amount > 0 then
            unit:boostMorale(effect.amount)
        else
            unit:reduceMorale(-effect.amount)
        end

    elseif effectType == "energy" then
        if effect.amount > 0 then
            unit:restoreEnergy(effect.amount)
        else
            unit:spendEnergy(-effect.amount)
        end

    elseif effectType == "suppression" then
        unit:addSuppression(effect.amount)
    end
end

--- Get action range
-- @return number Action range
function UnitAction:getRange()
    return self.range
end

--- Get area of effect
-- @return number Area of effect radius
function UnitAction:getAreaOfEffect()
    return self.areaOfEffect
end

--- Check if action is offensive
-- @return boolean Whether action is offensive
function UnitAction:isOffensive()
    return self.type == self.TYPES.SHOOT or self.type == self.TYPES.THROW
end

--- Check if action is defensive
-- @return boolean Whether action is defensive
function UnitAction:isDefensive()
    return self.type == self.TYPES.COVER or self.type == self.TYPES.CROUCH or
           self.type == self.TYPES.OVERWATCH
end

--- Check if action is movement
-- @return boolean Whether action is movement
function UnitAction:isMovement()
    return self.type == self.TYPES.MOVE
end

--- Get action icon
-- @return string Icon name
function UnitAction:getIcon()
    return self.icon
end

--- Get action animation
-- @return string Animation name
function UnitAction:getAnimation()
    return self.animation
end

--- Get action sound
-- @return string Sound name
function UnitAction:getSound()
    return self.sound
end

--- Get action data for serialization
-- @return table Action data
function UnitAction:getData()
    return {
        type = self.type,
        name = self.name,
        description = self.description,
        apCost = self.apCost,
        energyCost = self.energyCost,
        cooldown = self.cooldown,
        range = self.range,
        areaOfEffect = self.areaOfEffect,
        requirements = self.requirements,
        effects = self.effects,
        animation = self.animation,
        sound = self.sound,
        icon = self.icon
    }
end

--- Create standard actions
-- @return table Standard action definitions
function UnitAction.static.getStandardActions()
    return {
        [UnitAction.TYPES.MOVE] = UnitAction(UnitAction.TYPES.MOVE, {
            name = "Move",
            description = "Move to an adjacent tile",
            apCost = 1,
            range = 10,
            requirements = {{type = "has_ap"}},
            animation = "move",
            icon = "move_icon"
        }),

        [UnitAction.TYPES.SHOOT] = UnitAction(UnitAction.TYPES.SHOOT, {
            name = "Shoot",
            description = "Fire weapon at target",
            apCost = 4,
            range = 0, -- Uses weapon range
            requirements = {
                {type = "has_weapon"},
                {type = "has_ammo"},
                {type = "line_of_sight"},
                {type = "line_of_fire"}
            },
            animation = "shoot",
            sound = "gunshot",
            icon = "shoot_icon"
        }),

        [UnitAction.TYPES.OVERWATCH] = UnitAction(UnitAction.TYPES.OVERWATCH, {
            name = "Overwatch",
            description = "Watch for enemies and react with gunfire",
            apCost = 3,
            requirements = {{type = "has_weapon"}, {type = "has_ammo"}},
            animation = "overwatch",
            icon = "overwatch_icon"
        }),

        [UnitAction.TYPES.RELOAD] = UnitAction(UnitAction.TYPES.RELOAD, {
            name = "Reload",
            description = "Reload weapon",
            apCost = 2,
            requirements = {{type = "has_weapon"}},
            animation = "reload",
            sound = "reload",
            icon = "reload_icon"
        }),

        [UnitAction.TYPES.COVER] = UnitAction(UnitAction.TYPES.COVER, {
            name = "Take Cover",
            description = "Take cover behind available terrain",
            apCost = 1,
            animation = "cover",
            icon = "cover_icon"
        }),

        [UnitAction.TYPES.REST] = UnitAction(UnitAction.TYPES.REST, {
            name = "Rest",
            description = "Rest to recover energy",
            apCost = 0,
            energyCost = -2, -- Restores energy
            animation = "rest",
            icon = "rest_icon"
        }),

        [UnitAction.TYPES.END_TURN] = UnitAction(UnitAction.TYPES.END_TURN, {
            name = "End Turn",
            description = "End current turn",
            apCost = 0,
            animation = "end_turn",
            icon = "end_turn_icon"
        })
    }
end

return UnitAction
