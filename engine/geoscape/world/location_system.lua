---@class LocationSystem
---Places regions, capitals, and cities on the generated world
---Uses flood fill and constraint satisfaction
local LocationSystem = {}

---Region name seeds (deterministic generation)
local REGION_NAMES = {
    "North America", "South America", "Europe", "Africa", "Asia",
    "Australia", "Russia", "China", "India", "Brazil",
    "United States", "Japan", "Germany", "France", "UK",
}

---City name seeds
local CITY_NAMES = {
    "New York", "Los Angeles", "Chicago", "Houston", "Phoenix",
    "London", "Paris", "Berlin", "Madrid", "Rome",
    "Tokyo", "Beijing", "Shanghai", "Mumbai", "Delhi",
    "Sydney", "Melbourne", "Toronto", "Vancouver", "Mexico City",
}

---Create new location system
---@param world table Generated world
---@param seed number Generation seed
---@return LocationSystem
function LocationSystem.new(world, seed)
    return setmetatable({
        world = world,
        seed = seed,
        regions = {},
        cities = {},
        capital_map = {},  -- {x, y} -> region_id
    }, {__index = LocationSystem})
end

---Identify urban zones by clustering urban biomes
---@return table[] Array of {x, y, size}
function LocationSystem:identifyUrbanZones()
    local urban_map = {}  -- Mark urban provinces
    local width = self.world.width
    local height = self.world.height

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local province = self.world:getProvince(x, y)
            local idx = y * width + x + 1

            if province and province.biome == "urban" then
                urban_map[idx] = true
            end
        end
    end

    -- Find connected components (urban clusters)
    local visited = {}
    local zones = {}

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local idx = y * width + x + 1

            if urban_map[idx] and not visited[idx] then
                -- Start flood fill from this urban province
                local zone = {x = x, y = y, size = 0, provinces = {}}
                local queue = {{x = x, y = y}}

                while #queue > 0 do
                    local current = table.remove(queue, 1)
                    local cidx = current.y * width + current.x + 1

                    if visited[cidx] then
                        -- Already processed
                    else
                        visited[cidx] = true
                        zone.size = zone.size + 1
                        table.insert(zone.provinces, {x = current.x, y = current.y})

                        -- Add neighbors
                        for dy = -1, 1 do
                            for dx = -1, 1 do
                                if dx == 0 and dy == 0 then
                                    -- Skip self
                                else
                                    local nx = current.x + dx
                                    local ny = current.y + dy
                                    local nidx = ny * width + nx + 1

                                    if nx >= 0 and nx < width and ny >= 0 and ny < height then
                                        if urban_map[nidx] and not visited[nidx] then
                                            table.insert(queue, {x = nx, y = ny})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if zone.size > 0 then
                    table.insert(zones, zone)
                end
            end
        end
    end

    print(string.format("[LocationSystem] Identified %d urban zones", #zones))

    return zones
end

---Select region capitals from urban zones
---@param zone_count number Desired number of regions (15-20)
---@return table[] Capital locations
function LocationSystem:selectCapitals(zone_count)
    local zones = self:identifyUrbanZones()
    local capitals = {}

    math.randomseed(self.seed + 5000)

    -- Sort zones by size (largest first)
    table.sort(zones, function(a, b) return a.size > b.size end)

    -- Select capitals from largest zones
    local selected = math.min(zone_count, #zones)
    for i = 1, selected do
        local zone = zones[i]

        -- Find center of zone
        local cx = 0
        local cy = 0
        for _, prov in ipairs(zone.provinces) do
            cx = cx + prov.x
            cy = cy + prov.y
        end
        cx = math.floor(cx / zone.size)
        cy = math.floor(cy / zone.size)

        table.insert(capitals, {
            region_id = i,
            x = cx,
            y = cy,
            zone = zone,
        })
    end

    print(string.format("[LocationSystem] Selected %d capitals", #capitals))

    return capitals
end

---Expand regions from capitals via flood fill
---@param capitals table[] Capital locations
---@return table[] Expanded regions
function LocationSystem:expandRegions(capitals)
    local width = self.world.width
    local height = self.world.height
    local regions = {}
    local control_map = {}  -- Track which region owns each province

    -- Initialize control map
    for i = 1, width * height do
        control_map[i] = 0
    end

    -- Mark capitals
    for _, capital in ipairs(capitals) do
        local idx = capital.y * width + capital.x + 1
        control_map[idx] = capital.region_id

        regions[capital.region_id] = {
            region_id = capital.region_id,
            capital_x = capital.x,
            capital_y = capital.y,
            provinces = {},
        }

        table.insert(regions[capital.region_id].provinces, {x = capital.x, y = capital.y})
    end

    -- Flood fill from capitals to expand regions
    local queue = {}

    -- Initialize queue with neighbors of capitals
    for _, capital in ipairs(capitals) do
        for dy = -1, 1 do
            for dx = -1, 1 do
                if dx == 0 and dy == 0 then
                    -- Skip self
                else
                    local nx = capital.x + dx
                    local ny = capital.y + dy

                    if nx >= 0 and nx < width and ny >= 0 and ny < height then
                        local nidx = ny * width + nx + 1
                        if control_map[nidx] == 0 then
                            table.insert(queue, {
                                x = nx,
                                y = ny,
                                from_region = capital.region_id,
                            })
                        end
                    end
                end
            end
        end
    end

    -- Process flood fill
    while #queue > 0 do
        local current = table.remove(queue, 1)
        local idx = current.y * width + current.x + 1

        -- Only claim unclaimed provinces
        if control_map[idx] == 0 then
            control_map[idx] = current.from_region

            if regions[current.from_region] then
                table.insert(regions[current.from_region].provinces,
                    {x = current.x, y = current.y})
            end

            -- Add neighbors to queue
            for dy = -1, 1 do
                for dx = -1, 1 do
                    if dx == 0 and dy == 0 then
                        -- Skip self
                    else
                        local nx = current.x + dx
                        local ny = current.y + dy

                        if nx >= 0 and nx < width and ny >= 0 and ny < height then
                            local nidx = ny * width + nx + 1
                            if control_map[nidx] == 0 then
                                table.insert(queue, {
                                    x = nx,
                                    y = ny,
                                    from_region = current.from_region,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    -- Apply control to world
    for region_id, region in pairs(regions) do
        for _, prov in ipairs(region.provinces) do
            local province = self.world:getProvince(prov.x, prov.y)
            if province then
                province.region_id = region_id
            end
        end
    end

    print(string.format("[LocationSystem] Expanded %d regions", #regions))

    return regions
end

---Place cities in regions
---@param regions table[] Expanded regions
function LocationSystem:placeCities(regions)
    math.randomseed(self.seed + 6000)

    local width = self.world.width
    local height = self.world.height

    for region_id, region in pairs(regions) do
        -- Place capital city
        local capital = self.world:getProvince(region.capital_x, region.capital_y)
        if capital then
            capital.has_city = true
            table.insert(capital.cities, {
                name = self:generateCityName(region_id, true),
                population = 1000000 + math.floor(math.random() * 4000000),
                is_capital = true,
                region_id = region_id,
            })
        end

        -- Place secondary cities (5-10 per region)
        local city_count = 5 + math.floor(math.random() * 6)
        local attempts = 0

        for i = 1, city_count do
            attempts = attempts + 1
            if attempts > city_count * 10 then
                break  -- Give up if can't place
            end

            -- Pick random province from region
            if #region.provinces > 0 then
                local prov_idx = math.floor(math.random() * #region.provinces) + 1
                local prov_data = region.provinces[prov_idx]
                local province = self.world:getProvince(prov_data.x, prov_data.y)

                if province and province.biome ~= "water" and not province.has_city then
                    -- Check minimum distance from capital
                    local dx = province.x - region.capital_x
                    local dy = province.y - region.capital_y
                    local dist = math.sqrt(dx * dx + dy * dy)

                    if dist > 5 then  -- Minimum 5 tiles from capital
                        province.has_city = true
                        table.insert(province.cities, {
                            name = self:generateCityName(region_id, false),
                            population = 100000 + math.floor(math.random() * 900000),
                            is_capital = false,
                            region_id = region_id,
                        })
                    end
                end
            end
        end
    end

    -- Count total cities
    local total_cities = 0
    self.world:forEachProvince(function(x, y, province)
        total_cities = total_cities + #province.cities
    end)

    print(string.format("[LocationSystem] Placed %d cities", total_cities))
end

---Generate deterministic region/city name
---@param region_id number Region ID
---@param is_capital boolean Is this a capital?
---@return string Generated name
function LocationSystem:generateCityName(region_id, is_capital)
    local name_idx = ((region_id + self.seed) % #REGION_NAMES) + 1

    if is_capital then
        return REGION_NAMES[name_idx]
    else
        local city_idx = ((region_id * 7 + self.seed) % #CITY_NAMES) + 1
        return CITY_NAMES[city_idx]
    end
end

---Main location generation function
---@param region_count number Desired regions (default: 18)
function LocationSystem:generateLocations(region_count)
    region_count = region_count or 18

    print("[LocationSystem] Generating locations...")

    -- Step 1: Identify urban zones
    local zones = self:identifyUrbanZones()

    -- Step 2: Select capitals
    local capitals = self:selectCapitals(region_count)

    -- Step 3: Expand regions
    local regions = self:expandRegions(capitals)

    -- Step 4: Place cities
    self:placeCities(regions)

    self.regions = regions

    print("[LocationSystem] Location generation complete")
end

return LocationSystem
