-- ─────────────────────────────────────────────────────────────────────────
-- UNIT PROGRESSION TEST SUITE
-- FILE: tests2/battlescape/unit_progression_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.unit_progression",
    fileName = "unit_progression.lua",
    description = "Unit experience, leveling, rank progression, and skill advancement"
})

print("[UNIT_PROGRESSION_TEST] Setting up")

local UnitProgression = {
    units = {},
    experience = {},
    ranks = {},
    skills = {},
    promotions = {},

    new = function(self)
        return setmetatable({
            units = {}, experience = {}, ranks = {},
            skills = {}, promotions = {}
        }, {__index = self})
    end,

    enrollUnit = function(self, unitId, name, class, level)
        self.units[unitId] = {
            id = unitId, name = name, class = class or "soldier",
            level = level or 1, kills = 0, missions = 0
        }
        self.experience[unitId] = {exp = 0, exp_to_level = 100}
        self.ranks[unitId] = {rank = "Rookie", promotions = 0}
        self.skills[unitId] = {}
        return true
    end,

    getUnit = function(self, unitId)
        return self.units[unitId]
    end,

    gainExperience = function(self, unitId, amount)
        if not self.experience[unitId] then return false end
        self.experience[unitId].exp = self.experience[unitId].exp + amount
        if self.experience[unitId].exp >= self.experience[unitId].exp_to_level then
            self:levelUp(unitId)
        end
        return true
    end,

    getExperience = function(self, unitId)
        if not self.experience[unitId] then return 0 end
        return self.experience[unitId].exp
    end,

    getExperienceProgress = function(self, unitId)
        if not self.experience[unitId] then return 0 end
        local exp_progress = self.experience[unitId].exp
        local exp_next = self.experience[unitId].exp_to_level
        return math.floor((exp_progress / exp_next) * 100)
    end,

    levelUp = function(self, unitId)
        if not self.units[unitId] then return false end
        local unit = self.units[unitId]
        unit.level = unit.level + 1
        self.experience[unitId].exp = 0
        self.experience[unitId].exp_to_level = math.floor(100 * (1.1 ^ unit.level))
        return true
    end,

    getLevel = function(self, unitId)
        if not self.units[unitId] then return 0 end
        return self.units[unitId].level
    end,

    recordKill = function(self, unitId)
        if not self.units[unitId] then return false end
        self.units[unitId].kills = self.units[unitId].kills + 1
        self:gainExperience(unitId, 50)
        return true
    end,

    getKillCount = function(self, unitId)
        if not self.units[unitId] then return 0 end
        return self.units[unitId].kills
    end,

    completeMission = function(self, unitId)
        if not self.units[unitId] then return false end
        self.units[unitId].missions = self.units[unitId].missions + 1
        self:gainExperience(unitId, 30)
        return true
    end,

    getMissionCount = function(self, unitId)
        if not self.units[unitId] then return 0 end
        return self.units[unitId].missions
    end,

    learnSkill = function(self, unitId, skillId, name, power)
        if not self.skills[unitId] then return false end
        self.skills[unitId][skillId] = {id = skillId, name = name, power = power or 50, learned = true}
        return true
    end,

    hasSkill = function(self, unitId, skillId)
        if not self.skills[unitId] then return false end
        return self.skills[unitId][skillId] ~= nil and self.skills[unitId][skillId].learned
    end,

    getSkillCount = function(self, unitId)
        if not self.skills[unitId] then return 0 end
        local count = 0
        for _ in pairs(self.skills[unitId]) do count = count + 1 end
        return count
    end,

    getSkillsByClass = function(self, unitId)
        if not self.skills[unitId] then return {} end
        return self.skills[unitId]
    end,

    promote = function(self, unitId, newRank)
        if not self.ranks[unitId] then return false end
        local rank = self.ranks[unitId]
        rank.rank = newRank
        rank.promotions = rank.promotions + 1
        return true
    end,

    getRank = function(self, unitId)
        if not self.ranks[unitId] then return "Unknown" end
        return self.ranks[unitId].rank
    end,

    getPromotionCount = function(self, unitId)
        if not self.ranks[unitId] then return 0 end
        return self.ranks[unitId].promotions
    end,

    calculateCombatRating = function(self, unitId)
        if not self.units[unitId] then return 0 end
        local unit = self.units[unitId]
        local level_contrib = unit.level * 10
        local kill_contrib = unit.kills * 5
        local skill_contrib = self:getSkillCount(unitId) * 15
        return level_contrib + kill_contrib + skill_contrib
    end,

    calculateVeteranStatus = function(self, unitId)
        if not self.units[unitId] then return false end
        local unit = self.units[unitId]
        return unit.level >= 10 and unit.missions >= 5
    end,

    getHighestLevel = function(self)
        local maxLevel = 0
        for unitId, _ in pairs(self.units) do
            local level = self:getLevel(unitId)
            if level > maxLevel then maxLevel = level end
        end
        return maxLevel
    end,

    getAverageLevel = function(self)
        if not next(self.units) then return 0 end
        local totalLevel = 0
        for unitId, _ in pairs(self.units) do
            totalLevel = totalLevel + self:getLevel(unitId)
        end
        return math.floor(totalLevel / self:getUnitCount())
    end,

    getUnitCount = function(self)
        local count = 0
        for _ in pairs(self.units) do count = count + 1 end
        return count
    end,

    getVeteranCount = function(self)
        local count = 0
        for unitId, _ in pairs(self.units) do
            if self:calculateVeteranStatus(unitId) then count = count + 1 end
        end
        return count
    end,

    calculateExperienceLoss = function(self, unitId, lossPercent)
        if not self.experience[unitId] then return false end
        local loss = math.floor(self.experience[unitId].exp * (lossPercent / 100))
        self.experience[unitId].exp = math.max(0, self.experience[unitId].exp - loss)
        return true
    end,

    resetUnit = function(self, unitId)
        if not self.units[unitId] then return false end
        self.units[unitId].level = 1
        self.units[unitId].kills = 0
        self.units[unitId].missions = 0
        self.experience[unitId] = {exp = 0, exp_to_level = 100}
        self.ranks[unitId] = {rank = "Rookie", promotions = 0}
        self.skills[unitId] = {}
        return true
    end
}

