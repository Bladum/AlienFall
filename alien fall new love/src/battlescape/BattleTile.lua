--- Battle Tile
-- Represents a single tile in the battlescape with terrain properties
--
-- @classmod battlescape.BattleTile

-- GROK: BattleTile represents 20x20 pixel grid cells with cover, elevation, material, and environmental properties
-- GROK: Used by pathfinding, line-of-sight, and environmental systems for terrain calculations
-- GROK: Key properties: cover, elevation, material, walkable, flammable
-- GROK: Supports dynamic changes from environmental effects and destruction

local class = require 'lib.Middleclass'

--- BattleTile class
-- @type BattleTile
BattleTile = class('BattleTile')

--- Terrain materials
-- @field GRASS Grass terrain
-- @field DIRT Dirt terrain
-- @field CONCRETE Concrete terrain
-- @field WOOD Wood terrain
-- @field METAL Metal terrain
-- @field WATER Water terrain
BattleTile.static.MATERIALS = {
    GRASS = "grass",
    DIRT = "dirt",
    CONCRETE = "concrete",
    WOOD = "wood",
    METAL = "metal",
    WATER = "water",
    STONE = "stone",
    SAND = "sand",
    RUBBLE = "rubble"
}

--- Create a new BattleTile instance
-- @param x Grid X coordinate
-- @param y Grid Y coordinate
-- @param data Tile data from map generation
-- @return BattleTile instance
function BattleTile:initialize(x, y, data)
    self.x = x
    self.y = y

    -- Basic terrain properties
    self.material = data.material or self.MATERIALS.GRASS
    self.elevation = data.elevation or 0
    self.cover = data.cover or 0 -- 0-4 cover value
    self.walkable = data.walkable ~= false -- Most tiles are walkable by default

    -- Environmental properties
    self.flammable = data.flammable or self:isMaterialFlammable(self.material)
    self.blocksVision = data.blocksVision or false
    self.blocksSound = data.blocksSound or false

    -- Dynamic properties (change during battle)
    self.onFire = false
    self.smoky = false
    self.destroyed = false
    self.fireDamage = 0
    self.visibilityModifier = 1.0

    -- Special properties
    self.door = data.door or false
    self.window = data.window or false
    self.stairs = data.stairs or false
    self.elevator = data.elevator or false

    -- AI/pathfinding properties
    self.movementCost = data.movementCost or self:getDefaultMovementCost()
    self.pathfindingWeight = data.pathfindingWeight or 1.0
end

--- Get default movement cost based on material
-- @return number Movement cost
function BattleTile:getDefaultMovementCost()
    local materialCosts = {
        [self.MATERIALS.GRASS] = 1.0,
        [self.MATERIALS.DIRT] = 1.0,
        [self.MATERIALS.CONCRETE] = 1.0,
        [self.MATERIALS.WOOD] = 1.0,
        [self.MATERIALS.METAL] = 1.0,
        [self.MATERIALS.STONE] = 1.0,
        [self.MATERIALS.SAND] = 1.2,
        [self.MATERIALS.WATER] = 2.0,
        [self.MATERIALS.RUBBLE] = 3.0
    }

    return materialCosts[self.material] or 1.0
end

--- Check if material is flammable
-- @param material Material to check
-- @return boolean Whether material is flammable
function BattleTile:isMaterialFlammable(material)
    local flammableMaterials = {
        [self.MATERIALS.GRASS] = true,
        [self.MATERIALS.WOOD] = true,
        [self.MATERIALS.RUBBLE] = false,
        [self.MATERIALS.CONCRETE] = false,
        [self.MATERIALS.METAL] = false,
        [self.MATERIALS.STONE] = false,
        [self.MATERIALS.WATER] = false,
        [self.MATERIALS.SAND] = false
    }

    return flammableMaterials[material] or false
end

--- Get tile position
-- @return number x, number y
function BattleTile:getPosition()
    return self.x, self.y
end

--- Check if tile is walkable
-- @return boolean Whether tile is walkable
function BattleTile:isWalkable()
    return self.walkable and not self.destroyed
end

--- Check if tile blocks vision
-- @return boolean Whether tile blocks vision
function BattleTile:blocksVision()
    return self.blocksVision or self.destroyed
end

--- Check if tile blocks sound
-- @return boolean Whether tile blocks sound
function BattleTile:blocksSound()
    return self.blocksSound
end

--- Get cover value
-- @return number Cover value (0-4)
function BattleTile:getCover()
    if self.destroyed then
        return 0
    end
    return self.cover
end

--- Get elevation
-- @return number Elevation level
function BattleTile:getElevation()
    return self.elevation
end

--- Get movement cost
-- @return number Movement cost multiplier
function BattleTile:getMovementCost()
    if not self:isWalkable() then
        return 999 -- Effectively impassable
    end
    return self.movementCost
end

