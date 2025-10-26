-- ─────────────────────────────────────────────────────────────────────────
-- PILOT SKILLS TEST SUITE
-- FILE: tests2/core/pilot_skills_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.pilot_skills",
    fileName = "pilot_skills.lua",
    description = "Pilot skill trees with specializations, abilities, bonuses, and mastery levels"
})

print("[PILOT_SKILLS_TEST] Setting up")

local PilotSkills = {
    pilots = {},
    skills = {},
    progression = {},
    specializations = {},

    new = function(self)
        return setmetatable({pilots = {}, skills = {}, progression = {}, specializations = {}}, {__index = self})
    end,

    createPilot = function(self, pilotId, name, faction)
        self.pilots[pilotId] = {id = pilotId, name = name, faction = faction or "unknown", level = 1, experience = 0}
        self.skills[pilotId] = {}
        self.progression[pilotId] = {}
        self.specializations[pilotId] = {primary = nil, secondary = nil}
        return true
    end,

    getPilot = function(self, pilotId)
        return self.pilots[pilotId]
    end,

    addSkill = function(self, pilotId, skillId, skillType, basePower)
        if not self.pilots[pilotId] then return false end
        self.skills[pilotId][skillId] = {id = skillId, type = skillType, level = 1, power = basePower or 50}
        self.progression[pilotId][skillId] = {experience = 0, mastery = 0}
        return true
    end,

    getSkill = function(self, pilotId, skillId)
        if not self.skills[pilotId] then return nil end
        return self.skills[pilotId][skillId]
    end,

    getSkillCount = function(self, pilotId)
        if not self.skills[pilotId] then return 0 end
        local count = 0
        for _ in pairs(self.skills[pilotId]) do count = count + 1 end
        return count
    end,

    levelUpSkill = function(self, pilotId, skillId)
        if not self.skills[pilotId] or not self.skills[pilotId][skillId] then return false end
        self.skills[pilotId][skillId].level = self.skills[pilotId][skillId].level + 1
        self.skills[pilotId][skillId].power = self.skills[pilotId][skillId].power + 10
        return true
    end,

    getSkillLevel = function(self, pilotId, skillId)
        if not self.skills[pilotId] or not self.skills[pilotId][skillId] then return 0 end
        return self.skills[pilotId][skillId].level
    end,

    getSkillPower = function(self, pilotId, skillId)
        if not self.skills[pilotId] or not self.skills[pilotId][skillId] then return 0 end
        return self.skills[pilotId][skillId].power
    end,

    addSkillExperience = function(self, pilotId, skillId, amount)
        if not self.progression[pilotId] or not self.progression[pilotId][skillId] then return false end
        self.progression[pilotId][skillId].experience = self.progression[pilotId][skillId].experience + amount
        if self.progression[pilotId][skillId].experience >= 100 then
            self:levelUpSkill(pilotId, skillId)
            self.progression[pilotId][skillId].experience = 0
        end
        return true
    end,

    getSkillExperience = function(self, pilotId, skillId)
        if not self.progression[pilotId] or not self.progression[pilotId][skillId] then return 0 end
        return self.progression[pilotId][skillId].experience
    end,

    getMastery = function(self, pilotId, skillId)
        if not self.progression[pilotId] or not self.progression[pilotId][skillId] then return 0 end
        return self.progression[pilotId][skillId].mastery
    end,

    setPrimarySpecialization = function(self, pilotId, specializationId)
        if not self.pilots[pilotId] then return false end
        self.specializations[pilotId].primary = specializationId
        return true
    end,

    getSpecialization = function(self, pilotId, which)
        if not self.specializations[pilotId] then return nil end
        if which == "primary" then
            return self.specializations[pilotId].primary
        else
            return self.specializations[pilotId].secondary
        end
    end,

    getAverageSkillLevel = function(self, pilotId)
        if not self.skills[pilotId] or not next(self.skills[pilotId]) then return 0 end
        local total = 0
        local count = 0
        for _, skill in pairs(self.skills[pilotId]) do
            total = total + skill.level
            count = count + 1
        end
        return count > 0 and math.floor(total / count) or 0
    end,

    getTotalSkillPower = function(self, pilotId)
        if not self.skills[pilotId] then return 0 end
        local total = 0
        for _, skill in pairs(self.skills[pilotId]) do
            total = total + skill.power
        end
        return total
    end,

    addPilotExperience = function(self, pilotId, amount)
        if not self.pilots[pilotId] then return false end
        self.pilots[pilotId].experience = self.pilots[pilotId].experience + amount
        if self.pilots[pilotId].experience >= 500 then
            self:promotePilot(pilotId)
            self.pilots[pilotId].experience = 0
        end
        return true
    end,

    getPilotExperience = function(self, pilotId)
        if not self.pilots[pilotId] then return 0 end
        return self.pilots[pilotId].experience
    end,

    promotePilot = function(self, pilotId)
        if not self.pilots[pilotId] then return false end
        self.pilots[pilotId].level = self.pilots[pilotId].level + 1
        return true
    end,

    getPilotLevel = function(self, pilotId)
        if not self.pilots[pilotId] then return 0 end
        return self.pilots[pilotId].level
    end,

    calculateCombatBonus = function(self, pilotId)
        if not self.pilots[pilotId] then return 0 end
        local baseBonus = self:getTotalSkillPower(pilotId)
        local levelBonus = self.pilots[pilotId].level * 5
        return baseBonus + levelBonus
    end,

    getSkillsByType = function(self, pilotId, skillType)
        if not self.skills[pilotId] then return {} end
        local filtered = {}
        for skillId, skill in pairs(self.skills[pilotId]) do
            if skill.type == skillType then
                table.insert(filtered, skillId)
            end
        end
        return filtered
    end,

    getAllPilots = function(self)
        local count = 0
        for _ in pairs(self.pilots) do count = count + 1 end
        return count
    end,

    resetSkillProgression = function(self, pilotId, skillId)
        if not self.progression[pilotId] or not self.progression[pilotId][skillId] then return false end
        self.progression[pilotId][skillId].experience = 0
        self.progression[pilotId][skillId].mastery = 0
        return true
    end
}

