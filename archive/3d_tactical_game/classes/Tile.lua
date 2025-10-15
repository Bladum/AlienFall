---@class Tile
-- Represents a single tile in the game grid
-- Each tile has a terrain type (floor/wall/door) and tracks visibility/occupancy

local Constants = require("config.constants")

local Tile = {}
Tile.__index = Tile

--- Create a new Tile
---@param x number Grid X position (1-based)
---@param y number Grid Y position (1-based)
---@param terrainType number Type from Constants.TERRAIN
---@return Tile
function Tile.new(x, y, terrainType)
    local self = setmetatable({}, Tile)
    
    -- Position
    self.gridX = x
    self.gridY = y
    self.worldX = x  -- 3D world position
    self.worldZ = y  -- 3D world position
    
    -- Terrain properties
    self.terrainType = terrainType or Constants.TERRAIN.FLOOR
    self.traversable = self:isTraversable()
    
    -- Visibility state per team (indexed by team ID)
    self.visibility = {}
    for teamId = 1, 4 do
        self.visibility[teamId] = Constants.VISIBILITY.HIDDEN
    end
    
    -- Occupancy
    self.occupant = nil  -- Reference to Unit on this tile
    self.effect = nil    -- Reference to TileEffect (smoke, fire, etc.)
    
    -- Rendering
    self.model = nil     -- G3D model for 3D rendering
    self.needsUpdate = true  -- Flag to rebuild model
    
    return self
end

--- Check if this terrain type is traversable
---@return boolean
function Tile:isTraversable()
    return self.terrainType == Constants.TERRAIN.FLOOR or
           self.terrainType == Constants.TERRAIN.DOOR
end

--- Check if this tile blocks line of sight
---@return boolean
function Tile:blocksLOS()
    -- Walls block LOS
    if self.terrainType == Constants.TERRAIN.WALL then
        return true
    end
    
    -- Smoke effect blocks LOS
    if self.effect and self.effect.blocksLOS then
        return true
    end
    
    return false
end

--- Set visibility state for a specific team
---@param teamId number Team identifier
---@param state number Visibility state from Constants.VISIBILITY
function Tile:setVisibility(teamId, state)
    if self.visibility[teamId] ~= state then
        self.visibility[teamId] = state
        self.needsUpdate = true  -- Mark for rendering update
    end
end

--- Get visibility state for a specific team
---@param teamId number Team identifier
---@return number Visibility state
function Tile:getVisibility(teamId)
    return self.visibility[teamId] or Constants.VISIBILITY.HIDDEN
end

--- Check if tile is visible to a specific team
---@param teamId number Team identifier
---@return boolean
function Tile:isVisibleTo(teamId)
    return self.visibility[teamId] == Constants.VISIBILITY.VISIBLE
end

--- Check if tile has been explored by a specific team
---@param teamId number Team identifier
---@return boolean
function Tile:isExploredBy(teamId)
    return self.visibility[teamId] >= Constants.VISIBILITY.EXPLORED
end

--- Set the unit occupying this tile
---@param unit any Unit object or nil
function Tile:setOccupant(unit)
    self.occupant = unit
end

--- Check if tile is occupied
---@return boolean
function Tile:isOccupied()
    return self.occupant ~= nil
end

--- Get the occupying unit
---@return any Unit object or nil
function Tile:getOccupant()
    return self.occupant
end

--- Set a tile effect (smoke, fire, etc.)
---@param effect any TileEffect object or nil
function Tile:setEffect(effect)
    self.effect = effect
    self.needsUpdate = true
end

--- Get the tile effect
---@return any TileEffect object or nil
function Tile:getEffect()
    return self.effect
end

--- Update tile state (called each frame)
---@param dt number Delta time in seconds
function Tile:update(dt)
    -- Update tile effect if present
    if self.effect then
        self.effect:update(dt)
        
        -- Remove effect if it has expired
        if self.effect:isExpired() then
            self.effect = nil
            self.needsUpdate = true
        end
    end
end

--- Get lighting value based on visibility for a team
---@param teamId number Team identifier
---@return number Brightness value (0-1)
function Tile:getBrightness(teamId)
    local visState = self:getVisibility(teamId)
    
    if visState == Constants.VISIBILITY.VISIBLE then
        return Constants.LIGHT_VISIBLE
    elseif visState == Constants.VISIBILITY.EXPLORED then
        return Constants.LIGHT_EXPLORED
    else
        return Constants.LIGHT_HIDDEN
    end
end

--- Convert to string for debugging
---@return string
function Tile:toString()
    local terrainNames = {"FLOOR", "WALL", "DOOR"}
    return string.format("Tile(%d,%d)[%s]", 
        self.gridX, self.gridY, 
        terrainNames[self.terrainType] or "UNKNOWN")
end

return Tile






















