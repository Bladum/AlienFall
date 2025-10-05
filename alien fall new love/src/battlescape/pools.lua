--- Projectile and Effects Pooling System
--
-- Pre-configured object pools for common game objects to reduce garbage collection.
--
-- @module battlescape.pools

local ObjectPool = require('utils.object_pool')

local Pools = {}

--- Projectile object structure
local Projectile = {
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,
    damage = 0,
    sprite = nil,
    lifetime = 0,
    active = false,
    source_unit = nil,
    target_unit = nil
}

function Projectile:reset()
    self.x = 0
    self.y = 0
    self.vx = 0
    self.vy = 0
    self.damage = 0
    self.sprite = nil
    self.lifetime = 0
    self.active = false
    self.source_unit = nil
    self.target_unit = nil
end

function Projectile:update(dt)
    if not self.active then return end
    
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.lifetime = self.lifetime - dt
    
    if self.lifetime <= 0 then
        self.active = false
    end
end

function Projectile:draw()
    if not self.active or not self.sprite then return end
    love.graphics.draw(self.sprite, self.x, self.y)
end

--- Particle effect object structure
local ParticleEffect = {
    x = 0,
    y = 0,
    effect_type = "explosion",
    particles = {},
    lifetime = 0,
    active = false,
    color = {1, 1, 1, 1}
}

function ParticleEffect:reset()
    self.x = 0
    self.y = 0
    self.effect_type = "explosion"
    self.particles = {}
    self.lifetime = 0
    self.active = false
    self.color = {1, 1, 1, 1}
end

function ParticleEffect:update(dt)
    if not self.active then return end
    
    self.lifetime = self.lifetime - dt
    
    if self.lifetime <= 0 then
        self.active = false
    end
    
    -- Update particles
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt
        
        if p.life <= 0 then
            table.remove(self.particles, i)
        end
    end
end

function ParticleEffect:draw()
    if not self.active then return end
    
    for _, p in ipairs(self.particles) do
        local alpha = p.life / p.max_life
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

--- Temporary data table pool (for calculations, pathfinding, etc.)
local function createTable()
    return {}
end

local function resetTable(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

--- Initialize all pools
function Pools.initialize()
    -- Projectile pool
    Pools.projectiles = ObjectPool:new(
        function()
            local proj = {}
            for k, v in pairs(Projectile) do
                proj[k] = v
            end
            return proj
        end,
        function(proj) proj:reset() end,
        50,   -- Initial size
        200   -- Max size
    )
    
    -- Particle effect pool
    Pools.effects = ObjectPool:new(
        function()
            local effect = {}
            for k, v in pairs(ParticleEffect) do
                effect[k] = v
            end
            return effect
        end,
        function(effect) effect:reset() end,
        30,   -- Initial size
        100   -- Max size
    )
    
    -- Temporary table pool (for pathfinding, calculations)
    Pools.temp_tables = ObjectPool:new(
        createTable,
        resetTable,
        100,  -- Initial size
        500   -- Max size
    )
end

--- Creates a new projectile from the pool
-- @param x number Starting X position
-- @param y number Starting Y position
-- @param target_x number Target X position
-- @param target_y number Target Y position
-- @param speed number Projectile speed
-- @param damage number Damage amount
-- @param sprite love.Image Projectile sprite
-- @return Projectile Pooled projectile object
function Pools.createProjectile(x, y, target_x, target_y, speed, damage, sprite)
    local proj = Pools.projectiles:acquire()
    
    proj.x = x
    proj.y = y
    proj.damage = damage
    proj.sprite = sprite
    proj.active = true
    proj.lifetime = 5.0  -- 5 seconds max
    
    -- Calculate velocity
    local dx = target_x - x
    local dy = target_y - y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance > 0 then
        proj.vx = (dx / distance) * speed
        proj.vy = (dy / distance) * speed
    else
        proj.vx = 0
        proj.vy = 0
    end
    
    return proj
end

--- Creates a particle effect from the pool
-- @param x number X position
-- @param y number Y position
-- @param effect_type string Type of effect ("explosion", "smoke", "blood", etc.)
-- @param color table RGBA color {r, g, b, a}
-- @param particle_count number Number of particles (default: 20)
-- @return ParticleEffect Pooled effect object
function Pools.createEffect(x, y, effect_type, color, particle_count)
    local effect = Pools.effects:acquire()
    
    effect.x = x
    effect.y = y
    effect.effect_type = effect_type or "explosion"
    effect.color = color or {1, 1, 1, 1}
    effect.active = true
    effect.lifetime = 2.0  -- 2 seconds
    effect.particles = {}
    
    particle_count = particle_count or 20
    
    -- Generate particles
    for i = 1, particle_count do
        local angle = (i / particle_count) * math.pi * 2
        local speed = math.random(50, 150)
        
        table.insert(effect.particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            size = math.random(2, 5),
            life = math.random(0.5, 1.5),
            max_life = 1.5
        })
    end
    
    return effect
end

--- Releases a projectile back to the pool
-- @param proj Projectile Projectile to release
function Pools.releaseProjectile(proj)
    proj.active = false
    Pools.projectiles:release(proj)
end

--- Releases an effect back to the pool
-- @param effect ParticleEffect Effect to release
function Pools.releaseEffect(effect)
    effect.active = false
    Pools.effects:release(effect)
end

--- Gets a temporary table for calculations
-- @return table Empty table from pool
function Pools.getTempTable()
    return Pools.temp_tables:acquire()
end

--- Releases a temporary table back to the pool
-- @param tbl table Table to release
function Pools.releaseTempTable(tbl)
    Pools.temp_tables:release(tbl)
end

--- Gets statistics for all pools
-- @return table Statistics for each pool
function Pools.getStats()
    return {
        projectiles = Pools.projectiles and Pools.projectiles:getStats() or {},
        effects = Pools.effects and Pools.effects:getStats() or {},
        temp_tables = Pools.temp_tables and Pools.temp_tables:getStats() or {}
    }
end

--- Releases all objects back to pools (cleanup)
function Pools.releaseAll()
    if Pools.projectiles then Pools.projectiles:releaseAll() end
    if Pools.effects then Pools.effects:releaseAll() end
    if Pools.temp_tables then Pools.temp_tables:releaseAll() end
end

--- Clears all pools (complete cleanup)
function Pools.clear()
    if Pools.projectiles then Pools.projectiles:clear() end
    if Pools.effects then Pools.effects:clear() end
    if Pools.temp_tables then Pools.temp_tables:clear() end
end

return Pools
