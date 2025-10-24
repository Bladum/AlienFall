-- Billboard Renderer for 3D Units in First-Person View
-- Renders unit sprites as always-facing-camera billboards
-- Integrates with HexRaycaster and View3D systems

local BillboardRenderer = {}

-- Billboard structure:
-- {
--   unit = unit object,
--   screenX = screen X position (in 3D projected space),
--   screenY = screen Y position,
--   screenZ = distance from camera,
--   scale = visual scale (based on distance and size),
--   opacity = alpha transparency (based on LOS)
-- }

function BillboardRenderer.new()
    local self = {}
    self.billboards = {}  -- Current frame billboards
    self.cache = {}       -- Cache of sprite data per unit

    return setmetatable(self, { __index = BillboardRenderer })
end

-- Project 3D hex world position to 2D screen position
-- Args:
--   unitX, unitY: hex coordinates of unit
--   unitZ: height above ground (0-1 typically)
--   cameraX, cameraY: camera position (center of viewport)
--   cameraZ: camera height
--   cameraAngle: camera heading (0-360)
--   cameraPitch: camera pitch angle (-45 to +45)
--   hexRaycaster: raycaster for projection calculations
--   screenW, screenH: viewport dimensions (in pixels)
-- Returns:
--   screenX, screenY, screenZ (distance from camera)
--   visible (boolean - is billboard within field of view)
local function project3DToScreen(unitX, unitY, unitZ, cameraX, cameraY, cameraZ, cameraAngle, cameraPitch, hexRaycaster, screenW, screenH)
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
        return screenW / 2, screenH / 2, distance, false  -- Visible but far (for sorting)
    end

    -- Normalize angle to camera's view
    -- Calculate angle to unit from camera
    local angleToUnit = math.atan2(relY, relX)
    local cameraDelta = angleToUnit - math.rad(cameraAngle)

    -- Wrap angle to -180 to +180 degrees
    while cameraDelta > math.pi do cameraDelta = cameraDelta - 2 * math.pi end
    while cameraDelta < -math.pi do cameraDelta = cameraDelta + 2 * math.pi end

    -- Field of view check (90° total FOV, 45° each side)
    local fovHalf = math.rad(45)
    if math.abs(cameraDelta) > fovHalf then
        return screenW / 2, screenH / 2, distance, false  -- Outside field of view
    end

    -- Project to screen
    -- Horizontal: angle-based positioning
    local screenX = screenW / 2 + math.sin(cameraDelta) * (screenW / 2)

    -- Vertical: pitch-based positioning with Z adjustment
    local verticalAngle = cameraPitch + math.atan2(relZ, distance)
    local screenY = screenH / 2 - math.sin(verticalAngle) * (screenH / 2)

    -- Clamp to screen
    local onScreen = (screenX >= 0 and screenX <= screenW and screenY >= 0 and screenY <= screenH)

    return screenX, screenY, distance, true
end

-- Get sprite for unit with caching
-- Args:
--   unit: unit object with transform, armor type, team
--   assetManager: asset manager for loading sprites
-- Returns:
--   sprite (table with width, height, quads for animations)
local function getUnitSprite(unit, assetManager)
    if not unit then return nil end

    -- Build cache key from unit properties
    local cacheKey = unit.id or tostring(unit)

    -- Return cached if available
    if BillboardRenderer.spriteCache and BillboardRenderer.spriteCache[cacheKey] then
        return BillboardRenderer.spriteCache[cacheKey]
    end

    -- Load sprite for unit type
    local armor = unit.armor or "light"
    local team = unit.team or 1
    local spriteName = "unit_" .. armor .. "_team_" .. team

    local sprite = assetManager and assetManager:getSprite(spriteName)
    if not sprite then
        -- Fallback placeholder
        sprite = {
            width = 24,
            height = 24,
            quad = love.graphics.newQuad(0, 0, 24, 24, 24, 24),
            texture = nil
        }
    end

    return sprite
end

