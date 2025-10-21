---HUDOverlay - First-Person Combat HUD Display
---
---Displays real-time tactical information for first-person battlescape view.
---Shows crosshair, target info, unit stats, ammo count, minimap, and objectives.
---Integrates with renderer_3d.lua for overlay composition.
---
---Features:
---  - Dynamic crosshair (changes based on accuracy/stance)
---  - Target reticle with distance/range indicator
---  - Weapon ammo counter with magazine display
---  - Unit health/armor/TU display with status indicators
---  - Enemy detection bar (threat level)
---  - Minimap with unit positions and LOS
---  - Objective tracker with mission progress
---  - Motion tracker (movement detection)
---  - Diagnostic mode (showing coordinates, FPS, debug info)
---
---HUD Layout (960×720 screen):
---  - Center: Crosshair (±30px cross) with accuracy circle
---  - Top-left: Ammo counter, weapon name
---  - Top-right: Objective, timer
---  - Bottom-left: Unit health, armor, TU bars
---  - Bottom-right: Minimap (160×120px)
---  - Center-top: Target info when aiming
---  - Left-edge: Motion tracker (vertical bar)
---
---Colors:
---  - Ammo ready: Green, Low: Yellow, Critical: Red
---  - Health: Green-Yellow-Red gradient
---  - Armor: Blue
---  - TU: Yellow
---  - Threat: Red intensity indicates danger level
---  - Minimap: Green (player), Red (enemies), Blue (allies)
---
---Key Exports:
---  - HUDOverlay.new(scene): Creates HUD
---  - setUnitStats(health, armor, tu, status): Update player stats
---  - setTarget(enemyData): Set current target
---  - setWeapon(ammo, magazine, weaponName): Update weapon display
---  - update(dt): Update animations
---  - draw(): Render HUD
---  - setDiagnosticMode(enabled): Show debug info
---
---Dependencies:
---  - battlescape.systems.pathfinding: For range info
---  - love.graphics: Rendering
---
---@module battlescape.ui.hud_overlay
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local HUDOverlay = require("battlescape.ui.hud_overlay")
---  local hud = HUDOverlay.new()
---  hud:setUnitStats(100, 50, 75)
---  hud:setWeapon(30, 5, "Rifle")
---  hud:draw()
---
---@see battlescape.rendering.renderer_3d For HUD composition

local HUDOverlay = {}

---@class HUDOverlay
---@field unitStats table Player unit stats {health, armor, tu, status}
---@field target table Current target data {x, y, name, threat}
---@field weapon table Weapon info {ammo, magazine, name, type}
---@field colors table Color definitions
---@field minimap table Minimap data {width, height, units}
---@field screenWidth number Screen width (960)
---@field screenHeight number Screen height (720)
---@field diagnosticMode boolean Show debug info
---@field crosshairAccuracy number Crosshair spread (0-1)
---@field threatLevel number Threat level (0-1)
---@field initialized boolean

---Create HUD overlay system
---@return HUDOverlay HUD instance
function HUDOverlay.new()
    local self = setmetatable({}, {__index = HUDOverlay})
    
    self.unitStats = {
        health = 100,
        armor = 50,
        tu = 75,
        status = "ready"
    }
    
    self.target = nil
    
    self.weapon = {
        ammo = 30,
        magazine = 5,
        name = "Rifle",
        type = "bullet"
    }
    
    self.colors = {
        crosshair = {0.2, 1.0, 0.2},       -- Green
        target = {1.0, 0.2, 0.2},          -- Red
        health = {0.2, 1.0, 0.2},          -- Green
        armor = {0.2, 0.5, 1.0},           -- Blue
        tu = {1.0, 1.0, 0.2},              -- Yellow
        ammo_ready = {0.2, 1.0, 0.2},      -- Green
        ammo_low = {1.0, 1.0, 0.2},        -- Yellow
        ammo_critical = {1.0, 0.2, 0.2},   -- Red
        threat = {1.0, 0.1, 0.1},          -- Red
        text = {1.0, 1.0, 1.0},            -- White
        background = {0.0, 0.0, 0.0, 0.7}, -- Black semi-transparent
    }
    
    self.screenWidth = 960
    self.screenHeight = 720
    self.diagnosticMode = false
    self.crosshairAccuracy = 0.5  -- 0 = tight, 1 = spread
    self.threatLevel = 0.0
    self.minimapZoom = 4  -- Pixels per hex tile
    
    self.initialized = true
    
    print("[HUDOverlay] Initialized")
    
    return self
