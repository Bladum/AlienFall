--[[
widgets/node.lua
Node widget for graph-based editors and visual programming interfaces.


Graph node widget for node-graph editors, visual programming interfaces, and data flow diagrams.
Provides visual representation of nodes with input/output ports for creating connected graphs.

PURPOSE:
- Represent visual nodes in graph-based editors and visual programming interfaces
- Support input/output ports for creating connections between nodes
- Enable node-based workflows for ability trees, behavior graphs, and data pipelines
- Provide interactive visual elements for graph manipulation and editing

KEY FEATURES:
- Visual node representation with customizable appearance
- Input/output port system for graph connections
- Hit testing for mouse interaction and selection
- Title display and node identification
- Selection state management
- Port positioning and layout
- Integration with node graph systems
- Customizable node dimensions and styling

@see widgets.complex.nodegraph
@see widgets.common.core.Base
]]
local core = require("widgets.core")
local Node = {}
Node.__index = Node

function Node:new(x, y, w, h, title)
    local obj = { x = x, y = y, w = w or 120, h = h or 60, title = title or "Node", ports = { left = { { y = 0.25 }, { y = 0.75 } }, right = { { y = 0.25 }, { y = 0.75 } } }, selected = false }
    setmetatable(obj, self)
    return obj
end

function Node:draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.print(self.title, self.x + 6, self.y + 6)
end

function Node:hitTest(x, y)
    return core.isInside(x, y, self.x, self.y, self.w, self.h)
end

return Node






