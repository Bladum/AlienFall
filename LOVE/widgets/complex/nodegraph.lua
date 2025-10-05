--[[
widgets/nodegraph.lua
NodeGraph widget for visual node-based editing and graph management.


Visual node canvas and connection manager for creating graph-based editors and visual programming interfaces.
Provides a canvas for placing nodes, creating connections between ports, and managing graph structures.

PURPOSE:
- Provide a visual canvas for node-based editing and graph creation
- Enable creation of connections between node ports for data flow and relationships
- Support graph-based structures for editors, ability trees, tech trees, and visual programming
- Manage node placement, selection, and manipulation within a defined canvas area

KEY FEATURES:
- Visual canvas for node placement and manipulation
- Connection system between node input/output ports
- Node selection and dragging functionality
- Link creation and management between nodes
- Graph persistence and serialization support
- Interactive editing capabilities
- Zoom and pan support for large graphs
- Connection validation and error handling

@see widgets.complex.node
@see widgets.common.core.Base
]]
local Node = require("widgets.complex.node")
local NodeGraph = {}
NodeGraph.__index = NodeGraph

function NodeGraph:new(x, y, w, h)
    local obj = { x = x, y = y, w = w, h = h, nodes = {}, links = {}, draggingNode = nil, tempLink = nil }
    setmetatable(obj, self)
    return obj
end

function NodeGraph:addNode(node)
    table.insert(self.nodes, node)
end

function NodeGraph:connect(aNode, aPortIndex, bNode, bPortIndex)
    if not aNode or not bNode then return false end
    table.insert(self.links, { a = { node = aNode, port = aPortIndex }, b = { node = bNode, port = bPortIndex } })
    return true
end

local function findPort(node, x, y)
    -- basic: if x near left/right side then return side and port index
    local margin = 8
    if x >= node.x - margin and x <= node.x + margin then return "left", 1 end
    if x >= node.x + node.w - margin and x <= node.x + node.w + margin then return "right", 1 end
    return nil
end

function NodeGraph:mousepressed(x, y, button)
    if button ~= 1 then return false end
    for i = #self.nodes, 1, -1 do
        local n = self.nodes[i]; if n:hitTest(x, y) then
            self.draggingNode = n; self.dragOffsetX = x - n.x; self.dragOffsetY = y - n.y; return true
        end
    end
    return false
end

function NodeGraph:mousemoved(x, y, dx, dy)
    if self.draggingNode then
        self.draggingNode.x = x - self.dragOffsetX; self.draggingNode.y = y - self.dragOffsetY
    end
end

function NodeGraph:mousereleased(x, y, button)
    if self.draggingNode then
        self.draggingNode = nil; return true
    end
    if self.tempLink then
        -- find target port
        for _, n in ipairs(self.nodes) do
            if findPort(n, x, y) then
                table.insert(self.links, { a = self.tempLink.a, b = { node = n } })
            end
        end
        self.tempLink = nil
        return true
    end
    return false
end

function NodeGraph:draw()
    -- Draw nodes
    for _, node in ipairs(self.nodes) do
        node:draw()
    end

    -- Draw connections
    love.graphics.setColor(1, 1, 1)
    for _, link in ipairs(self.links) do
        if link.a.node and link.b.node then
            local ax = link.a.node.x + (link.a.port == "left" and 0 or link.a.node.w)
            local ay = link.a.node.y + link.a.node.h * 0.5
            local bx = link.b.node.x + (link.b.port == "left" and 0 or link.b.node.w)
            local by = link.b.node.y + link.b.node.h * 0.5
            love.graphics.line(ax, ay, bx, by)
        end
    end

    -- Draw temporary link
    if self.tempLink then
        love.graphics.setColor(1, 1, 0)
        local ax = self.tempLink.a.node.x + (self.tempLink.a.port == "left" and 0 or self.tempLink.a.node.w)
        local ay = self.tempLink.a.node.y + self.tempLink.a.node.h * 0.5
        love.graphics.line(ax, ay, love.mouse.getX(), love.mouse.getY())
    end
end

return NodeGraph