-- Add unit billboard to render queue
-- Args:
--   unit: unit object
--   cameraX, cameraY, cameraZ: camera position
--   cameraAngle, cameraPitch: camera orientation
--   hexRaycaster: raycasting system
--   screenW, screenH: viewport dimensions
--   assetManager: for loading sprites
function BillboardRenderer:addUnitBillboard(unit, cameraX, cameraY, cameraZ, cameraAngle, cameraPitch, hexRaycaster, screenW, screenH, assetManager)
    if not unit or not unit.transform or not unit.alive then
        return
    end

    -- Project to screen space
    local screenX, screenY, distance, visible = project3DToScreen(
        unit.transform.x, unit.transform.y, 0.5,
        cameraX, cameraY, cameraZ,
        cameraAngle, cameraPitch,
        hexRaycaster, screenW, screenH
    )

    if not visible then
        return
    end

    -- Get unit sprite
    local sprite = getUnitSprite(unit, assetManager)

    -- Calculate visual scale based on distance
    local baseScale = 2.0
    local distanceScale = 1.0 / (distance * 0.5)
    local scale = math.max(0.5, math.min(2.0, baseScale * distanceScale))

    -- Create billboard entry
    local billboard = {
        unit = unit,
        screenX = screenX,
        screenY = screenY,
        distance = distance,
        scale = scale,
        sprite = sprite,
        health = unit.health or 100,
        maxHealth = unit.maxHealth or 100,
        opacity = 1.0,  -- Will be adjusted for LOS/FOW
        team = unit.team
    }

    table.insert(self.billboards, billboard)
end

-- Sort billboards by distance (painters algorithm - back to front)
function BillboardRenderer:sortBillboards()
    table.sort(self.billboards, function(a, b)
        return a.distance > b.distance
    end)
end

-- Draw all billboards
-- Args:
--   spriteAtlas: Love2D image with unit sprites
--   losSystem: line of sight system for visibility (optional)
--   currentTeam: current team for visibility checks
function BillboardRenderer:drawBillboards(spriteAtlas, losSystem, currentTeam)
    -- Sort billboards back to front
    self:sortBillboards()

    for _, billboard in ipairs(self.billboards) do
        if billboard.sprite then
            -- Determine opacity based on visibility
            local opacity = billboard.opacity
            if losSystem and currentTeam then
                -- Check if billboard is visible
                local vis = losSystem:getVisibility(currentTeam, billboard.unit.transform.x, billboard.unit.transform.y)
                if vis == "hidden" then
                    opacity = 0.3  -- Dim if not visible
                elseif vis == "partially" then
                    opacity = 0.7  -- Semi-transparent if partially visible
                end
            end

            love.graphics.setColor(1, 1, 1, opacity)

            -- Draw sprite at projected position
            if spriteAtlas then
                love.graphics.draw(
                    spriteAtlas,
                    billboard.sprite.quad,
                    billboard.screenX,
                    billboard.screenY,
                    0,  -- rotation
                    billboard.scale,
                    billboard.scale,
                    billboard.sprite.width / 2,
                    billboard.sprite.height / 2
                )
            else
                -- Fallback colored rectangle
                local c = billboard.unit.team == 1 and {0.3, 1, 0.3} or {1, 0.3, 0.3}
                love.graphics.setColor(c[1], c[2], c[3], opacity)
                love.graphics.rectangle(
                    "fill",
                    billboard.screenX - 12 * billboard.scale,
                    billboard.screenY - 12 * billboard.scale,
                    24 * billboard.scale,
                    24 * billboard.scale
                )
            end

            -- Draw health bar above billboard
            self:drawHealthBar(billboard)

            -- Draw selection highlight if selected
            if billboard.unit.isSelected then
                self:drawSelectionHighlight(billboard)
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)  -- Reset color
end

-- Draw health bar for billboard
function BillboardRenderer:drawHealthBar(billboard)
    if billboard.health <= 0 then return end

    local x = billboard.screenX
    local y = billboard.screenY - 12 * billboard.scale - 8
    local w = 24 * billboard.scale
    local h = 3

    -- Background
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x - w/2, y, w, h)

    -- Health bar
    local healthPercent = billboard.health / billboard.maxHealth
    local color
    if healthPercent > 0.5 then
        color = {0.2, 1, 0.2}  -- Green
    elseif healthPercent > 0.25 then
        color = {1, 1, 0.2}    -- Yellow
    else
        color = {1, 0.2, 0.2}  -- Red
    end
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.rectangle("fill", x - w/2, y, w * healthPercent, h)
end

-- Draw selection highlight
function BillboardRenderer:drawSelectionHighlight(billboard)
    love.graphics.setColor(1, 1, 0, 0.8)  -- Yellow
    love.graphics.rectangle(
        "line",
        billboard.screenX - 12 * billboard.scale - 2,
        billboard.screenY - 12 * billboard.scale - 2,
        24 * billboard.scale + 4,
        24 * billboard.scale + 4
    )
end

