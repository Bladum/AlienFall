-- Performance Optimizer for 3D Rendering
-- Implements frustum culling, effect pooling, and LOD systems
-- Reduces draw calls, GC pressure, and improves FPS

local PerformanceOptimizer = {}

-- Configuration constants
local FOV_DEGREES = 90  -- Horizontal field of view
local FOV_RADIANS = (FOV_DEGREES / 2) * (math.pi / 180)  -- Half-angle in radians
local NEAR_PLANE = 0.1
local FAR_PLANE = 100  -- Objects beyond this distance culled
local LOD_DISTANCE_NEAR = 5
local LOD_DISTANCE_FAR = 20
local LOD_DISTANCE_ULTRA_FAR = 50

-- Effect pooling constants
local POOL_INITIAL_SIZE = 32
local POOL_MAX_SIZE = 256

-- Pool for reusable effect objects
local function createEffectPool()
    return {
        active = {},      -- Currently in use
        inactive = {},    -- Available for reuse
        nextId = 1
    }
end

-- Create new performance optimizer
function PerformanceOptimizer.new()
    local self = {}

    -- Frustum culling
    self.fovRadians = FOV_RADIANS
    self.nearPlane = NEAR_PLANE
    self.farPlane = FAR_PLANE

    -- Effect pooling
    self.effectPool = createEffectPool()
    self:initializeEffectPool()

    -- Performance metrics
    self.stats = {
        effectsRendered = 0,
        effectsCulled = 0,
        lodLevel = 0,
        frameTime = 0,
        gcPressure = 0
    }

    return setmetatable(self, { __index = PerformanceOptimizer })
end

-- Initialize reusable effect objects
function PerformanceOptimizer:initializeEffectPool()
    local pool = self.effectPool

    for i = 1, POOL_INITIAL_SIZE do
        local effect = {
            id = pool.nextId,
            type = "",
            x = 0, y = 0, z = 0,
            screenX = 0, screenY = 0,
            distance = 0,
            visible = false,
            opacity = 1,
            scale = 1,
            intensity = 1,
            duration = 1,
            createdAt = 0,
            frameIndex = 0,
            lodLevel = 0,
            active = false
        }
        table.insert(pool.inactive, effect)
        pool.nextId = pool.nextId + 1
    end
end

-- Get effect from pool (reuse or create new)
function PerformanceOptimizer:getEffectFromPool(effectType)
    local pool = self.effectPool

    -- Try to reuse from inactive pool
    if #pool.inactive > 0 then
        local effect = table.remove(pool.inactive)
        effect.active = true
        effect.type = effectType
        table.insert(pool.active, effect)
        return effect
    end

    -- Create new if pool not at max
    if pool.nextId < POOL_MAX_SIZE then
        local effect = {
            id = pool.nextId,
            type = effectType,
            x = 0, y = 0, z = 0,
            screenX = 0, screenY = 0,
            distance = 0,
            visible = false,
            opacity = 1,
            scale = 1,
            intensity = 1,
            duration = 1,
            createdAt = 0,
            frameIndex = 0,
            lodLevel = 0,
            active = true
        }
        pool.nextId = pool.nextId + 1
        table.insert(pool.active, effect)
        return effect
    end

    -- Pool exhausted, reuse oldest inactive if available
    if #pool.inactive > 0 then
        local effect = table.remove(pool.inactive)
        effect.active = true
        effect.type = effectType
        table.insert(pool.active, effect)
        return effect
    end

    print("[PerformanceOptimizer] Warning: Effect pool exhausted, creating temporary effect")
    return {
        type = effectType,
        active = true,
        x = 0, y = 0, z = 0,
        screenX = 0, screenY = 0,
        distance = 0,
        opacity = 1,
        scale = 1,
        intensity = 1,
        lodLevel = 0
    }
end

