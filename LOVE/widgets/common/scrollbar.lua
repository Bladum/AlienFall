--[[
widgets/scrollbar.lua
ScrollBar widget (vertical and horizontal scrolling)


Basic scrollbar widget providing vertical and horizontal scrolling with draggable thumb
for tactical strategy game interfaces. Suitable for scrolling large content areas like
soldier rosters, research trees, mission logs, and inventory lists in OpenXCOM-style games.

PURPOSE:
- Provide visual scrolling controls for large content areas
- Support both vertical and horizontal scrolling
- Enable mouse-based scrolling interaction
- Foundation for scrollable UI components

KEY FEATURES:
- Vertical and horizontal orientations
- Draggable thumb with mouse interaction
- Value range from 0.0 to 1.0
- Callback system for scroll events
- Binding system for scrollable containers
- Basic visual styling with themes

@see widgets.common.core.Base
@see widgets.common.listbox
@see widgets.common.panel
@see widgets.common.textarea
]]

local core = require("widgets.core")
local ScrollBar = {}
ScrollBar.__index = ScrollBar

--- Creates a new ScrollBar widget instance
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param length number The length of the scrollbar (height for vertical, width for horizontal)
--- @param orientation string The orientation ("vertical" or "horizontal")
--- @param options table Optional configuration table
--- @return ScrollBar A new scrollbar widget instance
function ScrollBar:new(x, y, length, orientation, options)
    local obj = {
        x = x,
        y = y,
        orientation = orientation or "vertical",
        options = options or {},
        dragged = false,
        value = 0
    }

    if orientation == "vertical" then
        obj.w = 16 -- default width for vertical scrollbar
        obj.h = length
    else
        obj.w = length
        obj.h = 16 -- default height for horizontal scrollbar
    end

    setmetatable(obj, self)
    return obj
end

function ScrollBar:update(dt) end

function ScrollBar:draw()
    love.graphics.setColor(unpack(core.theme.secondary))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    -- thumb
    if self.orientation == "vertical" then
        local thumbH = math.max(20, self.h * 0.2)
        local thumbY = self.y + (self.h - thumbH) * self.value
        love.graphics.setColor(unpack(core.theme.primary))
        love.graphics.rectangle("fill", self.x, thumbY, self.w, thumbH)
    else
        local thumbW = math.max(20, self.w * 0.2)
        local thumbX = self.x + (self.w - thumbW) * self.value
        love.graphics.setColor(unpack(core.theme.primary))
        love.graphics.rectangle("fill", thumbX, self.y, thumbW, self.h)
    end
end

function ScrollBar:mousepressed(x, y, button)
    if button ~= 1 then return false end
    if not core.isInside(x, y, self.x, self.y, self.w, self.h) then return false end
    self.dragged = true; return true
end

function ScrollBar:mousereleased(x, y, button)
    self.dragged = false
end

function ScrollBar:mousemoved(x, y, dx, dy)
    if not self.dragged then return end
    if self.orientation == "vertical" then
        local rel = (y - self.y) / self.h
        local newv = core.clamp(rel, 0, 1)
        if newv ~= self.value then
            self.value = newv; if self.onChange then pcall(self.onChange, self, self.value) end
        end
    else
        local rel = (x - self.x) / self.w
        local newv = core.clamp(rel, 0, 1)
        if newv ~= self.value then
            self.value = newv; if self.onChange then pcall(self.onChange, self, self.value) end
        end
    end
    if self.bind and type(self.bind.setOffset) == "function" then
        self.bind:setOffset(self.value)
    end
end

--- Sets the scrollbar value (0.0 to 1.0)
--- @param v number The value to set (clamped to 0.0-1.0 range)
function ScrollBar:setValue(v)
    self.value = core.clamp(v, 0, 1)
end

--- Gets the current scrollbar value
--- @return number The current value (0.0 to 1.0)
function ScrollBar:getValue()
    return self.value
end

return ScrollBar
