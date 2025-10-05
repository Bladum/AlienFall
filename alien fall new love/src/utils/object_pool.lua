--- ObjectPool - Generic object pooling system for performance optimization
--
-- Reduces garbage collection overhead by reusing objects instead of creating new ones.
-- Supports any object type with initialize/reset pattern.
--
-- @module utils.object_pool

local class = require('lib.middleclass')

local ObjectPool = class('ObjectPool')

--- Creates a new ObjectPool instance.
-- @param factory function Factory function to create new objects: function() return object end
-- @param reset_fn function Optional reset function to clean objects: function(obj) end
-- @param initial_size number Initial number of objects to pre-allocate (default: 10)
-- @param max_size number Maximum pool size, 0 for unlimited (default: 0)
function ObjectPool:initialize(factory, reset_fn, initial_size, max_size)
    assert(type(factory) == "function", "factory must be a function")
    
    self.factory = factory
    self.reset_fn = reset_fn or function(obj) 
        -- Default reset: call reset() method if it exists
        if obj.reset then
            obj:reset()
        end
    end
    
    self.initial_size = initial_size or 10
    self.max_size = max_size or 0  -- 0 = unlimited
    
    -- Pool storage
    self.available = {}  -- Available objects
    self.in_use = {}     -- Objects currently in use
    
    -- Statistics
    self.stats = {
        created = 0,
        reused = 0,
        released = 0,
        peak_usage = 0,
        current_usage = 0
    }
    
    -- Pre-allocate initial objects
    for i = 1, self.initial_size do
        local obj = self.factory()
        table.insert(self.available, obj)
        self.stats.created = self.stats.created + 1
    end
end

--- Acquires an object from the pool.
-- @return any Object from pool (reused or newly created)
function ObjectPool:acquire()
    local obj
    
    if #self.available > 0 then
        -- Reuse existing object
        obj = table.remove(self.available)
        self.stats.reused = self.stats.reused + 1
    else
        -- Create new object if pool is empty
        obj = self.factory()
        self.stats.created = self.stats.created + 1
    end
    
    -- Track object as in use
    table.insert(self.in_use, obj)
    self.stats.current_usage = #self.in_use
    
    if self.stats.current_usage > self.stats.peak_usage then
        self.stats.peak_usage = self.stats.current_usage
    end
    
    return obj
end

--- Releases an object back to the pool.
-- @param obj any Object to return to pool
-- @return boolean Whether object was successfully released
function ObjectPool:release(obj)
    assert(obj ~= nil, "Cannot release nil object")
    
    -- Find and remove from in_use
    for i, used_obj in ipairs(self.in_use) do
        if used_obj == obj then
            table.remove(self.in_use, i)
            
            -- Reset object state
            self.reset_fn(obj)
            
            -- Check max pool size
            if self.max_size == 0 or #self.available < self.max_size then
                table.insert(self.available, obj)
                self.stats.released = self.stats.released + 1
            else
                -- Pool full, discard object (will be garbage collected)
                -- This prevents unbounded memory growth
            end
            
            self.stats.current_usage = #self.in_use
            return true
        end
    end
    
    -- Object not found in in_use list
    return false
end

--- Releases all in-use objects back to the pool.
-- Useful for cleanup between scenes or levels.
function ObjectPool:releaseAll()
    while #self.in_use > 0 do
        local obj = table.remove(self.in_use)
        self.reset_fn(obj)
        
        if self.max_size == 0 or #self.available < self.max_size then
            table.insert(self.available, obj)
        end
    end
    
    self.stats.current_usage = 0
end

--- Clears the entire pool, discarding all objects.
function ObjectPool:clear()
    self.available = {}
    self.in_use = {}
    self.stats.current_usage = 0
end

--- Gets current pool statistics.
-- @return table Statistics {created, reused, released, peak_usage, current_usage, available, reuse_rate}
function ObjectPool:getStats()
    local total_acquires = self.stats.created + self.stats.reused
    local reuse_rate = total_acquires > 0 and (self.stats.reused / total_acquires * 100) or 0
    
    return {
        created = self.stats.created,
        reused = self.stats.reused,
        released = self.stats.released,
        peak_usage = self.stats.peak_usage,
        current_usage = self.stats.current_usage,
        available = #self.available,
        reuse_rate = reuse_rate
    }
end

--- Pre-warms the pool by creating objects up to specified size.
-- @param count number Number of objects to pre-allocate
function ObjectPool:prewarm(count)
    for i = 1, count do
        local obj = self.factory()
        table.insert(self.available, obj)
        self.stats.created = self.stats.created + 1
    end
end

return ObjectPool
