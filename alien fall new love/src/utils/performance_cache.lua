--- PerformanceCache.lua
-- Centralized caching system for hot-path performance optimization
-- Provides LRU cache, pathfinding cache, and LOS cache
-- Designed to reduce repeated expensive calculations

local class = require('lib.middleclass')

---@class PerformanceCache
---@field private _pathCache table Cached pathfinding results
---@field private _losCache table Cached line-of-sight results
---@field private _detectionCache table Cached detection calculations
---@field private _cacheStats table Cache hit/miss statistics
---@field private _maxCacheSize number Maximum number of cached entries
local PerformanceCache = class('PerformanceCache')

-- Constants
local DEFAULT_MAX_SIZE = 1000
local PATH_CACHE_TTL = 5 -- turns
local LOS_CACHE_TTL = 3 -- turns
local DETECTION_CACHE_TTL = 1 -- days

---Initialize performance cache
---@param maxSize number Maximum cache entries (optional)
function PerformanceCache:initialize(maxSize)
    self._maxCacheSize = maxSize or DEFAULT_MAX_SIZE
    
    -- Separate caches for different data types
    self._pathCache = {
        entries = {},
        accessTimes = {},
        turnCreated = {},
        size = 0
    }
    
    self._losCache = {
        entries = {},
        accessTimes = {},
        turnCreated = {},
        size = 0
    }
    
    self._detectionCache = {
        entries = {},
        accessTimes = {},
        dayCreated = {},
        size = 0
    }
    
    -- Statistics tracking
    self._cacheStats = {
        pathHits = 0,
        pathMisses = 0,
        losHits = 0,
        losMisses = 0,
        detectionHits = 0,
        detectionMisses = 0,
        evictions = 0
    }
end

---Generate cache key from parameters
---@param ... any Variable parameters to hash
---@return string key Cache key
function PerformanceCache:_generateKey(...)
    local parts = {...}
    local keyParts = {}
    for i, part in ipairs(parts) do
        if type(part) == "table" then
            -- For tables, use a simple serialization
            table.insert(keyParts, self:_serializeTable(part))
        else
            table.insert(keyParts, tostring(part))
        end
    end
    return table.concat(keyParts, "|")
end

---Simple table serialization for caching
---@param t table Table to serialize
---@return string serialized
function PerformanceCache:_serializeTable(t)
    local parts = {}
    for k, v in pairs(t) do
        table.insert(parts, tostring(k) .. "=" .. tostring(v))
    end
    table.sort(parts) -- Consistent ordering
    return "{" .. table.concat(parts, ",") .. "}"
end

---Evict least recently used entry from cache
---@param cache table Cache structure
function PerformanceCache:_evictLRU(cache)
    if cache.size == 0 then return end
    
    local oldestKey = nil
    local oldestTime = math.huge
    
    for key, time in pairs(cache.accessTimes) do
        if time < oldestTime then
            oldestTime = time
            oldestKey = key
        end
    end
    
    if oldestKey then
        cache.entries[oldestKey] = nil
        cache.accessTimes[oldestKey] = nil
        if cache.turnCreated then cache.turnCreated[oldestKey] = nil end
        if cache.dayCreated then cache.dayCreated[oldestKey] = nil end
        cache.size = cache.size - 1
        self._cacheStats.evictions = self._cacheStats.evictions + 1
    end
end

---Store path in cache
---@param startX number Start X coordinate
---@param startY number Start Y coordinate
---@param goalX number Goal X coordinate
---@param goalY number Goal Y coordinate
---@param unitId number Unit identifier
---@param path table Calculated path
---@param currentTurn number Current game turn
function PerformanceCache:cachePath(startX, startY, goalX, goalY, unitId, path, currentTurn)
    local key = self:_generateKey("path", startX, startY, goalX, goalY, unitId)
    
    -- Evict if cache is full
    if self._pathCache.size >= self._maxCacheSize then
        self:_evictLRU(self._pathCache)
    end
    
    self._pathCache.entries[key] = path
    self._pathCache.accessTimes[key] = os.clock()
    self._pathCache.turnCreated[key] = currentTurn
    self._pathCache.size = self._pathCache.size + 1
end

