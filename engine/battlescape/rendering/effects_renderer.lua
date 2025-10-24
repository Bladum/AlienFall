-- 3D Effects Renderer for Fire, Smoke, and Objects
-- Renders animated billboard effects and static objects in first-person view
-- Integrates with BillboardRenderer for proper z-sorting and layering
-- Phase 5: Integrated with PerformanceOptimizer for frustum culling and LOD

local EffectsRenderer = {}
local PerformanceOptimizer = require("battlescape.rendering.performance_optimizer")

-- Effect types
EffectsRenderer.EFFECT_FIRE = "fire"
EffectsRenderer.EFFECT_SMOKE = "smoke"
EffectsRenderer.EFFECT_EXPLOSION = "explosion"
EffectsRenderer.OBJECT_TREE = "tree"
EffectsRenderer.OBJECT_TABLE = "table"
EffectsRenderer.OBJECT_FENCE = "fence"

function EffectsRenderer.new()
    local self = {}
    self.effects = {}  -- Active effects
    self.objects = {}  -- Static objects (trees, tables, etc)
    self.optimizer = PerformanceOptimizer.new()  -- Performance optimization (Phase 5)
    self.optimizedEffects = {}  -- Cached optimized list

    return setmetatable(self, { __index = EffectsRenderer })
end

-- Add fire effect at position
-- Args:
--   x, y: hex coordinates
--   intensity: fire intensity (0-1)
--   duration: how long fire burns (in turns or seconds)
--   cameraX, cameraY, cameraZ: camera position
--   cameraAngle, cameraPitch: camera orientation
--   hexRaycaster: for projection
--   screenW, screenH: viewport dimensions
function EffectsRenderer:addFire(x, y, intensity, duration, cameraX, cameraY, cameraZ, cameraAngle, cameraPitch, hexRaycaster, screenW, screenH)
    local BillboardRenderer = require("battlescape.rendering.billboard_renderer")

    -- Project to screen space
    local screenX, screenY, distance, visible = self:project3DToScreen(
        x, y, 0.3,  -- fire sits above ground
        cameraX, cameraY, cameraZ,
        cameraAngle, cameraPitch,
        hexRaycaster, screenW, screenH
    )

    if not visible then
        return
    end

    -- Fire animation frames (4 frames for flickering)
    local frameIndex = math.floor((love.timer.getTime() * 4) % 4) + 1

    local fire = {
        type = EffectsRenderer.EFFECT_FIRE,
        x = x,
        y = y,
        screenX = screenX,
        screenY = screenY,
        distance = distance,
        intensity = intensity,
        duration = duration,
        createdAt = love.timer.getTime(),
        frameIndex = frameIndex,
        opacity = intensity,
        scale = 1.0 + (intensity * 0.5)
    }

    table.insert(self.effects, fire)
    return fire
end

-- Add smoke effect at position
-- Args:
--   x, y: hex coordinates
--   density: smoke density (0-1)
--   duration: how long smoke persists
--   cameraX, cameraY, cameraZ: camera position
--   cameraAngle, cameraPitch: camera orientation
--   hexRaycaster: for projection
--   screenW, screenH: viewport dimensions
function EffectsRenderer:addSmoke(x, y, density, duration, cameraX, cameraY, cameraZ, cameraAngle, cameraPitch, hexRaycaster, screenW, screenH)
    -- Project to screen space
    local screenX, screenY, distance, visible = self:project3DToScreen(
        x, y, 0.6,  -- smoke floats above ground
        cameraX, cameraY, cameraZ,
        cameraAngle, cameraPitch,
        hexRaycaster, screenW, screenH
    )

    if not visible then
        return
    end

    local smoke = {
        type = EffectsRenderer.EFFECT_SMOKE,
        x = x,
        y = y,
        screenX = screenX,
        screenY = screenY,
        distance = distance,
        density = density,
        duration = duration,
        createdAt = love.timer.getTime(),
        opacity = density * 0.5,  -- Semi-transparent
        scale = 1.5 + (density * 0.5)
    }

    table.insert(self.effects, smoke)
    return smoke
end

