--[[
widgets/alienfall/resourcebar.lua
Resource bar widget for displaying multiple game resources

The ResourceBar widget provides a comprehensive display system for managing
and visualizing multiple named resources (energy, materials, credits, etc.)
with optional icons, progress indicators, and interactive controls.

PURPOSE:
- Provide a comprehensive display system for managing and visualizing multiple named resources
- Support icons, progress indicators, and interactive controls for resource management
- Enable resource modification, validation, and user interaction in strategy games

KEY FEATURES:
- Display multiple resources with icons and labels
- Progress bars for resources with maximum values
- Horizontal or vertical layout options
- Interactive +/- buttons for resource modification
- Change highlighting and animations
- Customizable colors and icons
- Compact and full display modes
- Click callbacks for resource interaction
- Support for resource limits and validation

@see widgets.core
@see widgets.common.button
]]

local resourceBar = ResourceBar:new(50, 50, 300, 60, {
    resources = resources,
    showIcons = true,
    showProgress = true,
    showLabels = true,
    orientation = "horizontal",
    onResourceChange = function(resourceType, newValue, oldValue, bar)
        print(resourceType .. " changed from " .. oldValue .. " to " .. newValue)
    end
})

-- Advanced resource bar with editing capabilities
local advancedBar = ResourceBar:new(100, 100, 400, 80, {
    showIcons = true,
    showProgress = true,
    showLabels = true,
    showButtons = true,
    allowEditing = true,
    highlightChanges = true,
    animateChanges = true,
    compactMode = false,
    orientation = "horizontal",
    spacing = 10,
    resourceHeight = 30,
    colors = {
        backgroundColor = { 0.1, 0.1, 0.15 },
        borderColor = { 0.3, 0.3, 0.4 }
    },
    onResourceClick = function(resourceType, value, index, bar)
        print("Clicked on " .. resourceType .. " with value " .. value)
    end,
    onResourceButton = function(resourceType, delta, newValue, bar)
        print("Changed " .. resourceType .. " by " .. delta .. " to " .. newValue)
    end
})

-- Add resources dynamically
advancedBar:addResource("energy", 50, 100, {
    color = { 0.3, 0.7, 1.0 },
    icon = "⚡",
    label = "Power"
})

advancedBar:addResource("materials", 25, 100, {
    color = { 0.6, 0.4, 0.2 },
    icon = "🔧",
    label = "Alloys"
})

-- Vertical resource bar for side panel
local sideBar = ResourceBar:new(20, 100, 120, 300, {
    orientation = "vertical",
    showIcons = true,
    showProgress = true,
    showLabels = false, -- Save space
    compactMode = true,
    spacing = 5,
    resourceHeight = 25
})

-- Add base resources
sideBar:addResource("supplies", 80, 100, { icon = "📦" })
sideBar:addResource("personnel", 15, 20, { icon = "👥" })
sideBar:addResource("facilities", 8, 12, { icon = "🏭" })

-- Resource bar with unlimited resources (no max values)
local unlimitedBar = ResourceBar:new(200, 50, 250, 40, {
    showProgress = false, -- No progress bars for unlimited resources
    showValues = true,
    compactMode = true
})

unlimitedBar:addResource("credits", 50000, nil, {
    icon = "💰",
    color = { 1, 0.8, 0.2 }
})

unlimitedBar:addResource("research", 1250, nil, {
    icon = "🔬",
    color = { 0.2, 0.6, 1.0 }
})



-- Dynamic resource updates
function updateResources(newResources)
    resourceBar:setResources(newResources)
end

function spendCredits(amount)
    local current, max = resourceBar:getResource("credits")
    if current and current >= amount then
        resourceBar:updateResource("credits", current - amount)
        return true
    end
    return false
end

function addMaterials(amount)
    local current, max = resourceBar:getResource("materials")
    if current then
        local newAmount = current + amount
        if max then newAmount = math.min(newAmount, max) end
        resourceBar:updateResource("materials", newAmount)
    end
