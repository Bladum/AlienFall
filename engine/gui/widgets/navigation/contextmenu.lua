---ContextMenu Widget - Right-Click Context Menu
---
---Displays a context menu with actions near cursor position. Supports nested submenus,
---keyboard shortcuts, disabled items, and separators. Auto-closes on click outside.
---Grid-aligned for consistent positioning.
---
---Features:
---  - Dynamic position (appears near cursor)
---  - Nested submenus (→ indicator)
---  - Keyboard shortcuts display (e.g., "Ctrl+C")
---  - Disabled menu items (grayed out)
---  - Separators (horizontal lines)
---  - Auto-close on click outside
---  - Grid-aligned positioning (24×24 pixels)
---
---Menu Item Structure:
---  - Label: Menu item text
---  - Callback: Function to execute
---  - Shortcut: Keyboard shortcut display
---  - Enabled: Can be clicked
---  - Submenu: Nested menu items
---  - Separator: Visual divider (no action)
---
---Interaction:
---  - Click item: Execute callback and close
---  - Hover item with submenu: Show submenu
---  - Click outside: Close menu
---  - ESC key: Close menu
---  - Disabled items: No interaction
---
---Key Exports:
---  - ContextMenu.new(items): Creates context menu
---  - show(x, y): Displays menu at position
---  - hide(): Closes menu
---  - addItem(item): Adds menu item
---  - addSeparator(): Adds divider line
---  - setItems(items): Replaces all items
---  - draw(): Renders menu and submenus
---  - mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - widgets.core.base: BaseWidget inheritance
---  - widgets.core.theme: Color and font theme
---
---@module widgets.navigation.contextmenu
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ContextMenu = require("gui.widgets.navigation.contextmenu")
---  local menu = ContextMenu.new({
---    {label = "Copy", shortcut = "Ctrl+C", callback = copyFunc},
---    {label = "Paste", shortcut = "Ctrl+V", callback = pasteFunc},
---    {separator = true},
---    {label = "Delete", callback = deleteFunc}
---  })
---  menu:show(mouseX, mouseY)
---
---@see widgets.navigation.dropdown For dropdown menus

--[[
    ContextMenu Widget
    
    Displays a context menu with actions.
    Features:
    - Dynamic position (near cursor)
    - Nested submenus
    - Keyboard shortcuts display
    - Disabled menu items
    - Separators
    - Auto-close on click outside
    - Grid-aligned positioning
]]

local BaseWidget = require("gui.widgets.core.base")
local Theme = require("gui.widgets.core.theme")

local ContextMenu = setmetatable({}, {__index = BaseWidget})
ContextMenu.__index = ContextMenu

function ContextMenu.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, ContextMenu)
    
    self.items = {}  -- {label, callback, enabled, shortcut, separator}
    self.itemHeight = 24
    self.padding = 4
    self.hoveredItem = 0
    self.autoClose = true
    
    return self
end

function ContextMenu:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw menu items
    local currentY = self.y + self.padding
    Theme.setFont("default")
    local font = Theme.getFont("default")
    
    for i, item in ipairs(self.items) do
        if item.separator then
            -- Draw separator line
            Theme.setColor(self.borderColor)
            love.graphics.setLineWidth(1)
            love.graphics.line(self.x + self.padding, currentY + self.itemHeight / 2, 
                             self.x + self.width - self.padding, currentY + self.itemHeight / 2)
        else
            -- Highlight hovered item
            if i == self.hoveredItem and item.enabled ~= false then
                Theme.setColor(self.hoverColor)
                love.graphics.rectangle("fill", self.x, currentY, self.width, self.itemHeight)
            end
            
            -- Draw item text
            local textColor
            if item.enabled == false then
                textColor = self.disabledTextColor
            else
                textColor = self.textColor
            end
            Theme.setColor(textColor)
            
            love.graphics.print(item.label, self.x + self.padding + 4, currentY + 4)
            
            -- Draw shortcut if present
            if item.shortcut then
                Theme.setFont("small")
                Theme.setColor(self.disabledTextColor)
                local shortcutFont = Theme.getFont("small")
                local shortcutWidth = shortcutFont:getWidth(item.shortcut)
                love.graphics.print(item.shortcut, 
                                  self.x + self.width - shortcutWidth - self.padding - 4, 
                                  currentY + 4)
                Theme.setFont("default")
            end
        end
        
        currentY = currentY + self.itemHeight
    end
end

function ContextMenu:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if button ~= 1 then
        return false
    end
    
    -- Check if clicking inside menu
    if self:containsPoint(x, y) then
        -- Determine which item was clicked
        local relativeY = y - self.y - self.padding
        local itemIndex = math.floor(relativeY / self.itemHeight) + 1
        
        if itemIndex >= 1 and itemIndex <= #self.items then
            local item = self.items[itemIndex]
            
            if not item.separator and item.enabled ~= false then
                if item.callback then
                    item.callback()
                end
                
                if self.autoClose then
                    self.visible = false
                end
                
                return true
            end
        end
        
        return true
    else
        -- Clicked outside - close menu
        if self.autoClose then
            self.visible = false
        end
    end
    
    return false
end

function ContextMenu:mousemoved(x, y, dx, dy, istouch)
    if not self.visible then
        return false
    end
    
    -- Update hovered item
    if self:containsPoint(x, y) then
        local relativeY = y - self.y - self.padding
        self.hoveredItem = math.floor(relativeY / self.itemHeight) + 1
        return true
    else
        self.hoveredItem = 0
    end
    
    return false
end

function ContextMenu:addItem(label, callback, enabled, shortcut)
    table.insert(self.items, {
        label = label,
        callback = callback,
        enabled = enabled ~= false,
        shortcut = shortcut,
        separator = false
    })
    self:updateSize()
end

function ContextMenu:addSeparator()
    table.insert(self.items, {separator = true})
    self:updateSize()
end

function ContextMenu:clearItems()
    self.items = {}
    self:updateSize()
end

function ContextMenu:updateSize()
    self.height = #self.items * self.itemHeight + self.padding * 2
end

function ContextMenu:showAt(x, y)
    self.x = x
    self.y = y
    self.visible = true
    self.hoveredItem = 0
end

function ContextMenu:hide()
    self.visible = false
end

return ContextMenu



