-- Add explosion effect at position
-- Args:
--   x, y: hex coordinates
--   radius: explosion radius
--   damage: damage amount (for visual intensity)
--   cameraX, cameraY, cameraZ: camera position
--   cameraAngle, cameraPitch: camera orientation
--   hexRaycaster: for projection
--   screenW, screenH: viewport dimensions
function EffectsRenderer:addExplosion(x, y, radius, damage, cameraX, cameraY, cameraZ, cameraAngle, cameraPitch, hexRaycaster, screenW, screenH)
    -- Project to screen space
    local screenX, screenY, distance, visible = self:project3DToScreen(
        x, y, 0.5,
        cameraX, cameraY, cameraZ,
        cameraAngle, cameraPitch,
        hexRaycaster, screenW, screenH
    )

    if not visible then
        return
    end

    local explosion = {
        type = EffectsRenderer.EFFECT_EXPLOSION,
        x = x,
        y = y,
        screenX = screenX,
        screenY = screenY,
        distance = distance,
        radius = radius,
        damage = damage,
        createdAt = love.timer.getTime(),
        duration = 0.5,  -- Short explosion duration
        frameIndex = 1,
        maxFrames = 8,
        scale = radius * 2.0,
        opacity = 1.0
    }

    table.insert(self.effects, explosion)
    return explosion
end

-- Add static object at position
-- Args:
--   objectType: OBJECT_TREE, OBJECT_TABLE, OBJECT_FENCE
--   x, y: hex coordinates
--   blocking: whether object blocks movement
--   losBlocking: whether object blocks line of sight
--   cameraX, cameraY, cameraZ: camera position
--   cameraAngle, cameraPitch: camera orientation
--   hexRaycaster: for projection
--   screenW, screenH: viewport dimensions
function EffectsRenderer:addObject(objectType, x, y, blocking, losBlocking, cameraX, cameraY, cameraZ, cameraAngle, cameraPitch, hexRaycaster, screenW, screenH)
    -- Project to screen space
    local zHeight = 0.5  -- Objects sit on ground
    local screenX, screenY, distance, visible = self:project3DToScreen(
        x, y, zHeight,
        cameraX, cameraY, cameraZ,
        cameraAngle, cameraPitch,
        hexRaycaster, screenW, screenH
    )

    if not visible then
        return
    end

    -- Get object size and color
    local size, color = self:getObjectProperties(objectType)

    local object = {
        type = objectType,
        x = x,
        y = y,
        screenX = screenX,
        screenY = screenY,
        distance = distance,
        size = size,
        color = color,
        blocking = blocking or false,
        losBlocking = losBlocking or false,
        opacity = 1.0
    }

    table.insert(self.objects, object)
    return object
end

-- Get object properties (size and color)
function EffectsRenderer:getObjectProperties(objectType)
    if objectType == EffectsRenderer.OBJECT_TREE then
        return 2.0, {0.2, 0.6, 0.2}  -- Green
    elseif objectType == EffectsRenderer.OBJECT_TABLE then
        return 1.0, {0.6, 0.4, 0.2}  -- Brown
    elseif objectType == EffectsRenderer.OBJECT_FENCE then
        return 1.5, {0.7, 0.7, 0.7}  -- Gray
    else
        return 1.0, {0.5, 0.5, 0.5}  -- Gray (unknown)
    end
end

-- Project 3D position to screen (shared with BillboardRenderer)
function EffectsRenderer:project3DToScreen(unitX, unitY, unitZ, cameraX, cameraY, cameraZ, cameraAngle, cameraPitch, hexRaycaster, screenW, screenH)
    -- Calculate relative position
    local relX = unitX - cameraX
    local relY = unitY - cameraY
    local relZ = unitZ - cameraZ

    -- Calculate distance from camera
    local distance = math.sqrt(relX * relX + relY * relY)

    -- Early exit: behind or too far from camera
    if distance < 0.1 then
        return screenW / 2, screenH / 2, 0, false
    end
    if distance > 20 then
        return screenW / 2, screenH / 2, distance, false
    end

    -- Calculate angle to object from camera
    local angleToUnit = math.atan2(relY, relX)
    local cameraDelta = angleToUnit - math.rad(cameraAngle)

    -- Wrap angle
    while cameraDelta > math.pi do cameraDelta = cameraDelta - 2 * math.pi end
    while cameraDelta < -math.pi do cameraDelta = cameraDelta + 2 * math.pi end

    -- FOV check (90° total)
    local fovHalf = math.rad(45)
    if math.abs(cameraDelta) > fovHalf then
        return screenW / 2, screenH / 2, distance, false
    end

    -- Project to screen
    local screenX = screenW / 2 + math.sin(cameraDelta) * (screenW / 2)
    local verticalAngle = cameraPitch + math.atan2(relZ, distance)
    local screenY = screenH / 2 - math.sin(verticalAngle) * (screenH / 2)

    local onScreen = (screenX >= 0 and screenX <= screenW and screenY >= 0 and screenY <= screenH)

    return screenX, screenY, distance, true
