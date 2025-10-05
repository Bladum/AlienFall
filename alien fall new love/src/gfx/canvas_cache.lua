--- Canvas UI Cache Module
--- Provides canvas-based caching for static UI elements to improve rendering performance.
--- Static UI elements are rendered once to a canvas and then drawn from cache each frame.
---
--- @module gfx.canvas_cache
--- @author AlienFall Development Team
--- @copyright 2025

local validate = require('utils.validate')

local CanvasCache = {}

--- Canvas cache entry structure
--- @class CacheEntry
--- @field canvas love.Canvas The cached canvas
--- @field width number Canvas width
--- @field height number Canvas height
--- @field dirty boolean True if cache needs refresh
--- @field last_used number Frame number of last use

--- Initialize canvas cache system
function CanvasCache.new()
    local self = {
        -- Cache storage: key -> CacheEntry
        cache = {},
        
        -- Frame counter for LRU eviction
        frame_counter = 0,
        
        -- Maximum cache entries before eviction
        max_entries = 50,
        
        -- Statistics
        stats = {
            hits = 0,
            misses = 0,
            invalidations = 0,
            evictions = 0
        }
    }
    
    return setmetatable(self, {__index = CanvasCache})
end

--- Get or create a canvas cache entry
--- Returns nil if canvas creation fails
---
--- @param key string Unique cache key
--- @param width number Canvas width
--- @param height number Canvas height
--- @return love.Canvas|nil The canvas, or nil if creation failed
function CanvasCache:get(key, width, height)
    validate.require_non_empty_string(key, "key")
    validate.require_positive(width, "width")
    validate.require_positive(height, "height")
    
    local entry = self.cache[key]
    
    -- Cache hit - return existing canvas if dimensions match
    if entry then
        if entry.width == width and entry.height == height then
            entry.last_used = self.frame_counter
            self.stats.hits = self.stats.hits + 1
            return entry.canvas
        else
            -- Dimensions changed, invalidate entry
            self:invalidate(key)
        end
    end
    
    -- Cache miss - create new canvas
    self.stats.misses = self.stats.misses + 1
    
    -- Evict old entries if cache is full
    if self:getSize() >= self.max_entries then
        self:evictLRU()
    end
    
    -- Create new canvas
    local ok, canvas = pcall(love.graphics.newCanvas, width, height)
    if not ok then
        print("Warning: Failed to create canvas for key '" .. key .. "': " .. tostring(canvas))
        return nil
    end
    
    -- Store in cache
    self.cache[key] = {
        canvas = canvas,
        width = width,
        height = height,
        dirty = true,
        last_used = self.frame_counter
    }
    
    return canvas
end

--- Check if a canvas is dirty (needs redraw)
---
--- @param key string Cache key
--- @return boolean True if dirty or missing
function CanvasCache:isDirty(key)
    local entry = self.cache[key]
    if not entry then
        return true  -- Missing entries are "dirty"
    end
    return entry.dirty
end

--- Mark a canvas as dirty (needs redraw)
---
--- @param key string Cache key
function CanvasCache:invalidate(key)
    local entry = self.cache[key]
    if entry then
        entry.dirty = true
        self.stats.invalidations = self.stats.invalidations + 1
    end
end

--- Mark a canvas as clean (up to date)
---
--- @param key string Cache key
function CanvasCache:markClean(key)
    local entry = self.cache[key]
    if entry then
        entry.dirty = false
    end
end

--- Remove a canvas from cache
---
--- @param key string Cache key
function CanvasCache:remove(key)
    local entry = self.cache[key]
    if entry then
        if entry.canvas then
            entry.canvas:release()
        end
        self.cache[key] = nil
    end
end

--- Clear all cached canvases
function CanvasCache:clear()
    for key, entry in pairs(self.cache) do
        if entry.canvas then
            entry.canvas:release()
        end
    end
    self.cache = {}
end

--- Evict least recently used canvas
function CanvasCache:evictLRU()
    local oldest_key = nil
    local oldest_frame = math.huge
    
    for key, entry in pairs(self.cache) do
        if entry.last_used < oldest_frame then
            oldest_frame = entry.last_used
            oldest_key = key
        end
    end
    
    if oldest_key then
        self:remove(oldest_key)
        self.stats.evictions = self.stats.evictions + 1
    end
end

--- Get number of cached canvases
---
--- @return number Cache size
function CanvasCache:getSize()
    local count = 0
    for _ in pairs(self.cache) do
        count = count + 1
    end
    return count
end

--- Update frame counter
--- Call this once per frame for proper LRU tracking
function CanvasCache:update()
    self.frame_counter = self.frame_counter + 1
end

--- Get cache statistics
---
--- @return table Statistics (hits, misses, invalidations, evictions)
function CanvasCache:getStats()
    local total = self.stats.hits + self.stats.misses
    local hit_rate = total > 0 and (self.stats.hits / total * 100) or 0
    
    return {
        hits = self.stats.hits,
        misses = self.stats.misses,
        invalidations = self.stats.invalidations,
        evictions = self.stats.evictions,
        size = self:getSize(),
        hit_rate = hit_rate
    }
end

--- Render content to a cached canvas
--- Automatically handles canvas switching and marking as clean
---
--- @param key string Cache key
--- @param width number Canvas width
--- @param height number Canvas height
--- @param draw_func function Function that draws the content
--- @return boolean True if render was successful
function CanvasCache:render(key, width, height, draw_func)
    validate.require_callable(draw_func, "draw_func")
    
    local canvas = self:get(key, width, height)
    if not canvas then
        return false  -- Canvas creation failed
    end
    
    -- Only redraw if dirty
    if not self:isDirty(key) then
        return true  -- Already up to date
    end
    
    -- Render to canvas
    local previous_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    -- Call user draw function
    local ok, err = pcall(draw_func)
    if not ok then
        print("Warning: Canvas render failed for key '" .. key .. "': " .. tostring(err))
        love.graphics.setCanvas(previous_canvas)
        return false
    end
    
    love.graphics.setCanvas(previous_canvas)
    
    -- Mark as clean
    self:markClean(key)
    
    return true
end

--- Draw a cached canvas
--- Returns false if canvas doesn't exist
---
--- @param key string Cache key
--- @param x number X position to draw at (default: 0)
--- @param y number Y position to draw at (default: 0)
--- @return boolean True if canvas was drawn
function CanvasCache:draw(key, x, y)
    x = x or 0
    y = y or 0
    
    local entry = self.cache[key]
    if not entry then
        return false  -- Canvas not cached
    end
    
    entry.last_used = self.frame_counter
    love.graphics.draw(entry.canvas, x, y)
    return true
end

--- Helper: Render and draw a cached canvas in one call
--- If canvas is dirty, renders it. Then draws it.
---
--- @param key string Cache key
--- @param width number Canvas width
--- @param height number Canvas height
--- @param x number X position to draw at (default: 0)
--- @param y number Y position to draw at (default: 0)
--- @param draw_func function Function that draws the content (only called if dirty)
--- @return boolean True if successful
function CanvasCache:renderAndDraw(key, width, height, x, y, draw_func)
    -- Render if dirty
    if self:isDirty(key) then
        if not self:render(key, width, height, draw_func) then
            return false
        end
    end
    
    -- Draw canvas
    return self:draw(key, x, y)
end

return CanvasCache