--- Get pathfinding weight
-- @return number Pathfinding weight
function BattleTile:getPathfindingWeight()
    return self.pathfindingWeight
end

--- Check if tile provides high cover (blocks line of fire)
-- @return boolean Whether tile provides high cover
function BattleTile:providesHighCover()
    return self:getCover() >= 3
end

--- Check if tile provides low cover (partial blocking)
-- @return boolean Whether tile provides low cover
function BattleTile:providesLowCover()
    return self:getCover() >= 1 and self:getCover() < 3
end

--- Get visibility modifier
-- @return number Visibility modifier (0.0-1.0)
function BattleTile:getVisibilityModifier()
    return self.visibilityModifier
end

--- Apply environmental effect
-- @param effectType Type of effect
-- @param intensity Effect intensity
function BattleTile:applyEnvironmentalEffect(effectType, intensity)
    if effectType == "fire" then
        self.onFire = true
        self.fireDamage = (self.fireDamage or 0) + intensity
        self.visibilityModifier = math.max(0.3, self.visibilityModifier - 0.3)
    elseif effectType == "smoke" then
        self.smoky = true
        self.visibilityModifier = math.max(0.1, self.visibilityModifier - intensity * 0.1)
    elseif effectType == "destruction" then
        self.destroyed = true
        self.walkable = false
        self.cover = 0
        self.material = self.MATERIALS.RUBBLE
        self.flammable = false
    end
end

--- Remove environmental effect
-- @param effectType Type of effect
function BattleTile:removeEnvironmentalEffect(effectType)
    if effectType == "fire" then
        self.onFire = false
        self.visibilityModifier = math.min(1.0, self.visibilityModifier + 0.3)
    elseif effectType == "smoke" then
        self.smoky = false
        self.visibilityModifier = 1.0
    end
end

--- Check if tile is on fire
-- @return boolean Whether tile is on fire
function BattleTile:isOnFire()
    return self.onFire
end

--- Check if tile is smoky
-- @return boolean Whether tile is smoky
function BattleTile:isSmoky()
    return self.smoky
end

--- Check if tile is destroyed
-- @return boolean Whether tile is destroyed
function BattleTile:isDestroyed()
    return self.destroyed
end

--- Get fire damage accumulated
-- @return number Fire damage
function BattleTile:getFireDamage()
    return self.fireDamage or 0
end

--- Check if tile has special property
-- @param property Property to check (door, window, stairs, elevator)
-- @return boolean Whether tile has property
function BattleTile:hasProperty(property)
    return self[property] or false
end

--- Get tile material
-- @return string Material type
function BattleTile:getMaterial()
    return self.material
end

--- Get tile data for serialization
-- @return table Tile data
function BattleTile:getData()
    return {
        x = self.x,
        y = self.y,
        material = self.material,
        elevation = self.elevation,
        cover = self.cover,
        walkable = self.walkable,
        flammable = self.flammable,
        blocksVision = self.blocksVision,
        blocksSound = self.blocksSound,
        onFire = self.onFire,
        smoky = self.smoky,
        destroyed = self.destroyed,
        fireDamage = self.fireDamage,
        visibilityModifier = self.visibilityModifier,
        door = self.door,
        window = self.window,
        stairs = self.stairs,
        elevator = self.elevator,
        movementCost = self.movementCost,
        pathfindingWeight = self.pathfindingWeight
    }
end

--- Load tile from data
-- @param data Tile data
function BattleTile:loadFromData(data)
    self.material = data.material or self.material
    self.elevation = data.elevation or self.elevation
    self.cover = data.cover or self.cover
    self.walkable = data.walkable ~= false
    self.flammable = data.flammable or self.flammable
    self.blocksVision = data.blocksVision or self.blocksVision
    self.blocksSound = data.blocksSound or self.blocksSound
    self.onFire = data.onFire or false
    self.smoky = data.smoky or false
    self.destroyed = data.destroyed or false
    self.fireDamage = data.fireDamage or 0
    self.visibilityModifier = data.visibilityModifier or 1.0
    self.door = data.door or false
    self.window = data.window or false
    self.stairs = data.stairs or false
    self.elevator = data.elevator or false
    self.movementCost = data.movementCost or self:getDefaultMovementCost()
    self.pathfindingWeight = data.pathfindingWeight or 1.0
end

--- Get tile description for UI/debugging
-- @return string Tile description
function BattleTile:getDescription()
    local desc = string.format("Tile (%d,%d): %s", self.x, self.y, self.material)

    if self.destroyed then
        desc = desc .. " [DESTROYED]"
    elseif self.onFire then
        desc = desc .. " [ON FIRE]"
    elseif self.smoky then
        desc = desc .. " [SMOKY]"
    end

    if self.cover > 0 then
        desc = desc .. string.format(" [Cover: %d]", self.cover)
    end

    if self.elevation > 0 then
        desc = desc .. string.format(" [Elev: %d]", self.elevation)
    end

    return desc
end

return BattleTile
