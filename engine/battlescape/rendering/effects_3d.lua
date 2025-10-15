---Effects3D - 3D Visual Effects Renderer
---
---Renders fire, smoke, explosions, and other visual effects in 3D for the first-person
---battlescape. Integrates with existing FireSystem and SmokeSystem to provide 3D visual
---representation of combat effects.
---
---Features:
---  - Fire rendering (3D flames on tiles)
---  - Smoke rendering (3D particle clouds)
---  - Explosion effects (expanding spheres)
---  - Muzzle flashes (weapon fire)
---  - Hit effects (bullet impacts)
---  - Particle systems for each effect type
---
---Effect Types:
---  - Explosions: Expanding sphere with particles
---  - Muzzle flashes: Brief bright flash at gun barrel
---  - Hit effects: Sparks/blood at impact point
---  - Fire: Flickering flames on burning tiles
---  - Smoke: Drifting particle clouds
---
---Rendering:
---  - Billboard particles (always face camera)
---  - Alpha blending for transparency
---  - Depth sorting for proper layering
---  - Color gradients for realism
---
---Key Exports:
---  - Effects3D.new(): Creates effects renderer
---  - addExplosion(x, y, z, radius): Spawns explosion effect
---  - addMuzzleFlash(x, y, z, direction): Spawns muzzle flash
---  - addHitEffect(x, y, z, type): Spawns hit effect
---  - update(dt): Updates active effects
---  - draw(camera): Renders all effects
---  - clear(): Removes all effects
---
---Dependencies:
---  - None (standalone renderer)
---
---@module battlescape.rendering.effects_3d
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Effects3D = require("battlescape.rendering.effects_3d")
---  local effects = Effects3D.new()
---  effects:addExplosion(10, 0, 15, 5)
---  effects:update(dt)
---  effects:draw(camera)
---
---@see battlescape.effects.fire_system For fire logic
---@see battlescape.effects.smoke_system For smoke logic

-- 3D Effects Rendering System for Battlescape
-- Renders fire, smoke, explosions, and other visual effects in 3D
-- Integrates with existing FireSystem and SmokeSystem

local Effects3D = {}
Effects3D.__index = Effects3D

--- Create new 3D effects renderer
function Effects3D.new()
    local self = setmetatable({}, Effects3D)
    
    -- Active effects
    self.explosions = {}
    self.muzzleFlashes = {}
    self.hitEffects = {}
    
    -- Animation settings
    self.settings = {
        fireAnimFPS = 10,       -- Fire animation speed
        smokeAnimFPS = 5,        -- Smoke animation speed
        explosionDuration = 0.5, -- Explosion effect duration
        flashDuration = 0.1,     -- Muzzle flash duration
        hitDuration = 0.3,       -- Hit effect duration
    }
    
    print("[Effects3D] Initialized")
    return self
end

--- Update effects (remove expired ones)
---@param dt number Delta time
function Effects3D:update(dt)
    local time = love.timer.getTime()
    
    -- Remove expired explosions
    for i = #self.explosions, 1, -1 do
        if time - self.explosions[i].startTime > self.settings.explosionDuration then
            table.remove(self.explosions, i)
        end
    end
    
    -- Remove expired muzzle flashes
    for i = #self.muzzleFlashes, 1, -1 do
        if time - self.muzzleFlashes[i].startTime > self.settings.flashDuration then
            table.remove(self.muzzleFlashes, i)
        end
    end
    
    -- Remove expired hit effects
    for i = #self.hitEffects, 1, -1 do
        if time - self.hitEffects[i].startTime > self.settings.hitDuration then
            table.remove(self.hitEffects, i)
        end
    end
end

--- Render fire effects
---@param fireSystem table FireSystem instance
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function Effects3D:renderFire(fireSystem, billboard, camera, assets)
    local fires = fireSystem:getAllFires()
    local time = love.timer.getTime()
    
    for _, fire in ipairs(fires) do
        -- Get animated frame
        local frame = self:getFireFrame(time)
        local sprite = assets:get("effects", "fire" .. frame)
        
        if sprite then
            -- Fire rises from ground
            billboard:add(fire.x, 0.6, fire.y, sprite, {
                width = 1.0,
                height = 1.2,
                alpha = 1.0,
                emissive = true,  -- Fire glows in dark
                color = {r = 1.0, g = 0.8, b = 0.3}  -- Orange glow
            })
        end
    end
end

--- Render smoke effects
---@param smokeSystem table SmokeSystem instance
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function Effects3D:renderSmoke(smokeSystem, billboard, camera, assets)
    local smokes = smokeSystem:getAllSmoke()
    local time = love.timer.getTime()
    
    for _, smoke in ipairs(smokes) do
        -- Get animated frame
        local frame = self:getSmokeFrame(time)
        local sprite = assets:get("effects", "smoke" .. frame)
        
        if sprite then
            -- Smoke rises over time
            local age = time - smoke.startTime
            local yOffset = age * 0.5  -- Rise speed
            local alpha = math.max(0.1, 1.0 - (age / smoke.duration))
            
            -- Render semi-transparent
            billboard:add(smoke.x, 0.5 + yOffset, smoke.y, sprite, {
                width = 1.5,
                height = 1.5,
                alpha = alpha * 0.6,  -- Semi-transparent
                emissive = false,
                color = {r = 0.7, g = 0.7, b = 0.7}  -- Gray smoke
            })
        end
    end
