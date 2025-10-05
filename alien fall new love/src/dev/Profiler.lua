-- Profiler - Performance profiling and monitoring system
-- Tracks function calls, frame times, memory usage, and provides visualization

local class = require('lib.middleclass')
local Logger = require('engine.logger')

local Profiler = class('Profiler')

-- Configuration
Profiler.static.MAX_SAMPLES = 120  -- 2 seconds at 60 FPS
Profiler.static.MAX_MARKERS = 100

function Profiler:initialize()
    self.logger = Logger.new("Profiler")
    
    -- Frame timing
    self.frame_times = {}
    self.frame_index = 1
    
    -- Memory tracking
    self.memory_samples = {}
    self.memory_index = 1
    
    -- Function timing markers
    self.markers = {}
    self.active_markers = {}
    
    -- Statistics
    self.stats = {
        fps = 0,
        avg_frame_time = 0,
        min_frame_time = math.huge,
        max_frame_time = 0,
        memory_current = 0,
        memory_peak = 0,
        draw_calls = 0
    }
    
    -- State
    self.enabled = false
    self.paused = false
    
    self.logger:info("Profiler initialized")
end

function Profiler:enable()
    self.enabled = true
    self.logger:info("Profiler enabled")
end

function Profiler:disable()
    self.enabled = false
    self.logger:info("Profiler disabled")
end

function Profiler:toggle()
    self.enabled = not self.enabled
    self.logger:info("Profiler " .. (self.enabled and "enabled" or "disabled"))
end

function Profiler:isEnabled()
    return self.enabled
end

function Profiler:pause()
    self.paused = true
end

function Profiler:resume()
    self.paused = false
end

function Profiler:isPaused()
    return self.paused
end

function Profiler:beginFrame()
    if not self.enabled or self.paused then
        return
    end
    
    self.frame_start_time = love.timer.getTime()
end

function Profiler:endFrame()
    if not self.enabled or self.paused then
        return
    end
    
    local frame_time = (love.timer.getTime() - self.frame_start_time) * 1000  -- Convert to ms
    
    -- Store frame time
    self.frame_times[self.frame_index] = frame_time
    self.frame_index = (self.frame_index % Profiler.static.MAX_SAMPLES) + 1
    
    -- Update stats
    self.stats.fps = love.timer.getFPS()
    self.stats.min_frame_time = math.min(self.stats.min_frame_time, frame_time)
    self.stats.max_frame_time = math.max(self.stats.max_frame_time, frame_time)
    
    -- Calculate average frame time
    local sum = 0
    local count = 0
    for _, ft in pairs(self.frame_times) do
        sum = sum + ft
        count = count + 1
    end
    self.stats.avg_frame_time = count > 0 and (sum / count) or 0
    
    -- Sample memory
    local memory_kb = collectgarbage("count")
    self.memory_samples[self.memory_index] = memory_kb
    self.memory_index = (self.memory_index % Profiler.static.MAX_SAMPLES) + 1
    
    self.stats.memory_current = memory_kb
    self.stats.memory_peak = math.max(self.stats.memory_peak, memory_kb)
end

function Profiler:beginMarker(name)
    if not self.enabled or self.paused then
        return
    end
    
    self.active_markers[name] = love.timer.getTime()
end

function Profiler:endMarker(name)
    if not self.enabled or self.paused then
        return
    end
    
    local start_time = self.active_markers[name]
    if not start_time then
        self.logger:warn("Marker '" .. name .. "' was not started")
        return
    end
    
    local duration = (love.timer.getTime() - start_time) * 1000  -- Convert to ms
    
    -- Store marker data
    if not self.markers[name] then
        self.markers[name] = {
            name = name,
            samples = {},
            index = 1,
            total_time = 0,
            call_count = 0,
            avg_time = 0,
            min_time = math.huge,
            max_time = 0
        }
    end
    
    local marker = self.markers[name]
    marker.samples[marker.index] = duration
    marker.index = (marker.index % Profiler.static.MAX_SAMPLES) + 1
    marker.total_time = marker.total_time + duration
    marker.call_count = marker.call_count + 1
    marker.min_time = math.min(marker.min_time, duration)
    marker.max_time = math.max(marker.max_time, duration)
    
    -- Calculate average
    local sum = 0
    local count = 0
    for _, sample in pairs(marker.samples) do
        sum = sum + sample
        count = count + 1
    end
    marker.avg_time = count > 0 and (sum / count) or 0
    
    self.active_markers[name] = nil
end

function Profiler:getFrameTimes()
    return self.frame_times
end

function Profiler:getMemorySamples()
    return self.memory_samples
end

function Profiler:getMarkers()
    local sorted_markers = {}
    for _, marker in pairs(self.markers) do
        table.insert(sorted_markers, marker)
    end
    
    -- Sort by average time (descending)
    table.sort(sorted_markers, function(a, b)
        return a.avg_time > b.avg_time
    end)
    
    return sorted_markers
end

function Profiler:getStats()
    return self.stats
end

function Profiler:reset()
    self.frame_times = {}
    self.frame_index = 1
    self.memory_samples = {}
    self.memory_index = 1
    self.markers = {}
    self.active_markers = {}
    
    self.stats.min_frame_time = math.huge
    self.stats.max_frame_time = 0
    self.stats.memory_peak = 0
    
    self.logger:info("Profiler reset")
end

function Profiler:exportData(filename)
    local data = {
        stats = self.stats,
        frame_times = self.frame_times,
        memory_samples = self.memory_samples,
        markers = {}
    }
    
    for name, marker in pairs(self.markers) do
        data.markers[name] = {
            name = marker.name,
            call_count = marker.call_count,
            total_time = marker.total_time,
            avg_time = marker.avg_time,
            min_time = marker.min_time,
            max_time = marker.max_time
        }
    end
    
    -- Convert to JSON or Lua table string
    local content = "return " .. self:tableToString(data)
    
    local success, err = love.filesystem.write(filename, content)
    if success then
        self.logger:info("Profiling data exported to: " .. filename)
        return true
    else
        self.logger:error("Failed to export profiling data: " .. tostring(err))
        return false
    end
end

function Profiler:tableToString(t, indent)
    indent = indent or 0
    local spacing = string.rep("  ", indent)
    local result = "{\n"
    
    for k, v in pairs(t) do
        result = result .. spacing .. "  "
        
        if type(k) == "string" then
            result = result .. k .. " = "
        else
            result = result .. "[" .. tostring(k) .. "] = "
        end
        
        if type(v) == "table" then
            result = result .. self:tableToString(v, indent + 1)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
        
        result = result .. ",\n"
    end
    
    result = result .. spacing .. "}"
    return result
end

return Profiler
