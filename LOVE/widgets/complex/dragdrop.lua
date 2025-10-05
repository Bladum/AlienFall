--[[
widgets/dragdrop.lua
DragDrop system for reusable drag-and-drop functionality


Reusable drag-and-drop system for widgets, supporting drag state, drop zones, and accessibility.
Essential for inventory management, soldier equipment assignment, and base facility construction
in tactical strategy game interfaces.

PURPOSE:
- Provide a drag-and-drop system for widgets with drag state and drop zones
- Enable inventory management, soldier equipment assignment, and base facility construction
- Support accessibility announcements for screen readers
- Facilitate complex drag operations with validation and visual feedback

KEY FEATURES:
- Global drag state management with visual feedback
- Drop zone registration and validation
- Accessibility announcements for screen readers
- Support for custom drag visuals and data
- Integration with core widgets like InventoryGrid and BaseLayout
- Smooth drag animations and transitions
- Collision detection for drop zones
- Custom validation callbacks for drop acceptance
- Visual feedback during drag operations

]]
local core = require("widgets.core")
local dragdrop = {}

-- Drag state
dragdrop.state = {
    active = false,
    data = nil,
    source = nil,
    visual = nil,
    offsetX = 0,
    offsetY = 0
}

-- Drop zones
dragdrop.dropZones = {}

function dragdrop.registerDropZone(widget, acceptCallback)
    table.insert(dragdrop.dropZones, {
        widget = widget,
        accept = acceptCallback or function(data) return true end
    })
end

function dragdrop.unregisterDropZone(widget)
    for i, zone in ipairs(dragdrop.dropZones) do
        if zone.widget == widget then
            table.remove(dragdrop.dropZones, i)
            break
        end
    end
end

function dragdrop.startDrag(source, data, visual, offsetX, offsetY)
    if dragdrop.state.active then
        dragdrop.endDrag()
    end

    dragdrop.state.active = true
    dragdrop.state.data = data
    dragdrop.state.source = source
    dragdrop.state.visual = visual
    dragdrop.state.offsetX = offsetX or 0
    dragdrop.state.offsetY = offsetY or 0

    if core.config.enableAccessibility then
        local label = data.label or "item"
        core.announce("Started dragging " .. label)
    end
end

function dragdrop.endDrag()
    if not dragdrop.state.active then return end

    dragdrop.state.active = false

    if dragdrop.state.source and dragdrop.state.source.endDrag then
        dragdrop.state.source:endDrag()
    end

    dragdrop.state.data = nil
    dragdrop.state.source = nil
    dragdrop.state.visual = nil
end

function dragdrop.update(dt)
    if not dragdrop.state.active then return end

    local mx, my = love.mouse.getPosition()

    -- Update visual position
    if dragdrop.state.visual then
        dragdrop.state.visual.x = mx + dragdrop.state.offsetX
        dragdrop.state.visual.y = my + dragdrop.state.offsetY
    end
end

function dragdrop.draw()
    if not dragdrop.state.active or not dragdrop.state.visual then return end

    -- Draw drag visual with transparency
    love.graphics.setColor(1, 1, 1, 0.8)
    if dragdrop.state.visual.draw then
        dragdrop.state.visual:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function dragdrop.handleMouseReleased(x, y, button)
    if not dragdrop.state.active or button ~= 1 then return false end

    -- Find drop target
    for _, zone in ipairs(dragdrop.dropZones) do
        if zone.widget.visible and zone.widget.enabled and
            zone.widget:hitTest(x, y) and zone.accept(dragdrop.state.data) then
            if zone.widget:drop(dragdrop.state.data) then
                dragdrop.endDrag()
                return true
            end
        end
    end

    -- No valid drop target
    dragdrop.endDrag()
    return true
end

-- Drag data types
dragdrop.dataTypes = {
    TEXT = "text",
    IMAGE = "image",
    FILE = "file",
    WIDGET = "widget",
    CUSTOM = "custom"
}

function dragdrop.createDragData(type, content, label, metadata)
    return {
        type = type,
        content = content,
        label = label or "item",
        metadata = metadata or {},
        timestamp = love.timer.getTime()
    }
end

-- Visual feedback for drop zones
function dragdrop.drawDropZones()
    if not dragdrop.state.active then return end

    local mx, my = love.mouse.getPosition()

    for _, zone in ipairs(dragdrop.dropZones) do
        if zone.widget.visible and zone.widget.enabled and zone.accept(dragdrop.state.data) then
            local isHover = zone.widget:hitTest(mx, my)

            if isHover then
                -- Highlight drop zone
                love.graphics.setColor(unpack(core.theme.accent))
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line",
                    zone.widget.x - 2,
                    zone.widget.y - 2,
                    zone.widget.w + 4,
                    zone.widget.h + 4)
                love.graphics.setLineWidth(1)
            end
        end
    end
end

-- Auto-scroll functionality for drag operations
dragdrop.autoScroll = {
    enabled = true,
    margin = 50,
    speed = 200
}

function dragdrop.handleAutoScroll(dt)
    if not dragdrop.state.active or not dragdrop.autoScroll.enabled then return end

    local mx, my = love.mouse.getPosition()
    local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

    local scrollX, scrollY = 0, 0

    if mx < dragdrop.autoScroll.margin then
        scrollX = -dragdrop.autoScroll.speed * dt
    elseif mx > screenW - dragdrop.autoScroll.margin then
        scrollX = dragdrop.autoScroll.speed * dt
    end

    if my < dragdrop.autoScroll.margin then
        scrollY = -dragdrop.autoScroll.speed * dt
    elseif my > screenH - dragdrop.autoScroll.margin then
        scrollY = dragdrop.autoScroll.speed * dt
    end

    -- This would need to be integrated with the application's scrolling system
    -- For now, we'll just move the drag visual
    if scrollX ~= 0 or scrollY ~= 0 then
        dragdrop.state.offsetX = dragdrop.state.offsetX + scrollX
        dragdrop.state.offsetY = dragdrop.state.offsetY + scrollY
    end
end

return dragdrop






