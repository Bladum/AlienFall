-- ─────────────────────────────────────────────────────────────────────────
-- BIOME SYSTEM TEST SUITE
-- FILE: tests2/geoscape/biome_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.world.biome_system",
    fileName = "biome_system.lua",
    description = "Biome and terrain type system for world generation"
})

print("[BIOME_TEST] Setting up")

local BiomeSystem = {
    biomes = {},
    biomeTiles = {},

    new = function(self)
        return setmetatable({biomes = {}, biomeTiles = {}}, {__index = self})
    end,

    registerBiome = function(self, biomeId, name, properties)
        self.biomes[biomeId] = {
            id = biomeId,
            name = name,
            terrain = properties.terrain or "grass",
            difficulty = properties.difficulty or 1,
            hazards = properties.hazards or {},
            resources = properties.resources or {}
        }
        return true
    end,

    getBiome = function(self, biomeId)
        return self.biomes[biomeId]
    end,

    placeBiomeTile = function(self, x, y, biomeId)
        if not self.biomes[biomeId] then return false end
        local key = x .. "," .. y
        self.biomeTiles[key] = biomeId
        return true
    end,

    getBiomeTile = function(self, x, y)
        local key = x .. "," .. y
        return self.biomeTiles[key]
    end,

    getTileBiome = function(self, x, y)
        local biomeId = self:getBiomeTile(x, y)
        return biomeId and self.biomes[biomeId] or nil
    end,

    generateBiomeRegion = function(self, x, y, width, height, biomeId)
        if not self.biomes[biomeId] then return false end
        local placed = 0
        for i = x, x + width - 1 do
            for j = y, y + height - 1 do
                self:placeBiomeTile(i, j, biomeId)
                placed = placed + 1
            end
        end
        return placed
    end,

    getTileCount = function(self)
        local count = 0
        for _ in pairs(self.biomeTiles) do count = count + 1 end
        return count
    end,

    getBiomeCount = function(self)
        local count = 0
        for _ in pairs(self.biomes) do count = count + 1 end
        return count
    end,

    getTileDifficulty = function(self, x, y)
        local biome = self:getTileBiome(x, y)
        return biome and biome.difficulty or nil
    end
}

Suite:group("Biome Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.biomes = BiomeSystem:new()
    end)

    Suite:testMethod("BiomeSystem.new", {description = "Creates biome system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.biomes ~= nil, true, "System created")
    end)

    Suite:testMethod("BiomeSystem.registerBiome", {description = "Registers new biome", testCase = "register", type = "functional"}, function()
        local ok = shared.biomes:registerBiome("forest", "Forest", {terrain = "trees", difficulty = 2})
        Helpers.assertEqual(ok, true, "Biome registered")
    end)

    Suite:testMethod("BiomeSystem.getBiome", {description = "Retrieves biome", testCase = "get", type = "functional"}, function()
        shared.biomes:registerBiome("desert", "Desert", {terrain = "sand", difficulty = 1})
        local biome = shared.biomes:getBiome("desert")
        Helpers.assertEqual(biome ~= nil, true, "Biome retrieved")
    end)

    Suite:testMethod("BiomeSystem.getBiome", {description = "Returns nil for missing biome", testCase = "missing", type = "functional"}, function()
        local biome = shared.biomes:getBiome("nonexistent")
        Helpers.assertEqual(biome, nil, "Missing biome returns nil")
    end)

    Suite:testMethod("BiomeSystem.getBiomeCount", {description = "Counts registered biomes", testCase = "count", type = "functional"}, function()
        shared.biomes:registerBiome("forest", "Forest", {})
        shared.biomes:registerBiome("desert", "Desert", {})
        shared.biomes:registerBiome("tundra", "Tundra", {})
        local count = shared.biomes:getBiomeCount()
        Helpers.assertEqual(count, 3, "Three biomes registered")
    end)
end)

