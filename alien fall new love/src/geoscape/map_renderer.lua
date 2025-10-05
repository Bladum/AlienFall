--- Map Renderer for Geoscape
-- Handles rendering of world map, provinces, missions, crafts, and radar coverage
-- Designed for 800x600 internal resolution with 20x20 grid system
--
-- @module geoscape.map_renderer

local MapRenderer = {}

--- Initialize map renderer
-- @param viewport table: {x, y, width, height} viewport bounds
-- @return MapRenderer instance
function MapRenderer.new(viewport)
    local self = {
        viewport = viewport or {x = 0, y = 40, width = 800, height = 560},
        provinceMarkerSize = 4,  -- 4 pixels for province dots
        missionMarkerSize = 8,   -- 8 pixels for mission icons
        craftMarkerSize = 6,     -- 6 pixels for craft icons
        radarAlpha = 0.3,        -- Radar coverage transparency
        gridSize = 20            -- Grid unit size
    }
    
    return setmetatable(self, {__index = MapRenderer})
end

--- Render the world map background
-- @param world World instance
function MapRenderer:drawBackground(world)
    if not world then return end
    
    -- Draw dark background
    love.graphics.setColor(0.05, 0.1, 0.15, 1)
    love.graphics.rectangle("fill", 
        self.viewport.x, 
        self.viewport.y, 
        self.viewport.width, 
        self.viewport.height)
    
    -- Draw grid lines (subtle)
    love.graphics.setColor(0.1, 0.15, 0.2, 0.3)
    
    -- Vertical lines every 100 pixels
    for x = 0, self.viewport.width, 100 do
        love.graphics.line(
            self.viewport.x + x, self.viewport.y,
            self.viewport.x + x, self.viewport.y + self.viewport.height)
    end
    
    -- Horizontal lines every 100 pixels
    for y = 0, self.viewport.height, 100 do
        love.graphics.line(
            self.viewport.x, self.viewport.y + y,
            self.viewport.x + self.viewport.width, self.viewport.y + y)
    end
end

--- Render all provinces as markers
-- @param world World instance
-- @param selectedProvince Province: Currently selected province (optional)
function MapRenderer:drawProvinces(world, selectedProvince)
    if not world then return end
    
    local provinces = world:getProvinces()
    if not provinces then return end
    
    for provinceId, province in pairs(provinces) do
        local x, y = province:getCoordinates()
        
        -- Convert to screen space
        local screenX = self.viewport.x + x
        local screenY = self.viewport.y + y
        
        -- Check if selected
        local isSelected = selectedProvince and (province == selectedProvince or province.id == selectedProvince.id)
        
        -- Draw province marker
        if isSelected then
            -- Selected: larger, brighter
            love.graphics.setColor(1, 1, 0, 1)  -- Yellow
            love.graphics.circle("fill", screenX, screenY, self.provinceMarkerSize + 2)
        else
            -- Normal: small dot
            local regionColor = self:getRegionColor(province:getRegionId())
            love.graphics.setColor(regionColor[1], regionColor[2], regionColor[3], 0.8)
            love.graphics.circle("fill", screenX, screenY, self.provinceMarkerSize)
        end
        
        -- Draw province outline
        love.graphics.setColor(0.3, 0.3, 0.4, 0.6)
        love.graphics.circle("line", screenX, screenY, self.provinceMarkerSize)
    end
end

--- Get color for region (for visual variety)
-- @param regionId string: Region identifier
-- @return table: {r, g, b} color
function MapRenderer:getRegionColor(regionId)
    -- Hash region ID to consistent color
    local hash = 0
    if regionId then
        for i = 1, #regionId do
            hash = hash + string.byte(regionId, i)
        end
    end
    
    local hue = (hash % 360) / 360
    return self:hsvToRgb(hue, 0.6, 0.7)
end

--- Convert HSV to RGB
-- @param h number: Hue (0-1)
-- @param s number: Saturation (0-1)
-- @param v number: Value (0-1)
-- @return table: {r, g, b}
function MapRenderer:hsvToRgb(h, s, v)
    local r, g, b
    
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return {r, g, b}
end

--- Render mission markers
-- @param missions table: Active missions {mission_id -> mission_data}
function MapRenderer:drawMissions(missions)
    if not missions then return end
    
    for missionId, mission in pairs(missions) do
        if mission.location then
            local x = mission.location.x or 0
            local y = mission.location.y or 0
            
            -- Convert to screen space
            local screenX = self.viewport.x + x
            local screenY = self.viewport.y + y
            
            -- Draw mission marker (pulsing red square)
            local pulse = math.sin(love.timer.getTime() * 3) * 0.2 + 0.8
            love.graphics.setColor(1, 0, 0, pulse)
            love.graphics.rectangle("fill", 
                screenX - self.missionMarkerSize/2, 
                screenY - self.missionMarkerSize/2,
                self.missionMarkerSize, 
                self.missionMarkerSize)
            
            -- Draw mission border
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("line",
                screenX - self.missionMarkerSize/2, 
                screenY - self.missionMarkerSize/2,
                self.missionMarkerSize, 
                self.missionMarkerSize)
            
            -- Draw mission type indicator
            local missionType = mission.type or "unknown"
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.print(missionType:sub(1, 1):upper(), 
                screenX - 3, 
                screenY - 10, 
                0, 
                0.8, 0.8)
        end
    end
