--[[
]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local TreeView = {}
TreeView.__index = TreeView

function TreeView:new(x, y, w, h, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    obj.nodes = {}
    obj.selectedNode = nil
    obj.hoveredNode = nil
    obj.scroll = 0
    obj.maxScroll = 0

    -- Visual options
    obj.nodeHeight = options.nodeHeight or 20
    obj.indentSize = options.indentSize or 20
    obj.showLines = options.showLines ~= false
    obj.showIcons = options.showIcons ~= false
    obj.expandOnDoubleClick = options.expandOnDoubleClick ~= false

    -- Icons (simple text symbols)
    obj.icons = options.icons or {
        expanded = "▼",
        collapsed = "▶",
        leaf = "•",
        folder = "📁",
        folderOpen = "📂",
        file = "📄"
    }

    -- Events
    obj.onNodeSelect = options.onNodeSelect
    obj.onNodeExpand = options.onNodeExpand
    obj.onNodeCollapse = options.onNodeCollapse
    obj.onNodeDoubleClick = options.onNodeDoubleClick

    -- Drag and drop support
    obj.allowDragDrop = options.allowDragDrop or false
    obj.draggedNode = nil
    obj.dropTarget = nil

    -- Search functionality
    obj.searchQuery = ""
    obj.filteredNodes = {}
    obj.showSearchResults = false

    -- Animation
    obj.expandAnimations = {}

    setmetatable(obj, self)
    obj:_calculateLayout()
    return obj
end

-- Node structure: {label, children = {}, expanded = false, data = nil, icon = nil, type = "folder"/"file"}
function TreeView:setNodes(nodes)
    self.nodes = nodes or {}
    self:_calculateLayout()
end

function TreeView:addNode(parentPath, node)
    local parent = self:_findNodeByPath(parentPath)
    if parent then
        parent.children = parent.children or {}
        table.insert(parent.children, node)
        self:_calculateLayout()
    elseif not parentPath then
        -- Add to root
        table.insert(self.nodes, node)
        self:_calculateLayout()
    end
end

function TreeView:removeNode(nodePath)
    local parent, index = self:_findParentAndIndex(nodePath)
    if parent and index then
        table.remove(parent, index)
        self:_calculateLayout()
    end
end

function TreeView:expandNode(nodePath, animate)
    local node = self:_findNodeByPath(nodePath)
    if node and node.children and not node.expanded then
        node.expanded = true

        if animate ~= false then
            -- Animate expansion
            node.expandHeight = 0
            local targetHeight = self:_getNodeSubtreeHeight(node)
            Animation.animateWidget(node, "expandHeight", targetHeight, 0.3, Animation.types.EASE_OUT)
        end

        if self.onNodeExpand then
            self.onNodeExpand(node, nodePath)
        end

        self:_calculateLayout()
    end
end

function TreeView:collapseNode(nodePath, animate)
    local node = self:_findNodeByPath(nodePath)
    if node and node.expanded then
        if animate ~= false then
            -- Animate collapse
            local currentHeight = self:_getNodeSubtreeHeight(node)
            node.expandHeight = currentHeight
            Animation.animateWidget(node, "expandHeight", 0, 0.3, Animation.types.EASE_IN,
                function()
                    node.expanded = false; self:_calculateLayout()
                end)
        else
            node.expanded = false
            self:_calculateLayout()
        end

        if self.onNodeCollapse then
            self.onNodeCollapse(node, nodePath)
        end
    end
end

function TreeView:toggleNode(nodePath, animate)
    local node = self:_findNodeByPath(nodePath)
    if node and node.children then
        if node.expanded then
            self:collapseNode(nodePath, animate)
        else
            self:expandNode(nodePath, animate)
        end
    end
end

function TreeView:selectNode(nodePath)
    local node = self:_findNodeByPath(nodePath)
    if node then
        self.selectedNode = node

        if self.onNodeSelect then
            self.onNodeSelect(node, nodePath)
        end

        -- Ensure selected node is visible
        self:_scrollToNode(node)
    end
end

function TreeView:search(query)
    self.searchQuery = query or ""
    if self.searchQuery == "" then
        self.showSearchResults = false
        self.filteredNodes = {}
    else
        self.showSearchResults = true
        self.filteredNodes = self:_searchNodes(self.nodes, query)
    end
end

function TreeView:_searchNodes(nodes, query, path, results)
    results = results or {}
    path = path or {}

    for i, node in ipairs(nodes) do
        local currentPath = {}
        for j = 1, #path do table.insert(currentPath, path[j]) end
        table.insert(currentPath, i)

        -- Check if node matches search
        if string.find(string.lower(node.label or ""), string.lower(query), 1, true) then
            table.insert(results, { node = node, path = currentPath })
        end

        -- Search children
        if node.children then
            self:_searchNodes(node.children, query, currentPath, results)
        end
    end

    return results
end

function TreeView:update(dt)
    core.Base.update(self, dt)
    Animation.update(dt)

    -- Update hover detection
    local mx, my = love.mouse.getPosition()
    self.hoveredNode = nil

    if self:hitTest(mx, my) then
        local nodeY = self.y - self.scroll
        local nodesToCheck = self.showSearchResults and self.filteredNodes or self.nodes

        if self.showSearchResults then
            for _, result in ipairs(self.filteredNodes) do
                local nodeRect = { x = self.x, y = nodeY, w = self.w, h = self.nodeHeight }
                if my >= nodeRect.y and my < nodeRect.y + nodeRect.h then
                    self.hoveredNode = result.node
                    break
                end
                nodeY = nodeY + self.nodeHeight
            end
        else
            self:_updateHoverRecursive(self.nodes, mx, my, nodeY, 0)
        end
    end
end

function TreeView:_updateHoverRecursive(nodes, mx, my, nodeY, indent)
    for _, node in ipairs(nodes) do
        local nodeRect = { x = self.x + indent, y = nodeY, w = self.w - indent, h = self.nodeHeight }

        if my >= nodeRect.y and my < nodeRect.y + nodeRect.h then
            self.hoveredNode = node
            return true
        end

        nodeY = nodeY + self.nodeHeight

        -- Check expanded children
        if node.expanded and node.children then
            local found = self:_updateHoverRecursive(node.children, mx, my, nodeY, indent + self.indentSize)
            if found then return true end
            nodeY = nodeY + self:_getNodeSubtreeHeight(node)
        end
    end

    return false
end

function TreeView:draw()
    core.Base.draw(self)

    -- Background
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Setup clipping
    love.graphics.push()
    love.graphics.intersectScissor(self.x, self.y, self.w, self.h)

    if self.showSearchResults then
        self:_drawSearchResults()
    else
        self:_drawNodes()
    end

    love.graphics.pop()

    -- Border
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Focus ring
    if self.focused then
        love.graphics.setColor(unpack(core.focus.focusRingColor))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", self.x - 1, self.y - 1, self.w + 2, self.h + 2)
        love.graphics.setLineWidth(1)
    end
end

function TreeView:_drawSearchResults()
    local nodeY = self.y - self.scroll

    for _, result in ipairs(self.filteredNodes) do
        local node = result.node
        local isHovered = (self.hoveredNode == node)
        local isSelected = (self.selectedNode == node)

        -- Node background
        if isSelected then
            love.graphics.setColor(unpack(core.theme.accent))
            love.graphics.rectangle("fill", self.x, nodeY, self.w, self.nodeHeight)
        elseif isHovered then
            love.graphics.setColor(unpack(core.theme.primaryHover))
            love.graphics.rectangle("fill", self.x, nodeY, self.w, self.nodeHeight)
        end

        -- Node icon and label
        self:_drawNodeContent(node, self.x + 5, nodeY, 0, true)

        nodeY = nodeY + self.nodeHeight
    end
end

function TreeView:_drawNodes()
    local nodeY = self.y - self.scroll
    nodeY = self:_drawNodesRecursive(self.nodes, nodeY, 0)

    -- Update max scroll
    local totalHeight = nodeY - (self.y - self.scroll)
    self.maxScroll = math.max(0, totalHeight - self.h)
end

function TreeView:_drawNodesRecursive(nodes, nodeY, indent)
    for _, node in ipairs(nodes) do
        local isHovered = (self.hoveredNode == node)
        local isSelected = (self.selectedNode == node)
        local hasChildren = node.children and #node.children > 0

        -- Node background
        if isSelected then
            love.graphics.setColor(unpack(core.theme.accent))
            love.graphics.rectangle("fill", self.x, nodeY, self.w, self.nodeHeight)
        elseif isHovered then
            love.graphics.setColor(unpack(core.theme.primaryHover))
            love.graphics.rectangle("fill", self.x, nodeY, self.w, self.nodeHeight)
        end

        -- Connecting lines
        if self.showLines and indent > 0 then
            love.graphics.setColor(unpack(core.theme.border))
            -- Horizontal line
            love.graphics.line(self.x + indent - self.indentSize / 2, nodeY + self.nodeHeight / 2,
                self.x + indent, nodeY + self.nodeHeight / 2)
            -- Vertical line (simplified)
            if nodeY > self.y then
                love.graphics.line(self.x + indent - self.indentSize / 2, nodeY,
                    self.x + indent - self.indentSize / 2, nodeY + self.nodeHeight / 2)
            end
        end

        -- Expand/collapse button
        local buttonX = self.x + indent
        if hasChildren then
            love.graphics.setColor(unpack(core.theme.text))
            local icon = node.expanded and self.icons.expanded or self.icons.collapsed
            love.graphics.print(icon, buttonX, nodeY + 2)
            buttonX = buttonX + 15
        else
            buttonX = buttonX + 15
        end

        -- Node content
        self:_drawNodeContent(node, buttonX, nodeY, indent)

        nodeY = nodeY + self.nodeHeight

        -- Draw expanded children
        if node.expanded and hasChildren then
            nodeY = self:_drawNodesRecursive(node.children, nodeY, indent + self.indentSize)
        end
    end

    return nodeY
end

function TreeView:_drawNodeContent(node, x, y, indent, isSearchResult)
    local textX = x

    -- Node icon
    if self.showIcons then
        love.graphics.setColor(unpack(core.theme.text))
        local icon = node.icon
        if not icon then
            if node.children then
                icon = node.expanded and self.icons.folderOpen or self.icons.folder
            else
                icon = node.type == "file" and self.icons.file or self.icons.leaf
            end
        end
        love.graphics.print(icon, textX, y + 2)
        textX = textX + 20
    end

    -- Node label
    love.graphics.setColor(unpack(core.theme.text))
    local displayText = node.label or "Untitled"

    -- Highlight search terms
    if isSearchResult and self.searchQuery ~= "" then
        -- Simple highlight by making text bold (color change)
        if string.find(string.lower(displayText), string.lower(self.searchQuery), 1, true) then
            love.graphics.setColor(unpack(core.theme.accent))
        end
    end

    love.graphics.print(displayText, textX, y + 2)
end

function TreeView:mousepressed(x, y, button)
    if button ~= 1 or not self:hitTest(x, y) then return false end

    core.setFocus(self)

    if self.showSearchResults then
        -- Handle search result click
        local nodeY = self.y - self.scroll
        for _, result in ipairs(self.filteredNodes) do
            if y >= nodeY and y < nodeY + self.nodeHeight then
                self:selectNode(result.path)
                return true
            end
            nodeY = nodeY + self.nodeHeight
        end
    else
        -- Handle normal tree click
        local nodeY = self.y - self.scroll
        local clicked = self:_handleClickRecursive(self.nodes, x, y, nodeY, 0, {})
        return clicked
    end

    return false
end

function TreeView:_handleClickRecursive(nodes, x, y, nodeY, indent, path)
    for i, node in ipairs(nodes) do
        local currentPath = {}
        for j = 1, #path do table.insert(currentPath, path[j]) end
        table.insert(currentPath, i)

        local hasChildren = node.children and #node.children > 0

        if y >= nodeY and y < nodeY + self.nodeHeight then
            -- Check if clicked on expand/collapse button
            local buttonX = self.x + indent
            if hasChildren and x >= buttonX and x < buttonX + 15 then
                self:toggleNode(currentPath)
            else
                self:selectNode(currentPath)
            end
            return true
        end

        nodeY = nodeY + self.nodeHeight

        -- Check expanded children
        if node.expanded and hasChildren then
            local found = self:_handleClickRecursive(node.children, x, y, nodeY,
                indent + self.indentSize, currentPath)
            if found then return true end
            nodeY = nodeY + self:_getNodeSubtreeHeight(node)
        end
    end

    return false
end

function TreeView:keypressed(key)
    if not self.focused then return core.Base.keypressed(self, key) end

    if key == "up" then
        self:_selectPreviousNode()
        return true
    elseif key == "down" then
        self:_selectNextNode()
        return true
    elseif key == "left" then
        if self.selectedNode and self.selectedNode.expanded then
            local path = self:_getNodePath(self.selectedNode)
            self:collapseNode(path)
        end
        return true
    elseif key == "right" then
        if self.selectedNode and self.selectedNode.children and not self.selectedNode.expanded then
            local path = self:_getNodePath(self.selectedNode)
            self:expandNode(path)
        end
        return true
    elseif key == "return" or key == "space" then
        if self.selectedNode then
            local path = self:_getNodePath(self.selectedNode)
            self:toggleNode(path)
        end
        return true
    end

    return core.Base.keypressed(self, key)
end

function TreeView:wheelmoved(x, y)
    if self:hitTest(love.mouse.getPosition()) then
        self.scroll = math.max(0, math.min(self.maxScroll, self.scroll - y * 20))
        return true
    end
    return false
end

-- Helper methods
function TreeView:_findNodeByPath(path)
    if not path or #path == 0 then return nil end

    local current = self.nodes[path[1]]
    for i = 2, #path do
        if not current or not current.children then return nil end
        current = current.children[path[i]]
    end

    return current
end

function TreeView:_findParentAndIndex(path)
    if not path or #path == 0 then return nil end
    if #path == 1 then return self.nodes, path[1] end

    local parentPath = {}
    for i = 1, #path - 1 do
        table.insert(parentPath, path[i])
    end

    local parent = self:_findNodeByPath(parentPath)
    return parent and parent.children, path[#path]
end

function TreeView:_getNodePath(targetNode)
    local function searchPath(nodes, path)
        for i, node in ipairs(nodes) do
            local currentPath = {}
            for j = 1, #path do table.insert(currentPath, path[j]) end
            table.insert(currentPath, i)

            if node == targetNode then
                return currentPath
            end

            if node.children then
                local found = searchPath(node.children, currentPath)
                if found then return found end
            end
        end
        return nil
    end

    return searchPath(self.nodes, {})
end

function TreeView:_getNodeSubtreeHeight(node)
    if not node.expanded or not node.children then return 0 end

    local height = 0
    for _, child in ipairs(node.children) do
        height = height + self.nodeHeight
        if child.expanded and child.children then
            height = height + self:_getNodeSubtreeHeight(child)
        end
    end

    return height
end

function TreeView:_calculateLayout()
    -- Calculate total height for scrolling
    local totalHeight = self:_calculateNodesHeight(self.nodes)
    self.maxScroll = math.max(0, totalHeight - self.h)
end

function TreeView:_calculateNodesHeight(nodes)
    local height = 0
    for _, node in ipairs(nodes) do
        height = height + self.nodeHeight
        if node.expanded and node.children then
            height = height + self:_calculateNodesHeight(node.children)
        end
    end
    return height
end

function TreeView:_selectPreviousNode()
    -- Simplified previous node selection
    if self.selectedNode then
        local path = self:_getNodePath(self.selectedNode)
        if path and path[#path] > 1 then
            path[#path] = path[#path] - 1
            self:selectNode(path)
        end
    end
end

function TreeView:_selectNextNode()
    -- Simplified next node selection
    if self.selectedNode then
        local path = self:_getNodePath(self.selectedNode)
        if path then
            -- Try to go to first child if expanded
            if self.selectedNode.expanded and self.selectedNode.children and #self.selectedNode.children > 0 then
                local newPath = {}
                for i = 1, #path do table.insert(newPath, path[i]) end
                table.insert(newPath, 1)
                self:selectNode(newPath)
                return
            end

            -- Try next sibling
            local parent = #path > 1 and self:_findNodeByPath({ unpack(path, 1, #path - 1) }) or
            { children = self.nodes }
            if path[#path] < #(parent.children or self.nodes) then
                path[#path] = path[#path] + 1
                self:selectNode(path)
            end
        end
    else
        -- Select first node
        if #self.nodes > 0 then
            self:selectNode({ 1 })
        end
    end
end

function TreeView:_scrollToNode(node)
    -- Ensure the selected node is visible
    local nodePath = self:_getNodePath(node)
    if nodePath then
        local nodeY = self:_getNodeScreenY(nodePath)

        if nodeY < self.y then
            self.scroll = self.scroll - (self.y - nodeY)
        elseif nodeY + self.nodeHeight > self.y + self.h then
            self.scroll = self.scroll + (nodeY + self.nodeHeight - (self.y + self.h))
        end

        self.scroll = math.max(0, math.min(self.maxScroll, self.scroll))
    end
end

function TreeView:_getNodeScreenY(nodePath)
    local y = self.y - self.scroll

    local function calculateY(nodes, path, currentIndex, indent)
        for i = 1, math.min(path[currentIndex] or #nodes, #nodes) do
            if currentIndex == #path and i == path[currentIndex] then
                return y
            end

            y = y + self.nodeHeight

            local node = nodes[i]
            if node.expanded and node.children and currentIndex < #path and i == path[currentIndex] then
                return calculateY(node.children, path, currentIndex + 1, indent + self.indentSize)
            elseif node.expanded and node.children then
                y = y + self:_getNodeSubtreeHeight(node)
            end
        end

        return y
    end

    if #nodePath > 0 then
        return calculateY(self.nodes, nodePath, 1, 0)
    end

    return y
end

-- Public methods
function TreeView:expandAll()
    local function expand(nodes)
        for _, node in ipairs(nodes) do
            if node.children then
                node.expanded = true
                expand(node.children)
            end
        end
    end

    expand(self.nodes)
    self:_calculateLayout()
end

function TreeView:collapseAll()
    local function collapse(nodes)
        for _, node in ipairs(nodes) do
            node.expanded = false
            if node.children then
                collapse(node.children)
            end
        end
    end

    collapse(self.nodes)
    self:_calculateLayout()
end

function TreeView:getSelectedNode()
    return self.selectedNode
end

function TreeView:getSelectedPath()
    return self.selectedNode and self:_getNodePath(self.selectedNode) or nil
end

return TreeView






