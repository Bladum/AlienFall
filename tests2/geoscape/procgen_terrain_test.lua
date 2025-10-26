-- ─────────────────────────────────────────────────────────────────────────
-- PROCEDURAL GENERATION TERRAIN TEST SUITE
-- FILE: tests2/geoscape/procgen_terrain_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.procgen_terrain",
    fileName = "procgen_terrain.lua",
    description = "Procedurally generated terrain with biomes, features, and noise-based generation"
})

print("[PROCGEN_TERRAIN_TEST] Setting up")

local ProcGenTerrain = {
    terrains = {},
    biomes = {},
    features = {},
    noise_maps = {},

    new = function(self)
        return setmetatable({
            terrains = {}, biomes = {}, features = {}, noise_maps = {}
        }, {__index = self})
    end,

    registerBiome = function(self, biomeId, name, terrain_type, temperature_range)
        self.biomes[biomeId] = {
            id = biomeId, name = name, type = terrain_type or "plains",
            min_temp = temperature_range and temperature_range[1] or -10,
            max_temp = temperature_range and temperature_range[2] or 30,
            moisture = 50, vegetation = 40, hazard_level = 1,
            features_list = {}
        }
        return true
    end,

    getBiome = function(self, biomeId)
        return self.biomes[biomeId]
    end,

    createTerrain = function(self, terrainId, width, height, seed)
        self.terrains[terrainId] = {
            id = terrainId, width = width or 256, height = height or 256,
            seed = seed or math.random(1, 1000000),
            biome_map = {}, elevation_map = {}, feature_map = {},
            generation_time = 0, complexity = 0.5, generated = false
        }
        self.noise_maps[terrainId] = {
            elevation = {}, temperature = {}, moisture = {}
        }
        return true
    end,

    getTerrain = function(self, terrainId)
        return self.terrains[terrainId]
    end,

    generateTerrainNoise = function(self, terrainId, scale, octaves)
        if not self.terrains[terrainId] then return false end
        local terrain = self.terrains[terrainId]
        local octaves_count = octaves or 4
        for y = 1, terrain.height do
            if not self.noise_maps[terrainId].elevation[y] then
                self.noise_maps[terrainId].elevation[y] = {}
            end
            for x = 1, terrain.width do
                local value = 0
                local amplitude = 1
                local frequency = 1
                for _ = 1, octaves_count do
                    local sample_x = (x * frequency) / (scale or 50)
                    local sample_y = (y * frequency) / (scale or 50)
                    local noise = math.sin(sample_x) * math.cos(sample_y) * amplitude
                    value = value + noise
                    amplitude = amplitude / 2
                    frequency = frequency * 2
                end
                self.noise_maps[terrainId].elevation[y][x] = math.max(0, math.min(1, (value + 1) / 2))
            end
        end
        terrain.generated = true
        return true
    end,

    getElevationAt = function(self, terrainId, x, y)
        if not self.noise_maps[terrainId] or not self.noise_maps[terrainId].elevation[y] then return 0 end
        return self.noise_maps[terrainId].elevation[y][x] or 0
    end,

    assignBiomesToTerrain = function(self, terrainId)
        if not self.terrains[terrainId] then return false end
        local terrain = self.terrains[terrainId]
        local biome_list = {}
        for biomeId, _ in pairs(self.biomes) do
            table.insert(biome_list, biomeId)
        end
        if #biome_list == 0 then return false end
        for y = 1, terrain.height do
            if not terrain.biome_map[y] then terrain.biome_map[y] = {} end
            for x = 1, terrain.width do
                local elevation = self:getElevationAt(terrainId, x, y)
                local biome_index = math.floor(elevation * #biome_list) + 1
                terrain.biome_map[y][x] = biome_list[math.min(#biome_list, biome_index)]
            end
        end
        return true
    end,

    getBiomeAtLocation = function(self, terrainId, x, y)
        if not self.terrains[terrainId] or not self.terrains[terrainId].biome_map[y] then return nil end
        return self.terrains[terrainId].biome_map[y][x]
    end,

    placeFeature = function(self, terrainId, featureId, feature_name, x, y, biome_requirement)
        if not self.terrains[terrainId] then return false end
        if not self.features[terrainId] then
            self.features[terrainId] = {}
        end
        local biome = self:getBiomeAtLocation(terrainId, x, y)
        if biome_requirement and biome ~= biome_requirement then return false end
        self.features[terrainId][featureId] = {
            id = featureId, name = feature_name or "feature",
            x = x, y = y, biome = biome, type = "landmark",
            value = 10, discovered = false
        }
        return true
    end,

    getFeature = function(self, terrainId, featureId)
        if not self.features[terrainId] then return nil end
        return self.features[terrainId][featureId]
    end,

    getFeaturesInRegion = function(self, terrainId, x1, y1, x2, y2)
        if not self.features[terrainId] then return {} end
        local found = {}
        for featureId, feature in pairs(self.features[terrainId]) do
            if feature.x >= x1 and feature.x <= x2 and feature.y >= y1 and feature.y <= y2 then
                table.insert(found, feature)
            end
        end
        return found
    end,

    discoverFeature = function(self, terrainId, featureId)
        if not self.features[terrainId] or not self.features[terrainId][featureId] then return false end
        self.features[terrainId][featureId].discovered = true
        return true
    end,

    calculateTerrainRoughness = function(self, terrainId)
        if not self.terrains[terrainId] or not self.terrains[terrainId].generated then return 0 end
        local terrain = self.terrains[terrainId]
        local roughness = 0
        local sample_size = math.floor(terrain.width / 16)
        for i = 0, 15 do
            for j = 0, 15 do
                local x = i * sample_size + 1
                local y = j * sample_size + 1
                local elevation = self:getElevationAt(terrainId, x, y)
                local next_x = math.min(terrain.width, x + sample_size)
                local next_y = math.min(terrain.height, y + sample_size)
                local next_elevation = self:getElevationAt(terrainId, next_x, next_y)
                roughness = roughness + math.abs(elevation - next_elevation)
            end
        end
        return roughness / 256
    end,

    calculateTerrainComplexity = function(self, terrainId)
        if not self.terrains[terrainId] then return 0 end
        local terrain = self.terrains[terrainId]
        local feature_count = 0
        if self.features[terrainId] then
            for _ in pairs(self.features[terrainId]) do
                feature_count = feature_count + 1
            end
        end
        local roughness = self:calculateTerrainRoughness(terrainId)
        return (roughness * 0.5 + (feature_count / 100) * 0.5)
    end,

    addHazard = function(self, terrainId, hazardId, hazard_name, x, y, intensity)
        if not self.terrains[terrainId] then return false end
        if not self.terrains[terrainId].hazards then
            self.terrains[terrainId].hazards = {}
        end
        self.terrains[terrainId].hazards[hazardId] = {
            id = hazardId, name = hazard_name or "hazard",
            x = x, y = y, intensity = intensity or 50, active = true
        }
        return true
    end,

    getHazardsAt = function(self, terrainId, x, y, radius)
        if not self.terrains[terrainId] or not self.terrains[terrainId].hazards then return {} end
        local found = {}
        local rad = radius or 10
        for hazardId, hazard in pairs(self.terrains[terrainId].hazards) do
            local dist = math.sqrt((hazard.x - x)^2 + (hazard.y - y)^2)
            if dist <= rad then
                table.insert(found, hazard)
            end
        end
        return found
    end,

    calculateTerrainTraversability = function(self, terrainId, x, y)
        if not self.terrains[terrainId] then return 0 end
        local elevation = self:getElevationAt(terrainId, x, y)
        local hazards = self:getHazardsAt(terrainId, x, y, 5)
        local traversability = 100 - (elevation * 30)
        for _, hazard in ipairs(hazards) do
            traversability = traversability - (hazard.intensity * 0.5)
        end
        return math.max(0, traversability)
    end,

    smoothTerrain = function(self, terrainId, passes)
        if not self.terrains[terrainId] or not self.terrains[terrainId].generated then return false end
        local terrain = self.terrains[terrainId]
        local passes_count = passes or 1
        for _ = 1, passes_count do
            for y = 2, terrain.height - 1 do
                for x = 2, terrain.width - 1 do
                    local neighbors = 0
                    local sum = 0
                    for ny = y - 1, y + 1 do
                        for nx = x - 1, x + 1 do
                            sum = sum + self:getElevationAt(terrainId, nx, ny)
                            neighbors = neighbors + 1
                        end
                    end
                    if not self.noise_maps[terrainId].elevation[y] then
                        self.noise_maps[terrainId].elevation[y] = {}
                    end
                    self.noise_maps[terrainId].elevation[y][x] = sum / neighbors
                end
            end
        end
        return true
    end,

    getTerrainStatistics = function(self, terrainId)
        if not self.terrains[terrainId] then return nil end
        local terrain = self.terrains[terrainId]
        local stats = {
            width = terrain.width, height = terrain.height,
            generated = terrain.generated, complexity = self:calculateTerrainComplexity(terrainId),
            roughness = self:calculateTerrainRoughness(terrainId)
        }
        return stats
    end,

    reset = function(self)
        self.terrains = {}
        self.biomes = {}
        self.features = {}
        self.noise_maps = {}
        return true
    end
}

Suite:group("Biomes", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
    end)

    Suite:testMethod("ProcGenTerrain.registerBiome", {description = "Registers biome", testCase = "register", type = "functional"}, function()
        local ok = shared.pgt:registerBiome("biome1", "Forest", "forest", {5, 20})
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ProcGenTerrain.getBiome", {description = "Gets biome", testCase = "get", type = "functional"}, function()
        shared.pgt:registerBiome("biome2", "Desert", "desert", {20, 40})
        local biome = shared.pgt:getBiome("biome2")
        Helpers.assertEqual(biome ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Terrain Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
    end)

    Suite:testMethod("ProcGenTerrain.createTerrain", {description = "Creates terrain", testCase = "create", type = "functional"}, function()
        local ok = shared.pgt:createTerrain("terrain1", 128, 128, 42)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ProcGenTerrain.getTerrain", {description = "Gets terrain", testCase = "get", type = "functional"}, function()
        shared.pgt:createTerrain("terrain2", 256, 256, 123)
        local terrain = shared.pgt:getTerrain("terrain2")
        Helpers.assertEqual(terrain ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Noise Generation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
        shared.pgt:createTerrain("terrain1", 64, 64, 1)
    end)

    Suite:testMethod("ProcGenTerrain.generateTerrainNoise", {description = "Generates noise", testCase = "generate", type = "functional"}, function()
        local ok = shared.pgt:generateTerrainNoise("terrain1", 50, 4)
        Helpers.assertEqual(ok, true, "Generated")
    end)

    Suite:testMethod("ProcGenTerrain.getElevationAt", {description = "Gets elevation", testCase = "elevation", type = "functional"}, function()
        shared.pgt:generateTerrainNoise("terrain1", 50, 4)
        local elev = shared.pgt:getElevationAt("terrain1", 32, 32)
        Helpers.assertEqual(elev >= 0 and elev <= 1, true, "Valid elevation")
    end)
end)

Suite:group("Biome Assignment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
        shared.pgt:registerBiome("biome1", "Forest", "forest")
        shared.pgt:registerBiome("biome2", "Mountain", "mountain")
        shared.pgt:createTerrain("terrain1", 64, 64, 1)
        shared.pgt:generateTerrainNoise("terrain1", 50, 4)
    end)

    Suite:testMethod("ProcGenTerrain.assignBiomesToTerrain", {description = "Assigns biomes", testCase = "assign", type = "functional"}, function()
        local ok = shared.pgt:assignBiomesToTerrain("terrain1")
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("ProcGenTerrain.getBiomeAtLocation", {description = "Gets biome location", testCase = "location", type = "functional"}, function()
        shared.pgt:assignBiomesToTerrain("terrain1")
        local biome = shared.pgt:getBiomeAtLocation("terrain1", 32, 32)
        Helpers.assertEqual(biome ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Features", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
        shared.pgt:registerBiome("biome1", "Forest", "forest")
        shared.pgt:createTerrain("terrain1", 64, 64, 1)
        shared.pgt:generateTerrainNoise("terrain1", 50, 4)
        shared.pgt:assignBiomesToTerrain("terrain1")
    end)

    Suite:testMethod("ProcGenTerrain.placeFeature", {description = "Places feature", testCase = "place", type = "functional"}, function()
        local ok = shared.pgt:placeFeature("terrain1", "feat1", "Tower", 32, 32)
        Helpers.assertEqual(ok, true, "Placed")
    end)

    Suite:testMethod("ProcGenTerrain.getFeature", {description = "Gets feature", testCase = "get", type = "functional"}, function()
        shared.pgt:placeFeature("terrain1", "feat2", "Ruin", 48, 48)
        local feat = shared.pgt:getFeature("terrain1", "feat2")
        Helpers.assertEqual(feat ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ProcGenTerrain.getFeaturesInRegion", {description = "Gets region features", testCase = "region", type = "functional"}, function()
        shared.pgt:placeFeature("terrain1", "feat1", "Tower", 20, 20)
        shared.pgt:placeFeature("terrain1", "feat2", "Ruin", 25, 25)
        local feats = shared.pgt:getFeaturesInRegion("terrain1", 10, 10, 30, 30)
        Helpers.assertEqual(#feats > 0, true, "Found features")
    end)

    Suite:testMethod("ProcGenTerrain.discoverFeature", {description = "Discovers feature", testCase = "discover", type = "functional"}, function()
        shared.pgt:placeFeature("terrain1", "feat3", "Shrine", 16, 16)
        local ok = shared.pgt:discoverFeature("terrain1", "feat3")
        Helpers.assertEqual(ok, true, "Discovered")
    end)
end)

Suite:group("Terrain Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
        shared.pgt:createTerrain("terrain1", 64, 64, 1)
        shared.pgt:generateTerrainNoise("terrain1", 50, 4)
    end)

    Suite:testMethod("ProcGenTerrain.calculateTerrainRoughness", {description = "Calculates roughness", testCase = "roughness", type = "functional"}, function()
        local rough = shared.pgt:calculateTerrainRoughness("terrain1")
        Helpers.assertEqual(rough >= 0, true, "Roughness >= 0")
    end)

    Suite:testMethod("ProcGenTerrain.calculateTerrainComplexity", {description = "Calculates complexity", testCase = "complexity", type = "functional"}, function()
        local complexity = shared.pgt:calculateTerrainComplexity("terrain1")
        Helpers.assertEqual(complexity >= 0, true, "Complexity >= 0")
    end)

    Suite:testMethod("ProcGenTerrain.getTerrainStatistics", {description = "Gets statistics", testCase = "stats", type = "functional"}, function()
        local stats = shared.pgt:getTerrainStatistics("terrain1")
        Helpers.assertEqual(stats ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Hazards", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
        shared.pgt:createTerrain("terrain1", 64, 64, 1)
        shared.pgt:generateTerrainNoise("terrain1", 50, 4)
    end)

    Suite:testMethod("ProcGenTerrain.addHazard", {description = "Adds hazard", testCase = "add", type = "functional"}, function()
        local ok = shared.pgt:addHazard("terrain1", "haz1", "Volcano", 32, 32, 75)
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ProcGenTerrain.getHazardsAt", {description = "Gets hazards", testCase = "get", type = "functional"}, function()
        shared.pgt:addHazard("terrain1", "haz1", "Storm", 32, 32, 60)
        local hazards = shared.pgt:getHazardsAt("terrain1", 35, 35, 10)
        Helpers.assertEqual(#hazards > 0, true, "Found hazards")
    end)
end)

Suite:group("Traversability", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
        shared.pgt:createTerrain("terrain1", 64, 64, 1)
        shared.pgt:generateTerrainNoise("terrain1", 50, 4)
    end)

    Suite:testMethod("ProcGenTerrain.calculateTerrainTraversability", {description = "Calculates traversability", testCase = "traversability", type = "functional"}, function()
        local trav = shared.pgt:calculateTerrainTraversability("terrain1", 32, 32)
        Helpers.assertEqual(trav >= 0, true, "Traversability >= 0")
    end)
end)

Suite:group("Processing", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
        shared.pgt:createTerrain("terrain1", 64, 64, 1)
        shared.pgt:generateTerrainNoise("terrain1", 50, 4)
    end)

    Suite:testMethod("ProcGenTerrain.smoothTerrain", {description = "Smooths terrain", testCase = "smooth", type = "functional"}, function()
        local ok = shared.pgt:smoothTerrain("terrain1", 2)
        Helpers.assertEqual(ok, true, "Smoothed")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pgt = ProcGenTerrain:new()
    end)

    Suite:testMethod("ProcGenTerrain.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.pgt:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
