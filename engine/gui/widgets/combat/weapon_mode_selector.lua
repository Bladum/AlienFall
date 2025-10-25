---WeaponModeSelector Widget - Firing Mode Selection
---
---Displays 6 firing modes for the current weapon with AP/EP costs and accuracy modifiers.
---Shows which modes are available for the selected weapon and allows mode selection.
---Used in tactical combat for weapon configuration. Grid-aligned for consistent positioning.
---
---Features:
---  - 6 firing mode buttons (SNAP, AIM, LONG, AUTO, HEAVY, FINESSE)
---  - AP cost display per mode
---  - EP (energy points) cost display per mode
---  - Accuracy modifier display
---  - Grid-aligned positioning (24×24 pixels)
---  - Keyboard shortcuts (1-6 keys)
---  - Mode unavailable indicator (grayed out per weapon)
---  - Highlight currently selected mode
---
---Firing Modes:
---  - SNAP: Quick shot (low AP, low accuracy)
---  - AIM: Aimed shot (high AP, high accuracy)
---  - LONG: Long-range shot (very high AP, very high accuracy)
---  - AUTO: Full-auto burst (high AP, low accuracy)
---  - HEAVY: Heavy weapon mode (very high AP, moderate accuracy)
---  - FINESSE: Precision shot (moderate AP, high accuracy)
---
---Layout:
---  - 2 rows × 3 columns of mode buttons
---  - Each button shows: Mode Name, AP/EP costs, Accuracy modifier
---  - 24px grid alignment for all elements
---
---Mode Properties:
---  - Name: Mode name
---  - AP Cost: Action points required
---  - EP Cost: Energy points required
---  - Accuracy: Hit chance modifier (±%)
---  - Available: Can be used with current weapon
---
---Key Exports:
---  - WeaponModeSelector.new(x, y, width, height): Creates selector
---  - setModes(modes): Sets available firing modes
---  - setCurrentAP(ap): Updates available AP
---  - setCurrentEP(ep): Updates available EP
---  - getSelectedMode(): Returns selected mode
---  - setSelectedMode(mode): Selects specific mode
---  - draw(): Renders mode selector
---  - mousepressed(x, y, button): Mode selection
---  - keypressed(key): Keyboard shortcuts (1-6)
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.combat.weapon_mode_selector
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local WeaponModeSelector = require("gui.widgets.combat.weapon_mode_selector")
---  local selector = WeaponModeSelector.new(0, 0, 288, 192)
---  selector:setModes({
---    {name="SNAP", ap=2, ep=0, accuracy=-10, available=true},
---    {name="AIM", ap=4, ep=0, accuracy=+10, available=true},
---    {name="AUTO", ap=6, ep=0, accuracy=-20, available=true}
---  })
---  selector:setCurrentAP(8)
---  selector:draw()
---
---@see widgets.display.action_panel For action buttons

