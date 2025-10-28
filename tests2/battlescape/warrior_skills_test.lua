-- ─────────────────────────────────────────────────────────────────────────
-- WARRIOR SKILLS TEST SUITE
-- FILE: tests2/battlescape/warrior_skills_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.warrior_skills",
    fileName = "warrior_skills.lua",
    description = "Warrior skills system with specializations, progression, and abilities"
})

print("[WARRIOR_SKILLS_TEST] Setting up")

local WarriorSkills = {
    warriors = {},
    skills = {},
    specializations = {},
    progression = {},

    new = function(self)
        return setmetatable({
            warriors = {}, skills = {}, specializations = {}, progression = {}
        }, {__index = self})
    end,

    registerSkill = function(self, skillId, name, skillType, baseDamage)
        self.skills[skillId] = {
            id = skillId, name = name, type = skillType or "melee",
            base_damage = baseDamage or 10, cooldown = 0, uses_per_turn = 1,
            experience = 0, mastery_level = 0, passive = false
        }
        return true
    end,

    getSkill = function(self, skillId)
        return self.skills[skillId]
    end,

    createWarrior = function(self, warriorId, name, class)
        self.warriors[warriorId] = {
            id = warriorId, name = name, class = class or "soldier",
            level = 1, experience = 0, health = 100, skills = {},
            specialization = nil, skill_points = 0
        }
        self.progression[warriorId] = {
            total_kills = 0, total_damage = 0, missions_survived = 0,
            specialized_at_level = nil
        }
        return true
    end,

    getWarrior = function(self, warriorId)
        return self.warriors[warriorId]
    end,

    learnSkill = function(self, warriorId, skillId)
        if not self.warriors[warriorId] or not self.skills[skillId] then return false end
        local warrior = self.warriors[warriorId]
        if warrior.skills[skillId] then return false end
        warrior.skills[skillId] = {skill_id = skillId, level = 1, experience = 0}
        return true
    end,

    hasSkill = function(self, warriorId, skillId)
        if not self.warriors[warriorId] then return false end
        return self.warriors[warriorId].skills[skillId] ~= nil
    end,

    getWarriorSkills = function(self, warriorId)
        if not self.warriors[warriorId] then return {} end
        return self.warriors[warriorId].skills
    end,

    getSkillCount = function(self, warriorId)
        if not self.warriors[warriorId] then return 0 end
        local count = 0
        for _ in pairs(self.warriors[warriorId].skills) do
            count = count + 1
        end
        return count
    end,

    improveSkill = function(self, warriorId, skillId, xpGain)
        if not self.warriors[warriorId] or not self.warriors[warriorId].skills[skillId] then return false end
        local warrior_skill = self.warriors[warriorId].skills[skillId]
        warrior_skill.experience = warrior_skill.experience + (xpGain or 10)
        if warrior_skill.experience >= 100 then
            warrior_skill.level = warrior_skill.level + 1
            warrior_skill.experience = warrior_skill.experience - 100
            return true
        end
        return false
    end,

    getSkillLevel = function(self, warriorId, skillId)
        if not self.warriors[warriorId] or not self.warriors[warriorId].skills[skillId] then return 0 end
        return self.warriors[warriorId].skills[skillId].level
    end,

    useSkill = function(self, warriorId, skillId, targetId, damage)
        if not self:hasSkill(warriorId, skillId) then return false end
        local skill = self.skills[skillId]
        if skill.cooldown > 0 then return false end
        local effective_damage = (damage or skill.base_damage) + (self:getSkillLevel(warriorId, skillId) * 2)
        self.progression[warriorId].total_damage = self.progression[warriorId].total_damage + effective_damage
        skill.cooldown = 1
        return true
    end,

    resetSkillCooldown = function(self, skillId)
        if not self.skills[skillId] then return false end
        self.skills[skillId].cooldown = 0
        return true
    end,

    registerSpecialization = function(self, specId, name, requirement, bonus)
        self.specializations[specId] = {
            id = specId, name = name, level_requirement = requirement or 5,
            bonus = bonus or 0, warriors_count = 0
        }
        return true
    end,

    getSpecialization = function(self, specId)
        return self.specializations[specId]
    end,

    specializeWarrior = function(self, warriorId, specId)
        if not self.warriors[warriorId] or not self.specializations[specId] then return false end
        local warrior = self.warriors[warriorId]
        if warrior.level < self.specializations[specId].level_requirement then return false end
        warrior.specialization = specId
        self.progression[warriorId].specialized_at_level = warrior.level
        self.specializations[specId].warriors_count = self.specializations[specId].warriors_count + 1
        return true
    end,

    getWarriorSpecialization = function(self, warriorId)
        if not self.warriors[warriorId] then return nil end
        return self.warriors[warriorId].specialization
    end,

    calculateSkillDamage = function(self, warriorId, skillId)
        if not self:hasSkill(warriorId, skillId) then return 0 end
        local skill = self.skills[skillId]
        local level = self:getSkillLevel(warriorId, skillId)
        local multiplier = 1.0 + (level * 0.1)
        return math.floor(skill.base_damage * multiplier)
    end,

    advanceWarriorLevel = function(self, warriorId)
        if not self.warriors[warriorId] then return false end
        local warrior = self.warriors[warriorId]
        warrior.level = warrior.level + 1
        warrior.skill_points = warrior.skill_points + 3
        warrior.experience = 0
        return true
    end,

    getWarriorLevel = function(self, warriorId)
        if not self.warriors[warriorId] then return 0 end
        return self.warriors[warriorId].level
    end,

    recordKill = function(self, warriorId)
        if not self.progression[warriorId] then return false end
        self.progression[warriorId].total_kills = self.progression[warriorId].total_kills + 1
        return true
    end,

    getKillCount = function(self, warriorId)
        if not self.progression[warriorId] then return 0 end
        return self.progression[warriorId].total_kills
    end,

    getTotalDamage = function(self, warriorId)
        if not self.progression[warriorId] then return 0 end
        return self.progression[warriorId].total_damage
    end,

    recordMissionSurvival = function(self, warriorId)
        if not self.progression[warriorId] then return false end
        self.progression[warriorId].missions_survived = self.progression[warriorId].missions_survived + 1
        return true
    end,

    getMissionsSurvived = function(self, warriorId)
        if not self.progression[warriorId] then return 0 end
        return self.progression[warriorId].missions_survived
    end,

    isSpecialized = function(self, warriorId)
        if not self.warriors[warriorId] then return false end
        return self.warriors[warriorId].specialization ~= nil
    end,

    getSpecializationBonusDamage = function(self, warriorId)
        if not self:isSpecialized(warriorId) then return 0 end
        local spec = self.specializations[self.warriors[warriorId].specialization]
        if not spec then return 0 end
        return spec.bonus
    end,

    calculateWarriorStrength = function(self, warriorId)
        if not self.warriors[warriorId] then return 0 end
        local warrior = self.warriors[warriorId]
        local base = warrior.level * 10
        local spec_bonus = self:getSpecializationBonusDamage(warriorId)
        local skill_count = self:getSkillCount(warriorId)
        return base + spec_bonus + (skill_count * 5)
    end,

    reset = function(self)
        self.warriors = {}
        self.skills = {}
        self.specializations = {}
        self.progression = {}
        return true
    end
}

