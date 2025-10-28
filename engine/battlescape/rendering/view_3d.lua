---3D Battlescape Viewer - First-Person Camera System
---
---Integrates hex raycaster with battlescape for first-person 3D view toggle.
---Provides camera management, coordinate conversion, and rendering pipeline
---for 3D first-person combat visualization.
---
---Features:
---  - Toggle between 2D and 3D views with SPACE
---  - First-person camera from active unit position
---  - Real-time coordinate synchronization
---  - WASD camera rotation (60° increments for hex grid)
---  - Mouse look (optional pitch control)
---  - Distance fog and lighting
---  - Minimap integration in 3D mode
---  - Day/night visibility ranges
---
---Key Exports:
---  - View3D.new(battlescape): Create viewer from battlescape
---  - View3D:update(dt): Update camera state
---  - View3D:draw(): Render 3D view
---  - View3D:toggleMode(): Switch between 2D/3D
---  - View3D:setCameraFromUnit(unit): Position camera at unit
---
---@module battlescape.rendering.view_3d
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local View3D = {}
View3D.__index = View3D

local HexRaycaster = require("battlescape.rendering.hex_raycaster")
local HexMath = require("battlescape.battle_ecs.hex_math")
local BillboardRenderer = require("battlescape.rendering.billboard_renderer")
local EffectsRenderer = require("battlescape.rendering.effects_renderer")
local ShootingSystem3D = require("battlescape.combat.shooting_system_3d")

---Create new 3D viewer
---@param battlescape table Battlescape state
---@return table viewer New viewer instance
function View3D.new(battlescape)
    local self = setmetatable({}, View3D)

    self.battlescape = battlescape
    self.enabled = false  -- Start in 2D mode

    -- Get screen dimensions
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- Create hex raycaster
    if battlescape.battlefield and battlescape.battlefield.tiles then
        -- HexRaycaster needs hex grid and terrain system
        local terrainSystem = battlescape.terrainSystem or {}
        self.raycaster = HexRaycaster.new(battlescape.battlefield, terrainSystem)
    else
        self.raycaster = nil
    end

    -- Create billboard renderer for units
    self.billboardRenderer = BillboardRenderer.new()

    -- Create effects renderer for fire, smoke, objects
    self.effectsRenderer = EffectsRenderer.new()

    -- Create 3D shooting system
    self.shootingSystem3D = ShootingSystem3D.new()

    -- Camera state
    self.cameraQ = 45
    self.cameraR = 45
    self.cameraAngle = 0  -- Radians, 0 = facing East (q+1)
    self.cameraPitch = 0  -- Vertical look (-pi/2 to pi/2)

    -- Hex directions (for WASD rotation: 60° increments)
    self.hexDirAngles = {
        0,      -- East (0°)
        math.pi / 3,      -- Northeast (60°)
        2 * math.pi / 3,  -- Northwest (120°)
        math.pi,          -- West (180°)
        4 * math.pi / 3,  -- Southwest (240°)
        5 * math.pi / 3   -- Southeast (300°)
    }

    -- Controls
    self.rotationSpeed = math.pi / 2  -- 90° per second
    self.pitchSpeed = math.pi / 3     -- 60° per second

    -- Minimap
    self.minimapSize = 150
    self.minimapX = screenW - self.minimapSize - 10
    self.minimapY = 10

    print("[View3D] 3D viewer initialized - Press SPACE to toggle 2D/3D")
    return self
end

---Toggle between 2D and 3D views
function View3D:toggleMode()
    self.enabled = not self.enabled
    print(string.format("[View3D] Mode switched to %s view", self.enabled and "3D" or "2D"))
end

---Set camera from unit position
---@param unit table Unit with position {q, r}
function View3D:setCameraFromUnit(unit)
    if unit and unit.position then
        self.cameraQ = unit.position.q or 45
        self.cameraR = unit.position.r or 45
        print(string.format("[View3D] Camera positioned at (%d, %d)",
            self.cameraQ, self.cameraR))
    end
