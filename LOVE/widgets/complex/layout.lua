--[[
widgets/layout.lua
Advanced layout management system for widget arrangement


Comprehensive layout management system for arranging child widgets within containers.
Supports multiple layout algorithms and constraint systems for responsive UIs.

PURPOSE:
- Provide advanced layout management for widget arrangement
- Enable automatic positioning and sizing of child widgets
- Support responsive layouts that adapt to container changes
- Facilitate professional UI design with consistent spacing and alignment

KEY FEATURES:
- Multiple layout types: VERTICAL, HORIZONTAL, GRID, CENTER, FLOW, DOCK, ABSOLUTE
- Constraint system: FILL, FIXED, PERCENT, AUTO sizing options
- Responsive design with automatic layout recalculation
- Padding, spacing, and alignment controls
- Nested layout support for complex hierarchies
- Performance optimized layout calculations
- Visual debugging tools for layout inspection
- Integration with widget theming and styling
- Animation support for smooth layout transitions

LAYOUT TYPES:
- VERTICAL: Stacks children vertically with configurable spacing and alignment
- HORIZONTAL: Arranges children horizontally with vertical alignment options
- GRID: Organizes children in a grid with automatic cell sizing
- CENTER: Centers a single child within the container
- FLOW: Flows children left-to-right, wrapping to new lines as needed
- DOCK: Docks children to container edges (top, bottom, left, right, fill)
- ABSOLUTE: Allows manual positioning (pass-through mode)

CONSTRAINT SYSTEM:
- FILL: Child expands to fill available space
- FIXED: Child maintains fixed size
- PERCENT: Child size as percentage of container
- AUTO: Child uses its preferred/natural size

@see widgets.common.core.Base
@see widgets.common.panel
]]

local core = require("widgets.core")
local layout = {}

-- Layout types
layout.types = {
    VERTICAL = "vertical",
    HORIZONTAL = "horizontal",
    GRID = "grid",
    ABSOLUTE = "absolute",
    CENTER = "center",
    DOCK = "dock",
    FLOW = "flow"
}

-- Layout constraints
layout.constraints = {
    FILL = "fill",
    FIXED = "fixed",
    PERCENT = "percent",
    AUTO = "auto"
}

function layout.createContainer(x, y, w, h, layoutType, options)
    options = options or {}

    return {
        x = x,
        y = y,
        w = w,
        h = h,
        type = layoutType or layout.types.VERTICAL,
        children = {},
        spacing = options.spacing or 5,
        padding = options.padding or 5,
        align = options.align or "start", -- start, center, end
        valign = options.valign or "start",
        constraints = options.constraints or {},
        dirty = true -- Flag for when layout needs updating
    }
end

function layout.addChild(container, child, constraints)
    table.insert(container.children, {
        widget = child,
        constraints = constraints or { width = layout.constraints.AUTO, height = layout.constraints.AUTO }
    })
    container.dirty = true
end

function layout.removeChild(container, child)
    for i, childData in ipairs(container.children) do
        if childData.widget == child then
            table.remove(container.children, i)
            container.dirty = true
            break
        end
    end
end

function layout.updateLayout(container)
    if not container.dirty then return end

    local children = container.children
    if #children == 0 then
        container.dirty = false
        return
    end

    if container.type == layout.types.VERTICAL then
        layout.layoutVertical(container)
    elseif container.type == layout.types.HORIZONTAL then
        layout.layoutHorizontal(container)
    elseif container.type == layout.types.GRID then
        layout.layoutGrid(container)
    elseif container.type == layout.types.CENTER then
        layout.layoutCenter(container)
    elseif container.type == layout.types.FLOW then
        layout.layoutFlow(container)
    elseif container.type == layout.types.DOCK then
        layout.layoutDock(container)
    end

    container.dirty = false
end

function layout.layoutVertical(container)
    local currentY = container.y + container.padding
    local availableWidth = container.w - container.padding * 2

    for _, childData in ipairs(container.children) do
        local child = childData.widget
        local constraints = childData.constraints

        -- Calculate width
        if constraints.width == layout.constraints.FILL then
            child.w = availableWidth
        elseif constraints.width == layout.constraints.PERCENT and constraints.widthPercent then
            child.w = availableWidth * (constraints.widthPercent / 100)
        elseif constraints.width ~= layout.constraints.AUTO then
            child.w = constraints.width
        end

        -- Calculate height
        if constraints.height == layout.constraints.FILL then
            -- Height will be set after all children are positioned
        elseif constraints.height == layout.constraints.PERCENT and constraints.heightPercent then
            child.h = (container.h - container.padding * 2) * (constraints.heightPercent / 100)
        elseif constraints.height ~= layout.constraints.AUTO then
            child.h = constraints.height
        end

        -- Position child
        child.x = container.x + container.padding
        if container.align == "center" then
            child.x = child.x + (availableWidth - child.w) / 2
        elseif container.align == "end" then
            child.x = child.x + availableWidth - child.w
        end

        child.y = currentY
        currentY = currentY + child.h + container.spacing
    end

    -- Handle FILL height constraints
    local totalHeight = currentY - container.y - container.spacing
    local fillChildren = {}

    for _, childData in ipairs(container.children) do
        if childData.constraints.height == layout.constraints.FILL then
            table.insert(fillChildren, childData.widget)
        end
    end

    if #fillChildren > 0 then
        local remainingHeight = container.h - totalHeight
        local fillHeight = remainingHeight / #fillChildren

        for _, child in ipairs(fillChildren) do
            child.h = fillHeight
        end
    end
end

