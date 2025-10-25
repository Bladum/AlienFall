---CombatFeedback - Visual Combat Resolution Feedback
---
---Displays real-time feedback for combat resolution events. Shows damage numbers,
---hit/miss indicators, critical hit effects, status effects, and combat log. Integrates
---with combat_mechanics.lua to provide player feedback on combat outcomes.
---
---Features:
---  - Floating damage numbers (color coded by damage type)
---  - Hit/Miss indicators with particle effects
---  - Critical hit notifications with special effects
---  - Area damage visualization (explosion radius)
---  - Status effect icons (poison, fire, stun, etc.)
---  - Combat log with scrollable history
---  - Kill feed notifications
---  - Reaction fire indicators
---  - Accuracy feedback (distance, cover, modifiers)
---
---Feedback Types:
---  - Damage: Red numbers, magnitude-scaled size, floating animation
---  - Healing: Green numbers, ascending animation
---  - Critical: Yellow numbers + flash effect, 1.5x size
---  - Miss: "MISS" text in gray, X effect
---  - Resist: "RESIST" in purple (damage reduced by armor)
---  - Block: "BLOCKED" in blue (cover protection)
---  - Status: Icon + duration indicator
---
---Rendering:
---  - Screen-relative positioning (damage floats above unit)
---  - Text fade-out animation (2 second lifespan)
---  - Particle system for impact effects
---  - Z-ordering: Effects below, numbers, UI text above
---
---Key Exports:
---  - CombatFeedback.new(): Creates feedback system
---  - showDamage(x, y, damage, type): Display damage number
---  - showHit(x, y, accuracy, resultType): Show hit/miss feedback
---  - showCritical(x, y, multiplier): Display critical hit
---  - showEffect(x, y, effectType, duration): Status effect icon
---  - showLog(message): Add to combat log
---  - update(dt): Update animations
---  - draw(): Render feedback effects
---
---Dependencies:
---  - battlescape.systems.combat_mechanics: Combat resolution
---  - love.graphics: Rendering
---  - love.timer: Timing for animations
---
---@module battlescape.ui.combat_feedback
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CombatFeedback = require("battlescape.ui.combat_feedback")
---  local feedback = CombatFeedback.new()
---  feedback:showDamage(32, 48, 25, "bullet")
---  feedback:update(dt)
---  feedback:draw()
---
---@see battlescape.systems.combat_mechanics For combat resolution

local CombatFeedback = {}

---@class CombatFeedback
---@field floatingNumbers table Array of active floating damage numbers
---@field effects table Array of active status effects
---@field combatLog table Array of combat log messages
---@field maxLogSize number Maximum log messages to keep
---@field colors table Color definitions for feedback types
---@field particleSystem love.ParticleSystem Optional particle effects
---@field initialized boolean

---Create combat feedback system
---@return CombatFeedback Feedback instance
function CombatFeedback.new()
    local self = setmetatable({}, {__index = CombatFeedback})
    
    self.floatingNumbers = {}
    self.effects = {}
    self.combatLog = {}
    self.maxLogSize = 50
    
    -- Color definitions for different feedback types
    self.colors = {
        damage = {1.0, 0.2, 0.2},           -- Red
        healing = {0.2, 1.0, 0.2},          -- Green
        critical = {1.0, 1.0, 0.0},         -- Yellow
        miss = {0.5, 0.5, 0.5},             -- Gray
        resist = {0.8, 0.2, 0.8},           -- Purple
        block = {0.2, 0.5, 1.0},            -- Blue
        fire = {1.0, 0.5, 0.0},             -- Orange
        poison = {0.6, 1.0, 0.2},           -- Lime
        stun = {1.0, 1.0, 0.2},             -- Yellow
        bleed = {0.8, 0.1, 0.1},            -- Dark red
        log_text = {1.0, 1.0, 1.0},         -- White
        log_highlight = {1.0, 1.0, 0.5},    -- Yellow
    }
    
    -- Optional particle system
    self.particleSystem = nil
    
    self.initialized = true
    
    print("[CombatFeedback] Initialized")
    
    return self