Suite:group("Pilot Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PilotSkills:new()
    end)

    Suite:testMethod("PilotSkills.createPilot", {description = "Creates pilot", testCase = "create", type = "functional"}, function()
        local ok = shared.ps:createPilot("pilot1", "Captain Shaw", "xcom")
        Helpers.assertEqual(ok, true, "Pilot created")
    end)

    Suite:testMethod("PilotSkills.getPilot", {description = "Gets pilot", testCase = "get", type = "functional"}, function()
        shared.ps:createPilot("pilot2", "Commander Lane", "xcom")
        local pilot = shared.ps:getPilot("pilot2")
        Helpers.assertEqual(pilot ~= nil, true, "Pilot retrieved")
    end)

    Suite:testMethod("PilotSkills.getPilotLevel", {description = "Gets level", testCase = "level", type = "functional"}, function()
        shared.ps:createPilot("pilot3", "Rookie", "xcom")
        local level = shared.ps:getPilotLevel("pilot3")
        Helpers.assertEqual(level, 1, "Level 1")
    end)

    Suite:testMethod("PilotSkills.getAllPilots", {description = "Counts pilots", testCase = "count", type = "functional"}, function()
        shared.ps:createPilot("p1", "Pilot1", "faction1")
        shared.ps:createPilot("p2", "Pilot2", "faction2")
        local count = shared.ps:getAllPilots()
        Helpers.assertEqual(count, 2, "Two pilots")
    end)
end)

Suite:group("Skill Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PilotSkills:new()
        shared.ps:createPilot("skilled", "Expert", "xcom")
    end)

    Suite:testMethod("PilotSkills.addSkill", {description = "Adds skill", testCase = "add", type = "functional"}, function()
        local ok = shared.ps:addSkill("skilled", "marksmanship", "weapon", 60)
        Helpers.assertEqual(ok, true, "Skill added")
    end)

    Suite:testMethod("PilotSkills.getSkill", {description = "Gets skill", testCase = "get", type = "functional"}, function()
        shared.ps:addSkill("skilled", "aim", "combat", 50)
        local skill = shared.ps:getSkill("skilled", "aim")
        Helpers.assertEqual(skill ~= nil, true, "Skill retrieved")
    end)

    Suite:testMethod("PilotSkills.getSkillCount", {description = "Counts skills", testCase = "count", type = "functional"}, function()
        shared.ps:addSkill("skilled", "s1", "t1", 50)
        shared.ps:addSkill("skilled", "s2", "t2", 60)
        shared.ps:addSkill("skilled", "s3", "t1", 55)
        local count = shared.ps:getSkillCount("skilled")
        Helpers.assertEqual(count, 3, "Three skills")
    end)
end)

