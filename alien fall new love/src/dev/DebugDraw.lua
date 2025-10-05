-- DebugDraw - Visual debug overlays for game systems
-- Displays pathfinding, LOS, detection ranges, collisions, AI states, and more

local class = require('lib.middleclass')
local Logger = require('engine.logger')

local DebugDraw = class('DebugDraw')

function DebugDraw:initialize()
    self.logger = Logger.new("DebugDraw")
    
    -- Toggle flags for different visualization modes
    self.show_pathfinding = false
    self.show_los = false
    self.show_detection = false
    self.show_collision = false
    self.show_ai_state = false
    self.show_grid = false
    self.show_coordinates = false
    
    -- Data to visualize (set by game systems)
    self.pathfinding_data = nil
    self.los_data = nil
    self.detection_data = nil
    self.collision_data = nil
    self.ai_state_data = nil
    
    -- Font for labels
    self.font = love.graphics.newFont(12)
    
    self.logger:info("DebugDraw initialized")
end

-- Toggle functions
function DebugDraw:togglePathfinding()
    self.show_pathfinding = not self.show_pathfinding
    self.logger:info("Pathfinding visualization: " .. (self.show_pathfinding and "ON" or "OFF"))
    return self.show_pathfinding
end

function DebugDraw:toggleLOS()
    self.show_los = not self.show_los
    self.logger:info("LOS visualization: " .. (self.show_los and "ON" or "OFF"))
    return self.show_los
end

function DebugDraw:toggleDetection()
    self.show_detection = not self.show_detection
    self.logger:info("Detection visualization: " .. (self.show_detection and "ON" or "OFF"))
    return self.show_detection
end

function DebugDraw:toggleCollision()
    self.show_collision = not self.show_collision
    self.logger:info("Collision visualization: " .. (self.show_collision and "ON" or "OFF"))
    return self.show_collision
end

function DebugDraw:toggleAI()
    self.show_ai_state = not self.show_ai_state
    self.logger:info("AI state visualization: " .. (self.show_ai_state and "ON" or "OFF"))
    return self.show_ai_state
end

function DebugDraw:toggleGrid()
    self.show_grid = not self.show_grid
    self.logger:info("Grid visualization: " .. (self.show_grid and "ON" or "OFF"))
    return self.show_grid
end

function DebugDraw:toggleCoordinates()
    self.show_coordinates = not self.show_coordinates
    self.logger:info("Coordinate visualization: " .. (self.show_coordinates and "ON" or "OFF"))
    return self.show_coordinates
end

function DebugDraw:toggleAll(state)
    self.show_pathfinding = state
    self.show_los = state
    self.show_detection = state
    self.show_collision = state
    self.show_ai_state = state
    self.logger:info("All debug visualizations: " .. (state and "ON" or "OFF"))
end

-- Data setters (called by game systems)
function DebugDraw:setPathfindingData(data)
    self.pathfinding_data = data
end

function DebugDraw:setLOSData(data)
    self.los_data = data
end

function DebugDraw:setDetectionData(data)
    self.detection_data = data
end

function DebugDraw:setCollisionData(data)
    self.collision_data = data
end

function DebugDraw:setAIStateData(data)
    self.ai_state_data = data
end

-- Draw methods
function DebugDraw:draw()
    if self.show_grid then
        self:drawGrid()
    end
    
    if self.show_pathfinding and self.pathfinding_data then
        self:drawPathfinding()
    end
    
    if self.show_los and self.los_data then
        self:drawLOS()
    end
    
    if self.show_detection and self.detection_data then
        self:drawDetection()
    end
    
    if self.show_collision and self.collision_data then
        self:drawCollision()
    end
    
    if self.show_ai_state and self.ai_state_data then
        self:drawAIState()
    end
    
    if self.show_coordinates then
        self:drawCoordinates()
    end
    
    -- Draw legend
    self:drawLegend()
end

