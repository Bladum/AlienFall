-- ProfilerUI - Visual overlay for profiling data
-- Displays frame time graphs, memory usage, and function timings

local class = require('lib.middleclass')

local ProfilerUI = class('ProfilerUI')

-- Configuration
ProfilerUI.static.PANEL_WIDTH = 400
ProfilerUI.static.PANEL_HEIGHT = 500
ProfilerUI.static.GRAPH_HEIGHT = 80
ProfilerUI.static.FONT_SIZE = 12

function ProfilerUI:initialize(profiler)
    self.profiler = profiler
    
    -- UI state
    self.visible = false
    self.x = 10
    self.y = 10
    self.width = ProfilerUI.static.PANEL_WIDTH
    self.height = ProfilerUI.static.PANEL_HEIGHT
    
    -- Font
    self.font = love.graphics.newFont(ProfilerUI.static.FONT_SIZE)
    
    -- View mode: 'overview', 'markers', 'memory'
    self.view_mode = 'overview'
end

function ProfilerUI:toggle()
    self.visible = not self.visible
    if self.visible and not self.profiler:isEnabled() then
        self.profiler:enable()
    end
end

function ProfilerUI:isVisible()
    return self.visible
end

function ProfilerUI:setViewMode(mode)
    self.view_mode = mode
end

function ProfilerUI:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- Draw border
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    
    -- Draw content based on view mode
    love.graphics.setFont(self.font)
    
    if self.view_mode == 'overview' then
        self:drawOverview()
    elseif self.view_mode == 'markers' then
        self:drawMarkers()
    elseif self.view_mode == 'memory' then
        self:drawMemory()
    end
    
    -- Draw controls help at bottom
    self:drawControls()
end

function ProfilerUI:drawOverview()
    local y = self.y + 10
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Performance Profiler - Overview", self.x + 10, y)
    y = y + 25
    
    -- Stats
    local stats = self.profiler:getStats()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    
    love.graphics.print(string.format("FPS: %d", stats.fps), self.x + 10, y)
    y = y + 20
    
    love.graphics.print(string.format("Frame Time: %.2f ms (avg)", stats.avg_frame_time), self.x + 10, y)
    y = y + 15
    
    love.graphics.print(string.format("  Min: %.2f ms", stats.min_frame_time), self.x + 20, y)
    y = y + 15
    
    love.graphics.print(string.format("  Max: %.2f ms", stats.max_frame_time), self.x + 20, y)
    y = y + 20
    
    love.graphics.print(string.format("Memory: %.2f MB", stats.memory_current / 1024), self.x + 10, y)
    y = y + 15
    
    love.graphics.print(string.format("  Peak: %.2f MB", stats.memory_peak / 1024), self.x + 20, y)
    y = y + 25
    
    -- Frame time graph
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Frame Time History", self.x + 10, y)
    y = y + 20
    
    self:drawGraph(self.profiler:getFrameTimes(), self.x + 10, y, self.width - 20, ProfilerUI.static.GRAPH_HEIGHT, 
        {0, 1, 0, 1}, 0, 33.33)  -- 0-33ms range (30 FPS)
    y = y + ProfilerUI.static.GRAPH_HEIGHT + 20
    
    -- Memory graph
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Memory Usage History", self.x + 10, y)
    y = y + 20
    
    local memory_samples = self.profiler:getMemorySamples()
    local max_memory = stats.memory_peak
    self:drawGraph(memory_samples, self.x + 10, y, self.width - 20, ProfilerUI.static.GRAPH_HEIGHT,
        {0, 0.5, 1, 1}, 0, max_memory)
end

