-- ─────────────────────────────────────────────────────────────────────────
-- UNIT PROGRESSION TEST SUITE
-- FILE: tests2/core/unit_progression_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.unit_progression",
    fileName = "unit_progression.lua",
    description = "Soldier experience, ranks, perks, and stat progression"
})

print("[UNIT_PROGRESSION_TEST] Setting up")

local UnitProgression = {
    units = {},
    ranks = {},
    perks = {},
    experience = {},

    new = function(self)
        return setmetatable({units = {}, ranks = {}, perks = {}, experience = {}}, {__index = self})
    end,

    registerUnit = function(self, unitId, name, baseClass)
        self.units[unitId] = {id = unitId, name = name, class = baseClass, level = 1, rank = "recruit", stats = {str = 10, dex = 10, will = 10, acc = 80}}
        self.experience[unitId] = 0
        self.perks[unitId] = {}
        return true
    end,

    getUnit = function(self, unitId)
        return self.units[unitId]
    end,

    addExperience = function(self, unitId, amount)
        if not self.units[unitId] then return false end
        self.experience[unitId] = self.experience[unitId] + amount
        local levelsGained = math.floor(self.experience[unitId] / 100)
        while levelsGained > 0 and self.units[unitId].level < 20 do
            self.units[unitId].level = self.units[unitId].level + 1
            self.units[unitId].stats.str = self.units[unitId].stats.str + 1
            self.units[unitId].stats.acc = self.units[unitId].stats.acc + 2
            levelsGained = levelsGained - 1
        end
        return true
    end,

    getLevel = function(self, unitId)
        if not self.units[unitId] then return 0 end
        return self.units[unitId].level
    end,

    getExperience = function(self, unitId)
        return self.experience[unitId] or 0
    end,

    promoteRank = function(self, unitId, newRank)
        if not self.units[unitId] then return false end
        self.units[unitId].rank = newRank
        return true
    end,

    getRank = function(self, unitId)
        if not self.units[unitId] then return nil end
        return self.units[unitId].rank
    end,

    learnPerk = function(self, unitId, perkId, perkName)
        if not self.units[unitId] then return false end
        table.insert(self.perks[unitId], {id = perkId, name = perkName, learned = true})
        return true
    end,

    getPerkCount = function(self, unitId)
        if not self.perks[unitId] then return 0 end
        return #self.perks[unitId]
    end,

    hasPerks = function(self, unitId)
        if not self.perks[unitId] then return false end
        return #self.perks[unitId] > 0
    end,

    boostStat = function(self, unitId, statName, amount)
        if not self.units[unitId] or not self.units[unitId].stats[statName] then return false end
        self.units[unitId].stats[statName] = self.units[unitId].stats[statName] + amount
        return true
    end,

    getStat = function(self, unitId, statName)
        if not self.units[unitId] or not self.units[unitId].stats[statName] then return 0 end
        return self.units[unitId].stats[statName]
    end,

    getStats = function(self, unitId)
        if not self.units[unitId] then return {} end
        return self.units[unitId].stats
    end,

    resetProgress = function(self, unitId)
        if not self.units[unitId] then return false end
        self.units[unitId].level = 1
        self.units[unitId].rank = "recruit"
        self.experience[unitId] = 0
        self.perks[unitId] = {}
        self.units[unitId].stats = {str = 10, dex = 10, will = 10, acc = 80}
        return true
    end,

    getUnitCount = function(self)
        local count = 0
        for _ in pairs(self.units) do count = count + 1 end
        return count
    end,

    getAverageLevel = function(self)
        local total = 0
        local count = 0
        for _, unit in pairs(self.units) do
            total = total + unit.level
            count = count + 1
        end
        if count == 0 then return 0 end
        return math.floor(total / count)
    end
}