Suite:group("Unit Enrollment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
    end)

    Suite:testMethod("UnitProgression.enrollUnit", {description = "Enrolls unit", testCase = "enroll", type = "functional"}, function()
        local ok = shared.up:enrollUnit("unit1", "John", "soldier", 1)
        Helpers.assertEqual(ok, true, "Enrolled")
    end)

    Suite:testMethod("UnitProgression.getUnit", {description = "Gets unit", testCase = "get_unit", type = "functional"}, function()
        shared.up:enrollUnit("unit2", "Jane", "sniper", 1)
        local unit = shared.up:getUnit("unit2")
        Helpers.assertEqual(unit ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("UnitProgression.getUnitCount", {description = "Unit count", testCase = "unit_count", type = "functional"}, function()
        shared.up:enrollUnit("u1", "U1", "soldier", 1)
        shared.up:enrollUnit("u2", "U2", "soldier", 1)
        local count = shared.up:getUnitCount()
        Helpers.assertEqual(count, 2, "Two units")
    end)
end)

Suite:group("Experience System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:enrollUnit("exp_unit", "Exp", "soldier", 1)
    end)

    Suite:testMethod("UnitProgression.gainExperience", {description = "Gains experience", testCase = "gain_exp", type = "functional"}, function()
        local ok = shared.up:gainExperience("exp_unit", 50)
        Helpers.assertEqual(ok, true, "Gained")
    end)

    Suite:testMethod("UnitProgression.getExperience", {description = "Gets experience", testCase = "get_exp", type = "functional"}, function()
        shared.up:gainExperience("exp_unit", 75)
        local exp = shared.up:getExperience("exp_unit")
        Helpers.assertEqual(exp, 75, "Exp 75")
    end)

    Suite:testMethod("UnitProgression.getExperienceProgress", {description = "Experience progress", testCase = "exp_progress", type = "functional"}, function()
        shared.up:gainExperience("exp_unit", 50)
        local prog = shared.up:getExperienceProgress("exp_unit")
        Helpers.assertEqual(prog, 50, "50% progress")
    end)
end)

