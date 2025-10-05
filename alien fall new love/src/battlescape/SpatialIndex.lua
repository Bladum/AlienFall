--- SpatialIndex - Spatial partitioning for efficient entity queries
-- Uses grid-based spatial hashing for O(1) average-case lookups
-- @module SpatialIndex

local class = require('lib.middleclass')
local SpatialIndex = class('SpatialIndex')

--- Initialize the spatial index
-- @param cell_size Number of tiles per cell (default: 8)
function SpatialIndex:initialize(cell_size)
    self.cell_size = cell_size or 8
    
    -- Grid cells: cells[x][y] = {entity1, entity2, ...}
    self.cells = {}
    
    -- Entity to cell mapping: entity_cells[entity_id] = {cell_keys...}
    self.entity_cells = {}
    
    -- Statistics
    self.stats = {
        total_entities = 0,
        total_cells = 0,
        queries_performed = 0,
        entities_checked = 0
    }
end

--- Get cell key from world coordinates
-- @param x X coordinate
-- @param y Y coordinate
-- @return Cell key string
function SpatialIndex:_getCellKey(x, y)
    local cx = math.floor(x / self.cell_size)
    local cy = math.floor(y / self.cell_size)
    return string.format("%d,%d", cx, cy)
end

--- Get all cell keys that overlap with a bounding box
-- @param min_x Minimum X
-- @param min_y Minimum Y
-- @param max_x Maximum X
-- @param max_y Maximum Y
-- @return Array of cell keys
function SpatialIndex:_getCellKeys(min_x, min_y, max_x, max_y)
    local keys = {}
    
    local start_cx = math.floor(min_x / self.cell_size)
    local start_cy = math.floor(min_y / self.cell_size)
    local end_cx = math.floor(max_x / self.cell_size)
    local end_cy = math.floor(max_y / self.cell_size)
    
    for cx = start_cx, end_cx do
        for cy = start_cy, end_cy do
            table.insert(keys, string.format("%d,%d", cx, cy))
        end
    end
    
    return keys
end

--- Insert an entity into the spatial index
-- @param entity_id Entity identifier
-- @param x X position
-- @param y Y position
-- @param width Optional width (default: 1)
-- @param height Optional height (default: 1)
function SpatialIndex:insert(entity_id, x, y, width, height)
    width = width or 1
    height = height or 1
    
    -- Remove if already exists
    if self.entity_cells[entity_id] then
        self:remove(entity_id)
    end
    
    -- Get cells for entity bounds
    local cell_keys = self:_getCellKeys(x, y, x + width - 1, y + height - 1)
    
    -- Insert into cells
    for _, key in ipairs(cell_keys) do
        if not self.cells[key] then
            self.cells[key] = {}
            self.stats.total_cells = self.stats.total_cells + 1
        end
        
        table.insert(self.cells[key], entity_id)
    end
    
    -- Store entity to cell mapping
    self.entity_cells[entity_id] = cell_keys
    self.stats.total_entities = self.stats.total_entities + 1
end

--- Remove an entity from the spatial index
-- @param entity_id Entity identifier
function SpatialIndex:remove(entity_id)
    local cell_keys = self.entity_cells[entity_id]
    if not cell_keys then
        return
    end
    
    -- Remove from all cells
    for _, key in ipairs(cell_keys) do
        local cell = self.cells[key]
        if cell then
            for i = #cell, 1, -1 do
                if cell[i] == entity_id then
                    table.remove(cell, i)
                end
            end
            
            -- Remove empty cells
            if #cell == 0 then
                self.cells[key] = nil
                self.stats.total_cells = self.stats.total_cells - 1
            end
        end
    end
    
    -- Remove entity mapping
    self.entity_cells[entity_id] = nil
    self.stats.total_entities = self.stats.total_entities - 1
end

--- Update an entity's position
-- @param entity_id Entity identifier
-- @param x New X position
-- @param y New Y position
-- @param width Optional width
-- @param height Optional height
function SpatialIndex:update(entity_id, x, y, width, height)
    self:insert(entity_id, x, y, width, height)
