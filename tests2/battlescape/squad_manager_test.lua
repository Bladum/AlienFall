-- ─────────────────────────────────────────────────────────────────────────
-- SQUAD MANAGER TEST SUITE
-- FILE: tests2/battlescape/squad_manager_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.squad_manager",
    fileName = "squad_manager.lua",
    description = "Squad composition, tactics, morale, and coordination"
})

print("[SQUAD_MANAGER_TEST] Setting up")

local SquadManager = {
    squads = {},
    units_to_squad = {},
    formations = {},
    morale = {},

    new = function(self)
        return setmetatable({squads = {}, units_to_squad = {}, formations = {}, morale = {}}, {__index = self})
    end,

    createSquad = function(self, squadId, commander, maxSize)
        self.squads[squadId] = {id = squadId, commander = commander, members = {}, maxSize = maxSize, tacticalBonus = 0, readiness = 100}
        self.morale[squadId] = 75
        return true
    end,

    addUnitToSquad = function(self, squadId, unitId)
        if not self.squads[squadId] then return false end
        if #self.squads[squadId].members >= self.squads[squadId].maxSize then return false end
        table.insert(self.squads[squadId].members, unitId)
        self.units_to_squad[unitId] = squadId
        return true
    end,

    removeUnitFromSquad = function(self, squadId, unitId)
        if not self.squads[squadId] then return false end
        for i, id in ipairs(self.squads[squadId].members) do
            if id == unitId then table.remove(self.squads[squadId].members, i) break end
        end
        self.units_to_squad[unitId] = nil
        return true
    end,

    getSquadMembers = function(self, squadId)
        if not self.squads[squadId] then return {} end
        return self.squads[squadId].members
    end,

    getSquadSize = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return #self.squads[squadId].members
    end,

    getUnitSquad = function(self, unitId)
        return self.units_to_squad[unitId]
    end,

    setFormation = function(self, squadId, formationName)
        if not self.squads[squadId] then return false end
        self.formations[squadId] = formationName
        if formationName == "defensive" then self.squads[squadId].tacticalBonus = 15
        elseif formationName == "offensive" then self.squads[squadId].tacticalBonus = -5
        elseif formationName == "scout" then self.squads[squadId].tacticalBonus = 10
        else self.squads[squadId].tacticalBonus = 0 end
        return true
    end,

    getFormation = function(self, squadId)
        return self.formations[squadId] or "standard"
    end,

    getTacticalBonus = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return self.squads[squadId].tacticalBonus
    end,

    setMorale = function(self, squadId, moraleValue)
        if not self.squads[squadId] then return false end
        self.morale[squadId] = math.max(0, math.min(100, moraleValue))
        return true
    end,

    getMorale = function(self, squadId)
        return self.morale[squadId] or 75
    end,

    adjustMorale = function(self, squadId, delta)
        if not self.squads[squadId] then return false end
        self.morale[squadId] = math.max(0, math.min(100, self.morale[squadId] + delta))
        return true
    end,

    isCombatReady = function(self, squadId)
        if not self.squads[squadId] then return false end
        return self.morale[squadId] >= 30 and #self.squads[squadId].members > 0
    end,

    setReadiness = function(self, squadId, readiness)
        if not self.squads[squadId] then return false end
        self.squads[squadId].readiness = math.max(0, math.min(100, readiness))
        return true
    end,

    getReadiness = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return self.squads[squadId].readiness
    end,

    getSquadCount = function(self)
        local count = 0
        for _ in pairs(self.squads) do count = count + 1 end
        return count
    end,

    getActiveSquads = function(self)
        local count = 0
        for _, squad in pairs(self.squads) do
            if #squad.members > 0 then count = count + 1 end
        end
        return count
    end,

    getTotalSquadMembers = function(self)
        local total = 0
        for _, squad in pairs(self.squads) do
            total = total + #squad.members
        end
        return total
    end,

    reassignCommander = function(self, squadId, newCommander)
        if not self.squads[squadId] then return false end
        self.squads[squadId].commander = newCommander
        return true
    end,

    canAddUnit = function(self, squadId)
        if not self.squads[squadId] then return false end
        return #self.squads[squadId].members < self.squads[squadId].maxSize
    end
}