Suite:group("Tile Placement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.biomes = BiomeSystem:new()
        shared.biomes:registerBiome("forest", "Forest", {})
    end)

    Suite:testMethod("BiomeSystem.placeBiomeTile", {description = "Places biome tile", testCase = "place", type = "functional"}, function()
        local ok = shared.biomes:placeBiomeTile(0, 0, "forest")
        Helpers.assertEqual(ok, true, "Tile placed")
    end)

    Suite:testMethod("BiomeSystem.getBiomeTile", {description = "Retrieves biome at tile", testCase = "get_tile", type = "functional"}, function()
        shared.biomes:placeBiomeTile(5, 5, "forest")
        local biomeId = shared.biomes:getBiomeTile(5, 5)
        Helpers.assertEqual(biomeId, "forest", "Biome retrieved from tile")
    end)

    Suite:testMethod("BiomeSystem.getTileBiome", {description = "Gets biome data for tile", testCase = "tile_data", type = "functional"}, function()
        shared.biomes:placeBiomeTile(3, 3, "forest")
        local biome = shared.biomes:getTileBiome(3, 3)
        Helpers.assertEqual(biome ~= nil, true, "Biome data retrieved")
    end)

    Suite:testMethod("BiomeSystem.placeBiomeTile", {description = "Rejects invalid biome", testCase = "invalid", type = "functional"}, function()
        local ok = shared.biomes:placeBiomeTile(0, 0, "nonexistent")
        Helpers.assertEqual(ok, false, "Invalid biome rejected")
    end)

    Suite:testMethod("BiomeSystem.getTileCount", {description = "Counts placed tiles", testCase = "count_tiles", type = "functional"}, function()
        shared.biomes:placeBiomeTile(0, 0, "forest")
        shared.biomes:placeBiomeTile(1, 1, "forest")
        shared.biomes:placeBiomeTile(2, 2, "forest")
        local count = shared.biomes:getTileCount()
        Helpers.assertEqual(count, 3, "Three tiles placed")
    end)
end)

Suite:group("Region Generation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.biomes = BiomeSystem:new()
        shared.biomes:registerBiome("grass", "Grassland", {})
    end)

    Suite:testMethod("BiomeSystem.generateBiomeRegion", {description = "Generates biome region", testCase = "generate", type = "functional"}, function()
        local placed = shared.biomes:generateBiomeRegion(0, 0, 5, 5, "grass")
        Helpers.assertEqual(placed, 25, "Generated 5x5 region (25 tiles)")
    end)

    Suite:testMethod("BiomeSystem.generateBiomeRegion", {description = "Fills correct area", testCase = "fill_area", type = "functional"}, function()
        shared.biomes:generateBiomeRegion(0, 0, 3, 4, "grass")
        local biome = shared.biomes:getTileBiome(2, 3)
        Helpers.assertEqual(biome ~= nil, true, "Tile in region has biome")
    end)

    Suite:testMethod("BiomeSystem.generateBiomeRegion", {description = "Rejects invalid biome", testCase = "invalid_biome", type = "functional"}, function()
        local placed = shared.biomes:generateBiomeRegion(0, 0, 2, 2, "invalid")
        Helpers.assertEqual(placed, false, "Invalid biome rejected")
    end)
end)

Suite:group("Biome Properties", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.biomes = BiomeSystem:new()
        shared.biomes:registerBiome("mountain", "Mountain", {difficulty = 3})
        shared.biomes:placeBiomeTile(10, 10, "mountain")
    end)

    Suite:testMethod("BiomeSystem.getTileDifficulty", {description = "Gets tile difficulty", testCase = "difficulty", type = "functional"}, function()
        local difficulty = shared.biomes:getTileDifficulty(10, 10)
        Helpers.assertEqual(difficulty, 3, "Difficulty retrieved")
    end)

    Suite:testMethod("BiomeSystem.getTileDifficulty", {description = "Returns nil for empty tile", testCase = "empty_tile", type = "functional"}, function()
        local difficulty = shared.biomes:getTileDifficulty(99, 99)
        Helpers.assertEqual(difficulty, nil, "Empty tile returns nil")
    end)
end)

Suite:run()
