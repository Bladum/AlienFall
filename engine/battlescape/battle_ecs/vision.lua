---Vision - Vision and Line of Sight Component (ECS)
---
---Pure data component storing unit vision range, arc, and visible tiles. Part of
---the ECS (Entity-Component-System) battle architecture. Tracks what tiles each
---unit can see and vision parameters.
---
---Features:
---  - Vision range (distance in hexes)
---  - Vision arc (cone in degrees)
---  - Visible tiles tracking
---  - Direction-based vision
---  - Night vision support
---  - Infrared vision flag
---
---Component Data:
---  - range: Maximum vision distance
---  - arc: Vision cone angle (120° default)
---  - visibleTiles: Set of visible hex coords
---  - hasNightVision: Boolean flag
---  - hasInfrared: Boolean flag
---
---Vision Arcs:
---  - 360°: Full omnidirectional vision
---  - 120°: Standard forward arc (3 hex directions)
---  - 60°: Narrow focused vision (1 hex direction)
---
---Key Exports:
---  - Vision.new(range, arc): Creates vision component
---  - setVisibleTiles(vision, tiles): Updates visible set
---  - isVisible(vision, x, y): Checks if tile visible
---  - clearVisible(vision): Clears visible tiles
---
---Dependencies:
---  - None (pure data component)
---
---@module battlescape.battle_ecs.vision
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Vision = require("battlescape.battle_ecs.vision")
---  local vision = Vision.new(8, 120)
---  vision.visibleTiles["10_15"] = true
---
---@see battlescape.battle_ecs.vision_system For vision calculation
---@see battlescape.battle_ecs.unit_entity For usage

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

























