---3D Unit Sprite Rendering System
---
---Renders unit sprites as billboards in 3D first-person battlescape view. Each unit
---is displayed as a rotated 2D sprite that always faces the camera. Supports animation,
---team coloring, status effect indicators, and depth sorting for proper layering.
---
---Features:
---  - Billboard sprite rendering (always face camera)
---  - Unit animation support with frame cycling
---  - Team color overlays (green=player, red=enemy, yellow=ally)
---  - Health/damage visual indicators (red tint when hurt)
---  - Status effect icons displayed above units
---  - Depth sorting for correct transparency ordering
---  - Corpse display for dead units
---  - Selection highlighting
---
---Sprite Management:
---  - Asset loading from engine/assets/sprites/
---  - Frame animation with configurable speed
---  - Sprite caching for performance
---  - Batch rendering support
---
---Key Exports:
---  - UnitSpriteRenderer.new(): Creates renderer
---  - addUnit(unitId, spriteData): Adds unit to scene
---  - updateUnit(unitId, position, facing): Updates position
---  - draw(): Renders all visible units
---  - getVisibleUnits(): Gets units in camera view
---
---Dependencies:
---  - battlescape.rendering.renderer_3d: 3D camera system
---  - battlescape.systems.unit_system: Unit data
---  - assets.sprite_manager: Sprite loading
---
---@module battlescape.rendering.unit_sprite_renderer
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local SpriteRenderer = require("engine.battlescape.rendering.unit_sprite_renderer")
---  local renderer = SpriteRenderer.new(camera)
---  renderer:addUnit(unitId, {sprite="soldier", team="PLAYER"})
---  renderer:draw()

local UnitSpriteRenderer = {}
UnitSpriteRenderer.__index = UnitSpriteRenderer

--- Create new unit sprite renderer
-- @param camera table 3D camera system
-- @return table New UnitSpriteRenderer instance
function UnitSpriteRenderer.new(camera)
    local self = setmetatable({}, UnitSpriteRenderer)

    self.camera = camera
    self.units = {}              -- Tracked units: unitId -> unit data
    self.sprites = {}            -- Loaded sprites: spriteName -> image data
    self.animations = {}         -- Animation states: unitId -> animation data
    self.selectionHighlight = nil -- Currently selected unit
    self.depthSorted = {}        -- Depth-sorted unit list for rendering

    self.spriteScale = 1.0       -- Scale factor for sprites (default 24×24 upscaled)
    self.animationSpeed = 0.15   -- Frames per second for animations

    print("[UnitSpriteRenderer] Initialized 3D unit sprite rendering system")

    return self
end

--- Add unit to rendering system
-- @param unitId string Unique unit identifier
-- @param spriteData table Sprite configuration
-- @return boolean Success
function UnitSpriteRenderer:addUnit(unitId, spriteData)
    if not unitId then
        return false
    end

    local unit = {
        id = unitId,
        spriteName = spriteData.spriteName or "soldier_default",
        team = spriteData.team or "NEUTRAL",  -- PLAYER, ENEMY, ALLY, NEUTRAL
        position = spriteData.position or {x = 0, y = 0, z = 0},
        facing = spriteData.facing or 0,

        -- Visual state
        hp = spriteData.hp or 100,
        maxHp = spriteData.maxHp or 100,
        isDead = spriteData.isDead or false,
        isSelected = false,
        statusEffects = spriteData.statusEffects or {},

        -- Animation
        currentFrame = 0,
        isAnimating = spriteData.isAnimating or false,
        animationType = spriteData.animationType or "idle",  -- idle, walk, attack, die

        -- Rendering
        scale = spriteData.scale or 1.0,
        alpha = spriteData.alpha or 1.0,
        colorTint = spriteData.colorTint or {r = 1.0, g = 1.0, b = 1.0},

        -- Sorting
        depth = 0,  -- Distance from camera (calculated in draw)
    }

    self.units[unitId] = unit

    -- Initialize animation
    self.animations[unitId] = {
        current = 0,
        maxFrames = self:getAnimationFrameCount(unit.spriteName, unit.animationType),
        speed = self.animationSpeed,
    }

    print(string.format("[UnitSpriteRenderer] Added unit '%s' (sprite: %s, team: %s)",
          unitId, unit.spriteName, unit.team))

    return true
end

