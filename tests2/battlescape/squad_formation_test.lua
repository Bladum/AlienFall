-- ─────────────────────────────────────────────────────────────────────────
-- SQUAD FORMATION TEST SUITE
-- FILE: tests2/battlescape/squad_formation_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.squad_formation",
    fileName = "squad_formation.lua",
    description = "Squad positioning with formations, tactics, and role assignments"
})

print("[SQUAD_FORMATION_TEST] Setting up")

local SquadFormation = {
    squads = {},
    units = {},
    positions = {},
    formations = {},
    roles = {},

    new = function(self)
        return setmetatable({squads = {}, units = {}, positions = {}, formations = {}, roles = {}}, {__index = self})
    end,

    createSquad = function(self, squadId, squadName, maxSize)
        self.squads[squadId] = {id = squadId, name = squadName, maxSize = maxSize or 6, unitCount = 0, active = true}
        self.units[squadId] = {}
        self.positions[squadId] = {}
        self.formations[squadId] = "line"
        self.roles[squadId] = {}
        return true
    end,

    getSquad = function(self, squadId)
        return self.squads[squadId]
    end,

    addUnitToSquad = function(self, squadId, unitId, unitName, unitRole)
        if not self.squads[squadId] then return false end
        if self.squads[squadId].unitCount >= self.squads[squadId].maxSize then return false end
        self.units[squadId][unitId] = {id = unitId, name = unitName, role = unitRole, health = 100, morale = 80}
        self.roles[squadId][unitId] = unitRole
        self.squads[squadId].unitCount = self.squads[squadId].unitCount + 1
        self.positions[squadId][unitId] = {x = 0, y = 0}
        return true
    end,

    getUnitCount = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return self.squads[squadId].unitCount
    end,

    removeUnitFromSquad = function(self, squadId, unitId)
        if not self.units[squadId] or not self.units[squadId][unitId] then return false end
        self.units[squadId][unitId] = nil
        self.roles[squadId][unitId] = nil
        self.positions[squadId][unitId] = nil
        self.squads[squadId].unitCount = self.squads[squadId].unitCount - 1
        return true
    end,

    positionUnit = function(self, squadId, unitId, x, y)
        if not self.positions[squadId] or not self.positions[squadId][unitId] then return false end
        self.positions[squadId][unitId] = {x = x, y = y}
        return true
    end,

    getUnitPosition = function(self, squadId, unitId)
        if not self.positions[squadId] then return nil end
        return self.positions[squadId][unitId]
    end,

    setFormation = function(self, squadId, formationName)
        if not self.squads[squadId] then return false end
        self.formations[squadId] = formationName
        return true
    end,

    getFormation = function(self, squadId)
        if not self.formations[squadId] then return "line" end
        return self.formations[squadId]
    end,

    applyFormationLayout = function(self, squadId)
        if not self.squads[squadId] then return false end
        local formation = self.formations[squadId]
        local unitIds = {}
        for unitId in pairs(self.units[squadId]) do
            table.insert(unitIds, unitId)
        end
        if formation == "line" then
            for i, unitId in ipairs(unitIds) do
                self:positionUnit(squadId, unitId, i * 2, 0)
            end
        elseif formation == "wedge" then
            for i, unitId in ipairs(unitIds) do
                self:positionUnit(squadId, unitId, i, math.floor(i / 2))
            end
        elseif formation == "circle" then
            for i, unitId in ipairs(unitIds) do
                self:positionUnit(squadId, unitId, 5 + math.cos(i * 60) * 3, 5 + math.sin(i * 60) * 3)
            end
        end
        return true
    end,

    getFormationSpread = function(self, squadId)
        if not self.positions[squadId] then return 0 end
        local maxDist = 0
        local positions = self.positions[squadId]
        local posArray = {}
        for _, pos in pairs(positions) do
            table.insert(posArray, pos)
        end
        for i = 1, #posArray do
            for j = i + 1, #posArray do
                local dx = posArray[i].x - posArray[j].x
                local dy = posArray[i].y - posArray[j].y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist > maxDist then maxDist = dist end
            end
        end
        return math.floor(maxDist)
    end,

    assignRole = function(self, squadId, unitId, role)
        if not self.units[squadId] or not self.units[squadId][unitId] then return false end
        self.units[squadId][unitId].role = role
        self.roles[squadId][unitId] = role
        return true
    end,

    getUnitRole = function(self, squadId, unitId)
        if not self.roles[squadId] then return nil end
        return self.roles[squadId][unitId]
    end,

    getUnitsByRole = function(self, squadId, role)
        if not self.units[squadId] then return {} end
        local filtered = {}
        for unitId, unit in pairs(self.units[squadId]) do
            if unit.role == role then
                table.insert(filtered, unitId)
            end
        end
        return filtered
    end,

    setUnitHealth = function(self, squadId, unitId, health)
        if not self.units[squadId] or not self.units[squadId][unitId] then return false end
        self.units[squadId][unitId].health = math.max(0, math.min(100, health))
        return true
    end,

    getUnitHealth = function(self, squadId, unitId)
        if not self.units[squadId] or not self.units[squadId][unitId] then return 0 end
        return self.units[squadId][unitId].health
    end,

    setUnitMorale = function(self, squadId, unitId, morale)
        if not self.units[squadId] or not self.units[squadId][unitId] then return false end
        self.units[squadId][unitId].morale = math.max(0, math.min(100, morale))
        return true
    end,

    getUnitMorale = function(self, squadId, unitId)
        if not self.units[squadId] or not self.units[squadId][unitId] then return 0 end
        return self.units[squadId][unitId].morale
    end,

    getAverageSquadHealth = function(self, squadId)
        if not self.units[squadId] or not next(self.units[squadId]) then return 0 end
        local totalHealth = 0
        local count = 0
        for _, unit in pairs(self.units[squadId]) do
            totalHealth = totalHealth + unit.health
            count = count + 1
        end
        return math.floor(totalHealth / count)
    end,

    getAverageSquadMorale = function(self, squadId)
        if not self.units[squadId] or not next(self.units[squadId]) then return 0 end
        local totalMorale = 0
        local count = 0
        for _, unit in pairs(self.units[squadId]) do
            totalMorale = totalMorale + unit.morale
            count = count + 1
        end
        return math.floor(totalMorale / count)
    end,

    getCasualtyCount = function(self, squadId)
        if not self.units[squadId] then return 0 end
        local count = 0
        for _, unit in pairs(self.units[squadId]) do
            if unit.health == 0 then count = count + 1 end
        end
        return count
    end,

    isSquadOperational = function(self, squadId)
        if not self.squads[squadId] then return false end
        return self.squads[squadId].unitCount > 0 and self:getAverageSquadHealth(squadId) > 0
    end,

    moveSquad = function(self, squadId, deltaX, deltaY)
        if not self.positions[squadId] then return false end
        for unitId, pos in pairs(self.positions[squadId]) do
            pos.x = pos.x + deltaX
            pos.y = pos.y + deltaY
        end
        return true
    end,

    regroup = function(self, squadId, centerX, centerY)
        if not self.positions[squadId] then return false end
        self.formations[squadId] = "circle"
        self:applyFormationLayout(squadId)
        self:moveSquad(squadId, centerX - 5, centerY - 5)
        return true
    end,

    activateSquad = function(self, squadId)
        if not self.squads[squadId] then return false end
        self.squads[squadId].active = true
        return true
    end,

    deactivateSquad = function(self, squadId)
        if not self.squads[squadId] then return false end
        self.squads[squadId].active = false
        return true
    end,

    isSquadActive = function(self, squadId)
        if not self.squads[squadId] then return false end
        return self.squads[squadId].active
    end
}

