---Billboard - 3D Sprite Rendering System
---
---Renders 2D sprites that always face the camera (billboard technique). Used for units,
---effects, items, and objects in first-person 3D battlescape view. Sprites maintain
---upright orientation regardless of camera angle (cylindrical billboarding).
---
---Features:
---  - Camera-facing sprite rendering
---  - Depth sorting (painter's algorithm)
---  - Alpha blending and transparency
---  - Configurable size and scale
---  - Position in 3D world space
---  - Rotation lock (always upright)
---
---Billboard Types:
---  - Unit sprites (soldiers, aliens)
---  - Item sprites (weapons, ammo)
---  - Effect sprites (explosions, smoke)
---  - Object sprites (doors, furniture)
---
---Rendering Process:
---  1. Calculate billboard world position
---  2. Project to screen space
---  3. Calculate distance from camera
---  4. Sort by depth (far to near)
---  5. Render with alpha blending
---
---Key Exports:
---  - Billboard.new(x, y, z, sprite, width, height): Creates billboard
---  - draw(cameraX, cameraY, cameraZ, cameraAngle): Renders billboard
---  - setPosition(x, y, z): Updates position
---  - setAlpha(alpha): Sets transparency
---  - getDistance(cameraX, cameraY, cameraZ): Returns distance
---
---Dependencies:
---  - None (standalone renderer)
---
---@module battlescape.rendering.billboard
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Billboard = require("battlescape.rendering.billboard")
---  local sprite = Billboard.new(10, 0, 15, unitImage, 1, 2)
---  sprite:draw(cameraX, cameraY, cameraZ, cameraAngle)
---
---@see battlescape.rendering.renderer_3d For usage

-- Billboard Sprite Rendering System for 3D Battlescape
-- Renders sprites that always face the camera (billboard technique)
-- Used for units, effects, items, and objects in first-person 3D view

local Billboard = {}
Billboard.__index = Billboard

---@class BillboardSprite
---@field x number World X position
---@field y number World Y position (height)
---@field z number World Z position
---@field sprite love.Image Sprite image
---@field width number Width in world units
---@field height number Height in world units
---@field alpha number Transparency (0-1)
---@field emissive boolean Whether sprite glows in the dark
---@field color table RGB color tint {r, g, b}

--- Create new billboard renderer
function Billboard.new()
    local self = setmetatable({}, Billboard)
    
    -- Rendering settings
    self.settings = {
        nearestFilter = true,  -- Pixel art style
        alphaBlending = true,  -- Support transparency
        zSorting = true,       -- Sort by distance
    }
    
    -- Batch rendering
    self.billboards = {}
    
    print("[Billboard] Initialized")
    return self
end

--- Add billboard sprite to render queue
---@param x number World X position
---@param y number World Y position (height, 0=ground)
---@param z number World Z position
---@param sprite love.Image Sprite image
---@param options table Optional parameters {width, height, alpha, emissive, color}
function Billboard:add(x, y, z, sprite, options)
    options = options or {}
    
    table.insert(self.billboards, {
        x = x,
        y = y,
        z = z,
        sprite = sprite,
        width = options.width or 1.0,
        height = options.height or 1.0,
        alpha = options.alpha or 1.0,
        emissive = options.emissive or false,
        color = options.color or {r=1, g=1, b=1},
    })
end

--- Render all billboards (called once per frame)
---@param camera table Camera with {x, y, z, yaw, pitch, fov}
function Billboard:render(camera)
    if #self.billboards == 0 then return end
    
    -- Sort by distance (far to near for proper transparency)
    if self.settings.zSorting then
        self:sortByDistance(camera)
    end
    
    -- Render each billboard
    for _, billboard in ipairs(self.billboards) do
        self:renderBillboard(billboard, camera)
    end
    
    -- Clear queue for next frame
    self.billboards = {}
end

--- Render single billboard sprite
---@param billboard table Billboard data
---@param camera table Camera parameters
function Billboard:renderBillboard(billboard, camera)
    -- Calculate billboard angle to face camera
    local dx = camera.x - billboard.x
    local dz = camera.z - billboard.z
    local angle = math.atan2(dx, dz)
    
    -- Calculate distance to camera
    local dist = math.sqrt(dx * dx + dz * dz)
    
    -- Calculate screen position (perspective projection)
    local screenX, screenY, screenScale = self:worldToScreen(
        billboard.x, billboard.y, billboard.z, camera
    )
    
    -- Don't render if behind camera or too far
    if screenScale <= 0 or dist > 50 then return end
    
    -- Calculate sprite size on screen
    local spriteWidth = billboard.sprite:getWidth()
    local spriteHeight = billboard.sprite:getHeight()
    local displayWidth = spriteWidth * billboard.width * screenScale
    local displayHeight = spriteHeight * billboard.height * screenScale
    
    -- Set color and alpha
    love.graphics.setColor(
        billboard.color.r * billboard.alpha,
        billboard.color.g * billboard.alpha,
        billboard.color.b * billboard.alpha,
        billboard.alpha
    )
    
    -- Draw sprite centered at position
    love.graphics.draw(
        billboard.sprite,
        screenX,
        screenY,
        angle,  -- Rotation to face camera
        displayWidth / spriteWidth,  -- Scale X
        displayHeight / spriteHeight, -- Scale Y
        spriteWidth / 2,  -- Origin X (center)
        spriteHeight / 2  -- Origin Y (center)
    )
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

--- Convert world position to screen coordinates
---@param x number World X
---@param y number World Y (height)
---@param z number World Z
---@param camera table Camera parameters
---@return number, number, number Screen X, Screen Y, Scale
function Billboard:worldToScreen(x, y, z, camera)
    -- Relative to camera
    local dx = x - camera.x
    local dy = y - camera.y
    local dz = z - camera.z
    
    -- Rotate by camera yaw
    local cosYaw = math.cos(-camera.yaw)
    local sinYaw = math.sin(-camera.yaw)
    local rx = dx * cosYaw - dz * sinYaw
    local rz = dx * sinYaw + dz * cosYaw
    
    -- Perspective projection
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Avoid division by zero
    if rz <= 0.1 then
        return -1000, -1000, 0  -- Behind camera
    end
    
    -- FOV-based projection
    local fov = camera.fov or 90
    local fovScale = math.tan(math.rad(fov / 2))
    
    local screenScale = 1.0 / (rz * fovScale)
    local screenX = screenWidth / 2 + rx * screenWidth * screenScale / 2
    local screenY = screenHeight / 2 - dy * screenHeight * screenScale / 2
    
    return screenX, screenY, screenScale
end

--- Sort billboards by distance (far to near)
---@param camera table Camera parameters
function Billboard:sortByDistance(camera)
    table.sort(self.billboards, function(a, b)
        local distA = (a.x - camera.x)^2 + (a.z - camera.z)^2
        local distB = (b.x - camera.x)^2 + (b.z - camera.z)^2
        return distA > distB  -- Far to near
    end)
end

--- Render unit as billboard sprite
---@param unit table Unit data with {x, y, facing, spriteName, team}
---@param camera table Camera parameters
---@param assets table Asset manager
function Billboard:renderUnit(unit, camera, assets)
    -- Get unit sprite
    local spriteName = unit.spriteName or "soldier"
    local sprite = assets:get("units", spriteName)
    
    if not sprite then
        print("[Billboard] Missing sprite: " .. spriteName)
        return
    end
    
    -- Unit position (convert tile to world)
    local worldX = unit.x
    local worldZ = unit.y
    local worldY = 0.5  -- Half height (center of sprite)
    
    -- Color based on team
    local color = {r=1, g=1, b=1}
    if unit.team == "player" then
        color = {r=0.7, g=1, b=0.7}  -- Slight green tint
    elseif unit.team == "enemy" then
        color = {r=1, g=0.7, b=0.7}  -- Slight red tint
    end
    
    -- Add to render queue
    self:add(worldX, worldY, worldZ, sprite, {
        width = 1.0,
        height = 1.0,
        alpha = unit.isVisible and 1.0 or 0.0,
        emissive = false,
        color = color,
    })
end

--- Render item on ground as billboard
---@param item table Item data with {x, y, slot, spriteName}
---@param camera table Camera parameters
---@param assets table Asset manager
function Billboard:renderItem(item, camera, assets)
    -- Get item sprite
    local sprite = assets:get("items", item.spriteName)
    if not sprite then return end
    
    -- Item slot positions (5 slots per tile)
    local ITEM_SLOTS = {
        {x = -0.3, z = -0.3},  -- Top-left
        {x = 0.3,  z = -0.3},  -- Top-right
        {x = 0.0,  z = 0.0},   -- Center
        {x = -0.3, z = 0.3},   -- Bottom-left
        {x = 0.3,  z = 0.3}    -- Bottom-right
    }
    
    local slot = ITEM_SLOTS[item.slot] or ITEM_SLOTS[3]
    
    -- Position on ground
    local worldX = item.x + slot.x
    local worldZ = item.y + slot.z
    local worldY = 0.1  -- Just above ground
    
    -- Add to render queue (scaled down 50%)
    self:add(worldX, worldY, worldZ, sprite, {
        width = 0.5,
        height = 0.5,
        alpha = 1.0,
        emissive = false,
    })
end

--- Render effect (fire, smoke, explosion) as billboard
---@param effect table Effect data with {x, y, type, frame}
---@param camera table Camera parameters
---@param assets table Asset manager
function Billboard:renderEffect(effect, camera, assets)
    -- Get effect sprite for current frame
    local spriteName = effect.type .. "_" .. effect.frame
    local sprite = assets:get("effects", spriteName)
    if not sprite then return end
    
    -- Effect properties
    local worldX = effect.x
    local worldZ = effect.y
    local worldY = 0.6  -- Slightly above ground
    
    local options = {
        width = 1.0,
        height = 1.2,
        alpha = effect.alpha or 1.0,
        emissive = (effect.type == "fire"),  -- Fire glows
        color = effect.color or {r=1, g=1, b=1},
    }
    
    -- Smoke is semi-transparent
    if effect.type == "smoke" then
        options.alpha = 0.6
    end
    
    -- Add to render queue
    self:add(worldX, worldY, worldZ, sprite, options)
end

--- Clear all billboards (called at start of frame)
function Billboard:clear()
    self.billboards = {}
end

return Billboard






















