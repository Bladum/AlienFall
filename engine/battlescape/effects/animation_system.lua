---AnimationSystem - Unit Movement and Rotation Animation Manager
---
---Handles smooth animations for unit movement, rotation, and state transitions in
---tactical combat. Provides path-based movement animations with configurable timing,
---rotation transitions, and completion callbacks for game state synchronization.
---
---Animation Types:
---  - Path-based movement: Smooth tile-to-tile movement along calculated paths
---  - Rotation transitions: Gradual facing direction changes
---  - State animations: Idle, walking, running, combat stances
---  - Completion callbacks: Trigger events when animations finish
---
---Features:
---  - Configurable movement timing (60ms per tile default)
---  - Smooth interpolation between positions
---  - Animation queue management for sequential movements
---  - Rotation smoothing to prevent jerky turns
---  - Performance optimization for multiple simultaneous animations
---  - Integration with unit state system
---
---Key Exports:
---  - new(): Create new animation system instance
---  - addMovement(unit, path, onComplete): Add movement animation
---  - addRotation(unit, targetAngle, onComplete): Add rotation animation
---  - update(dt): Update all active animations
---  - clearAnimations(unit): Clear animations for specific unit
---  - isAnimating(unit): Check if unit is currently animating
---  - getAnimationProgress(unit): Get current animation progress
---
---Dependencies:
---  - Unit system for position and rotation state
---  - Pathfinding system for movement paths
---
---@module battlescape.effects.animation_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local AnimationSystem = require("battlescape.effects.animation_system")
---  local animSystem = AnimationSystem.new()
---  animSystem:addMovement(unit, path, function() print("Movement complete") end)
---  animSystem:update(dt)
---
---@see battlescape.combat.unit For unit state management
---@see ai.pathfinding.tactical_pathfinding For path generation

-- Animation System
-- Handles unit movement and rotation animations

--- @class AnimationSystem
--- Manages smooth animations for unit movement and rotation in tactical combat.
--- Provides path-based movement animations and rotation transitions with configurable timing.
--- All animations are updated in the main game loop and support completion callbacks.
---
--- @field activeAnimations table[] Array of currently active animation objects
--- @field MOVEMENT_TIME number Time in seconds to move between adjacent tiles (default: 0.06)
local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

-- Animation constants
AnimationSystem.MOVEMENT_TIME = 0.06  -- 60ms per tile (2 ticks at 30 FPS)

--- Creates a new animation system instance.
---
--- @return AnimationSystem A new AnimationSystem instance with empty animation queue
function AnimationSystem.new()
    local self = setmetatable({}, AnimationSystem)

    self.activeAnimations = {}

    return self
end