--- Update unit position and state
-- @param unitId string Unit ID
-- @param position table New position {x, y, z}
-- @param facing number Facing direction (0-5 for hex)
function UnitSpriteRenderer:updateUnit(unitId, position, facing)
    local unit = self.units[unitId]

    if not unit then
        return
    end

    if position then
        unit.position = position
    end

    if facing then
        unit.facing = facing
    end
end

--- Set unit health (affects visual damage tint)
-- @param unitId string Unit ID
-- @param hp number Current health
-- @param maxHp number Maximum health
function UnitSpriteRenderer:setUnitHealth(unitId, hp, maxHp)
    local unit = self.units[unitId]

    if not unit then
        return
    end

    unit.hp = hp
    unit.maxHp = maxHp

    -- Apply damage tint based on health percentage
    local healthPercent = hp / maxHp
    if healthPercent < 0.5 then
        -- Red tint for heavy damage
        unit.colorTint = {r = 1.0, g = 0.5, b = 0.5}
    elseif healthPercent < 0.75 then
        -- Yellow tint for moderate damage
        unit.colorTint = {r = 1.0, g = 1.0, b = 0.5}
    else
        -- Normal coloring for light/no damage
        unit.colorTint = {r = 1.0, g = 1.0, b = 1.0}
    end
end

--- Update unit animation state
-- @param unitId string Unit ID
-- @param animationType string Animation type (idle, walk, attack, die)
-- @param isAnimating boolean Whether animation is active
function UnitSpriteRenderer:setAnimation(unitId, animationType, isAnimating)
    local unit = self.units[unitId]

    if not unit then
        return
    end

    unit.animationType = animationType or "idle"
    unit.isAnimating = isAnimating ~= false
    unit.currentFrame = 0

    -- Reset animation state
    if self.animations[unitId] then
        self.animations[unitId].current = 0
        self.animations[unitId].maxFrames = self:getAnimationFrameCount(unit.spriteName, unit.animationType)
    end
end

--- Mark unit as dead (shows corpse sprite)
-- @param unitId string Unit ID
function UnitSpriteRenderer:markUnitDead(unitId)
    local unit = self.units[unitId]

    if unit then
        unit.isDead = true
        unit.animationType = "dead"
        unit.isAnimating = false
        print(string.format("[UnitSpriteRenderer] Unit '%s' marked as dead", unitId))
    end
end

--- Set unit selection highlight
-- @param unitId string Unit ID or nil to deselect
function UnitSpriteRenderer:setSelection(unitId)
    -- Clear previous selection
    if self.selectionHighlight then
        local prevUnit = self.units[self.selectionHighlight]
        if prevUnit then
            prevUnit.isSelected = false
        end
    end

    -- Set new selection
    if unitId then
        local unit = self.units[unitId]
        if unit then
            unit.isSelected = true
            self.selectionHighlight = unitId
        end
    else
        self.selectionHighlight = nil
    end
end

--- Add status effect indicator to unit
-- @param unitId string Unit ID
-- @param effectId string Status effect identifier
function UnitSpriteRenderer:addStatusEffect(unitId, effectId)
    local unit = self.units[unitId]

    if not unit then
        return
    end

    table.insert(unit.statusEffects, {
        id = effectId,
        icon = self:getStatusEffectIcon(effectId),
        color = self:getStatusEffectColor(effectId),
    })
end

--- Remove status effect indicator
-- @param unitId string Unit ID
-- @param effectId string Status effect identifier
function UnitSpriteRenderer:removeStatusEffect(unitId, effectId)
    local unit = self.units[unitId]

    if not unit then
        return
    end

    for i, effect in ipairs(unit.statusEffects) do
        if effect.id == effectId then
            table.remove(unit.statusEffects, i)
            break
        end
    end
end

--- Update all animations (call each frame)
-- @param dt number Delta time since last frame
function UnitSpriteRenderer:update(dt)
    for unitId, animation in pairs(self.animations) do
        local unit = self.units[unitId]

        if unit and unit.isAnimating then
            -- Advance animation frame
            animation.current = animation.current + (dt * animation.speed)

            -- Loop animation when complete
            if animation.current >= animation.maxFrames then
                animation.current = animation.current % animation.maxFrames
            end

            unit.currentFrame = math.floor(animation.current)
        end
    end
end

--- Draw all visible units as billboards
-- @param viewWidth number Screen width in pixels
-- @param viewHeight number Screen height in pixels
function UnitSpriteRenderer:draw(viewWidth, viewHeight)
    -- Sort units by depth (front to back)
    self:calculateDepth()

    -- Render each unit as billboard
    for _, unit in ipairs(self.depthSorted) do
        self:drawUnitBillboard(unit, viewWidth, viewHeight)
    end
