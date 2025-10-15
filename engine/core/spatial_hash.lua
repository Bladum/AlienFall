---Spatial Hash Grid System
---
---Optimizes collision detection and proximity queries from O(n²) to O(n) using
---a grid-based spatial partitioning algorithm. Divides the map into cells and
---tracks which items are in each cell for fast neighbor lookups.
---
---Use Cases:
---  - Unit spawning (find empty tiles nearby)
---  - Collision detection (check only nearby objects)
---  - Pathfinding (find walkable neighbors)
---  - Area queries (get all units in radius)
---
---Key Exports:
---  - SpatialHash.new(width, height, cellSize): Creates spatial grid
---  - insert(item, x, y): Adds item to grid at position
---  - remove(item, x, y): Removes item from grid
---  - query(x, y, radius): Gets all items within radius
---  - clear(): Empties entire grid
---
---Dependencies:
---  - None (pure Lua implementation)
---
---@module core.spatial_hash
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local SpatialHash = require("core.spatial_hash")
---  local grid = SpatialHash.new(100, 100, 10)  -- 100x100 map, 10 tile cells
---  grid:insert(unit, unit.x, unit.y)
---  local nearby = grid:query(player.x, player.y, 5)  -- 5 tile radius
---
---@see battlescape.maps.grid_map For battlefield grid implementation
---@see ai.pathfinding For pathfinding system

local SpatialHash = {}
SpatialHash.__index = SpatialHash

-- Create new spatial hash grid
-- cellSize: size of each grid cell (larger = fewer cells, more items per cell)
function SpatialHash.new(width, height, cellSize)
    local self = setmetatable({}, SpatialHash)
    
    self.width = width
    self.height = height
    self.cellSize = cellSize or 10  -- Default 10x10 tiles per cell
    
    -- Calculate grid dimensions
    self.gridWidth = math.ceil(width / self.cellSize)
    self.gridHeight = math.ceil(height / self.cellSize)
    
    -- Hash table: key = cell coordinate, value = list of items
    self.cells = {}
    
    -- Track all items for debugging
    self.itemCount = 0
    
    print(string.format("[SpatialHash] Created %dx%d grid (cell size: %d, %dx%d cells)", 
        width, height, self.cellSize, self.gridWidth, self.gridHeight))
    
    return self
end

-- Convert world coordinates to cell coordinates
function SpatialHash:worldToCell(x, y)
    return math.floor((x - 1) / self.cellSize), math.floor((y - 1) / self.cellSize)
end

-- Get cell key from cell coordinates
function SpatialHash:getCellKey(cellX, cellY)
    -- Use numeric key for performance
    return cellY * self.gridWidth + cellX
end

-- Insert item at position
function SpatialHash:insert(x, y, item)
    local cellX, cellY = self:worldToCell(x, y)
    local key = self:getCellKey(cellX, cellY)
    
    if not self.cells[key] then
        self.cells[key] = {}
    end
    
    table.insert(self.cells[key], {x = x, y = y, item = item})
    self.itemCount = self.itemCount + 1
end

-- Remove item at position
function SpatialHash:remove(x, y, item)
    local cellX, cellY = self:worldToCell(x, y)
    local key = self:getCellKey(cellX, cellY)
    
    local cell = self.cells[key]
    if not cell then return false end
    
    for i = #cell, 1, -1 do
        if cell[i].x == x and cell[i].y == y and cell[i].item == item then
            table.remove(cell, i)
            self.itemCount = self.itemCount - 1
            
            -- Remove empty cells
            if #cell == 0 then
                self.cells[key] = nil
            end
            
            return true
        end
    end
    
    return false
end

-- Query items at exact position
function SpatialHash:queryExact(x, y)
    local cellX, cellY = self:worldToCell(x, y)
    local key = self:getCellKey(cellX, cellY)
    
    local cell = self.cells[key]
    if not cell then return {} end
    
    local results = {}
    for _, entry in ipairs(cell) do
        if entry.x == x and entry.y == y then
            table.insert(results, entry.item)
        end
    end
    
    return results
