---@class Province
---@field x number
---@field y number
---@field biome string
---@field elevation number
---@field population number
---@field region_id number
---@field control string
---@field resources table
---@field has_city boolean
local Province = {}

---@class WorldMap
---Core grid-based world container for provinces
---Manages 80x40 province grid with efficient access patterns
local WorldMap = {}

---Create new empty world
---@param width number World width in provinces (default: 80)
---@param height number World height in provinces (default: 40)
---@return WorldMap
function WorldMap.new(width, height)
    width = width or 80
    height = height or 40

    local self = {
        width = width,
        height = height,
        provinces = {},     -- 1D array of Province objects
        biomes = {},        -- Biome type per province (string)
        elevation = {},     -- Height per province (0-1)
        resources = {},     -- Resources per province (table)
        locations = {},     -- Locations/cities per province
        data = {},          -- Generic data per province
    }

    -- Pre-allocate arrays for all provinces
    local total = width * height
    for i = 1, total do
        self.provinces[i] = nil
        self.biomes[i] = "unknown"
        self.elevation[i] = 0
        self.resources[i] = {}
        self.locations[i] = {}
        self.data[i] = {}
    end

    print(string.format("[WorldMap] Initialized %dx%d grid (%d provinces)",
        width, height, total))

    return setmetatable(self, {__index = WorldMap})
end

---Convert (x, y) to linear index
---@param x number Province X coordinate
---@param y number Province Y coordinate
---@return number Linear index (1-based)
local function coordToIndex(x, y, width)
    return y * width + x + 1
end

---Validate coordinates
---@param x number
---@param y number
---@param width number
---@param height number
---@return boolean Valid
local function isValidCoord(x, y, width, height)
    return x >= 0 and x < width and y >= 0 and y < height
end

---Get province at coordinates
---@param x number Province X coordinate (0-79)
---@param y number Province Y coordinate (0-39)
---@return Province|nil Province at (x, y) or nil if out of bounds
function WorldMap:getProvince(x, y)
    if not isValidCoord(x, y, self.width, self.height) then
        return nil
    end

    local idx = coordToIndex(x, y, self.width)
    return self.provinces[idx]
end

---Set province at coordinates
---@param x number Province X coordinate
---@param y number Province Y coordinate
---@param province Province Province object to store
---@return boolean Success
function WorldMap:setProvince(x, y, province)
    if not isValidCoord(x, y, self.width, self.height) then
        return false
    end

    local idx = coordToIndex(x, y, self.width)
    self.provinces[idx] = province

    if province then
        self.biomes[idx] = province.biome or "unknown"
        self.elevation[idx] = province.elevation or 0
        self.resources[idx] = province.resources or {}
    end

    return true
end

---Get biome type at coordinates
---@param x number
---@param y number
---@return string Biome type or "unknown"
function WorldMap:getBiome(x, y)
    if not isValidCoord(x, y, self.width, self.height) then
        return "unknown"
    end

    local idx = coordToIndex(x, y, self.width)
    return self.biomes[idx]
end

---Set biome type at coordinates
---@param x number
---@param y number
---@param biome string Biome type
function WorldMap:setBiome(x, y, biome)
    if not isValidCoord(x, y, self.width, self.height) then
        return
    end

    local idx = coordToIndex(x, y, self.width)
    self.biomes[idx] = biome
end

---Get elevation at coordinates
---@param x number
---@param y number
---@return number Elevation (0-1) or 0 if out of bounds
function WorldMap:getElevation(x, y)
    if not isValidCoord(x, y, self.width, self.height) then
        return 0
    end

    local idx = coordToIndex(x, y, self.width)
    return self.elevation[idx]
end

---Set elevation at coordinates
---@param x number
---@param y number
---@param elevation number Elevation (0-1)
function WorldMap:setElevation(x, y, elevation)
    if not isValidCoord(x, y, self.width, self.height) then
        return
    end

    local idx = coordToIndex(x, y, self.width)
    self.elevation[idx] = math.max(0, math.min(1, elevation))
end

---Get resources at coordinates
---@param x number
---@param y number
---@return table Resources table or empty table
function WorldMap:getResources(x, y)
    if not isValidCoord(x, y, self.width, self.height) then
        return {}
    end

    local idx = coordToIndex(x, y, self.width)
    return self.resources[idx] or {}
end

---Set resources at coordinates
---@param x number
---@param y number
---@param resources table Resource table {mineral, energy, tech, rare}
function WorldMap:setResources(x, y, resources)
    if not isValidCoord(x, y, self.width, self.height) then
        return
    end

    local idx = coordToIndex(x, y, self.width)
    self.resources[idx] = resources or {}
end

---Get locations/cities at coordinates
---@param x number
---@param y number
---@return table[] Array of locations
function WorldMap:getLocations(x, y)
    if not isValidCoord(x, y, self.width, self.height) then
        return {}
    end

    local idx = coordToIndex(x, y, self.width)
    return self.locations[idx] or {}
end

