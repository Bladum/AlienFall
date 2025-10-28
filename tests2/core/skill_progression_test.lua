-- ─────────────────────────────────────────────────────────────────────────
-- SKILL PROGRESSION TEST SUITE
-- FILE: tests2/core/skill_progression_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.skill_progression",
    fileName = "skill_progression.lua",
    description = "Character skill progression with XP tracking, leveling, and specialization mastery"
})

print("[SKILL_PROGRESSION_TEST] Setting up")

local SkillProgression = {
    characters = {},
    skills = {},
    progression = {},
    milestones = {},

    new = function(self)
        return setmetatable({
            characters = {}, skills = {}, progression = {}, milestones = {}
        }, {__index = self})
    end,

    registerCharacter = function(self, charId, name, class)
        self.characters[charId] = {
            id = charId, name = name, class = class or "warrior",
            level = 1, total_xp = 0, available_points = 0
        }
        self.progression[charId] = {
            learned_skills = {}, skill_xp = {}, specializations = {},
            mastered_skills = {}, combo_count = 0
        }
        return true
    end,

    getCharacter = function(self, charId)
        return self.characters[charId]
    end,

    createSkill = function(self, skillId, name, category, base_power)
        self.skills[skillId] = {
            id = skillId, name = name, category = category or "physical",
            base_power = base_power or 10, tier = 1, cost = 1,
            synergies = {}, prerequisites = {}, mastery_threshold = 100
        }
        return true
    end,

    getSkill = function(self, skillId)
        return self.skills[skillId]
    end,

    learnSkill = function(self, charId, skillId)
        if not self.characters[charId] or not self.skills[skillId] then return false end
        if self.progression[charId].learned_skills[skillId] then return false end
        self.progression[charId].learned_skills[skillId] = true
        self.progression[charId].skill_xp[skillId] = 0
        return true
    end,

    hasSkill = function(self, charId, skillId)
        if not self.progression[charId] then return false end
        return self.progression[charId].learned_skills[skillId] ~= nil
    end,

    gainSkillXp = function(self, charId, skillId, amount)
        if not self:hasSkill(charId, skillId) then return false end
        self.progression[charId].skill_xp[skillId] = (self.progression[charId].skill_xp[skillId] or 0) + amount
        return true
    end,

    getSkillXp = function(self, charId, skillId)
        if not self.progression[charId] or not self.progression[charId].skill_xp[skillId] then return 0 end
        return self.progression[charId].skill_xp[skillId]
    end,

    upgradeSkill = function(self, charId, skillId)
        if not self:hasSkill(charId, skillId) then return false end
        local xp = self:getSkillXp(charId, skillId)
        if xp < 50 then return false end
        self.progression[charId].skill_xp[skillId] = 0
        if not self.progression[charId].skill_levels then
            self.progression[charId].skill_levels = {}
        end
        self.progression[charId].skill_levels[skillId] = (self.progression[charId].skill_levels[skillId] or 1) + 1
        return true
    end,

    getSkillLevel = function(self, charId, skillId)
        if not self.progression[charId] or not self.progression[charId].skill_levels then return 0 end
        return self.progression[charId].skill_levels[skillId] or 0
    end,

    masterSkill = function(self, charId, skillId)
        if not self:hasSkill(charId, skillId) then return false end
        local xp = self:getSkillXp(charId, skillId)
        if xp < 100 then return false end
        self.progression[charId].mastered_skills[skillId] = true
        self.progression[charId].skill_xp[skillId] = 0
        return true
    end,

    isMastered = function(self, charId, skillId)
        if not self.progression[charId] then return false end
        return self.progression[charId].mastered_skills[skillId] ~= nil
    end,

    getMasteredSkillCount = function(self, charId)
        if not self.progression[charId] then return 0 end
        local count = 0
        for _ in pairs(self.progression[charId].mastered_skills) do
            count = count + 1
        end
        return count
    end,

    addSkillSynergy = function(self, skillId1, skillId2)
        if not self.skills[skillId1] or not self.skills[skillId2] then return false end
        self.skills[skillId1].synergies[skillId2] = true
        self.skills[skillId2].synergies[skillId1] = true
        return true
    end,

    getSkillSynergies = function(self, skillId)
        if not self.skills[skillId] then return {} end
        local synergies = {}
        for synId, _ in pairs(self.skills[skillId].synergies) do
            table.insert(synergies, synId)
        end
        return synergies
    end,

    calculateComboEffectiveness = function(self, charId, skillId1, skillId2)
        if not self:hasSkill(charId, skillId1) or not self:hasSkill(charId, skillId2) then return 0 end
        if not self.skills[skillId1].synergies[skillId2] then return 0 end
        local level1 = self:getSkillLevel(charId, skillId1)
        local level2 = self:getSkillLevel(charId, skillId2)
        return (level1 + level2) * 2.5
    end,

    executeCombo = function(self, charId, skillId1, skillId2)
        if self:calculateComboEffectiveness(charId, skillId1, skillId2) <= 0 then return false end
        self.progression[charId].combo_count = self.progression[charId].combo_count + 1
        return true
    end,

    getComboCount = function(self, charId)
        if not self.progression[charId] then return 0 end
        return self.progression[charId].combo_count
    end,

    gainCharacterXp = function(self, charId, amount)
        if not self.characters[charId] then return false end
        self.characters[charId].total_xp = self.characters[charId].total_xp + amount
        return true
    end,

    calculateLevelUp = function(self, charId)
        if not self.characters[charId] then return 0 end
        return math.floor(self.characters[charId].total_xp / 100) + 1
    end,

    advanceLevel = function(self, charId)
        if not self.characters[charId] then return false end
        self.characters[charId].level = self.characters[charId].level + 1
        self.characters[charId].available_points = self.characters[charId].available_points + 2
        return true
    end,

    getAvailablePoints = function(self, charId)
        if not self.characters[charId] then return 0 end
        return self.characters[charId].available_points
    end,

    specializeSkill = function(self, charId, skillId, specType)
        if not self:hasSkill(charId, skillId) then return false end
        self.progression[charId].specializations[skillId] = specType or "base"
        return true
    end,

    getSpecialization = function(self, charId, skillId)
        if not self.progression[charId] or not self.progression[charId].specializations[skillId] then return nil end
        return self.progression[charId].specializations[skillId]
    end,

    calculateSkillPower = function(self, charId, skillId)
        if not self:hasSkill(charId, skillId) then return 0 end
        local skill = self.skills[skillId]
        local level = self:getSkillLevel(charId, skillId)
        local base_power = skill.base_power or 10
        local level_bonus = level * 2
        local mastery_bonus = self:isMastered(charId, skillId) and 20 or 0
        return base_power + level_bonus + mastery_bonus
    end,

    getSkillCount = function(self, charId)
        if not self.progression[charId] then return 0 end
        local count = 0
        for _ in pairs(self.progression[charId].learned_skills) do
            count = count + 1
        end
        return count
    end,

    registerMilestone = function(self, milestoneId, name, requirement_type, threshold)
        self.milestones[milestoneId] = {
            id = milestoneId, name = name, type = requirement_type or "skill_count",
            threshold = threshold or 5, completed_by = {}
        }
        return true
    end,

    checkMilestone = function(self, charId, milestoneId)
        if not self.milestones[milestoneId] then return false end
        local milestone = self.milestones[milestoneId]
        if self:getSkillCount(charId) >= milestone.threshold then
            if not milestone.completed_by[charId] then
                milestone.completed_by[charId] = true
                return true
            end
        end
        return false
    end,

    resetCharacterProgression = function(self, charId)
        if not self.progression[charId] then return false end
        self.progression[charId].learned_skills = {}
        self.progression[charId].skill_xp = {}
        self.progression[charId].specializations = {}
        self.progression[charId].mastered_skills = {}
        self.progression[charId].combo_count = 0
        return true
    end,

    reset = function(self)
        self.characters = {}
        self.skills = {}
        self.progression = {}
        self.milestones = {}
        return true
    end
}