end

-- Resource bar with custom icons and colors
local customBar = ResourceBar:new(150, 200, 350, 50, {
    resourceColors = {
        elerium = { 0.5, 0.2, 1.0 },
        alloys = { 0.8, 0.8, 0.8 },
        plasma = { 1.0, 0.3, 0.3 },
        antimatter = { 0.2, 1.0, 0.8 }
    },
    resourceIcons = {
        elerium = "💎",
        alloys = "⚙️",
        plasma = "🔥",
        antimatter = "⚛️"
    }
})

-- Add alien technology resources
customBar:addResource("elerium", 10, 50)
customBar:addResource("alloys", 25, 100)
customBar:addResource("plasma", 5, 20)
customBar:addResource("antimatter", 1, 10)

-- Resource bar for base management
function createBaseResourcePanel()
    local panel = ResourceBar:new(50, 400, 500, 80, {
        showIcons = true,
        showProgress = true,
        showLabels = true,
        showButtons = true,
        allowEditing = true,
        highlightChanges = true,
        onResourceChange = function(type, newValue, oldValue, bar)
            if newValue < oldValue then
                -- Resource spent
                playSound("resource_spent")
            else
                -- Resource gained
                playSound("resource_gained")
            end
            updateBaseEfficiency()
        end
    })

    -- Add base resources
    panel:addResource("power", 85, 100, { icon = "⚡", label = "Power" })
    panel:addResource("water", 60, 100, { icon = "💧", label = "Water" })
    panel:addResource("living_space", 120, 150, { icon = "🏠", label = "Housing" })
    panel:addResource("maintenance", 90, 100, { icon = "🔧", label = "Maintenance" })

    return panel
end

-- Resource bar with validation and constraints
local validatedBar = ResourceBar:new(100, 100, 300, 60, {
    allowEditing = true,
    onResourceButton = function(resourceType, delta, newValue, bar)
        -- Custom validation logic
        if resourceType == "credits" and newValue < 0 then
            showMessage("Cannot have negative credits!")
            return false -- Prevent the change
        end

        if resourceType == "supplies" and newValue > 100 then
            showMessage("Storage capacity exceeded!")
            return false -- Prevent the change
        end

        -- Change is valid
        return true
    end
})

-- Multiple resource bars for different categories
local resourceBars = {
    -- Primary resources
    primary = ResourceBar:new(50, 50, 400, 50, {
        resources = {
            { type = "energy",    value = 75,   maxValue = 100 },
            { type = "materials", value = 45,   maxValue = 100 },
            { type = "credits",   value = 2500, maxValue = nil }
        }
    }),

    -- Strategic resources
    strategic = ResourceBar:new(50, 120, 400, 50, {
        resources = {
            { type = "elerium",  value = 10,   maxValue = 50 },
            { type = "alloys",   value = 25,   maxValue = 100 },
            { type = "research", value = 1250, maxValue = nil }
        }
    }),

    -- Personnel resources
    personnel = ResourceBar:new(50, 190, 400, 50, {
        resources = {
            { type = "scientists", value = 15, maxValue = 20 },
            { type = "engineers",  value = 8,  maxValue = 12 },
            { type = "soldiers",   value = 25, maxValue = 30 }
        }
    })
}

-- Update all bars
function updateAllResourceBars()
    for name, bar in pairs(resourceBars) do
        bar:update(love.timer.getDelta())
    end
end

-- Resource bar with real-time updates from game state
local gameStateBar = ResourceBar:new(200, 300, 300, 60, {
    showProgress = true,
    highlightChanges = true,
    animateChanges = true
})

function syncWithGameState()
    local gameResources = getGameResources()
    local barResources = {}

    for _, res in ipairs(gameResources) do
        table.insert(barResources, {
            type = res.type,
            value = res.current,
            maxValue = res.capacity,
            label = res.displayName,
            color = res.color
        })
    end

    gameStateBar:setResources(barResources)