--[[
    Weapon Mode Selector Widget
    
    Displays 6 firing modes for the current weapon with AP/EP costs and accuracy modifiers.
    Shows which modes are available for the selected weapon and allows mode selection.
    
    Features:
    - 6 mode buttons (SNAP, AIM, LONG, AUTO, HEAVY, FINESSE)
    - Displays AP cost, EP cost, accuracy modifier for each mode
    - Grays out unavailable modes per weapon
    - Highlights currently selected mode
    - Grid-aligned (24px grid)
    - Keyboard shortcuts (1-6 keys)
    
    Layout: 2 rows × 3 columns of mode buttons
    Each button shows: Mode Name, AP/EP costs, Accuracy modifier
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")
local WeaponSystem = require("battlescape.combat.weapon_system")
local WeaponModes = require("battlescape.combat.weapon_modes")

local WeaponModeSelector = setmetatable({}, {__index = BaseWidget})
WeaponModeSelector.__index = WeaponModeSelector

-- Mode display names and keyboard shortcuts
local MODE_INFO = {
    {id = "SNAP", name = "Snap Shot", key = "1", description = "Quick shot"},
    {id = "AIM", name = "Aimed Shot", key = "2", description = "Careful aim"},
    {id = "LONG", name = "Long Shot", key = "3", description = "Sniper shot"},
    {id = "AUTO", name = "Auto Fire", key = "4", description = "Burst (5 bullets)"},
    {id = "HEAVY", name = "Heavy Shot", key = "5", description = "Power shot"},
    {id = "FINESSE", name = "Finesse", key = "6", description = "Precision strike"}
}

--[[
    Create a new weapon mode selector
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param weaponId string - Current weapon ID (optional)
    @return table - New weapon mode selector instance
]]
function WeaponModeSelector.new(x, y, weaponId)
    -- Calculate size: 3 columns � 2 rows of mode buttons
    -- Each button: 192�96 pixels (8�4 grid cells)
    -- Total: 576�192 pixels (24�8 grid cells)
    local width = 576  -- 24 grid cells wide
    local height = 192  -- 8 grid cells tall
    
    local self = BaseWidget.new(x, y, width, height, "weapon_mode_selector")
    setmetatable(self, WeaponModeSelector)
    
    self.weaponId = weaponId
    self.selectedMode = "AIM"  -- Default mode
    self.availableModes = {}
    self.onModeSelect = nil  -- Callback: function(mode)
    
    -- Mode button dimensions (8�4 grid cells each)
    self.buttonWidth = 192  -- 8 grid cells
    self.buttonHeight = 96  -- 4 grid cells
    self.buttonSpacing = 0  -- No spacing for compact layout
    
    -- Update available modes
    self:updateWeapon(weaponId)
    
    return self
end

--[[
    Update the weapon and available modes
    @param weaponId string - Weapon ID to display modes for
]]
function WeaponModeSelector:updateWeapon(weaponId)
    self.weaponId = weaponId
    
    if weaponId then
        self.availableModes = WeaponSystem.getAvailableModes(weaponId)
    else
        self.availableModes = {}
    end
    
    -- If current selected mode is not available, switch to first available
    if weaponId and not self:isModeAvailable(self.selectedMode) then
        if #self.availableModes > 0 then
            self.selectedMode = self.availableModes[1]
        else
            self.selectedMode = "AIM"  -- Fallback
        end
    end
end

--[[
    Check if a mode is available for current weapon
    @param mode string - Mode ID (SNAP, AIM, etc.)
    @return boolean - True if mode is available
]]
function WeaponModeSelector:isModeAvailable(mode)
    for _, availableMode in ipairs(self.availableModes) do
        if availableMode == mode then
            return true
        end
    end
    return false
end

--[[
    Set the selected mode
    @param mode string - Mode ID to select
]]
function WeaponModeSelector:setSelectedMode(mode)
    if self:isModeAvailable(mode) then
        self.selectedMode = mode
        if self.onModeSelect then
            self.onModeSelect(mode)
        end
    end
end

--[[
    Get mode statistics for display
    @param mode string - Mode ID
    @return table - {apCost, epCost, accuracyMod, description}
]]
function WeaponModeSelector:getModeStats(mode)
    local modeData = WeaponModes.MODES[mode]
    if not modeData then
        return {apCost = 0, epCost = 0, accuracyMod = 0, description = "Unknown"}
    end
    
    -- Get modifiers
    local apMod = modeData.apMultiplier or 1.0
    local epMod = modeData.epMultiplier or 1.0
    local accMod = modeData.accuracyModifier or 0
    
    -- Format for display
    local apCost = string.format("%.1fx", apMod)
    local epCost = string.format("%.1fx", epMod)
    local accuracyMod = (accMod >= 0) and ("+" .. accMod .. "%") or (accMod .. "%")
    
    -- Get description
    local description = modeData.description or ""
    
    return {
        apCost = apCost,
        epCost = epCost,
        accuracyMod = accuracyMod,
        description = description
    }
end

--[[
    Draw the weapon mode selector
]]
function WeaponModeSelector:draw()
    if not self.visible then
        return
    end
    
    -- Draw background panel
    Theme.setColor(Theme.colors.background)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    Theme.setColor(Theme.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw mode buttons in 2�3 grid
    local row = 0
    local col = 0
    
    for i, modeInfo in ipairs(MODE_INFO) do
        local modeId = modeInfo.id
        local modeName = modeInfo.name
        local modeKey = modeInfo.key
        
        -- Calculate button position
        local buttonX = self.x + col * self.buttonWidth
        local buttonY = self.y + row * self.buttonHeight
        
        -- Check if mode is available
        local isAvailable = self:isModeAvailable(modeId)
        local isSelected = (modeId == self.selectedMode)
        
        -- Draw button background
        local bgColor
        if not isAvailable then
            bgColor = Theme.colors.disabled
        elseif isSelected then
            bgColor = Theme.colors.primary
        elseif self:containsPoint(love.mouse.getPosition()) then
            -- Check if mouse is over this specific button
            local mx, my = love.mouse.getPosition()
            if mx >= buttonX and mx < buttonX + self.buttonWidth and
               my >= buttonY and my < buttonY + self.buttonHeight then
                bgColor = Theme.colors.hover
            else
                bgColor = Theme.colors.secondary
            end
        else
            bgColor = Theme.colors.secondary
        end
        
        Theme.setColor(bgColor)
        love.graphics.rectangle("fill", buttonX, buttonY, self.buttonWidth, self.buttonHeight)
        
        -- Draw button border
        Theme.setColor(Theme.colors.border)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", buttonX, buttonY, self.buttonWidth, self.buttonHeight)
        
        -- Draw mode info text
        if isAvailable then
            Theme.setColor(Theme.colors.text)
        else
            Theme.setColor(Theme.colors.disabledText)
        end
        
        Theme.setFont("default")
        local font = Theme.getFont("default")
        
        -- Mode name + key
        local titleText = string.format("[%s] %s", modeKey, modeName)
        love.graphics.print(titleText, buttonX + 8, buttonY + 8)
        
        -- Get mode stats
        local stats = self:getModeStats(modeId)
        
        -- AP/EP costs
        local costsText = string.format("AP:%s EP:%s", stats.apCost, stats.epCost)
        love.graphics.print(costsText, buttonX + 8, buttonY + 32)
        
        -- Accuracy modifier
        local accText = string.format("Acc: %s", stats.accuracyMod)
        love.graphics.print(accText, buttonX + 8, buttonY + 56)
        
        -- Description (small font)
        Theme.setFont("small")
        love.graphics.print(stats.description, buttonX + 8, buttonY + 76)
        
        -- Move to next position
        col = col + 1
        if col >= 3 then
            col = 0
            row = row + 1
        end
    end
end

--[[
    Handle mouse press
]]
function WeaponModeSelector:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if not self:containsPoint(x, y) or button ~= 1 then
        return false
    end
    
    -- Determine which mode button was clicked
    local relX = x - self.x
    local relY = y - self.y
    
    local col = math.floor(relX / self.buttonWidth)
    local row = math.floor(relY / self.buttonHeight)
    
    -- Calculate mode index (0-5)
    local modeIndex = row * 3 + col + 1
    
    if modeIndex >= 1 and modeIndex <= #MODE_INFO then
        local modeId = MODE_INFO[modeIndex].id
        
        if self:isModeAvailable(modeId) then
            self:setSelectedMode(modeId)
            return true
        end
    end
    
    return false
end

--[[
    Handle keyboard input
]]
function WeaponModeSelector:keypressed(key)
    if not self.visible or not self.enabled then
        return false
    end
    
    -- Check keyboard shortcuts (1-6)
    for i, modeInfo in ipairs(MODE_INFO) do
        if key == modeInfo.key then
            if self:isModeAvailable(modeInfo.id) then
                self:setSelectedMode(modeInfo.id)
                return true
            end
        end
    end
    
    return false
end

return WeaponModeSelector



