end

--- Render craft markers
-- @param crafts table: Active crafts {craft_id -> craft_data}
-- @param selectedCraft table: Currently selected craft (optional)
function MapRenderer:drawCrafts(crafts, selectedCraft)
    if not crafts then return end
    
    for craftId, craft in pairs(crafts) do
        if craft.position then
            local x = craft.position.x or 0
            local y = craft.position.y or 0
            
            -- Convert to screen space
            local screenX = self.viewport.x + x
            local screenY = self.viewport.y + y
            
            -- Check if selected
            local isSelected = selectedCraft and (craft == selectedCraft or craft.id == selectedCraft.id)
            
            -- Draw craft marker (triangle pointing right)
            if isSelected then
                love.graphics.setColor(0, 1, 0, 1)  -- Green when selected
            else
                love.graphics.setColor(0, 0.7, 1, 0.9)  -- Blue
            end
            
            local size = isSelected and self.craftMarkerSize + 2 or self.craftMarkerSize
            love.graphics.polygon("fill",
                screenX + size, screenY,           -- Right point
                screenX - size/2, screenY - size,  -- Top left
                screenX - size/2, screenY + size)  -- Bottom left
            
            -- Draw craft border
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.polygon("line",
                screenX + size, screenY,
                screenX - size/2, screenY - size,
                screenX - size/2, screenY + size)
        end
    end
end

--- Render radar coverage circles
-- @param bases table: Bases with radar {base_id -> base_data}
function MapRenderer:drawRadarCoverage(bases)
    if not bases then return end
    
    for baseId, base in pairs(bases) do
        if base.position and base.radar_range then
            local x = base.position.x or 0
            local y = base.position.y or 0
            
            -- Convert to screen space
            local screenX = self.viewport.x + x
            local screenY = self.viewport.y + y
            
            -- Draw radar circle (semi-transparent)
            love.graphics.setColor(0, 1, 0, self.radarAlpha)
            love.graphics.circle("fill", screenX, screenY, base.radar_range)
            
            -- Draw radar border
            love.graphics.setColor(0, 1, 0, 0.6)
            love.graphics.circle("line", screenX, screenY, base.radar_range)
        end
    end
end

--- Render craft movement path
-- @param craft table: Craft with path data
function MapRenderer:drawCraftPath(craft)
    if not craft or not craft.position or not craft.destination then return end
    
    local startX = self.viewport.x + craft.position.x
    local startY = self.viewport.y + craft.position.y
    local endX = self.viewport.x + craft.destination.x
    local endY = self.viewport.y + craft.destination.y
    
    -- Draw dashed line for path
    love.graphics.setColor(0.5, 0.8, 1, 0.6)
    local segments = 10
    for i = 0, segments do
        local t1 = i / segments
        local t2 = (i + 0.5) / segments
        
        local x1 = startX + (endX - startX) * t1
        local y1 = startY + (endY - startY) * t1
        local x2 = startX + (endX - startX) * t2
        local y2 = startY + (endY - startY) * t2
        
        love.graphics.line(x1, y1, x2, y2)
    end
    
    -- Draw destination marker
    love.graphics.setColor(1, 1, 0, 0.8)
    love.graphics.circle("line", endX, endY, 8)
end

--- Render legend/key
-- @param x number: Legend X position
-- @param y number: Legend Y position
function MapRenderer:drawLegend(x, y)
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", x, y, 150, 100)
    love.graphics.setColor(0.5, 0.5, 0.8, 1)
    love.graphics.rectangle("line", x, y, 150, 100)
    
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local lineHeight = 15
    local textY = y + 5
    
    -- Province
    love.graphics.circle("fill", x + 10, textY + 7, 4)
    love.graphics.print("Province", x + 20, textY)
    textY = textY + lineHeight
    
    -- Mission
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", x + 6, textY + 3, 8, 8)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Mission", x + 20, textY)
    textY = textY + lineHeight
    
    -- Craft
    love.graphics.setColor(0, 0.7, 1, 1)
    love.graphics.polygon("fill", x + 14, textY + 7, x + 6, textY + 3, x + 6, textY + 11)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Craft", x + 20, textY)
    textY = textY + lineHeight
    
    -- Radar
    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.circle("fill", x + 10, textY + 7, 6)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Radar", x + 20, textY)
end

return MapRenderer
