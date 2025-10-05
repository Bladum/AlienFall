--[[
widgets/chart.lua
Chart widget for data visualization in strategy games


Comprehensive charting widget providing data visualization capabilities for strategy games.
Essential for displaying research progress, resource trends, mission statistics, and tactical
analysis in base management and geoscape operations for tactical strategy game interfaces.

PURPOSE:
- Provide comprehensive charting capabilities for data visualization in strategy games
- Display research progress, resource trends, mission statistics, and tactical analysis
- Enable real-time data updates for dynamic game statistics
- Support multiple chart types for different data presentation needs

KEY FEATURES:
- Multiple chart types: line, column, bar, pie, area, scatter
- Animated data transitions and interactive tooltips
- Customizable styling and legend support
- Real-time data updates for dynamic game statistics
- Smooth animations for data changes
- Interactive tooltips with detailed information
- Customizable colors and themes
- Support for multiple data series
- Grid lines and axis labels
- Legend with series identification

]]

local core = require("widgets.core")
local Animation = require("widgets.complex.animation")

local Chart = {}
Chart.__index = Chart

-- Chart types
Chart.types = {
    LINE = "line",
    COLUMN = "column",
    BAR = "bar",
    PIE = "pie",
    AREA = "area",
    SCATTER = "scatter"
}

function Chart:new(x, y, w, h, chartType, data, options)
    options = options or {}
    local obj = core.Base:new(x, y, w, h, options)

    obj.chartType = chartType or Chart.types.LINE
    obj.data = data or {}
    obj.animatedData = {}

    -- Chart configuration
    obj.title = options.title or ""
    obj.xAxisLabel = options.xAxisLabel or ""
    obj.yAxisLabel = options.yAxisLabel or ""
    obj.showGrid = options.showGrid ~= false
    obj.showLegend = options.showLegend ~= false
    obj.showTooltips = options.showTooltips ~= false
    obj.showValues = options.showValues or false

    -- Margins and padding
    obj.margins = options.margins or { top = 40, right = 20, bottom = 40, left = 60 }
    obj.legendHeight = options.legendHeight or 30

    -- Animation options
    obj.animateOnLoad = options.animateOnLoad ~= false
    obj.animationDuration = options.animationDuration or 1.0
    obj.animationDelay = options.animationDelay or 0.05 -- delay between bars/points

    -- Visual options
    obj.colors = options.colors or {
        { 0.2, 0.6, 1.0 }, { 1.0, 0.6, 0.2 }, { 0.2, 1.0, 0.6 }, { 1.0, 0.2, 0.6 },
        { 0.6, 0.2, 1.0 }, { 1.0, 1.0, 0.2 }, { 0.6, 1.0, 0.2 }, { 1.0, 0.2, 0.2 }
    }
    obj.lineWidth = options.lineWidth or 2
    obj.pointRadius = options.pointRadius or 4
    obj.barSpacing = options.barSpacing or 0.1

    -- Interaction state
    obj.hoveredElement = nil
    obj.tooltip = { visible = false, x = 0, y = 0, text = "" }

    -- Data processing
    obj.processedData = {}
    obj.dataRange = { minX = 0, maxX = 0, minY = 0, maxY = 0 }

    setmetatable(obj, self)
    obj:_processData()
    obj:_initAnimations()
    return obj
end

function Chart:setData(data, animate)
    self.data = data or {}
    self:_processData()

    if animate ~= false then
        self:_initAnimations()
    else
        self.animatedData = self.processedData
    end
end

function Chart:_processData()
    self.processedData = {}
    self.dataRange = { minX = math.huge, maxX = -math.huge, minY = math.huge, maxY = -math.huge }

    if self.chartType == Chart.types.PIE then
        self:_processPieData()
    else
        self:_processSeriesData()
    end
end

