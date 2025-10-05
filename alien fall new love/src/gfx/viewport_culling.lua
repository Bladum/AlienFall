--- Viewport Culling Module
--- Provides efficient culling of off-screen tiles and entities to improve rendering performance.
--- Only elements within the visible viewport (plus a margin) are rendered.
---
--- @module gfx.viewport_culling
--- @author AlienFall Development Team
--- @copyright 2025

local validate = require('utils.validate')

local ViewportCulling = {}

--- Initialize viewport culling system
---
--- @param config table Configuration options
---   - viewport_width: Width of the viewport (default: 800)
---   - viewport_height: Height of the viewport (default: 600)
---   - margin: Extra margin around viewport for smooth scrolling (default: 100)
---   - tile_size: Size of tiles for grid culling (default: 32)
function ViewportCulling.new(config)
    config = config or {}
    
    local self = {
        -- Viewport dimensions (internal resolution)
        viewport_width = config.viewport_width or 800,
        viewport_height = config.viewport_height or 600,
        
        -- Margin for smooth scrolling (pixels beyond viewport)
        margin = config.margin or 100,
        
        -- Camera position (top-left corner of viewport in world space)
        camera_x = 0,
        camera_y = 0,
        
        -- Tile size for grid-based culling
        tile_size = config.tile_size or 32,
        
        -- Statistics
        stats = {
            total_checked = 0,
            total_visible = 0,
            total_culled = 0
        }
    }
    
    return setmetatable(self, {__index = ViewportCulling})
end

--- Update camera position
--- Call this when the camera/viewport moves
---
--- @param x number Camera X position (world space)
--- @param y number Camera Y position (world space)
function ViewportCulling:setCameraPosition(x, y)
    validate.require_type(x, "number", "camera x")
    validate.require_type(y, "number", "camera y")
    self.camera_x = x
    self.camera_y = y
end

--- Get camera position
---
--- @return number, number Camera X and Y position
function ViewportCulling:getCameraPosition()
    return self.camera_x, self.camera_y
end

--- Calculate visible bounds (with margin)
--- Returns the visible rectangle in world space
---
--- @return number, number, number, number min_x, min_y, max_x, max_y
function ViewportCulling:getVisibleBounds()
    local min_x = self.camera_x - self.margin
    local min_y = self.camera_y - self.margin
    local max_x = self.camera_x + self.viewport_width + self.margin
    local max_y = self.camera_y + self.viewport_height + self.margin
    
    return min_x, min_y, max_x, max_y
end

--- Check if a point is visible
---
--- @param x number Point X coordinate (world space)
--- @param y number Point Y coordinate (world space)
--- @return boolean True if point is visible
function ViewportCulling:isPointVisible(x, y)
    self.stats.total_checked = self.stats.total_checked + 1
    
    local min_x, min_y, max_x, max_y = self:getVisibleBounds()
    local visible = x >= min_x and x <= max_x and y >= min_y and y <= max_y
    
    if visible then
        self.stats.total_visible = self.stats.total_visible + 1
    else
        self.stats.total_culled = self.stats.total_culled + 1
    end
    
    return visible
end

--- Check if a rectangle is visible (or partially visible)
---
--- @param x number Rectangle X position (world space)
--- @param y number Rectangle Y position (world space)
--- @param width number Rectangle width
--- @param height number Rectangle height
--- @return boolean True if rectangle is visible
function ViewportCulling:isRectVisible(x, y, width, height)
    self.stats.total_checked = self.stats.total_checked + 1
    
    local min_x, min_y, max_x, max_y = self:getVisibleBounds()
    
    -- Check for overlap using AABB (Axis-Aligned Bounding Box) test
    local visible = not (x + width < min_x or x > max_x or y + height < min_y or y > max_y)
    
    if visible then
        self.stats.total_visible = self.stats.total_visible + 1
    else
        self.stats.total_culled = self.stats.total_culled + 1
    end
    
    return visible
end

