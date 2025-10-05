--[[
widgets/panel.lua
Panel container (versatile layout-aware container with advanced features)


Versatile container widget providing advanced layout management, collapsible sections,
tabbed interfaces, and scrolling capabilities for complex tactical strategy game UIs.
Essential for organizing base management screens, research trees, soldier stats panels,
and mission briefings with professional OpenXCOM-style interfaces.

PURPOSE:
- Provide flexible container for grouping and organizing child widgets
- Support multiple layout systems for automatic child positioning
- Enable collapsible sections and tabbed interfaces for space-efficient UIs
- Handle scrolling for content that exceeds panel dimensions
- Core component for modular UI construction in strategy games

KEY FEATURES:
- Layout management: vertical, horizontal, grid, and flex layouts
- Collapsible sections: animated expand/collapse with headers
- Tabbed interfaces: organize content in multiple tabs
- Scrolling support: vertical/horizontal scrolling with customizable scrollbars
- Visual styling: backgrounds, borders, shadows, rounded corners
- Auto-sizing: dynamic panel sizing based on content
- Child management: add/remove/reorder child widgets
- Animation integration: smooth transitions for collapse/expand
- Accessibility: keyboard navigation and screen reader support

@see widgets.common.core.Base
@see widgets.complex.layout
@see widgets.complex.animation
@see widgets.common.scrollbar
@see widgets.common.tab
]]

---@diagnostic disable: undefined-field
local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Layout = require("widgets.complex.layout")
local Container = require("widgets.common.container")

--- @class Panel
--- @field x number
--- @field y number
--- @field w number
--- @field h number
--- @field children table
--- @field tabs table
--- @field tabbed boolean
--- @field collapsible boolean
--- @field headerHeight number
--- @field headerText string
--- @field padding table
--- @field contentArea table
--- @field onChildAdded function
--- @field onChildRemoved function
--- @field onTabChange function
--- @field onCollapse function
--- @field onExpand function
--- @field animateCollapse boolean
--- @field showShadow boolean
--- @field showBackground boolean
--- @field showBorder boolean
--- @field headerFont love.Font
--- @field backgroundColor table
--- @field wrapChildren boolean
--- @field layout string
--- @field layoutManager table
--- @field autoSize boolean
--- @field shadowColor table
--- @field shadowOffset table
--- @field borderColor table
--- @field borderWidth number
--- @field originalHeight number
--- @field activeTab number
--- @field scrollable boolean
--- @field scrollX number
--- @field scrollY number
--- @field maxScrollX number
--- @field maxScrollY number
--- @field scrollSpeed number
--- @field showScrollbars boolean
--- @field tabHeight number
--- @field hitTest function
local Panel = {}
Panel.__index = Panel
setmetatable(Panel, { __index = Container })

function Panel:new(x, y, w, h, options)
    local obj = Container:new(x, y, w, h, options)

    -- Container properties (additional panel defaults)
    obj.padding = (options and options.padding) or { 8, 8, 8, 8 }
    obj.spacing = (options and options.spacing) or 4

    -- Layout system
    obj.layout = (options and options.layout) or "none" -- none, vertical, horizontal, grid, flex
    obj.layoutManager = nil
    obj.autoSize = (options and options.autoSize) or false
    obj.wrapChildren = (options and options.wrapChildren) or false

    -- Visual properties
    obj.showBackground = (options and options.showBackground) ~= false
    obj.backgroundColor = (options and options.backgroundColor) or core.theme.background
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.borderRadius = (options and options.borderRadius) or 4
    obj.borderWidth = (options and options.borderWidth) or 1
    obj.showBorder = (options and options.showBorder) or false
    obj.showShadow = (options and options.showShadow) or false
    obj.shadowColor = (options and options.shadowColor) or { 0, 0, 0, 0.3 }
    obj.shadowOffset = (options and options.shadowOffset) or { 2, 2 }

    -- Collapsible functionality
    obj.collapsible = (options and options.collapsible) or false
    obj.collapsed = (options and options.collapsed) or false
    obj.headerHeight = (options and options.headerHeight) or 30
    obj.headerText = (options and options.headerText) or "Panel"
    obj.headerFont = (options and options.headerFont) or core.theme.font
    obj.originalHeight = obj.h
    obj.animateCollapse = (options and options.animateCollapse) ~= false

    -- Tab functionality
    obj.tabbed = (options and options.tabbed) or false
    obj.tabs = {}
    obj.activeTab = 1
    obj.tabHeight = (options and options.tabHeight) or 28
    obj.tabSpacing = (options and options.tabSpacing) or 2

    -- Scrolling
    obj.scrollable = (options and options.scrollable) or false
    obj.scrollX = 0
    obj.scrollY = 0
    obj.maxScrollX = 0
    obj.maxScrollY = 0
    obj.scrollSpeed = (options and options.scrollSpeed) or 20
    obj.showScrollbars = (options and options.showScrollbars) or true

    -- State
    obj.headerHovered = false
    obj.contentArea = { x = obj.x, y = obj.y, w = obj.w, h = obj.h }

    -- Callbacks
    obj.onCollapse = options and options.onCollapse
    obj.onExpand = options and options.onExpand
    obj.onTabChange = options and options.onTabChange
    obj.onChildAdded = options and options.onChildAdded
    obj.onChildRemoved = options and options.onChildRemoved

    setmetatable(obj, self)
    obj:_initializeLayout()
    obj:_updateContentArea()
    return obj