function DebugDraw:drawGrid()
    love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
    love.graphics.setLineWidth(1)
    
    -- Draw 20x20 grid
    local grid_size = 20
    local width, height = 800, 600  -- Internal resolution
    
    for x = 0, width, grid_size do
        love.graphics.line(x, 0, x, height)
    end
    
    for y = 0, height, grid_size do
        love.graphics.line(0, y, width, y)
    end
end

function DebugDraw:drawPathfinding()
    if not self.pathfinding_data then
        return
    end
    
    -- Draw path waypoints
    if self.pathfinding_data.path then
        love.graphics.setColor(0, 1, 0, 0.7)
        love.graphics.setLineWidth(3)
        
        for i = 1, #self.pathfinding_data.path - 1 do
            local p1 = self.pathfinding_data.path[i]
            local p2 = self.pathfinding_data.path[i + 1]
            love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        end
        
        -- Draw waypoint circles
        for _, point in ipairs(self.pathfinding_data.path) do
            love.graphics.circle('fill', point.x, point.y, 3)
        end
    end
    
    -- Draw movement cost overlay
    if self.pathfinding_data.costs then
        love.graphics.setFont(self.font)
        for _, tile in ipairs(self.pathfinding_data.costs) do
            local color_intensity = math.min(tile.cost / 10, 1)
            love.graphics.setColor(1, 1 - color_intensity, 0, 0.3)
            love.graphics.rectangle('fill', tile.x, tile.y, tile.width or 20, tile.height or 20)
            
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.print(string.format("%.1f", tile.cost), tile.x + 2, tile.y + 2)
        end
    end
end

function DebugDraw:drawLOS()
    if not self.los_data then
        return
    end
    
    -- Draw LOS rays
    if self.los_data.rays then
        love.graphics.setLineWidth(1)
        
        for _, ray in ipairs(self.los_data.rays) do
            if ray.blocked then
                love.graphics.setColor(1, 0, 0, 0.3)
            else
                love.graphics.setColor(0, 1, 0, 0.3)
            end
            
            love.graphics.line(ray.start_x, ray.start_y, ray.end_x, ray.end_y)
            
            if ray.blocked and ray.block_x and ray.block_y then
                love.graphics.setColor(1, 0, 0, 0.8)
                love.graphics.circle('fill', ray.block_x, ray.block_y, 4)
            end
        end
    end
    
    -- Draw visible tiles
    if self.los_data.visible_tiles then
        love.graphics.setColor(0, 1, 0, 0.2)
        for _, tile in ipairs(self.los_data.visible_tiles) do
            love.graphics.rectangle('fill', tile.x, tile.y, tile.width or 20, tile.height or 20)
        end
    end
end

function DebugDraw:drawDetection()
    if not self.detection_data then
        return
    end
    
    -- Draw detection ranges
    if self.detection_data.ranges then
        love.graphics.setLineWidth(2)
        
        for _, range in ipairs(self.detection_data.ranges) do
            if range.detected then
                love.graphics.setColor(1, 0, 0, 0.5)
            else
                love.graphics.setColor(0, 0.5, 1, 0.3)
            end
            
            love.graphics.circle('line', range.x, range.y, range.radius)
            
            -- Draw range label
            love.graphics.setFont(self.font)
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.print(string.format("%.0f", range.radius), 
                range.x - 10, range.y - range.radius - 15)
        end
    end
    
    -- Draw detection markers
    if self.detection_data.markers then
        for _, marker in ipairs(self.detection_data.markers) do
            love.graphics.setColor(1, 1, 0, 0.8)
            love.graphics.circle('fill', marker.x, marker.y, 5)
            love.graphics.setColor(1, 0, 0, 0.8)
            love.graphics.circle('line', marker.x, marker.y, 5)
        end
    end
end

function DebugDraw:drawCollision()
    if not self.collision_data then
        return
    end
    
    love.graphics.setLineWidth(2)
    
    -- Draw collision boxes
    if self.collision_data.boxes then
        for _, box in ipairs(self.collision_data.boxes) do
            if box.colliding then
                love.graphics.setColor(1, 0, 0, 0.5)
            else
                love.graphics.setColor(0, 1, 0, 0.3)
            end
            
            love.graphics.rectangle('line', box.x, box.y, box.width, box.height)
            
            -- Draw center point
            local center_x = box.x + box.width / 2
            local center_y = box.y + box.height / 2
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.circle('fill', center_x, center_y, 2)
        end
    end
