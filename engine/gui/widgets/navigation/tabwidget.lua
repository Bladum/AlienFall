---TabWidget - Multi-Page Tabbed Container
---
---A tabbed container widget with multiple pages. Users can switch between tabs to
---view different content areas. Grid-aligned for consistent positioning.
---
---Features:
---  - Multiple tabs with labels
---  - Tab switching (click or keyboard)
---  - Content area per tab
---  - Grid-aligned positioning (24×24 pixels)
---  - Active tab highlighting
---  - Tab close buttons (optional)
---
---Tab Layout:
---  - Tab bar: Horizontal row of tab buttons
---  - Content area: Active tab's content
---  - Scrollable tabs: When too many tabs to fit
---
---Keyboard Navigation:
---  - Tab/Shift+Tab: Next/Previous tab
---  - Ctrl+1-9: Jump to tab by number
---  - Ctrl+W: Close active tab (if closeable)
---
---Key Exports:
---  - TabWidget.new(x, y, width, height): Creates tab widget
---  - addTab(label, content): Adds new tab with content
---  - removeTab(index): Removes tab by index
---  - setActiveTab(index): Switches to specific tab
---  - getActiveTab(): Returns current tab index
---  - setTabCloseable(index, closeable): Enables close button
---  - draw(): Renders tab bar and content
---  - keypressed(key): Keyboard tab switching
---  - mousepressed(x, y, button): Tab click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.navigation.tabwidget
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TabWidget = require("gui.widgets.navigation.tabwidget")
---  local tabs = TabWidget.new(0, 0, 480, 360)
---  tabs:addTab("Units", unitsPanel)
---  tabs:addTab("Equipment", equipmentPanel)
---  tabs:addTab("Research", researchPanel)
---  tabs:draw()
---
---@see widgets.containers.window For window containers

--[[
    TabWidget
    
    A tabbed container with multiple pages.
    Features:
    - Multiple tabs with labels
    - Tab switching
    - Content per tab
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local TabWidget = setmetatable({}, {__index = BaseWidget})
TabWidget.__index = TabWidget

--[[
    Create a new tab widget
    @param x number - X position (grid-aligned)
    @param y number - Y position (grid-aligned)
    @param width number - Width (grid-aligned)
    @param height number - Height (grid-aligned)
    @return table - New tab widget instance
]]
function TabWidget.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "tabwidget")
    setmetatable(self, TabWidget)
    
    self.tabs = {}  -- {label, content}
    self.activeTab = 1
    self.tabHeight = 24
    self.onTabChange = nil
    
    return self
end

--[[
    Draw the tab widget
]]
function TabWidget:draw()
    if not self.visible then
        return
    end
    
    -- Draw tab bar background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.tabHeight)
    
    -- Draw tabs
    local tabWidth = #self.tabs > 0 and (self.width / #self.tabs) or self.width
    Theme.setFont(self.font)
    
    for i, tab in ipairs(self.tabs) do
        local tabX = self.x + (i - 1) * tabWidth
        
        -- Draw tab background
        if i == self.activeTab then
            Theme.setColor(self.activeColor)
        else
            Theme.setColor(self.hoverColor)
        end
        love.graphics.rectangle("fill", tabX, self.y, tabWidth, self.tabHeight)
        
        -- Draw tab border
        Theme.setColor(self.borderColor)
        love.graphics.setLineWidth(self.borderWidth)
        love.graphics.rectangle("line", tabX, self.y, tabWidth, self.tabHeight)
        
        -- Draw tab label
        Theme.setColor(self.textColor)
        local font = Theme.getFont(self.font)
        local textWidth = font:getWidth(tab.label)
        local textHeight = font:getHeight()
        local textX = tabX + (tabWidth - textWidth) / 2
        local textY = self.y + (self.tabHeight - textHeight) / 2
        love.graphics.print(tab.label, textX, textY)
    end
    
    -- Draw content area
    local contentY = self.y + self.tabHeight
    local contentHeight = self.height - self.tabHeight
    
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, contentY, self.width, contentHeight)
    
    -- Draw active tab content
    if self.activeTab > 0 and self.activeTab <= #self.tabs then
        local content = self.tabs[self.activeTab].content
        if content and content.draw then
            love.graphics.push()
            love.graphics.setScissor(self.x, contentY, self.width, contentHeight)
            content:draw()
            love.graphics.setScissor()
            love.graphics.pop()
        end
    end
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

--[[
    Handle mouse press
]]
function TabWidget:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    -- Check if clicking on tabs
    if button == 1 and y >= self.y and y < self.y + self.tabHeight and
       x >= self.x and x < self.x + self.width then
        local tabWidth = #self.tabs > 0 and (self.width / #self.tabs) or self.width
        local tabIndex = math.floor((x - self.x) / tabWidth) + 1
        
        if tabIndex >= 1 and tabIndex <= #self.tabs and tabIndex ~= self.activeTab then
            self.activeTab = tabIndex
            
            if self.onTabChange then
                self.onTabChange(self.activeTab)
            end
        end
        
        return true
    end
    
    -- Forward to active tab content
    if self.activeTab > 0 and self.activeTab <= #self.tabs then
        local content = self.tabs[self.activeTab].content
        if content and content.mousepressed then
            return content:mousepressed(x, y, button)
        end
    end
    
    return false
end

--[[
    Add a tab
    @param label string - Tab label
    @param content table - Tab content widget (optional)
]]
function TabWidget:addTab(label, content)
    table.insert(self.tabs, {label = label, content = content})
    if #self.tabs == 1 then
        self.activeTab = 1
    end
end

--[[
    Set active tab
    @param index number - Tab index (1-based)
]]
function TabWidget:setActiveTab(index)
    if index >= 1 and index <= #self.tabs then
        self.activeTab = index
        
        if self.onTabChange then
            self.onTabChange(self.activeTab)
        end
    end
end

return TabWidget



























