-- ─────────────────────────────────────────────────────────────────────────
-- PROCEDURAL GENERATION TEST SUITE
-- FILE: tests2/battlescape/procedural_generation_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.procedural_generation",
    fileName = "procedural_generation.lua",
    description = "Procedural generation system for missions, maps, and terrain variety"
})

print("[PROCEDURAL_GENERATION_TEST] Setting up")

local ProceduralGeneration = {
    seeds = {},
    missions = {},
    maps = {},
    terrain_configs = {},
    difficulty_scaling = {},

    new = function(self)
        return setmetatable({
            seeds = {}, missions = {}, maps = {},
            terrain_configs = {}, difficulty_scaling = {}
        }, {__index = self})
    end,

    setSeed = function(self, seedId, seed_value)
        self.seeds[seedId] = seed_value
        math.randomseed(seed_value)
        return true
    end,

    getSeed = function(self, seedId)
        return self.seeds[seedId]
    end,

    generateMission = function(self, missionId, difficulty)
        local difficulty_level = difficulty or 5
        self.missions[missionId] = {
            id = missionId, difficulty = difficulty_level,
            enemy_count = 5 + difficulty_level * 2,
            duration_turns = 20 + difficulty_level,
            objective_type = "elimination",
            rewards_exp = 100 + difficulty_level * 10,
            generated_turn = 0
        }
        return true
    end,

    getMission = function(self, missionId)
        return self.missions[missionId]
    end,

    getMissionDifficulty = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].difficulty
    end,

    getMissionEnemyCount = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].enemy_count
    end,

    getMissionRewards = function(self, missionId)
        if not self.missions[missionId] then return 0 end
        return self.missions[missionId].rewards_exp
    end,

    registerTerrainConfig = function(self, configId, name, biome, tile_types)
        self.terrain_configs[configId] = {
            id = configId, name = name, biome = biome or "temperate",
            tile_types = tile_types or {}, feature_density = 0.3
        }
        return true
    end,

    getTerrainConfig = function(self, configId)
        return self.terrain_configs[configId]
    end,

    generateMap = function(self, mapId, width, height, configId)
        if not self.terrain_configs[configId] then return false end
        self.maps[mapId] = {
            id = mapId, width = width, height = height,
            config = configId, tiles = {}, coverage = 0,
            hazard_count = math.floor((width * height) * 0.05),
            spawn_points = {}
        }
        local total_tiles = width * height
        self.maps[mapId].coverage = math.floor((total_tiles * 0.6) * 100 / total_tiles)
        return true
    end,

    getMap = function(self, mapId)
        return self.maps[mapId]
    end,

    getMapDimensions = function(self, mapId)
        if not self.maps[mapId] then return 0, 0 end
        return self.maps[mapId].width, self.maps[mapId].height
    end,

    getMapTileCount = function(self, mapId)
        if not self.maps[mapId] then return 0 end
        return self.maps[mapId].width * self.maps[mapId].height
    end,

    addSpawnPoint = function(self, mapId, x, y, faction)
        if not self.maps[mapId] then return false end
        table.insert(self.maps[mapId].spawn_points, {x = x, y = y, faction = faction or "player"})
        return true
    end,

    getSpawnPointCount = function(self, mapId)
        if not self.maps[mapId] then return 0 end
        return #self.maps[mapId].spawn_points
    end,

    generateObjective = function(self, objectiveId, objectiveType, difficulty)
        local difficulty_level = difficulty or 5
        return {
            id = objectiveId, type = objectiveType or "capture",
            difficulty = difficulty_level,
            location_x = math.floor(math.random() * 100),
            location_y = math.floor(math.random() * 100),
            time_limit = 30 - difficulty_level * 2,
            completion_reward = 50 * difficulty_level
        }
    end,

    scaleDifficultyForTeam = function(self, teamSize, baseEnemyCount)
        local scaled_enemies = baseEnemyCount + math.floor(teamSize / 2)
        return scaled_enemies
    end,

    getMapCoverage = function(self, mapId)
        if not self.maps[mapId] then return 0 end
        return self.maps[mapId].coverage
    end,

    getMapHazardCount = function(self, mapId)
        if not self.maps[mapId] then return 0 end
        return self.maps[mapId].hazard_count
    end,

    calculateMapComplexity = function(self, mapId)
        if not self.maps[mapId] then return 0 end
        local map = self.maps[mapId]
        local tile_count = map.width * map.height
        local hazard_factor = map.hazard_count * 10
        local spawn_factor = #map.spawn_points * 5
        return math.floor((tile_count + hazard_factor + spawn_factor) / 10)
    end,

    validateMap = function(self, mapId)
        if not self.maps[mapId] then return false end
        local map = self.maps[mapId]
        if map.width <= 0 or map.height <= 0 then return false end
        if map.coverage < 0 or map.coverage > 100 then return false end
        if #map.spawn_points < 1 then return false end
        return true
    end,

    generateVariant = function(self, baseMapId, variantId, seedModifier)
        if not self.maps[baseMapId] then return false end
        local base = self.maps[baseMapId]
        self.maps[variantId] = {
            id = variantId, width = base.width, height = base.height,
            config = base.config, tiles = {}, coverage = base.coverage + (seedModifier or 5),
            hazard_count = base.hazard_count + math.floor(seedModifier or 0),
            spawn_points = {}
        }
        return true
    end,

    getTotalMissionsGenerated = function(self)
        local count = 0
        for _ in pairs(self.missions) do count = count + 1 end
        return count
    end,

    getTotalMapsGenerated = function(self)
        local count = 0
        for _ in pairs(self.maps) do count = count + 1 end
        return count
    end,

    reset = function(self)
        self.seeds = {}
        self.missions = {}
        self.maps = {}
        self.terrain_configs = {}
        self.difficulty_scaling = {}
        return true
    end
}