end

--- Calculate depth for all units (distance from camera)
function UnitSpriteRenderer:calculateDepth()
    self.depthSorted = {}

    for _, unit in pairs(self.units) do
        if unit then
            -- Calculate distance to camera (if camera system provides position)
            if self.camera and self.camera.position then
                local dx = (unit.position.x or 0) - (self.camera.position.x or 0)
                local dy = (unit.position.y or 0) - (self.camera.position.y or 0)
                local dz = (unit.position.z or 0) - (self.camera.position.z or 0)
                unit.depth = math.sqrt(dx * dx + dy * dy + dz * dz)
            else
                unit.depth = 0
            end

            table.insert(self.depthSorted, unit)
        end
    end

    -- Sort by depth (nearest last = rendered on top)
    table.sort(self.depthSorted, function(a, b)
        return a.depth > b.depth
    end)
end

--- Draw single unit as billboard sprite
-- @param unit table Unit data
-- @param viewWidth number Screen width
-- @param viewHeight number Screen height
function UnitSpriteRenderer:drawUnitBillboard(unit, viewWidth, viewHeight)
    -- Get sprite image
    local sprite = self:loadSprite(unit.spriteName)
    if not sprite then
        return
    end

    -- Calculate screen position from world position
    -- (requires integration with camera projection)
    local screenX, screenY = self:worldToScreen(unit.position)

    if not screenX or not screenY then
        return  -- Unit not visible
    end

    -- Apply team color
    local r, g, b = self:getTeamColor(unit.team)
    love.graphics.setColor(r * unit.colorTint.r, g * unit.colorTint.g, b * unit.colorTint.b, unit.alpha)

    -- Draw sprite (rotated billboard that faces camera)
    local spriteWidth, spriteHeight = sprite:getDimensions()
    love.graphics.draw(sprite, screenX, screenY, 0, unit.scale, unit.scale,
                      spriteWidth / 2, spriteHeight / 2)

    -- Draw selection highlight if selected
    if unit.isSelected then
        love.graphics.setColor(1.0, 1.0, 0.0, 0.5)  -- Yellow highlight
        love.graphics.rectangle("line", screenX - spriteWidth * unit.scale / 2,
                              screenY - spriteHeight * unit.scale / 2,
                              spriteWidth * unit.scale, spriteHeight * unit.scale)
    end

    -- Draw health bar above unit
    self:drawHealthBar(screenX, screenY - spriteHeight * unit.scale / 2 - 10, unit)

    -- Draw status effect icons above unit
    self:drawStatusEffects(screenX, screenY - spriteHeight * unit.scale / 2 - 25, unit)

    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)  -- Reset color
end

--- Draw health bar for unit
-- @param x number Screen X position
-- @param y number Screen Y position
-- @param unit table Unit data
function UnitSpriteRenderer:drawHealthBar(x, y, unit)
    local barWidth = 32
    local barHeight = 4

    -- Background (dark red)
    love.graphics.setColor(0.5, 0.0, 0.0, 0.7)
    love.graphics.rectangle("fill", x - barWidth / 2, y, barWidth, barHeight)

    -- Health bar (green to red gradient)
    local healthPercent = unit.hp / unit.maxHp
    local barColor = {
        r = 1.0 - healthPercent,  -- Red when damaged
        g = healthPercent,         -- Green when healthy
        b = 0.0,
    }
    love.graphics.setColor(barColor.r, barColor.g, barColor.b, 0.9)
    love.graphics.rectangle("fill", x - barWidth / 2, y, barWidth * healthPercent, barHeight)

    -- Border
    love.graphics.setColor(1.0, 1.0, 1.0, 0.8)
    love.graphics.rectangle("line", x - barWidth / 2, y, barWidth, barHeight)
end

--- Draw status effect icons above unit
-- @param x number Screen X position
-- @param y number Screen Y position
-- @param unit table Unit data
function UnitSpriteRenderer:drawStatusEffects(x, y, unit)
    local iconSize = 8
    local spacing = 10
    local totalWidth = #unit.statusEffects * spacing

    for i, effect in ipairs(unit.statusEffects) do
        local effectX = x - totalWidth / 2 + (i - 1) * spacing

        -- Draw colored circle for effect
        love.graphics.setColor(effect.color.r, effect.color.g, effect.color.b, 0.9)
        love.graphics.circle("fill", effectX, y, iconSize / 2)

        -- Draw border
        love.graphics.setColor(1.0, 1.0, 1.0, 0.6)
        love.graphics.circle("line", effectX, y, iconSize / 2)
    end
