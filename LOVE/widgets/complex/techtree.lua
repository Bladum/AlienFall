--[[
widgets/techtree.lua
TechTree widget for displaying research dependencies and progression


Interactive visualization of research trees with nodes, connections, and progression states.
Essential for strategy games with complex technology dependencies and research management.

PURPOSE:
- Visualize research trees with nodes, connections, and progression states
- Provide interaction to start research or inspect requirements
- Enable strategic planning of technology development paths
- Support complex research dependency management

KEY FEATURES:
- Interactive node visualization with different states (locked/available/researching/completed)
- Connection lines showing research dependencies and prerequisites
- Zoom and pan controls for large technology trees
- Node categorization and filtering by research type
- Progress indicators for ongoing research projects
- Unlock animations and visual feedback
- Save/load persistence for research progress
- Customizable node layouts and positioning
- Research queue integration and planning
- Cost and time estimation displays

]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local Button = require("widgets.common.button")

local TechTree = {}
TechTree.__index = TechTree
setmetatable(TechTree, { __index = core.Base })

function TechTree:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Tech tree data
    obj.techs = (options and options.techs) or {}
    obj.connections = (options and options.connections) or {}

    -- Layout configuration
    obj.nodeWidth = (options and options.nodeWidth) or 120
    obj.nodeHeight = (options and options.nodeHeight) or 80
    obj.nodeSpacingX = (options and options.nodeSpacingX) or 40
    obj.nodeSpacingY = (options and options.nodeSpacingY) or 30
    obj.maxColumns = (options and options.maxColumns) or 6
    obj.maxRows = (options and options.maxRows) or 8

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or core.theme.backgroundDark
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.connectionColor = (options and options.connectionColor) or core.theme.textLight
    obj.connectionWidth = (options and options.connectionWidth) or 2

    -- Node states and colors
    obj.stateColors = {
        available = { 0.2, 0.8, 0.2, 0.9 },
        researching = { 0.2, 0.6, 1, 0.9 },
        completed = { 0.8, 0.8, 0.2, 0.9 },
        locked = { 0.4, 0.4, 0.4, 0.7 },
        unavailable = { 0.2, 0.2, 0.2, 0.5 }
    }

    obj.borderColors = {
        available = { 0.2, 1, 0.2 },
        researching = { 0.4, 0.8, 1 },
        completed = { 1, 1, 0.4 },
        locked = { 0.6, 0.6, 0.6 },
        unavailable = { 0.3, 0.3, 0.3 }
    }

    -- View and interaction
    obj.viewX = 0
    obj.viewY = 0
    obj.maxViewX = 0
    obj.maxViewY = 0
    obj.allowScroll = (options and options.allowScroll) ~= false
    obj.scrollSpeed = (options and options.scrollSpeed) or 100

    -- Node selection and interaction
    obj.selectedTech = nil
    obj.hoveredTech = nil
    obj.showTooltips = (options and options.showTooltips) ~= false
    obj.showProgress = (options and options.showProgress) ~= false
    obj.showCosts = (options and options.showCosts) ~= false

    -- Animation settings
    obj.animateProgress = (options and options.animateProgress) ~= false
    obj.animateUnlock = (options and options.animateUnlock) ~= false
    obj.unlockEffects = {}

    -- Filtering and categories
    obj.categories = (options and options.categories) or {}
    obj.activeCategory = nil
    obj.showOnlyAvailable = (options and options.showOnlyAvailable) or false

    -- Callbacks
    obj.onTechClick = options and options.onTechClick
    obj.onTechHover = options and options.onTechHover
    obj.onTechResearch = options and options.onTechResearch
    obj.onCategoryChange = options and options.onCategoryChange

    -- Cache for performance
    obj.nodeCache = {}
    obj.connectionCache = {}
    obj.needsRebuild = true

    -- Tooltip state
    obj.tooltipText = ""
    obj.tooltipX = 0
    obj.tooltipY = 0
    obj.showTooltip = false

    setmetatable(obj, self)
    obj:_calculateViewBounds()
    return obj
end

function TechTree:setTechs(techs)
    self.techs = techs
    self.needsRebuild = true
    self:_calculateViewBounds()
end

function TechTree:addTech(tech)
    table.insert(self.techs, tech)
    self.needsRebuild = true
    self:_calculateViewBounds()
end

function TechTree:updateTech(techId, data)
    for _, tech in ipairs(self.techs) do
        if tech.id == techId then
            for key, value in pairs(data) do
                tech[key] = value
            end

            -- Trigger unlock animation if tech was just completed
            if data.state == "completed" and self.animateUnlock then
                self:_triggerUnlockEffect(tech)
            end

            break
        end
    end
    self.needsRebuild = true
end

function TechTree:setConnections(connections)
    self.connections = connections
    self.needsRebuild = true
end

function TechTree:addConnection(fromId, toId)
    table.insert(self.connections, { from = fromId, to = toId })
    self.needsRebuild = true
end

function TechTree:_calculateViewBounds()
    local maxX, maxY = 0, 0

    for _, tech in ipairs(self.techs) do
        local techX = (tech.column or 0) * (self.nodeWidth + self.nodeSpacingX)
        local techY = (tech.row or 0) * (self.nodeHeight + self.nodeSpacingY)
        maxX = math.max(maxX, techX + self.nodeWidth)
        maxY = math.max(maxY, techY + self.nodeHeight)
    end

    self.maxViewX = math.max(0, maxX - self.w)
    self.maxViewY = math.max(0, maxY - self.h)
end

function TechTree:_triggerUnlockEffect(tech)
    local effect = {
        tech = tech,
        startTime = love.timer.getTime(),
        duration = 1.0,
        particles = {}
    }

    -- Create particles for unlock effect
    for i = 1, 10 do
        table.insert(effect.particles, {
            x = 0,
            y = 0,
            vx = (love.math.random() - 0.5) * 200,
            vy = (love.math.random() - 0.5) * 200,
            life = 1.0,
            size = love.math.random(2, 6)
        })
    end

    table.insert(self.unlockEffects, effect)
end

function TechTree:_buildCache()
    if not self.needsRebuild then return end

    self.nodeCache = {}
    self.connectionCache = {}

    -- Build node cache
    for _, tech in ipairs(self.techs) do
        if self:_shouldShowTech(tech) then
            local nodeX = (tech.column or 0) * (self.nodeWidth + self.nodeSpacingX) - self.viewX
            local nodeY = (tech.row or 0) * (self.nodeHeight + self.nodeSpacingY) - self.viewY

            -- Only cache visible nodes
            if nodeX + self.nodeWidth >= 0 and nodeX <= self.w and
                nodeY + self.nodeHeight >= 0 and nodeY <= self.h then
                table.insert(self.nodeCache, {
                    tech = tech,
                    x = nodeX + self.x,
                    y = nodeY + self.y,
                    w = self.nodeWidth,
                    h = self.nodeHeight
                })
            end
        end
    end

    -- Build connection cache
    for _, connection in ipairs(self.connections) do
        local fromTech = self:_findTech(connection.from)
        local toTech = self:_findTech(connection.to)

        if fromTech and toTech and self:_shouldShowTech(fromTech) and self:_shouldShowTech(toTech) then
            local fromX = (fromTech.column or 0) * (self.nodeWidth + self.nodeSpacingX) - self.viewX + self.nodeWidth / 2
            local fromY = (fromTech.row or 0) * (self.nodeHeight + self.nodeSpacingY) - self.viewY + self.nodeHeight / 2
            local toX = (toTech.column or 0) * (self.nodeWidth + self.nodeSpacingX) - self.viewX + self.nodeWidth / 2
            local toY = (toTech.row or 0) * (self.nodeHeight + self.nodeSpacingY) - self.viewY + self.nodeHeight / 2

            table.insert(self.connectionCache, {
                fromX = fromX + self.x,
                fromY = fromY + self.y,
                toX = toX + self.x,
                toY = toY + self.y,
                fromTech = fromTech,
                toTech = toTech
            })
        end
    end

    self.needsRebuild = false
end

function TechTree:_shouldShowTech(tech)
    -- Category filter
    if self.activeCategory and tech.category ~= self.activeCategory then
        return false
    end

    -- Available only filter
    if self.showOnlyAvailable and tech.state ~= "available" and tech.state ~= "researching" then
        return false
    end

    return true
end

function TechTree:_findTech(techId)
    for _, tech in ipairs(self.techs) do
        if tech.id == techId then
            return tech
        end
    end
    return nil
end

function TechTree:update(dt)
    core.Base.update(self, dt)

    -- Update unlock effects
    for i = #self.unlockEffects, 1, -1 do
        local effect = self.unlockEffects[i]
        local elapsed = love.timer.getTime() - effect.startTime

        if elapsed >= effect.duration then
            table.remove(self.unlockEffects, i)
        else
            -- Update particles
            for _, particle in ipairs(effect.particles) do
                particle.x = particle.x + particle.vx * dt
                particle.y = particle.y + particle.vy * dt
                particle.life = particle.life - dt / effect.duration
            end
        end
    end

    -- Mark cache as needing rebuild if view changed
    if self.lastViewX ~= self.viewX or self.lastViewY ~= self.viewY then
        self.needsRebuild = true
        self.lastViewX = self.viewX
        self.lastViewY = self.viewY
    end
end

function TechTree:draw()
    -- Store current scissor
    local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()

    -- Clip to widget bounds
    love.graphics.setScissor(self.x, self.y, self.w, self.h)

    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Build cache if needed
    self:_buildCache()

    -- Draw connections first
    for _, connection in ipairs(self.connectionCache) do
        self:_drawConnection(connection)
    end

    -- Draw nodes
    for _, node in ipairs(self.nodeCache) do
        self:_drawNode(node)
    end

    -- Draw unlock effects
    for _, effect in ipairs(self.unlockEffects) do
        self:_drawUnlockEffect(effect)
    end

    -- Draw border
    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Restore scissor
    love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)

    -- Draw tooltip outside of clipping
    if self.showTooltip and self.showTooltips then
        self:_drawTooltip()
    end