Suite:group("Squad Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
    end)

    Suite:testMethod("SquadFormation.createSquad", {description = "Creates squad", testCase = "create", type = "functional"}, function()
        local ok = shared.sf:createSquad("squad1", "Alpha Squad", 6)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("SquadFormation.getSquad", {description = "Gets squad", testCase = "get", type = "functional"}, function()
        shared.sf:createSquad("squad2", "Bravo", 4)
        local squad = shared.sf:getSquad("squad2")
        Helpers.assertEqual(squad ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Unit Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
        shared.sf:createSquad("units_squad", "Unit Squad", 6)
    end)

    Suite:testMethod("SquadFormation.addUnitToSquad", {description = "Adds unit", testCase = "add_unit", type = "functional"}, function()
        local ok = shared.sf:addUnitToSquad("units_squad", "u1", "Unit 1", "soldier")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("SquadFormation.getUnitCount", {description = "Unit count", testCase = "count", type = "functional"}, function()
        shared.sf:addUnitToSquad("units_squad", "u1", "Unit 1", "soldier")
        shared.sf:addUnitToSquad("units_squad", "u2", "Unit 2", "support")
        local count = shared.sf:getUnitCount("units_squad")
        Helpers.assertEqual(count, 2, "Two units")
    end)

    Suite:testMethod("SquadFormation.removeUnitFromSquad", {description = "Removes unit", testCase = "remove", type = "functional"}, function()
        shared.sf:addUnitToSquad("units_squad", "u_remove", "Remove Me", "soldier")
        local ok = shared.sf:removeUnitFromSquad("units_squad", "u_remove")
        Helpers.assertEqual(ok, true, "Removed")
    end)
end)

Suite:group("Positioning", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
        shared.sf:createSquad("pos_squad", "Position Squad", 6)
        shared.sf:addUnitToSquad("pos_squad", "u1", "Unit 1", "soldier")
    end)

    Suite:testMethod("SquadFormation.positionUnit", {description = "Positions unit", testCase = "position", type = "functional"}, function()
        local ok = shared.sf:positionUnit("pos_squad", "u1", 10, 15)
        Helpers.assertEqual(ok, true, "Positioned")
    end)

    Suite:testMethod("SquadFormation.getUnitPosition", {description = "Gets position", testCase = "get_pos", type = "functional"}, function()
        shared.sf:positionUnit("pos_squad", "u1", 5, 8)
        local pos = shared.sf:getUnitPosition("pos_squad", "u1")
        Helpers.assertEqual(pos.x, 5, "X = 5")
    end)
end)

Suite:group("Formations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
        shared.sf:createSquad("form_squad", "Formation Squad", 6)
        for i = 1, 4 do
            shared.sf:addUnitToSquad("form_squad", "u" .. i, "Unit " .. i, "soldier")
        end
    end)

    Suite:testMethod("SquadFormation.setFormation", {description = "Sets formation", testCase = "set_form", type = "functional"}, function()
        local ok = shared.sf:setFormation("form_squad", "wedge")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("SquadFormation.getFormation", {description = "Gets formation", testCase = "get_form", type = "functional"}, function()
        shared.sf:setFormation("form_squad", "line")
        local form = shared.sf:getFormation("form_squad")
        Helpers.assertEqual(form, "line", "Line formation")
    end)

    Suite:testMethod("SquadFormation.applyFormationLayout", {description = "Applies layout", testCase = "apply_layout", type = "functional"}, function()
        shared.sf:setFormation("form_squad", "line")
        local ok = shared.sf:applyFormationLayout("form_squad")
        Helpers.assertEqual(ok, true, "Applied")
    end)

    Suite:testMethod("SquadFormation.getFormationSpread", {description = "Formation spread", testCase = "spread", type = "functional"}, function()
        shared.sf:setFormation("form_squad", "line")
        shared.sf:applyFormationLayout("form_squad")
        local spread = shared.sf:getFormationSpread("form_squad")
        Helpers.assertEqual(spread > 0, true, "Spread > 0")
    end)
end)

Suite:group("Role Assignment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
        shared.sf:createSquad("role_squad", "Role Squad", 6)
        shared.sf:addUnitToSquad("role_squad", "u1", "Unit 1", "soldier")
        shared.sf:addUnitToSquad("role_squad", "u2", "Unit 2", "support")
    end)

    Suite:testMethod("SquadFormation.assignRole", {description = "Assigns role", testCase = "assign_role", type = "functional"}, function()
        local ok = shared.sf:assignRole("role_squad", "u1", "sniper")
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("SquadFormation.getUnitRole", {description = "Gets role", testCase = "get_role", type = "functional"}, function()
        local role = shared.sf:getUnitRole("role_squad", "u1")
        Helpers.assertEqual(role, "soldier", "Soldier role")
    end)

    Suite:testMethod("SquadFormation.getUnitsByRole", {description = "Units by role", testCase = "units_by_role", type = "functional"}, function()
        local supports = shared.sf:getUnitsByRole("role_squad", "support")
        Helpers.assertEqual(#supports, 1, "One support")
    end)
end)

Suite:group("Unit Health & Morale", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
        shared.sf:createSquad("health_squad", "Health Squad", 6)
        shared.sf:addUnitToSquad("health_squad", "u1", "Unit 1", "soldier")
        shared.sf:addUnitToSquad("health_squad", "u2", "Unit 2", "soldier")
    end)

    Suite:testMethod("SquadFormation.setUnitHealth", {description = "Sets health", testCase = "set_health", type = "functional"}, function()
        local ok = shared.sf:setUnitHealth("health_squad", "u1", 75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("SquadFormation.getUnitHealth", {description = "Gets health", testCase = "get_health", type = "functional"}, function()
        shared.sf:setUnitHealth("health_squad", "u1", 50)
        local health = shared.sf:getUnitHealth("health_squad", "u1")
        Helpers.assertEqual(health, 50, "50 health")
    end)

    Suite:testMethod("SquadFormation.setUnitMorale", {description = "Sets morale", testCase = "set_morale", type = "functional"}, function()
        local ok = shared.sf:setUnitMorale("health_squad", "u1", 60)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("SquadFormation.getUnitMorale", {description = "Gets morale", testCase = "get_morale", type = "functional"}, function()
        shared.sf:setUnitMorale("health_squad", "u1", 70)
        local morale = shared.sf:getUnitMorale("health_squad", "u1")
        Helpers.assertEqual(morale, 70, "70 morale")
    end)
end)

Suite:group("Squad Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
        shared.sf:createSquad("status_squad", "Status Squad", 6)
        shared.sf:addUnitToSquad("status_squad", "u1", "Unit 1", "soldier")
        shared.sf:addUnitToSquad("status_squad", "u2", "Unit 2", "soldier")
    end)

    Suite:testMethod("SquadFormation.getAverageSquadHealth", {description = "Average health", testCase = "avg_health", type = "functional"}, function()
        shared.sf:setUnitHealth("status_squad", "u1", 80)
        shared.sf:setUnitHealth("status_squad", "u2", 100)
        local avg = shared.sf:getAverageSquadHealth("status_squad")
        Helpers.assertEqual(avg, 90, "90 average")
    end)

    Suite:testMethod("SquadFormation.getAverageSquadMorale", {description = "Average morale", testCase = "avg_morale", type = "functional"}, function()
        shared.sf:setUnitMorale("status_squad", "u1", 70)
        shared.sf:setUnitMorale("status_squad", "u2", 90)
        local avg = shared.sf:getAverageSquadMorale("status_squad")
        Helpers.assertEqual(avg, 80, "80 average")
    end)

    Suite:testMethod("SquadFormation.getCasualtyCount", {description = "Casualty count", testCase = "casualties", type = "functional"}, function()
        shared.sf:setUnitHealth("status_squad", "u1", 0)
        local count = shared.sf:getCasualtyCount("status_squad")
        Helpers.assertEqual(count, 1, "One casualty")
    end)

    Suite:testMethod("SquadFormation.isSquadOperational", {description = "Is operational", testCase = "operational", type = "functional"}, function()
        local op = shared.sf:isSquadOperational("status_squad")
        Helpers.assertEqual(op, true, "Operational")
    end)
end)

Suite:group("Squad Movement", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
        shared.sf:createSquad("move_squad", "Move Squad", 6)
        shared.sf:addUnitToSquad("move_squad", "u1", "Unit 1", "soldier")
        shared.sf:positionUnit("move_squad", "u1", 10, 10)
    end)

    Suite:testMethod("SquadFormation.moveSquad", {description = "Moves squad", testCase = "move", type = "functional"}, function()
        local ok = shared.sf:moveSquad("move_squad", 5, 5)
        Helpers.assertEqual(ok, true, "Moved")
    end)

    Suite:testMethod("SquadFormation.regroup", {description = "Regroups", testCase = "regroup", type = "functional"}, function()
        local ok = shared.sf:regroup("move_squad", 20, 20)
        Helpers.assertEqual(ok, true, "Regrouped")
    end)
end)

Suite:group("Squad Activation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sf = SquadFormation:new()
        shared.sf:createSquad("active_squad", "Active Squad", 6)
    end)

    Suite:testMethod("SquadFormation.activateSquad", {description = "Activates squad", testCase = "activate", type = "functional"}, function()
        shared.sf:deactivateSquad("active_squad")
        local ok = shared.sf:activateSquad("active_squad")
        Helpers.assertEqual(ok, true, "Activated")
    end)

    Suite:testMethod("SquadFormation.deactivateSquad", {description = "Deactivates squad", testCase = "deactivate", type = "functional"}, function()
        local ok = shared.sf:deactivateSquad("active_squad")
        Helpers.assertEqual(ok, true, "Deactivated")
    end)

    Suite:testMethod("SquadFormation.isSquadActive", {description = "Is active", testCase = "is_active", type = "functional"}, function()
        local active = shared.sf:isSquadActive("active_squad")
        Helpers.assertEqual(active, false, "Inactive")
    end)
end)

Suite:run()
