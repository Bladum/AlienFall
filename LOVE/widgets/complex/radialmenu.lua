--[[
widgets/radialmenu.lua
RadialMenu widget for circular context menus and tactical action selection.


Circular context menu widget optimized for rapid action selection in tactical and strategy games.
Provides a compact radial layout for displaying multiple action options with smooth animations.

PURPOSE:
- Provide a compact circular context menu for rapid action selection
- Optimize for tactical and strategy game interfaces where speed is critical
- Support spatial radial layout for improved ergonomics and visual clarity
- Enable quick access to frequently used commands and actions

KEY FEATURES:
- Circular arrangement of action segments for intuitive navigation
- Smooth open/close animations with customizable timing
- Keyboard navigation support for accessibility
- Action grouping and categorization capabilities
- Customizable styling and visual appearance
- Mouse and touch input support
- Dynamic action list updates
- Visual feedback for selection states

@see widgets.common.core.Base
@see widgets.complex.animation
@see widgets.common.button
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local RadialMenu = {}
RadialMenu.__index = RadialMenu
setmetatable(RadialMenu, { __index = core.Base })

function RadialMenu:new(x, y, options)
    local obj = core.Base:new(x, y, 200, 200)

    -- Center position
    obj.centerX = x
    obj.centerY = y

    -- Menu configuration
    obj.actions = (options and options.actions) or {}
    obj.radius = (options and options.radius) or 80
    obj.innerRadius = (options and options.innerRadius) or 20
    obj.segmentPadding = (options and options.segmentPadding) or math.rad(5)

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or { 0.1, 0.1, 0.1, 0.8 }
    obj.borderColor = (options and options.borderColor) or { 0.8, 0.8, 0.8 }
    obj.selectedColor = (options and options.selectedColor) or { 0.2, 0.6, 1, 0.8 }
    obj.textColor = (options and options.textColor) or { 1, 1, 1 }
    obj.iconColor = (options and options.iconColor) or { 1, 1, 1 }

    -- State
    obj.isOpen = false
    obj.selectedSegment = nil
    obj.animationProgress = 0
    obj.animationDuration = 0.2
    obj.animationStartTime = 0

    -- Interaction
    obj.mouseAngle = 0
    obj.mouseDistance = 0
    obj.allowKeyboardNavigation = (options and options.allowKeyboardNavigation) ~= false
    obj.selectedIndex = -1

    -- Callbacks
    obj.onActionSelect = options and options.onActionSelect
    obj.onMenuOpen = options and options.onMenuOpen
    obj.onMenuClose = options and options.onMenuClose

    setmetatable(obj, self)
    return obj
end

function RadialMenu:open()
    if self.isOpen then return end

    self.isOpen = true
    self.animationStartTime = love.timer.getTime()

    -- Animate opening
    Animation:animate(self, self.animationDuration, { animationProgress = 1 }, "outQuart")

    if self.onMenuOpen then
        self.onMenuOpen(self)
    end
end

function RadialMenu:close()
    if not self.isOpen then return end

    self.isOpen = false
    self.selectedSegment = nil
    self.selectedIndex = -1

    -- Animate closing
    Animation:animate(self, self.animationDuration, { animationProgress = 0 }, "inQuart")

    if self.onMenuClose then
        self.onMenuClose(self)
    end
end

function RadialMenu:toggle()
    if self.isOpen then
        self:close()
    else
        self:open()
    end
end

function RadialMenu:setActions(actions)
    self.actions = actions
end

function RadialMenu:update(dt)
    core.Base.update(self, dt)

    if not self.isOpen then return end

    -- Update mouse position relative to center
    local mx, my = love.mouse.getPosition()
    local dx = mx - self.centerX
    local dy = my - self.centerY

    self.mouseDistance = math.sqrt(dx * dx + dy * dy)
    self.mouseAngle = math.atan2(dy, dx)

    -- Determine selected segment
    self:_updateSelectedSegment()
end

function RadialMenu:_updateSelectedSegment()
    if self.mouseDistance < self.innerRadius or self.mouseDistance > self.radius then
        self.selectedSegment = nil
        self.selectedIndex = -1
        return
    end

    if #self.actions == 0 then return end

    -- Calculate angle per segment
    local anglePerSegment = (2 * math.pi) / #self.actions

    -- Normalize mouse angle to 0-2π
    local normalizedAngle = self.mouseAngle
    if normalizedAngle < 0 then
        normalizedAngle = normalizedAngle + 2 * math.pi
    end

    -- Offset by half segment to center segments properly
    normalizedAngle = normalizedAngle + anglePerSegment / 2
    if normalizedAngle >= 2 * math.pi then
        normalizedAngle = normalizedAngle - 2 * math.pi
    end

    -- Determine segment
    local segmentIndex = math.floor(normalizedAngle / anglePerSegment) + 1
    if segmentIndex > #self.actions then
        segmentIndex = 1
    end

    self.selectedSegment = segmentIndex
    self.selectedIndex = segmentIndex
end

function RadialMenu:draw()
    if not self.isOpen and self.animationProgress <= 0 then return end

    -- Apply animation scaling
    love.graphics.push()
    love.graphics.translate(self.centerX, self.centerY)
    love.graphics.scale(self.animationProgress, self.animationProgress)

    -- Draw segments
    for i, action in ipairs(self.actions) do
        self:_drawSegment(i, action)
    end

    -- Draw center circle
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.circle("fill", 0, 0, self.innerRadius)
    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.circle("line", 0, 0, self.innerRadius)

    love.graphics.pop()
end

function RadialMenu:_drawSegment(index, action)
    local anglePerSegment = (2 * math.pi) / #self.actions
    local startAngle = (index - 1) * anglePerSegment - math.pi / 2
    local endAngle = startAngle + anglePerSegment

    -- Adjust for padding
    startAngle = startAngle + self.segmentPadding / 2
    endAngle = endAngle - self.segmentPadding / 2

    -- Determine colors
    local bgColor = self.backgroundColor
    local borderColor = self.borderColor

    if self.selectedSegment == index then
        bgColor = self.selectedColor
    end

    -- Draw segment arc
    love.graphics.setColor(unpack(bgColor))
    self:_drawArc(0, 0, self.innerRadius, self.radius, startAngle, endAngle, "fill")

    love.graphics.setColor(unpack(borderColor))
    self:_drawArc(0, 0, self.innerRadius, self.radius, startAngle, endAngle, "line")

    -- Draw action content
    local midAngle = (startAngle + endAngle) / 2
    local textRadius = (self.innerRadius + self.radius) / 2
    local textX = math.cos(midAngle) * textRadius
    local textY = math.sin(midAngle) * textRadius

    -- Draw icon if available
    if action.icon then
        love.graphics.setColor(unpack(self.iconColor))
        love.graphics.setFont(core.theme.fontBold)
        local iconWidth = core.theme.fontBold:getWidth(action.icon)
        love.graphics.print(action.icon, textX - iconWidth / 2, textY - 10)
        textY = textY + 15
    end

    -- Draw action name
    love.graphics.setColor(unpack(self.textColor))
    love.graphics.setFont(core.theme.font)
    local textWidth = core.theme.font:getWidth(action.name or "")
    love.graphics.print(action.name or "", textX - textWidth / 2, textY)
end

function RadialMenu:_drawArc(x, y, innerRadius, outerRadius, startAngle, endAngle, mode)
    local segments = math.max(8, math.ceil((endAngle - startAngle) / (math.pi / 8)))
    local vertices = {}

    -- Inner arc
    for i = 0, segments do
        local angle = startAngle + (endAngle - startAngle) * (i / segments)
        table.insert(vertices, x + math.cos(angle) * innerRadius)
        table.insert(vertices, y + math.sin(angle) * innerRadius)
    end

    -- Outer arc (reversed)
    for i = segments, 0, -1 do
        local angle = startAngle + (endAngle - startAngle) * (i / segments)
        table.insert(vertices, x + math.cos(angle) * outerRadius)
        table.insert(vertices, y + math.sin(angle) * outerRadius)
    end

    if mode == "fill" then
        love.graphics.polygon("fill", vertices)
    else
        -- Draw outline
        love.graphics.setLineWidth(2)

        -- Inner arc
        local innerVertices = {}
        for i = 1, (segments + 1) * 2, 2 do
            table.insert(innerVertices, vertices[i])
            table.insert(innerVertices, vertices[i + 1])
        end
        if #innerVertices >= 4 then
            for i = 1, #innerVertices - 2, 2 do
                love.graphics.line(innerVertices[i], innerVertices[i + 1],
                    innerVertices[i + 2], innerVertices[i + 3])
            end
        end

        -- Outer arc
        local outerVertices = {}
        for i = (segments + 1) * 2 + 1, #vertices, 2 do
            table.insert(outerVertices, vertices[i])
            table.insert(outerVertices, vertices[i + 1])
        end
        if #outerVertices >= 4 then
            for i = 1, #outerVertices - 2, 2 do
                love.graphics.line(outerVertices[i], outerVertices[i + 1],
                    outerVertices[i + 2], outerVertices[i + 3])
            end
        end

        -- Side lines
        if #vertices >= 4 then
            love.graphics.line(vertices[1], vertices[2], vertices[#vertices - 1], vertices[#vertices])
            love.graphics.line(vertices[(segments + 1) * 2 - 1], vertices[(segments + 1) * 2],
                vertices[(segments + 1) * 2 + 1], vertices[(segments + 1) * 2 + 2])
        end
    end
end

function RadialMenu:mousepressed(x, y, button)
    if not self.isOpen then return false end

    if button == 1 and self.selectedSegment then
        local action = self.actions[self.selectedSegment]
        if action and self.onActionSelect then
            self.onActionSelect(action, self.selectedSegment, self)
        end
        self:close()
        return true
    elseif button == 2 then
        self:close()
        return true
    end

    return false
end

function RadialMenu:keypressed(key)
    if not self.isOpen or not self.allowKeyboardNavigation then return false end

    if key == "escape" then
        self:close()
        return true
    elseif key == "return" or key == "space" then
        if self.selectedIndex > 0 and self.selectedIndex <= #self.actions then
            local action = self.actions[self.selectedIndex]
            if self.onActionSelect then
                self.onActionSelect(action, self.selectedIndex, self)
            end
            self:close()
        end
        return true
    elseif key == "left" then
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #self.actions
        end
        self.selectedSegment = self.selectedIndex
        return true
    elseif key == "right" then
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #self.actions then
            self.selectedIndex = 1
        end
        self.selectedSegment = self.selectedIndex
        return true
    end

    -- Number key selection
    local num = tonumber(key)
    if num and num >= 1 and num <= #self.actions then
        local action = self.actions[num]
        if self.onActionSelect then
            self.onActionSelect(action, num, self)
        end
        self:close()
        return true
    end

    return false
end

-- Public API
function RadialMenu:addAction(action)
    table.insert(self.actions, action)
end

function RadialMenu:removeAction(index)
    if index >= 1 and index <= #self.actions then
        table.remove(self.actions, index)
    end
end

function RadialMenu:clearActions()
    self.actions = {}
end

function RadialMenu:setCenter(x, y)
    self.centerX = x
    self.centerY = y
    self.x = x - self.radius
    self.y = y - self.radius
    self.w = self.radius * 2
    self.h = self.radius * 2
end

return RadialMenu