-- Return effect to pool for reuse
function PerformanceOptimizer:returnEffectToPool(effect)
    if not effect or not effect.active then
        return
    end

    local pool = self.effectPool

    -- Find and remove from active
    for i, e in ipairs(pool.active) do
        if e == effect then
            table.remove(pool.active, i)
            break
        end
    end

    -- Reset and add to inactive
    effect.active = false
    effect.type = ""
    effect.visible = false
    table.insert(pool.inactive, effect)

    self.stats.gcPressure = self.stats.gcPressure - 1
end

-- Calculate frustum culling for point
-- Returns true if point is within camera frustum
function PerformanceOptimizer:isBehindFrustum(effectX, effectY, screenX, screenY, cameraAngle, cameraPitch, distance)
    -- Check distance culling (near/far plane)
    if distance < self.nearPlane or distance > self.farPlane then
        return true  -- Culled
    end

    -- Screen position check (if already projected)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- Simple bounds check: if way off screen, cull
    if screenX < -screenW * 0.5 or screenX > screenW * 1.5 or
       screenY < -screenH * 0.5 or screenY > screenH * 1.5 then
        return true  -- Culled
    end

    -- Angle-based frustum culling: only render within ±45° horizontal FOV
    -- Calculate angle from camera to effect
    local angleToEffect = self:calculateAngleToPoint(effectX, effectY, cameraAngle)
    local angleDiff = math.abs(angleToEffect - cameraAngle)

    -- Normalize angle difference to [-pi, pi]
    while angleDiff > math.pi do
        angleDiff = angleDiff - 2 * math.pi
    end
    while angleDiff < -math.pi do
        angleDiff = angleDiff + 2 * math.pi
    end

    -- If beyond 45° horizontal, cull
    if math.abs(angleDiff) > self.fovRadians then
        return true  -- Culled
    end

    -- Pitch culling: if pitch is extreme, don't render above/below
    -- Range: -pi/4 to pi/4 (45° up/down)
    if math.abs(cameraPitch) > math.pi / 4 then
        -- Only render if effect is within reasonable vertical range
        if cameraPitch > 0 and screenY > screenH * 0.8 then
            return true  -- Looking up, effect too high on screen
        elseif cameraPitch < 0 and screenY < screenH * 0.2 then
            return true  -- Looking down, effect too low on screen
        end
    end

    return false  -- Not culled
end

-- Calculate angle from camera position to effect
function PerformanceOptimizer:calculateAngleToPoint(effectX, effectY, cameraAngle)
    -- Approximate angle based on hex offset
    local dx = effectX  -- Hex x coordinate
    local dy = effectY  -- Hex y coordinate

    -- Convert to radians (hex grid approximation)
    local angle = math.atan2(dy, dx)
    return angle
end

-- Determine LOD level based on distance
function PerformanceOptimizer:calculateLODLevel(distance)
    if distance < LOD_DISTANCE_NEAR then
        return 3  -- LOD 3: Full detail
    elseif distance < LOD_DISTANCE_FAR then
        return 2  -- LOD 2: Medium detail
    elseif distance < LOD_DISTANCE_ULTRA_FAR then
        return 1  -- LOD 1: Low detail
    else
        return 0  -- LOD 0: Minimal/off-screen
    end
end

-- Apply LOD-based scale reduction
function PerformanceOptimizer:calculateLODScale(lodLevel, baseScale)
    local scales = {
        [0] = 0.0,   -- Not rendered
        [1] = 0.4,   -- Ultra far: 40% size
        [2] = 0.7,   -- Far: 70% size
        [3] = 1.0    -- Near: Full size
    }

    return (scales[lodLevel] or 1.0) * baseScale
end

-- Apply LOD-based opacity reduction
function PerformanceOptimizer:calculateLODOpacity(lodLevel, baseOpacity)
    local opacities = {
        [0] = 0.0,   -- Not rendered
        [1] = 0.3,   -- Ultra far: 30% opacity
        [2] = 0.7,   -- Far: 70% opacity
        [3] = 1.0    -- Near: Full opacity
    }

    return (opacities[lodLevel] or 1.0) * baseOpacity
end

