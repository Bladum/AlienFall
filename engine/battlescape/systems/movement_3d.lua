---Movement3D - First-Person Turn-Based Movement
---
---WASD hex-based movement system for 3D first-person battlescape. Movement is turn-based
---(consumes action points) but smoothly animated. A/D keys rotate unit 60° left/right
---for hex grid navigation. Inspired by Wolfenstein 3D but fully turn-based.
---
---Features:
---  - WASD hex movement (W=forward, S=backward, A/D=rotate)
---  - Turn-based AP consumption (2-4 AP per move)
---  - Smooth movement animations
---  - 60° rotation steps (hex grid)
---  - Collision detection
---  - Path validation before move
---
---Controls:
---  - W: Move forward one hex tile
---  - S: Move backward one hex tile
---  - A: Rotate 60° left
---  - D: Rotate 60° right
---
---Movement Flow:
---  1. Player presses WASD
---  2. Check AP availability
---  3. Validate destination tile
---  4. Spend AP
---  5. Animate movement
---  6. Update unit position
---
---Key Exports:
---  - Movement3D.new(): Creates movement system
---  - handleInput(key, unit): Processes WASD input
---  - moveForward(unit): Moves one hex forward
---  - moveBackward(unit): Moves one hex backward
---  - rotateLeft(unit): Rotates 60° left
---  - rotateRight(unit): Rotates 60° right
---  - update(dt): Updates animations
---  - canMove(unit, direction): Validates move
---
---Dependencies:
---  - None (standalone system)
---
---@module battlescape.systems.movement_3d
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Movement3D = require("battlescape.systems.movement_3d")
---  local movement = Movement3D.new()
---  if movement:canMove(unit, "forward") then
---    movement:moveForward(unit)
---  end
---  movement:update(dt)
---
---@see battlescape.combat.action_system For AP management

-- 3D Movement System for First-Person Battlescape
-- WASD hex-based movement with smooth animations
-- Movement is turn-based (consumes action points) but animated
-- A/D keys rotate unit 60° left/right (hex rotation)

local Movement3D = {}
Movement3D.__index = Movement3D

---@class Animation
---@field type string "movement" or "rotation"
---@field unit table Unit being animated
---@field startTime number Animation start time
---@field duration number Animation duration in seconds
---@field onComplete function Callback when animation finishes

--- Create new 3D movement system
function Movement3D.new()
    local self = setmetatable({}, Movement3D)
    
    -- Current animation (only one at a time)
    self.animation = nil
    
    -- Movement settings
    self.settings = {
        moveDuration = 0.2,     -- 200ms per tile
        rotateDuration = 0.2,   -- 200ms per 60° rotation
        apCostMove = 1,         -- AP cost for movement
        apCostRotate = 0,       -- Rotation is free
    }
    
    -- Hex directions (0-5, starting north, clockwise)
    self.hexDirections = {
        {q = 0, r = -1},  -- 0: North
        {q = 1, r = -1},  -- 1: Northeast
        {q = 1, r = 0},   -- 2: Southeast
        {q = 0, r = 1},   -- 3: South
        {q = -1, r = 1},  -- 4: Southwest
        {q = -1, r = 0},  -- 5: Northwest
    }
    
    print("[Movement3D] Initialized")
    return self
end

--- Update animations
---@param dt number Delta time
function Movement3D:update(dt)
    if not self.animation then return end
    
    local elapsed = love.timer.getTime() - self.animation.startTime
    local progress = math.min(elapsed / self.animation.duration, 1.0)
    
    -- Smooth easing (ease in-out)
    local t = self:easeInOut(progress)
    
    -- Update based on animation type
    if self.animation.type == "movement" then
        self:updateMovement(t)
    elseif self.animation.type == "rotation" then
        self:updateRotation(t)
    end
    
    -- Complete animation
    if progress >= 1.0 then
        self.animation.onComplete()
        self.animation = nil
    end
end

--- Ease in-out function for smooth animation
---@param t number Progress (0-1)
---@return number Eased value
function Movement3D:easeInOut(t)
    return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2
end