end

-- Compact resource bar for HUD
local hudBar = ResourceBar:new(10, 10, 200, 30, {
    compactMode = true,
    showLabels = false,
    showIcons = true,
    showProgress = true,
    orientation = "horizontal",
    spacing = 2,
    resourceHeight = 25,
    backgroundColor = { 0, 0, 0, 0.7 },
    borderColor = { 1, 1, 1, 0.3 }
})

-- Add essential resources only
hudBar:addResource("health", 85, 100, { icon = "❤️" })
hudBar:addResource("ammo", 30, 50, { icon = "🔫" })
hudBar:addResource("fuel", 60, 100, { icon = "⛽" })



local core = require("widgets.core")
local Animation = require("widgets.complex.animation")
local ProgressBar = require("widgets.common.progressbar")
local Button = require("widgets.common.button")

local ResourceBar = {}
ResourceBar.__index = ResourceBar
setmetatable(ResourceBar, { __index = core.Base })

function ResourceBar:new(x, y, w, h, options)
    local obj = core.Base:new(x, y, w, h)

    -- Resources configuration
    obj.resources = (options and options.resources) or {}
    obj.maxResources = (options and options.maxResources) or 6
    obj.showLabels = (options and options.showLabels) ~= false
    obj.showValues = (options and options.showValues) ~= false
    obj.showIcons = (options and options.showIcons) ~= false

    -- Layout configuration
    obj.orientation = (options and options.orientation) or "horizontal" -- "horizontal" or "vertical"
    obj.spacing = (options and options.spacing) or 8
    obj.padding = (options and options.padding) or { 4, 4, 4, 4 }
    obj.resourceHeight = (options and options.resourceHeight) or 24
    obj.iconSize = (options and options.iconSize) or 20

    -- Visual properties
    obj.backgroundColor = (options and options.backgroundColor) or core.theme.backgroundLight
    obj.borderColor = (options and options.borderColor) or core.theme.border
    obj.showBorder = (options and options.showBorder) ~= false
    obj.borderRadius = (options and options.borderRadius) or 4

    -- Resource display modes
    obj.compactMode = (options and options.compactMode) or false
    obj.showProgress = (options and options.showProgress) ~= false
    obj.showButtons = (options and options.showButtons) or false
    obj.allowEditing = (options and options.allowEditing) or false

    -- Animation settings
    obj.animateChanges = (options and options.animateChanges) ~= false
    obj.highlightChanges = (options and options.highlightChanges) ~= false
    obj.changeHighlightDuration = 1.5

    -- Default resource colors
    obj.resourceColors = {
        energy = { 0.3, 0.7, 1 },
        materials = { 0.6, 0.4, 0.2 },
        supplies = { 0.2, 0.8, 0.2 },
        intel = { 0.8, 0.2, 0.8 },
        credits = { 1, 0.8, 0.2 },
        research = { 0.2, 0.6, 1 },
        elerium = { 0.5, 0.2, 1 },
        alloys = { 0.8, 0.8, 0.8 }
    }

    -- Resource icons (text-based)
    obj.resourceIcons = {
        energy = "⚡",
        materials = "🔧",
        supplies = "📦",
        intel = "🔍",
        credits = "💰",
        research = "🔬",
        elerium = "💎",
        alloys = "⚙️"
    }

    -- Internal state
    obj.components = {}
    obj.changeHighlights = {}
    obj.lastValues = {}

    -- Callbacks
    obj.onResourceClick = options and options.onResourceClick
    obj.onResourceChange = options and options.onResourceChange
    obj.onResourceButton = options and options.onResourceButton

    setmetatable(obj, self)
    obj:_buildComponents()
    return obj
end

