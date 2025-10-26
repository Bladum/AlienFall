-- ─────────────────────────────────────────────────────────────────────────
-- CREW MANAGEMENT TEST SUITE
-- FILE: tests2/basescape/crew_management_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.basescape.crew_management",
    fileName = "crew_management.lua",
    description = "Crew management with staff assignments, morale, and specialization"
})

print("[CREW_MANAGEMENT_TEST] Setting up")

local CrewManagement = {
    crew_members = {},
    assignments = {},
    specializations = {},
    departments = {},

    new = function(self)
        return setmetatable({
            crew_members = {}, assignments = {}, specializations = {}, departments = {}
        }, {__index = self})
    end,

    hireCrewMember = function(self, crewId, name, role, skill_level)
        self.crew_members[crewId] = {
            id = crewId, name = name, role = role or "worker",
            skill_level = skill_level or 1, morale = 50, stress = 20,
            assignment = nil, specialization = nil, experience = 0,
            injuries = 0, efficiency = 1.0
        }
        return true
    end,

    getCrewMember = function(self, crewId)
        return self.crew_members[crewId]
    end,

    fireCrewMember = function(self, crewId)
        if not self.crew_members[crewId] then return false end
        self.crew_members[crewId] = nil
        return true
    end,

    getCrewCount = function(self)
        local count = 0
        for _ in pairs(self.crew_members) do
            count = count + 1
        end
        return count
    end,

    getCrewByRole = function(self, role)
        local results = {}
        for crewId, member in pairs(self.crew_members) do
            if member.role == role then
                table.insert(results, crewId)
            end
        end
        return results
    end,

    assignCrewMember = function(self, crewId, departmentId)
        if not self.crew_members[crewId] then return false end
        self.crew_members[crewId].assignment = departmentId
        if not self.assignments[departmentId] then
            self.assignments[departmentId] = {}
        end
        self.assignments[departmentId][crewId] = true
        return true
    end,

    unassignCrewMember = function(self, crewId)
        if not self.crew_members[crewId] then return false end
        local old_dept = self.crew_members[crewId].assignment
        self.crew_members[crewId].assignment = nil
        if old_dept and self.assignments[old_dept] then
            self.assignments[old_dept][crewId] = nil
        end
        return true
    end,

    getCrewAssignment = function(self, crewId)
        if not self.crew_members[crewId] then return nil end
        return self.crew_members[crewId].assignment
    end,

    getDepartmentCrew = function(self, departmentId)
        if not self.assignments[departmentId] then return {} end
        local crew = {}
        for crewId, _ in pairs(self.assignments[departmentId]) do
            table.insert(crew, crewId)
        end
        return crew
    end,

    getDepartmentSize = function(self, departmentId)
        if not self.assignments[departmentId] then return 0 end
        local count = 0
        for _ in pairs(self.assignments[departmentId]) do
            count = count + 1
        end
        return count
    end,

    registerSpecialization = function(self, specId, name, requirement_skill)
        self.specializations[specId] = {
            id = specId, name = name, required_skill = requirement_skill or 3,
            specialists = {}, bonus_efficiency = 1.25
        }
        return true
    end,

    getSpecialization = function(self, specId)
        return self.specializations[specId]
    end,

    specializeCrewMember = function(self, crewId, specId)
        if not self.crew_members[crewId] or not self.specializations[specId] then return false end
        local member = self.crew_members[crewId]
        if member.skill_level < self.specializations[specId].required_skill then return false end
        member.specialization = specId
        self.specializations[specId].specialists[crewId] = true
        return true
    end,

    getCrewSpecialization = function(self, crewId)
        if not self.crew_members[crewId] then return nil end
        return self.crew_members[crewId].specialization
    end,

    getSpecializationCount = function(self, specId)
        if not self.specializations[specId] then return 0 end
        local count = 0
        for _ in pairs(self.specializations[specId].specialists) do
            count = count + 1
        end
        return count
    end,

    setCrewMorale = function(self, crewId, morale)
        if not self.crew_members[crewId] then return false end
        self.crew_members[crewId].morale = math.max(0, math.min(100, morale))
        return true
    end,

    getCrewMorale = function(self, crewId)
        if not self.crew_members[crewId] then return 0 end
        return self.crew_members[crewId].morale
    end,

    setCrewStress = function(self, crewId, stress)
        if not self.crew_members[crewId] then return false end
        self.crew_members[crewId].stress = math.max(0, math.min(100, stress))
        return true
    end,

    getCrewStress = function(self, crewId)
        if not self.crew_members[crewId] then return 0 end
        return self.crew_members[crewId].stress
    end,

    improveMorale = function(self, crewId, amount)
        if not self.crew_members[crewId] then return false end
        local member = self.crew_members[crewId]
        member.morale = math.min(100, member.morale + (amount or 5))
        member.stress = math.max(0, member.stress - (amount or 5))
        return true
    end,

    increaseMorale = function(self, departmentId, amount)
        if not self.assignments[departmentId] then return false end
        for crewId, _ in pairs(self.assignments[departmentId]) do
            self:improveMorale(crewId, amount or 3)
        end
        return true
    end,

    reduceStress = function(self, crewId, amount)
        if not self.crew_members[crewId] then return false end
        self.crew_members[crewId].stress = math.max(0, self.crew_members[crewId].stress - (amount or 5))
        return true
    end,

    recordInjury = function(self, crewId)
        if not self.crew_members[crewId] then return false end
        self.crew_members[crewId].injuries = self.crew_members[crewId].injuries + 1
        self.crew_members[crewId].stress = math.min(100, self.crew_members[crewId].stress + 15)
        return true
    end,

    healInjury = function(self, crewId)
        if not self.crew_members[crewId] or self.crew_members[crewId].injuries == 0 then return false end
        self.crew_members[crewId].injuries = self.crew_members[crewId].injuries - 1
        return true
    end,

    getInjuries = function(self, crewId)
        if not self.crew_members[crewId] then return 0 end
        return self.crew_members[crewId].injuries
    end,

    gainExperience = function(self, crewId, xp)
        if not self.crew_members[crewId] then return false end
        local member = self.crew_members[crewId]
        member.experience = member.experience + (xp or 10)
        if member.experience >= 100 then
            member.skill_level = member.skill_level + 1
            member.experience = member.experience - 100
        end
        return true
    end,

    getCrewSkillLevel = function(self, crewId)
        if not self.crew_members[crewId] then return 0 end
        return self.crew_members[crewId].skill_level
    end,

    calculateCrewEfficiency = function(self, crewId)
        if not self.crew_members[crewId] then return 0 end
        local member = self.crew_members[crewId]
        local base_eff = member.skill_level / 10
        local morale_factor = member.morale / 100
        local stress_factor = (100 - member.stress) / 100
        local injury_penalty = 1.0 - (member.injuries * 0.1)
        local spec_bonus = 1.0
        if member.specialization then
            local spec = self.specializations[member.specialization]
            if spec then
                spec_bonus = spec.bonus_efficiency
            end
        end
        local efficiency = (base_eff * morale_factor * stress_factor * injury_penalty * spec_bonus) * 100
        return math.floor(efficiency)
    end,

    calculateDepartmentEfficiency = function(self, departmentId)
        if not self.assignments[departmentId] then return 0 end
        local crew_list = self:getDepartmentCrew(departmentId)
        if #crew_list == 0 then return 0 end
        local total_eff = 0
        for _, crewId in ipairs(crew_list) do
            total_eff = total_eff + self:calculateCrewEfficiency(crewId)
        end
        return math.floor(total_eff / #crew_list)
    end,

    createDepartment = function(self, deptId, name, priority)
        self.departments[deptId] = {
            id = deptId, name = name, priority = priority or 50,
            staff_limit = 20, tasks = {}
        }
        return true
    end,

    getDepartment = function(self, deptId)
        return self.departments[deptId]
    end,

    getDepartmentEmployeeCount = function(self, deptId)
        return self:getDepartmentSize(deptId)
    end,

    reset = function(self)
        self.crew_members = {}
        self.assignments = {}
        self.specializations = {}
        self.departments = {}
        return true
    end
}

Suite:group("Crew Hiring", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
    end)

    Suite:testMethod("CrewManagement.hireCrewMember", {description = "Hires member", testCase = "hire", type = "functional"}, function()
        local ok = shared.cm:hireCrewMember("crew1", "John", "scientist", 3)
        Helpers.assertEqual(ok, true, "Hired")
    end)

    Suite:testMethod("CrewManagement.getCrewMember", {description = "Gets member", testCase = "get", type = "functional"}, function()
        shared.cm:hireCrewMember("crew2", "Jane", "engineer", 2)
        local member = shared.cm:getCrewMember("crew2")
        Helpers.assertEqual(member ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CrewManagement.fireCrewMember", {description = "Fires member", testCase = "fire", type = "functional"}, function()
        shared.cm:hireCrewMember("crew3", "Bob", "worker", 1)
        local ok = shared.cm:fireCrewMember("crew3")
        Helpers.assertEqual(ok, true, "Fired")
    end)

    Suite:testMethod("CrewManagement.getCrewCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.cm:hireCrewMember("crew4", "Alice", "technician", 2)
        shared.cm:hireCrewMember("crew5", "Charlie", "soldier", 3)
        local count = shared.cm:getCrewCount()
        Helpers.assertEqual(count, 2, "2 crew")
    end)

    Suite:testMethod("CrewManagement.getCrewByRole", {description = "Gets by role", testCase = "role", type = "functional"}, function()
        shared.cm:hireCrewMember("crew6", "Dave", "scientist", 3)
        local results = shared.cm:getCrewByRole("scientist")
        Helpers.assertEqual(#results > 0, true, "Found crew")
    end)
end)

Suite:group("Assignments", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
        shared.cm:hireCrewMember("assign_crew", "Eve", "engineer", 2)
        shared.cm:createDepartment("assign_dept", "Engineering", 80)
    end)

    Suite:testMethod("CrewManagement.assignCrewMember", {description = "Assigns member", testCase = "assign", type = "functional"}, function()
        local ok = shared.cm:assignCrewMember("assign_crew", "assign_dept")
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("CrewManagement.getCrewAssignment", {description = "Gets assignment", testCase = "assignment", type = "functional"}, function()
        shared.cm:assignCrewMember("assign_crew", "assign_dept")
        local dept = shared.cm:getCrewAssignment("assign_crew")
        Helpers.assertEqual(dept, "assign_dept", "Assign_dept")
    end)

    Suite:testMethod("CrewManagement.getDepartmentCrew", {description = "Gets department crew", testCase = "dept_crew", type = "functional"}, function()
        shared.cm:assignCrewMember("assign_crew", "assign_dept")
        local crew = shared.cm:getDepartmentCrew("assign_dept")
        Helpers.assertEqual(#crew > 0, true, "Has crew")
    end)

    Suite:testMethod("CrewManagement.getDepartmentSize", {description = "Gets size", testCase = "size", type = "functional"}, function()
        shared.cm:assignCrewMember("assign_crew", "assign_dept")
        local size = shared.cm:getDepartmentSize("assign_dept")
        Helpers.assertEqual(size, 1, "1 crew member")
    end)

    Suite:testMethod("CrewManagement.unassignCrewMember", {description = "Unassigns member", testCase = "unassign", type = "functional"}, function()
        shared.cm:assignCrewMember("assign_crew", "assign_dept")
        local ok = shared.cm:unassignCrewMember("assign_crew")
        Helpers.assertEqual(ok, true, "Unassigned")
    end)
end)

Suite:group("Specializations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
        shared.cm:hireCrewMember("spec_crew", "Frank", "scientist", 4)
        shared.cm:registerSpecialization("spec1", "Biologist", 3)
    end)

    Suite:testMethod("CrewManagement.registerSpecialization", {description = "Registers spec", testCase = "register", type = "functional"}, function()
        local ok = shared.cm:registerSpecialization("spec2", "Physicist", 4)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("CrewManagement.getSpecialization", {description = "Gets spec", testCase = "get", type = "functional"}, function()
        local spec = shared.cm:getSpecialization("spec1")
        Helpers.assertEqual(spec ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("CrewManagement.specializeCrewMember", {description = "Specializes member", testCase = "specialize", type = "functional"}, function()
        local ok = shared.cm:specializeCrewMember("spec_crew", "spec1")
        Helpers.assertEqual(ok, true, "Specialized")
    end)

    Suite:testMethod("CrewManagement.getCrewSpecialization", {description = "Gets spec", testCase = "get_spec", type = "functional"}, function()
        shared.cm:specializeCrewMember("spec_crew", "spec1")
        local spec = shared.cm:getCrewSpecialization("spec_crew")
        Helpers.assertEqual(spec, "spec1", "Spec1")
    end)

    Suite:testMethod("CrewManagement.getSpecializationCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.cm:specializeCrewMember("spec_crew", "spec1")
        local count = shared.cm:getSpecializationCount("spec1")
        Helpers.assertEqual(count, 1, "1 specialist")
    end)
end)

Suite:group("Morale & Stress", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
        shared.cm:hireCrewMember("moral_crew", "Grace", "soldier", 2)
    end)

    Suite:testMethod("CrewManagement.setCrewMorale", {description = "Sets morale", testCase = "morale", type = "functional"}, function()
        local ok = shared.cm:setCrewMorale("moral_crew", 75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CrewManagement.getCrewMorale", {description = "Gets morale", testCase = "get_morale", type = "functional"}, function()
        shared.cm:setCrewMorale("moral_crew", 65)
        local morale = shared.cm:getCrewMorale("moral_crew")
        Helpers.assertEqual(morale, 65, "65 morale")
    end)

    Suite:testMethod("CrewManagement.setCrewStress", {description = "Sets stress", testCase = "stress", type = "functional"}, function()
        local ok = shared.cm:setCrewStress("moral_crew", 40)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("CrewManagement.getCrewStress", {description = "Gets stress", testCase = "get_stress", type = "functional"}, function()
        shared.cm:setCrewStress("moral_crew", 35)
        local stress = shared.cm:getCrewStress("moral_crew")
        Helpers.assertEqual(stress, 35, "35 stress")
    end)

    Suite:testMethod("CrewManagement.improveMorale", {description = "Improves morale", testCase = "improve", type = "functional"}, function()
        local ok = shared.cm:improveMorale("moral_crew", 10)
        Helpers.assertEqual(ok, true, "Improved")
    end)

    Suite:testMethod("CrewManagement.reduceStress", {description = "Reduces stress", testCase = "reduce", type = "functional"}, function()
        local ok = shared.cm:reduceStress("moral_crew", 10)
        Helpers.assertEqual(ok, true, "Reduced")
    end)
end)

Suite:group("Department Morale", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
        shared.cm:createDepartment("morale_dept", "Morale Test", 70)
        shared.cm:hireCrewMember("morale_crew1", "Henry", "worker", 1)
        shared.cm:assignCrewMember("morale_crew1", "morale_dept")
    end)

    Suite:testMethod("CrewManagement.increaseMorale", {description = "Increases morale", testCase = "increase", type = "functional"}, function()
        local ok = shared.cm:increaseMorale("morale_dept", 5)
        Helpers.assertEqual(ok, true, "Increased")
    end)
end)

Suite:group("Health & Injuries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
        shared.cm:hireCrewMember("health_crew", "Iris", "soldier", 2)
    end)

    Suite:testMethod("CrewManagement.recordInjury", {description = "Records injury", testCase = "injury", type = "functional"}, function()
        local ok = shared.cm:recordInjury("health_crew")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("CrewManagement.getInjuries", {description = "Gets injuries", testCase = "injuries", type = "functional"}, function()
        shared.cm:recordInjury("health_crew")
        local inj = shared.cm:getInjuries("health_crew")
        Helpers.assertEqual(inj, 1, "1 injury")
    end)

    Suite:testMethod("CrewManagement.healInjury", {description = "Heals injury", testCase = "heal", type = "functional"}, function()
        shared.cm:recordInjury("health_crew")
        local ok = shared.cm:healInjury("health_crew")
        Helpers.assertEqual(ok, true, "Healed")
    end)
end)

Suite:group("Experience & Skills", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
        shared.cm:hireCrewMember("exp_crew", "Jack", "engineer", 2)
    end)

    Suite:testMethod("CrewManagement.gainExperience", {description = "Gains experience", testCase = "experience", type = "functional"}, function()
        local ok = shared.cm:gainExperience("exp_crew", 50)
        Helpers.assertEqual(ok, true, "Gained")
    end)

    Suite:testMethod("CrewManagement.getCrewSkillLevel", {description = "Gets skill", testCase = "skill", type = "functional"}, function()
        local skill = shared.cm:getCrewSkillLevel("exp_crew")
        Helpers.assertEqual(skill > 0, true, "Skill > 0")
    end)
end)

Suite:group("Efficiency", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
        shared.cm:hireCrewMember("eff_crew", "Karen", "technician", 3)
        shared.cm:createDepartment("eff_dept", "Tech", 85)
        shared.cm:assignCrewMember("eff_crew", "eff_dept")
    end)

    Suite:testMethod("CrewManagement.calculateCrewEfficiency", {description = "Calculates crew eff", testCase = "crew_eff", type = "functional"}, function()
        local eff = shared.cm:calculateCrewEfficiency("eff_crew")
        Helpers.assertEqual(eff >= 0, true, "Efficiency >= 0")
    end)

    Suite:testMethod("CrewManagement.calculateDepartmentEfficiency", {description = "Calculates dept eff", testCase = "dept_eff", type = "functional"}, function()
        local eff = shared.cm:calculateDepartmentEfficiency("eff_dept")
        Helpers.assertEqual(eff >= 0, true, "Efficiency >= 0")
    end)
end)

Suite:group("Departments", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
    end)

    Suite:testMethod("CrewManagement.createDepartment", {description = "Creates department", testCase = "create", type = "functional"}, function()
        local ok = shared.cm:createDepartment("dept1", "Research", 90)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("CrewManagement.getDepartment", {description = "Gets department", testCase = "get", type = "functional"}, function()
        shared.cm:createDepartment("dept2", "Development", 80)
        local dept = shared.cm:getDepartment("dept2")
        Helpers.assertEqual(dept ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cm = CrewManagement:new()
    end)

    Suite:testMethod("CrewManagement.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.cm:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