end

---Display floating damage number
---@param x number Screen X position
---@param y number Screen Y position
---@param damage number Damage amount
---@param damageType string Type: "bullet", "fire", "energy", "explosive"
---@param isCritical boolean Whether this is a critical hit
function CombatFeedback:showDamage(x, y, damage, damageType, isCritical)
    damageType = damageType or "bullet"
    
    local color = self.colors.damage
    local scale = 1.0
    
    -- Color code by damage type
    if damageType == "fire" then
        color = self.colors.fire
    elseif damageType == "energy" then
        color = self.colors.critical
    elseif damageType == "explosive" then
        color = {1.0, 0.7, 0.0}  -- Orange-yellow
    elseif damageType == "poison" then
        color = self.colors.poison
    end
    
    -- Scale critical hits
    if isCritical then
        color = self.colors.critical
        scale = 1.5
        damage = math.ceil(damage * 1.5)  -- Critical multiplier
    end
    
    local number = {
        x = x,
        y = y,
        vx = (math.random() - 0.5) * 40,  -- Horizontal spread
        vy = -80,  -- Upward velocity
        value = damage,
        color = color,
        scale = scale,
        lifetime = 2.0,
        age = 0.0,
        isCritical = isCritical
    }
    
    table.insert(self.floatingNumbers, number)
    
    -- Add to log
    self:showLog(string.format("%d %s damage", damage, damageType))
end

---Display hit/miss feedback
---@param x number Screen X position
---@param y number Screen Y position
---@param accuracy number Hit accuracy (0-1)
---@param resultType string "hit", "miss", "graze", "critical"
function CombatFeedback:showHit(x, y, accuracy, resultType)
    resultType = resultType or "hit"
    
    local text = resultType:upper()
    local color = self.colors.miss
    
    if resultType == "hit" then
        color = {0.2, 1.0, 0.2}  -- Green
        text = "HIT"
    elseif resultType == "critical" then
        color = self.colors.critical
        text = "CRITICAL!"
    elseif resultType == "graze" then
        color = {1.0, 0.8, 0.2}  -- Yellow-orange
        text = "GRAZE"
    elseif resultType == "miss" then
        color = self.colors.miss
        text = "MISS"
    end
    
    local effect = {
        x = x,
        y = y,
        text = text,
        color = color,
        scale = 1.2,
        lifetime = 1.5,
        age = 0.0,
        accuracy = accuracy
    }
    
    table.insert(self.floatingNumbers, effect)
    
    -- Add to log
    self:showLog(string.format("Shot: %s (%.0f%% accuracy)", text, accuracy * 100))
end

---Display critical hit effect
---@param x number Screen X position
---@param y number Screen Y position
---@param multiplier number Damage multiplier (1.5x, 2.0x, etc.)
function CombatFeedback:showCritical(x, y, multiplier)
    multiplier = multiplier or 1.5
    
    local effect = {
        x = x,
        y = y,
        vx = 0,
        vy = -100,
        text = string.format("CRITICAL! x%.1f", multiplier),
        color = self.colors.critical,
        scale = 2.0,
        lifetime = 2.0,
        age = 0.0,
        isCritical = true
    }
    
    table.insert(self.floatingNumbers, effect)
    
    self:showLog(string.format("CRITICAL HIT! Multiplier: x%.1f", multiplier))
end

---Display status effect
---@param x number Screen X position
---@param y number Screen Y position
---@param effectType string Type: "fire", "poison", "stun", "bleed", "slow"
---@param duration number Effect duration in seconds
function CombatFeedback:showEffect(x, y, effectType, duration)
    effectType = effectType or "fire"
    
    local color = self.colors[effectType] or self.colors.fire
    
    local effect = {
        x = x,
        y = y,
        type = effectType,
        color = color,
        duration = duration,
        age = 0.0,
        icon = self:getEffectIcon(effectType)
    }
    
    table.insert(self.effects, effect)
    
    self:showLog(string.format("%s applied for %.1fs", effectType:upper(), duration))