end

---Update 3D viewer state
---@param dt number Delta time in seconds
function View3D:update(dt)
    if not self.enabled or not self.raycaster then return end

    -- WASD rotation (60° increments for hex grid)
    local angleChange = 0

    if love.keyboard.isDown("w") then
        -- Rotate left 60°
        angleChange = -math.pi / 3
    end
    if love.keyboard.isDown("s") then
        -- Rotate right 60°
        angleChange = math.pi / 3
    end
    if love.keyboard.isDown("a") then
        -- Rotate left 30°
        angleChange = -math.pi / 6
    end
    if love.keyboard.isDown("d") then
        -- Rotate right 30°
        angleChange = math.pi / 6
    end

    if angleChange ~= 0 then
        self.cameraAngle = self.cameraAngle + angleChange
        -- Normalize to 0-2π
        self.cameraAngle = self.cameraAngle % (2 * math.pi)
    end

    -- Q/E for pitch (vertical look)
    if love.keyboard.isDown("q") then
        self.cameraPitch = math.max(self.cameraPitch - self.pitchSpeed * dt, -math.pi / 2)
    end
    if love.keyboard.isDown("e") then
        self.cameraPitch = math.min(self.cameraPitch + self.pitchSpeed * dt, math.pi / 2)
    end

    -- Update raycaster camera
    if self.raycaster then
        self.raycaster:setCamera(self.cameraQ, self.cameraR, self.cameraAngle)
        self.raycaster:setNight(self.battlescape.isNight or false)
    end

    -- Prepare billboards for rendering
    if self.billboardRenderer then
        self.billboardRenderer:clear()

        -- Add all visible units as billboards
        if self.battlescape.units then
            for _, unit in ipairs(self.battlescape.units) do
                if unit and unit.alive then
                    self.billboardRenderer:addUnitBillboard(
                        unit,
                        self.cameraQ, self.cameraR, 0.5,  -- camera position
                        self.cameraAngle, self.cameraPitch,  -- camera orientation
                        self.raycaster,  -- raycaster for calculations
                        love.graphics.getWidth(), love.graphics.getHeight(),  -- viewport
                        nil  -- assetManager (optional)
                    )
                end
            end
        end
    end

    -- Update effects animations
    if self.effectsRenderer then
        self.effectsRenderer:update(dt)

        -- Optionally apply LOS visibility culling to effects
        if self.battlescape.losSystem and self.battlescape.turnManager then
            local viewerTeam = self.battlescape.turnManager:getCurrentTeam()
            for _, effect in ipairs(self.effectsRenderer.effects) do
                if effect and viewerTeam then
                    local visibility = self.battlescape.losSystem:getVisibility(viewerTeam, effect.x, effect.y)
                    -- Dim effect if partially visible, hide if hidden
                    if visibility == "partially" then
                        effect.opacity = (effect.opacity or 1.0) * 0.6
                    elseif visibility == "hidden" or not visibility then
                        effect.opacity = 0  -- Hidden from view
                    end
                end
            end
        end
    end

    -- Update shooting system (clean up effects)
    if self.shootingSystem3D then
        self.shootingSystem3D:update(dt)
    end
end

---Draw 3D view
function View3D:draw()
    if not self.enabled or not self.raycaster then return end

    love.graphics.push()

    -- Draw 3D raycasted view
    self.raycaster:draw()

    -- Draw effects with optimization (Phase 5: Frustum culling + LOD)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    if self.effectsRenderer then
        self.effectsRenderer:drawEffectsOptimized(self.cameraAngle, self.cameraPitch, screenW, screenH)
    end

    -- Draw ground items
    if self.billboardRenderer then
        self.billboardRenderer:drawItems(nil)
    end

    -- Draw unit billboards
    if self.billboardRenderer then
        self.billboardRenderer:drawBillboards(nil, self.battlescape.losSystem, self.battlescape.turnManager and self.battlescape.turnManager:getCurrentTeam())
    end

    -- Draw shooting effects (muzzle flash, tracers, hit markers)
    if self.shootingSystem3D then
        self.shootingSystem3D:drawEffects()
    end

    -- Draw minimap in corner
    self:drawMinimap()

    -- Draw HUD overlay
    self:drawHUD()

    love.graphics.pop()
