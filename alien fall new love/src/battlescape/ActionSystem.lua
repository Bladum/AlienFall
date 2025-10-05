--- Action System
-- Manages unit actions, AP costs, and action execution pipeline
--
-- @classmod battlescape.ActionSystem

-- GROK: ActionSystem manages the tactical action economy with AP and Energy resources
-- GROK: Handles action validation, execution pipeline, and resource management
-- GROK: Key methods: validateAction(), executeAction(), getRemainingAP()
-- GROK: Integrates with unit stats and battlescape state for deterministic resolution

local class = require 'lib.Middleclass'

--- ActionSystem class
-- @type ActionSystem
ActionSystem = class('ActionSystem')

--- Create a new ActionSystem instance
-- @param battleState Reference to the current battle state
-- @return ActionSystem instance
function ActionSystem:initialize(battleState)
    self.battleState = battleState
    self.actionHistory = {} -- Track executed actions for replay/debugging
    self.pendingActions = {} -- Queue for complex action sequences
end

--- Validate if a unit can perform an action
-- @param unit The unit attempting the action
-- @param actionType The type of action (movement, shoot, overwatch, etc.)
-- @param actionData Additional data for the action (target, position, etc.)
-- @return boolean Whether the action is valid
-- @return string Error message if invalid
function ActionSystem:validateAction(unit, actionType, actionData)
    -- Check if unit exists and is active
    if not unit or not unit:isAlive() then
        return false, "Unit is not available"
    end

    -- Check if it's the unit's turn
    if self.battleState:getCurrentUnit() ~= unit then
        return false, "Not this unit's turn"
    end

    -- Check action point requirements
    local apCost = self:getActionCost(unit, actionType, actionData)
    if unit:getAP() < apCost then
        return false, "Insufficient Action Points"
    end

    -- Check energy requirements for special actions
    local energyCost = self:getEnergyCost(unit, actionType, actionData)
    if unit:getEnergy() < energyCost then
        return false, "Insufficient Energy"
    end

    -- Action-specific validation
    return self:validateActionSpecific(unit, actionType, actionData)
end

--- Get Action Point cost for an action
-- @param unit The unit performing the action
-- @param actionType The type of action
-- @param actionData Additional action data
-- @return number AP cost
function ActionSystem:getActionCost(unit, actionType, actionData)
    -- Base costs from data files
    local baseCosts = {
        move = 1,      -- Per tile
        shoot = 4,
        overwatch = 3,
        reload = 2,
        cover = 1,
        crouch = 1,
        stand = 1,
        rotate = 1,
        throw = 3,
        use_item = 2,
        rest = 0,      -- Free action
        end_turn = 0   -- Free action
    }

    local cost = baseCosts[actionType] or 0

    -- Apply modifiers based on unit state and action data
    if actionType == "move" then
        cost = cost * (actionData.distance or 1)
        -- Terrain modifiers
        if actionData.terrain then
            cost = cost * actionData.terrain.moveCost
        end
        -- Stance modifiers
        if unit:getStance() == "crouch" then
            cost = cost * 1.5 -- Crouching costs more
        elseif unit:getStance() == "prone" then
            cost = cost * 2.0 -- Prone costs even more
        end
    elseif actionType == "shoot" then
        -- Range modifiers
        if actionData.range then
            if actionData.range > unit:getWeaponRange() then
                cost = cost + 2 -- Penalty for long range
            end
        end
        -- Suppression modifiers
        if unit:isSuppressed() then
            cost = cost + 1
        end
    end

    return math.ceil(cost) -- Round up to ensure integer AP
end

--- Get Energy cost for an action
-- @param unit The unit performing the action
-- @param actionType The type of action
-- @param actionData Additional action data
-- @return number Energy cost
function ActionSystem:getEnergyCost(unit, actionType, actionData)
    -- Energy costs for special abilities
    local energyCosts = {
        psionic_attack = 3,
        psionic_defense = 2,
        berserk = 5,
        mind_control = 4,
        panic = 0,     -- Free (forced)
        surrender = 0  -- Free (forced)
    }

    return energyCosts[actionType] or 0
end