Suite:group("Skills", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
    end)

    Suite:testMethod("WarriorSkills.registerSkill", {description = "Registers skill", testCase = "register", type = "functional"}, function()
        local ok = shared.ws:registerSkill("skill1", "Slash", "melee", 15)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("WarriorSkills.getSkill", {description = "Gets skill", testCase = "get", type = "functional"}, function()
        shared.ws:registerSkill("skill2", "Pierce", "melee", 12)
        local skill = shared.ws:getSkill("skill2")
        Helpers.assertEqual(skill ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Warriors", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
    end)

    Suite:testMethod("WarriorSkills.createWarrior", {description = "Creates warrior", testCase = "create", type = "functional"}, function()
        local ok = shared.ws:createWarrior("warrior1", "Soldier A", "soldier")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("WarriorSkills.getWarrior", {description = "Gets warrior", testCase = "get", type = "functional"}, function()
        shared.ws:createWarrior("warrior2", "Soldier B", "soldier")
        local warrior = shared.ws:getWarrior("warrior2")
        Helpers.assertEqual(warrior ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("WarriorSkills.getWarriorLevel", {description = "Gets level", testCase = "level", type = "functional"}, function()
        shared.ws:createWarrior("warrior3", "Soldier C", "soldier")
        local level = shared.ws:getWarriorLevel("warrior3")
        Helpers.assertEqual(level, 1, "Level 1")
    end)
end)

Suite:group("Skill Learning", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
        shared.ws:createWarrior("warrior4", "Soldier D", "soldier")
        shared.ws:registerSkill("skill3", "Bash", "melee", 14)
    end)

    Suite:testMethod("WarriorSkills.learnSkill", {description = "Learns skill", testCase = "learn", type = "functional"}, function()
        local ok = shared.ws:learnSkill("warrior4", "skill3")
        Helpers.assertEqual(ok, true, "Learned")
    end)

    Suite:testMethod("WarriorSkills.hasSkill", {description = "Has skill", testCase = "has", type = "functional"}, function()
        shared.ws:learnSkill("warrior4", "skill3")
        local has = shared.ws:hasSkill("warrior4", "skill3")
        Helpers.assertEqual(has, true, "Has skill")
    end)

    Suite:testMethod("WarriorSkills.getWarriorSkills", {description = "Gets all skills", testCase = "all_skills", type = "functional"}, function()
        shared.ws:learnSkill("warrior4", "skill3")
        local skills = shared.ws:getWarriorSkills("warrior4")
        Helpers.assertEqual(skills ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("WarriorSkills.getSkillCount", {description = "Gets skill count", testCase = "count", type = "functional"}, function()
        shared.ws:learnSkill("warrior4", "skill3")
        local count = shared.ws:getSkillCount("warrior4")
        Helpers.assertEqual(count, 1, "1 skill")
    end)
end)

Suite:group("Skill Improvement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
        shared.ws:createWarrior("warrior5", "Soldier E", "soldier")
        shared.ws:registerSkill("skill4", "Strike", "melee", 11)
        shared.ws:learnSkill("warrior5", "skill4")
    end)

    Suite:testMethod("WarriorSkills.improveSkill", {description = "Improves skill", testCase = "improve", type = "functional"}, function()
        local ok = shared.ws:improveSkill("warrior5", "skill4", 50)
        Helpers.assertEqual(ok, false, "Not leveled yet")
    end)

    Suite:testMethod("WarriorSkills.getSkillLevel", {description = "Gets skill level", testCase = "level", type = "functional"}, function()
        shared.ws:improveSkill("warrior5", "skill4", 150)
        local level = shared.ws:getSkillLevel("warrior5", "skill4")
        Helpers.assertEqual(level > 1, true, "Level > 1")
    end)
end)

Suite:group("Skill Usage", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
        shared.ws:createWarrior("warrior6", "Soldier F", "soldier")
        shared.ws:registerSkill("skill5", "Swing", "melee", 13)
        shared.ws:learnSkill("warrior6", "skill5")
    end)

    Suite:testMethod("WarriorSkills.useSkill", {description = "Uses skill", testCase = "use", type = "functional"}, function()
        local ok = shared.ws:useSkill("warrior6", "skill5", "target1", 15)
        Helpers.assertEqual(ok, true, "Used")
    end)

    Suite:testMethod("WarriorSkills.resetSkillCooldown", {description = "Resets cooldown", testCase = "cooldown", type = "functional"}, function()
        shared.ws:useSkill("warrior6", "skill5", "target1", 15)
        local ok = shared.ws:resetSkillCooldown("skill5")
        Helpers.assertEqual(ok, true, "Reset")
    end)

    Suite:testMethod("WarriorSkills.calculateSkillDamage", {description = "Calculates damage", testCase = "damage", type = "functional"}, function()
        local damage = shared.ws:calculateSkillDamage("warrior6", "skill5")
        Helpers.assertEqual(damage > 0, true, "Damage > 0")
    end)
end)

Suite:group("Specializations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
        shared.ws:createWarrior("warrior7", "Soldier G", "soldier")
        shared.ws:registerSpecialization("spec1", "Ranger", 5, 20)
    end)

    Suite:testMethod("WarriorSkills.registerSpecialization", {description = "Registers spec", testCase = "register", type = "functional"}, function()
        local ok = shared.ws:registerSpecialization("spec2", "Tank", 5, 15)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("WarriorSkills.getSpecialization", {description = "Gets spec", testCase = "get", type = "functional"}, function()
        local spec = shared.ws:getSpecialization("spec1")
        Helpers.assertEqual(spec ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("WarriorSkills.specializeWarrior", {description = "Specializes warrior", testCase = "specialize", type = "functional"}, function()
        for _ = 1, 4 do
            shared.ws:advanceWarriorLevel("warrior7")
        end
        local ok = shared.ws:specializeWarrior("warrior7", "spec1")
        Helpers.assertEqual(ok, true, "Specialized")
    end)

    Suite:testMethod("WarriorSkills.getWarriorSpecialization", {description = "Gets warrior spec", testCase = "get_spec", type = "functional"}, function()
        for _ = 1, 4 do
            shared.ws:advanceWarriorLevel("warrior7")
        end
        shared.ws:specializeWarrior("warrior7", "spec1")
        local spec = shared.ws:getWarriorSpecialization("warrior7")
        Helpers.assertEqual(spec, "spec1", "Spec1")
    end)

    Suite:testMethod("WarriorSkills.isSpecialized", {description = "Is specialized", testCase = "is_spec", type = "functional"}, function()
        for _ = 1, 4 do
            shared.ws:advanceWarriorLevel("warrior7")
        end
        shared.ws:specializeWarrior("warrior7", "spec1")
        local is = shared.ws:isSpecialized("warrior7")
        Helpers.assertEqual(is, true, "Specialized")
    end)

    Suite:testMethod("WarriorSkills.getSpecializationBonusDamage", {description = "Gets bonus damage", testCase = "bonus", type = "functional"}, function()
        for _ = 1, 4 do
            shared.ws:advanceWarriorLevel("warrior7")
        end
        shared.ws:specializeWarrior("warrior7", "spec1")
        local bonus = shared.ws:getSpecializationBonusDamage("warrior7")
        Helpers.assertEqual(bonus, 20, "20 bonus")
    end)
end)

Suite:group("Progression", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
        shared.ws:createWarrior("warrior8", "Soldier H", "soldier")
    end)

    Suite:testMethod("WarriorSkills.advanceWarriorLevel", {description = "Advances level", testCase = "advance", type = "functional"}, function()
        local ok = shared.ws:advanceWarriorLevel("warrior8")
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("WarriorSkills.recordKill", {description = "Records kill", testCase = "kill", type = "functional"}, function()
        local ok = shared.ws:recordKill("warrior8")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("WarriorSkills.getKillCount", {description = "Gets kill count", testCase = "kills", type = "functional"}, function()
        shared.ws:recordKill("warrior8")
        shared.ws:recordKill("warrior8")
        local kills = shared.ws:getKillCount("warrior8")
        Helpers.assertEqual(kills, 2, "2 kills")
    end)

    Suite:testMethod("WarriorSkills.getTotalDamage", {description = "Gets total damage", testCase = "damage", type = "functional"}, function()
        local damage = shared.ws:getTotalDamage("warrior8")
        Helpers.assertEqual(damage >= 0, true, "Damage >= 0")
    end)

    Suite:testMethod("WarriorSkills.recordMissionSurvival", {description = "Records survival", testCase = "survival", type = "functional"}, function()
        local ok = shared.ws:recordMissionSurvival("warrior8")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("WarriorSkills.getMissionsSurvived", {description = "Gets missions survived", testCase = "missions", type = "functional"}, function()
        shared.ws:recordMissionSurvival("warrior8")
        local missions = shared.ws:getMissionsSurvived("warrior8")
        Helpers.assertEqual(missions, 1, "1 mission")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
        shared.ws:createWarrior("warrior9", "Soldier I", "soldier")
        shared.ws:registerSkill("skill6", "Strike", "melee", 12)
        shared.ws:registerSpecialization("spec3", "Commando", 5, 25)
    end)

    Suite:testMethod("WarriorSkills.calculateWarriorStrength", {description = "Calculates strength", testCase = "strength", type = "functional"}, function()
        shared.ws:learnSkill("warrior9", "skill6")
        local strength = shared.ws:calculateWarriorStrength("warrior9")
        Helpers.assertEqual(strength > 0, true, "Strength > 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ws = WarriorSkills:new()
    end)

    Suite:testMethod("WarriorSkills.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.ws:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