end

function DebugDraw:drawAIState()
    if not self.ai_state_data then
        return
    end
    
    love.graphics.setFont(self.font)
    
    -- Draw AI state labels above units
    if self.ai_state_data.units then
        for _, unit in ipairs(self.ai_state_data.units) do
            local x = unit.x or 0
            local y = unit.y or 0
            
            -- Background
            local text = unit.state or "IDLE"
            local text_width = self.font:getWidth(text)
            local text_height = self.font:getHeight()
            
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle('fill', x - text_width/2 - 3, y - 30, text_width + 6, text_height + 4)
            
            -- State color
            local state_color = self:getAIStateColor(unit.state)
            love.graphics.setColor(state_color[1], state_color[2], state_color[3], 1)
            love.graphics.print(text, x - text_width/2, y - 28)
            
            -- Draw decision tree if available
            if unit.decision then
                love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
                love.graphics.print(unit.decision, x - text_width/2, y - 12)
            end
        end
    end
end

function DebugDraw:drawCoordinates()
    local mouse_x, mouse_y = love.mouse.getPosition()
    
    -- Transform to internal coordinates (needs to be done by caller or passed in)
    -- For now, just show screen coordinates
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle('fill', mouse_x + 10, mouse_y + 10, 100, 40)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("X: %d", mouse_x), mouse_x + 15, mouse_y + 15)
    love.graphics.print(string.format("Y: %d", mouse_y), mouse_x + 15, mouse_y + 30)
end

function DebugDraw:drawLegend()
    local any_active = self.show_pathfinding or self.show_los or self.show_detection or 
                       self.show_collision or self.show_ai_state or self.show_grid
    
    if not any_active then
        return
    end
    
    local x = 10
    local y = 70
    local line_height = 18
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle('fill', x, y, 200, 130)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Debug Visualizations", x + 5, y + 5)
    y = y + line_height + 5
    
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    
    if self.show_pathfinding then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.print("■ Pathfinding", x + 5, y)
        y = y + line_height
    end
    
    if self.show_los then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.print("■ Line of Sight", x + 5, y)
        y = y + line_height
    end
    
    if self.show_detection then
        love.graphics.setColor(0, 0.5, 1, 1)
        love.graphics.print("■ Detection", x + 5, y)
        y = y + line_height
    end
    
    if self.show_collision then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("■ Collision", x + 5, y)
        y = y + line_height
    end
    
    if self.show_ai_state then
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.print("■ AI States", x + 5, y)
        y = y + line_height
    end
    
    if self.show_grid then
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.print("■ Grid", x + 5, y)
        y = y + line_height
    end
end

function DebugDraw:getAIStateColor(state)
    local colors = {
        IDLE = {0.5, 0.5, 0.5},
        PATROL = {0, 0.8, 1},
        SEARCH = {1, 1, 0},
        COMBAT = {1, 0, 0},
        FLEE = {1, 0.5, 0},
        COVER = {0, 1, 0},
        MOVE = {0, 1, 1}
    }
    
    return colors[state] or {1, 1, 1}
end

-- Keyboard handling
function DebugDraw:keypressed(key)
    local handled = false
    
    if key == "p" then
        self:togglePathfinding()
        handled = true
    elseif key == "l" then
        self:toggleLOS()
        handled = true
    elseif key == "d" then
        self:toggleDetection()
        handled = true
    elseif key == "c" then
        self:toggleCollision()
        handled = true
    elseif key == "a" then
        self:toggleAI()
        handled = true
    elseif key == "g" then
        self:toggleGrid()
        handled = true
    elseif key == "m" then
        self:toggleCoordinates()
        handled = true
    end
    
    return handled
end

return DebugDraw