-- Apply LOD-based frame skipping (reduce animation updates)
function PerformanceOptimizer:shouldUpdateFrame(lodLevel, time)
    -- LOD 3: Update every frame (no skip)
    -- LOD 2: Update every 2nd frame (skip odd frames)
    -- LOD 1: Update every 4th frame (reduce animation smoothness)
    -- LOD 0: Don't update (not visible)

    local frameSets = {
        [0] = 0,     -- Not rendered
        [1] = 4,     -- Update every 4th frame
        [2] = 2,     -- Update every 2nd frame
        [3] = 1      -- Update every frame
    }

    local frameSet = frameSets[lodLevel] or 1

    if frameSet == 0 then
        return false
    end

    -- Simplified frame counting: use time-based modulo
    local frame = math.floor(time * 60) % frameSet  -- 60 FPS baseline
    return frame == 0
end

-- Cull and optimize effects list
-- Returns optimized effects list with culled items returned to pool
function PerformanceOptimizer:optimizeEffects(effects, cameraAngle, cameraPitch, cameraX, cameraY, cameraZ, hexRaycaster, screenW, screenH)
    local optimized = {}
    self.stats.effectsRendered = 0
    self.stats.effectsCulled = 0

    for i, effect in ipairs(effects) do
        if effect and effect.active then
            -- Check frustum culling
            if self:isBehindFrustum(effect.x, effect.y, effect.screenX, effect.screenY, cameraAngle, cameraPitch, effect.distance) then
                self.stats.effectsCulled = self.stats.effectsCulled + 1
                -- Don't add to optimized list (effectively culled)
            else
                -- Calculate LOD
                effect.lodLevel = self:calculateLODLevel(effect.distance)

                -- Apply LOD scaling
                effect.scale = self:calculateLODScale(effect.lodLevel, effect.scale or 1)
                effect.opacity = self:calculateLODOpacity(effect.lodLevel, effect.opacity or 1)

                table.insert(optimized, effect)
                self.stats.effectsRendered = self.stats.effectsRendered + 1
            end
        end
    end

    self.stats.lodLevel = math.floor(self.stats.effectsRendered > 0 and
                                     (self.stats.effectsRendered / (#effects + 1) * 100) or 0)

    return optimized
end

-- Get performance statistics
function PerformanceOptimizer:getStats()
    return {
        effectsRendered = self.stats.effectsRendered,
        effectsCulled = self.stats.effectsCulled,
        cullingRatio = self.stats.effectsCulled / math.max(1, self.stats.effectsRendered + self.stats.effectsCulled),
        poolActive = #self.effectPool.active,
        poolInactive = #self.effectPool.inactive,
        poolUtilization = #self.effectPool.active / (#self.effectPool.active + #self.effectPool.inactive),
        frameTime = self.stats.frameTime,
        gcPressure = self.stats.gcPressure
    }
end

-- Debug visualization of frustum
function PerformanceOptimizer:drawFrustumDebug(cameraAngle, cameraPitch)
    love.graphics.setColor(1, 1, 0, 0.3)  -- Yellow, semi-transparent

    -- Draw FOV arc on screen
    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() / 2
    local radius = 100

    -- Draw frustum bounds (simplified)
    local leftAngle = cameraAngle - self.fovRadians
    local rightAngle = cameraAngle + self.fovRadians

    -- Draw sector
    love.graphics.arc("line", centerX, centerY, radius, leftAngle, rightAngle, 32)

    -- Draw bounds lines
    love.graphics.line(centerX, centerY,
                      centerX + math.cos(leftAngle) * radius,
                      centerY + math.sin(leftAngle) * radius)
    love.graphics.line(centerX, centerY,
                      centerX + math.cos(rightAngle) * radius,
                      centerY + math.sin(rightAngle) * radius)

    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw pool statistics
function PerformanceOptimizer:drawPoolStats(x, y)
    local stats = self:getStats()

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.printf("PERF: R=" .. stats.effectsRendered ..
                         " C=" .. stats.effectsCulled ..
                         " Pool=" .. stats.poolActive .. "/" ..
                         (stats.poolActive + stats.poolInactive), x, y, 400, "left")
    love.graphics.setColor(1, 1, 1, 1)
end

return PerformanceOptimizer