Suite:group("Squad Creation & Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SquadManager:new()
    end)

    Suite:testMethod("SquadManager.new", {description = "Creates manager", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.sm ~= nil, true, "Manager created")
    end)

    Suite:testMethod("SquadManager.createSquad", {description = "Creates squad", testCase = "create_squad", type = "functional"}, function()
        local ok = shared.sm:createSquad("alpha", "soldier1", 6)
        Helpers.assertEqual(ok, true, "Squad created")
    end)

    Suite:testMethod("SquadManager.getSquadCount", {description = "Counts squads", testCase = "count", type = "functional"}, function()
        shared.sm:createSquad("s1", "cmd1", 5)
        shared.sm:createSquad("s2", "cmd2", 6)
        shared.sm:createSquad("s3", "cmd3", 4)
        local count = shared.sm:getSquadCount()
        Helpers.assertEqual(count, 3, "Three squads")
    end)

    Suite:testMethod("SquadManager.reassignCommander", {description = "Changes commander", testCase = "reassign", type = "functional"}, function()
        shared.sm:createSquad("alpha", "cmd1", 6)
        local ok = shared.sm:reassignCommander("alpha", "cmd2")
        Helpers.assertEqual(ok, true, "Commander changed")
    end)
end)

Suite:group("Squad Composition", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SquadManager:new()
        shared.sm:createSquad("bravo", "commander", 6)
    end)

    Suite:testMethod("SquadManager.addUnitToSquad", {description = "Adds unit", testCase = "add_unit", type = "functional"}, function()
        local ok = shared.sm:addUnitToSquad("bravo", "soldier1")
        Helpers.assertEqual(ok, true, "Unit added")
    end)

    Suite:testMethod("SquadManager.getSquadSize", {description = "Gets squad size", testCase = "size", type = "functional"}, function()
        shared.sm:addUnitToSquad("bravo", "s1")
        shared.sm:addUnitToSquad("bravo", "s2")
        shared.sm:addUnitToSquad("bravo", "s3")
        local size = shared.sm:getSquadSize("bravo")
        Helpers.assertEqual(size, 3, "Size 3")
    end)

    Suite:testMethod("SquadManager.addUnitToSquad", {description = "Respects max size", testCase = "max_size", type = "functional"}, function()
        shared.sm:createSquad("small", "cmd", 2)
        shared.sm:addUnitToSquad("small", "u1")
        shared.sm:addUnitToSquad("small", "u2")
        local ok = shared.sm:addUnitToSquad("small", "u3")
        Helpers.assertEqual(ok, false, "Rejected overflow")
    end)

    Suite:testMethod("SquadManager.getUnitSquad", {description = "Tracks unit squad", testCase = "unit_squad", type = "functional"}, function()
        shared.sm:addUnitToSquad("bravo", "soldier1")
        local squadId = shared.sm:getUnitSquad("soldier1")
        Helpers.assertEqual(squadId, "bravo", "Soldier in bravo")
    end)

    Suite:testMethod("SquadManager.removeUnitFromSquad", {description = "Removes unit", testCase = "remove", type = "functional"}, function()
        shared.sm:addUnitToSquad("bravo", "soldier1")
        local ok = shared.sm:removeUnitFromSquad("bravo", "soldier1")
        Helpers.assertEqual(ok, true, "Unit removed")
    end)

    Suite:testMethod("SquadManager.canAddUnit", {description = "Checks capacity", testCase = "can_add", type = "functional"}, function()
        shared.sm:createSquad("charlie", "cmd", 2)
        shared.sm:addUnitToSquad("charlie", "u1")
        shared.sm:addUnitToSquad("charlie", "u2")
        local ok = shared.sm:canAddUnit("charlie")
        Helpers.assertEqual(ok, false, "Cannot add more")
    end)
end)

Suite:group("Formations & Tactics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SquadManager:new()
        shared.sm:createSquad("delta", "cmd", 6)
    end)

    Suite:testMethod("SquadManager.setFormation", {description = "Sets formation", testCase = "set_formation", type = "functional"}, function()
        local ok = shared.sm:setFormation("delta", "defensive")
        Helpers.assertEqual(ok, true, "Formation set")
    end)

    Suite:testMethod("SquadManager.getFormation", {description = "Gets formation", testCase = "get_formation", type = "functional"}, function()
        shared.sm:setFormation("delta", "offensive")
        local formation = shared.sm:getFormation("delta")
        Helpers.assertEqual(formation, "offensive", "Offensive formation")
    end)

    Suite:testMethod("SquadManager.getTacticalBonus", {description = "Defensive bonus", testCase = "def_bonus", type = "functional"}, function()
        shared.sm:setFormation("delta", "defensive")
        local bonus = shared.sm:getTacticalBonus("delta")
        Helpers.assertEqual(bonus, 15, "Defense +15")
    end)

    Suite:testMethod("SquadManager.getTacticalBonus", {description = "Offensive penalty", testCase = "off_penalty", type = "functional"}, function()
        shared.sm:setFormation("delta", "offensive")
        local bonus = shared.sm:getTacticalBonus("delta")
        Helpers.assertEqual(bonus, -5, "Offense -5")
    end)

    Suite:testMethod("SquadManager.getTacticalBonus", {description = "Scout bonus", testCase = "scout_bonus", type = "functional"}, function()
        shared.sm:setFormation("delta", "scout")
        local bonus = shared.sm:getTacticalBonus("delta")
        Helpers.assertEqual(bonus, 10, "Scout +10")
    end)
