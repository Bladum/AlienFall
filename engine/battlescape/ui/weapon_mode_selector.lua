---WeaponModeSelector - Weapon Firing Mode Selection Widget
---
---Compact widget for selecting weapon firing modes (SNAP, AIM, LONG, AUTO, HEAVY, FINESSE)
---with validation against weapon capabilities. Displays available modes as buttons with
---stat previews and handles mode switching with callbacks.
---
---Features:
---  - Dynamic mode availability based on weapon type
---  - Visual mode buttons with stat tooltips
---  - Mode validation and automatic fallback
---  - Callback system for mode change events
---  - Compact overlay design for battlescape UI
---  - Integration with weapon system and mode definitions
---
---Key Exports:
---  - new(x, y, width, height): Create new mode selector widget
---  - setWeapon(weaponId): Set weapon to display modes for
---  - setMode(mode): Set currently selected firing mode
---  - getMode(): Get currently selected mode
---  - update(dt): Update animations and hover states
---  - draw(): Render the mode selector interface
---  - mousepressed(x, y, button): Handle mode selection
---  - keypressed(key): Handle keyboard shortcuts
---
---Dependencies:
---  - require("battlescape.combat.weapon_system"): Weapon definitions and mode validation
---  - require("battlescape.combat.weapon_modes"): Mode definitions and statistics
---
---@module battlescape.ui.weapon_mode_selector
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local WeaponModeSelector = require("battlescape.ui.weapon_mode_selector")
---  local selector = WeaponModeSelector.new(800, 600, 160, 120)
---  selector:setWeapon("rifle")
---  selector.onModeChanged = function(mode) print("Mode changed to:", mode) end
---
---@see battlescape.combat.weapon_system For weapon definitions
---@see battlescape.combat.weapon_modes For firing mode definitions

---@meta

---@class WeaponModeSelector
---@field x number
---@field y number
---@field width number
---@field height number
---@field weapon string|nil -- Weapon ID currently selected
---@field selectedMode string -- Currently selected mode (SNAP, AIM, etc.)
---@field onModeChanged function|nil -- Callback: function(mode)
---@field visible boolean
---@field enabled boolean
local WeaponModeSelector = {}
WeaponModeSelector.__index = WeaponModeSelector

-- Dependencies
local WeaponSystem = require("battlescape.combat.weapon_system")
local WeaponModes = require("battlescape.combat.weapon_modes")

---Create new weapon mode selector widget
---@param x number X position
---@param y number Y position
---@param width number Width (default 240)
---@param height number Height (default 180)
---@return WeaponModeSelector
function WeaponModeSelector.new(x, y, width, height)
    local self = setmetatable({}, WeaponModeSelector)
    
    self.x = x or 0
    self.y = y or 0
    self.width = width or 240
    self.height = height or 180
    self.weapon = nil
    self.selectedMode = "SNAP" -- Default mode
    self.onModeChanged = nil
    self.visible = true
    self.enabled = true
    
    return self
end

---Set the weapon to display modes for
---@param weaponId string|nil Weapon ID or nil to clear
function WeaponModeSelector:setWeapon(weaponId)
    self.weapon = weaponId
    
    -- Ensure selected mode is valid for this weapon
    if weaponId then
        local availableModes = WeaponSystem.getAvailableModes(weaponId)
        if not WeaponSystem.isModeAvailable(weaponId, self.selectedMode) then
            -- Reset to first available mode
            self.selectedMode = availableModes[1] or "SNAP"
        end
    end
end

---Set the currently selected mode
---@param mode string Mode name (SNAP, AIM, LONG, AUTO, HEAVY, FINESSE)
function WeaponModeSelector:setMode(mode)
    if not self.weapon then return end
    
    -- Validate mode is available
    if WeaponSystem.isModeAvailable(self.weapon, mode) then
        self.selectedMode = mode
        
        -- Trigger callback
        if self.onModeChanged then
            self.onModeChanged(mode)
        end
    else
        print("[WeaponModeSelector] Mode not available: " .. mode .. " for weapon: " .. self.weapon)
    end
end

---Get currently selected mode
---@return string Current mode name
function WeaponModeSelector:getMode()
    return self.selectedMode
end