-- Get billboard at screen position (for mouse picking)
-- Args:
--   x, y: mouse position
--   pickRadius: radius in pixels for picking (default 8)
-- Returns:
--   billboard (the one under cursor) or nil
function BillboardRenderer:getBillboardAtPosition(x, y, pickRadius)
    pickRadius = pickRadius or 8

    -- Iterate in reverse order (front to back) for proper picking
    for i = #self.billboards, 1, -1 do
        local billboard = self.billboards[i]
        local dx = billboard.screenX - x
        local dy = billboard.screenY - y
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist <= pickRadius + 12 * billboard.scale then
            return billboard
        end
    end

    return nil
end

-- Clear billboards for new frame
function BillboardRenderer:clear()
    self.billboards = {}
end

-- Add ground item to render queue
-- Args:
--   x, y: hex coordinates
--   itemType: type of item (weapon, ammo, medkit, etc)
--   itemCount: how many items (for stacking indicator)
--   cameraX, cameraY, cameraZ: camera position
--   cameraAngle, cameraPitch: camera orientation
--   hexRaycaster: raycasting system
--   screenW, screenH: viewport dimensions
-- Returns:
--   item table or nil if not visible
function BillboardRenderer:addItemBillboard(x, y, itemType, itemCount, cameraX, cameraY, cameraZ, cameraAngle, cameraPitch, hexRaycaster, screenW, screenH)
    if not itemType then return end

    -- Project to screen space
    local screenX, screenY, distance, visible = project3DToScreen(
        x, y, 0.1,  -- items sit slightly above ground
        cameraX, cameraY, cameraZ,
        cameraAngle, cameraPitch,
        hexRaycaster, screenW, screenH
    )

    if not visible then
        return
    end

    -- Calculate visual scale (items are smaller than units - 50% scale)
    local baseScale = 1.0
    local distanceScale = 1.0 / (distance * 0.5)
    local scale = math.max(0.25, math.min(1.5, baseScale * distanceScale * 0.5))  -- 0.5 multiplier for smaller size

    -- Create item entry
    local item = {
        itemType = itemType,
        itemCount = itemCount or 1,
        screenX = screenX,
        screenY = screenY,
        distance = distance,
        scale = scale,
        opacity = 1.0
    }

    -- Store with items (will be sorted separately or with units)
    if not self.items then
        self.items = {}
    end
    table.insert(self.items, item)

    return item
end

-- Draw ground items
-- Args:
--   itemAtlas: Love2D image with item sprites (optional)
function BillboardRenderer:drawItems(itemAtlas)
    if not self.items or #self.items == 0 then return end

    -- Sort by distance if needed
    table.sort(self.items, function(a, b)
        return a.distance > b.distance
    end)

    for _, item in ipairs(self.items) do
        love.graphics.setColor(1, 1, 1, item.opacity)

        -- Draw item sprite or fallback
        if itemAtlas then
            -- Draw item sprite at position
            love.graphics.rectangle("line",  -- Use line rectangle as placeholder
                item.screenX - 6 * item.scale,
                item.screenY - 6 * item.scale,
                12 * item.scale,
                12 * item.scale)
        else
            -- Fallback: colored rectangle based on item type
            local color = self:getItemColor(item.itemType)
            love.graphics.setColor(color[1], color[2], color[3], item.opacity)
            love.graphics.rectangle("fill",
                item.screenX - 6 * item.scale,
                item.screenY - 6 * item.scale,
                12 * item.scale,
                12 * item.scale)
        end

        -- Draw item count if more than 1
        if item.itemCount and item.itemCount > 1 then
            love.graphics.setColor(1, 1, 1, item.opacity)
            love.graphics.print(tostring(item.itemCount),
                item.screenX + 4 * item.scale,
                item.screenY + 4 * item.scale)
        end
    end
end

-- Get color for item type
function BillboardRenderer:getItemColor(itemType)
    if itemType == "weapon" then
        return {0.8, 0.2, 0.2}  -- Red
    elseif itemType == "ammo" then
        return {0.8, 0.8, 0.2}  -- Yellow
    elseif itemType == "medkit" then
        return {0.2, 0.8, 0.2}  -- Green
    elseif itemType == "grenade" then
        return {0.8, 0.5, 0.2}  -- Orange
    else
        return {0.5, 0.5, 0.5}  -- Gray (unknown)
    end
end

-- Clear items for new frame
function BillboardRenderer:clearItems()
    self.items = {}
end

return BillboardRenderer