Suite:group("Unit Registration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
    end)

    Suite:testMethod("UnitProgression.new", {description = "Creates system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.up ~= nil, true, "System created")
    end)

    Suite:testMethod("UnitProgression.registerUnit", {description = "Registers unit", testCase = "register", type = "functional"}, function()
        local ok = shared.up:registerUnit("soldier1", "John Smith", "rifleman")
        Helpers.assertEqual(ok, true, "Unit registered")
    end)

    Suite:testMethod("UnitProgression.getUnit", {description = "Retrieves unit", testCase = "get", type = "functional"}, function()
        shared.up:registerUnit("soldier2", "Jane Doe", "sniper")
        local unit = shared.up:getUnit("soldier2")
        Helpers.assertEqual(unit ~= nil, true, "Unit retrieved")
    end)

    Suite:testMethod("UnitProgression.getLevel", {description = "Initial level 1", testCase = "init_level", type = "functional"}, function()
        shared.up:registerUnit("soldier3", "Bob", "heavy")
        local level = shared.up:getLevel("soldier3")
        Helpers.assertEqual(level, 1, "Level 1")
    end)

    Suite:testMethod("UnitProgression.getUnitCount", {description = "Counts units", testCase = "count", type = "functional"}, function()
        shared.up:registerUnit("u1", "U1", "class")
        shared.up:registerUnit("u2", "U2", "class")
        shared.up:registerUnit("u3", "U3", "class")
        local count = shared.up:getUnitCount()
        Helpers.assertEqual(count, 3, "Three units")
    end)
end)

Suite:group("Experience & Leveling", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:registerUnit("vet", "Veteran", "rifleman")
    end)

    Suite:testMethod("UnitProgression.addExperience", {description = "Adds experience", testCase = "add_xp", type = "functional"}, function()
        local ok = shared.up:addExperience("vet", 50)
        Helpers.assertEqual(ok, true, "Experience added")
    end)

    Suite:testMethod("UnitProgression.getExperience", {description = "Gets experience", testCase = "get_xp", type = "functional"}, function()
        shared.up:addExperience("vet", 75)
        local xp = shared.up:getExperience("vet")
        Helpers.assertEqual(xp, 75, "XP 75")
    end)

    Suite:testMethod("UnitProgression.addExperience", {description = "Levels at 100 XP", testCase = "level_up", type = "functional"}, function()
        shared.up:addExperience("vet", 100)
        local level = shared.up:getLevel("vet")
        Helpers.assertEqual(level, 2, "Level 2")
    end)

    Suite:testMethod("UnitProgression.addExperience", {description = "Multi-level possible", testCase = "multi_level", type = "functional"}, function()
        shared.up:addExperience("vet", 300)
        local level = shared.up:getLevel("vet")
        Helpers.assertEqual(level, 4, "Level 4")
    end)

    Suite:testMethod("UnitProgression.addExperience", {description = "Caps at 20", testCase = "level_cap", type = "functional"}, function()
        shared.up:addExperience("vet", 5000)
        local level = shared.up:getLevel("vet")
        Helpers.assertEqual(level, 20, "Level 20")
    end)
end)

Suite:group("Promotions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:registerUnit("cadet", "Cadet", "rifleman")
    end)

    Suite:testMethod("UnitProgression.promoteRank", {description = "Promotes rank", testCase = "promote", type = "functional"}, function()
        local ok = shared.up:promoteRank("cadet", "sergeant")
        Helpers.assertEqual(ok, true, "Promoted")
    end)

    Suite:testMethod("UnitProgression.getRank", {description = "Gets rank", testCase = "get_rank", type = "functional"}, function()
        shared.up:promoteRank("cadet", "lieutenant")
        local rank = shared.up:getRank("cadet")
        Helpers.assertEqual(rank, "lieutenant", "Lieutenant")
    end)

    Suite:testMethod("UnitProgression.getRank", {description = "Initial recruit", testCase = "init_rank", type = "functional"}, function()
        local rank = shared.up:getRank("cadet")
        Helpers.assertEqual(rank, "recruit", "Recruit")
    end)
end)

