-- Geoscape Render Module
-- Contains rendering and drawing logic

local GeoscapeRender = {}

function GeoscapeRender:draw()
    -- Clear background
    love.graphics.clear(0.05, 0.05, 0.15)
    
    -- Apply camera transformations
    love.graphics.push()
    love.graphics.scale(self.camera.zoom)
    love.graphics.translate(self.camera.x, self.camera.y)
    
    -- Draw connections between provinces
    love.graphics.setColor(0.3, 0.3, 0.4, 0.6)
    love.graphics.setLineWidth(2 / self.camera.zoom) -- Scale line width with zoom
    for _, province in ipairs(self.provinces) do
        for _, connId in ipairs(province.connections) do
            local connProvince = self:getProvinceById(connId)
            if connProvince then
                love.graphics.line(
                    province.x,
                    province.y,
                    connProvince.x,
                    connProvince.y
                )
            end
        end
    end
    
    -- Draw provinces
    for _, province in ipairs(self.provinces) do
        local isHovered = self.hoveredProvince == province
        local isSelected = self.selectedProvince == province
        
        -- Province circle (scale with zoom)
        local radius = 25 / self.camera.zoom
        if isSelected then
            love.graphics.setColor(0.9, 0.6, 0.2)
        elseif isHovered then
            love.graphics.setColor(0.5, 0.5, 0.7)
        elseif province.hasBase then
            love.graphics.setColor(0.2, 0.6, 0.3)
        else
            love.graphics.setColor(0.3, 0.3, 0.5)
        end
        
        love.graphics.circle("fill", province.x, province.y, radius)
        
        -- Border
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("line", province.x, province.y, radius)
        
        -- Province name (only show if zoomed in enough)
        if self.camera.zoom > 0.7 then
            love.graphics.setColor(1, 1, 1)
            local fontSize = math.max(12, 16 / self.camera.zoom)
            local font = love.graphics.newFont(fontSize)
            love.graphics.setFont(font)
            
            -- Shorten long names for readability
            local displayName = self:shortenProvinceName(province.name)
            local textWidth = font:getWidth(displayName)
            love.graphics.print(
                displayName,
                province.x - textWidth / 2,
                province.y + radius + 5
            )
        end
        
        -- Base indicator
        if province.hasBase then
            love.graphics.setColor(1, 1, 0)
            love.graphics.circle("fill", province.x, province.y - radius - 5, 5 / self.camera.zoom)
        end
    end
    
    -- Reset transformations
    love.graphics.pop()
    
    -- Draw UI (outside camera transformations)
    self.backButton:draw()
    self.pauseButton:draw()
    self.infoPanel:draw()
    
    -- Draw province info if selected or hovered
    local displayProvince = self.selectedProvince or self.hoveredProvince
    if displayProvince then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(14))
        local panelX = self.infoPanel.x + 10
        local panelY = self.infoPanel.y + 35
        
        love.graphics.print(displayProvince.name, panelX, panelY)
        love.graphics.print("Population: " .. self:formatNumber(displayProvince.population), panelX, panelY + 20)
        love.graphics.print("Satisfaction: " .. displayProvince.satisfaction .. "%", panelX, panelY + 40)
        love.graphics.print("Funding: $" .. self:formatNumber(displayProvince.funding), panelX, panelY + 60)
        love.graphics.print("Base: " .. (displayProvince.hasBase and "Yes" or "No"), panelX, panelY + 80)
    end
    
    -- Draw zoom level and controls
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print(string.format("Zoom: %.1fx", self.camera.zoom), 10, love.graphics.getHeight() - 60)
    love.graphics.print("Mouse wheel: Zoom | RMB: Drag | Click: Select", 10, love.graphics.getHeight() - 40)
    
    -- Draw time
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    local timeText = string.format("Time: Day %d | %s", math.floor(self.gameTime / 86400), self.paused and "PAUSED" or "Running")
    love.graphics.print(timeText, love.graphics.getWidth() / 2 - 150, 10)
end

return GeoscapeRender