--[[
    ResearchTree Widget
    
    Displays research/tech tree with dependencies.
    Features:
    - Node-based tree structure
    - Research status (locked, available, researching, completed)
    - Dependency lines
    - Click to select research
    - Zoom and pan
    - Grid-aligned positioning
]]

local BaseWidget = require("widgets.core.base")
local Theme = require("widgets.core.theme")

local ResearchTree = setmetatable({}, {__index = BaseWidget})
ResearchTree.__index = ResearchTree

function ResearchTree.new(x, y, width, height)
    local self = BaseWidget.new(x, y, width, height, "panel")
    setmetatable(self, ResearchTree)
    
    self.nodes = {}  -- {id, name, x, y, status, prerequisites, icon}
    self.selectedNode = nil
    self.nodeSize = 48
    self.offsetX = 0
    self.offsetY = 0
    self.scale = 1
    
    return self
end

function ResearchTree:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    Theme.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Set scissor for clipping
    love.graphics.push()
    love.graphics.setScissor(self.x, self.y, self.width, self.height)
    
    -- Draw dependency lines first
    for _, node in ipairs(self.nodes) do
        if node.prerequisites then
            for _, prereqId in ipairs(node.prerequisites) do
                local prereqNode = self:findNode(prereqId)
                if prereqNode then
                    local x1 = self.x + (prereqNode.x + self.offsetX) * self.scale + self.nodeSize / 2
                    local y1 = self.y + (prereqNode.y + self.offsetY) * self.scale + self.nodeSize / 2
                    local x2 = self.x + (node.x + self.offsetX) * self.scale + self.nodeSize / 2
                    local y2 = self.y + (node.y + self.offsetY) * self.scale + self.nodeSize / 2
                    
                    -- Line color based on completion
                    if prereqNode.status == "completed" then
                        love.graphics.setColor(0, 0.8, 0.4)
                    else
                        love.graphics.setColor(0.5, 0.5, 0.5)
                    end
                    
                    love.graphics.setLineWidth(2)
                    love.graphics.line(x1, y1, x2, y2)
                end
            end
        end
    end
    
    -- Draw nodes
    for _, node in ipairs(self.nodes) do
        local nodeX = self.x + (node.x + self.offsetX) * self.scale
        local nodeY = self.y + (node.y + self.offsetY) * self.scale
        local nodeW = self.nodeSize * self.scale
        local nodeH = self.nodeSize * self.scale
        
        -- Node background color based on status
        local bgColor
        if node.status == "completed" then
            bgColor = {0, 0.6, 0.3}
        elseif node.status == "researching" then
            bgColor = {0.2, 0.5, 1}
        elseif node.status == "available" then
            bgColor = {0.6, 0.6, 0.1}
        else  -- locked
            bgColor = {0.3, 0.3, 0.3}
        end
        
        love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3])
        love.graphics.rectangle("fill", nodeX, nodeY, nodeW, nodeH)
        
        -- Draw icon if available
        if node.icon then
            love.graphics.setColor(1, 1, 1, 1)
            local iconScale = nodeW / node.icon:getWidth()
            love.graphics.draw(node.icon, nodeX, nodeY, 0, iconScale, iconScale)
        end
        
        -- Highlight selected node
        if self.selectedNode == node.id then
            love.graphics.setColor(1, 1, 1)
            love.graphics.setLineWidth(3)
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.setLineWidth(1)
        end
        love.graphics.rectangle("line", nodeX, nodeY, nodeW, nodeH)
        
        -- Draw node name
        Theme.setFont("small")
        Theme.setColor(self.textColor)
        local font = Theme.getFont("small")
        local nameX = nodeX + (nodeW - font:getWidth(node.name)) / 2
        love.graphics.print(node.name, nameX, nodeY + nodeH + 2)
    end
    
    love.graphics.setScissor()
    love.graphics.pop()
    
    -- Draw border
    Theme.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function ResearchTree:mousepressed(x, y, button)
    if not self.visible or not self.enabled then
        return false
    end
    
    if not self:containsPoint(x, y) then
        return false
    end
    
    if button == 1 then
        -- Check if clicking a node
        for _, node in ipairs(self.nodes) do
            local nodeX = self.x + (node.x + self.offsetX) * self.scale
            local nodeY = self.y + (node.y + self.offsetY) * self.scale
            local nodeW = self.nodeSize * self.scale
            local nodeH = self.nodeSize * self.scale
            
            if x >= nodeX and x < nodeX + nodeW and
               y >= nodeY and y < nodeY + nodeH then
                self.selectedNode = node.id
                
                if self.onClick then
                    self.onClick(node)
                end
                
                return true
            end
        end
    end
    
    return false
end

function ResearchTree:addNode(node)
    table.insert(self.nodes, node)
end

function ResearchTree:findNode(id)
    for _, node in ipairs(self.nodes) do
        if node.id == id then
            return node
        end
    end
    return nil
end

function ResearchTree:setNodeStatus(id, status)
    local node = self:findNode(id)
    if node then
        node.status = status
    end
end

function ResearchTree:setOffset(x, y)
    self.offsetX = x
    self.offsetY = y
end

return ResearchTree