end

--- Initializes the layout manager based on the panel's layout type (private method)
function Panel:_initializeLayout()
    if self.layout ~= "none" then
        local layoutOptions = {
            spacing = self.spacing,
            padding = self.padding,
            wrap = self.wrapChildren
        }

        if self.layout == "vertical" then
            self.layoutManager = Layout.VerticalLayout.new(layoutOptions)
        elseif self.layout == "horizontal" then
            self.layoutManager = Layout.HorizontalLayout.new(layoutOptions)
        elseif self.layout == "grid" then
            self.layoutManager = Layout.GridLayout.new(layoutOptions)
        elseif self.layout == "flex" then
            self.layoutManager = Layout.FlexLayout.new(layoutOptions)
        end
    end
end

--- Updates the content area dimensions accounting for headers and tabs (private method)
function Panel:_updateContentArea()
    local headerOffset = (self.collapsible or self.tabbed) and
        (self.collapsible and self.headerHeight or self.tabHeight) or 0

    self.contentArea = {
        x = self.x + self.padding[4],
        y = self.y + self.padding[1] + headerOffset,
        w = self.w - self.padding[2] - self.padding[4],
        h = (self.collapsed and 0 or (self.h - self.padding[1] - self.padding[3] - headerOffset))
    }

    -- Update scroll limits
    if self.scrollable then
        self:_updateScrollLimits()
    end

    -- Apply layout
    if self.layoutManager then
        self.layoutManager:apply(self.children, self.contentArea)
    end
end

--- Updates the maximum scroll limits based on child widget positions (private method)
function Panel:_updateScrollLimits()
    if not self.scrollable then return end

    local totalWidth = 0
    local totalHeight = 0

    for _, child in ipairs(self.children) do
        if child.x and child.y and child.w and child.h then
            totalWidth = math.max(totalWidth, child.x + child.w - self.contentArea.x)
            totalHeight = math.max(totalHeight, child.y + child.h - self.contentArea.y)
        end
    end

    self.maxScrollX = math.max(0, totalWidth - self.contentArea.w)
    self.maxScrollY = math.max(0, totalHeight - self.contentArea.h)
end

function Panel:add(child, tabName)
    if self.tabbed then
        -- Add to specific tab
        local tabIndex = tabName and self:_getTabIndex(tabName) or self.activeTab

        if not self.tabs[tabIndex] then
            self.tabs[tabIndex] = { name = tabName or ("Tab " .. tabIndex), children = {} }
        end

        table.insert(self.tabs[tabIndex].children, child)
    else
        table.insert(self.children, child)
    end

    -- Update child position if layout is active
    self:_updateContentArea()

    if self.onChildAdded then
        self.onChildAdded(child, self)
    end
end

function Panel:remove(child)
    if self.tabbed then
        for _, tab in ipairs(self.tabs) do
            for i, c in ipairs(tab.children) do
                if c == child then
                    table.remove(tab.children, i)
                    break
                end
            end
        end
    else
        for i, c in ipairs(self.children) do
            if c == child then
                table.remove(self.children, i)
                break
            end
        end
    end

    self:_updateContentArea()

    if self.onChildRemoved then
        self.onChildRemoved(child, self)
    end
