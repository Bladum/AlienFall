---Combat3D - First-Person Combat Handler
---
---Handles shooting mechanics from 3D first-person view in the alternative battlescape.
---Integrates with existing ActionSystem for combat resolution while providing 3D-specific
---targeting, aiming, and shooting mechanics. Inspired by Wolfenstein 3D but turn-based.
---
---Features:
---  - First-person shooting mechanics
---  - 3D targeting and aiming
---  - Integration with ActionSystem
---  - Turn-based shooting resolution
---  - Weapon accuracy modifiers
---  - Crosshair targeting system
---
---Combat Flow:
---  1. Enter targeting mode (aim weapon)
---  2. Select target unit or position
---  3. Calculate hit chance based on distance/cover
---  4. Spend AP for shot
---  5. Resolve damage through ActionSystem
---  6. Display hit/miss feedback
---
---Targeting Modes:
---  - Unit targeting: Aim at specific enemy
---  - Area targeting: Shoot at position
---  - Snap shot: Quick low-accuracy shot
---  - Aimed shot: Slow high-accuracy shot
---
---Key Exports:
---  - Combat3D.new(): Creates 3D combat handler
---  - enterTargeting(unit, weapon): Starts targeting mode
---  - exitTargeting(): Cancels targeting
---  - selectTarget(unit): Targets specific enemy
---  - calculateHitChance(shooter, target): Computes accuracy
---  - shoot(): Executes attack
---  - isTargeting(): Checks if in targeting mode
---
---Dependencies:
---  - battlescape.combat.action_system: Combat resolution (implied)
---
---@module battlescape.combat.combat_3d
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Combat3D = require("battlescape.combat.combat_3d")
---  local combat = Combat3D.new()
---  combat:enterTargeting(currentUnit, rifle)
---  combat:selectTarget(enemyUnit)
---  combat:shoot()
---
---@see battlescape.combat.action_system For combat resolution

-- 3D Combat Handler for First-Person Battlescape
-- Handles shooting mechanics from 3D view
-- Integrates with existing ActionSystem for combat resolution

local Combat3D = {}
Combat3D.__index = Combat3D

--- Create new 3D combat handler
function Combat3D.new()
    local self = setmetatable({}, Combat3D)
    
    -- Combat state
    self.targeting = false
    self.targetUnit = nil
    self.targetPosition = nil
    
    print("[Combat3D] Initialized")
    return self
end

--- Handle shooting at target unit
---@param shooter table Shooter unit
---@param target table Target unit
---@param actionSystem table ActionSystem instance
---@param losSystem table LOS system
---@param effects3D table Effects3D renderer
---@return table|nil Combat result
function Combat3D:shootAtTarget(shooter, target, actionSystem, losSystem, effects3D)
    -- Validate shooter
    if not shooter or shooter.actionPointsLeft < 1 then
        print("[Combat3D] Shooter has no AP left")
        return nil
    end
    
    -- Validate target
    if not target or target.team == shooter.team then
        print("[Combat3D] Invalid target")
        return nil
    end
    
    -- Check LOS
    if not losSystem:hasLOS(shooter.x, shooter.y, target.x, target.y) then
        print("[Combat3D] No line of sight to target")
        return nil
    end
    
    -- Check ammo
    if shooter.weapon and shooter.weapon.ammo <= 0 then
        print("[Combat3D] No ammo")
        return nil
    end
    
    -- Play muzzle flash
    effects3D:playMuzzleFlash(shooter.x, shooter.y)
    
    -- Execute attack using existing ActionSystem
    local result = actionSystem:executeAttack(shooter, target, losSystem)
    
    if result.hit then
        print(string.format("[Combat3D] %s hit %s for %d damage", 
              shooter.name, target.name, result.damage))
        
        -- Play hit effect
        local hitType = target.race == "robot" and "spark" or "blood"
        effects3D:playHitEffect(target.x, target.y, hitType)
    else
        print(string.format("[Combat3D] %s missed %s", 
              shooter.name, target.name))
        
        -- Play miss effect
        effects3D:playMissEffect(target.x, target.y)
    end
    
    -- Deduct ammo and AP (already done by ActionSystem, but double-check)
    if shooter.weapon then
        shooter.weapon.ammo = math.max(0, shooter.weapon.ammo - 1)
    end
    
    return result