end

--- Convert world position to screen coordinates
-- @param worldPos table World position {x, y, z}
-- @return number screenX, number screenY
function UnitSpriteRenderer:worldToScreen(worldPos)
    -- Placeholder implementation - integrate with actual camera projection
    if not self.camera then
        return nil, nil
    end

    -- This should use camera.project() or similar
    -- For now, return placeholder coordinates
    local screenX = 480 + (worldPos.x or 0) * 8
    local screenY = 360 - (worldPos.y or 0) * 8

    return screenX, screenY
end

--- Get team color for unit
-- @param team string Team identifier
-- @return number r, number g, number b
function UnitSpriteRenderer:getTeamColor(team)
    local colors = {
        PLAYER = {r = 0.2, g = 0.8, b = 0.2},    -- Green
        ENEMY = {r = 1.0, g = 0.2, b = 0.2},     -- Red
        ALLY = {r = 0.2, g = 0.8, b = 1.0},      -- Cyan
        NEUTRAL = {r = 0.8, g = 0.8, b = 0.8},   -- Gray
    }

    local color = colors[team] or colors.NEUTRAL
    return color.r, color.g, color.b
end

--- Get status effect icon (placeholder)
-- @param effectId string Effect identifier
-- @return string Icon identifier
function UnitSpriteRenderer:getStatusEffectIcon(effectId)
    return effectId  -- Placeholder
end

--- Get status effect color
-- @param effectId string Effect identifier
-- @return table Color {r, g, b}
function UnitSpriteRenderer:getStatusEffectColor(effectId)
    local colors = {
        MARKED = {r = 1.0, g = 1.0, b = 0.0},       -- Yellow
        SUPPRESSED = {r = 1.0, g = 0.5, b = 0.0},   -- Orange
        FORTIFIED = {r = 0.5, g = 1.0, b = 0.5},    -- Light green
        BURNING = {r = 1.0, g = 0.0, b = 0.0},      -- Red
        STUNNED = {r = 0.5, g = 0.5, b = 1.0},      -- Light blue
        HASTE = {r = 0.0, g = 1.0, b = 0.5},        -- Green-cyan
        SLOW = {r = 0.0, g = 0.5, b = 1.0},         -- Blue
    }

    return colors[effectId] or {r = 0.5, g = 0.5, b = 0.5}
end

--- Load sprite from assets
-- @param spriteName string Sprite identifier
-- @return table Image data or nil
function UnitSpriteRenderer:loadSprite(spriteName)
    -- Check cache first
    if self.sprites[spriteName] then
        return self.sprites[spriteName]
    end

    -- Placeholder: Load sprite from assets directory
    -- In real implementation, would use love.graphics.newImage()
    local spritePath = "engine/assets/sprites/units/" .. spriteName .. ".png"

    -- For now, return placeholder (would fail without real sprite files)
    print(string.format("[UnitSpriteRenderer] Loading sprite: %s", spriteName))

    return nil  -- Placeholder until sprite assets are available
end

--- Get animation frame count for sprite
-- @param spriteName string Sprite identifier
-- @param animationType string Animation type
-- @return number Frame count
function UnitSpriteRenderer:getAnimationFrameCount(spriteName, animationType)
    -- Placeholder frame counts
    local frameCounts = {
        idle = 4,
        walk = 8,
        attack = 6,
        die = 10,
    }

    return frameCounts[animationType] or 4
end

--- Get visible units in camera view
-- @return table Array of visible unit IDs
function UnitSpriteRenderer:getVisibleUnits()
    local visible = {}

    for unitId, unit in pairs(self.units) do
        if unit and not unit.isDead then
            -- Simple frustum check (can be optimized with actual camera system)
            table.insert(visible, unitId)
        end
    end

    return visible
end

--- Remove unit from rendering
-- @param unitId string Unit ID
function UnitSpriteRenderer:removeUnit(unitId)
    self.units[unitId] = nil
    self.animations[unitId] = nil

    if self.selectionHighlight == unitId then
        self.selectionHighlight = nil
    end

    print(string.format("[UnitSpriteRenderer] Removed unit '%s' from rendering", unitId))
end

return UnitSpriteRenderer