end

function Panel:addTab(name, children)
    if not self.tabbed then return end

    table.insert(self.tabs, {
        name = name,
        children = children or {}
    })

    self:_updateContentArea()
end

function Panel:setActiveTab(index)
    if not self.tabbed or not self.tabs[index] then return end

    local oldTab = self.activeTab
    self.activeTab = index

    -- Update children list
    self.children = self.tabs[self.activeTab].children
    self:_updateContentArea()

    if self.onTabChange then
        self.onTabChange(self.activeTab, oldTab, self)
    end
end

function Panel:_getTabIndex(name)
    for i, tab in ipairs(self.tabs) do
        if tab.name == name then
            return i
        end
    end
    return nil
end

function Panel:collapse(animate)
    if not self.collapsible or self.collapsed then return end

    self.collapsed = true
    local targetHeight = self.headerHeight + self.padding[1] + self.padding[3]

    if animate and self.animateCollapse then
        Animation.animateWidget(self, "h", targetHeight, 0.3, Animation.types.EASE_OUT, function()
            self:_updateContentArea()
        end)
    else
        self.h = targetHeight
        self:_updateContentArea()
    end

    if self.onCollapse then
        self.onCollapse(self)
    end
end

function Panel:expand(animate)
    if not self.collapsible or not self.collapsed then return end

    self.collapsed = false

    if animate and self.animateCollapse then
        Animation.animateWidget(self, "h", self.originalHeight, 0.3, Animation.types.EASE_OUT, function()
            self:_updateContentArea()
        end)
    else
        self.h = self.originalHeight
        self:_updateContentArea()
    end

    if self.onExpand then
        self.onExpand(self)
    end
end

function Panel:toggle()
    if self.collapsed then
        self:expand(true)
    else
        self:collapse(true)
    end
end

function Panel:scroll(dx, dy)
    if not self.scrollable then return end

    self.scrollX = math.max(0, math.min(self.maxScrollX, self.scrollX + dx))
    self.scrollY = math.max(0, math.min(self.maxScrollY, self.scrollY + dy))
end

function Panel:update(dt)
    core.Base.update(self, dt)

    -- Update hover state for header
    if self.collapsible then
        local mx, my = love.mouse.getPosition()
        self.headerHovered = mx >= self.x and mx <= self.x + self.w and
            my >= self.y and my <= self.y + self.headerHeight
    end

    -- Update children
    local currentChildren = self.tabbed and
        (self.tabs[self.activeTab] and self.tabs[self.activeTab].children or {}) or
        self.children

    for _, child in ipairs(currentChildren) do
        if child.update then
            child:update(dt)
        end
    end

    -- Auto-resize if enabled
    if self.autoSize then
        self:_autoResize()
    end
end

--- Automatically resizes the panel to fit all child widgets (private method)
function Panel:_autoResize()
    local minWidth = 0
    local minHeight = 0

    for _, child in ipairs(self.children) do
        if child.x and child.y and child.w and child.h then
            minWidth = math.max(minWidth, child.x + child.w - self.contentArea.x)
            minHeight = math.max(minHeight, child.y + child.h - self.contentArea.y)
        end
    end

    local newWidth = minWidth + self.padding[2] + self.padding[4]
    local newHeight = minHeight + self.padding[1] + self.padding[3] +
        (self.collapsible and self.headerHeight or 0) +
        (self.tabbed and self.tabHeight or 0)

    if newWidth ~= self.w or newHeight ~= self.h then
        self.w = newWidth
        self.h = newHeight
        self.originalHeight = newHeight
        self:_updateContentArea()
    end
end

