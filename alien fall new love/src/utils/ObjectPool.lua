--- ObjectPool - Generic object pooling system
--
-- Provides efficient object reuse for frequently created/destroyed objects
-- like projectiles, particles, and UI elements. Reduces garbage collection
-- pressure and improves performance.
--
-- @module utils.ObjectPool

local class = require("lib.middleclass")

local ObjectPool = class('ObjectPool')

-- Constants
local DEFAULT_INITIAL_SIZE = 10
local DEFAULT_MAX_SIZE = 100
local DEFAULT_GROWTH_FACTOR = 1.5

--- Initialize the object pool
--- @param opts table Configuration options
--- @param opts.factory function Function that creates new objects: function() return obj end
--- @param opts.reset function Function to reset object state: function(obj) ... end
--- @param opts.validate function Optional validation function: function(obj) return boolean end
--- @param opts.initialSize number Initial pool size (default: 10)
--- @param opts.maxSize number Maximum pool size (default: 100)
--- @param opts.growthFactor number Growth factor when expanding (default: 1.5)
--- @param opts.autoExpand boolean Auto-expand when pool is exhausted (default: true)
function ObjectPool:initialize(opts)
    opts = opts or {}
    
    -- Validate required parameters
    assert(type(opts.factory) == "function", "factory function is required")
    assert(type(opts.reset) == "function", "reset function is required")
    
    self.factory = opts.factory
    self.reset = opts.reset
    self.validate = opts.validate or function() return true end
    
    self.initialSize = opts.initialSize or DEFAULT_INITIAL_SIZE
    self.maxSize = opts.maxSize or DEFAULT_MAX_SIZE
    self.growthFactor = opts.growthFactor or DEFAULT_GROWTH_FACTOR
    self.autoExpand = opts.autoExpand ~= false
    
    -- Pool storage
    self.available = {}  -- Available objects
    self.inUse = {}      -- Objects currently in use
    
    -- Statistics
    self.stats = {
        created = 0,
        acquired = 0,
        released = 0,
        expanded = 0,
        peakUsage = 0,
        currentSize = 0
    }
    
    -- Pre-populate pool
    self:expand(self.initialSize)
end

--- Create a new object using the factory
--- @return any object The newly created object
function ObjectPool:createObject()
    local obj = self.factory()
    self.stats.created = self.stats.created + 1
    return obj
end

--- Expand the pool by a number of objects
--- @param count number Number of objects to create
--- @return number created Number of objects actually created
function ObjectPool:expand(count)
    local created = 0
    
    for i = 1, count do
        if self.stats.currentSize >= self.maxSize then
            break
        end
        
        local obj = self:createObject()
        table.insert(self.available, obj)
        self.stats.currentSize = self.stats.currentSize + 1
        created = created + 1
    end
    
    if created > 0 then
        self.stats.expanded = self.stats.expanded + 1
    end
    
    return created
end

--- Acquire an object from the pool
--- @return any|nil object An available object, or nil if pool is exhausted
function ObjectPool:acquire()
    local obj = nil
    
    -- Try to get from available pool
    if #self.available > 0 then
        obj = table.remove(self.available)
    elseif self.autoExpand and self.stats.currentSize < self.maxSize then
        -- Auto-expand if enabled and not at max size
        local growthSize = math.max(1, math.floor(self.stats.currentSize * (self.growthFactor - 1)))
        growthSize = math.min(growthSize, self.maxSize - self.stats.currentSize)
        
        if growthSize > 0 then
            self:expand(growthSize)
            obj = table.remove(self.available)
        end
    end
    
    if obj then
        -- Validate before use
        if not self.validate(obj) then
            -- Object failed validation, create a new one
            obj = self:createObject()
            self.stats.currentSize = self.stats.currentSize + 1
        end
        
        self.inUse[obj] = true
        self.stats.acquired = self.stats.acquired + 1
        
        -- Track peak usage
        local currentUsage = self:getUsageCount()
        if currentUsage > self.stats.peakUsage then
            self.stats.peakUsage = currentUsage
        end
    end
    
    return obj
end

--- Release an object back to the pool
--- @param obj any The object to release
--- @return boolean success True if object was released successfully
function ObjectPool:release(obj)
    if not obj then
        return false
    end
    
    -- Check if object is actually in use
    if not self.inUse[obj] then
        return false
    end
    
    -- Reset object state
    self.reset(obj)
    
    -- Validate after reset
    if not self.validate(obj) then
        -- Object failed validation after reset, discard it
        self.inUse[obj] = nil
        self.stats.currentSize = self.stats.currentSize - 1
        return false
    end
    
    -- Return to available pool
    self.inUse[obj] = nil
    table.insert(self.available, obj)
    self.stats.released = self.stats.released + 1
    
    return true
end

--- Release multiple objects at once
--- @param objects table Array of objects to release
--- @return number released Number of objects successfully released
function ObjectPool:releaseAll(objects)
    local released = 0
    
    for _, obj in ipairs(objects) do
        if self:release(obj) then
            released = released + 1
        end
    end
    
    return released
end

--- Clear all objects from the pool
function ObjectPool:clear()
    self.available = {}
    self.inUse = {}
    self.stats.currentSize = 0
end

--- Get the number of available objects
--- @return number count Number of available objects
function ObjectPool:getAvailableCount()
    return #self.available
end

--- Get the number of objects currently in use
--- @return number count Number of in-use objects
function ObjectPool:getUsageCount()
    local count = 0
    for _ in pairs(self.inUse) do
        count = count + 1
    end
    return count
end

--- Get pool statistics
--- @return table stats Statistics about pool usage
function ObjectPool:getStats()
    return {
        totalSize = self.stats.currentSize,
        available = self:getAvailableCount(),
        inUse = self:getUsageCount(),
        created = self.stats.created,
        acquired = self.stats.acquired,
        released = self.stats.released,
        expanded = self.stats.expanded,
        peakUsage = self.stats.peakUsage,
        utilization = self:getUsageCount() / math.max(1, self.stats.currentSize)
    }
end

--- Check if an object is currently in use
--- @param obj any The object to check
--- @return boolean inUse True if object is in use
function ObjectPool:isInUse(obj)
    return self.inUse[obj] == true
end

--- Shrink pool to target size (removes unused objects)
--- @param targetSize number Target pool size
--- @return number removed Number of objects removed
function ObjectPool:shrink(targetSize)
    local removed = 0
    
    while #self.available > 0 and self.stats.currentSize > targetSize do
        table.remove(self.available)
        self.stats.currentSize = self.stats.currentSize - 1
        removed = removed + 1
    end
    
    return removed
end

--- Reset pool statistics
function ObjectPool:resetStats()
    self.stats.acquired = 0
    self.stats.released = 0
    self.stats.expanded = 0
    self.stats.peakUsage = self:getUsageCount()
end

return ObjectPool