end

-- Query items in radius (returns all items in cells that overlap the radius)
function SpatialHash:queryRadius(centerX, centerY, radius)
    local results = {}
    
    -- Calculate bounding box
    local minX = math.max(1, centerX - radius)
    local maxX = math.min(self.width, centerX + radius)
    local minY = math.max(1, centerY - radius)
    local maxY = math.min(self.height, centerY + radius)
    
    -- Get cell range
    local minCellX, minCellY = self:worldToCell(minX, minY)
    local maxCellX, maxCellY = self:worldToCell(maxX, maxY)
    
    -- Query all cells in range
    for cellY = minCellY, maxCellY do
        for cellX = minCellX, maxCellX do
            local key = self:getCellKey(cellX, cellY)
            local cell = self.cells[key]
            
            if cell then
                for _, entry in ipairs(cell) do
                    -- Check if within actual radius
                    local dx = entry.x - centerX
                    local dy = entry.y - centerY
                    local distSq = dx * dx + dy * dy
                    
                    if distSq <= radius * radius then
                        table.insert(results, entry)
                    end
                end
            end
        end
    end
    
    return results
end

-- Query items in rectangular area
function SpatialHash:queryRect(minX, minY, maxX, maxY)
    local results = {}
    
    -- Clamp to grid bounds
    minX = math.max(1, minX)
    minY = math.max(1, minY)
    maxX = math.min(self.width, maxX)
    maxY = math.min(self.height, maxY)
    
    -- Get cell range
    local minCellX, minCellY = self:worldToCell(minX, minY)
    local maxCellX, maxCellY = self:worldToCell(maxX, maxY)
    
    -- Query all cells in range
    for cellY = minCellY, maxCellY do
        for cellX = minCellX, maxCellX do
            local key = self:getCellKey(cellX, cellY)
            local cell = self.cells[key]
            
            if cell then
                for _, entry in ipairs(cell) do
                    -- Check if within rectangle
                    if entry.x >= minX and entry.x <= maxX and 
                       entry.y >= minY and entry.y <= maxY then
                        table.insert(results, entry)
                    end
                end
            end
        end
    end
    
    return results
end

-- Check if position is occupied
function SpatialHash:isOccupied(x, y)
    local items = self:queryExact(x, y)
    return #items > 0
end

-- Clear all items
function SpatialHash:clear()
    self.cells = {}
    self.itemCount = 0
end

-- Get statistics
function SpatialHash:getStats()
    local cellCount = 0
    local maxItemsPerCell = 0
    local totalItems = 0
    
    for _, cell in pairs(self.cells) do
        cellCount = cellCount + 1
        local itemCount = #cell
        totalItems = totalItems + itemCount
        maxItemsPerCell = math.max(maxItemsPerCell, itemCount)
    end
    
    local avgItemsPerCell = cellCount > 0 and (totalItems / cellCount) or 0
    
    return {
        totalCells = self.gridWidth * self.gridHeight,
        occupiedCells = cellCount,
        totalItems = totalItems,
        maxItemsPerCell = maxItemsPerCell,
        avgItemsPerCell = avgItemsPerCell,
        loadFactor = cellCount / (self.gridWidth * self.gridHeight)
    }
end

-- Debug: print grid contents
function SpatialHash:debugPrint()
    print("[SpatialHash] Debug Info:")
    print(string.format("  Grid: %dx%d cells (%dx%d world)", 
        self.gridWidth, self.gridHeight, self.width, self.height))
    print(string.format("  Items: %d", self.itemCount))
    
    local stats = self:getStats()
    print(string.format("  Occupied cells: %d/%d (%.1f%%)", 
        stats.occupiedCells, stats.totalCells, stats.loadFactor * 100))
    print(string.format("  Items per cell: avg=%.2f, max=%d", 
        stats.avgItemsPerCell, stats.maxItemsPerCell))
end

return SpatialHash






