---Handle mouse click
---@param mx number Mouse X
---@param my number Mouse Y
---@return boolean True if click was handled
function WeaponModeSelector:onClick(mx, my)
    if not self.visible or not self.enabled or not self.weapon then
        return false
    end
    
    -- Check if click is within bounds
    if mx < self.x or mx > self.x + self.width or
       my < self.y or my > self.y + self.height then
        return false
    end
    
    -- Get available modes
    local modes = WeaponSystem.getAvailableModes(self.weapon)
    if #modes == 0 then return false end
    
    -- Calculate button layout (2 columns, 3 rows max)
    local buttonWidth = (self.width - 20) / 2
    local buttonHeight = 48
    local padding = 8
    local startY = self.y + 40 -- Leave space for title
    
    -- Check which mode button was clicked
    for i, mode in ipairs(modes) do
        local col = ((i - 1) % 2)
        local row = math.floor((i - 1) / 2)
        
        local btnX = self.x + 10 + col * (buttonWidth + padding)
        local btnY = startY + row * (buttonHeight + padding)
        
        if mx >= btnX and mx <= btnX + buttonWidth and
           my >= btnY and my <= btnY + buttonHeight then
            -- Clicked this mode button
            self:setMode(mode)
            return true
        end
    end
    
    return false
end

---Draw the widget
function WeaponModeSelector:draw()
    if not self.visible or not self.weapon then
        return
    end
    
    local love = love
    local g = love.graphics
    
    -- Get available modes
    local modes = WeaponSystem.getAvailableModes(self.weapon)
    if #modes == 0 then return end
    
    -- Background panel
    g.setColor(0.2, 0.2, 0.3, 0.95)
    g.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Border
    g.setColor(0.4, 0.6, 0.8, 1.0)
    g.setLineWidth(2)
    g.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Title
    g.setColor(1.0, 1.0, 1.0, 1.0)
    g.print("FIRING MODE", self.x + 10, self.y + 10)
    
    -- Draw mode buttons (2 columns, 3 rows max)
    local buttonWidth = (self.width - 20) / 2
    local buttonHeight = 48
    local padding = 8
    local startY = self.y + 40
    
    for i, mode in ipairs(modes) do
        local col = ((i - 1) % 2)
        local row = math.floor((i - 1) / 2)
        
        local btnX = self.x + 10 + col * (buttonWidth + padding)
        local btnY = startY + row * (buttonHeight + padding)
        
        -- Button background
        local isSelected = (mode == self.selectedMode)
        if isSelected then
            g.setColor(0.3, 0.5, 0.8, 1.0) -- Highlight selected
        else
            g.setColor(0.25, 0.25, 0.35, 1.0)
        end
        g.rectangle("fill", btnX, btnY, buttonWidth, buttonHeight)
        
        -- Button border
        if isSelected then
            g.setColor(0.5, 0.7, 1.0, 1.0)
            g.setLineWidth(3)
        else
            g.setColor(0.4, 0.4, 0.5, 1.0)
            g.setLineWidth(1)
        end
        g.rectangle("line", btnX, btnY, buttonWidth, buttonHeight)
        
        -- Mode info
        local modeData = WeaponModes.getModeData(mode)
        if modeData then
            -- Mode name
            g.setColor(1.0, 1.0, 1.0, 1.0)
            g.print(modeData.name, btnX + 5, btnY + 5)
            
            -- AP/EP cost
            local apMod = modeData.apCostMod or 1.0
            local epMod = modeData.epCostMod or 1.0
            local apColor = apMod < 1.0 and {0.4, 1.0, 0.4} or apMod > 1.0 and {1.0, 0.4, 0.4} or {0.8, 0.8, 0.8}
            g.setColor(apColor)
            g.print(string.format("AP: %.0f%%", apMod * 100), btnX + 5, btnY + 22)
            
            -- Accuracy modifier
            local accMod = modeData.accuracyMod or 1.0
            local accColor = accMod > 1.0 and {0.4, 1.0, 0.4} or accMod < 1.0 and {1.0, 0.4, 0.4} or {0.8, 0.8, 0.8}
            g.setColor(accColor)
            g.print(string.format("Acc: %.0f%%", accMod * 100), btnX + buttonWidth/2, btnY + 22)
        end
    end
    
    -- Reset color
    g.setColor(1.0, 1.0, 1.0, 1.0)
end

---Set visibility
---@param visible boolean
function WeaponModeSelector:setVisible(visible)
    self.visible = visible
end

---Set enabled state
---@param enabled boolean
function WeaponModeSelector:setEnabled(enabled)
    self.enabled = enabled
end

---Check if point is inside widget
---@param x number
---@param y number
---@return boolean
function WeaponModeSelector:containsPoint(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

return WeaponModeSelector






