end

---Display damage resist/block effect
---@param x number Screen X position
---@param y number Screen Y position
---@param blockType string "resist" or "block"
---@param reducedDamage number Damage amount prevented
function CombatFeedback:showReduction(x, y, blockType, reducedDamage)
    blockType = blockType or "resist"
    
    local color = blockType == "resist" and self.colors.resist or self.colors.block
    local text = blockType == "resist" and "RESIST" or "BLOCKED"
    
    local effect = {
        x = x,
        y = y,
        text = string.format("%s -%d", text, math.ceil(reducedDamage)),
        color = color,
        scale = 1.0,
        lifetime = 1.5,
        age = 0.0
    }
    
    table.insert(self.floatingNumbers, effect)
    
    self:showLog(string.format("%s: %d damage prevented", text, math.ceil(reducedDamage)))
end

---Show area damage (explosion effect)
---@param centerX number Center X
---@param centerY number Center Y
---@param radius number Effect radius
---@param damage table Array of units affected {x, y, damageAmount}
function CombatFeedback:showAreaDamage(centerX, centerY, radius, damage)
    -- Draw radius circle
    local radiusEffect = {
        x = centerX,
        y = centerY,
        radius = radius,
        lifetime = 0.5,
        age = 0.0
    }
    
    table.insert(self.effects, radiusEffect)
    
    -- Show individual damage numbers
    for _, dmg in ipairs(damage) do
        self:showDamage(dmg.x, dmg.y, dmg.damageAmount, "explosive", false)
    end
    
    self:showLog(string.format("Area damage: %d units affected", #damage))
end

---Add message to combat log
---@param message string Log message
function CombatFeedback:showLog(message)
    local timestamp = string.format("[%.1f] ", love.timer.getTime() % 100)
    local logEntry = {
        text = timestamp .. message,
        time = love.timer.getTime(),
        lifespan = 10.0  -- Log entries last 10 seconds before fading
    }
    
    table.insert(self.combatLog, logEntry)
    
    -- Keep log size reasonable
    while #self.combatLog > self.maxLogSize do
        table.remove(self.combatLog, 1)
    end
    
    print("[CombatFeedback] " .. message)
end

---Update feedback animations
---@param dt number Delta time in seconds
function CombatFeedback:update(dt)
    -- Update floating numbers
    local activeNumbers = {}
    for _, num in ipairs(self.floatingNumbers) do
        num.age = num.age + dt
        
        if num.age < num.lifetime then
            -- Update position
            if num.vx then num.x = num.x + num.vx * dt end
            if num.vy then num.y = num.y + num.vy * dt end
            
            -- Apply gravity
            if num.vy then
                num.vy = num.vy + 50 * dt  -- Gravity acceleration
            end
            
            table.insert(activeNumbers, num)
        end
    end
    self.floatingNumbers = activeNumbers
    
    -- Update effects
    local activeEffects = {}
    for _, effect in ipairs(self.effects) do
        effect.age = effect.age + dt
        
        if effect.type then
            -- Duration-based effects
            if effect.age < effect.duration then
                table.insert(activeEffects, effect)
            end
        else
            -- Timed visual effects
            if effect.lifetime and effect.age < effect.lifetime then
                table.insert(activeEffects, effect)
            end
        end
    end
    self.effects = activeEffects
    
    -- Update combat log visibility
    local currentTime = love.timer.getTime()
    local activeLogs = {}
    for _, entry in ipairs(self.combatLog) do
        if currentTime - entry.time < entry.lifespan then
            table.insert(activeLogs, entry)
        end
    end
    self.combatLog = activeLogs
end

---Draw all feedback elements
function CombatFeedback:draw()
    -- Draw floating numbers
    for _, num in ipairs(self.floatingNumbers) do
        self:drawFloatingNumber(num)
    end
    
    -- Draw status effect icons
    for _, effect in ipairs(self.effects) do
        if effect.icon and effect.duration then
            self:drawEffectIcon(effect)
        elseif effect.radius then
            -- Draw area damage circle
            self:drawAreaCircle(effect)
        end
    end
    
    -- Draw combat log
    self:drawCombatLog()
end

---Draw a single floating number
---@param num table Floating number data
function CombatFeedback:drawFloatingNumber(num)
    if not num or not num.value then
        return
    end
    
    local progress = num.age / num.lifetime
    local alpha = 1.0 - (progress ^ 2)  -- Ease-out fade
    
    love.graphics.setColor(num.color[1], num.color[2], num.color[3], alpha)
    
    -- Scale gets smaller as it fades
    local scale = num.scale * (1.0 + progress)
    
    local text = tostring(math.ceil(num.value))
    if num.text then
        text = num.text
    end
    
    love.graphics.push()
    love.graphics.translate(math.floor(num.x), math.floor(num.y))
    love.graphics.scale(scale, scale)
    love.graphics.printf(text, -20, -10, 40, "center")
    love.graphics.pop()
    
    love.graphics.setColor(1, 1, 1, 1)
end

---Draw effect icon with duration
---@param effect table Status effect data
function CombatFeedback:drawEffectIcon(effect)
    local x, y = math.floor(effect.x), math.floor(effect.y)
    local progress = effect.age / effect.duration
    local alpha = 1.0 - progress
    
    love.graphics.setColor(effect.color[1], effect.color[2], effect.color[3], alpha)
    
    -- Draw circle for status effect
    love.graphics.circle("fill", x, y - 15, 8)
    
    -- Draw remaining duration text
    love.graphics.setColor(1, 1, 1, alpha)
    local remainingTime = math.ceil(effect.duration - effect.age)
    love.graphics.printf(remainingTime, x - 5, y - 18, 10, "center")
    
    love.graphics.setColor(1, 1, 1, 1)
end

---Draw area damage circle
---@param radiusEffect table Area effect data
function CombatFeedback:drawAreaCircle(radiusEffect)
    local progress = radiusEffect.age / radiusEffect.lifetime
    local alpha = 1.0 - progress
    
    love.graphics.setColor(1.0, 0.5, 0.0, alpha * 0.3)
    love.graphics.circle("fill", radiusEffect.x, radiusEffect.y, radiusEffect.radius)
    
    love.graphics.setColor(1.0, 0.5, 0.0, alpha)
    love.graphics.circle("line", radiusEffect.x, radiusEffect.y, radiusEffect.radius)
    
    love.graphics.setColor(1, 1, 1, 1)
end

---Draw combat log
function CombatFeedback:drawCombatLog()
    if #self.combatLog == 0 then
        return
    end
    
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 10, 630, 300, 80)
    
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Draw recent log entries
    local displayCount = math.min(4, #self.combatLog)
    for i = 1, displayCount do
        local idx = #self.combatLog - displayCount + i
        local entry = self.combatLog[idx]
        
        love.graphics.setColor(self.colors.log_text[1], self.colors.log_text[2],
            self.colors.log_text[3], 0.8)
        love.graphics.printf(entry.text, 15, 635 + (i - 1) * 15, 290, "left")
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

---Get effect icon symbol
---@param effectType string Effect type
---@return string Icon character
function CombatFeedback:getEffectIcon(effectType)
    local icons = {
        fire = "🔥",
        poison = "☠",
        stun = "⚡",
        bleed = "✕",
        slow = "↓"
    }
    
    return icons[effectType] or "●"
end

return CombatFeedback