function ProfilerUI:drawMarkers()
    local y = self.y + 10
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Performance Profiler - Function Markers", self.x + 10, y)
    y = y + 25
    
    -- Marker list
    local markers = self.profiler:getMarkers()
    
    if #markers == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.print("No markers recorded", self.x + 10, y)
    else
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.print("Name", self.x + 10, y)
        love.graphics.print("Avg (ms)", self.x + 200, y)
        love.graphics.print("Calls", self.x + 300, y)
        y = y + 20
        
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.line(self.x + 10, y, self.x + self.width - 10, y)
        y = y + 5
        
        local max_visible = math.floor((self.height - 100) / 18)
        for i = 1, math.min(#markers, max_visible) do
            local marker = markers[i]
            
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
            
            -- Truncate name if too long
            local name = marker.name
            if #name > 25 then
                name = name:sub(1, 22) .. "..."
            end
            
            love.graphics.print(name, self.x + 10, y)
            love.graphics.print(string.format("%.2f", marker.avg_time), self.x + 200, y)
            love.graphics.print(tostring(marker.call_count), self.x + 300, y)
            
            y = y + 18
        end
    end
end

function ProfilerUI:drawMemory()
    local y = self.y + 10
    
    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Performance Profiler - Memory Details", self.x + 10, y)
    y = y + 25
    
    local stats = self.profiler:getStats()
    
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print(string.format("Current: %.2f MB", stats.memory_current / 1024), self.x + 10, y)
    y = y + 20
    
    love.graphics.print(string.format("Peak: %.2f MB", stats.memory_peak / 1024), self.x + 10, y)
    y = y + 30
    
    -- Large memory graph
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Memory Usage Over Time", self.x + 10, y)
    y = y + 20
    
    local memory_samples = self.profiler:getMemorySamples()
    self:drawGraph(memory_samples, self.x + 10, y, self.width - 20, 200,
        {0, 0.5, 1, 1}, 0, stats.memory_peak)
end

function ProfilerUI:drawGraph(samples, x, y, width, height, color, min_val, max_val)
    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.5)
    love.graphics.rectangle('fill', x, y, width, height)
    
    -- Draw border
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle('line', x, y, width, height)
    
    -- Draw grid lines
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    for i = 1, 4 do
        local grid_y = y + (height / 4) * i
        love.graphics.line(x, grid_y, x + width, grid_y)
    end
    
    -- Draw samples
    if not samples or #samples == 0 then
        return
    end
    
    -- Find actual min/max if not provided
    if not min_val or not max_val then
        min_val = math.huge
        max_val = -math.huge
        for _, sample in pairs(samples) do
            min_val = math.min(min_val, sample)
            max_val = math.max(max_val, sample)
        end
    end
    
    local range = max_val - min_val
    if range <= 0 then
        range = 1
    end
    
    love.graphics.setColor(color[1], color[2], color[3], color[4])
    love.graphics.setLineWidth(1)
    
    local points = {}
    local sample_width = width / #samples
    
    for i, sample in ipairs(samples) do
        if sample then
            local norm = (sample - min_val) / range
            local px = x + (i - 1) * sample_width
            local py = y + height - (norm * height)
            
            table.insert(points, px)
            table.insert(points, py)
        end
    end
    
    if #points >= 4 then
        love.graphics.line(points)
    end
    
    -- Draw value labels
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print(string.format("%.1f", max_val), x + width + 5, y)
    love.graphics.print(string.format("%.1f", min_val), x + width + 5, y + height - 12)
end

function ProfilerUI:drawControls()
    local y = self.y + self.height - 50
    
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.line(self.x, y, self.x + self.width, y)
    
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    y = y + 5
    
    love.graphics.print("F9: Toggle Profiler | 1: Overview | 2: Markers | 3: Memory", self.x + 10, y)
    y = y + 15
    love.graphics.print("R: Reset | P: Pause | E: Export", self.x + 10, y)
end

function ProfilerUI:keypressed(key)
    if not self.visible then
        return false
    end
    
    if key == "1" then
        self:setViewMode('overview')
        return true
    elseif key == "2" then
        self:setViewMode('markers')
        return true
    elseif key == "3" then
        self:setViewMode('memory')
        return true
    elseif key == "r" then
        self.profiler:reset()
        return true
    elseif key == "p" then
        if self.profiler:isPaused() then
            self.profiler:resume()
        else
            self.profiler:pause()
        end
        return true
    elseif key == "e" then
        local filename = "profiler_" .. os.date("%Y%m%d_%H%M%S") .. ".lua"
        self.profiler:exportData(filename)
        return true
    end
    
    return false
end

return ProfilerUI
