--[[
widgets/textarea.lua
TextArea widget (basic multi-line text editing)


Basic multi-line text editing widget providing cursor movement, text input, and navigation
for tactical strategy game interfaces. Suitable for simple text entry scenarios like
mission notes, soldier biographies, and basic form inputs.

PURPOSE:
- Provide multi-line text editing capabilities
- Support cursor positioning and basic text manipulation
- Enable keyboard and mouse interaction for text input
- Foundation for more advanced text editing implementations

KEY FEATURES:
- Multi-line text display and editing
- Cursor positioning with mouse clicks
- Keyboard navigation (arrow keys, backspace, return)
- Basic text input and deletion
- Simple visual rendering with cursor indicator
- Lightweight implementation for basic use cases

@see widgets.common.core.Base
@see widgets.common.textinput
@see widgets.common.label
]]

local core = require("widgets.core")
local TextArea = {}
TextArea.__index = TextArea

function TextArea:new(x, y, w, h, text)
    local obj = { x = x or 0, y = y or 0, w = w or 200, h = h or 100, text = text or "", font = love.graphics.getFont(), cursorX = 1, cursorY = 1, lines = {} }
    setmetatable(obj, self)
    obj:updateLines()
    return obj
end

function TextArea:updateLines()
    self.lines = {}
    for line in self.text:gmatch("([^\n]*)\n?") do
        table.insert(self.lines, line)
        if line == "" then break end
    end
    if #self.lines == 0 then table.insert(self.lines, "") end
    self.cursorY = math.max(1, math.min(self.cursorY or 1, #self.lines))
    self.cursorX = math.max(1, math.min(self.cursorX or 1, #self.lines[self.cursorY] + 1))
end

function TextArea:update(dt)
    -- Basic hover tracking
    local mx, my = love.mouse.getPosition()
    local hovered = core.isInside(mx, my, self.x, self.y, self.w, self.h)
    if hovered then core.setTooltipWidget(self) end
end

function TextArea:draw()
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.setFont(self.font)
    local lineHeight = self.font:getHeight()
    for i, line in ipairs(self.lines) do
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.print(line, self.x + 4, self.y + (i - 1) * lineHeight + 4)
    end
    -- draw cursor
    if self.cursorVisible ~= false then
        local cx = self.x + 4 + self.font:getWidth(self.lines[self.cursorY]:sub(1, self.cursorX - 1))
        local cy = self.y + (self.cursorY - 1) * lineHeight + 4
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.line(cx, cy, cx, cy + lineHeight)
    end
end

function TextArea:mousepressed(x, y, button)
    if button ~= 1 then return false end
    if core.isInside(x, y, self.x, self.y, self.w, self.h) then
        local lineHeight = self.font:getHeight()
        local localY = y - self.y
        local row = math.floor(localY / lineHeight) + 1
        row = math.max(1, math.min(row, #self.lines))
        self.cursorY = row
        local localX = x - self.x - 4
        local col = 1
        for i = 1, #self.lines[row] do
            if self.font:getWidth(self.lines[row]:sub(1, i)) > localX then break end
            col = i + 1
        end
        self.cursorX = col
        return true
    end
    return false
end

function TextArea:keypressed(key)
    if key == "backspace" then
        if self.cursorX > 1 then
            local line = self.lines[self.cursorY]
            self.lines[self.cursorY] = line:sub(1, self.cursorX - 2) .. line:sub(self.cursorX)
            self.cursorX = math.max(1, self.cursorX - 1)
        elseif self.cursorY > 1 then
            local prev = self.lines[self.cursorY - 1]
            local cur = self.lines[self.cursorY]
            local newPos = #prev + 1
            self.lines[self.cursorY - 1] = prev .. cur
            table.remove(self.lines, self.cursorY)
            self.cursorY = self.cursorY - 1
            self.cursorX = newPos
        end
    elseif key == "return" then
        local line = self.lines[self.cursorY]
        local before = line:sub(1, self.cursorX - 1)
        local after = line:sub(self.cursorX)
        self.lines[self.cursorY] = before
        table.insert(self.lines, self.cursorY + 1, after)
        self.cursorY = self.cursorY + 1
        self.cursorX = 1
    elseif key == "left" then
        if self.cursorX > 1 then
            self.cursorX = self.cursorX - 1
        elseif self.cursorY > 1 then
            self.cursorY = self.cursorY - 1; self.cursorX = #self.lines[self.cursorY] + 1
        end
    elseif key == "right" then
        if self.cursorX <= #self.lines[self.cursorY] then
            self.cursorX = self.cursorX + 1
        elseif self.cursorY < #self.lines then
            self.cursorY = self.cursorY + 1; self.cursorX = 1
        end
    elseif key == "up" then
        self.cursorY = math.max(1, self.cursorY - 1); self.cursorX = math.min(self.cursorX, #self.lines[self.cursorY] + 1)
    elseif key == "down" then
        self.cursorY = math.min(#self.lines, self.cursorY + 1); self.cursorX = math.min(self.cursorX,
            #self.lines[self.cursorY] + 1)
    end
    self.text = table.concat(self.lines, "\n")
end

function TextArea:textinput(t)
    local line = self.lines[self.cursorY]
    local before = line:sub(1, self.cursorX - 1)
    local after = line:sub(self.cursorX)
    self.lines[self.cursorY] = before .. t .. after
    self.cursorX = self.cursorX + #t
    self.text = table.concat(self.lines, "\n")
end

return TextArea