---Retrieve cached path
---@param startX number Start X coordinate
---@param startY number Start Y coordinate
---@param goalX number Goal X coordinate
---@param goalY number Goal Y coordinate
---@param unitId number Unit identifier
---@param currentTurn number Current game turn
---@return table|nil path Cached path or nil
function PerformanceCache:getPath(startX, startY, goalX, goalY, unitId, currentTurn)
    local key = self:_generateKey("path", startX, startY, goalX, goalY, unitId)
    
    local path = self._pathCache.entries[key]
    if not path then
        self._cacheStats.pathMisses = self._cacheStats.pathMisses + 1
        return nil
    end
    
    -- Check if cache entry is still valid (not too old)
    local turnCreated = self._pathCache.turnCreated[key] or 0
    if currentTurn - turnCreated > PATH_CACHE_TTL then
        -- Cache entry too old, invalidate it
        self._pathCache.entries[key] = nil
        self._pathCache.accessTimes[key] = nil
        self._pathCache.turnCreated[key] = nil
        self._pathCache.size = self._pathCache.size - 1
        self._cacheStats.pathMisses = self._cacheStats.pathMisses + 1
        return nil
    end
    
    -- Update access time
    self._pathCache.accessTimes[key] = os.clock()
    self._cacheStats.pathHits = self._cacheStats.pathHits + 1
    
    return path
end

---Store LOS visibility in cache
---@param unitId number Unit identifier
---@param unitX number Unit X coordinate
---@param unitY number Unit Y coordinate
---@param isNight boolean Night flag
---@param visibleTiles table Calculated visible tiles
---@param currentTurn number Current game turn
function PerformanceCache:cacheLOS(unitId, unitX, unitY, isNight, visibleTiles, currentTurn)
    local key = self:_generateKey("los", unitId, unitX, unitY, isNight)
    
    -- Evict if cache is full
    if self._losCache.size >= self._maxCacheSize then
        self:_evictLRU(self._losCache)
    end
    
    self._losCache.entries[key] = visibleTiles
    self._losCache.accessTimes[key] = os.clock()
    self._losCache.turnCreated[key] = currentTurn
    self._losCache.size = self._losCache.size + 1
end

---Retrieve cached LOS visibility
---@param unitId number Unit identifier
---@param unitX number Unit X coordinate
---@param unitY number Unit Y coordinate
---@param isNight boolean Night flag
---@param currentTurn number Current game turn
---@return table|nil visibleTiles Cached visibility or nil
function PerformanceCache:getLOS(unitId, unitX, unitY, isNight, currentTurn)
    local key = self:_generateKey("los", unitId, unitX, unitY, isNight)
    
    local visibleTiles = self._losCache.entries[key]
    if not visibleTiles then
        self._cacheStats.losMisses = self._cacheStats.losMisses + 1
        return nil
    end
    
    -- Check if cache entry is still valid
    local turnCreated = self._losCache.turnCreated[key] or 0
    if currentTurn - turnCreated > LOS_CACHE_TTL then
        -- Cache entry too old, invalidate it
        self._losCache.entries[key] = nil
        self._losCache.accessTimes[key] = nil
        self._losCache.turnCreated[key] = nil
        self._losCache.size = self._losCache.size - 1
        self._cacheStats.losMisses = self._cacheStats.losMisses + 1
        return nil
    end
    
    -- Update access time
    self._losCache.accessTimes[key] = os.clock()
    self._cacheStats.losHits = self._cacheStats.losHits + 1
    
    return visibleTiles
end

---Store detection calculation in cache
---@param missionId number Mission identifier
---@param radarId number Radar facility identifier
---@param detectionPower number Calculated detection power
---@param currentDay number Current game day
function PerformanceCache:cacheDetection(missionId, radarId, detectionPower, currentDay)
    local key = self:_generateKey("detection", missionId, radarId)
    
    -- Evict if cache is full
    if self._detectionCache.size >= self._maxCacheSize then
        self:_evictLRU(self._detectionCache)
    end
    
    self._detectionCache.entries[key] = detectionPower
    self._detectionCache.accessTimes[key] = os.clock()
    self._detectionCache.dayCreated[key] = currentDay
    self._detectionCache.size = self._detectionCache.size + 1
end