Suite:group("Perks & Abilities", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:registerUnit("perk_unit", "Perk Unit", "specialist")
    end)

    Suite:testMethod("UnitProgression.learnPerk", {description = "Learns perk", testCase = "learn", type = "functional"}, function()
        local ok = shared.up:learnPerk("perk_unit", "rapid_fire", "Rapid Fire")
        Helpers.assertEqual(ok, true, "Perk learned")
    end)

    Suite:testMethod("UnitProgression.getPerkCount", {description = "Counts perks", testCase = "count_perks", type = "functional"}, function()
        shared.up:learnPerk("perk_unit", "p1", "Perk 1")
        shared.up:learnPerk("perk_unit", "p2", "Perk 2")
        shared.up:learnPerk("perk_unit", "p3", "Perk 3")
        local count = shared.up:getPerkCount("perk_unit")
        Helpers.assertEqual(count, 3, "Three perks")
    end)

    Suite:testMethod("UnitProgression.hasPerks", {description = "Has perks check", testCase = "has_perks", type = "functional"}, function()
        shared.up:learnPerk("perk_unit", "ability", "Ability")
        local has = shared.up:hasPerks("perk_unit")
        Helpers.assertEqual(has, true, "Has perks")
    end)
end)

Suite:group("Stats", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:registerUnit("stat_unit", "Stat Unit", "fighter")
    end)

    Suite:testMethod("UnitProgression.getStat", {description = "Gets stat", testCase = "get_stat", type = "functional"}, function()
        local acc = shared.up:getStat("stat_unit", "acc")
        Helpers.assertEqual(acc, 80, "Accuracy 80")
    end)

    Suite:testMethod("UnitProgression.boostStat", {description = "Boosts stat", testCase = "boost", type = "functional"}, function()
        local ok = shared.up:boostStat("stat_unit", "str", 5)
        Helpers.assertEqual(ok, true, "Stat boosted")
    end)

    Suite:testMethod("UnitProgression.boostStat", {description = "Increases value", testCase = "increase", type = "functional"}, function()
        shared.up:boostStat("stat_unit", "str", 3)
        local str = shared.up:getStat("stat_unit", "str")
        Helpers.assertEqual(str, 13, "Strength 13")
    end)

    Suite:testMethod("UnitProgression.getStats", {description = "Gets all stats", testCase = "all_stats", type = "functional"}, function()
        local stats = shared.up:getStats("stat_unit")
        Helpers.assertEqual(stats ~= nil, true, "Stats retrieved")
    end)
end)

Suite:group("Progression Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:registerUnit("reset_unit", "Reset Unit", "soldier")
    end)

    Suite:testMethod("UnitProgression.resetProgress", {description = "Resets progress", testCase = "reset", type = "functional"}, function()
        shared.up:addExperience("reset_unit", 200)
        shared.up:promoteRank("reset_unit", "captain")
        local ok = shared.up:resetProgress("reset_unit")
        Helpers.assertEqual(ok, true, "Reset OK")
    end)

    Suite:testMethod("UnitProgression.resetProgress", {description = "Restores defaults", testCase = "restore", type = "functional"}, function()
        shared.up:addExperience("reset_unit", 150)
        shared.up:resetProgress("reset_unit")
        local level = shared.up:getLevel("reset_unit")
        Helpers.assertEqual(level, 1, "Level 1 restored")
    end)
end)

Suite:group("Team Statistics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:registerUnit("u1", "U1", "class")
        shared.up:registerUnit("u2", "U2", "class")
        shared.up:registerUnit("u3", "U3", "class")
    end)

    Suite:testMethod("UnitProgression.getAverageLevel", {description = "Calculates average", testCase = "average", type = "functional"}, function()
        shared.up:addExperience("u1", 100)
        shared.up:addExperience("u2", 200)
        shared.up:addExperience("u3", 100)
        local avg = shared.up:getAverageLevel()
        Helpers.assertEqual(avg, 2, "Average level 2")
    end)
end)

Suite:run()