--- Action-specific validation
-- @param unit The unit performing the action
-- @param actionType The type of action
-- @param actionData Additional action data
-- @return boolean Whether the action is valid
-- @return string Error message if invalid
function ActionSystem:validateActionSpecific(unit, actionType, actionData)
    if actionType == "move" then
        -- Check path validity
        if not actionData.path or #actionData.path == 0 then
            return false, "No valid path"
        end
        -- Check destination accessibility
        local destTile = actionData.path[#actionData.path]
        if not self.battleState:getMap():isTileWalkable(destTile.x, destTile.y) then
            return false, "Destination not walkable"
        end
        -- Check for unit collision
        if self.battleState:getUnitAt(destTile.x, destTile.y) then
            return false, "Destination occupied"
        end

    elseif actionType == "shoot" then
        -- Check weapon availability
        if not unit:getWeapon() then
            return false, "No weapon equipped"
        end
        -- Check ammo
        if unit:getAmmo() <= 0 then
            return false, "Out of ammunition"
        end
        -- Check line of sight
        if not self.battleState:getLineOfSight():hasLineOfSight(unit:getPosition(), actionData.target:getPosition()) then
            return false, "No line of sight to target"
        end
        -- Check line of fire (cover, etc.)
        if not self.battleState:getLineOfFire():hasLineOfFire(unit:getPosition(), actionData.target:getPosition()) then
            return false, "No line of fire to target"
        end

    elseif actionType == "overwatch" then
        -- Check if already on overwatch
        if unit:isOnOverwatch() then
            return false, "Already on overwatch"
        end

    elseif actionType == "throw" then
        -- Check item availability
        if not actionData.item then
            return false, "No item to throw"
        end
        -- Check throw distance
        local distance = self.battleState:getMap():getDistance(unit:getPosition(), actionData.target)
        if distance > unit:getThrowRange() then
            return false, "Target out of throwing range"
        end
    end

    return true
end

--- Execute an action
-- @param unit The unit performing the action
-- @param actionType The type of action
-- @param actionData Additional action data
-- @return boolean Success
-- @return table Results of the action
function ActionSystem:executeAction(unit, actionType, actionData)
    -- Validate first
    local valid, errorMsg = self:validateAction(unit, actionType, actionData)
    if not valid then
        return false, {error = errorMsg}
    end

    -- Calculate costs
    local apCost = self:getActionCost(unit, actionType, actionData)
    local energyCost = self:getEnergyCost(unit, actionType, actionData)

    -- Execute the action
    local success, results = self:executeActionSpecific(unit, actionType, actionData)

    if success then
        -- Deduct costs
        unit:spendAP(apCost)
        unit:spendEnergy(energyCost)

        -- Record in history
        table.insert(self.actionHistory, {
            unit = unit,
            actionType = actionType,
            actionData = actionData,
            apCost = apCost,
            energyCost = energyCost,
            results = results,
            turn = self.battleState:getCurrentTurn()
        })

        -- Trigger events
        self.battleState:triggerEvent('battlescape:unit_action', {
            unit = unit,
            actionType = actionType,
            actionData = actionData,
            results = results
        })
    end

    return success, results
end

--- Execute action-specific logic
-- @param unit The unit performing the action
-- @param actionType The type of action
-- @param actionData Additional action data
-- @return boolean Success
-- @return table Results
function ActionSystem:executeActionSpecific(unit, actionType, actionData)
    if actionType == "move" then
        -- Update unit position
        unit:setPosition(actionData.path[#actionData.path])
        -- Update facing direction
        if #actionData.path > 1 then
            local prevTile = actionData.path[#actionData.path - 1]
            local currTile = actionData.path[#actionData.path]
            unit:setFacing(self:calculateFacing(prevTile, currTile))
        end
        return true, {newPosition = unit:getPosition()}

    elseif actionType == "shoot" then
        -- Perform combat resolution
        local hit, damage, effects = self.battleState:getCombatSystem():resolveAttack(unit, actionData.target, actionData.weapon)
        unit:spendAmmo(1)
        return true, {
            hit = hit,
            damage = damage,
            effects = effects,
            target = actionData.target
        }

    elseif actionType == "overwatch" then
        unit:setOverwatch(true)
        return true, {overwatch = true}

    elseif actionType == "reload" then
        local ammoReloaded = unit:reload()
        return true, {ammoReloaded = ammoReloaded}

    elseif actionType == "cover" then
        unit:setStance("cover")
        return true, {stance = "cover"}

    elseif actionType == "crouch" then
        unit:setStance("crouch")
        return true, {stance = "crouch"}

    elseif actionType == "stand" then
        unit:setStance("stand")
        return true, {stance = "stand"}

    elseif actionType == "rotate" then
        unit:setFacing(actionData.direction)
        return true, {facing = actionData.direction}

    elseif actionType == "throw" then
        -- Handle grenade/item throwing
        local hit, effects = self.battleState:getCombatSystem():resolveThrow(unit, actionData.target, actionData.item)
        unit:removeItem(actionData.item)
        return true, {
            hit = hit,
            effects = effects,
            target = actionData.target
        }

    elseif actionType == "rest" then
        -- Regenerate some energy
        local energyRegained = math.min(2, unit:getMaxEnergy() - unit:getEnergy())
        unit:restoreEnergy(energyRegained)
        return true, {energyRegained = energyRegained}

    elseif actionType == "end_turn" then
        self.battleState:endUnitTurn(unit)
        return true, {turnEnded = true}
    end

    return false, {error = "Unknown action type"}
end

--- Calculate facing direction from movement
-- @param fromTile Starting tile
-- @param toTile Ending tile
-- @return string Facing direction
function ActionSystem:calculateFacing(fromTile, toTile)
    local dx = toTile.x - fromTile.x
    local dy = toTile.y - fromTile.y

    if math.abs(dx) > math.abs(dy) then
        return dx > 0 and "east" or "west"
    else
        return dy > 0 and "south" or "north"
    end
end

--- Get remaining AP for a unit
-- @param unit The unit
-- @return number Remaining AP
function ActionSystem:getRemainingAP(unit)
    return unit:getAP()
end

--- Get remaining Energy for a unit
-- @param unit The unit
-- @return number Remaining Energy
function ActionSystem:getRemainingEnergy(unit)
    return unit:getEnergy()
end

--- Check if unit can still act this turn
-- @param unit The unit
-- @return boolean Whether unit can act
function ActionSystem:canUnitAct(unit)
    return unit:getAP() > 0 or unit:getEnergy() > 0
end

--- Get action history
-- @return table Action history
function ActionSystem:getActionHistory()
    return self.actionHistory
end

--- Clear action history (for new battle)
function ActionSystem:clearHistory()
    self.actionHistory = {}
    self.pendingActions = {}
end

return ActionSystem