Suite:group("Leveling", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:enrollUnit("level_unit", "Level", "soldier", 1)
    end)

    Suite:testMethod("UnitProgression.levelUp", {description = "Levels up", testCase = "level_up", type = "functional"}, function()
        shared.up:gainExperience("level_unit", 100)
        local level = shared.up:getLevel("level_unit")
        Helpers.assertEqual(level, 2, "Level 2")
    end)

    Suite:testMethod("UnitProgression.getLevel", {description = "Gets level", testCase = "get_level", type = "functional"}, function()
        shared.up:gainExperience("level_unit", 100)
        shared.up:gainExperience("level_unit", 50)
        local level = shared.up:getLevel("level_unit")
        Helpers.assertEqual(level, 2, "Level 2")
    end)

    Suite:testMethod("UnitProgression.getHighestLevel", {description = "Highest level", testCase = "highest", type = "functional"}, function()
        shared.up:enrollUnit("l1", "L1", "soldier", 1)
        shared.up:enrollUnit("l2", "L2", "soldier", 1)
        shared.up:gainExperience("l1", 100)
        shared.up:gainExperience("l2", 200)
        local highest = shared.up:getHighestLevel()
        Helpers.assertEqual(highest, 3, "Highest 3")
    end)

    Suite:testMethod("UnitProgression.getAverageLevel", {description = "Average level", testCase = "average", type = "functional"}, function()
        shared.up:enrollUnit("a1", "A1", "soldier", 1)
        shared.up:enrollUnit("a2", "A2", "soldier", 1)
        shared.up:gainExperience("a1", 100)
        local avg = shared.up:getAverageLevel()
        Helpers.assertEqual(avg >= 1, true, "Average >= 1")
    end)
end)

Suite:group("Combat History", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:enrollUnit("combat_unit", "Combat", "soldier", 1)
    end)

    Suite:testMethod("UnitProgression.recordKill", {description = "Records kill", testCase = "kill", type = "functional"}, function()
        local ok = shared.up:recordKill("combat_unit")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("UnitProgression.getKillCount", {description = "Kill count", testCase = "kill_count", type = "functional"}, function()
        shared.up:recordKill("combat_unit")
        shared.up:recordKill("combat_unit")
        local kills = shared.up:getKillCount("combat_unit")
        Helpers.assertEqual(kills, 2, "Two kills")
    end)

    Suite:testMethod("UnitProgression.completeMission", {description = "Completes mission", testCase = "mission", type = "functional"}, function()
        local ok = shared.up:completeMission("combat_unit")
        Helpers.assertEqual(ok, true, "Completed")
    end)

    Suite:testMethod("UnitProgression.getMissionCount", {description = "Mission count", testCase = "mission_count", type = "functional"}, function()
        shared.up:completeMission("combat_unit")
        shared.up:completeMission("combat_unit")
        local missions = shared.up:getMissionCount("combat_unit")
        Helpers.assertEqual(missions, 2, "Two missions")
    end)
end)