--- Update movement animation
---@param t number Eased progress (0-1)
function Movement3D:updateMovement(t)
    local anim = self.animation
    local unit = anim.unit
    
    -- Interpolate position (visual only, doesn't change actual grid position)
    unit.renderX = anim.startX + (anim.targetX - anim.startX) * t
    unit.renderY = anim.startY + (anim.targetY - anim.startY) * t
end

--- Update rotation animation
---@param t number Eased progress (0-1)
function Movement3D:updateRotation(t)
    local anim = self.animation
    local unit = anim.unit
    
    -- Interpolate angle
    local angleDiff = anim.targetFacing - anim.startFacing
    
    -- Handle wrap-around (always rotate shortest direction)
    if angleDiff > 3 then
        angleDiff = angleDiff - 6
    elseif angleDiff < -3 then
        angleDiff = angleDiff + 6
    end
    
    unit.renderFacing = anim.startFacing + angleDiff * t
end

--- Move unit forward (W key)
---@param unit table Unit to move
---@param battlefield table Battlefield data
---@return boolean Success
function Movement3D:moveForward(unit, battlefield)
    if self.animation then
        print("[Movement3D] Animation in progress")
        return false
    end
    
    -- Get target tile in facing direction
    local direction = math.floor(unit.facing)
    local hexDir = self.hexDirections[direction + 1]
    local targetQ = unit.q + hexDir.q
    local targetR = unit.r + hexDir.r
    
    -- Convert axial to offset coordinates
    local targetX = targetQ + math.floor((targetR + (targetR % 2)) / 2)
    local targetY = targetR
    
    -- Check if tile exists and is walkable
    local tile = battlefield:getTile(targetX, targetY)
    if not tile or not tile:isWalkable() then
        print("[Movement3D] Tile blocked at " .. targetX .. "," .. targetY)
        return false
    end
    
    -- Check action points
    if unit.actionPointsLeft < self.settings.apCostMove then
        print("[Movement3D] Not enough AP (need " .. self.settings.apCostMove .. ")")
        return false
    end
    
    -- Start movement animation
    self:animateMovement(unit, targetX, targetY, targetQ, targetR)
    return true
end

--- Move unit backward (S key)
---@param unit table Unit to move
---@param battlefield table Battlefield data
---@return boolean Success
function Movement3D:moveBackward(unit, battlefield)
    -- Same as forward but opposite direction
    local backwardFacing = (math.floor(unit.facing) + 3) % 6
    local originalFacing = unit.facing
    
    -- Temporarily change facing
    unit.facing = backwardFacing
    local result = self:moveForward(unit, battlefield)
    unit.facing = originalFacing
    
    return result
end

--- Rotate unit left 60° (A key)
---@param unit table Unit to rotate
function Movement3D:rotateLeft(unit)
    if self.animation then
        print("[Movement3D] Animation in progress")
        return false
    end
    
    local newFacing = (math.floor(unit.facing) - 1) % 6
    self:animateRotation(unit, newFacing)
    return true
end

--- Rotate unit right 60° (D key)
---@param unit table Unit to rotate
function Movement3D:rotateRight(unit)
    if self.animation then
        print("[Movement3D] Animation in progress")
        return false
    end
    
    local newFacing = (math.floor(unit.facing) + 1) % 6
    self:animateRotation(unit, newFacing)
    return true
end

--- Start movement animation
---@param unit table Unit to animate
---@param targetX number Target X coordinate
---@param targetY number Target Y coordinate
---@param targetQ number Target axial Q
---@param targetR number Target axial R
function Movement3D:animateMovement(unit, targetX, targetY, targetQ, targetR)
    local startX = unit.x
    local startY = unit.y
    local startTime = love.timer.getTime()
    
    -- Store render position if not set
    if not unit.renderX then unit.renderX = startX end
    if not unit.renderY then unit.renderY = startY end
    
    self.animation = {
        type = "movement",
        unit = unit,
        startX = unit.renderX,
        startY = unit.renderY,
        targetX = targetX,
        targetY = targetY,
        startTime = startTime,
        duration = self.settings.moveDuration,
        onComplete = function()
            -- Update actual position
            unit.x = targetX
            unit.y = targetY
            unit.q = targetQ
            unit.r = targetR
            unit.renderX = targetX
            unit.renderY = targetY
            
            -- Deduct action points
            unit.actionPointsLeft = unit.actionPointsLeft - self.settings.apCostMove
            
            print("[Movement3D] Unit moved to " .. targetX .. "," .. targetY .. 
                  " (AP remaining: " .. unit.actionPointsLeft .. ")")
        end
    }
end

--- Start rotation animation
---@param unit table Unit to animate
---@param targetFacing number Target facing (0-5)
function Movement3D:animateRotation(unit, targetFacing)
    local startFacing = unit.renderFacing or unit.facing
    local startTime = love.timer.getTime()
    
    self.animation = {
        type = "rotation",
        unit = unit,
        startFacing = startFacing,
        targetFacing = targetFacing,
        startTime = startTime,
        duration = self.settings.rotateDuration,
        onComplete = function()
            -- Update actual facing
            unit.facing = targetFacing
            unit.renderFacing = targetFacing
            
            print("[Movement3D] Unit rotated to facing " .. targetFacing)
        end
    }
end

--- Handle keyboard input
---@param key string Key pressed
---@param unit table Active unit
---@param battlefield table Battlefield data
---@return boolean Handled
function Movement3D:onKeyPressed(key, unit, battlefield)
    if not unit then return false end
    
    if key == "w" then
        return self:moveForward(unit, battlefield)
    elseif key == "s" then
        return self:moveBackward(unit, battlefield)
    elseif key == "a" then
        return self:rotateLeft(unit)
    elseif key == "d" then
        return self:rotateRight(unit)
    end
    
    return false
end

--- Check if animation is active
---@return boolean Is animating
function Movement3D:isAnimating()
    return self.animation ~= nil
end

--- Cancel current animation
function Movement3D:cancelAnimation()
    if self.animation then
        print("[Movement3D] Animation cancelled")
        self.animation = nil
    end
end

--- Get unit's render position (for camera following)
---@param unit table Unit
---@return number, number Render X, Y
function Movement3D:getRenderPosition(unit)
    return unit.renderX or unit.x, unit.renderY or unit.y
end

return Movement3D


