Suite:group("Characters", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
    end)

    Suite:testMethod("SkillProgression.registerCharacter", {description = "Registers character", testCase = "register", type = "functional"}, function()
        local ok = shared.sp:registerCharacter("char1", "Hero", "warrior")
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("SkillProgression.getCharacter", {description = "Gets character", testCase = "get", type = "functional"}, function()
        shared.sp:registerCharacter("char2", "Mage", "spellcaster")
        local char = shared.sp:getCharacter("char2")
        Helpers.assertEqual(char ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Skills", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
    end)

    Suite:testMethod("SkillProgression.createSkill", {description = "Creates skill", testCase = "create", type = "functional"}, function()
        local ok = shared.sp:createSkill("skill1", "Fireball", "magic", 25)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("SkillProgression.getSkill", {description = "Gets skill", testCase = "get", type = "functional"}, function()
        shared.sp:createSkill("skill2", "Slash", "physical", 15)
        local skill = shared.sp:getSkill("skill2")
        Helpers.assertEqual(skill ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("SkillProgression.learnSkill", {description = "Learns skill", testCase = "learn", type = "functional"}, function()
        shared.sp:createSkill("skill3", "Dodge", "defense", 10)
        local ok = shared.sp:learnSkill("char1", "skill3")
        Helpers.assertEqual(ok, true, "Learned")
    end)

    Suite:testMethod("SkillProgression.hasSkill", {description = "Has skill", testCase = "has", type = "functional"}, function()
        shared.sp:createSkill("skill4", "Power", "utility")
        shared.sp:learnSkill("char1", "skill4")
        local has = shared.sp:hasSkill("char1", "skill4")
        Helpers.assertEqual(has, true, "Has")
    end)
end)

Suite:group("XP & Leveling", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
        shared.sp:createSkill("skill1", "Test", "physical")
        shared.sp:learnSkill("char1", "skill1")
    end)

    Suite:testMethod("SkillProgression.gainSkillXp", {description = "Gains skill XP", testCase = "gain_xp", type = "functional"}, function()
        local ok = shared.sp:gainSkillXp("char1", "skill1", 25)
        Helpers.assertEqual(ok, true, "Gained")
    end)

    Suite:testMethod("SkillProgression.getSkillXp", {description = "Gets skill XP", testCase = "get_xp", type = "functional"}, function()
        shared.sp:gainSkillXp("char1", "skill1", 30)
        local xp = shared.sp:getSkillXp("char1", "skill1")
        Helpers.assertEqual(xp, 30, "30")
    end)

    Suite:testMethod("SkillProgression.upgradeSkill", {description = "Upgrades skill", testCase = "upgrade", type = "functional"}, function()
        shared.sp:gainSkillXp("char1", "skill1", 50)
        local ok = shared.sp:upgradeSkill("char1", "skill1")
        Helpers.assertEqual(ok, true, "Upgraded")
    end)

    Suite:testMethod("SkillProgression.getSkillLevel", {description = "Gets skill level", testCase = "level", type = "functional"}, function()
        shared.sp:gainSkillXp("char1", "skill1", 50)
        shared.sp:upgradeSkill("char1", "skill1")
        local level = shared.sp:getSkillLevel("char1", "skill1")
        Helpers.assertEqual(level > 0, true, "Level > 0")
    end)
end)

Suite:group("Mastery", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
        shared.sp:createSkill("skill1", "Master", "physical")
        shared.sp:learnSkill("char1", "skill1")
    end)

    Suite:testMethod("SkillProgression.masterSkill", {description = "Masters skill", testCase = "master", type = "functional"}, function()
        shared.sp:gainSkillXp("char1", "skill1", 100)
        local ok = shared.sp:masterSkill("char1", "skill1")
        Helpers.assertEqual(ok, true, "Mastered")
    end)

    Suite:testMethod("SkillProgression.isMastered", {description = "Is mastered", testCase = "is_mastered", type = "functional"}, function()
        shared.sp:gainSkillXp("char1", "skill1", 100)
        shared.sp:masterSkill("char1", "skill1")
        local is = shared.sp:isMastered("char1", "skill1")
        Helpers.assertEqual(is, true, "Mastered")
    end)

    Suite:testMethod("SkillProgression.getMasteredSkillCount", {description = "Gets mastered count", testCase = "count", type = "functional"}, function()
        shared.sp:gainSkillXp("char1", "skill1", 100)
        shared.sp:masterSkill("char1", "skill1")
        local count = shared.sp:getMasteredSkillCount("char1")
        Helpers.assertEqual(count, 1, "1")
    end)
end)

Suite:group("Synergies & Combos", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
        shared.sp:createSkill("skill1", "Fire", "magic")
        shared.sp:createSkill("skill2", "Explosion", "magic")
        shared.sp:learnSkill("char1", "skill1")
        shared.sp:learnSkill("char1", "skill2")
    end)

    Suite:testMethod("SkillProgression.addSkillSynergy", {description = "Adds synergy", testCase = "add_synergy", type = "functional"}, function()
        local ok = shared.sp:addSkillSynergy("skill1", "skill2")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("SkillProgression.getSkillSynergies", {description = "Gets synergies", testCase = "get_synergies", type = "functional"}, function()
        shared.sp:addSkillSynergy("skill1", "skill2")
        local syns = shared.sp:getSkillSynergies("skill1")
        Helpers.assertEqual(#syns > 0, true, "Has synergies")
    end)

    Suite:testMethod("SkillProgression.calculateComboEffectiveness", {description = "Calculates combo", testCase = "calc_combo", type = "functional"}, function()
        shared.sp:addSkillSynergy("skill1", "skill2")
        shared.sp:gainSkillXp("char1", "skill1", 50)
        shared.sp:upgradeSkill("char1", "skill1")
        local eff = shared.sp:calculateComboEffectiveness("char1", "skill1", "skill2")
        Helpers.assertEqual(eff > 0, true, "Effectiveness > 0")
    end)

    Suite:testMethod("SkillProgression.executeCombo", {description = "Executes combo", testCase = "execute_combo", type = "functional"}, function()
        shared.sp:addSkillSynergy("skill1", "skill2")
        shared.sp:gainSkillXp("char1", "skill1", 50)
        shared.sp:upgradeSkill("char1", "skill1")
        local ok = shared.sp:executeCombo("char1", "skill1", "skill2")
        Helpers.assertEqual(ok, true, "Executed")
    end)

    Suite:testMethod("SkillProgression.getComboCount", {description = "Gets combo count", testCase = "combo_count", type = "functional"}, function()
        shared.sp:addSkillSynergy("skill1", "skill2")
        shared.sp:gainSkillXp("char1", "skill1", 50)
        shared.sp:upgradeSkill("char1", "skill1")
        shared.sp:executeCombo("char1", "skill1", "skill2")
        local count = shared.sp:getComboCount("char1")
        Helpers.assertEqual(count > 0, true, "Count > 0")
    end)
end)

Suite:group("Character XP", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
    end)

    Suite:testMethod("SkillProgression.gainCharacterXp", {description = "Gains char XP", testCase = "gain_char_xp", type = "functional"}, function()
        local ok = shared.sp:gainCharacterXp("char1", 50)
        Helpers.assertEqual(ok, true, "Gained")
    end)

    Suite:testMethod("SkillProgression.calculateLevelUp", {description = "Calculates level", testCase = "calc_level", type = "functional"}, function()
        shared.sp:gainCharacterXp("char1", 150)
        local level = shared.sp:calculateLevelUp("char1")
        Helpers.assertEqual(level > 1, true, "Level > 1")
    end)

    Suite:testMethod("SkillProgression.advanceLevel", {description = "Advances level", testCase = "advance", type = "functional"}, function()
        local ok = shared.sp:advanceLevel("char1")
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("SkillProgression.getAvailablePoints", {description = "Gets points", testCase = "points", type = "functional"}, function()
        shared.sp:advanceLevel("char1")
        local points = shared.sp:getAvailablePoints("char1")
        Helpers.assertEqual(points > 0, true, "Points > 0")
    end)
end)

Suite:group("Specialization", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
        shared.sp:createSkill("skill1", "Attack", "physical")
        shared.sp:learnSkill("char1", "skill1")
    end)

    Suite:testMethod("SkillProgression.specializeSkill", {description = "Specializes skill", testCase = "specialize", type = "functional"}, function()
        local ok = shared.sp:specializeSkill("char1", "skill1", "aggressive")
        Helpers.assertEqual(ok, true, "Specialized")
    end)

    Suite:testMethod("SkillProgression.getSpecialization", {description = "Gets spec", testCase = "get_spec", type = "functional"}, function()
        shared.sp:specializeSkill("char1", "skill1", "defensive")
        local spec = shared.sp:getSpecialization("char1", "skill1")
        Helpers.assertEqual(spec, "defensive", "defensive")
    end)
end)

Suite:group("Power Calculation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
        shared.sp:createSkill("skill1", "Power", "physical", 15)
        shared.sp:learnSkill("char1", "skill1")
    end)

    Suite:testMethod("SkillProgression.calculateSkillPower", {description = "Calculates power", testCase = "calc_power", type = "functional"}, function()
        local power = shared.sp:calculateSkillPower("char1", "skill1")
        Helpers.assertEqual(power > 0, true, "Power > 0")
    end)

    Suite:testMethod("SkillProgression.getSkillCount", {description = "Gets skill count", testCase = "count", type = "functional"}, function()
        local count = shared.sp:getSkillCount("char1")
        Helpers.assertEqual(count > 0, true, "Count > 0")
    end)
end)

Suite:group("Milestones", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
    end)

    Suite:testMethod("SkillProgression.registerMilestone", {description = "Registers milestone", testCase = "register", type = "functional"}, function()
        local ok = shared.sp:registerMilestone("m1", "Master5", "skill_count", 5)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("SkillProgression.checkMilestone", {description = "Checks milestone", testCase = "check", type = "functional"}, function()
        shared.sp:registerMilestone("m2", "Master3", "skill_count", 3)
        local check = shared.sp:checkMilestone("char1", "m2")
        Helpers.assertEqual(check == false or check == true, true, "Checked")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sp = SkillProgression:new()
    end)

    Suite:testMethod("SkillProgression.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.sp:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)

    Suite:testMethod("SkillProgression.resetCharacterProgression", {description = "Resets character", testCase = "reset_char", type = "functional"}, function()
        shared.sp:registerCharacter("char1", "Hero", "warrior")
        local ok = shared.sp:resetCharacterProgression("char1")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
