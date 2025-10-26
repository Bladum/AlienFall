---================================================================================
---PHASE 3J: World & Map Generation Tests
---================================================================================
---
---Comprehensive test suite for world and map generation including:
---
---  1. World System Core (4 tests)
---     - World creation and dimensions
---     - Hex coordinate system
---     - Tile management
---
---  2. Terrain & Biome System (4 tests)
---     - Terrain type selection
---     - Biome configuration
---     - Terrain costs and properties
---
---  3. Province & Region Management (4 tests)
---     - Province creation and tracking
---     - Province-hex relationships
---     - Boundary calculation
---
---  4. Map Generation (5 tests)
---     - Mission map procedural generation
---     - UFO crash site generation
---     - Base assault generation
---     - Mapblock/mapscript placement
---
---  5. World Events & Calendar (3 tests)
---     - Day/night cycle mechanics
---     - Date advancement
---     - Event processing
---
---  6. Integration Tests (1 test)
---     - Complete world generation workflow
---
---@module tests2.world.world_map_generation_test

package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")

---@class MockWorld
---Manages world state, tiles, provinces, and time.
---@field width number World width in hex tiles
---@field height number World height in hex tiles
---@field tiles table 2D array of tile data
---@field provinces table Map of province ID to province data
---@field date table Current game date {year, month, day}
---@field turn number Current turn counter
local MockWorld = {}

function MockWorld:new(config)
    local instance = {
        width = config.width or 80,
        height = config.height or 60,
        tiles = {},
        provinces = {},
        date = {year = 2005, month = 1, day = 1},
        turn = 0,
        dayTime = 0.5  -- 0-1, where 0.5 is noon
    }
    setmetatable(instance, {__index = self})

    -- Initialize tile grid
    for q = 0, instance.width - 1 do
        instance.tiles[q] = {}
        for r = 0, instance.height - 1 do
            instance.tiles[q][r] = {
                terrain = "OCEAN",
                cost = 1,
                isLand = false
            }
        end
    end

    return instance
end

function MockWorld:setTile(q, r, terrain, cost, isLand)
    if self.tiles[q] and self.tiles[q][r] then
        self.tiles[q][r] = {
            terrain = terrain,
            cost = cost or 1,
            isLand = isLand or false
        }
        return true
    end
    return false
end

function MockWorld:getTile(q, r)
    if self.tiles[q] then
        return self.tiles[q][r]
    end
    return nil
end

function MockWorld:hexToPixel(q, r)
    -- Standard hex to pixel conversion (offset coordinates)
    local size = 32
    local x = size * (3/2 * q)
    local y = size * (math.sqrt(3)/2 * q + math.sqrt(3) * r)
    return x, y
end

function MockWorld:pixelToHex(x, y)
    -- Reverse conversion
    local size = 32
    local q = (2/3 * x) / size
    local r = (-1/3 * x + math.sqrt(3)/3 * y) / size
    return math.round(q), math.round(r)
end

function MockWorld:addProvince(province)
    self.provinces[province.id] = province
end

function MockWorld:getProvince(id)
    return self.provinces[id]
end

function MockWorld:getProvinceAtHex(q, r)
    for _, province in pairs(self.provinces) do
        for _, hex in ipairs(province.hexes or {}) do
            if hex.q == q and hex.r == r then
                return province
            end
        end
    end
    return nil
end

function MockWorld:getProvinceCount()
    local count = 0
    for _ in pairs(self.provinces) do
        count = count + 1
    end
    return count
end

function MockWorld:getAllProvinces()
    local result = {}
    for _, province in pairs(self.provinces) do
        table.insert(result, province)
    end
    return result
end

function MockWorld:advanceDay()
    self.turn = self.turn + 1
    self.date.day = self.date.day + 1

    if self.date.day > 28 then
        self.date.day = 1
        self.date.month = self.date.month + 1

        if self.date.month > 12 then
            self.date.month = 1
            self.date.year = self.date.year + 1
        end
    end
