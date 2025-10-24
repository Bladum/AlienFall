---@class GeoMap
---Wrapper that orchestrates entire world generation pipeline
---Coordinates: ProceduralGenerator -> LocationSystem -> Playable World
local GeoMap = {}

local ProceduralGenerator = require("engine.geoscape.world.procedural_generator")
local LocationSystem = require("engine.geoscape.world.location_system")

---Create and generate a complete world
---@param seed number Generation seed
---@param difficulty string Game difficulty
---@param width number Map width (default: 80)
---@param height number Map height (default: 40)
---@param region_count number Target regions (default: 18)
---@return table Complete game world
function GeoMap.new(seed, difficulty, width, height, region_count)
    width = width or 80
    height = height or 40
    region_count = region_count or 18
    difficulty = difficulty or "normal"

    local total_start = os.clock()

    print("\n" .. string.rep("=", 70))
    print("GEOSCAPE WORLD GENERATION")
    print(string.rep("=", 70))
    print(string.format("Seed: %d | Difficulty: %s | Size: %dx%d",
        seed, difficulty, width, height))
    print(string.rep("=", 70) .. "\n")

    -- Step 1: Generate procedural world
    print("[GeoMap] Phase 1: Procedural Generation")
    local generator = ProceduralGenerator.new(seed, difficulty)
    local gen_result = generator:generate(width, height)
    local world = gen_result.world

    -- Step 2: Generate locations (regions, capitals, cities)
    print("\n[GeoMap] Phase 2: Location Generation")
    local location_system = LocationSystem.new(world, seed)
    location_system:generateLocations(region_count)

    -- Step 3: Initialize player state
    print("\n[GeoMap] Phase 3: Initializing Player State")
    local player_region = 1
    local player_province = world:getProvince(0, 0)
    if player_province then
        player_province.region_id = player_region
        player_province.control = "player"
    end

    -- Step 4: Set up time system
    print("[GeoMap] Phase 4: Initializing Time System")
    local time_system = {
        turn = 0,
        year = 2026,
        month = 1,
        day = 1,
        hour = 6,
    }

    local total_time = (os.clock() - total_start) * 1000

    print("\n" .. string.rep("=", 70))
    print(string.format("GENERATION COMPLETE: %.2fms", total_time))
    print(string.rep("=", 70))

    if total_time > 100 then
        print("WARNING: Generation time exceeded 100ms target!")
    end

    -- Create game state
    local geomap = {
        world = world,
        locations = location_system,
        generator = generator,
        time = time_system,
        player_region = player_region,
        player_bases = {},  -- Will be populated from basescape

        -- Statistics
        stats = {
            generation_time_ms = total_time,
            seed = seed,
            difficulty = difficulty,
            width = width,
            height = height,
            region_count = region_count,
        },
    }

    return setmetatable(geomap, {__index = GeoMap})
end

---Advance game time by one turn
function GeoMap:advanceTurn()
    self.time.turn = self.time.turn + 1

    -- Advance day
    self.time.day = self.time.day + 1

    -- Handle month/year rollover
    local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local month_days = days_in_month[self.time.month]

    if self.time.year % 4 == 0 then
        month_days = 29
    end

    if self.time.day > month_days then
        self.time.day = 1
        self.time.month = self.time.month + 1

        if self.time.month > 12 then
            self.time.month = 1
            self.time.year = self.time.year + 1
        end
    end

    return self.time.turn
end

---Get current game time as formatted string
---@return string Date string (e.g., "January 15, 2026")
function GeoMap:getDateString()
    local months = {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    }

    return string.format("%s %d, %d",
        months[self.time.month], self.time.day, self.time.year)
end

---Get current season
---@return string Season name
function GeoMap:getSeason()
    if self.time.month >= 3 and self.time.month <= 5 then
        return "spring"
    elseif self.time.month >= 6 and self.time.month <= 8 then
        return "summer"
    elseif self.time.month >= 9 and self.time.month <= 11 then
        return "autumn"
    else
        return "winter"
    end
end

---Get world statistics
---@return table Statistics
function GeoMap:getStatistics()
    return self.world:getStatistics()
end

---Save world to file
---@param filename string Save file path
---@return boolean Success
function GeoMap:save(filename)
    -- Placeholder for save system
    print(string.format("[GeoMap] Saving to %s", filename))
    return true
end

---Load world from file
---@param filename string Load file path
---@return GeoMap
function GeoMap:load(filename)
    -- Placeholder for load system
    print(string.format("[GeoMap] Loading from %s", filename))
    return self
end

---Debug: Print detailed world information
function GeoMap:debug()
    print("\n" .. string.rep("=", 70))
    print("GEOMAP DEBUG INFORMATION")
    print(string.rep("=", 70))

    print("\nWorld Statistics:")
    local stats = self:getStatistics()
    print(string.format("  Total Provinces: %d", stats.total_provinces))
    print(string.format("  Avg Elevation: %.2f", stats.avg_elevation))
    print(string.format("  Total Population: %d", stats.total_population))

    print("\nBiome Distribution:")
    for biome, count in pairs(stats.by_biome) do
        local pct = (count / stats.total_provinces) * 100
        print(string.format("  %s: %d (%.1f%%)", biome, count, pct))
    end

    print("\nControl Distribution:")
    for control, count in pairs(stats.by_control) do
        local pct = (count / stats.total_provinces) * 100
        print(string.format("  %s: %d (%.1f%%)", control, count, pct))
    end

    print("\nGeneration Stats:")
    for key, value in pairs(self.stats) do
        if type(value) == "number" then
            if string.find(key, "time") then
                print(string.format("  %s: %.2fms", key, value))
            else
                print(string.format("  %s: %d", key, value))
            end
        else
            print(string.format("  %s: %s", key, tostring(value)))
        end
    end

    print("\nCurrent Time:")
    print(string.format("  Date: %s", self:getDateString()))
    print(string.format("  Season: %s", self:getSeason()))
    print(string.format("  Turn: %d", self.time.turn))

    print(string.rep("=", 70) .. "\n")
end

return GeoMap