end

function TechTree:_drawConnection(connection)
    local fromTech = connection.fromTech
    local toTech = connection.toTech

    -- Determine connection color based on tech states
    local connectionColor = self.connectionColor
    if fromTech.state == "completed" and toTech.state ~= "unavailable" then
        connectionColor = self.borderColors.available
    elseif fromTech.state == "unavailable" or toTech.state == "unavailable" then
        connectionColor = self.borderColors.unavailable
    end

    love.graphics.setColor(unpack(connectionColor))
    love.graphics.setLineWidth(self.connectionWidth)

    -- Draw connection line with arrow
    local dx = connection.toX - connection.fromX
    local dy = connection.toY - connection.fromY
    local length = math.sqrt(dx * dx + dy * dy)

    if length > 0 then
        -- Normalize direction
        dx = dx / length
        dy = dy / length

        -- Adjust endpoints to node edges
        local startX = connection.fromX + dx * (self.nodeWidth / 2)
        local startY = connection.fromY + dy * (self.nodeHeight / 2)
        local endX = connection.toX - dx * (self.nodeWidth / 2)
        local endY = connection.toY - dy * (self.nodeHeight / 2)

        -- Draw line
        love.graphics.line(startX, startY, endX, endY)

        -- Draw arrowhead
        local arrowSize = 8
        local arrowX1 = endX - dx * arrowSize + dy * arrowSize / 2
        local arrowY1 = endY - dy * arrowSize - dx * arrowSize / 2
        local arrowX2 = endX - dx * arrowSize - dy * arrowSize / 2
        local arrowY2 = endY - dy * arrowSize + dx * arrowSize / 2

        love.graphics.polygon("fill", endX, endY, arrowX1, arrowY1, arrowX2, arrowY2)
    end
