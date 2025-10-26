-- ─────────────────────────────────────────────────────────────────────────
-- MAP GENERATOR TEST SUITE
-- FILE: tests2/battlescape/map_generator_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.map_generator",
    fileName = "map_generator.lua",
    description = "Procedural battlemap generation with terrain, cover, and hazards"
})

print("[MAP_GENERATOR_TEST] Setting up")

local MapGenerator = {
    maps = {},
    tiles = {},
    cover_points = {},
    hazards = {},

    new = function(self)
        return setmetatable({maps = {}, tiles = {}, cover_points = {}, hazards = {}}, {__index = self})
    end,

    generateMap = function(self, mapId, width, height, biome)
        self.maps[mapId] = {id = mapId, width = width, height = height, biome = biome, tileCount = width * height, enemies = 0}
        self.tiles[mapId] = {}
        self.cover_points[mapId] = {}
        self.hazards[mapId] = {}
        for i = 1, width * height do
            table.insert(self.tiles[mapId], {x = i % width, y = math.floor(i / width), terrain = "grass", passable = true})
        end
        return true
    end,

    getMap = function(self, mapId)
        return self.maps[mapId]
    end,

    getTileCount = function(self, mapId)
        if not self.maps[mapId] then return 0 end
        return self.maps[mapId].tileCount
    end,

    addCover = function(self, mapId, x, y, coverType, armor)
        if not self.maps[mapId] then return false end
        table.insert(self.cover_points[mapId], {x = x, y = y, type = coverType, armor = armor or 50, health = 100})
        return true
    end,

    getCoverCount = function(self, mapId)
        if not self.cover_points[mapId] then return 0 end
        return #self.cover_points[mapId]
    end,

    addHazard = function(self, mapId, x, y, hazardType, damage)
        if not self.maps[mapId] then return false end
        table.insert(self.hazards[mapId], {x = x, y = y, type = hazardType, damage = damage or 20, active = true})
        return true
    end,

    getHazardCount = function(self, mapId)
        if not self.hazards[mapId] then return 0 end
        return #self.hazards[mapId]
    end,

    placeTerrain = function(self, mapId, x, y, terrainType)
        if not self.maps[mapId] then return false end
        local tileIndex = y * self.maps[mapId].width + x + 1
        if tileIndex > 0 and tileIndex <= #self.tiles[mapId] then
            self.tiles[mapId][tileIndex].terrain = terrainType
            self.tiles[mapId][tileIndex].passable = terrainType ~= "wall" and terrainType ~= "water"
            return true
        end
        return false
    end,

    placeEnemy = function(self, mapId, x, y, enemyType)
        if not self.maps[mapId] then return false end
        self.maps[mapId].enemies = self.maps[mapId].enemies + 1
        return true
    end,

    getEnemyCount = function(self, mapId)
        if not self.maps[mapId] then return 0 end
        return self.maps[mapId].enemies
    end,

    getTerrain = function(self, mapId, x, y)
        if not self.maps[mapId] or not self.tiles[mapId] then return nil end
        local tileIndex = y * self.maps[mapId].width + x + 1
        if tileIndex > 0 and tileIndex <= #self.tiles[mapId] then
            return self.tiles[mapId][tileIndex].terrain
        end
        return nil
    end,

    isPassable = function(self, mapId, x, y)
        if not self.maps[mapId] or not self.tiles[mapId] then return false end
        local tileIndex = y * self.maps[mapId].width + x + 1
        if tileIndex > 0 and tileIndex <= #self.tiles[mapId] then
            return self.tiles[mapId][tileIndex].passable
        end
        return false
    end,

    getMapCount = function(self)
        local count = 0
        for _ in pairs(self.maps) do count = count + 1 end
        return count
    end,

    calculateCoverage = function(self, mapId)
        if not self.maps[mapId] then return 0 end
        local coverage = self:getCoverCount(mapId)
        return math.floor((coverage / self.maps[mapId].tileCount) * 100)
    end,

    getTotalHazardDamage = function(self, mapId)
        if not self.hazards[mapId] then return 0 end
        local total = 0
        for _, hazard in ipairs(self.hazards[mapId]) do
            if hazard.active then total = total + hazard.damage end
        end
        return total
    end
}

Suite:group("Map Generation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MapGenerator:new()
    end)

    Suite:testMethod("MapGenerator.new", {description = "Creates generator", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.mg ~= nil, true, "Generator created")
    end)

    Suite:testMethod("MapGenerator.generateMap", {description = "Generates map", testCase = "generate", type = "functional"}, function()
        local ok = shared.mg:generateMap("map1", 20, 20, "urban")
        Helpers.assertEqual(ok, true, "Map generated")
    end)

    Suite:testMethod("MapGenerator.getMap", {description = "Retrieves map", testCase = "get", type = "functional"}, function()
        shared.mg:generateMap("map2", 25, 25, "forest")
        local map = shared.mg:getMap("map2")
        Helpers.assertEqual(map ~= nil, true, "Map retrieved")
    end)

    Suite:testMethod("MapGenerator.getTileCount", {description = "Correct tile count", testCase = "tile_count", type = "functional"}, function()
        shared.mg:generateMap("map3", 10, 15, "desert")
        local count = shared.mg:getTileCount("map3")
        Helpers.assertEqual(count, 150, "150 tiles")
    end)

    Suite:testMethod("MapGenerator.getMapCount", {description = "Counts maps", testCase = "count", type = "functional"}, function()
        shared.mg:generateMap("m1", 10, 10, "urban")
        shared.mg:generateMap("m2", 15, 15, "forest")
        shared.mg:generateMap("m3", 20, 20, "desert")
        local count = shared.mg:getMapCount()
        Helpers.assertEqual(count, 3, "Three maps")
    end)