--- Check if a circle is visible (or partially visible)
---
--- @param x number Circle center X (world space)
--- @param y number Circle center Y (world space)
--- @param radius number Circle radius
--- @return boolean True if circle is visible
function ViewportCulling:isCircleVisible(x, y, radius)
    self.stats.total_checked = self.stats.total_checked + 1
    
    local min_x, min_y, max_x, max_y = self:getVisibleBounds()
    
    -- Check if circle overlaps viewport rectangle
    -- Find closest point on rectangle to circle center
    local closest_x = math.max(min_x, math.min(x, max_x))
    local closest_y = math.max(min_y, math.min(y, max_y))
    
    -- Calculate distance from circle center to closest point
    local dx = x - closest_x
    local dy = y - closest_y
    local distance_sq = dx * dx + dy * dy
    
    local visible = distance_sq <= (radius * radius)
    
    if visible then
        self.stats.total_visible = self.stats.total_visible + 1
    else
        self.stats.total_culled = self.stats.total_culled + 1
    end
    
    return visible
end

--- Get visible tile range for grid-based culling
--- Returns the range of tile indices that are visible
---
--- @return number, number, number, number min_tile_x, min_tile_y, max_tile_x, max_tile_y
function ViewportCulling:getVisibleTileRange()
    local min_x, min_y, max_x, max_y = self:getVisibleBounds()
    
    -- Convert to tile coordinates
    local min_tile_x = math.floor(min_x / self.tile_size)
    local min_tile_y = math.floor(min_y / self.tile_size)
    local max_tile_x = math.ceil(max_x / self.tile_size)
    local max_tile_y = math.ceil(max_y / self.tile_size)
    
    return min_tile_x, min_tile_y, max_tile_x, max_tile_y
end

--- Cull a list of entities
--- Returns only the entities that are visible
---
--- @param entities table Array of entities with x, y, width, height fields
--- @return table Array of visible entities
function ViewportCulling:cullEntities(entities)
    validate.require_type(entities, "table", "entities")
    
    local visible = {}
    
    for _, entity in ipairs(entities) do
        -- Determine entity bounds
        local x = entity.x or 0
        local y = entity.y or 0
        local width = entity.width or self.tile_size
        local height = entity.height or self.tile_size
        
        if self:isRectVisible(x, y, width, height) then
            table.insert(visible, entity)
        end
    end
    
    return visible
end

--- Cull a 2D grid of tiles
--- Calls callback only for visible tiles
---
--- @param grid table 2D array of tiles (grid[y][x])
--- @param callback function Function to call for each visible tile (x, y, tile)
function ViewportCulling:cullGrid(grid, callback)
    validate.require_type(grid, "table", "grid")
    validate.require_callable(callback, "callback")
    
    local min_tx, min_ty, max_tx, max_ty = self:getVisibleTileRange()
    
    for ty = min_ty, max_ty do
        local row = grid[ty]
        if row then
            for tx = min_tx, max_tx do
                local tile = row[tx]
                if tile then
                    callback(tx, ty, tile)
                end
            end
        end
    end
end

--- Get culling statistics
--- Useful for debugging and optimization
---
--- @return table Statistics (total_checked, total_visible, total_culled, cull_rate)
function ViewportCulling:getStats()
    local cull_rate = self.stats.total_checked > 0 
        and (self.stats.total_culled / self.stats.total_checked * 100) 
        or 0
    
    return {
        total_checked = self.stats.total_checked,
        total_visible = self.stats.total_visible,
        total_culled = self.stats.total_culled,
        cull_rate = cull_rate
    }
end

--- Reset statistics
--- Call this periodically to avoid integer overflow
function ViewportCulling:resetStats()
    self.stats.total_checked = 0
    self.stats.total_visible = 0
    self.stats.total_culled = 0
end

--- Convert screen coordinates to world coordinates
---
--- @param screen_x number Screen X coordinate
--- @param screen_y number Screen Y coordinate
--- @return number, number World X and Y coordinates
function ViewportCulling:screenToWorld(screen_x, screen_y)
    return self.camera_x + screen_x, self.camera_y + screen_y
end

--- Convert world coordinates to screen coordinates
---
--- @param world_x number World X coordinate
--- @param world_y number World Y coordinate
--- @return number, number Screen X and Y coordinates
function ViewportCulling:worldToScreen(world_x, world_y)
    return world_x - self.camera_x, world_y - self.camera_y
end

--- Set viewport dimensions
---
--- @param width number New viewport width
--- @param height number New viewport height
function ViewportCulling:setViewportSize(width, height)
    validate.require_positive(width, "width")
    validate.require_positive(height, "height")
    self.viewport_width = width
    self.viewport_height = height
end

--- Get viewport dimensions
---
--- @return number, number Viewport width and height
function ViewportCulling:getViewportSize()
    return self.viewport_width, self.viewport_height
end

return ViewportCulling