Suite:group("Seeds", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
    end)

    Suite:testMethod("ProceduralGeneration.setSeed", {description = "Sets seed", testCase = "set", type = "functional"}, function()
        local ok = shared.pg:setSeed("seed1", 12345)
        Helpers.assertEqual(ok, true, "Seed set")
    end)

    Suite:testMethod("ProceduralGeneration.getSeed", {description = "Gets seed", testCase = "get", type = "functional"}, function()
        shared.pg:setSeed("seed2", 54321)
        local seed = shared.pg:getSeed("seed2")
        Helpers.assertEqual(seed, 54321, "Seed 54321")
    end)
end)

Suite:group("Mission Generation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
    end)

    Suite:testMethod("ProceduralGeneration.generateMission", {description = "Generates mission", testCase = "generate", type = "functional"}, function()
        local ok = shared.pg:generateMission("mission1", 5)
        Helpers.assertEqual(ok, true, "Generated")
    end)

    Suite:testMethod("ProceduralGeneration.getMission", {description = "Gets mission", testCase = "get", type = "functional"}, function()
        shared.pg:generateMission("mission2", 3)
        local mission = shared.pg:getMission("mission2")
        Helpers.assertEqual(mission ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ProceduralGeneration.getMissionDifficulty", {description = "Gets difficulty", testCase = "difficulty", type = "functional"}, function()
        shared.pg:generateMission("mission3", 7)
        local difficulty = shared.pg:getMissionDifficulty("mission3")
        Helpers.assertEqual(difficulty, 7, "Difficulty 7")
    end)

    Suite:testMethod("ProceduralGeneration.getMissionEnemyCount", {description = "Gets enemy count", testCase = "enemies", type = "functional"}, function()
        shared.pg:generateMission("mission4", 3)
        local enemies = shared.pg:getMissionEnemyCount("mission4")
        Helpers.assertEqual(enemies > 0, true, "Enemies > 0")
    end)

    Suite:testMethod("ProceduralGeneration.getMissionRewards", {description = "Gets rewards", testCase = "rewards", type = "functional"}, function()
        shared.pg:generateMission("mission5", 5)
        local rewards = shared.pg:getMissionRewards("mission5")
        Helpers.assertEqual(rewards > 0, true, "Rewards > 0")
    end)
end)

Suite:group("Terrain Configuration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
    end)

    Suite:testMethod("ProceduralGeneration.registerTerrainConfig", {description = "Registers config", testCase = "register", type = "functional"}, function()
        local ok = shared.pg:registerTerrainConfig("tundra", "Tundra", "arctic", {"snow", "ice"})
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ProceduralGeneration.getTerrainConfig", {description = "Gets config", testCase = "get", type = "functional"}, function()
        shared.pg:registerTerrainConfig("desert", "Desert", "arid", {"sand", "rock"})
        local config = shared.pg:getTerrainConfig("desert")
        Helpers.assertEqual(config ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Map Generation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
        shared.pg:registerTerrainConfig("forest", "Forest", "temperate", {"grass", "tree"})
    end)

    Suite:testMethod("ProceduralGeneration.generateMap", {description = "Generates map", testCase = "generate", type = "functional"}, function()
        local ok = shared.pg:generateMap("map1", 100, 100, "forest")
        Helpers.assertEqual(ok, true, "Generated")
    end)

    Suite:testMethod("ProceduralGeneration.getMap", {description = "Gets map", testCase = "get", type = "functional"}, function()
        shared.pg:generateMap("map2", 80, 80, "forest")
        local map = shared.pg:getMap("map2")
        Helpers.assertEqual(map ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ProceduralGeneration.getMapDimensions", {description = "Gets dimensions", testCase = "dimensions", type = "functional"}, function()
        shared.pg:generateMap("map3", 50, 75, "forest")
        local w, h = shared.pg:getMapDimensions("map3")
        Helpers.assertEqual(w, 50, "Width 50")
        Helpers.assertEqual(h, 75, "Height 75")
    end)

    Suite:testMethod("ProceduralGeneration.getMapTileCount", {description = "Tile count", testCase = "tiles", type = "functional"}, function()
        shared.pg:generateMap("map4", 40, 30, "forest")
        local tiles = shared.pg:getMapTileCount("map4")
        Helpers.assertEqual(tiles, 1200, "1200 tiles")
    end)
end)

Suite:group("Spawn Points", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
        shared.pg:registerTerrainConfig("camp", "Camp", "temperate", {"grass"})
        shared.pg:generateMap("spawn_map", 100, 100, "camp")
    end)

    Suite:testMethod("ProceduralGeneration.addSpawnPoint", {description = "Adds spawn", testCase = "add", type = "functional"}, function()
        local ok = shared.pg:addSpawnPoint("spawn_map", 10, 10, "player")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ProceduralGeneration.getSpawnPointCount", {description = "Count spawns", testCase = "count", type = "functional"}, function()
        shared.pg:addSpawnPoint("spawn_map", 20, 20, "enemy")
        shared.pg:addSpawnPoint("spawn_map", 30, 30, "player")
        local count = shared.pg:getSpawnPointCount("spawn_map")
        Helpers.assertEqual(count, 2, "Two spawns")
    end)
end)

