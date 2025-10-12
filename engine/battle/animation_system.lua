-- Animation System
-- Handles unit movement and rotation animations

local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

-- Animation constants
AnimationSystem.MOVEMENT_TIME = 0.06  -- 60ms per tile (2 ticks at 30 FPS)

-- Create animation system
function AnimationSystem.new()
    local self = setmetatable({}, AnimationSystem)
    
    self.activeAnimations = {}
    
    return self
end

-- Start path-based movement animation (moves through each tile sequentially)
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

-- Start rotation animation
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

-- Update all animations
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

-- Check if any animations are active
function AnimationSystem:isAnimating()
    return #self.activeAnimations > 0
end

-- Check if specific unit is animating
function AnimationSystem:isUnitAnimating(unit)
    for _, anim in ipairs(self.activeAnimations) do
        if anim.unit == unit then
            return true
        end
    end
    return false
end

-- Clear all animations
function AnimationSystem:clear()
    self.activeAnimations = {}
end

return AnimationSystem
