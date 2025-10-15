---World Entity - Planetary Body for Geoscape
---
---Represents a planetary body with hex grid geography, province network, and day/night cycle.
---Central entity for the geoscape strategic layer, managing spatial relationships, time
---progression, and global state. Integrates hex grid, provinces, biomes, and calendar systems.
---
---World Components:
---  - HexGrid: Axial coordinate system, pathfinding, distance calculations
---  - ProvinceGraph: Network of provinces with connections
---  - DayNightCycle: Visual overlay moving across world
---  - Calendar: Time tracking (day, month, year, quarter)
---  - Biomes: Terrain definitions for battlescape generation
---
---World Properties:
---  - id: Unique world identifier (e.g., "earth")
---  - name: Display name (e.g., "Earth")
---  - description: Lore text
---  - hexGrid: Grid system for spatial calculations
---  - provinceGraph: Province network
---  - dayNightCycle: Day/night overlay
---  - calendar: Time management
---
---Key Exports:
---  - World.new(data): Creates world entity
---  - updateDayNight(day): Advances day/night cycle
---  - getProvince(provinceId): Returns province by ID
---  - getProvinceAt(x, y): Returns province at screen coordinates
---  - getAdjacentProvinces(provinceId): Returns connected provinces
---  - pathfind(fromId, toId): A* pathfinding between provinces
---
---Dependencies:
---  - geoscape.systems.hex_grid: Coordinate system
---  - geoscape.geography.province_graph: Province network
---  - geoscape.systems.daynight_cycle: Visual overlay
---  - lore.calendar: Time tracking
---
---@module geoscape.world.world
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local World = require("geoscape.world.world")
---  local earth = World.new({id = "earth", name = "Earth"})
---  earth:updateDayNight(currentDay)
---  local province = earth:getProvince("province_23")
---
---@see geoscape.geography.province For province entity
---@see geoscape.systems.hex_grid For coordinate system

local HexGrid = require("geoscape.systems.hex_grid")
local ProvinceGraph = require("geoscape.geography.province_graph")
local DayNightCycle = require("geoscape.systems.daynight_cycle")
local Calendar = require("lore.calendar")

local World = {}
World.__index = World

---Create a new world
---@param data table World configuration data
---@return table World instance
function World.new(data)
    local self = setmetatable({}, World)
    
    -- Core identification
    self.id = data.id or "earth"
    self.name = data.name or "Earth"
    
    -- Hex grid dimensions
    self.width = data.width or 80
    self.height = data.height or 40
    self.hexSize = data.hexSize or 12
    self.scale = data.scale or 500  -- km per tile
    
    -- Create hex grid system
    self.hexGrid = HexGrid.new(self.width, self.height, self.hexSize)
    
    -- Create province graph
    self.provinceGraph = ProvinceGraph.new()
    
    -- Create day/night cycle
    self.dayNightCycle = DayNightCycle.new(self.width, data.dayNightSpeed or 4, data.dayNightCoverage or 0.5)
    
    -- Create calendar
    self.calendar = Calendar.new()
    
    -- Visual settings
    self.backgroundImage = data.backgroundImage or nil
    self.backgroundColor = data.backgroundColor or {r = 0.1, g = 0.1, b = 0.2}
    
    -- Tile grid data (80x40 grid of terrain types)
    self.tiles = {}
    for q = 0, self.width - 1 do
        self.tiles[q] = {}
        for r = 0, self.height - 1 do
            self.tiles[q][r] = {
                terrain = "ocean",
                cost = 1,
                isLand = false,
                isWater = true
            }
        end
    end
    
    -- Inter-world portals (for multi-world support)
    self.portals = data.portals or {}
    
    print(string.format("[World] Created '%s' (%dx%d hex grid, %d km/tile scale)",
        self.name, self.width, self.height, self.scale))
    
    return self
end