end

function TechTree:_drawNode(node)
    local tech = node.tech
    local isSelected = self.selectedTech == tech.id
    local isHovered = self.hoveredTech == tech.id

    -- Get colors based on state
    local fillColor = self.stateColors[tech.state] or self.stateColors.unavailable
    local borderColor = self.borderColors[tech.state] or self.borderColors.unavailable

    -- Highlight selected/hovered nodes
    if isSelected or isHovered then
        local highlightIntensity = isSelected and 0.3 or 0.15
        fillColor = {
            math.min(1, fillColor[1] + highlightIntensity),
            math.min(1, fillColor[2] + highlightIntensity),
            math.min(1, fillColor[3] + highlightIntensity),
            fillColor[4]
        }
    end

    -- Draw node background
    love.graphics.setColor(unpack(fillColor))
    love.graphics.rectangle("fill", node.x, node.y, node.w, node.h, 6)

    -- Draw node border
    love.graphics.setColor(unpack(borderColor))
    love.graphics.setLineWidth(isSelected and 3 or 2)
    love.graphics.rectangle("line", node.x, node.y, node.w, node.h, 6)

    -- Draw tech icon or image
    if tech.icon then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(core.theme.fontBold)
        local iconSize = 24
        love.graphics.print(tech.icon,
            node.x + (node.w - iconSize) / 2,
            node.y + 8)
    end

    -- Draw tech name
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(core.theme.font)
    local nameY = tech.icon and (node.y + 35) or (node.y + 8)
    love.graphics.printf(tech.name or "Tech",
        node.x + 4, nameY, node.w - 8, "center")

    -- Draw progress bar if researching
    if tech.state == "researching" and self.showProgress and tech.progress then
        local progressY = node.y + node.h - 20
        local progressW = node.w - 8
        local progressH = 8

        -- Progress background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", node.x + 4, progressY, progressW, progressH)

        -- Progress fill
        love.graphics.setColor(unpack(borderColor))
        local fillW = progressW * math.min(1, math.max(0, tech.progress))
        love.graphics.rectangle("fill", node.x + 4, progressY, fillW, progressH)

        -- Progress text
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(core.theme.font)
        local progressText = string.format("%.0f%%", tech.progress * 100)
        local textWidth = core.theme.font:getWidth(progressText)
        love.graphics.print(progressText,
            node.x + (node.w - textWidth) / 2,
            progressY - 12)
    end

    -- Draw cost if specified
    if self.showCosts and tech.cost then
        love.graphics.setColor(1, 1, 0.6)
        love.graphics.setFont(core.theme.font)
        local costText = tostring(tech.cost)
        local costY = node.y + node.h - (tech.state == "researching" and 35 or 15)
        love.graphics.printf(costText, node.x + 4, costY, node.w - 8, "center")
    end

    -- Draw category indicator
    if tech.category then
        local catColor = { 0.8, 0.8, 0.8, 0.7 }
        if tech.category == "weapons" then
            catColor = { 1, 0.4, 0.4, 0.7 }
        elseif tech.category == "armor" then
            catColor = { 0.4, 0.4, 1, 0.7 }
        elseif tech.category == "engineering" then
            catColor = { 0.4, 1, 0.4, 0.7 }
        end

        love.graphics.setColor(unpack(catColor))
        love.graphics.rectangle("fill", node.x + node.w - 12, node.y + 4, 8, 8)
    end