end

--- Query entities in a rectangular area
-- @param min_x Minimum X
-- @param min_y Minimum Y
-- @param max_x Maximum X
-- @param max_y Maximum Y
-- @return Array of entity IDs (may contain duplicates)
function SpatialIndex:queryRect(min_x, min_y, max_x, max_y)
    local cell_keys = self:_getCellKeys(min_x, min_y, max_x, max_y)
    local results = {}
    local seen = {}
    
    self.stats.queries_performed = self.stats.queries_performed + 1
    
    for _, key in ipairs(cell_keys) do
        local cell = self.cells[key]
        if cell then
            for _, entity_id in ipairs(cell) do
                if not seen[entity_id] then
                    table.insert(results, entity_id)
                    seen[entity_id] = true
                    self.stats.entities_checked = self.stats.entities_checked + 1
                end
            end
        end
    end
    
    return results
end

--- Query entities within a radius of a point
-- @param center_x Center X
-- @param center_y Center Y
-- @param radius Radius
-- @return Array of entity IDs (filtered by actual distance)
function SpatialIndex:queryRadius(center_x, center_y, radius)
    -- Query bounding box first
    local min_x = center_x - radius
    local min_y = center_y - radius
    local max_x = center_x + radius
    local max_y = center_y + radius
    
    local candidates = self:queryRect(min_x, min_y, max_x, max_y)
    
    -- This returns candidates; caller should filter by actual distance
    -- to entity positions if needed for precise radius check
    return candidates
end

--- Query entities at a specific point
-- @param x X coordinate
-- @param y Y coordinate
-- @return Array of entity IDs
function SpatialIndex:queryPoint(x, y)
    local key = self:_getCellKey(x, y)
    local cell = self.cells[key]
    
    self.stats.queries_performed = self.stats.queries_performed + 1
    
    if not cell then
        return {}
    end
    
    local results = {}
    for _, entity_id in ipairs(cell) do
        table.insert(results, entity_id)
        self.stats.entities_checked = self.stats.entities_checked + 1
    end
    
    return results
end

--- Get the nearest entity to a point
-- @param x X coordinate
-- @param y Y coordinate
-- @param entity_positions Table mapping entity_id to {x, y}
-- @param max_radius Optional maximum search radius
-- @return entity_id, distance (or nil if none found)
function SpatialIndex:findNearest(x, y, entity_positions, max_radius)
    max_radius = max_radius or 50
    
    local candidates = self:queryRadius(x, y, max_radius)
    
    local nearest_id = nil
    local nearest_dist = math.huge
    
    for _, entity_id in ipairs(candidates) do
        local pos = entity_positions[entity_id]
        if pos then
            local dx = pos.x - x
            local dy = pos.y - y
            local dist = math.sqrt(dx * dx + dy * dy)
            
            if dist < nearest_dist then
                nearest_dist = dist
                nearest_id = entity_id
            end
        end
    end
    
    if nearest_dist <= max_radius then
        return nearest_id, nearest_dist
    end
    
    return nil, nil
end

--- Clear all entities from the index
function SpatialIndex:clear()
    self.cells = {}
    self.entity_cells = {}
    self.stats.total_entities = 0
    self.stats.total_cells = 0
end

--- Get statistics
-- @return Statistics table
function SpatialIndex:getStats()
    return {
        total_entities = self.stats.total_entities,
        total_cells = self.stats.total_cells,
        queries_performed = self.stats.queries_performed,
        entities_checked = self.stats.entities_checked,
        avg_entities_per_query = self.stats.queries_performed > 0 
            and (self.stats.entities_checked / self.stats.queries_performed) or 0
    }
end

--- Reset query statistics
function SpatialIndex:resetStats()
    self.stats.queries_performed = 0
    self.stats.entities_checked = 0
end

--- Debug: Get all cells with entity counts
-- @return Array of {key, count}
function SpatialIndex:debugGetCells()
    local result = {}
    for key, cell in pairs(self.cells) do
        table.insert(result, {key = key, count = #cell})
    end
    return result
end

return SpatialIndex
