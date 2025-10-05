--[[
widgets/tab.lua
Tab widget (single tab for tabbed interfaces)


Basic tab widget representing a single tab in a tabbed interface with title, content,
and activation state management. Designed to be used within tabbed containers like
TabWidget or TabContainer for organizing UI content in tactical strategy game interfaces.

PURPOSE:
- Represent individual tabs in tabbed interfaces
- Manage tab activation and content display
- Provide basic tab header rendering and interaction
- Foundation for more advanced tab implementations

KEY FEATURES:
- Tab title and content association
- Active/inactive state management
- Mouse click activation
- Basic header and content rendering
- Callback system for activation events
- Lightweight implementation for simple tabbed UIs

@see widgets.common.core.Base
@see widgets.common.tabwidget
@see widgets.common.tabcontainer
@see widgets.common.panel
]]

local core = require("widgets.core")
local Tab = {}
Tab.__index = Tab

function Tab:new(title, content, options)
    local obj = {
        title = title or "Tab",
        content = content,
        x = options and options.x or 0,
        y = options and options.y or 0,
        w = options and options.w or 100,
        h = options and options.h or 30,
        active = options and options.active or false,
        onActivate = options and options.onActivate or nil
    }
    setmetatable(obj, self)
    return obj
end

function Tab:mousepressed(x, y, button)
    if button == 1 and core.isInside(x, y, self.x, self.y, self.w, self.h) then
        self.active = true
        if self.onActivate then self.onActivate() end
        return true
    end
    return false
end

function Tab:draw()
    -- Tab header
    if self.active then
        love.graphics.setColor(unpack(core.theme.accent))
    else
        love.graphics.setColor(unpack(core.theme.secondary))
    end
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.printf(self.title, self.x, self.y + self.h / 2 - 8, self.w, "center")

    -- Content area (only if active)
    if self.active and self.content then
        love.graphics.setColor(unpack(core.theme.background))
        love.graphics.rectangle("fill", self.x, self.y + self.h, self.w, 200) -- Fixed height for demo
        love.graphics.setColor(unpack(core.theme.border))
        love.graphics.rectangle("line", self.x, self.y + self.h, self.w, 200)

        if self.content.draw then
            self.content:draw()
        end
    end
end

return Tab