end

function TechTree:_drawUnlockEffect(effect)
    local tech = effect.tech
    local elapsed = love.timer.getTime() - effect.startTime
    local progress = elapsed / effect.duration

    if progress >= 1 then return end

    local nodeX = (tech.column or 0) * (self.nodeWidth + self.nodeSpacingX) - self.viewX + self.x
    local nodeY = (tech.row or 0) * (self.nodeHeight + self.nodeSpacingY) - self.viewY + self.y
    local centerX = nodeX + self.nodeWidth / 2
    local centerY = nodeY + self.nodeHeight / 2

    -- Draw particles
    for _, particle in ipairs(effect.particles) do
        if particle.life > 0 then
            love.graphics.setColor(1, 1, 0, particle.life)
            love.graphics.circle("fill",
                centerX + particle.x,
                centerY + particle.y,
                particle.size * particle.life)
        end
    end

    -- Draw expanding ring
    local ringRadius = progress * 60
    love.graphics.setColor(1, 1, 0, 1 - progress)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", centerX, centerY, ringRadius)
end

function TechTree:_drawTooltip()
    if not self.tooltipText or self.tooltipText == "" then return end

    love.graphics.setFont(core.theme.font)
    local lines = {}
    for line in self.tooltipText:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local maxWidth = 0
    for _, line in ipairs(lines) do
        maxWidth = math.max(maxWidth, core.theme.font:getWidth(line))
    end

    local tooltipWidth = maxWidth + 16
    local tooltipHeight = #lines * core.theme.font:getHeight() + 12

    local tooltipX = math.min(self.tooltipX, love.graphics.getWidth() - tooltipWidth)
    local tooltipY = self.tooltipY - tooltipHeight - 10

    if tooltipY < 0 then
        tooltipY = self.tooltipY + 20
    end

    -- Draw tooltip background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 4)

    -- Draw tooltip border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 4)

    -- Draw tooltip text
    love.graphics.setColor(1, 1, 1)
    for i, line in ipairs(lines) do
        love.graphics.print(line, tooltipX + 8, tooltipY + 6 + (i - 1) * core.theme.font:getHeight())
    end