function Chart:_processPieData()
    local total = 0
    for _, item in ipairs(self.data) do
        total = total + (item.value or 0)
    end

    local currentAngle = -math.pi / 2 -- Start from top
    for i, item in ipairs(self.data) do
        local percentage = (item.value or 0) / total
        local sweepAngle = percentage * 2 * math.pi

        table.insert(self.processedData, {
            label = item.label or ("Item " .. i),
            value = item.value or 0,
            percentage = percentage,
            startAngle = currentAngle,
            endAngle = currentAngle + sweepAngle,
            sweepAngle = sweepAngle,
            color = item.color or self.colors[((i - 1) % #self.colors) + 1]
        })

        currentAngle = currentAngle + sweepAngle
    end
end

function Chart:_processSeriesData()
    for seriesIndex, series in ipairs(self.data) do
        local processedSeries = {
            label = series.label or ("Series " .. seriesIndex),
            color = series.color or self.colors[((seriesIndex - 1) % #self.colors) + 1],
            points = {}
        }

        for i, point in ipairs(series.data or {}) do
            local x, y
            if type(point) == "table" then
                x, y = point.x or i, point.y or 0
            else
                x, y = i, point
            end

            table.insert(processedSeries.points, { x = x, y = y, originalY = y })

            -- Update data range
            self.dataRange.minX = math.min(self.dataRange.minX, x)
            self.dataRange.maxX = math.max(self.dataRange.maxX, x)
            self.dataRange.minY = math.min(self.dataRange.minY, y)
            self.dataRange.maxY = math.max(self.dataRange.maxY, y)
        end

        table.insert(self.processedData, processedSeries)
    end

    -- Ensure reasonable range
    if self.dataRange.minY == self.dataRange.maxY then
        self.dataRange.minY = self.dataRange.minY - 1
        self.dataRange.maxY = self.dataRange.maxY + 1
    end
end

function Chart:_initAnimations()
    if not self.animateOnLoad then
        self.animatedData = self.processedData
        return
    end

    if self.chartType == Chart.types.PIE then
        -- Animate pie slices
        for i, slice in ipairs(self.processedData) do
            slice.animatedSweep = 0
            Animation.create(slice, "animatedSweep", 0, slice.sweepAngle,
                self.animationDuration, Animation.types.EASE_OUT,
                function() end)
        end
    else
        -- Animate series data
        self.animatedData = {}
        for seriesIndex, series in ipairs(self.processedData) do
            local animatedSeries = {
                label = series.label,
                color = series.color,
                points = {}
            }

            for pointIndex, point in ipairs(series.points) do
                local animatedPoint = { x = point.x, y = 0, originalY = point.originalY }
                table.insert(animatedSeries.points, animatedPoint)

                -- Stagger animation start times
                local delay = (seriesIndex - 1) * 0.1 + (pointIndex - 1) * self.animationDelay
                love.timer.sleep = love.timer.sleep or function() end -- Compatibility

                Animation.create(animatedPoint, "y", 0, point.y,
                    self.animationDuration, Animation.types.EASE_OUT,
                    function() end)
            end

            table.insert(self.animatedData, animatedSeries)
        end
    end
end

function Chart:update(dt)
    core.Base.update(self, dt)
    Animation.update(dt)

    -- Update hover detection
    local mx, my = love.mouse.getPosition()
    self.hoveredElement = nil

    if self:hitTest(mx, my) then
        if self.chartType == Chart.types.PIE then
            self:_updatePieHover(mx, my)
        else
            self:_updateSeriesHover(mx, my)
        end
    end
end

function Chart:_updatePieHover(mx, my)
    local centerX = self.x + self.w / 2
    local centerY = self.y + self.h / 2
    local radius = math.min(self.w, self.h) / 2 - 20

    local dx, dy = mx - centerX, my - centerY
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance <= radius then
        local angle = math.atan2(dy, dx)
        if angle < -math.pi / 2 then angle = angle + 2 * math.pi end

        for i, slice in ipairs(self.processedData) do
            if angle >= slice.startAngle and angle <= slice.endAngle then
                self.hoveredElement = { type = "pie", index = i }
                self.tooltip = {
                    visible = true,
                    x = mx + 10,
                    y = my - 10,
                    text = string.format("%s: %.1f (%.1f%%)", slice.label, slice.value, slice.percentage * 100)
                }
                break
            end
        end
    end
end

function Chart:_updateSeriesHover(mx, my)
    local chartX = self.x + self.margins.left
    local chartY = self.y + self.margins.top
    local chartW = self.w - self.margins.left - self.margins.right
    local chartH = self.h - self.margins.top - self.margins.bottom

    if self.showLegend then
        chartH = chartH - self.legendHeight
    end

    -- Convert mouse position to data coordinates
    local dataX = self.dataRange.minX + (mx - chartX) / chartW * (self.dataRange.maxX - self.dataRange.minX)
    local dataY = self.dataRange.maxY - (my - chartY) / chartH * (self.dataRange.maxY - self.dataRange.minY)

    -- Find nearest point or bar
    local minDistance = math.huge
    local nearestElement = nil

    for seriesIndex, series in ipairs(self.animatedData or self.processedData) do
        if self.chartType == Chart.types.COLUMN or self.chartType == Chart.types.BAR then
            -- Check bar hover
            for pointIndex, point in ipairs(series.points) do
                local barX, barY, barW, barH = self:_getBarBounds(seriesIndex, pointIndex, point)
                if mx >= barX and mx <= barX + barW and my >= barY and my <= barY + barH then
                    nearestElement = { type = "bar", series = seriesIndex, point = pointIndex }
                    break
                end
            end
        else
            -- Check point hover
            for pointIndex, point in ipairs(series.points) do
                local screenX = chartX +
                    (point.x - self.dataRange.minX) / (self.dataRange.maxX - self.dataRange.minX) * chartW
                local screenY = chartY + chartH -
                    (point.y - self.dataRange.minY) / (self.dataRange.maxY - self.dataRange.minY) * chartH

                local distance = math.sqrt((mx - screenX) ^ 2 + (my - screenY) ^ 2)
                if distance < minDistance and distance < 20 then
                    minDistance = distance
                    nearestElement = { type = "point", series = seriesIndex, point = pointIndex }
                end
            end
        end
    end

    if nearestElement then
        self.hoveredElement = nearestElement
        local series = (self.animatedData or self.processedData)[nearestElement.series]
        local point = series.points[nearestElement.point]

        self.tooltip = {
            visible = true,
            x = mx + 10,
            y = my - 10,
            text = string.format("%s: (%.1f, %.1f)", series.label, point.x, point.originalY or point.y)
        }
    end
end

function Chart:draw()
    core.Base.draw(self)

    -- Background
    love.graphics.setColor(unpack(core.theme.background))
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    -- Title
    if self.title ~= "" then
        love.graphics.setColor(unpack(core.theme.text))
        local font = love.graphics.getFont()
        local titleW = font:getWidth(self.title)
        love.graphics.print(self.title, self.x + self.w / 2 - titleW / 2, self.y + 5)
    end

    -- Draw chart based on type
    if self.chartType == Chart.types.PIE then
        self:_drawPieChart()
    else
        self:_drawSeriesChart()
    end

    -- Tooltip
    if self.tooltip.visible and self.showTooltips then
        self:_drawTooltip()
    end

    -- Border
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

function Chart:_drawPieChart()
    local centerX = self.x + self.w / 2
    local centerY = self.y + self.h / 2 - (self.showLegend and self.legendHeight / 2 or 0)
    local radius = math.min(self.w, self.h - (self.showLegend and self.legendHeight or 0)) / 2 - 30

    for i, slice in ipairs(self.processedData) do
        local sweepAngle = slice.animatedSweep or slice.sweepAngle

        if sweepAngle > 0 then
            -- Draw slice
            love.graphics.setColor(unpack(slice.color))
            love.graphics.arc("fill", centerX, centerY, radius, slice.startAngle, slice.startAngle + sweepAngle)

            -- Draw slice border
            love.graphics.setColor(unpack(core.theme.background))
            love.graphics.setLineWidth(2)
            love.graphics.arc("line", centerX, centerY, radius, slice.startAngle, slice.startAngle + sweepAngle)
            love.graphics.setLineWidth(1)

            -- Draw labels if enabled
            if self.showValues and slice.percentage > 0.05 then -- Only show labels for slices > 5%
                local labelAngle = slice.startAngle + sweepAngle / 2
                local labelRadius = radius * 0.7
                local labelX = centerX + math.cos(labelAngle) * labelRadius
                local labelY = centerY + math.sin(labelAngle) * labelRadius

                love.graphics.setColor(unpack(core.theme.text))
                local text = string.format("%.1f%%", slice.percentage * 100)
                local font = love.graphics.getFont()
                love.graphics.print(text, labelX - font:getWidth(text) / 2, labelY - font:getHeight() / 2)
            end

            -- Highlight hovered slice
            if self.hoveredElement and self.hoveredElement.type == "pie" and self.hoveredElement.index == i then
                love.graphics.setColor(1, 1, 1, 0.3)
                love.graphics.arc("fill", centerX, centerY, radius, slice.startAngle, slice.startAngle + sweepAngle)
            end
        end
    end

    -- Legend
    if self.showLegend then
        self:_drawPieLegend()
    end
end

function Chart:_drawSeriesChart()
    local chartX = self.x + self.margins.left
    local chartY = self.y + self.margins.top
    local chartW = self.w - self.margins.left - self.margins.right
    local chartH = self.h - self.margins.top - self.margins.bottom

    if self.showLegend then
        chartH = chartH - self.legendHeight
    end

    -- Draw grid
    if self.showGrid then
        self:_drawGrid(chartX, chartY, chartW, chartH)
    end

    -- Draw axes
    self:_drawAxes(chartX, chartY, chartW, chartH)

    -- Draw data
    local dataToUse = self.animatedData or self.processedData
    for seriesIndex, series in ipairs(dataToUse) do
        if self.chartType == Chart.types.LINE or self.chartType == Chart.types.AREA then
            self:_drawLineSeries(series, seriesIndex, chartX, chartY, chartW, chartH)
        elseif self.chartType == Chart.types.COLUMN or self.chartType == Chart.types.BAR then
            self:_drawBarSeries(series, seriesIndex, chartX, chartY, chartW, chartH)
        elseif self.chartType == Chart.types.SCATTER then
            self:_drawScatterSeries(series, seriesIndex, chartX, chartY, chartW, chartH)
        end
    end

    -- Legend
    if self.showLegend then
        self:_drawSeriesLegend(chartY + chartH + 10)
    end
end

function Chart:_drawGrid(chartX, chartY, chartW, chartH)
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.setColor(core.theme.border[1], core.theme.border[2], core.theme.border[3], 0.3)

    -- Vertical grid lines
    local xSteps = 5
    for i = 0, xSteps do
        local x = chartX + (i / xSteps) * chartW
        love.graphics.line(x, chartY, x, chartY + chartH)
    end

    -- Horizontal grid lines
    local ySteps = 5
    for i = 0, ySteps do
        local y = chartY + (i / ySteps) * chartH
        love.graphics.line(chartX, y, chartX + chartW, y)
    end
end

function Chart:_drawAxes(chartX, chartY, chartW, chartH)
    love.graphics.setColor(unpack(core.theme.text))

    -- X-axis
    love.graphics.line(chartX, chartY + chartH, chartX + chartW, chartY + chartH)

    -- Y-axis
    love.graphics.line(chartX, chartY, chartX, chartY + chartH)

    -- Axis labels and ticks
    local font = love.graphics.getFont()

    -- X-axis labels
    local xSteps = 5
    for i = 0, xSteps do
        local x = chartX + (i / xSteps) * chartW
        local value = self.dataRange.minX + (i / xSteps) * (self.dataRange.maxX - self.dataRange.minX)
        local text = string.format("%.1f", value)
        love.graphics.print(text, x - font:getWidth(text) / 2, chartY + chartH + 5)

        -- Tick mark
        love.graphics.line(x, chartY + chartH, x, chartY + chartH + 3)
    end

    -- Y-axis labels
    local ySteps = 5
    for i = 0, ySteps do
        local y = chartY + chartH - (i / ySteps) * chartH
        local value = self.dataRange.minY + (i / ySteps) * (self.dataRange.maxY - self.dataRange.minY)
        local text = string.format("%.1f", value)
        love.graphics.print(text, chartX - font:getWidth(text) - 5, y - font:getHeight() / 2)

        -- Tick mark
        love.graphics.line(chartX - 3, y, chartX, y)
    end

    -- Axis titles
    if self.xAxisLabel ~= "" then
        local labelW = font:getWidth(self.xAxisLabel)
        love.graphics.print(self.xAxisLabel, chartX + chartW / 2 - labelW / 2, chartY + chartH + 25)
    end

    if self.yAxisLabel ~= "" then
        -- Rotate text for Y-axis label (simplified)
        love.graphics.print(self.yAxisLabel, self.x + 5, chartY + chartH / 2)
    end
end

function Chart:_drawLineSeries(series, seriesIndex, chartX, chartY, chartW, chartH)
    love.graphics.setColor(unpack(series.color))
    love.graphics.setLineWidth(self.lineWidth)

    local points = {}
    for _, point in ipairs(series.points) do
        local screenX = chartX + (point.x - self.dataRange.minX) / (self.dataRange.maxX - self.dataRange.minX) * chartW
        local screenY = chartY + chartH -
            (point.y - self.dataRange.minY) / (self.dataRange.maxY - self.dataRange.minY) * chartH
        table.insert(points, screenX)
        table.insert(points, screenY)
    end

    if #points >= 4 then
        -- Draw area fill if area chart
        if self.chartType == Chart.types.AREA then
            local areaPoints = {}
            for i = 1, #points do
                table.insert(areaPoints, points[i])
            end
            -- Close the area
            table.insert(areaPoints, chartX + chartW)
            table.insert(areaPoints, chartY + chartH)
            table.insert(areaPoints, chartX)
            table.insert(areaPoints, chartY + chartH)

            love.graphics.setColor(series.color[1], series.color[2], series.color[3], 0.3)
            love.graphics.polygon("fill", areaPoints)
            love.graphics.setColor(unpack(series.color))
        end

        -- Draw line
        love.graphics.line(points)
    end

    -- Draw points
    for i = 1, #points, 2 do
        love.graphics.circle("fill", points[i], points[i + 1], self.pointRadius)

        -- Highlight hovered point
        if self.hoveredElement and self.hoveredElement.type == "point" and
            self.hoveredElement.series == seriesIndex and
            self.hoveredElement.point == math.floor(i / 2) + 1 then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.circle("fill", points[i], points[i + 1], self.pointRadius + 2)
            love.graphics.setColor(unpack(series.color))
        end
    end

    love.graphics.setLineWidth(1)
end

function Chart:_drawBarSeries(series, seriesIndex, chartX, chartY, chartW, chartH)
    local numSeries = #(self.animatedData or self.processedData)
    local numPoints = #series.points

    for pointIndex, point in ipairs(series.points) do
        local barX, barY, barW, barH = self:_getBarBounds(seriesIndex, pointIndex, point, chartX, chartY, chartW, chartH,
            numSeries, numPoints)

        -- Draw bar
        love.graphics.setColor(unpack(series.color))
        love.graphics.rectangle("fill", barX, barY, barW, barH)

        -- Draw bar border
        love.graphics.setColor(unpack(core.theme.border))
        love.graphics.rectangle("line", barX, barY, barW, barH)

        -- Highlight hovered bar
        if self.hoveredElement and self.hoveredElement.type == "bar" and
            self.hoveredElement.series == seriesIndex and
            self.hoveredElement.point == pointIndex then
            love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.rectangle("fill", barX, barY, barW, barH)
        end

        -- Draw value labels if enabled
        if self.showValues then
            love.graphics.setColor(unpack(core.theme.text))
            local text = string.format("%.1f", point.originalY or point.y)
            local font = love.graphics.getFont()
            love.graphics.print(text, barX + barW / 2 - font:getWidth(text) / 2, barY - font:getHeight() - 2)
        end
    end
end

function Chart:_getBarBounds(seriesIndex, pointIndex, point, chartX, chartY, chartW, chartH, numSeries, numPoints)
    chartX = chartX or (self.x + self.margins.left)
    chartY = chartY or (self.y + self.margins.top)
    chartW = chartW or (self.w - self.margins.left - self.margins.right)
    chartH = chartH or (self.h - self.margins.top - self.margins.bottom - (self.showLegend and self.legendHeight or 0))
    numSeries = numSeries or #(self.animatedData or self.processedData)
    numPoints = numPoints or #point

    local barGroupWidth = chartW / numPoints * (1 - self.barSpacing)
    local barWidth = barGroupWidth / numSeries
    local barHeight = math.abs(point.y - self.dataRange.minY) / (self.dataRange.maxY - self.dataRange.minY) * chartH

    local groupX = chartX + (pointIndex - 1) / numPoints * chartW + self.barSpacing * chartW / (2 * numPoints)
    local barX = groupX + (seriesIndex - 1) * barWidth
    local barY = chartY + chartH - barHeight

    if point.y < 0 then
        barY = chartY + chartH - (0 - self.dataRange.minY) / (self.dataRange.maxY - self.dataRange.minY) * chartH
    end

    return barX, barY, barWidth, barHeight
end

function Chart:_drawScatterSeries(series, seriesIndex, chartX, chartY, chartW, chartH)
    love.graphics.setColor(unpack(series.color))

    for pointIndex, point in ipairs(series.points) do
        local screenX = chartX + (point.x - self.dataRange.minX) / (self.dataRange.maxX - self.dataRange.minX) * chartW
        local screenY = chartY + chartH -
            (point.y - self.dataRange.minY) / (self.dataRange.maxY - self.dataRange.minY) * chartH

        love.graphics.circle("fill", screenX, screenY, self.pointRadius)

        -- Highlight hovered point
        if self.hoveredElement and self.hoveredElement.type == "point" and
            self.hoveredElement.series == seriesIndex and
            self.hoveredElement.point == pointIndex then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.circle("fill", screenX, screenY, self.pointRadius + 2)
            love.graphics.setColor(unpack(series.color))
        end
    end
end

function Chart:_drawPieLegend()
    local legendY = self.y + self.h - self.legendHeight
    local itemWidth = self.w / #self.processedData

    for i, slice in ipairs(self.processedData) do
        local x = self.x + (i - 1) * itemWidth

        -- Color box
        love.graphics.setColor(unpack(slice.color))
        love.graphics.rectangle("fill", x + 5, legendY + 5, 15, 15)
        love.graphics.setColor(unpack(core.theme.border))
        love.graphics.rectangle("line", x + 5, legendY + 5, 15, 15)

        -- Label
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.printf(slice.label, x + 25, legendY + 7, itemWidth - 30, "left")
    end
end

function Chart:_drawSeriesLegend(legendY)
    local itemWidth = self.w / #(self.animatedData or self.processedData)

    for i, series in ipairs(self.animatedData or self.processedData) do
        local x = self.x + (i - 1) * itemWidth

        -- Color box
        love.graphics.setColor(unpack(series.color))
        love.graphics.rectangle("fill", x + 5, legendY + 5, 15, 15)
        love.graphics.setColor(unpack(core.theme.border))
        love.graphics.rectangle("line", x + 5, legendY + 5, 15, 15)

        -- Label
        love.graphics.setColor(unpack(core.theme.text))
        love.graphics.printf(series.label, x + 25, legendY + 7, itemWidth - 30, "left")
    end
end

function Chart:_drawTooltip()
    local padding = 8
    local font = love.graphics.getFont()
    local textW = font:getWidth(self.tooltip.text)
    local textH = font:getHeight()

    -- Background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", self.tooltip.x, self.tooltip.y, textW + padding * 2, textH + padding * 2)

    -- Border
    love.graphics.setColor(unpack(core.theme.border))
    love.graphics.rectangle("line", self.tooltip.x, self.tooltip.y, textW + padding * 2, textH + padding * 2)

    -- Text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.tooltip.text, self.tooltip.x + padding, self.tooltip.y + padding)
end

-- Public methods
function Chart:addDataSeries(label, data, color)
    local series = {
        label = label,
        data = data,
        color = color or self.colors[#self.data + 1] or { 0.5, 0.5, 0.5 }
    }
    table.insert(self.data, series)
    self:_processData()
    if self.animateOnLoad then
        self:_initAnimations()
    end
end

function Chart:removeDataSeries(index)
    if index > 0 and index <= #self.data then
        table.remove(self.data, index)
        self:_processData()
    end
end

function Chart:setChartType(chartType)
    self.chartType = chartType
    self:_processData()
    if self.animateOnLoad then
        self:_initAnimations()
    end
end

return Chart