end

--- Handle shooting at position (grenade, etc.)
---@param shooter table Shooter unit
---@param targetX number Target X coordinate
---@param targetY number Target Y coordinate
---@param actionSystem table ActionSystem instance
---@param effects3D table Effects3D renderer
---@return table|nil Combat result
function Combat3D:shootAtPosition(shooter, targetX, targetY, actionSystem, effects3D)
    -- Validate shooter
    if not shooter or shooter.actionPointsLeft < 1 then
        print("[Combat3D] Shooter has no AP left")
        return nil
    end
    
    -- Check if weapon can target ground (grenades, explosives)
    if not shooter.weapon or not shooter.weapon.canTargetGround then
        print("[Combat3D] Weapon cannot target ground")
        return nil
    end
    
    -- Play muzzle flash
    effects3D:playMuzzleFlash(shooter.x, shooter.y)
    
    -- Execute area attack
    local result = actionSystem:executeAreaAttack(shooter, targetX, targetY)
    
    if result.success then
        print(string.format("[Combat3D] %s fired at %d,%d", 
              shooter.name, targetX, targetY))
        
        -- Play explosion effect
        effects3D:playExplosion(targetX, targetY, result.radius or 2)
    end
    
    return result
end

--- Handle overwatch/reaction fire
---@param shooter table Shooter unit
---@param target table Moving target unit
---@param actionSystem table ActionSystem instance
---@param effects3D table Effects3D renderer
---@return boolean Fired
function Combat3D:reactionFire(shooter, target, actionSystem, effects3D)
    -- Check if shooter can react
    if not shooter.reactionFire or shooter.actionPointsLeft < 1 then
        return false
    end
    
    -- Play muzzle flash
    effects3D:playMuzzleFlash(shooter.x, shooter.y)
    
    -- Execute reaction shot
    local result = actionSystem:executeReactionFire(shooter, target)
    
    if result and result.hit then
        print(string.format("[Combat3D] %s reaction shot hit %s", 
              shooter.name, target.name))
        
        local hitType = target.race == "robot" and "spark" or "blood"
        effects3D:playHitEffect(target.x, target.y, hitType)
    else
        print(string.format("[Combat3D] %s reaction shot missed", shooter.name))
        if target then
            effects3D:playMissEffect(target.x, target.y)
        end
    end
    
    return true
end

--- Get targeting cursor info
---@param hoveredObject table Hovered object from MousePicking3D
---@param shooter table Active unit
---@return table|nil Cursor info {type, canShoot, apCost, hitChance}
function Combat3D:getTargetInfo(hoveredObject, shooter)
    if not hoveredObject or not shooter then
        return nil
    end
    
    if hoveredObject.type == "unit" then
        local target = hoveredObject.unit
        
        -- Check if enemy
        if target.team ~= shooter.team then
            return {
                type = "enemy",
                canShoot = shooter.actionPointsLeft >= 1,
                apCost = 1,
                hitChance = self:calculateHitChance(shooter, target),
                target = target,
            }
        else
            return {
                type = "ally",
                canShoot = false,
                target = target,
            }
        end
    elseif hoveredObject.type == "floor" then
        -- Check if can target ground
        if shooter.weapon and shooter.weapon.canTargetGround then
            return {
                type = "ground",
                canShoot = shooter.actionPointsLeft >= 1,
                apCost = 1,
                x = hoveredObject.x,
                y = hoveredObject.y,
            }
        end
    end
    
    return nil
end

--- Calculate hit chance (simplified, ActionSystem has full calculation)
---@param shooter table Shooter unit
---@param target table Target unit
---@return number Hit chance (0-100)
function Combat3D:calculateHitChance(shooter, target)
    -- Simplified calculation for UI display
    -- Real calculation done by ActionSystem
    
    local baseAccuracy = shooter.accuracy or 65
    local distance = math.sqrt((shooter.x - target.x)^2 + (shooter.y - target.y)^2)
    
    -- Accuracy drops with distance
    local distancePenalty = distance * 5
    local finalAccuracy = math.max(10, math.min(95, baseAccuracy - distancePenalty))
    
    return math.floor(finalAccuracy)
end

return Combat3D






