end

---Set player unit stats
---@param health number Health (0-100)
---@param armor number Armor value (0-100)
---@param tu number Time Units remaining (0-100+)
---@param status string Unit status ("ready", "wounded", "stunned", "dead")
function HUDOverlay:setUnitStats(health, armor, tu, status)
    self.unitStats = {
        health = math.max(0, math.min(100, health or 100)),
        armor = math.max(0, math.min(100, armor or 50)),
        tu = math.max(0, tu or 75),
        status = status or "ready"
    }
end

---Set current target
---@param targetData table Target info {x, y, name, threat, distance, health}
function HUDOverlay:setTarget(targetData)
    self.target = targetData
    
    if targetData then
        print(string.format("[HUDOverlay] Target: %s at distance %.1f",
            targetData.name or "Unknown", targetData.distance or 0))
    end
end

---Clear current target
function HUDOverlay:clearTarget()
    self.target = nil
end

---Set weapon information
---@param ammo number Current ammo (rounds)
---@param magazine number Magazine capacity
---@param weaponName string Weapon name
---@param weaponType string Weapon type ("bullet", "energy", "explosive")
function HUDOverlay:setWeapon(ammo, magazine, weaponName, weaponType)
    self.weapon = {
        ammo = ammo or 0,
        magazine = magazine or 30,
        name = weaponName or "Weapon",
        type = weaponType or "bullet"
    }
end

---Set crosshair accuracy spread
---@param accuracy number Accuracy value (0-1, 0=tight, 1=spread)
function HUDOverlay:setAccuracy(accuracy)
    self.crosshairAccuracy = math.max(0, math.min(1, accuracy or 0.5))
end

---Set threat level
---@param threat number Threat level (0-1)
function HUDOverlay:setThreatLevel(threat)
    self.threatLevel = math.max(0, math.min(1, threat or 0))
end

---Toggle diagnostic mode (debug info display)
function HUDOverlay:setDiagnosticMode(enabled)
    self.diagnosticMode = enabled or false
    print(string.format("[HUDOverlay] Diagnostic mode: %s",
        self.diagnosticMode and "ON" or "OFF"))
end

---Update HUD animations
---@param dt number Delta time in seconds
function HUDOverlay:update(dt)
    -- Could add animations/pulsing effects here
    -- For now, minimal updates needed
end

---Draw entire HUD overlay
function HUDOverlay:draw()
    if not self.initialized then
        return
    end
    
    -- Draw background elements (bars, panels)
    self:drawUnitStats()
    self:drawWeaponInfo()
    self:drawMinimap()
    self:drawObjectiveTracker()
    
    -- Draw center elements (crosshair, target)
    self:drawCrosshair()
    if self.target then
        self:drawTargetInfo()
    end
    
    -- Draw motion tracker
    self:drawMotionTracker()
    
    -- Debug info if enabled
    if self.diagnosticMode then
        self:drawDiagnostics()
    end
end