function Panel:draw()
    -- Draw shadow
    if self.showShadow then
        love.graphics.setColor(unpack(self.shadowColor))
        love.graphics.rectangle("fill",
            self.x + self.shadowOffset[1],
            self.y + self.shadowOffset[2],
            self.w, self.h, self.borderRadius)
    end

    -- Draw background
    if self.showBackground then
        love.graphics.setColor(unpack(self.backgroundColor))
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)
    end

    -- Draw border
    if self.showBorder then
        love.graphics.setColor(unpack(self.borderColor))
        love.graphics.setLineWidth(self.borderWidth)
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius)
        love.graphics.setLineWidth(1)
    end

    -- Draw header (collapsible or tabs)
    if self.collapsible then
        self:_drawCollapseHeader()
    elseif self.tabbed then
        self:_drawTabs()
    end

    -- Draw content area with clipping
    if not self.collapsed then
        love.graphics.push()
        love.graphics.intersectScissor(
            self.contentArea.x,
            self.contentArea.y,
            self.contentArea.w,
            self.contentArea.h
        )

        -- Apply scroll offset
        if self.scrollable then
            love.graphics.translate(-self.scrollX, -self.scrollY)
        end

        -- Draw children
        local currentChildren = self.tabbed and
            (self.tabs[self.activeTab] and self.tabs[self.activeTab].children or {}) or
            self.children

        for _, child in ipairs(currentChildren) do
            if child.draw then
                child:draw()
            end
        end

        love.graphics.pop()

        -- Draw scrollbars
        if self.scrollable and self.showScrollbars then
            self:_drawScrollbars()
        end
    end
end

--- Draws the collapsible header section (private method)
function Panel:_drawCollapseHeader()
    local headerY = self.y
    local headerColor = self.headerHovered and core.theme.primaryLight or core.theme.backgroundDark

    -- Header background
    love.graphics.setColor(unpack(headerColor))
    love.graphics.rectangle("fill", self.x, headerY, self.w, self.headerHeight, self.borderRadius, self.borderRadius, 0,
        0)

    -- Header text
    love.graphics.setColor(unpack(core.theme.text))
    love.graphics.setFont(self.headerFont)
    local textY = headerY + (self.headerHeight - self.headerFont:getHeight()) / 2
    love.graphics.print(self.headerText, self.x + 10, textY)

    -- Collapse indicator
    local indicatorX = self.x + self.w - 20
    local indicatorY = headerY + self.headerHeight / 2

    love.graphics.setColor(unpack(core.theme.text))
    if self.collapsed then
        -- Right arrow (collapsed)
        love.graphics.polygon("fill",
            indicatorX, indicatorY - 4,
            indicatorX, indicatorY + 4,
            indicatorX + 6, indicatorY)
    else
        -- Down arrow (expanded)
        love.graphics.polygon("fill",
            indicatorX - 3, indicatorY - 2,
            indicatorX + 3, indicatorY - 2,
            indicatorX, indicatorY + 4)
    end
end

--- Draws the tab navigation bar (private method)
function Panel:_drawTabs()
    local tabY = self.y
    local tabX = self.x

    for i, tab in ipairs(self.tabs) do
        local isActive = i == self.activeTab
        local tabWidth = self.w / #self.tabs - self.tabSpacing

        -- Tab background
        local tabColor = isActive and core.theme.primary or core.theme.backgroundDark
        love.graphics.setColor(unpack(tabColor))
        love.graphics.rectangle("fill", tabX, tabY, tabWidth, self.tabHeight, 4, 4, 0, 0)

        -- Tab text
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.setFont(self.headerFont)
        local textY = tabY + (self.tabHeight - self.headerFont:getHeight()) / 2
        local textX = tabX + (tabWidth - self.headerFont:getWidth(tab.name)) / 2
        love.graphics.print(tab.name, textX, textY)

        tabX = tabX + tabWidth + self.tabSpacing
    end
end