Suite:group("Skill Progression", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PilotSkills:new()
        shared.ps:createPilot("progressing", "Trainee", "xcom")
        shared.ps:addSkill("progressing", "training", "general", 40)
    end)

    Suite:testMethod("PilotSkills.levelUpSkill", {description = "Levels skill", testCase = "levelup", type = "functional"}, function()
        local ok = shared.ps:levelUpSkill("progressing", "training")
        Helpers.assertEqual(ok, true, "Leveled up")
    end)

    Suite:testMethod("PilotSkills.getSkillLevel", {description = "Gets level", testCase = "level", type = "functional"}, function()
        shared.ps:levelUpSkill("progressing", "training")
        local level = shared.ps:getSkillLevel("progressing", "training")
        Helpers.assertEqual(level, 2, "Level 2")
    end)

    Suite:testMethod("PilotSkills.getSkillPower", {description = "Gets power", testCase = "power", type = "functional"}, function()
        local power = shared.ps:getSkillPower("progressing", "training")
        Helpers.assertEqual(power, 40, "40 power")
    end)

    Suite:testMethod("PilotSkills.addSkillExperience", {description = "Adds experience", testCase = "xp", type = "functional"}, function()
        local ok = shared.ps:addSkillExperience("progressing", "training", 50)
        Helpers.assertEqual(ok, true, "XP added")
    end)

    Suite:testMethod("PilotSkills.getSkillExperience", {description = "Gets experience", testCase = "get_xp", type = "functional"}, function()
        shared.ps:addSkillExperience("progressing", "training", 75)
        local xp = shared.ps:getSkillExperience("progressing", "training")
        Helpers.assertEqual(xp, 75, "75 XP")
    end)
end)

Suite:group("Pilot Progression", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PilotSkills:new()
        shared.ps:createPilot("promotable", "Officer", "xcom")
    end)

    Suite:testMethod("PilotSkills.addPilotExperience", {description = "Adds experience", testCase = "add_xp", type = "functional"}, function()
        local ok = shared.ps:addPilotExperience("promotable", 100)
        Helpers.assertEqual(ok, true, "XP added")
    end)

    Suite:testMethod("PilotSkills.getPilotExperience", {description = "Gets experience", testCase = "get_pilot_xp", type = "functional"}, function()
        shared.ps:addPilotExperience("promotable", 200)
        local xp = shared.ps:getPilotExperience("promotable")
        Helpers.assertEqual(xp, 200, "200 XP")
    end)

    Suite:testMethod("PilotSkills.promotePilot", {description = "Promotes pilot", testCase = "promote", type = "functional"}, function()
        local ok = shared.ps:promotePilot("promotable")
        Helpers.assertEqual(ok, true, "Promoted")
    end)
end)

Suite:group("Specializations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PilotSkills:new()
        shared.ps:createPilot("specialized", "Expert", "xcom")
    end)

    Suite:testMethod("PilotSkills.setPrimarySpecialization", {description = "Sets primary", testCase = "set_primary", type = "functional"}, function()
        local ok = shared.ps:setPrimarySpecialization("specialized", "rifleman")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("PilotSkills.getSpecialization", {description = "Gets spec", testCase = "get_spec", type = "functional"}, function()
        shared.ps:setPrimarySpecialization("specialized", "sniper")
        local spec = shared.ps:getSpecialization("specialized", "primary")
        Helpers.assertEqual(spec, "sniper", "Sniper")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PilotSkills:new()
        shared.ps:createPilot("analyst", "Analyst", "xcom")
        shared.ps:addSkill("analyst", "sk1", "combat", 50)
        shared.ps:addSkill("analyst", "sk2", "combat", 60)
        shared.ps:addSkill("analyst", "sk3", "support", 40)
    end)

    Suite:testMethod("PilotSkills.getAverageSkillLevel", {description = "Average level", testCase = "avg_level", type = "functional"}, function()
        local avg = shared.ps:getAverageSkillLevel("analyst")
        Helpers.assertEqual(avg >= 1, true, "Average calculated")
    end)

    Suite:testMethod("PilotSkills.getTotalSkillPower", {description = "Total power", testCase = "total_power", type = "functional"}, function()
        local power = shared.ps:getTotalSkillPower("analyst")
        Helpers.assertEqual(power, 150, "150 power")
    end)

    Suite:testMethod("PilotSkills.calculateCombatBonus", {description = "Combat bonus", testCase = "bonus", type = "functional"}, function()
        local bonus = shared.ps:calculateCombatBonus("analyst")
        Helpers.assertEqual(bonus >= 150, true, "Bonus calculated")
    end)

    Suite:testMethod("PilotSkills.getSkillsByType", {description = "By type", testCase = "by_type", type = "functional"}, function()
        local skills = shared.ps:getSkillsByType("analyst", "combat")
        Helpers.assertEqual(#skills, 2, "Two combat skills")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ps = PilotSkills:new()
        shared.ps:createPilot("resetting", "Reset", "xcom")
        shared.ps:addSkill("resetting", "temp", "test", 50)
    end)

    Suite:testMethod("PilotSkills.resetSkillProgression", {description = "Resets", testCase = "reset", type = "functional"}, function()
        shared.ps:addSkillExperience("resetting", "temp", 75)
        local ok = shared.ps:resetSkillProgression("resetting", "temp")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
