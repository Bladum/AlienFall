---@class Unit
-- Base class for all units in the game
-- Handles position, team affiliation, stats, and behavior

local Constants = require("config.constants")

local Unit = {}
Unit.__index = Unit

--- Create a new Unit
---@param x number Grid X position
---@param y number Grid Y position
---@param teamId number Team ID from Constants.TEAM
---@return Unit
function Unit.new(x, y, teamId)
    local self = setmetatable({}, Unit)
    
    -- Position
    self.gridX = x
    self.gridY = y
    self.worldX = x
    self.worldZ = y
    self.worldY = Constants.UNIT_HEIGHT  -- Height above ground
    
    -- Movement
    self.angle = 0  -- Facing angle in radians
    self.moving = false
    self.moveTimer = 0
    self.moveDuration = 0.2
    self.startX = x
    self.startZ = y
    self.targetX = x
    self.targetZ = y
    
    -- Team affiliation
    self.teamId = teamId or Constants.TEAM.NEUTRAL
    self.team = nil  -- Reference to Team object (set by Team:addUnit)
    
    -- Stats
    self.health = 100
    self.maxHealth = 100
    self.active = true
    self.alive = true
    
    -- Vision
    self.losRange = Constants.UNIT_LOS_RANGE
    self.senseRange = Constants.UNIT_SENSE_RANGE
    
    -- Rendering
    self.sprite = nil  -- Texture for this unit
    self.model = nil   -- G3D model for 3D rendering
    self.scale = Constants.UNIT_SCALE
    self.visible = true
    
    -- Combat
    self.canAttack = true
    self.attackRange = 8
    self.attackDamage = 25
    self.attackCooldown = 0
    self.attackDelay = 1.0  -- Seconds between attacks
    
    return self
end

--- Update unit state
---@param dt number Delta time in seconds
function Unit:update(dt)
    -- Update movement animation
    if self.moving and self.moveTimer > 0 then
        self.moveTimer = self.moveTimer - dt
        
        if self.moveTimer <= 0 then
            self.moveTimer = 0
            self.moving = false
            -- Snap to final position
            self.worldX = self.targetX
            self.worldZ = self.targetZ
            self.gridX = self.targetX
            self.gridY = self.targetZ
        else
            -- Interpolate position
            local progress = (self.moveDuration - self.moveTimer) / self.moveDuration
            self.worldX = self.startX + (self.targetX - self.startX) * progress
            self.worldZ = self.startZ + (self.targetZ - self.startZ) * progress
        end
        
        -- Update model position if exists
        if self.model then
            self.model:setTranslation(self.worldX, self.worldY, self.worldZ)
        end
    end
    
    -- Update attack cooldown
    if self.attackCooldown > 0 then
        self.attackCooldown = self.attackCooldown - dt
    end
end

--- Start moving to a new grid position
---@param targetX number Target grid X
---@param targetY number Target grid Y
---@return boolean Success
function Unit:moveTo(targetX, targetY)
    if self.moving then
        return false  -- Already moving
    end
    
    self.startX = self.worldX
    self.startZ = self.worldZ
    self.targetX = targetX
    self.targetZ = targetY
    self.moving = true
    self.moveTimer = self.moveDuration
    
    return true
end

--- Face towards a specific position
---@param targetX number Target world X
---@param targetZ number Target world Z
function Unit:faceTowards(targetX, targetZ)
    local dx = targetX - self.worldX
    local dz = targetZ - self.worldZ
    self.angle = math.atan2(-dz, dx)
    
    -- Update model rotation if exists
    if self.model then
        self.model:setRotation(0, self.angle, 0)
    end
end

--- Check if this unit can see a specific position
---@param targetX number Target grid X
---@param targetY number Target grid Y
---@param map any Map object with tiles
---@return boolean
function Unit:canSee(targetX, targetY, map)
    -- Calculate distance
    local dx = targetX - self.gridX
    local dy = targetY - self.gridY
    local dist = math.sqrt(dx*dx + dy*dy)
    
    -- Outside LOS range
    if dist > self.losRange then
        return false
    end
    
    -- Check line of sight using map
    return map:hasLineOfSight(self.gridX, self.gridY, targetX, targetY)
end

--- Check if this unit can sense another unit (within sense range)
---@param otherUnit Unit Another unit
---@return boolean
function Unit:canSense(otherUnit)
    local dx = otherUnit.gridX - self.gridX
    local dy = otherUnit.gridY - self.gridY
    local dist = math.sqrt(dx*dx + dy*dy)
    
    return dist <= self.senseRange
end

--- Deal damage to this unit
---@param amount number Damage amount
---@return boolean Unit died
function Unit:takeDamage(amount)
    self.health = self.health - amount
    
    if self.health <= 0 then
        self.health = 0
        self.alive = false
        self.active = false
        return true  -- Unit died
    end
    
    return false  -- Unit survived
end

--- Heal this unit
---@param amount number Heal amount
function Unit:heal(amount)
    if not self.alive then return end
    self.health = math.min(self.health + amount, self.maxHealth)
end

--- Check if unit can attack
---@return boolean
function Unit:canPerformAttack()
    return self.canAttack and self.attackCooldown <= 0 and self.alive
end

--- Perform an attack (starts cooldown)
function Unit:performAttack()
    self.attackCooldown = self.attackDelay
end

--- Get position as table
---@return table {x, y, z}
function Unit:getPosition()
    return {x = self.worldX, y = self.worldY, z = self.worldZ}
end

--- Get grid position as table
---@return table {x, y}
function Unit:getGridPosition()
    return {x = self.gridX, y = self.gridY}
end

--- Check if unit is alive
---@return boolean
function Unit:isAlive()
    return self.alive
end

--- Convert to string for debugging
---@return string
function Unit:toString()
    return string.format("Unit[Team %d](%d,%d) HP:%d/%d", 
        self.teamId, self.gridX, self.gridY, self.health, self.maxHealth)
end

return Unit