---Set tile data at hex coordinates
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@param terrain string Terrain type
---@param cost number? Movement cost (default 1)
---@param isLand boolean? Is land tile (default false)
function World:setTile(q, r, terrain, cost, isLand)
    if not self.hexGrid:inBounds(q, r) then
        return
    end
    
    if not self.tiles[q] then
        self.tiles[q] = {}
    end
    
    self.tiles[q][r] = {
        terrain = terrain or "ocean",
        cost = cost or 1,
        isLand = isLand or false,
        isWater = not isLand
    }
end

---Get tile data at hex coordinates
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return table? Tile data or nil
function World:getTile(q, r)
    if not self.hexGrid:inBounds(q, r) then
        return nil
    end
    
    if not self.tiles[q] then
        return nil
    end
    
    return self.tiles[q][r]
end

---Add a province to the world
---@param province table Province object
function World:addProvince(province)
    self.provinceGraph:addProvince(province)
    
    -- Update tile at province position to mark as land
    if province.isLand then
        self:setTile(province.q, province.r, province.biomeId, 1, true)
    end
end

---Get province at hex coordinates
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return table? Province object or nil
function World:getProvinceAtHex(q, r)
    return self.provinceGraph:getProvinceAtHex(q, r)
end

---Get province by ID
---@param provinceId string Province ID
---@return table? Province object or nil
function World:getProvince(provinceId)
    return self.provinceGraph:getProvince(provinceId)
end

---Advance time by one day
function World:advanceDay()
    self.calendar:advanceTurn()
    self.dayNightCycle:advanceDay()
    
    -- Trigger daily events
    self:processDailyEvents()
end

---Process daily events (override in game logic)
function World:processDailyEvents()
    -- Check for new missions
    -- Update country relations
    -- Process base construction
    -- etc.
end

---Get light level at hex coordinates
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return number Light level (0.0 = night, 1.0 = day)
function World:getLightLevel(q, r)
    return self.dayNightCycle:getLightLevel(q, self.width)
end

---Check if hex is in daylight
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return boolean True if in daylight
function World:isDay(q, r)
    local isDay, lightLevel = self.dayNightCycle:isDay(q, self.width)
    return isDay
end

---Convert hex coordinates to pixel position
---@param q number Hex Q coordinate
---@param r number Hex R coordinate
---@return number, number Pixel X, Y coordinates
function World:hexToPixel(q, r)
    return self.hexGrid:toPixel(q, r)
end

---Convert pixel position to hex coordinates
---@param x number Pixel X coordinate
---@param y number Pixel Y coordinate
---@return number, number Hex Q, R coordinates
function World:pixelToHex(x, y)
    return self.hexGrid:toHex(x, y)
end

---Get world dimensions
---@return number, number Width and height in hex tiles
function World:getDimensions()
    return self.width, self.height
end

---Get world scale
---@return number Kilometers per tile
function World:getScale()
    return self.scale
end

---Get current date string
---@return string Date string
function World:getDate()
    return self.calendar:getMediumDate()
end

---Get current turn number
---@return number Turn number
function World:getTurn()
    return self.calendar.turn
end

---Serialize world for save/load
---@return table World state
function World:serialize()
    return {
        id = self.id,
        name = self.name,
        width = self.width,
        height = self.height,
        hexSize = self.hexSize,
        scale = self.scale,
        calendar = self.calendar:serialize(),
        dayNightCycle = self.dayNightCycle:serialize(),
        tiles = self.tiles,
        portals = self.portals
    }
end

---Load world state from serialization
---@param data table World state
function World:deserialize(data)
    if data.calendar then
        self.calendar:deserialize(data.calendar)
    end
    if data.dayNightCycle then
        self.dayNightCycle:deserialize(data.dayNightCycle)
    end
    if data.tiles then
        self.tiles = data.tiles
    end
end

---Get all provinces
---@return table List of Province objects
function World:getAllProvinces()
    return self.provinceGraph:getAllProvinces()
end

---Get province count
---@return number Number of provinces
function World:getProvinceCount()
    return self.provinceGraph:getProvinceCount()
end

return World






