end

---Draw minimap
function View3D:drawMinimap()
    love.graphics.push()

    -- Minimap background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill",
        self.minimapX, self.minimapY,
        self.minimapSize, self.minimapSize)

    -- Minimap border
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line",
        self.minimapX, self.minimapY,
        self.minimapSize, self.minimapSize)

    -- Player position (center)
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill",
        self.minimapX + self.minimapSize / 2,
        self.minimapY + self.minimapSize / 2,
        4)

    -- Direction indicator
    local angle = self.cameraAngle
    local dx = math.cos(angle) * 20
    local dy = math.sin(angle) * 20
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(
        self.minimapX + self.minimapSize / 2,
        self.minimapY + self.minimapSize / 2,
        self.minimapX + self.minimapSize / 2 + dx,
        self.minimapY + self.minimapSize / 2 + dy)

    love.graphics.pop()
end

---Draw HUD overlay
function View3D:drawHUD()
    love.graphics.push()

    -- Crosshair
    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() / 2
    love.graphics.setColor(0, 1, 0, 0.7)
    love.graphics.line(centerX - 10, centerY, centerX + 10, centerY)
    love.graphics.line(centerX, centerY - 10, centerX, centerY + 10)

    -- Mode indicator
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("[3D MODE] SPACE=Toggle 2D  WASD=Rotate  Q/E=Look  SPACE=Fire",
        10, 10)

    -- Camera info (debug)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(string.format("Pos: (%.0f, %.0f) Angle: %.0f°",
        self.cameraQ, self.cameraR, math.deg(self.cameraAngle)),
        10, 30)

    -- Phase 5: Performance metrics (if optimizer available)
    if self.effectsRenderer and self.effectsRenderer.optimizer then
        local stats = self.effectsRenderer.optimizer:getStats()
        love.graphics.setColor(0, 1, 0, 0.8)
        love.graphics.printf(
            string.format("PERF: Rendered=%d Culled=%d Pool=%d/%d Cull=%.1f%%",
                stats.effectsRendered,
                stats.effectsCulled,
                stats.poolActive,
                stats.poolActive + stats.poolInactive,
                stats.cullingRatio * 100),
            10, 50, 600, "left"
        )
    end

    love.graphics.pop()
end

---Get camera position
---@return number q, number r, number angle
function View3D:getCamera()
    return self.cameraQ, self.cameraR, self.cameraAngle
end

---Is 3D mode enabled
---@return boolean enabled
function View3D:isEnabled()
    return self.enabled
end

---Perform a 3D shot at screen coordinates
---@param screenX number Screen X coordinate
---@param screenY number Screen Y coordinate
---@param shootingUnit table Unit doing the shooting
---@param targetSystem table Target system reference
---@param losSystem table LOS system reference
---@param battlefieldSystem table Battlefield system reference
---@return table Result with shot outcome
function View3D:shoot3D(screenX, screenY, shootingUnit, targetSystem, losSystem, battlefieldSystem)
    if not self.shootingSystem3D or not shootingUnit then
        return {
            success = false,
            reason = "Not ready to shoot"
        }
    end

    return self.shootingSystem3D:shoot(
        screenX, screenY,
        shootingUnit,
        targetSystem,
        losSystem,
        battlefieldSystem,
        self.cameraAngle,
        self.cameraPitch,
        self.raycaster,
        self.effectsRenderer,
        self.billboardRenderer
    )
end

return View3D