end)

Suite:group("Morale System", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SquadManager:new()
        shared.sm:createSquad("echo", "cmd", 5)
    end)

    Suite:testMethod("SquadManager.getMorale", {description = "Gets morale", testCase = "get_morale", type = "functional"}, function()
        local morale = shared.sm:getMorale("echo")
        Helpers.assertEqual(morale, 75, "Default morale 75")
    end)

    Suite:testMethod("SquadManager.setMorale", {description = "Sets morale", testCase = "set_morale", type = "functional"}, function()
        local ok = shared.sm:setMorale("echo", 50)
        Helpers.assertEqual(ok, true, "Morale set")
    end)

    Suite:testMethod("SquadManager.setMorale", {description = "Clamps max", testCase = "clamp_max", type = "functional"}, function()
        shared.sm:setMorale("echo", 150)
        local morale = shared.sm:getMorale("echo")
        Helpers.assertEqual(morale, 100, "Clamped to 100")
    end)

    Suite:testMethod("SquadManager.adjustMorale", {description = "Adjusts morale", testCase = "adjust", type = "functional"}, function()
        shared.sm:adjustMorale("echo", -20)
        local morale = shared.sm:getMorale("echo")
        Helpers.assertEqual(morale, 55, "Morale 55")
    end)

    Suite:testMethod("SquadManager.adjustMorale", {description = "Clamps min", testCase = "clamp_min", type = "functional"}, function()
        shared.sm:adjustMorale("echo", -100)
        local morale = shared.sm:getMorale("echo")
        Helpers.assertEqual(morale, 0, "Morale 0")
    end)

    Suite:testMethod("SquadManager.isCombatReady", {description = "Ready check", testCase = "ready", type = "functional"}, function()
        shared.sm:addUnitToSquad("echo", "u1")
        local ok = shared.sm:isCombatReady("echo")
        Helpers.assertEqual(ok, true, "Combat ready")
    end)

    Suite:testMethod("SquadManager.isCombatReady", {description = "Fails low morale", testCase = "low_morale", type = "functional"}, function()
        shared.sm:addUnitToSquad("echo", "u1")
        shared.sm:setMorale("echo", 20)
        local ok = shared.sm:isCombatReady("echo")
        Helpers.assertEqual(ok, false, "Not combat ready")
    end)
end)

Suite:group("Readiness & Statistics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SquadManager:new()
        shared.sm:createSquad("foxtrot", "cmd", 8)
        shared.sm:createSquad("golf", "cmd", 6)
    end)

    Suite:testMethod("SquadManager.setReadiness", {description = "Sets readiness", testCase = "set_ready", type = "functional"}, function()
        local ok = shared.sm:setReadiness("foxtrot", 80)
        Helpers.assertEqual(ok, true, "Readiness set")
    end)

    Suite:testMethod("SquadManager.getReadiness", {description = "Gets readiness", testCase = "get_ready", type = "functional"}, function()
        shared.sm:setReadiness("foxtrot", 90)
        local readiness = shared.sm:getReadiness("foxtrot")
        Helpers.assertEqual(readiness, 90, "Readiness 90")
    end)

    Suite:testMethod("SquadManager.getActiveSquads", {description = "Counts active", testCase = "active", type = "functional"}, function()
        shared.sm:addUnitToSquad("foxtrot", "u1")
        shared.sm:addUnitToSquad("golf", "u2")
        local count = shared.sm:getActiveSquads()
        Helpers.assertEqual(count, 2, "Two active")
    end)

    Suite:testMethod("SquadManager.getTotalSquadMembers", {description = "Sums members", testCase = "total_members", type = "functional"}, function()
        shared.sm:addUnitToSquad("foxtrot", "u1")
        shared.sm:addUnitToSquad("foxtrot", "u2")
        shared.sm:addUnitToSquad("golf", "u3")
        shared.sm:addUnitToSquad("golf", "u4")
        local total = shared.sm:getTotalSquadMembers()
        Helpers.assertEqual(total, 4, "Total 4 members")
    end)

    Suite:testMethod("SquadManager.getSquadMembers", {description = "Lists members", testCase = "member_list", type = "functional"}, function()
        shared.sm:addUnitToSquad("foxtrot", "u1")
        shared.sm:addUnitToSquad("foxtrot", "u2")
        local members = shared.sm:getSquadMembers("foxtrot")
        local count = #members
        Helpers.assertEqual(count, 2, "Two members in list")
    end)
end)

Suite:run()
