--[[
widgets/menu.lua
Menu widget (vertical lists and basic menus)


Basic menu widget providing vertical lists of selectable items with mouse interaction
for tactical strategy game interfaces. Suitable for simple command lists, option menus,
and basic navigation in OpenXCOM-style games.

PURPOSE:
- Display vertical lists of selectable menu items
- Provide mouse-based interaction for menu selection
- Support callback system for menu actions
- Foundation for more advanced menu implementations

KEY FEATURES:
- Vertical menu layout with configurable dimensions
- Mouse hover and selection highlighting
- Callback system for item actions
- Basic visual styling with themes
- Lightweight implementation for simple menus

@see widgets.common.core.Base
@see widgets.common.contextmenu
@see widgets.common.menubar
@see widgets.common.toolbar
]]

local core = require("widgets.core")
local Menu = {}
Menu.__index = Menu

function Menu:new(x, y, items, options)
    local obj = {
        x = x or 0,
        y = y or 0,
        items = items or {},
        itemHeight = options and options.itemHeight or 24,
        width = options and options.width or 150,
        selected = nil,
        hovered = nil,
        onItemSelect = options and options.onItemSelect or nil
    }
    setmetatable(obj, self)
    return obj
end

function Menu:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = nil
    for i, v in ipairs(self.items) do
        local y = self.y + (i - 1) * self.itemHeight
        if core.isInside(mx, my, self.x, y, self.width, self.itemHeight) then
            self.hovered = i
            break
        end
    end
end

function Menu:draw()
    for i, v in ipairs(self.items) do
        local y = self.y + (i - 1) * self.itemHeight
        local isHovered = self.hovered == i
        local isSelected = self.selected == i

        -- Background
        if isSelected then
            love.graphics.setColor(unpack(core.theme.accent))
        elseif isHovered then
            love.graphics.setColor(unpack(core.theme.primaryHover))
        else
            love.graphics.setColor(unpack(core.theme.background))
        end
        love.graphics.rectangle("fill", self.x, y, self.width, self.itemHeight)

        -- Border
        love.graphics.setColor(unpack(core.theme.border))
        love.graphics.rectangle("line", self.x, y, self.width, self.itemHeight)

        -- Text
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.print(v.label or v, self.x + 6, y + 4)
    end
end

function Menu:mousepressed(x, y, button)
    if button ~= 1 then return false end
    for i, v in ipairs(self.items) do
        local ry = self.y + (i - 1) * self.itemHeight
        if core.isInside(x, y, self.x, ry, self.width, self.itemHeight) then
            self.selected = i
            if v.callback then v.callback() end
            if self.onItemSelect then self.onItemSelect(i, v) end
            return true
        end
    end
    return false
end

return Menu