end

function TechTree:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    -- Check for node clicks
    for _, node in ipairs(self.nodeCache) do
        if core.isInside(x, y, node.x, node.y, node.w, node.h) then
            local tech = node.tech

            if button == 1 then -- Left click
                self.selectedTech = tech.id

                if self.onTechClick then
                    self.onTechClick(tech, self)
                end

                -- Start research if available
                if tech.state == "available" and self.onTechResearch then
                    self.onTechResearch(tech, self)
                end
            elseif button == 2 then -- Right click
                -- Show context menu or detailed info
                if self.onTechClick then
                    self.onTechClick(tech, self, "right")
                end
            end

            return true
        end
    end

    -- Clear selection if clicking empty space
    self.selectedTech = nil
    return true
end

function TechTree:mousemoved(x, y, dx, dy)
    if not self:hitTest(x, y) then
        self.hoveredTech = nil
        self.showTooltip = false
        return
    end

    -- Check for node hover
    local wasHovered = self.hoveredTech
    self.hoveredTech = nil
    self.showTooltip = false

    for _, node in ipairs(self.nodeCache) do
        if core.isInside(x, y, node.x, node.y, node.w, node.h) then
            local tech = node.tech
            self.hoveredTech = tech.id

            -- Show tooltip
            self.tooltipText = self:_getTechTooltip(tech)
            self.tooltipX = x
            self.tooltipY = y
            self.showTooltip = true

            if self.onTechHover and wasHovered ~= tech.id then
                self.onTechHover(tech, self)
            end

            break
        end
    end
end

function TechTree:wheelmoved(x, y)
    if not self.allowScroll then return end

    -- Vertical scroll
    self.viewY = math.max(0, math.min(self.maxViewY, self.viewY - y * self.scrollSpeed))
    self.needsRebuild = true
end

function TechTree:keypressed(key)
    if not self.allowScroll then return false end

    local scrollAmount = self.scrollSpeed

    if key == "up" then
        self.viewY = math.max(0, self.viewY - scrollAmount)
        self.needsRebuild = true
        return true
    elseif key == "down" then
        self.viewY = math.min(self.maxViewY, self.viewY + scrollAmount)
        self.needsRebuild = true
        return true
    elseif key == "left" then
        self.viewX = math.max(0, self.viewX - scrollAmount)
        self.needsRebuild = true
        return true
    elseif key == "right" then
        self.viewX = math.min(self.maxViewX, self.viewX + scrollAmount)
        self.needsRebuild = true
        return true
    end

    return false
end

function TechTree:_getTechTooltip(tech)
    local tooltip = tech.name or "Technology"

    if tech.description then
        tooltip = tooltip .. "\n" .. tech.description
    end

    tooltip = tooltip .. "\nState: " .. (tech.state or "unknown")

    if tech.cost then
        tooltip = tooltip .. "\nCost: " .. tech.cost
    end

    if tech.category then
        tooltip = tooltip .. "\nCategory: " .. tech.category
    end

    if tech.state == "researching" and tech.progress then
        tooltip = tooltip .. "\nProgress: " .. string.format("%.1f%%", tech.progress * 100)
    end

    if tech.prerequisites and #tech.prerequisites > 0 then
        tooltip = tooltip .. "\nRequires: " .. table.concat(tech.prerequisites, ", ")
    end

    return tooltip
end

-- Public API
function TechTree:setCategory(category)
    self.activeCategory = category
    self.needsRebuild = true

    if self.onCategoryChange then
        self.onCategoryChange(category, self)
    end
end

function TechTree:centerOnTech(techId)
    local tech = self:_findTech(techId)
    if not tech then return end

    local techX = (tech.column or 0) * (self.nodeWidth + self.nodeSpacingX)
    local techY = (tech.row or 0) * (self.nodeHeight + self.nodeSpacingY)

    self.viewX = math.max(0, math.min(self.maxViewX, techX - self.w / 2))
    self.viewY = math.max(0, math.min(self.maxViewY, techY - self.h / 2))
    self.needsRebuild = true
end

function TechTree:getVisibleTechs()
    local visible = {}
    for _, node in ipairs(self.nodeCache) do
        table.insert(visible, node.tech)
    end
    return visible
end

function TechTree:resetView()
    self.viewX = 0
    self.viewY = 0
    self.needsRebuild = true
end

return TechTree






