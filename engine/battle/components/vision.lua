-- vision.lua
-- Vision and line-of-sight data component (pure data)
-- Part of ECS architecture for battle system

local Vision = {}

-- Create a new vision component
-- @param range number: Vision range in hexes (default 8)
-- @param arc number: Vision arc in degrees (default 120)
-- @return table: Vision component
function Vision.new(range, arc)
    local instance = {
        range = range or 8,      -- Maximum vision distance in hexes
        arc = arc or 120,        -- Vision cone arc (120° = front 3 hexes)
        visibleTiles = {},       -- Set of visible hex coordinates {x_y = true}
        canSeeUnits = {}         -- Set of visible unit IDs {id = true}
    }
    
    -- Add methods to instance
    instance.clear = function(self) Vision.clear(self) end
    instance.markTileVisible = function(self, x, y) Vision.markTileVisible(self, x, y) end
    instance.canSeeTile = function(self, x, y) return Vision.canSeeTile(self, x, y) end
    instance.markUnitVisible = function(self, unitId) Vision.markUnitVisible(self, unitId) end
    instance.canSeeUnit = function(self, unitId) return Vision.canSeeUnit(self, unitId) end
    
    return instance
end

-- Clear vision cache (should be recalculated each turn)
function Vision.clear(vision)
    vision.visibleTiles = {}
    vision.canSeeUnits = {}
end

-- Mark tile as visible
function Vision.markTileVisible(vision, x, y)
    local key = x .. "_" .. y
    vision.visibleTiles[key] = true
end

-- Check if tile is visible
function Vision.canSeeTile(vision, x, y)
    local key = x .. "_" .. y
    return vision.visibleTiles[key] == true
end

-- Mark unit as visible
function Vision.markUnitVisible(vision, unitId)
    vision.canSeeUnits[unitId] = true
end

-- Check if unit is visible
function Vision.canSeeUnit(vision, unitId)
    return vision.canSeeUnits[unitId] == true
end

return Vision