--- Starts a path-based movement animation that moves through each tile sequentially.
--- The unit will smoothly animate from tile to tile along the provided path.
---
--- @param unit table The unit object to animate (must have name, animX, animY fields)
--- @param path table[] Array of tile objects with x,y coordinates representing the movement path
--- @param onTileComplete function|nil Optional callback called when each tile movement completes: function(unit, x, y)
--- @param onComplete function|nil Optional callback called when entire path animation completes: function()
function AnimationSystem:startPathMovement(unit, path, onTileComplete, onComplete)
    if not path or #path < 2 then
        if onComplete then onComplete() end
        return
    end

    local anim = {
        type = "path_movement",
        unit = unit,
        path = path,
        currentStep = 1,  -- Start at step 1 (moving from path[1] to path[2])
        progress = 0,
        duration = AnimationSystem.MOVEMENT_TIME,
        onTileComplete = onTileComplete,
        onComplete = onComplete
    }

    table.insert(self.activeAnimations, anim)
    print(string.format("[AnimationSystem] Started path movement animation for %s (%d tiles)",
          unit.name, #path - 1))
end

--- Starts a rotation animation to smoothly turn the unit to a target facing direction.
--- Uses the shortest rotation direction and animates over 100ms per 60° turn.
---
--- @param unit table The unit object to animate (must have name, facing, animFacing fields)
--- @param targetFacing number The target facing direction (0-5, where 0=north, increasing clockwise)
--- @param onComplete function|nil Optional callback called when rotation completes: function()
function AnimationSystem:startRotation(unit, targetFacing, onComplete)
    local currentFacing = unit.facing or 0
    local facingDiff = (targetFacing - currentFacing) % 6

    -- Take the shorter rotation direction
    if facingDiff > 3 then
        facingDiff = facingDiff - 6
    end

    local anim = {
        type = "rotation",
        unit = unit,
        startFacing = currentFacing,
        targetFacing = targetFacing,
        facingDiff = facingDiff,
        progress = 0,
        duration = 0.1,  -- 100ms per 60° rotation
        onComplete = onComplete
    }

    table.insert(self.activeAnimations, anim)
    print(string.format("[AnimationSystem] Started rotation animation for %s: %d° → %d°",
          unit.name, currentFacing * 60, targetFacing * 60))
end

--- Updates all active animations based on elapsed time.
--- Should be called once per frame in the main game loop.
--- Handles animation progression, interpolation, and completion callbacks.
---
--- @param dt number Time elapsed since last update in seconds
function AnimationSystem:update(dt)
    local completedAnimations = {}

    for i, anim in ipairs(self.activeAnimations) do
        anim.progress = anim.progress + dt

        if anim.progress >= anim.duration then
            -- Animation step complete
            if anim.type == "movement" then
                anim.unit.animX = anim.toX
                anim.unit.animY = anim.toY
                -- Call completion callback
                if anim.onComplete then
                    anim.onComplete()
                end
                table.insert(completedAnimations, i)

            elseif anim.type == "path_movement" then
                -- Move to next tile in path
                anim.currentStep = anim.currentStep + 1
                local nextTile = anim.path[anim.currentStep]

                if nextTile then
                    -- Move to next tile
                    local prevTile = anim.path[anim.currentStep - 1]
                    anim.unit.animX = nextTile.x
                    anim.unit.animY = nextTile.y

                    -- Call tile completion callback
                    if anim.onTileComplete then
                        anim.onTileComplete(anim.unit, nextTile.x, nextTile.y)
                    end

                    -- Reset progress for next tile
                    anim.progress = 0
                    print(string.format("[AnimationSystem] %s moved to tile (%d,%d)",
                          anim.unit.name, nextTile.x, nextTile.y))
                else
                    -- Path complete
                    if anim.onComplete then
                        anim.onComplete()
                    end
                    table.insert(completedAnimations, i)
                    print(string.format("[AnimationSystem] %s completed path movement", anim.unit.name))
                end

            elseif anim.type == "rotation" then
                -- Rotation complete
                anim.unit.facing = anim.targetFacing
                anim.unit.animFacing = anim.targetFacing
                if anim.onComplete then
                    anim.onComplete()
                end
                table.insert(completedAnimations, i)
                print(string.format("[AnimationSystem] %s completed rotation to facing %d",
                      anim.unit.name, anim.targetFacing))
            end
        else
            -- Update animation state
            local t = anim.progress / anim.duration

            if anim.type == "movement" then
                -- Linear interpolation for position
                anim.unit.animX = anim.fromX + (anim.toX - anim.fromX) * t
                anim.unit.animY = anim.fromY + (anim.toY - anim.fromY) * t
            elseif anim.type == "path_movement" then
                -- Interpolate between current and next tile
                local currentTile = anim.path[anim.currentStep]
                local nextTile = anim.path[anim.currentStep + 1]

                if currentTile and nextTile then
                    anim.unit.animX = currentTile.x + (nextTile.x - currentTile.x) * t
                    anim.unit.animY = currentTile.y + (nextTile.y - currentTile.y) * t
                end
            elseif anim.type == "rotation" then
                -- Slerp-like interpolation for rotation
                local newFacing = anim.startFacing + anim.facingDiff * t

                -- Normalize to [0,5] range
                if newFacing < 0 then newFacing = newFacing + 6 end
                if newFacing > 5 then newFacing = newFacing - 6 end

                anim.unit.facing = newFacing
            end
        end
    end

    -- Remove completed animations (in reverse order to maintain indices)
    for i = #completedAnimations, 1, -1 do
        table.remove(self.activeAnimations, completedAnimations[i])
    end
end

--- Checks if any animations are currently active.
---
--- @return boolean True if there are active animations, false otherwise
function AnimationSystem:isAnimating()
    return #self.activeAnimations > 0
end

--- Checks if a specific unit is currently being animated.
---
--- @param unit table The unit object to check
--- @return boolean True if the unit has active animations, false otherwise
function AnimationSystem:isUnitAnimating(unit)
    for _, anim in ipairs(self.activeAnimations) do
        if anim.unit == unit then
            return true
        end
    end
    return false
end

--- Clears all active animations immediately without calling completion callbacks.
--- Useful for resetting animation state or canceling all animations.
function AnimationSystem:clear()
    self.activeAnimations = {}
end

return AnimationSystem

