---Add location/city to province
---@param x number
---@param y number
---@param location table Location data {name, type, population}
function WorldMap:addLocation(x, y, location)
    if not isValidCoord(x, y, self.width, self.height) then
        return
    end

    local idx = coordToIndex(x, y, self.width)
    if not self.locations[idx] then
        self.locations[idx] = {}
    end

    table.insert(self.locations[idx], location)
end

---Get all neighboring provinces within distance
---@param x number Center province X
---@param y number Center province Y
---@param distance number Search radius (default: 1)
---@return Province[] Array of neighboring provinces
function WorldMap:getNeighbors(x, y, distance)
    distance = distance or 1
    local neighbors = {}

    for dy = -distance, distance do
        for dx = -distance, distance do
            if dx == 0 and dy == 0 then
                -- Skip center
            else
                local nx = x + dx
                local ny = y + dy

                if isValidCoord(nx, ny, self.width, self.height) then
                    local province = self:getProvince(nx, ny)
                    if province then
                        table.insert(neighbors, {
                            x = nx,
                            y = ny,
                            province = province,
                        })
                    end
                end
            end
        end
    end

    return neighbors
end

---Get distance between two provinces (Manhattan distance)
---@param from table {x, y} coordinates
---@param to table {x, y} coordinates
---@return number Manhattan distance
function WorldMap:getDistance(from, to)
    return math.abs(from.x - to.x) + math.abs(from.y - to.y)
end

---Find all provinces matching a predicate
---@param predicate function Function(x, y, province) -> boolean
---@return table[] Array of {x, y, province}
function WorldMap:findProvinces(predicate)
    local results = {}

    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local province = self:getProvince(x, y)
            if province and predicate(x, y, province) then
                table.insert(results, {x = x, y = y, province = province})
            end
        end
    end

    return results
end

---Find all provinces by biome type
---@param biome string Biome type to search for
---@return table[] Array of {x, y, province}
function WorldMap:getProvincesByBiome(biome)
    return self:findProvinces(function(x, y, province)
        return province.biome == biome
    end)
end

---Find all provinces by control status
---@param control string Control type: "player", "alien", "neutral"
---@return table[] Array of {x, y, province}
function WorldMap:getProvincesByControl(control)
    return self:findProvinces(function(x, y, province)
        return province.control == control
    end)
end

---Find all provinces in a region
---@param region_id number Region ID to search for
---@return table[] Array of {x, y, province}
function WorldMap:getProvincesByRegion(region_id)
    return self:findProvinces(function(x, y, province)
        return province.region_id == region_id
    end)
end

---Iterate over all provinces
---@param fn function Function(x, y, province) called for each province
function WorldMap:forEachProvince(fn)
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local province = self:getProvince(x, y)
            if province then
                fn(x, y, province)
            end
        end
    end
end

---Iterate over rectangle of provinces
---@param x1 number Top-left X
---@param y1 number Top-left Y
---@param x2 number Bottom-right X
---@param y2 number Bottom-right Y
---@param fn function Function(x, y, province) called for each
function WorldMap:forEachProvinceInRect(x1, y1, x2, y2, fn)
    for y = math.max(0, y1), math.min(self.height - 1, y2) do
        for x = math.max(0, x1), math.min(self.width - 1, x2) do
            local province = self:getProvince(x, y)
            if province then
                fn(x, y, province)
            end
        end
    end
end

---Get all provinces
---@return Province[]
function WorldMap:getAllProvinces()
    return self.provinces
end

---Get statistics about the world
---@return table Statistics {total_provinces, by_biome, by_control, avg_elevation}
function WorldMap:getStatistics()
    local stats = {
        total_provinces = self.width * self.height,
        by_biome = {},
        by_control = {},
        avg_elevation = 0,
        total_population = 0,
    }

    local total_elev = 0

    self:forEachProvince(function(x, y, province)
        -- Count biomes
        local biome = province.biome
        stats.by_biome[biome] = (stats.by_biome[biome] or 0) + 1

        -- Count control
        local control = province.control
        stats.by_control[control] = (stats.by_control[control] or 0) + 1

        -- Sum elevation
        total_elev = total_elev + province.elevation

        -- Sum population
        stats.total_population = stats.total_population + (province.population or 0)
    end)

    stats.avg_elevation = total_elev / stats.total_provinces

    return stats
end

---Debug: Print world information
function WorldMap:debug()
    local stats = self:getStatistics()
    print("\n[WorldMap] Debug Information:")
    print(string.format("  Size: %dx%d (%d total provinces)",
        self.width, self.height, stats.total_provinces))
    print(string.format("  Avg Elevation: %.2f", stats.avg_elevation))
    print(string.format("  Population: %d", stats.total_population))
    print("  Biome Distribution:")
    for biome, count in pairs(stats.by_biome) do
        local pct = (count / stats.total_provinces) * 100
        print(string.format("    %s: %d (%.1f%%)", biome, count, pct))
    end
    print("  Control Distribution:")
    for control, count in pairs(stats.by_control) do
        local pct = (count / stats.total_provinces) * 100
        print(string.format("    %s: %d (%.1f%%)", control, count, pct))
    end
end

return WorldMap
