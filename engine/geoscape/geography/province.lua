---Province Entity - Strategic Location on World Map
---
---Represents a strategic location on the world map (node in province graph).
---Provinces have geography (hex coordinates, biome), demographics (population, satisfaction),
---economy (funding, resources), military (defense, bases), and diplomatic relations.
---
---Province Properties:
---  - id: Unique identifier
---  - name: Display name (e.g., "California", "Tokyo")
---  - hexCoordinates: {q, r} position on hex grid
---  - connections: Array of adjacent province IDs
---  - biome: Terrain type for battlescape generation
---  - population: Civilian count
---  - satisfaction: Public opinion (0-100)
---  - funding: Monthly credits provided to player
---  - hasBase: Player base present flag
---  - defense: Military strength
---  - faction: Controlling faction (player, alien, neutral)
---
---Economic System:
---  - High satisfaction → Higher funding
---  - Low satisfaction → Lower funding, risk of leaving
---  - Population affects total funding capacity
---  - Alien activity reduces satisfaction
---
---Strategic Value:
---  - Border provinces: High priority (control territory)
---  - High population: More funding potential
---  - Resource provinces: Special bonuses
---  - Base locations: Defense and radar coverage
---
---Key Exports:
---  - Province.new(data): Creates province entity
---  - updateSatisfaction(delta): Modifies public opinion
---  - calculateFunding(): Returns monthly credits
---  - isAdjacent(otherProvinceId): Checks connection
---  - getDefenseBonus(): Returns base defense strength
---
---Dependencies:
---  - geoscape.systems.hex_grid: Coordinate system
---  - geoscape.geography.biomes: Terrain definitions
---
---@module geoscape.geography.province
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Province = require("geoscape.geography.province")
---  local california = Province.new({
---    id = "province_ca",
---    name = "California",
---    population = 39000000,
---    satisfaction = 75
---  })
---
---@see geoscape.geography.province_graph For province network
---@see geoscape.world.world For world integration

local Province = {}
Province.__index = Province

---Create a new province
---@param data table Province data
---@return table Province instance
function Province.new(data)
    local self = setmetatable({}, Province)
    
    -- Core identification
    self.id = data.id or error("Province requires id")
    self.name = data.name or "Unknown Province"
    
    -- Hex grid position
    self.q = data.q or 0
    self.r = data.r or 0
    
    -- Geographic data
    self.biomeId = data.biomeId or "temperate_plains"
    self.regionId = data.regionId or "unknown"
    self.countryId = data.countryId or "neutral"
    self.isLand = data.isLand ~= false  -- Default to land
    self.isWater = data.isWater or false
    
    -- Graph connections (adjacent province IDs)
    self.connections = data.connections or {}
    
    -- Economic data
    self.economy = {
        gdp = data.gdp or 0,
        population = data.population or 0,
        wealth = data.wealth or 1.0  -- Multiplier
    }
    
    -- Game state
    self.playerBase = nil  -- Base object or nil
    self.crafts = {}  -- List of craft IDs present (max 4)
    self.missions = {}  -- List of active mission objects
    self.detected = false  -- Has player discovered this province?
    self.radarCoverage = false  -- Is this province under radar?
    
    -- Visual data
    self.cities = data.cities or {}  -- List of city names
    self.color = data.color or {r = 0.5, g = 0.5, b = 0.5}  -- RGB color for map
    
    return self
end

---Add a connection to another province
---@param provinceId string ID of connected province
---@param cost number? Travel cost (default 1)
function Province:addConnection(provinceId, cost)
    for _, conn in ipairs(self.connections) do
        if conn.id == provinceId then
            return  -- Already connected
        end
    end
    
    table.insert(self.connections, {
        id = provinceId,
        cost = cost or 1
    })
end

---Check if connected to another province
---@param provinceId string ID of province to check
---@return boolean True if connected
function Province:isConnectedTo(provinceId)
    for _, conn in ipairs(self.connections) do
        if conn.id == provinceId then
            return true
        end
    end
    return false
end

---Get travel cost to connected province
---@param provinceId string ID of connected province
---@return number? Travel cost, or nil if not connected
function Province:getTravelCost(provinceId)
    for _, conn in ipairs(self.connections) do
        if conn.id == provinceId then
            return conn.cost
        end
    end
    return nil
end

---Add a craft to this province
---@param craftId string Craft ID
---@return boolean True if added successfully
function Province:addCraft(craftId)
    if #self.crafts >= 4 then
        return false  -- Max 4 crafts per province
    end
    
    table.insert(self.crafts, craftId)
    return true
end

---Remove a craft from this province
---@param craftId string Craft ID
---@return boolean True if removed successfully
function Province:removeCraft(craftId)
    for i, id in ipairs(self.crafts) do
        if id == craftId then
            table.remove(self.crafts, i)
            return true
        end
    end
    return false
end

---Check if province has a craft
---@param craftId string Craft ID
---@return boolean True if craft is present
function Province:hasCraft(craftId)
    for _, id in ipairs(self.crafts) do
        if id == craftId then
            return true
        end
    end
    return false
end

---Add a mission to this province
---@param mission table Mission object
function Province:addMission(mission)
    table.insert(self.missions, mission)
end

---Remove a mission from this province
---@param missionId string Mission ID
---@return boolean True if removed successfully
function Province:removeMission(missionId)
    for i, mission in ipairs(self.missions) do
        if mission.id == missionId then
            table.remove(self.missions, i)
            return true
        end
    end
    return false
end

---Get all active missions in this province
---@return table List of mission objects
function Province:getMissions()
    return self.missions
end

---Check if province has any active missions
---@return boolean True if has missions
function Province:hasMissions()
    return #self.missions > 0
end

---Set player base in this province
---@param base table Base object
function Province:setBase(base)
    self.playerBase = base
end

---Check if province has a player base
---@return boolean True if has base
function Province:hasBase()
    return self.playerBase ~= nil
end

---Get province info for UI display
---@return table Province info
function Province:getInfo()
    return {
        id = self.id,
        name = self.name,
        position = {q = self.q, r = self.r},
        biome = self.biomeId,
        region = self.regionId,
        country = self.countryId,
        population = self.economy.population,
        gdp = self.economy.gdp,
        crafts = #self.crafts,
        missions = #self.missions,
        hasBase = self:hasBase(),
        cities = self.cities
    }
end

---Serialize province for save/load
---@return table Province data
function Province:serialize()
    return {
        id = self.id,
        name = self.name,
        q = self.q,
        r = self.r,
        biomeId = self.biomeId,
        regionId = self.regionId,
        countryId = self.countryId,
        isLand = self.isLand,
        isWater = self.isWater,
        connections = self.connections,
        economy = self.economy,
        crafts = self.crafts,
        missions = self.missions,
        detected = self.detected,
        radarCoverage = self.radarCoverage,
        cities = self.cities,
        color = self.color
    }
end

return Province


