end

-- Update effects (animations, duration, etc)
function EffectsRenderer:update(dt)
    local currentTime = love.timer.getTime()
    local toRemove = {}

    for i, effect in ipairs(self.effects) do
        local elapsed = currentTime - effect.createdAt

        -- Check if effect has expired
        if elapsed > effect.duration then
            table.insert(toRemove, i)
        else
            -- Update animation frame
            if effect.type == EffectsRenderer.EFFECT_FIRE then
                effect.frameIndex = math.floor((elapsed * 4) % 4) + 1
                -- Fade intensity
                effect.opacity = effect.intensity * (1 - (elapsed / effect.duration))
            elseif effect.type == EffectsRenderer.EFFECT_SMOKE then
                -- Fade and rise
                effect.opacity = effect.density * 0.5 * (1 - (elapsed / effect.duration))
                effect.screenY = effect.screenY - (dt * 10)  -- Rise slowly
            elseif effect.type == EffectsRenderer.EFFECT_EXPLOSION then
                effect.frameIndex = math.floor((elapsed / effect.duration) * effect.maxFrames) + 1
                effect.opacity = 1.0 - (elapsed / effect.duration)
                effect.scale = effect.radius * 2.0 * (1 + (elapsed / effect.duration))
            end
        end
    end

    -- Remove expired effects
    for i = #toRemove, 1, -1 do
        table.remove(self.effects, toRemove[i])
    end
end

-- Sort effects and objects by distance for proper rendering
function EffectsRenderer:sortByDistance()
    table.sort(self.effects, function(a, b)
        return a.distance > b.distance
    end)

    table.sort(self.objects, function(a, b)
        return a.distance > b.distance
    end)
end

-- Draw all effects with optimization
-- Args:
--   cameraAngle, cameraPitch: camera viewing angles (for frustum culling)
--   screenW, screenH: viewport dimensions
-- Phase 5: Uses frustum culling and LOD for performance
function EffectsRenderer:drawEffectsOptimized(cameraAngle, cameraPitch, screenW, screenH)
    love.graphics.push()

    self:sortByDistance()

    -- Perform frustum culling and LOD optimization
    self.optimizedEffects = self.optimizer:optimizeEffects(
        self.effects, cameraAngle, cameraPitch, 0, 0, 0, nil, screenW, screenH
    )

    -- Draw objects first (background)
    for _, object in ipairs(self.objects) do
        self:drawObject(object)
    end

    -- Draw optimized effects (culled + LOD applied)
    for _, effect in ipairs(self.optimizedEffects) do
        if effect.lodLevel > 0 then  -- Only draw if not culled (LOD 0)
            self:drawEffect(effect)
        end
    end

    love.graphics.pop()
end

-- Draw all effects (legacy method without optimization)
function EffectsRenderer:drawEffects()
    love.graphics.push()

    self:sortByDistance()

    -- Draw objects first (background)
    for _, object in ipairs(self.objects) do
        self:drawObject(object)
    end

    -- Draw effects (fire, smoke, explosions)
    for _, effect in ipairs(self.effects) do
        self:drawEffect(effect)
    end

    love.graphics.pop()
end

-- Draw single effect
function EffectsRenderer:drawEffect(effect)
    love.graphics.setColor(1, 1, 1, effect.opacity)

    if effect.type == EffectsRenderer.EFFECT_FIRE then
        self:drawFire(effect)
    elseif effect.type == EffectsRenderer.EFFECT_SMOKE then
        self:drawSmoke(effect)
    elseif effect.type == EffectsRenderer.EFFECT_EXPLOSION then
        self:drawExplosion(effect)
    end
end