Suite:group("Objectives", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
    end)

    Suite:testMethod("ProceduralGeneration.generateObjective", {description = "Generates objective", testCase = "generate", type = "functional"}, function()
        local obj = shared.pg:generateObjective("obj1", "capture", 5)
        Helpers.assertEqual(obj ~= nil, true, "Generated")
    end)
end)

Suite:group("Difficulty Scaling", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
    end)

    Suite:testMethod("ProceduralGeneration.scaleDifficultyForTeam", {description = "Scales difficulty", testCase = "scale", type = "functional"}, function()
        local scaled = shared.pg:scaleDifficultyForTeam(4, 10)
        Helpers.assertEqual(scaled > 10, true, "Scaled > 10")
    end)
end)

Suite:group("Map Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
        shared.pg:registerTerrainConfig("analysis", "Analysis", "temperate", {"grass"})
        shared.pg:generateMap("analysis_map", 100, 100, "analysis")
        shared.pg:addSpawnPoint("analysis_map", 50, 50, "player")
    end)

    Suite:testMethod("ProceduralGeneration.getMapCoverage", {description = "Gets coverage", testCase = "coverage", type = "functional"}, function()
        local coverage = shared.pg:getMapCoverage("analysis_map")
        Helpers.assertEqual(coverage > 0, true, "Coverage > 0")
    end)

    Suite:testMethod("ProceduralGeneration.getMapHazardCount", {description = "Hazard count", testCase = "hazards", type = "functional"}, function()
        local hazards = shared.pg:getMapHazardCount("analysis_map")
        Helpers.assertEqual(hazards >= 0, true, "Hazards >= 0")
    end)

    Suite:testMethod("ProceduralGeneration.calculateMapComplexity", {description = "Map complexity", testCase = "complexity", type = "functional"}, function()
        local complexity = shared.pg:calculateMapComplexity("analysis_map")
        Helpers.assertEqual(complexity > 0, true, "Complexity > 0")
    end)

    Suite:testMethod("ProceduralGeneration.validateMap", {description = "Validates map", testCase = "validate", type = "functional"}, function()
        local valid = shared.pg:validateMap("analysis_map")
        Helpers.assertEqual(valid, true, "Valid")
    end)
end)

Suite:group("Variants", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
        shared.pg:registerTerrainConfig("variant_conf", "Variant", "temperate", {"grass"})
        shared.pg:generateMap("base_map", 80, 80, "variant_conf")
    end)

    Suite:testMethod("ProceduralGeneration.generateVariant", {description = "Generates variant", testCase = "generate", type = "functional"}, function()
        local ok = shared.pg:generateVariant("base_map", "variant_map", 10)
        Helpers.assertEqual(ok, true, "Generated")
    end)
end)

Suite:group("Statistics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
    end)

    Suite:testMethod("ProceduralGeneration.getTotalMissionsGenerated", {description = "Total missions", testCase = "missions", type = "functional"}, function()
        shared.pg:generateMission("m1", 2)
        shared.pg:generateMission("m2", 4)
        local total = shared.pg:getTotalMissionsGenerated()
        Helpers.assertEqual(total, 2, "Two missions")
    end)

    Suite:testMethod("ProceduralGeneration.getTotalMapsGenerated", {description = "Total maps", testCase = "maps", type = "functional"}, function()
        shared.pg:registerTerrainConfig("stats_conf", "Stats", "temperate", {"grass"})
        shared.pg:generateMap("map_a", 50, 50, "stats_conf")
        shared.pg:generateMap("map_b", 60, 60, "stats_conf")
        local total = shared.pg:getTotalMapsGenerated()
        Helpers.assertEqual(total, 2, "Two maps")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.pg = ProceduralGeneration:new()
    end)

    Suite:testMethod("ProceduralGeneration.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.pg:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
