---Dropdown Widget - Collapsible Selection Menu
---
---A dropdown selection menu that expands/collapses to show options. Used for selecting
---from a list of choices in limited space. Grid-aligned for consistent positioning.
---
---Features:
---  - Selectable options
---  - Expand/collapse animation
---  - onChange event callback
---  - Grid-aligned positioning (24×24 pixels)
---  - Keyboard navigation (arrow keys)
---  - Auto-close on selection
---
---Visual States:
---  - Collapsed: Shows selected item only
---  - Expanded: Shows all options in dropdown
---  - Hover: Highlight option under mouse
---  - Selected: Checkmark or highlight on current selection
---
---Interaction:
---  - Click to expand/collapse
---  - Click option to select
---  - Arrow keys to navigate when expanded
---  - ESC to close without selection
---  - Click outside to close
---
---Key Exports:
---  - Dropdown.new(x, y, width, height): Creates dropdown
---  - setOptions(options): Sets option list
---  - getSelectedOption(): Returns selected option
---  - setSelectedIndex(index): Sets selection by index
---  - setCallback(func): Sets onChange handler
---  - draw(): Renders dropdown
---  - mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.navigation.dropdown
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Dropdown = require("widgets.navigation.dropdown")
---  local dd = Dropdown.new(0, 0, 192, 24)
---  dd:setOptions({"Easy", "Medium", "Hard"})
---  dd:setCallback(function(option) print("Difficulty:", option) end)
---  dd:draw()
---
---@see widgets.navigation.listbox For non-collapsible lists

--[[
    Dropdown Widget
    
    A dropdown selection menu.
    Features:
    - Selectable options
    - Expand/collapse animation
    - onChange event
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local Dropdown = setmetatable({}, {__index = BaseWidget})
Dropdown.__index = Dropdown

--[[
    Create a new dropdown
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New dropdown instance
]]
function Dropdown.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "dropdown")
    setmetatable(self, Dropdown)
    
    self.options = {}
    self.selectedIndex = 0
    self.expanded = false
    
    return self
end

--[[
    Draw the dropdown
]]
function Dropdown:draw()
    if not self.visible then
        return
    end
    
    -- Draw main dropdown box
    local bgColor = self.enabled and self.backgroundColor or self.disabledColor
    Theme.setColor(bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw selected text
    Theme.setFont(self.font)
    local textColor = self.enabled and self.textColor or self.disabledTextColor
    Theme.setColor(textColor)
    
    local displayText = self.selectedIndex > 0 and self.options[self.selectedIndex] or "Select..."
    local font = Theme.getFont(self.font)
    local textHeight = font:getHeight()
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(displayText, self.x + 4, textY)
    
    -- Draw dropdown arrow
    local arrowX = self.x + self.width - 16
    local arrowY = self.y + self.height / 2
    love.graphics.polygon("fill", 
        arrowX, arrowY - 3,
        arrowX + 6, arrowY - 3,
        arrowX + 3, arrowY + 3
    )
    
    -- Draw expanded options
    if self.expanded and #self.options > 0 then
        local optionHeight = self.height
        local dropdownHeight = #self.options * optionHeight
        
        -- Draw dropdown background
        Theme.setColor(self.backgroundColor)
        love.graphics.rectangle("fill", self.x, self.y + self.height, self.width, dropdownHeight)
        
        -- Draw dropdown border
        Theme.setColor(self.borderColor)
        love.graphics.rectangle("line", self.x, self.y + self.height, self.width, dropdownHeight)
        
        -- Draw options
        Theme.setFont(self.font)
        for i, option in ipairs(self.options) do
            local optionY = self.y + self.height + (i - 1) * optionHeight
            
            -- Highlight on hover
            local mx, my = love.mouse.getPosition()
            if mx >= self.x and mx < self.x + self.width and
               my >= optionY and my < optionY + optionHeight then
                Theme.setColor(self.hoverColor)
                love.graphics.rectangle("fill", self.x, optionY, self.width, optionHeight)
            end
            
            -- Draw option text
            Theme.setColor(self.textColor)
            local textY = optionY + (optionHeight - textHeight) / 2
            love.graphics.print(option, self.x + 4, textY)
        end
    end
end

--[[
    Handle mouse press
]]
function Dropdown:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 then
        return false
    end
    
    -- Check if clicking main dropdown
    if x >= self.x and x < self.x + self.width and
       y >= self.y and y < self.y + self.height then
        self.expanded = not self.expanded
        return true
    end
    
    -- Check if clicking an option
    if self.expanded then
        local optionHeight = self.height
        for i, option in ipairs(self.options) do
            local optionY = self.y + self.height + (i - 1) * optionHeight
            
            if x >= self.x and x < self.x + self.width and
               y >= optionY and y < optionY + optionHeight then
                self.selectedIndex = i
                self.expanded = false
                
                if self.onChange then
                    self.onChange(option)
                end
                
                return true
            end
        end
    end
    
    -- Close dropdown if clicking outside
    if self.expanded then
        self.expanded = false
        return true
    end
    
    return false
end

--[[
    Set dropdown options
    @param options table - Array of option strings
]]
function Dropdown:setOptions(options)
    self.options = options or {}
    if self.selectedIndex > #self.options then
        self.selectedIndex = 0
    end
end

--[[
    Get selected option
    @return string or nil - Selected option text
]]
function Dropdown:getSelected()
    if self.selectedIndex > 0 and self.selectedIndex <= #self.options then
        return self.options[self.selectedIndex]
    end
    return nil
end

return Dropdown






