end

--- Render explosion effects
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function Effects3D:renderExplosions(billboard, camera, assets)
    local time = love.timer.getTime()
    
    for _, explosion in ipairs(self.explosions) do
        local age = time - explosion.startTime
        local progress = age / self.settings.explosionDuration
        
        -- Animate explosion: expand and fade
        local frame = math.floor(progress * 4) + 1  -- 4 frames
        local sprite = assets:get("effects", "explosion" .. frame)
        
        if sprite then
            local scale = 1.0 + progress * 2.0  -- Expand
            local alpha = 1.0 - progress        -- Fade
            
            billboard:add(explosion.x, 0.5, explosion.y, sprite, {
                width = scale,
                height = scale,
                alpha = alpha,
                emissive = true,
                color = {r = 1.0, g = 0.6, b = 0.2}  -- Orange explosion
            })
        end
    end
end

--- Render muzzle flashes
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function Effects3D:renderMuzzleFlashes(billboard, camera, assets)
    local time = love.timer.getTime()
    
    for _, flash in ipairs(self.muzzleFlashes) do
        local age = time - flash.startTime
        local alpha = 1.0 - (age / self.settings.flashDuration)
        
        local sprite = assets:get("effects", "muzzle_flash")
        if sprite then
            billboard:add(flash.x, 0.5, flash.y, sprite, {
                width = 0.8,
                height = 0.8,
                alpha = alpha,
                emissive = true,
                color = {r = 1.0, g = 1.0, b = 0.8}  -- Bright yellow flash
            })
        end
    end
end

--- Render hit effects
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function Effects3D:renderHitEffects(billboard, camera, assets)
    local time = love.timer.getTime()
    
    for _, hit in ipairs(self.hitEffects) do
        local age = time - hit.startTime
        local alpha = 1.0 - (age / self.settings.hitDuration)
        
        local sprite = assets:get("effects", hit.type)  -- "hit_blood" or "hit_spark"
        if sprite then
            billboard:add(hit.x, 0.5, hit.y, sprite, {
                width = 0.6,
                height = 0.6,
                alpha = alpha,
                emissive = false,
                color = hit.color or {r = 1, g = 0, b = 0}
            })
        end
    end
end

--- Render all effects
---@param fireSystem table FireSystem instance
---@param smokeSystem table SmokeSystem instance
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function Effects3D:renderAll(fireSystem, smokeSystem, billboard, camera, assets)
    self:renderFire(fireSystem, billboard, camera, assets)
    self:renderSmoke(smokeSystem, billboard, camera, assets)
    self:renderExplosions(billboard, camera, assets)
    self:renderMuzzleFlashes(billboard, camera, assets)
    self:renderHitEffects(billboard, camera, assets)
end

--- Get fire animation frame
---@param time number Current time
---@return number Frame (1-4)
function Effects3D:getFireFrame(time)
    local frameCount = 4
    local frame = math.floor(time * self.settings.fireAnimFPS) % frameCount + 1
    return frame
end

--- Get smoke animation frame
---@param time number Current time
---@return number Frame (1-3)
function Effects3D:getSmokeFrame(time)
    local frameCount = 3
    local frame = math.floor(time * self.settings.smokeAnimFPS) % frameCount + 1
    return frame
end

--- Play explosion effect
---@param x number World X
---@param y number World Y
---@param radius number Explosion radius (optional)
function Effects3D:playExplosion(x, y, radius)
    table.insert(self.explosions, {
        x = x,
        y = y,
        radius = radius or 1.0,
        startTime = love.timer.getTime(),
    })
    print("[Effects3D] Explosion at " .. x .. "," .. y)
end

--- Play muzzle flash effect
---@param x number World X
---@param y number World Y
function Effects3D:playMuzzleFlash(x, y)
    table.insert(self.muzzleFlashes, {
        x = x,
        y = y,
        startTime = love.timer.getTime(),
    })
end

--- Play hit effect
---@param x number World X
---@param y number World Y
---@param hitType string "blood" or "spark"
function Effects3D:playHitEffect(x, y, hitType)
    hitType = hitType or "blood"
    
    local color = {r = 1, g = 0, b = 0}  -- Red for blood
    if hitType == "spark" then
        color = {r = 1, g = 1, b = 0}  -- Yellow for sparks (robots)
    end
    
    table.insert(self.hitEffects, {
        x = x,
        y = y,
        type = "hit_" .. hitType,
        color = color,
        startTime = love.timer.getTime(),
    })
end

--- Play miss effect (bullet impact on ground/wall)
---@param x number World X
---@param y number World Y
function Effects3D:playMissEffect(x, y)
    table.insert(self.hitEffects, {
        x = x,
        y = y,
        type = "hit_ground",
        color = {r = 0.7, g = 0.7, b = 0.5},  -- Dust color
        startTime = love.timer.getTime(),
    })
end

--- Clear all effects
function Effects3D:clear()
    self.explosions = {}
    self.muzzleFlashes = {}
    self.hitEffects = {}
end

return Effects3D






