function ResourceBar:setResources(resources)
    -- Detect changes for highlighting
    if self.highlightChanges then
        for _, resource in ipairs(resources) do
            local lastValue = self.lastValues[resource.type]
            if lastValue and lastValue ~= resource.value then
                self.changeHighlights[resource.type] = love.timer.getTime()
            end
            self.lastValues[resource.type] = resource.value
        end
    end

    self.resources = resources
    self:_buildComponents()
end

function ResourceBar:addResource(resourceType, value, maxValue, options)
    local resource = {
        type = resourceType,
        value = value or 0,
        maxValue = maxValue,
        color = (options and options.color) or self.resourceColors[resourceType] or { 0.5, 0.5, 0.5 },
        icon = (options and options.icon) or self.resourceIcons[resourceType],
        label = (options and options.label) or resourceType:sub(1, 1):upper() .. resourceType:sub(2),
        editable = (options and options.editable) or false,
        showButtons = (options and options.showButtons) or false
    }

    table.insert(self.resources, resource)
    self:_buildComponents()
end

function ResourceBar:updateResource(resourceType, value, maxValue)
    for _, resource in ipairs(self.resources) do
        if resource.type == resourceType then
            local oldValue = resource.value
            resource.value = value
            if maxValue then
                resource.maxValue = maxValue
            end

            -- Highlight change
            if self.highlightChanges and oldValue ~= value then
                self.changeHighlights[resourceType] = love.timer.getTime()
            end

            -- Trigger callback
            if self.onResourceChange then
                self.onResourceChange(resourceType, value, oldValue, self)
            end

            break
        end
    end

    self:_buildComponents()
end

function ResourceBar:getResource(resourceType)
    for _, resource in ipairs(self.resources) do
        if resource.type == resourceType then
            return resource.value, resource.maxValue
        end
    end
    return nil, nil
end

function ResourceBar:_buildComponents()
    self.components = {}

    if #self.resources == 0 then return end

    local availableWidth = self.w - self.padding[2] - self.padding[4]
    local availableHeight = self.h - self.padding[1] - self.padding[3]

    if self.orientation == "horizontal" then
        self:_buildHorizontalLayout(availableWidth, availableHeight)
    else
        self:_buildVerticalLayout(availableWidth, availableHeight)
    end
end