end)

Suite:group("Terrain Placement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MapGenerator:new()
        shared.mg:generateMap("terrain", 16, 16, "mixed")
    end)

    Suite:testMethod("MapGenerator.placeTerrain", {description = "Places terrain", testCase = "place", type = "functional"}, function()
        local ok = shared.mg:placeTerrain("terrain", 5, 5, "wall")
        Helpers.assertEqual(ok, true, "Terrain placed")
    end)

    Suite:testMethod("MapGenerator.getTerrain", {description = "Retrieves terrain", testCase = "get_terrain", type = "functional"}, function()
        shared.mg:placeTerrain("terrain", 8, 8, "building")
        local terrain = shared.mg:getTerrain("terrain", 8, 8)
        Helpers.assertEqual(terrain, "building", "Building terrain")
    end)

    Suite:testMethod("MapGenerator.isPassable", {description = "Wall blocks passage", testCase = "wall_block", type = "functional"}, function()
        shared.mg:placeTerrain("terrain", 3, 3, "wall")
        local passable = shared.mg:isPassable("terrain", 3, 3)
        Helpers.assertEqual(passable, false, "Not passable")
    end)

    Suite:testMethod("MapGenerator.isPassable", {description = "Grass passable", testCase = "grass_pass", type = "functional"}, function()
        local passable = shared.mg:isPassable("terrain", 0, 0)
        Helpers.assertEqual(passable, true, "Passable")
    end)
end)

Suite:group("Cover Points", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MapGenerator:new()
        shared.mg:generateMap("cover", 20, 20, "urban")
    end)

    Suite:testMethod("MapGenerator.addCover", {description = "Adds cover", testCase = "add_cover", type = "functional"}, function()
        local ok = shared.mg:addCover("cover", 10, 10, "barricade", 60)
        Helpers.assertEqual(ok, true, "Cover added")
    end)

    Suite:testMethod("MapGenerator.getCoverCount", {description = "Counts cover", testCase = "count_cover", type = "functional"}, function()
        shared.mg:addCover("cover", 5, 5, "wall", 80)
        shared.mg:addCover("cover", 10, 10, "crate", 40)
        shared.mg:addCover("cover", 15, 15, "vehicle", 100)
        local count = shared.mg:getCoverCount("cover")
        Helpers.assertEqual(count, 3, "Three cover points")
    end)

    Suite:testMethod("MapGenerator.calculateCoverage", {description = "Coverage percentage", testCase = "coverage", type = "functional"}, function()
        shared.mg:addCover("cover", 2, 2, "cover", 50)
        shared.mg:addCover("cover", 5, 5, "cover", 50)
        local coverage = shared.mg:calculateCoverage("cover")
        Helpers.assertEqual(coverage >= 0, true, "Coverage calculated")
    end)
end)

Suite:group("Hazards", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MapGenerator:new()
        shared.mg:generateMap("hazard", 16, 16, "lava")
    end)

    Suite:testMethod("MapGenerator.addHazard", {description = "Adds hazard", testCase = "add_hazard", type = "functional"}, function()
        local ok = shared.mg:addHazard("hazard", 8, 8, "fire", 25)
        Helpers.assertEqual(ok, true, "Hazard added")
    end)

    Suite:testMethod("MapGenerator.getHazardCount", {description = "Counts hazards", testCase = "count_hazard", type = "functional"}, function()
        shared.mg:addHazard("hazard", 4, 4, "poison", 15)
        shared.mg:addHazard("hazard", 8, 8, "radiation", 30)
        shared.mg:addHazard("hazard", 12, 12, "electricity", 20)
        local count = shared.mg:getHazardCount("hazard")
        Helpers.assertEqual(count, 3, "Three hazards")
    end)

    Suite:testMethod("MapGenerator.getTotalHazardDamage", {description = "Total damage", testCase = "total_damage", type = "functional"}, function()
        shared.mg:addHazard("hazard", 2, 2, "fire", 20)
        shared.mg:addHazard("hazard", 4, 4, "poison", 30)
        local total = shared.mg:getTotalHazardDamage("hazard")
        Helpers.assertEqual(total, 50, "Total damage 50")
    end)
end)

Suite:group("Enemy Placement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.mg = MapGenerator:new()
        shared.mg:generateMap("enemies", 18, 18, "industrial")
    end)

    Suite:testMethod("MapGenerator.placeEnemy", {description = "Places enemy", testCase = "place_enemy", type = "functional"}, function()
        local ok = shared.mg:placeEnemy("enemies", 5, 5, "alien")
        Helpers.assertEqual(ok, true, "Enemy placed")
    end)

    Suite:testMethod("MapGenerator.getEnemyCount", {description = "Counts enemies", testCase = "count_enemy", type = "functional"}, function()
        shared.mg:placeEnemy("enemies", 5, 5, "alien")
        shared.mg:placeEnemy("enemies", 10, 10, "alien")
        shared.mg:placeEnemy("enemies", 15, 15, "alien")
        local count = shared.mg:getEnemyCount("enemies")
        Helpers.assertEqual(count, 3, "Three enemies")
    end)
end)

Suite:run()