---Retrieve cached detection calculation
---@param missionId number Mission identifier
---@param radarId number Radar facility identifier
---@param currentDay number Current game day
---@return number|nil detectionPower Cached detection power or nil
function PerformanceCache:getDetection(missionId, radarId, currentDay)
    local key = self:_generateKey("detection", missionId, radarId)
    
    local detectionPower = self._detectionCache.entries[key]
    if not detectionPower then
        self._cacheStats.detectionMisses = self._cacheStats.detectionMisses + 1
        return nil
    end
    
    -- Check if cache entry is still valid
    local dayCreated = self._detectionCache.dayCreated[key] or 0
    if currentDay - dayCreated > DETECTION_CACHE_TTL then
        -- Cache entry too old, invalidate it
        self._detectionCache.entries[key] = nil
        self._detectionCache.accessTimes[key] = nil
        self._detectionCache.dayCreated[key] = nil
        self._detectionCache.size = self._detectionCache.size - 1
        self._cacheStats.detectionMisses = self._cacheStats.detectionMisses + 1
        return nil
    end
    
    -- Update access time
    self._detectionCache.accessTimes[key] = os.clock()
    self._cacheStats.detectionHits = self._cacheStats.detectionHits + 1
    
    return detectionPower
end

---Invalidate all path caches
function PerformanceCache:invalidatePathCache()
    self._pathCache.entries = {}
    self._pathCache.accessTimes = {}
    self._pathCache.turnCreated = {}
    self._pathCache.size = 0
end

---Invalidate all LOS caches
function PerformanceCache:invalidateLOSCache()
    self._losCache.entries = {}
    self._losCache.accessTimes = {}
    self._losCache.turnCreated = {}
    self._losCache.size = 0
end

---Invalidate all detection caches
function PerformanceCache:invalidateDetectionCache()
    self._detectionCache.entries = {}
    self._detectionCache.accessTimes = {}
    self._detectionCache.dayCreated = {}
    self._detectionCache.size = 0
end

---Clear all caches
function PerformanceCache:clearAll()
    self:invalidatePathCache()
    self:invalidateLOSCache()
    self:invalidateDetectionCache()
    
    -- Reset statistics
    self._cacheStats = {
        pathHits = 0,
        pathMisses = 0,
        losHits = 0,
        losMisses = 0,
        detectionHits = 0,
        detectionMisses = 0,
        evictions = 0
    }
end

---Get cache statistics
---@return table stats Cache performance statistics
function PerformanceCache:getStatistics()
    local stats = {
        path = {
            hits = self._cacheStats.pathHits,
            misses = self._cacheStats.pathMisses,
            hitRate = 0,
            size = self._pathCache.size
        },
        los = {
            hits = self._cacheStats.losHits,
            misses = self._cacheStats.losMisses,
            hitRate = 0,
            size = self._losCache.size
        },
        detection = {
            hits = self._cacheStats.detectionHits,
            misses = self._cacheStats.detectionMisses,
            hitRate = 0,
            size = self._detectionCache.size
        },
        evictions = self._cacheStats.evictions,
        totalSize = self._pathCache.size + self._losCache.size + self._detectionCache.size
    }
    
    -- Calculate hit rates
    if stats.path.hits + stats.path.misses > 0 then
        stats.path.hitRate = stats.path.hits / (stats.path.hits + stats.path.misses)
    end
    if stats.los.hits + stats.los.misses > 0 then
        stats.los.hitRate = stats.los.hits / (stats.los.hits + stats.los.misses)
    end
    if stats.detection.hits + stats.detection.misses > 0 then
        stats.detection.hitRate = stats.detection.hits / (stats.detection.hits + stats.detection.misses)
    end
    
    return stats
end

---Print cache statistics to console
function PerformanceCache:printStatistics()
    local stats = self:getStatistics()
    
    print("=== Performance Cache Statistics ===")
    print(string.format("Path Cache: %d entries, %.1f%% hit rate (%d hits, %d misses)",
        stats.path.size, stats.path.hitRate * 100, stats.path.hits, stats.path.misses))
    print(string.format("LOS Cache: %d entries, %.1f%% hit rate (%d hits, %d misses)",
        stats.los.size, stats.los.hitRate * 100, stats.los.hits, stats.los.misses))
    print(string.format("Detection Cache: %d entries, %.1f%% hit rate (%d hits, %d misses)",
        stats.detection.size, stats.detection.hitRate * 100, stats.detection.hits, stats.detection.misses))
    print(string.format("Total: %d/%d entries, %d evictions",
        stats.totalSize, self._maxCacheSize, stats.evictions))
    print("====================================")
end

return PerformanceCache
