--- Example usage of ObjectPool for common game objects
--
-- Demonstrates how to use the ObjectPool for projectiles, particles,
-- and UI elements.
--
-- @module examples.object_pool_usage

local ObjectPool = require("utils.ObjectPool")

--- Example 1: Projectile Pool
local function createProjectilePool()
    return ObjectPool:new({
        -- Factory: Create new projectile
        factory = function()
            return {
                x = 0,
                y = 0,
                vx = 0,
                vy = 0,
                active = false,
                lifetime = 0,
                damage = 0,
                owner = nil
            }
        end,
        
        -- Reset: Clear projectile state
        reset = function(projectile)
            projectile.x = 0
            projectile.y = 0
            projectile.vx = 0
            projectile.vy = 0
            projectile.active = false
            projectile.lifetime = 0
            projectile.damage = 0
            projectile.owner = nil
        end,
        
        -- Validate: Check projectile is valid
        validate = function(projectile)
            return type(projectile) == "table" and 
                   projectile.x ~= nil and 
                   projectile.y ~= nil
        end,
        
        initialSize = 20,
        maxSize = 200,
        autoExpand = true
    })
end

--- Example 2: Particle Pool
local function createParticlePool()
    return ObjectPool:new({
        factory = function()
            return {
                x = 0,
                y = 0,
                vx = 0,
                vy = 0,
                size = 1,
                color = {1, 1, 1, 1},
                lifetime = 0,
                maxLifetime = 1.0
            }
        end,
        
        reset = function(particle)
            particle.x = 0
            particle.y = 0
            particle.vx = 0
            particle.vy = 0
            particle.size = 1
            particle.color = {1, 1, 1, 1}
            particle.lifetime = 0
            particle.maxLifetime = 1.0
        end,
        
        validate = function(particle)
            return type(particle) == "table"
        end,
        
        initialSize = 50,
        maxSize = 500,
        autoExpand = true
    })
end

--- Example 3: UI Tooltip Pool
local function createTooltipPool()
    return ObjectPool:new({
        factory = function()
            local Tooltip = require("widgets.Tooltip")
            return Tooltip:new({
                text = "",
                x = 0,
                y = 0
            })
        end,
        
        reset = function(tooltip)
            tooltip:hide()
            tooltip:setText("")
            tooltip:setPosition(0, 0)
        end,
        
        validate = function(tooltip)
            return tooltip and type(tooltip.draw) == "function"
        end,
        
        initialSize = 5,
        maxSize = 20,
        autoExpand = false  -- Limited tooltips
    })
end

--- Example Usage in Game System
local ProjectileSystem = {}

function ProjectileSystem:initialize()
    self.projectilePool = createProjectilePool()
    self.activeProjectiles = {}
end

function ProjectileSystem:fireProjectile(x, y, vx, vy, damage, owner)
    -- Acquire projectile from pool
    local projectile = self.projectilePool:acquire()
    
    if not projectile then
        print("Warning: Projectile pool exhausted!")
        return nil
    end
    
    -- Initialize projectile
    projectile.x = x
    projectile.y = y
    projectile.vx = vx
    projectile.vy = vy
    projectile.active = true
    projectile.lifetime = 0
    projectile.damage = damage
    projectile.owner = owner
    
    table.insert(self.activeProjectiles, projectile)
    
    return projectile
end

function ProjectileSystem:update(dt)
    -- Update all active projectiles
    for i = #self.activeProjectiles, 1, -1 do
        local proj = self.activeProjectiles[i]
        
        proj.x = proj.x + proj.vx * dt
        proj.y = proj.y + proj.vy * dt
        proj.lifetime = proj.lifetime + dt
        
        -- Remove expired projectiles
        if proj.lifetime > 5.0 or not proj.active then
            self.projectilePool:release(proj)
            table.remove(self.activeProjectiles, i)
        end
    end
end

function ProjectileSystem:draw()
    for _, proj in ipairs(self.activeProjectiles) do
        love.graphics.circle("fill", proj.x, proj.y, 3)
    end
end

function ProjectileSystem:getPoolStats()
    return self.projectilePool:getStats()
end

--- Example: Using ObjectPool in ParticleSystem
local ParticleSystem = {}

function ParticleSystem:initialize()
    self.particlePool = createParticlePool()
    self.particles = {}
end

function ParticleSystem:emit(x, y, count, config)
    config = config or {}
    
    for i = 1, count do
        local particle = self.particlePool:acquire()
        
        if particle then
            -- Initialize particle
            particle.x = x
            particle.y = y
            
            -- Random velocity
            local angle = math.random() * math.pi * 2
            local speed = config.speed or 100
            particle.vx = math.cos(angle) * speed
            particle.vy = math.sin(angle) * speed
            
            particle.size = config.size or 2
            particle.color = config.color or {1, 1, 1, 1}
            particle.lifetime = 0
            particle.maxLifetime = config.lifetime or 1.0
            
            table.insert(self.particles, particle)
        end
    end
end

function ParticleSystem:update(dt)
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.lifetime = p.lifetime + dt
        
        -- Fade out
        p.color[4] = 1.0 - (p.lifetime / p.maxLifetime)
        
        -- Remove expired particles
        if p.lifetime >= p.maxLifetime then
            self.particlePool:release(p)
            table.remove(self.particles, i)
        end
    end
end

function ParticleSystem:draw()
    for _, p in ipairs(self.particles) do
        love.graphics.setColor(p.color)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

--- Example: Performance monitoring
local function monitorPoolPerformance(pool, name)
    local stats = pool:getStats()
    
    print(string.format("\n%s Pool Statistics:", name))
    print(string.format("  Total Size: %d", stats.totalSize))
    print(string.format("  Available: %d", stats.available))
    print(string.format("  In Use: %d", stats.inUse))
    print(string.format("  Utilization: %.1f%%", stats.utilization * 100))
    print(string.format("  Peak Usage: %d", stats.peakUsage))
    print(string.format("  Total Created: %d", stats.created))
    print(string.format("  Total Acquired: %d", stats.acquired))
    print(string.format("  Total Released: %d", stats.released))
    print(string.format("  Pool Expansions: %d", stats.expanded))
end

return {
    createProjectilePool = createProjectilePool,
    createParticlePool = createParticlePool,
    createTooltipPool = createTooltipPool,
    ProjectileSystem = ProjectileSystem,
    ParticleSystem = ParticleSystem,
    monitorPoolPerformance = monitorPoolPerformance
}