---Draw player unit stats (health, armor, TU)
function HUDOverlay:drawUnitStats()
    local startX = 10
    local startY = self.screenHeight - 90
    local barWidth = 150
    local barHeight = 12
    
    -- Background panel
    love.graphics.setColor(self.colors.background[1], self.colors.background[2],
        self.colors.background[3], self.colors.background[4])
    love.graphics.rectangle("fill", startX - 5, startY - 5, barWidth + 10, 80)
    
    -- Health bar
    love.graphics.setColor(self.colors.health)
    local healthRatio = self.unitStats.health / 100
    love.graphics.rectangle("fill", startX, startY, barWidth * healthRatio, barHeight)
    love.graphics.setColor(self.colors.text)
    love.graphics.rectangle("line", startX, startY, barWidth, barHeight)
    love.graphics.print(string.format("HP: %d", self.unitStats.health), startX + 5, startY + 15)
    
    -- Armor bar
    love.graphics.setColor(self.colors.armor)
    local armorRatio = self.unitStats.armor / 100
    love.graphics.rectangle("fill", startX, startY + 30, barWidth * armorRatio, barHeight)
    love.graphics.setColor(self.colors.text)
    love.graphics.rectangle("line", startX, startY + 30, barWidth, barHeight)
    love.graphics.print(string.format("ARM: %d", self.unitStats.armor), startX + 5, startY + 45)
    
    -- TU bar
    love.graphics.setColor(self.colors.tu)
    local tuRatio = math.min(1.0, self.unitStats.tu / 100)
    love.graphics.rectangle("fill", startX, startY + 60, barWidth * tuRatio, barHeight)
    love.graphics.setColor(self.colors.text)
    love.graphics.rectangle("line", startX, startY + 60, barWidth, barHeight)
    love.graphics.print(string.format("TU: %.0f", self.unitStats.tu), startX + 5, startY + 75)
    
    love.graphics.setColor(1, 1, 1)
end

---Draw weapon information
function HUDOverlay:drawWeaponInfo()
    local startX = self.screenWidth - 160
    local startY = 10
    
    -- Background
    love.graphics.setColor(self.colors.background[1], self.colors.background[2],
        self.colors.background[3], self.colors.background[4])
    love.graphics.rectangle("fill", startX - 5, startY - 5, 160, 70)
    
    -- Weapon name
    love.graphics.setColor(self.colors.text)
    love.graphics.print(self.weapon.name, startX + 5, startY + 5)
    
    -- Ammo counter
    local ammoColor = self.colors.ammo_ready
    if self.weapon.ammo < self.weapon.magazine / 3 then
        ammoColor = self.colors.ammo_critical
    elseif self.weapon.ammo < self.weapon.magazine / 2 then
        ammoColor = self.colors.ammo_low
    end
    
    love.graphics.setColor(ammoColor)
    local ammoText = string.format("%d / %d", self.weapon.ammo, self.weapon.magazine)
    love.graphics.print(ammoText, startX + 5, startY + 25)
    
    -- Ammo bar
    local barWidth = 140
    local barHeight = 10
    local ammoRatio = self.weapon.ammo / (self.weapon.magazine * 5)  -- Magazine capacity as max
    love.graphics.rectangle("fill", startX + 5, startY + 45, barWidth * ammoRatio, barHeight)
    love.graphics.setColor(self.colors.text)
    love.graphics.rectangle("line", startX + 5, startY + 45, barWidth, barHeight)
    
    love.graphics.setColor(1, 1, 1)
end

---Draw center crosshair
function HUDOverlay:drawCrosshair()
    local centerX = self.screenWidth / 2
    local centerY = self.screenHeight / 2
    
    -- Base crosshair size
    local size = 15
    local spread = size * self.crosshairAccuracy  -- Spread based on accuracy
    
    love.graphics.setColor(self.colors.crosshair)
    love.graphics.setLineWidth(2)
    
    -- Horizontal line
    love.graphics.line(centerX - size - spread, centerY, centerX + size + spread, centerY)
    
    -- Vertical line
    love.graphics.line(centerX, centerY - size - spread, centerX, centerY + size + spread)
    
    -- Center dot
    love.graphics.circle("fill", centerX, centerY, 2)
    
    -- Accuracy circle (if not perfect accuracy)
    if self.crosshairAccuracy > 0.1 then
        local circleRadius = 30 + (spread * 2)
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", centerX, centerY, circleRadius)
    end
    
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

---Draw target information
function HUDOverlay:drawTargetInfo()
    if not self.target then
        return
    end
    
    local centerX = self.screenWidth / 2
    local startY = 10
    
    -- Target box
    love.graphics.setColor(self.colors.background[1], self.colors.background[2],
        self.colors.background[3], self.colors.background[4])
    love.graphics.rectangle("fill", centerX - 80, startY, 160, 60)
    
    -- Target name
    love.graphics.setColor(self.colors.target)
    love.graphics.printf(self.target.name or "Target", centerX - 75, startY + 5, 150, "center")
    
    -- Distance
    love.graphics.setColor(self.colors.text)
    local distText = string.format("Distance: %.1f", self.target.distance or 0)
    love.graphics.printf(distText, centerX - 75, startY + 20, 150, "center")
    
    -- Threat indicator
    if self.target.threat then
        local threatText = string.format("Threat: %.0f%%", self.target.threat * 100)
        love.graphics.setColor(self.colors.threat)
        love.graphics.printf(threatText, centerX - 75, startY + 35, 150, "center")
    end
    
    love.graphics.setColor(1, 1, 1)