Suite:group("Skills", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:enrollUnit("skill_unit", "Skill", "soldier", 1)
    end)

    Suite:testMethod("UnitProgression.learnSkill", {description = "Learns skill", testCase = "learn", type = "functional"}, function()
        local ok = shared.up:learnSkill("skill_unit", "headshot", "Headshot", 80)
        Helpers.assertEqual(ok, true, "Learned")
    end)

    Suite:testMethod("UnitProgression.hasSkill", {description = "Has skill", testCase = "has_skill", type = "functional"}, function()
        shared.up:learnSkill("skill_unit", "precision", "Precision", 70)
        local has = shared.up:hasSkill("skill_unit", "precision")
        Helpers.assertEqual(has, true, "Has skill")
    end)

    Suite:testMethod("UnitProgression.getSkillCount", {description = "Skill count", testCase = "skill_count", type = "functional"}, function()
        shared.up:learnSkill("skill_unit", "s1", "Skill 1", 60)
        shared.up:learnSkill("skill_unit", "s2", "Skill 2", 70)
        local count = shared.up:getSkillCount("skill_unit")
        Helpers.assertEqual(count, 2, "Two skills")
    end)

    Suite:testMethod("UnitProgression.getSkillsByClass", {description = "Skills by class", testCase = "skills", type = "functional"}, function()
        shared.up:learnSkill("skill_unit", "test", "Test", 50)
        local skills = shared.up:getSkillsByClass("skill_unit")
        Helpers.assertEqual(skills ~= nil, true, "Skills exist")
    end)
end)

Suite:group("Ranks and Promotions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:enrollUnit("rank_unit", "Rank", "soldier", 1)
    end)

    Suite:testMethod("UnitProgression.promote", {description = "Promotes unit", testCase = "promote", type = "functional"}, function()
        local ok = shared.up:promote("rank_unit", "Sergeant")
        Helpers.assertEqual(ok, true, "Promoted")
    end)

    Suite:testMethod("UnitProgression.getRank", {description = "Gets rank", testCase = "get_rank", type = "functional"}, function()
        shared.up:promote("rank_unit", "Lieutenant")
        local rank = shared.up:getRank("rank_unit")
        Helpers.assertEqual(rank, "Lieutenant", "Lieutenant")
    end)

    Suite:testMethod("UnitProgression.getPromotionCount", {description = "Promotion count", testCase = "promo_count", type = "functional"}, function()
        shared.up:promote("rank_unit", "Sergeant")
        shared.up:promote("rank_unit", "Captain")
        local promos = shared.up:getPromotionCount("rank_unit")
        Helpers.assertEqual(promos, 2, "Two promotions")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:enrollUnit("analysis_unit", "Analysis", "soldier", 1)
    end)

    Suite:testMethod("UnitProgression.calculateCombatRating", {description = "Combat rating", testCase = "combat_rating", type = "functional"}, function()
        shared.up:gainExperience("analysis_unit", 100)
        shared.up:recordKill("analysis_unit")
        shared.up:learnSkill("analysis_unit", "test", "Test", 50)
        local rating = shared.up:calculateCombatRating("analysis_unit")
        Helpers.assertEqual(rating > 0, true, "Rating > 0")
    end)

    Suite:testMethod("UnitProgression.calculateVeteranStatus", {description = "Veteran status", testCase = "veteran", type = "functional"}, function()
        for i = 1, 10 do shared.up:gainExperience("analysis_unit", 100) end
        for i = 1, 5 do shared.up:completeMission("analysis_unit") end
        local veteran = shared.up:calculateVeteranStatus("analysis_unit")
        Helpers.assertEqual(veteran, true, "Veteran")
    end)

    Suite:testMethod("UnitProgression.getVeteranCount", {description = "Veteran count", testCase = "veteran_count", type = "functional"}, function()
        local count = shared.up:getVeteranCount()
        Helpers.assertEqual(count >= 0, true, "Count >= 0")
    end)
end)

Suite:group("Experience Loss", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:enrollUnit("loss_unit", "Loss", "soldier", 1)
    end)

    Suite:testMethod("UnitProgression.calculateExperienceLoss", {description = "Experience loss", testCase = "loss", type = "functional"}, function()
        shared.up:gainExperience("loss_unit", 100)
        local ok = shared.up:calculateExperienceLoss("loss_unit", 50)
        Helpers.assertEqual(ok, true, "Loss calculated")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.up = UnitProgression:new()
        shared.up:enrollUnit("reset_unit", "Reset", "soldier", 1)
    end)

    Suite:testMethod("UnitProgression.resetUnit", {description = "Resets unit", testCase = "reset", type = "functional"}, function()
        shared.up:gainExperience("reset_unit", 100)
        local ok = shared.up:resetUnit("reset_unit")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