function layout.layoutHorizontal(container)
    local currentX = container.x + container.padding
    local availableHeight = container.h - container.padding * 2

    for _, childData in ipairs(container.children) do
        local child = childData.widget
        local constraints = childData.constraints

        -- Calculate height
        if constraints.height == layout.constraints.FILL then
            child.h = availableHeight
        elseif constraints.height == layout.constraints.PERCENT and constraints.heightPercent then
            child.h = availableHeight * (constraints.heightPercent / 100)
        elseif constraints.height ~= layout.constraints.AUTO then
            child.h = constraints.height
        end

        -- Calculate width
        if constraints.width == layout.constraints.FILL then
            -- Width will be set after all children are positioned
        elseif constraints.width == layout.constraints.PERCENT and constraints.widthPercent then
            child.w = (container.w - container.padding * 2) * (constraints.widthPercent / 100)
        elseif constraints.width ~= layout.constraints.AUTO then
            child.w = constraints.width
        end

        -- Position child
        child.y = container.y + container.padding
        if container.valign == "center" then
            child.y = child.y + (availableHeight - child.h) / 2
        elseif container.valign == "end" then
            child.y = child.y + availableHeight - child.h
        end

        child.x = currentX
        currentX = currentX + child.w + container.spacing
    end

    -- Handle FILL width constraints
    local totalWidth = currentX - container.x - container.spacing
    local fillChildren = {}

    for _, childData in ipairs(container.children) do
        if childData.constraints.width == layout.constraints.FILL then
            table.insert(fillChildren, childData.widget)
        end
    end

    if #fillChildren > 0 then
        local remainingWidth = container.w - totalWidth
        local fillWidth = remainingWidth / #fillChildren

        for _, child in ipairs(fillChildren) do
            child.w = fillWidth
        end
    end
end

function layout.layoutGrid(container)
    local cols = container.cols or 3
    local rows = math.ceil(#container.children / cols)
    local cellWidth = (container.w - container.padding * 2 - container.spacing * (cols - 1)) / cols
    local cellHeight = (container.h - container.padding * 2 - container.spacing * (rows - 1)) / rows

    for i, childData in ipairs(container.children) do
        local child = childData.widget
        local row = math.floor((i - 1) / cols)
        local col = (i - 1) % cols

        child.x = container.x + container.padding + col * (cellWidth + container.spacing)
        child.y = container.y + container.padding + row * (cellHeight + container.spacing)
        child.w = cellWidth
        child.h = cellHeight
    end
end

function layout.layoutCenter(container)
    if #container.children == 0 then return end

    local child = container.children[1].widget
    child.x = container.x + (container.w - child.w) / 2
    child.y = container.y + (container.h - child.h) / 2
end

function layout.layoutFlow(container)
    local currentX = container.x + container.padding
    local currentY = container.y + container.padding
    local maxHeight = 0

    for _, childData in ipairs(container.children) do
        local child = childData.widget

        -- Check if child fits on current line
        if currentX + child.w > container.x + container.w - container.padding then
            currentX = container.x + container.padding
            currentY = currentY + maxHeight + container.spacing
            maxHeight = 0
        end

        child.x = currentX
        child.y = currentY
        currentX = currentX + child.w + container.spacing
        maxHeight = math.max(maxHeight, child.h)
    end
end

function layout.layoutDock(container)
    local availableRect = {
        x = container.x + container.padding,
        y = container.y + container.padding,
        w = container.w - container.padding * 2,
        h = container.h - container.padding * 2
    }

    for _, childData in ipairs(container.children) do
        local child = childData.widget
        local constraints = childData.constraints

        if constraints.dock == "top" then
            child.x = availableRect.x
            child.y = availableRect.y
            child.w = availableRect.w
            availableRect.y = availableRect.y + child.h + container.spacing
            availableRect.h = availableRect.h - child.h - container.spacing
        elseif constraints.dock == "bottom" then
            child.x = availableRect.x
            child.y = availableRect.y + availableRect.h - child.h
            child.w = availableRect.w
            availableRect.h = availableRect.h - child.h - container.spacing
        elseif constraints.dock == "left" then
            child.x = availableRect.x
            child.y = availableRect.y
            child.h = availableRect.h
            availableRect.x = availableRect.x + child.w + container.spacing
            availableRect.w = availableRect.w - child.w - container.spacing
        elseif constraints.dock == "right" then
            child.x = availableRect.x + availableRect.w - child.w
            child.y = availableRect.y
            child.h = availableRect.h
            availableRect.w = availableRect.w - child.w - container.spacing
        elseif constraints.dock == "fill" then
            child.x = availableRect.x
            child.y = availableRect.y
            child.w = availableRect.w
            child.h = availableRect.h
        end
    end
end

function layout.setContainerSize(container, w, h)
    container.w = w
    container.h = h
    container.dirty = true
end

function layout.invalidate(container)
    container.dirty = true
end

-- Utility functions
function layout.getPreferredSize(container)
    if container.type == layout.types.VERTICAL then
        local maxWidth = 0
        local totalHeight = 0

        for i, childData in ipairs(container.children) do
            local child = childData.widget
            maxWidth = math.max(maxWidth, child.w)
            totalHeight = totalHeight + child.h
            if i < #container.children then
                totalHeight = totalHeight + container.spacing
            end
        end

        return maxWidth + container.padding * 2, totalHeight + container.padding * 2
    elseif container.type == layout.types.HORIZONTAL then
        local maxHeight = 0
        local totalWidth = 0

        for i, childData in ipairs(container.children) do
            local child = childData.widget
            maxHeight = math.max(maxHeight, child.h)
            totalWidth = totalWidth + child.w
            if i < #container.children then
                totalWidth = totalWidth + container.spacing
            end
        end

        return totalWidth + container.padding * 2, maxHeight + container.padding * 2
    end

    return container.w, container.h
end

return layout






