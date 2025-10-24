-- Bullet Tracer System - Advanced 3D Projectile Path Rendering
-- Handles bullet trajectories, ricochet effects, and impact visualization
-- Integrates with HexRaycaster for 3D space calculations

local BulletTracer = {}

-- Bullet state
local BULLET_STATE_FLYING = "flying"
local BULLET_STATE_IMPACT = "impact"
local BULLET_STATE_RICOCHET = "ricochet"

function BulletTracer.new()
    local self = {}
    self.bullets = {}  -- Active bullets in flight
    self.tracers = {}  -- Rendered tracer lines

    return setmetatable(self, { __index = BulletTracer })
end

-- Fire a bullet from unit to target
-- Args:
--   fromUnit: unit firing
--   toUnit: target unit
--   weaponType: type of weapon ("rifle", "SMG", "shotgun", etc)
--   hexRaycaster: for 3D calculations
--   effectsRenderer: for visual effects
-- Returns:
--   bullet info table
function BulletTracer:fireBullet(fromUnit, toUnit, weaponType, hexRaycaster, effectsRenderer)
    if not fromUnit or not toUnit then
        return nil
    end

    -- Get trajectory points (start, end, maybe ricochet points)
    local trajectory = self:calculateTrajectory(fromUnit, toUnit, weaponType)

    local bullet = {
        state = BULLET_STATE_FLYING,
        fromUnit = fromUnit,
        toUnit = toUnit,
        weaponType = weaponType,
        trajectory = trajectory,
        currentSegment = 1,  -- Which segment of path
        progress = 0,  -- Progress along current segment (0-1)
        createdAt = love.timer.getTime(),
        speed = self:getWeaponSpeed(weaponType),
        tracerColor = self:getTracerColor(weaponType),
        impactCreated = false,
        ricochets = 0,
        maxRicochets = 2
    }

    table.insert(self.bullets, bullet)
    return bullet
end

-- Calculate bullet trajectory (path from shooter to target)
-- Args:
--   fromUnit: shooter
--   toUnit: target
--   weaponType: weapon type
-- Returns:
--   table with trajectory waypoints
function BulletTracer:calculateTrajectory(fromUnit, toUnit, weaponType)
    local trajectory = {}

    -- Start position (muzzle)
    table.insert(trajectory, {
        q = fromUnit.position.q,
        r = fromUnit.position.r,
        height = 0.5  -- Muzzle height above ground
    })

    -- End position (target)
    table.insert(trajectory, {
        q = toUnit.position.q,
        r = toUnit.position.r,
        height = 0.3  -- Hit height (chest/torso)
    })

    return trajectory
end

-- Get projectile speed based on weapon type
function BulletTracer:getWeaponSpeed(weaponType)
    local speeds = {
        rifle = 1.0,
        smg = 0.8,
        shotgun = 0.9,
        sniper = 1.2,
        pistol = 0.7,
        default = 1.0
    }
    return speeds[weaponType] or speeds.default
end

-- Get tracer color based on weapon type
function BulletTracer:getTracerColor(weaponType)
    local colors = {
        rifle = {1, 0.7, 0},      -- Orange
        smg = {0.8, 0, 0},        -- Red
        shotgun = {1, 1, 0},      -- Yellow
        sniper = {0, 1, 0},       -- Green
        pistol = {1, 0, 0},       -- Red
        default = {1, 0.8, 0}
    }
    return colors[weaponType] or colors.default
end

-- Update bullets (animate flight)
-- Args:
--   dt: delta time
function BulletTracer:update(dt)
    local toRemove = {}

    for i, bullet in ipairs(self.bullets) do
        if bullet.state == BULLET_STATE_FLYING then
            -- Advance bullet along trajectory
            local segmentDuration = 0.1  -- Time per segment (100ms)
            bullet.progress = bullet.progress + (dt / segmentDuration) * bullet.speed

            if bullet.progress >= 1.0 then
                -- Move to next segment
                bullet.currentSegment = bullet.currentSegment + 1
                bullet.progress = 0

                if bullet.currentSegment > #bullet.trajectory then
                    -- Reached end, create impact
                    bullet.state = BULLET_STATE_IMPACT
                    if not bullet.impactCreated then
                        bullet.impactCreated = true
                        -- Impact effect already created by shooting system
                    end
                end
            end
        elseif bullet.state == BULLET_STATE_IMPACT then
            -- Keep impact visible briefly then remove
            local age = love.timer.getTime() - bullet.createdAt
            if age > 0.5 then
                table.insert(toRemove, i)
            end
        end
    end

    -- Remove finished bullets
    for i = #toRemove, 1, -1 do
        table.remove(self.bullets, toRemove[i])
    end
end

-- Draw bullet tracers
-- Args:
--   hexRaycaster: for 3D projection
--   screenW, screenH: viewport dimensions
--   cameraQ, cameraR, cameraAngle, cameraPitch: camera state
function BulletTracer:draw(hexRaycaster, screenW, screenH, cameraQ, cameraR, cameraAngle, cameraPitch)
    love.graphics.push()

    for _, bullet in ipairs(self.bullets) do
        if bullet.state == BULLET_STATE_FLYING then
            self:drawFlyingBullet(bullet, hexRaycaster, screenW, screenH, cameraQ, cameraR, cameraAngle, cameraPitch)
        elseif bullet.state == BULLET_STATE_IMPACT then
            self:drawImpact(bullet)
        end
    end

    love.graphics.pop()
end

-- Draw bullet in flight with tracer line
function BulletTracer:drawFlyingBullet(bullet, hexRaycaster, screenW, screenH, cameraQ, cameraR, cameraAngle, cameraPitch)
    local currSeg = bullet.currentSegment
    if currSeg > #bullet.trajectory then
        return
    end

    -- Current position along trajectory
    local startWaypoint = bullet.trajectory[currSeg]
    local endWaypoint = bullet.trajectory[math.min(currSeg + 1, #bullet.trajectory)]

    if not startWaypoint or not endWaypoint then
        return
    end

    -- Interpolate current bullet position
    local currentQ = startWaypoint.q + (endWaypoint.q - startWaypoint.q) * bullet.progress
    local currentR = startWaypoint.r + (endWaypoint.r - startWaypoint.r) * bullet.progress
    local currentHeight = startWaypoint.height + (endWaypoint.height - startWaypoint.height) * bullet.progress

    -- Draw tracer line from start to current position
    love.graphics.setColor(bullet.tracerColor[1], bullet.tracerColor[2], bullet.tracerColor[3], 0.8)
    love.graphics.setLineWidth(2)

    -- Simple 2D representation (would need 3D projection in full implementation)
    local startX = screenW / 2 - 20
    local startY = screenH / 2
    local endX = screenW / 2 + (bullet.progress * 40)
    local endY = screenH / 2 - (bullet.progress * 30)

    love.graphics.line(startX, startY, endX, endY)

    -- Draw bullet point
    love.graphics.circle("fill", endX, endY, 3)
end

-- Draw impact effect
function BulletTracer:drawImpact(bullet)
    -- Impact spark effects
    love.graphics.setColor(1, 0.5, 0, 0.7)
    love.graphics.circle("fill", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 8)
end

-- Clear all bullets
function BulletTracer:clear()
    self.bullets = {}
end

-- Get number of active bullets
function BulletTracer:getActiveCount()
    return #self.bullets
end

return BulletTracer