--- Draws the scrollbars for scrollable content (private method)
function Panel:_drawScrollbars()
    local scrollbarSize = 12

    -- Vertical scrollbar
    if self.maxScrollY > 0 then
        local scrollbarX = self.contentArea.x + self.contentArea.w - scrollbarSize
        local scrollbarY = self.contentArea.y
        local scrollbarH = self.contentArea.h

        -- Track
        love.graphics.setColor(unpack(core.theme.backgroundDark))
        love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarSize, scrollbarH)

        -- Thumb
        local thumbHeight = math.max(20, scrollbarH * (self.contentArea.h / (self.contentArea.h + self.maxScrollY)))
        local thumbY = scrollbarY + (scrollbarH - thumbHeight) * (self.scrollY / self.maxScrollY)

        love.graphics.setColor(unpack(core.theme.primary))
        love.graphics.rectangle("fill", scrollbarX + 2, thumbY, scrollbarSize - 4, thumbHeight, 2)
    end

    -- Horizontal scrollbar
    if self.maxScrollX > 0 then
        local scrollbarX = self.contentArea.x
        local scrollbarY = self.contentArea.y + self.contentArea.h - scrollbarSize
        local scrollbarW = self.contentArea.w

        -- Track
        love.graphics.setColor(unpack(core.theme.backgroundDark))
        love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarW, scrollbarSize)

        -- Thumb
        local thumbWidth = math.max(20, scrollbarW * (self.contentArea.w / (self.contentArea.w + self.maxScrollX)))
        local thumbX = scrollbarX + (scrollbarW - thumbWidth) * (self.scrollX / self.maxScrollX)

        love.graphics.setColor(unpack(core.theme.primary))
        love.graphics.rectangle("fill", thumbX, scrollbarY + 2, thumbWidth, scrollbarSize - 4, 2)
    end
end

function Panel:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    -- Handle header clicks (collapse/tabs)
    if self.collapsible and y <= self.y + self.headerHeight then
        self:toggle()
        return true
    elseif self.tabbed and y <= self.y + self.tabHeight then
        local tabWidth = self.w / #self.tabs
        local clickedTab = math.ceil((x - self.x) / tabWidth)
        if clickedTab >= 1 and clickedTab <= #self.tabs then
            self:setActiveTab(clickedTab)
            return true
        end
    end

    if self.collapsed then return false end

    -- Forward to children
    local currentChildren = self.tabbed and
        (self.tabs[self.activeTab] and self.tabs[self.activeTab].children or {}) or
        self.children

    for i = #currentChildren, 1, -1 do
        local child = currentChildren[i]
        if child and child.mousepressed then
            local relativeX = x + (self.scrollable and self.scrollX or 0)
            local relativeY = y + (self.scrollable and self.scrollY or 0)

            if (child.hitTest and child:hitTest(relativeX, relativeY)) then
                if child:mousepressed(relativeX, relativeY, button) then
                    return true
                end
            elseif core.isInside(relativeX, relativeY, child.x, child.y, child.w, child.h) then
                if child:mousepressed(relativeX, relativeY, button) then
                    return true
                end
            end
        end
    end

    return true -- Consume click to prevent propagation
end

function Panel:mousereleased(x, y, button)
    local currentChildren = self.tabbed and
        (self.tabs[self.activeTab] and self.tabs[self.activeTab].children or {}) or
        self.children

    for _, child in ipairs(currentChildren) do
        if child.mousereleased then
            local relativeX = x + (self.scrollable and self.scrollX or 0)
            local relativeY = y + (self.scrollable and self.scrollY or 0)
            child:mousereleased(relativeX, relativeY, button)
        end
    end
end

function Panel:mousemoved(x, y, dx, dy)
    local currentChildren = self.tabbed and
        (self.tabs[self.activeTab] and self.tabs[self.activeTab].children or {}) or
        self.children

    for _, child in ipairs(currentChildren) do
        if child.mousemoved then
            local relativeX = x + (self.scrollable and self.scrollX or 0)
            local relativeY = y + (self.scrollable and self.scrollY or 0)
            child:mousemoved(relativeX, relativeY, dx, dy)
        end
    end
end

function Panel:wheelmoved(x, y)
    if self.scrollable and self:hitTest(love.mouse.getPosition()) then
        self:scroll(-x * self.scrollSpeed, -y * self.scrollSpeed)
        return true
    end
    return false
end

-- Public API
function Panel:setLayout(layoutType, options)
    self.layout = layoutType
    self.layoutOptions = options or {}
    self:_initializeLayout()
    self:_updateContentArea()
end

function Panel:setScrollable(scrollable)
    self.scrollable = scrollable
    if scrollable then
        self:_updateScrollLimits()
    end
end

function Panel:setPadding(top, right, bottom, left)
    if type(top) == "table" then
        self.padding = top
    else
        self.padding = { top, right or top, bottom or top, left or right or top }
    end
    self:_updateContentArea()
end

function Panel:getContentArea()
    return self.contentArea
end

return Panel