end

---Draw minimap
function HUDOverlay:drawMinimap()
    local mapX = self.screenWidth - 170
    local mapY = self.screenHeight - 130
    local mapWidth = 160
    local mapHeight = 120
    
    -- Background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", mapX, mapY, mapWidth, mapHeight)
    
    -- Border
    love.graphics.setColor(self.colors.text)
    love.graphics.rectangle("line", mapX, mapY, mapWidth, mapHeight)
    
    -- Grid
    love.graphics.setColor(0.3, 0.3, 0.3)
    for i = 0, 4 do
        love.graphics.line(mapX + (i * mapWidth / 4), mapY, 
            mapX + (i * mapWidth / 4), mapY + mapHeight)
        love.graphics.line(mapX, mapY + (i * mapHeight / 4),
            mapX + mapWidth, mapY + (i * mapHeight / 4))
    end
    
    -- Player position (center)
    love.graphics.setColor(self.colors.health)
    love.graphics.circle("fill", mapX + mapWidth / 2, mapY + mapHeight / 2, 3)
    
    -- LOS indicator (range circle)
    love.graphics.setColor(self.colors.health[1], self.colors.health[2], 
        self.colors.health[3], 0.2)
    love.graphics.circle("line", mapX + mapWidth / 2, mapY + mapHeight / 2, 
        mapWidth / 3)
    
    love.graphics.setColor(1, 1, 1)
end

---Draw objective/mission tracker
function HUDOverlay:drawObjectiveTracker()
    local startX = 10
    local startY = 10
    
    -- Background
    love.graphics.setColor(self.colors.background[1], self.colors.background[2],
        self.colors.background[3], self.colors.background[4])
    love.graphics.rectangle("fill", startX - 5, startY - 5, 200, 70)
    
    -- Objective title
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Objective:", startX + 5, startY + 5)
    
    -- Objective text (placeholder)
    love.graphics.setColor(1.0, 1.0, 0.5)
    love.graphics.printf("Clear area", startX + 5, startY + 20, 190, "left")
    
    -- Progress indicator
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Enemies: 5/10", startX + 5, startY + 40)
    
    love.graphics.setColor(1, 1, 1)
end

---Draw motion tracker (threat warning)
function HUDOverlay:drawMotionTracker()
    local startX = 10
    local startY = self.screenHeight / 2 - 40
    local width = 30
    local height = 80
    
    -- Background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", startX, startY, width, height)
    
    -- Border
    love.graphics.setColor(self.colors.text)
    love.graphics.rectangle("line", startX, startY, width, height)
    
    -- Threat indicator bar
    local threatHeight = height * self.threatLevel
    if self.threatLevel > 0 then
        love.graphics.setColor(1.0, 0.2 + (self.threatLevel * 0.8), 0.2)
        love.graphics.rectangle("fill", startX + 2, startY + height - threatHeight - 2,
            width - 4, threatHeight)
    end
    
    love.graphics.setColor(1, 1, 1)
end

---Draw diagnostic/debug information
function HUDOverlay:drawDiagnostics()
    local debugY = 60
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.print(string.format("FPS: %.0f", love.timer.getFPS()), 10, debugY)
    love.graphics.print(string.format("Accuracy: %.2f", self.crosshairAccuracy), 10, debugY + 15)
    love.graphics.print(string.format("Threat: %.2f", self.threatLevel), 10, debugY + 30)
    
    if self.target then
        love.graphics.print(string.format("Target: %s", self.target.name or "Unknown"),
            10, debugY + 45)
        love.graphics.print(string.format("Distance: %.1f", self.target.distance or 0),
            10, debugY + 60)
    end
    
    love.graphics.setColor(1, 1, 1)
end

return HUDOverlay