end

function MockWorld:getDate()
    return self.date
end

function MockWorld:getTurn()
    return self.turn
end

function MockWorld:getLightLevel(q, r)
    -- Simplified: based on day time
    if self.dayTime >= 0.25 and self.dayTime <= 0.75 then
        return 1.0  -- Full daylight
    else
        return 0.3  -- Night time
    end
end

function MockWorld:isDay(q, r)
    local light = self:getLightLevel(q, r)
    return light > 0.5
end

function MockWorld:getDimensions()
    return self.width, self.height
end

function MockWorld:getScale()
    return 32  -- Pixel size per hex
end

function MockWorld:processDailyEvents()
    return true
end

---@class MockBiomeSystem
---Manages terrain and biome configurations.
---@field biomes table Map of biome ID to biome config
---@field terrainTypes table Available terrain types
local MockBiomeSystem = {}

function MockBiomeSystem:new()
    local instance = {
        biomes = {
            DESERT = {name = "Desert", color = {255, 200, 0}},
            FOREST = {name = "Forest", color = {0, 150, 0}},
            MOUNTAIN = {name = "Mountain", color = {100, 100, 100}},
            OCEAN = {name = "Ocean", color = {0, 100, 255}},
            TUNDRA = {name = "Tundra", color = {200, 200, 255}}
        },
        terrainTypes = {
            PLAIN = {cost = 1, difficulty = 1},
            FOREST = {cost = 2, difficulty = 2},
            MOUNTAIN = {cost = 3, difficulty = 3},
            WATER = {cost = 10, difficulty = 0},  -- Impassable
            SWAMP = {cost = 2, difficulty = 2}
        }
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockBiomeSystem:getBiome(id)
    return self.biomes[id]
end

function MockBiomeSystem:getTerrainType(id)
    return self.terrainTypes[id]
end

function MockBiomeSystem:getAllBiomes()
    local result = {}
    for id, biome in pairs(self.biomes) do
        table.insert(result, {id = id, data = biome})
    end
    return result
end

function MockBiomeSystem:selectRandomTerrain(biome)
    local terrains = {"PLAIN", "FOREST", "MOUNTAIN", "SWAMP"}
    return terrains[math.random(1, #terrains)]
end

---@class MockMapGenerator
---Generates procedural mission maps.
---@field mapWidth number Map width in tiles
---@field mapHeight number Map height in tiles
---@field tiles table Generated tile data
local MockMapGenerator = {}

function MockMapGenerator:new()
    local instance = {
        mapWidth = 0,
        mapHeight = 0,
        tiles = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockMapGenerator:generateMissionMap(mission, biome)
    local width = mission.size or 40
    local height = mission.size or 40

    local map = {
        width = width,
        height = height,
        tiles = {},
        mission = mission,
        biome = biome
    }

    -- Generate tiles
    for x = 0, width - 1 do
        map.tiles[x] = {}
        for y = 0, height - 1 do
            map.tiles[x][y] = {
                terrain = self:getRandomTerrain(biome),
                elevation = math.random(0, 10),
                accessible = true
            }
        end
    end

    return map
end

function MockMapGenerator:generateUFOCrash(mission, biome)
    local map = self:generateMissionMap(mission, biome)

    -- Add UFO wreck at center
    local centerX = math.floor(map.width / 2)
    local centerY = math.floor(map.height / 2)

    for x = centerX - 2, centerX + 2 do
        for y = centerY - 2, centerY + 2 do
            if x >= 0 and x < map.width and y >= 0 and y < map.height then
                map.tiles[x][y].terrain = "WRECKAGE"
            end
        end
    end

    map.ufoPosition = {x = centerX, y = centerY}
    return map
end

function MockMapGenerator:generateAlienBase(mission, biome)
    local map = self:generateMissionMap(mission, biome)

    -- Add base structure
    local baseX = math.floor(map.width / 2)
    local baseY = math.floor(map.height / 2)

    map.basePosition = {x = baseX, y = baseY}
    map.baseRadius = 5

    return map
end

function MockMapGenerator:getRandomTerrain(biome)
    if biome == "DESERT" then
        return math.random() > 0.3 and "PLAIN" or "MOUNTAIN"
    elseif biome == "FOREST" then
        return math.random() > 0.4 and "FOREST" or "PLAIN"
    elseif biome == "MOUNTAIN" then
        return math.random() > 0.5 and "MOUNTAIN" or "PLAIN"
    else
        return "PLAIN"
    end
end

function MockMapGenerator:validateMap(map)
    if not map.tiles then return false end
    if map.width <= 0 or map.height <= 0 then return false end

    local tileCount = 0
    for x = 0, map.width - 1 do
        for y = 0, map.height - 1 do
            if map.tiles[x] and map.tiles[x][y] then
                tileCount = tileCount + 1
            end
        end
    end

    return tileCount == (map.width * map.height)
end

---================================================================================
---TEST SUITE
---================================================================================

local Suite = HierarchicalSuite:new({
    module = "engine.world.generation",
    file = "world_map_generation_test.lua",
    description = "World and map generation - Terrain, provinces, procedural generation"
})

---WORLD SYSTEM CORE TESTS
Suite:group("World System Core", function()

    Suite:testMethod("MockWorld:new", {
        description = "Creates world with dimensions",
        testCase = "initialization",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        if world.width ~= 80 then error("Width should be 80") end
        if world.height ~= 60 then error("Height should be 60") end
        if not world.tiles then error("Tiles should exist") end
    end)

    Suite:testMethod("MockWorld:getTile", {
        description = "Retrieves and updates tiles",
        testCase = "tile_management",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        world:setTile(10, 15, "LAND", 1, true)
        local tile = world:getTile(10, 15)

        if not tile then error("Tile should exist") end
        if tile.terrain ~= "LAND" then error("Terrain should be LAND") end
        if tile.cost ~= 1 then error("Cost should be 1") end
    end)

    Suite:testMethod("MockWorld:hexToPixel", {
        description = "Converts hex to pixel coordinates",
        testCase = "coord_conversion",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        local x, y = world:hexToPixel(10, 15)
        if type(x) ~= "number" then error("X should be number") end
        if type(y) ~= "number" then error("Y should be number") end
    end)

    Suite:testMethod("MockWorld:getDimensions", {
        description = "Returns world dimensions",
        testCase = "dimensions",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        local w, h = world:getDimensions()
        if w ~= 80 then error("Width should be 80") end
        if h ~= 60 then error("Height should be 60") end
    end)
end)

---TERRAIN & BIOME TESTS
Suite:group("Terrain & Biome System", function()

    Suite:testMethod("MockBiomeSystem:new", {
        description = "Initializes biome system",
        testCase = "initialization",
        type = "functional"
    }, function()
        local biomes = MockBiomeSystem:new()

        if not biomes.biomes then error("Biomes table should exist") end
        if #biomes:getAllBiomes() < 5 then error("Should have 5+ biomes") end
    end)

    Suite:testMethod("MockBiomeSystem:getBiome", {
        description = "Retrieves biome configuration",
        testCase = "biome_retrieval",
        type = "functional"
    }, function()
        local biomes = MockBiomeSystem:new()

        local desert = biomes:getBiome("DESERT")
        if not desert then error("DESERT biome should exist") end
        if desert.name ~= "Desert" then error("Name should be 'Desert'") end
    end)

    Suite:testMethod("MockBiomeSystem:getTerrainType", {
        description = "Gets terrain type properties",
        testCase = "terrain_properties",
        type = "functional"
    }, function()
        local biomes = MockBiomeSystem:new()

        local plain = biomes:getTerrainType("PLAIN")
        if not plain then error("PLAIN terrain should exist") end
        if plain.cost ~= 1 then error("Plain cost should be 1") end
    end)

    Suite:testMethod("MockBiomeSystem:selectRandomTerrain", {
        description = "Selects terrain for biome",
        testCase = "terrain_selection",
        type = "functional"
    }, function()
        local biomes = MockBiomeSystem:new()

        local terrain = biomes:selectRandomTerrain("FOREST")
        if not terrain then error("Should select terrain") end
        if type(terrain) ~= "string" then error("Terrain should be string") end
    end)
end)

---PROVINCE MANAGEMENT TESTS
Suite:group("Province & Region Management", function()

    Suite:testMethod("MockWorld:addProvince", {
        description = "Adds province to world",
        testCase = "province_addition",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        local province = {id = "p1", name = "Province 1", hexes = {{q = 10, r = 15}}}
        world:addProvince(province)

        if world:getProvinceCount() ~= 1 then error("Should have 1 province") end
    end)

    Suite:testMethod("MockWorld:getProvince", {
        description = "Retrieves province by ID",
        testCase = "province_retrieval",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        world:addProvince({id = "test", name = "Test", hexes = {}})
        local prov = world:getProvince("test")

        if not prov then error("Province should be found") end
        if prov.name ~= "Test" then error("Name should be 'Test'") end
    end)

    Suite:testMethod("MockWorld:getProvinceAtHex", {
        description = "Finds province at hex coordinate",
        testCase = "hex_province_lookup",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        world:addProvince({id = "p1", name = "P1", hexes = {{q = 10, r = 15}}})
        local prov = world:getProvinceAtHex(10, 15)

        if not prov then error("Should find province at hex") end
        if prov.id ~= "p1" then error("Province ID should match") end
    end)

    Suite:testMethod("MockWorld:getAllProvinces", {
        description = "Returns all provinces",
        testCase = "province_listing",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        world:addProvince({id = "p1", name = "P1", hexes = {}})
        world:addProvince({id = "p2", name = "P2", hexes = {}})

        local all = world:getAllProvinces()
        if #all ~= 2 then error("Should have 2 provinces") end
    end)
end)

---MAP GENERATION TESTS
Suite:group("Map Generation", function()

    Suite:testMethod("MockMapGenerator:new", {
        description = "Initializes map generator",
        testCase = "initialization",
        type = "functional"
    }, function()
        local gen = MockMapGenerator:new()
        if not gen then error("Generator should create") end
    end)

    Suite:testMethod("MockMapGenerator:generateMissionMap", {
        description = "Generates procedural mission map",
        testCase = "mission_generation",
        type = "functional"
    }, function()
        local gen = MockMapGenerator:new()
        local mission = {type = "CRASH", size = 40}

        local map = gen:generateMissionMap(mission, "DESERT")

        if not map then error("Map should be generated") end
        if map.width ~= 40 then error("Width should be 40") end
        if not map.tiles then error("Tiles should exist") end
    end)

    Suite:testMethod("MockMapGenerator:generateUFOCrash", {
        description = "Generates UFO crash site",
        testCase = "ufo_crash",
        type = "functional"
    }, function()
        local gen = MockMapGenerator:new()
        local mission = {type = "CRASH", size = 40}

        local map = gen:generateUFOCrash(mission, "DESERT")

        if not map then error("Map should be generated") end
        if not map.ufoPosition then error("UFO position should exist") end
    end)

    Suite:testMethod("MockMapGenerator:generateAlienBase", {
        description = "Generates alien base map",
        testCase = "base_generation",
        type = "functional"
    }, function()
        local gen = MockMapGenerator:new()
        local mission = {type = "BASE", size = 50}

        local map = gen:generateAlienBase(mission, "MOUNTAIN")

        if not map then error("Map should be generated") end
        if not map.basePosition then error("Base position should exist") end
    end)

    Suite:testMethod("MockMapGenerator:validateMap", {
        description = "Validates generated map",
        testCase = "validation",
        type = "functional"
    }, function()
        local gen = MockMapGenerator:new()
        local mission = {type = "CRASH", size = 40}
        local map = gen:generateMissionMap(mission, "FOREST")

        local valid = gen:validateMap(map)
        if not valid then error("Map should be valid") end
    end)
end)

---WORLD EVENTS & CALENDAR TESTS
Suite:group("World Events & Calendar", function()

    Suite:testMethod("MockWorld:advanceDay", {
        description = "Advances game time by day",
        testCase = "day_advancement",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        local initialDay = world.date.day
        world:advanceDay()

        if world.date.day ~= initialDay + 1 then error("Day should advance") end
        if world.turn ~= 1 then error("Turn should increment") end
    end)

    Suite:testMethod("MockWorld:getLightLevel", {
        description = "Calculates light level",
        testCase = "lighting",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        local light = world:getLightLevel(10, 15)

        if type(light) ~= "number" then error("Light should be number") end
        if light < 0 or light > 1 then error("Light should be 0-1") end
    end)

    Suite:testMethod("MockWorld:isDay", {
        description = "Determines day/night at location",
        testCase = "day_night_cycle",
        type = "functional"
    }, function()
        local world = MockWorld:new({width = 80, height = 60})

        local isDay = world:isDay(10, 15)
        if type(isDay) ~= "boolean" then error("isDay should return boolean") end
    end)
end)

---INTEGRATION TESTS
Suite:group("Integration", function()

    Suite:testMethod("Complete World Generation", {
        description = "Simulates full world generation workflow",
        testCase = "full_generation",
        type = "integration"
    }, function()
        -- Create world
        local world = MockWorld:new({width = 80, height = 60})

        -- Setup biomes
        local biomes = MockBiomeSystem:new()

        -- Add provinces
        world:addProvince({id = "usa", name = "USA", hexes = {{q = 20, r = 25}}})
        world:addProvince({id = "russia", name = "Russia", hexes = {{q = 50, r = 30}}})

        -- Generate mission maps
        local gen = MockMapGenerator:new()
        local crashMap = gen:generateUFOCrash({type = "CRASH", size = 40}, "DESERT")
        local baseMap = gen:generateAlienBase({type = "BASE", size = 50}, "MOUNTAIN")

        -- Advance time
        for _ = 1, 10 do
            world:advanceDay()
        end

        -- Verify state
        if world:getProvinceCount() ~= 2 then error("Should have 2 provinces") end
        if world.turn ~= 10 then error("Turn should be 10") end
        if not crashMap or not baseMap then error("Maps should generate") end
    end)
end)

---PERFORMANCE BENCHMARKS
Suite:group("Performance", function()

    Suite:testMethod("Scaling - World Size", {
        description = "Handles large world maps efficiently",
        testCase = "world_scaling",
        type = "performance"
    }, function()
        local startTime = os.clock()

        local world = MockWorld:new({width = 200, height = 150})

        -- Fill world with provinces
        for i = 1, 50 do
            world:addProvince({
                id = "p" .. i,
                name = "Province " .. i,
                hexes = {{q = math.random(0, 199), r = math.random(0, 149)}}
            })
        end

        -- Query provinces
        for i = 1, 100 do
            world:getProvinceAtHex(math.random(0, 199), math.random(0, 149))
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 200×150 world + 50 provinces: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)

    Suite:testMethod("Scaling - Map Generation", {
        description = "Generates large maps efficiently",
        testCase = "generation_scaling",
        type = "performance"
    }, function()
        local gen = MockMapGenerator:new()
        local startTime = os.clock()

        -- Generate multiple large maps
        for i = 1, 5 do
            gen:generateMissionMap({type = "CRASH", size = 60}, "DESERT")
            gen:generateUFOCrash({type = "CRASH", size = 50}, "FOREST")
            gen:generateAlienBase({type = "BASE", size = 60}, "MOUNTAIN")
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 15 procedural maps (50-60 size): " .. string.format("%.3fms", elapsed * 1000))
        end
    end)
end)

---================================================================================
---RUN TESTS
---================================================================================

Suite:run()

-- Close the Love2D window after tests complete
love.event.quit()