function ResourceBar:_buildHorizontalLayout(availableWidth, availableHeight)
    local resourceCount = math.min(#self.resources, self.maxResources)
    local resourceWidth = (availableWidth - (resourceCount - 1) * self.spacing) / resourceCount

    for i = 1, resourceCount do
        local resource = self.resources[i]
        local resourceX = self.x + self.padding[4] + (i - 1) * (resourceWidth + self.spacing)
        local resourceY = self.y + self.padding[1]

        self:_buildResourceComponent(resource, resourceX, resourceY, resourceWidth, availableHeight, i)
    end
end

function ResourceBar:_buildVerticalLayout(availableWidth, availableHeight)
    local resourceCount = math.min(#self.resources, self.maxResources)
    local resourceHeight = (availableHeight - (resourceCount - 1) * self.spacing) / resourceCount

    for i = 1, resourceCount do
        local resource = self.resources[i]
        local resourceX = self.x + self.padding[4]
        local resourceY = self.y + self.padding[1] + (i - 1) * (resourceHeight + self.spacing)

        self:_buildResourceComponent(resource, resourceX, resourceY, availableWidth, resourceHeight, i)
    end
end

function ResourceBar:_buildResourceComponent(resource, x, y, w, h, index)
    local componentData = {
        type = "resource",
        resource = resource,
        x = x,
        y = y,
        w = w,
        h = h,
        index = index,
        components = {}
    }

    local currentY = y
    local currentHeight = h

    -- Icon and label
    if self.showIcons or self.showLabels then
        local headerHeight = math.min(20, h * 0.3)
        local iconX = x

        if self.showIcons and resource.icon then
            componentData.iconX = iconX
            componentData.iconY = currentY
            componentData.iconSize = self.iconSize
            iconX = iconX + self.iconSize + 4
        end

        if self.showLabels then
            componentData.labelX = iconX
            componentData.labelY = currentY
            componentData.labelW = w - (iconX - x)
            componentData.labelH = headerHeight
            componentData.labelText = resource.label
        end

        currentY = currentY + headerHeight + 2
        currentHeight = currentHeight - headerHeight - 2
    end

    -- Progress bar
    if self.showProgress and resource.maxValue and resource.maxValue > 0 then
        local progressHeight = math.max(12, currentHeight * 0.6)

        local isHighlighted = self.changeHighlights[resource.type] and
            (love.timer.getTime() - self.changeHighlights[resource.type]) < self.changeHighlightDuration

        local progressBar = ProgressBar:new(x, currentY, w, progressHeight, {
            value = resource.value,
            maxValue = resource.maxValue,
            fillColor = resource.color,
            showText = self.showValues,
            text = self.compactMode and tostring(resource.value) or
                string.format("%d/%d", resource.value, resource.maxValue),
            textColor = { 1, 1, 1 },
            animate = self.animateChanges,
            glowEffect = isHighlighted
        })

        componentData.progressBar = progressBar
        currentY = currentY + progressHeight + 2
        currentHeight = currentHeight - progressHeight - 2
    elseif self.showValues then
        -- Value text without progress bar
        componentData.valueX = x
        componentData.valueY = currentY
        componentData.valueW = w
        componentData.valueH = math.max(16, currentHeight * 0.6)
        componentData.valueText = resource.maxValue and
            string.format("%d/%d", resource.value, resource.maxValue) or
            tostring(resource.value)

        currentY = currentY + componentData.valueH + 2
        currentHeight = currentHeight - componentData.valueH - 2
    end

    -- Buttons for resource modification
    if (self.showButtons or resource.showButtons) and self.allowEditing then
        local buttonHeight = math.max(16, currentHeight)
        local buttonWidth = (w - 4) / 3

        local minusButton = Button:new(x, currentY, buttonWidth, buttonHeight, {
            text = "-",
            variant = "secondary",
            fontSize = 12,
            onClick = function()
                self:_changeResource(resource.type, -1)
            end
        })

        local plusButton = Button:new(x + w - buttonWidth, currentY, buttonWidth, buttonHeight, {
            text = "+",
            variant = "secondary",
            fontSize = 12,
            onClick = function()
                self:_changeResource(resource.type, 1)
            end
        })

        componentData.minusButton = minusButton
        componentData.plusButton = plusButton
    end

    table.insert(self.components, componentData)
end

function ResourceBar:_changeResource(resourceType, delta)
    for _, resource in ipairs(self.resources) do
        if resource.type == resourceType then
            local newValue = math.max(0, resource.value + delta)
            if resource.maxValue then
                newValue = math.min(resource.maxValue, newValue)
            end

            local oldValue = resource.value
            resource.value = newValue

            -- Highlight change
            if self.highlightChanges then
                self.changeHighlights[resourceType] = love.timer.getTime()
            end

            -- Trigger callbacks
            if self.onResourceButton then
                self.onResourceButton(resourceType, delta, newValue, self)
            end

            if self.onResourceChange then
                self.onResourceChange(resourceType, newValue, oldValue, self)
            end

            break
        end
    end

    self:_buildComponents()
end

function ResourceBar:update(dt)
    core.Base.update(self, dt)

    -- Update progress bars and buttons
    for _, comp in ipairs(self.components) do
        if comp.progressBar then
            comp.progressBar:update(dt)
        end
        if comp.minusButton then
            comp.minusButton:update(dt)
        end
        if comp.plusButton then
            comp.plusButton:update(dt)
        end
    end
end

function ResourceBar:draw()
    -- Draw background
    if self.backgroundColor then
        love.graphics.setColor(unpack(self.backgroundColor))
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)
    end

    -- Draw border
    if self.showBorder then
        love.graphics.setColor(unpack(self.borderColor))
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius)
    end

    -- Draw resource components
    for _, comp in ipairs(self.components) do
        self:_drawResourceComponent(comp)
    end