-- Draw fire effect
function EffectsRenderer:drawFire(effect)
    -- Fire colors: yellow/orange/red based on frame
    local colors = {
        {1, 1, 0},      -- Yellow (frame 1)
        {1, 0.8, 0},    -- Orange (frame 2)
        {1, 0.6, 0},    -- Dark orange (frame 3)
        {1, 0.4, 0}     -- Red-orange (frame 4)
    }

    local color = colors[effect.frameIndex] or {1, 1, 0}
    love.graphics.setColor(color[1], color[2], color[3], effect.opacity)

    love.graphics.rectangle("fill",
        effect.screenX - 12 * effect.scale,
        effect.screenY - 12 * effect.scale,
        24 * effect.scale,
        24 * effect.scale)
end

-- Draw smoke effect
function EffectsRenderer:drawSmoke(effect)
    love.graphics.setColor(0.7, 0.7, 0.7, effect.opacity)

    -- Semi-transparent circles for smoke
    love.graphics.circle("fill",
        effect.screenX,
        effect.screenY,
        12 * effect.scale)
end

-- Draw explosion effect
function EffectsRenderer:drawExplosion(effect)
    -- Explosion colors fade from red/orange to white
    local progress = effect.frameIndex / effect.maxFrames
    local r = 1
    local g = progress
    local b = 0

    love.graphics.setColor(r, g, b, effect.opacity)
    love.graphics.circle("fill",
        effect.screenX,
        effect.screenY,
        effect.scale)
end

-- Draw single object
function EffectsRenderer:drawObject(object)
    love.graphics.setColor(object.color[1], object.color[2], object.color[3], object.opacity)

    -- Draw object as rectangle
    love.graphics.rectangle("fill",
        object.screenX - 12 * object.size,
        object.screenY - 12 * object.size,
        24 * object.size,
        24 * object.size)

    -- Draw selection outline if blocking
    if object.blocking then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("line",
            object.screenX - 12 * object.size,
            object.screenY - 12 * object.size,
            24 * object.size,
            24 * object.size)
    end
end

-- Clear all effects
function EffectsRenderer:clear()
    self.effects = {}
end

-- Clear all objects
function EffectsRenderer:clearObjects()
    self.objects = {}
end

-- Get effects at hex position (for damage calculations)
-- Args:
--   x, y: hex coordinates
-- Returns:
--   table of effects at that position
function EffectsRenderer:getEffectsAt(x, y)
    local result = {}
    for _, effect in ipairs(self.effects) do
        if effect.x == x and effect.y == y then
            table.insert(result, effect)
        end
    end
    return result
end

-- Check if object blocks movement at position
function EffectsRenderer:isBlocked(x, y)
    for _, object in ipairs(self.objects) do
        if object.x == x and object.y == y and object.blocking then
            return true
        end
    end
    return false
end

-- Check if object blocks LOS at position
function EffectsRenderer:blocksLOS(x, y)
    for _, object in ipairs(self.objects) do
        if object.x == x and object.y == y and object.losBlocking then
            return true
        end
    end
    return false
end

-- Get visibility modifier for effect at position based on LOS
-- Args:
--   x, y: hex coordinates of effect
--   losSystem: LOS system for visibility checks
--   team: viewing team
-- Returns:
--   opacity multiplier (1.0 = fully visible, 0.5 = partially visible, 0 = hidden)
function EffectsRenderer:getVisibilityModifier(x, y, losSystem, team)
    if not losSystem or not team then
        return 1.0  -- No LOS system, assume visible
    end

    local visibility = losSystem:getVisibility(team, x, y)
    if visibility == "visible" then
        return 1.0
    elseif visibility == "partially" then
        return 0.6  -- 60% opacity for partial visibility
    else
        return 0.0  -- Hidden from view
    end
end

-- Get all visible effects within viewport
-- Args:
--   losSystem: LOS system for visibility
--   viewerTeam: team doing viewing
--   cameraPosQ, cameraPosR: camera hex position
-- Returns:
--   table of visible effects
function EffectsRenderer:getVisibleEffects(losSystem, viewerTeam, cameraPosQ, cameraPosR)
    local visible = {}

    for _, effect in ipairs(self.effects) do
        if effect and effect.opacity and effect.opacity > 0 then
            local modifier = self:getVisibilityModifier(effect.x, effect.y, losSystem, viewerTeam)
            if modifier > 0 then
                table.insert(visible, {
                    effect = effect,
                    modifier = modifier
                })
            end
        end
    end

    return visible
end

return EffectsRenderer