end

function ResourceBar:_drawResourceComponent(comp)
    local resource = comp.resource

    -- Draw resource background highlight
    local isHighlighted = self.changeHighlights[resource.type] and
        (love.timer.getTime() - self.changeHighlights[resource.type]) < self.changeHighlightDuration

    if isHighlighted then
        local glow = 0.5 + 0.5 * math.sin(love.timer.getTime() * 6)
        love.graphics.setColor(unpack(resource.color), glow * 0.3)
        love.graphics.rectangle("fill", comp.x, comp.y, comp.w, comp.h, 2)
    end

    -- Draw icon
    if self.showIcons and comp.iconX and resource.icon then
        love.graphics.setColor(unpack(resource.color))
        love.graphics.setFont(core.theme.font)
        love.graphics.print(resource.icon, comp.iconX, comp.iconY)
    end

    -- Draw label
    if self.showLabels and comp.labelX then
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.setFont(core.theme.font)
        love.graphics.printf(comp.labelText, comp.labelX, comp.labelY, comp.labelW, "left")
    end

    -- Draw progress bar
    if comp.progressBar then
        comp.progressBar:draw()
    end

    -- Draw value text (without progress bar)
    if comp.valueX and not comp.progressBar then
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.setFont(core.theme.font)
        love.graphics.printf(comp.valueText, comp.valueX, comp.valueY, comp.valueW, "center")
    end

    -- Draw buttons
    if comp.minusButton then
        comp.minusButton:draw()
    end
    if comp.plusButton then
        comp.plusButton:draw()
    end
end

function ResourceBar:mousepressed(x, y, button)
    if not self:hitTest(x, y) then return false end

    -- Check component interactions
    for _, comp in ipairs(self.components) do
        -- Check buttons
        if comp.minusButton and comp.minusButton:mousepressed(x, y, button) then
            return true
        end
        if comp.plusButton and comp.plusButton:mousepressed(x, y, button) then
            return true
        end

        -- Check resource click
        if core.isInside(x, y, comp.x, comp.y, comp.w, comp.h) then
            if self.onResourceClick then
                self.onResourceClick(comp.resource.type, comp.resource.value, comp.index, self)
            end
            return true
        end
    end

    return true
end

function ResourceBar:mousereleased(x, y, button)
    for _, comp in ipairs(self.components) do
        if comp.minusButton then
            comp.minusButton:mousereleased(x, y, button)
        end
        if comp.plusButton then
            comp.plusButton:mousereleased(x, y, button)
        end
    end
end

function ResourceBar:mousemoved(x, y, dx, dy)
    for _, comp in ipairs(self.components) do
        if comp.minusButton then
            comp.minusButton:mousemoved(x, y, dx, dy)
        end
        if comp.plusButton then
            comp.plusButton:mousemoved(x, y, dx, dy)
        end
    end
end

-- Public API
function ResourceBar:removeResource(resourceType)
    for i, resource in ipairs(self.resources) do
        if resource.type == resourceType then
            table.remove(self.resources, i)
            break
        end
    end
    self:_buildComponents()
end

function ResourceBar:clearResources()
    self.resources = {}
    self:_buildComponents()
end

function ResourceBar:setResourceColor(resourceType, color)
    for _, resource in ipairs(self.resources) do
        if resource.type == resourceType then
            resource.color = color
            break
        end
    end
    self:_buildComponents()
end

function ResourceBar:highlightResource(resourceType)
    self.changeHighlights[resourceType] = love.timer.getTime()
end

function ResourceBar:getTotalValue()
    local total = 0
    for _, resource in ipairs(self.resources) do
        total = total + (resource.value or 0)
    end
    return total
end

-- Backward compatibility methods
function ResourceBar:getResources()
    return self.resources
end

return ResourceBar
