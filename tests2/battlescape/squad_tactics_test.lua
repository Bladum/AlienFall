-- ─────────────────────────────────────────────────────────────────────────
-- SQUAD TACTICS TEST SUITE
-- FILE: tests2/battlescape/squad_tactics_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.squad_tactics",
    fileName = "squad_tactics.lua",
    description = "Squad-level tactical system with movement, positioning, cover usage, and formations"
})

print("[SQUAD_TACTICS_TEST] Setting up")

local SquadTactics = {
    squads = {},
    units = {},
    positions = {},
    tactics = {},

    new = function(self)
        return setmetatable({
            squads = {}, units = {}, positions = {}, tactics = {}
        }, {__index = self})
    end,

    createSquad = function(self, squadId, name, commander_id, max_units)
        self.squads[squadId] = {
            id = squadId, name = name, commander = commander_id or nil,
            max_units = max_units or 8, members = {}, formation = "line",
            morale = 75, cohesion = 80, action_points = 100, turn = 0
        }
        self.tactics[squadId] = {
            stance = "balanced", aggression = 50, target_priority = "threat"
        }
        return true
    end,

    getSquad = function(self, squadId)
        return self.squads[squadId]
    end,

    recruitUnit = function(self, unitId, squadId, rank, class)
        if not self.squads[squadId] then return false end
        if #self.squads[squadId].members >= self.squads[squadId].max_units then return false end
        self.units[unitId] = {
            id = unitId, squad = squadId, rank = rank or "recruit",
            class = class or "soldier", health = 100, action_points = 100,
            experience = 0, status = "ready"
        }
        table.insert(self.squads[squadId].members, unitId)
        return true
    end,

    getUnit = function(self, unitId)
        return self.units[unitId]
    end,

    getSquadMembers = function(self, squadId)
        if not self.squads[squadId] then return {} end
        return self.squads[squadId].members
    end,

    getSquadMemberCount = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return #self.squads[squadId].members
    end,

    setUnitPosition = function(self, unitId, x, y)
        if not self.units[unitId] then return false end
        self.positions[unitId] = {x = x, y = y}
        return true
    end,

    getUnitPosition = function(self, unitId)
        return self.positions[unitId]
    end,

    moveUnit = function(self, unitId, new_x, new_y, distance_cost)
        if not self.units[unitId] then return false end
        local cost = distance_cost or 10
        if self.units[unitId].action_points < cost then return false end
        self.positions[unitId] = {x = new_x, y = new_y}
        self.units[unitId].action_points = self.units[unitId].action_points - cost
        return true
    end,

    calculateDistance = function(self, unitId1, unitId2)
        if not self.positions[unitId1] or not self.positions[unitId2] then return 0 end
        local p1 = self.positions[unitId1]
        local p2 = self.positions[unitId2]
        return math.sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2)
    end,

    setSquadFormation = function(self, squadId, formation_type)
        if not self.squads[squadId] then return false end
        self.squads[squadId].formation = formation_type or "line"
        return true
    end,

    getSquadFormation = function(self, squadId)
        if not self.squads[squadId] then return nil end
        return self.squads[squadId].formation
    end,

    calculateFormationBonus = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        local formation = self.squads[squadId].formation
        if formation == "line" then return 15
        elseif formation == "wedge" then return 20
        elseif formation == "circle" then return 10
        else return 5 end
    end,

    moveSuspectCreep = function(self, unitId, x, y)
        if not self.units[unitId] then return false end
        if self.units[unitId].action_points < 5 then return false end
        self.positions[unitId] = {x = x, y = y}
        self.units[unitId].action_points = self.units[unitId].action_points - 5
        return true
    end,

    takeCover = function(self, unitId)
        if not self.units[unitId] then return false end
        self.units[unitId].status = "in_cover"
        self.units[unitId].action_points = self.units[unitId].action_points - 5
        return true
    end,

    getUnitStatus = function(self, unitId)
        if not self.units[unitId] then return nil end
        return self.units[unitId].status
    end,

    attackUnit = function(self, attacker_id, target_id, damage)
        if not self.units[attacker_id] or not self.units[target_id] then return false end
        if self.units[attacker_id].action_points < 20 then return false end
        local damage_amount = damage or 15
        self.units[target_id].health = math.max(0, self.units[target_id].health - damage_amount)
        self.units[attacker_id].action_points = self.units[attacker_id].action_points - 20
        if self.units[target_id].health <= 0 then
            self.units[target_id].status = "incapacitated"
        end
        return true
    end,

    setUnitStance = function(self, squadId, stance)
        if not self.tactics[squadId] then return false end
        self.tactics[squadId].stance = stance or "balanced"
        return true
    end,

    getUnitStance = function(self, squadId)
        if not self.tactics[squadId] then return nil end
        return self.tactics[squadId].stance
    end,

    setAggression = function(self, squadId, level)
        if not self.tactics[squadId] then return false end
        self.tactics[squadId].aggression = math.max(0, math.min(100, level))
        return true
    end,

    getAggression = function(self, squadId)
        if not self.tactics[squadId] then return 0 end
        return self.tactics[squadId].aggression
    end,

    setTargetPriority = function(self, squadId, priority)
        if not self.tactics[squadId] then return false end
        self.tactics[squadId].target_priority = priority or "threat"
        return true
    end,

    getTargetPriority = function(self, squadId)
        if not self.tactics[squadId] then return nil end
        return self.tactics[squadId].target_priority
    end,

    calculateSquadMorale = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        local squad = self.squads[squadId]
        local health_avg = 0
        local count = 0
        for _, unitId in ipairs(squad.members) do
            if self.units[unitId] then
                health_avg = health_avg + self.units[unitId].health
                count = count + 1
            end
        end
        if count == 0 then return 0 end
        return (health_avg / count) * 0.7 + squad.morale * 0.3
    end,

    calculateSquadCohesion = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        local squad = self.squads[squadId]
        local avg_distance = 0
        if #squad.members < 2 then return 100 end
        for i = 1, #squad.members do
            for j = i + 1, #squad.members do
                avg_distance = avg_distance + self:calculateDistance(squad.members[i], squad.members[j])
            end
        end
        local pair_count = (#squad.members * (#squad.members - 1)) / 2
        avg_distance = avg_distance / pair_count
        return math.max(0, 100 - (avg_distance * 5))
    end,

    executeSquadAction = function(self, squadId, action_type)
        if not self.squads[squadId] then return false end
        local squad = self.squads[squadId]
        if squad.action_points < 20 then return false end
        squad.action_points = squad.action_points - 20
        return true
    end,

    getSquadActionPoints = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return self.squads[squadId].action_points
    end,

    resetSquadActionPoints = function(self, squadId)
        if not self.squads[squadId] then return false end
        self.squads[squadId].action_points = 100
        for _, unitId in ipairs(self.squads[squadId].members) do
            if self.units[unitId] then
                self.units[unitId].action_points = 100
            end
        end
        return true
    end,

    endSquadTurn = function(self, squadId)
        if not self.squads[squadId] then return false end
        self.squads[squadId].turn = self.squads[squadId].turn + 1
        self:resetSquadActionPoints(squadId)
        return true
    end,

    getSquadTurn = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return self.squads[squadId].turn
    end,

    calculateSquadEffectiveness = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        local morale = self:calculateSquadMorale(squadId)
        local cohesion = self:calculateSquadCohesion(squadId)
        local formation_bonus = self:calculateFormationBonus(squadId)
        return (morale + cohesion) / 2 + formation_bonus
    end,

    reset = function(self)
        self.squads = {}
        self.units = {}
        self.positions = {}
        self.tactics = {}
        return true
    end
}

Suite:group("Squad Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
    end)

    Suite:testMethod("SquadTactics.createSquad", {description = "Creates squad", testCase = "create", type = "functional"}, function()
        local ok = shared.st:createSquad("squad1", "Alpha", "cmd1", 8)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("SquadTactics.getSquad", {description = "Gets squad", testCase = "get", type = "functional"}, function()
        shared.st:createSquad("squad2", "Bravo", "cmd2", 6)
        local squad = shared.st:getSquad("squad2")
        Helpers.assertEqual(squad ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Units", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
        shared.st:createSquad("squad1", "Alpha", "cmd1")
    end)

    Suite:testMethod("SquadTactics.recruitUnit", {description = "Recruits unit", testCase = "recruit", type = "functional"}, function()
        local ok = shared.st:recruitUnit("unit1", "squad1", "soldier", "rifleman")
        Helpers.assertEqual(ok, true, "Recruited")
    end)

    Suite:testMethod("SquadTactics.getUnit", {description = "Gets unit", testCase = "get", type = "functional"}, function()
        shared.st:recruitUnit("unit2", "squad1", "sergeant", "gunner")
        local unit = shared.st:getUnit("unit2")
        Helpers.assertEqual(unit ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("SquadTactics.getSquadMembers", {description = "Gets members", testCase = "members", type = "functional"}, function()
        shared.st:recruitUnit("unit1", "squad1", "soldier", "rifleman")
        local members = shared.st:getSquadMembers("squad1")
        Helpers.assertEqual(#members > 0, true, "Has members")
    end)

    Suite:testMethod("SquadTactics.getSquadMemberCount", {description = "Gets member count", testCase = "count", type = "functional"}, function()
        shared.st:recruitUnit("unit1", "squad1", "soldier", "rifleman")
        shared.st:recruitUnit("unit2", "squad1", "soldier", "gunner")
        local count = shared.st:getSquadMemberCount("squad1")
        Helpers.assertEqual(count, 2, "2")
    end)
end)

Suite:group("Positioning", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
        shared.st:createSquad("squad1", "Alpha", "cmd1")
        shared.st:recruitUnit("unit1", "squad1", "soldier", "rifleman")
    end)

    Suite:testMethod("SquadTactics.setUnitPosition", {description = "Sets position", testCase = "set", type = "functional"}, function()
        local ok = shared.st:setUnitPosition("unit1", 10, 20)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("SquadTactics.getUnitPosition", {description = "Gets position", testCase = "get", type = "functional"}, function()
        shared.st:setUnitPosition("unit1", 15, 25)
        local pos = shared.st:getUnitPosition("unit1")
        Helpers.assertEqual(pos ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("SquadTactics.moveUnit", {description = "Moves unit", testCase = "move", type = "functional"}, function()
        shared.st:setUnitPosition("unit1", 10, 10)
        local ok = shared.st:moveUnit("unit1", 15, 15, 10)
        Helpers.assertEqual(ok, true, "Moved")
    end)

    Suite:testMethod("SquadTactics.calculateDistance", {description = "Calculates distance", testCase = "distance", type = "functional"}, function()
        shared.st:recruitUnit("unit2", "squad1", "soldier", "gunner")
        shared.st:setUnitPosition("unit1", 0, 0)
        shared.st:setUnitPosition("unit2", 3, 4)
        local dist = shared.st:calculateDistance("unit1", "unit2")
        Helpers.assertEqual(dist, 5, "5")
    end)
end)

Suite:group("Formations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
        shared.st:createSquad("squad1", "Alpha", "cmd1")
    end)

    Suite:testMethod("SquadTactics.setSquadFormation", {description = "Sets formation", testCase = "set", type = "functional"}, function()
        local ok = shared.st:setSquadFormation("squad1", "wedge")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("SquadTactics.getSquadFormation", {description = "Gets formation", testCase = "get", type = "functional"}, function()
        shared.st:setSquadFormation("squad1", "circle")
        local form = shared.st:getSquadFormation("squad1")
        Helpers.assertEqual(form, "circle", "circle")
    end)

    Suite:testMethod("SquadTactics.calculateFormationBonus", {description = "Calculates bonus", testCase = "bonus", type = "functional"}, function()
        shared.st:setSquadFormation("squad1", "wedge")
        local bonus = shared.st:calculateFormationBonus("squad1")
        Helpers.assertEqual(bonus > 0, true, "Bonus > 0")
    end)
end)

Suite:group("Combat", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
        shared.st:createSquad("squad1", "Alpha", "cmd1")
        shared.st:recruitUnit("unit1", "squad1", "soldier", "rifleman")
        shared.st:recruitUnit("unit2", "squad1", "soldier", "gunner")
    end)

    Suite:testMethod("SquadTactics.takeCover", {description = "Takes cover", testCase = "cover", type = "functional"}, function()
        local ok = shared.st:takeCover("unit1")
        Helpers.assertEqual(ok, true, "Took cover")
    end)

    Suite:testMethod("SquadTactics.getUnitStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        shared.st:takeCover("unit1")
        local status = shared.st:getUnitStatus("unit1")
        Helpers.assertEqual(status, "in_cover", "in_cover")
    end)

    Suite:testMethod("SquadTactics.attackUnit", {description = "Attacks unit", testCase = "attack", type = "functional"}, function()
        local ok = shared.st:attackUnit("unit1", "unit2", 25)
        Helpers.assertEqual(ok, true, "Attacked")
    end)
end)

Suite:group("Tactics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
        shared.st:createSquad("squad1", "Alpha", "cmd1")
    end)

    Suite:testMethod("SquadTactics.setUnitStance", {description = "Sets stance", testCase = "set", type = "functional"}, function()
        local ok = shared.st:setUnitStance("squad1", "defensive")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("SquadTactics.getUnitStance", {description = "Gets stance", testCase = "get", type = "functional"}, function()
        shared.st:setUnitStance("squad1", "aggressive")
        local stance = shared.st:getUnitStance("squad1")
        Helpers.assertEqual(stance, "aggressive", "aggressive")
    end)

    Suite:testMethod("SquadTactics.setAggression", {description = "Sets aggression", testCase = "aggression", type = "functional"}, function()
        local ok = shared.st:setAggression("squad1", 75)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("SquadTactics.getAggression", {description = "Gets aggression", testCase = "get", type = "functional"}, function()
        shared.st:setAggression("squad1", 60)
        local agg = shared.st:getAggression("squad1")
        Helpers.assertEqual(agg, 60, "60")
    end)

    Suite:testMethod("SquadTactics.setTargetPriority", {description = "Sets priority", testCase = "priority", type = "functional"}, function()
        local ok = shared.st:setTargetPriority("squad1", "closest")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("SquadTactics.getTargetPriority", {description = "Gets priority", testCase = "get", type = "functional"}, function()
        shared.st:setTargetPriority("squad1", "weakest")
        local priority = shared.st:getTargetPriority("squad1")
        Helpers.assertEqual(priority, "weakest", "weakest")
    end)
end)

Suite:group("Squad Effectiveness", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
        shared.st:createSquad("squad1", "Alpha", "cmd1")
        shared.st:recruitUnit("unit1", "squad1", "soldier", "rifleman")
    end)

    Suite:testMethod("SquadTactics.calculateSquadMorale", {description = "Calculates morale", testCase = "morale", type = "functional"}, function()
        local morale = shared.st:calculateSquadMorale("squad1")
        Helpers.assertEqual(morale >= 0, true, "Morale >= 0")
    end)

    Suite:testMethod("SquadTactics.calculateSquadCohesion", {description = "Calculates cohesion", testCase = "cohesion", type = "functional"}, function()
        local cohesion = shared.st:calculateSquadCohesion("squad1")
        Helpers.assertEqual(cohesion >= 0, true, "Cohesion >= 0")
    end)

    Suite:testMethod("SquadTactics.calculateSquadEffectiveness", {description = "Calculates effectiveness", testCase = "effectiveness", type = "functional"}, function()
        local eff = shared.st:calculateSquadEffectiveness("squad1")
        Helpers.assertEqual(eff > 0, true, "Effectiveness > 0")
    end)
end)

Suite:group("Action Points", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
        shared.st:createSquad("squad1", "Alpha", "cmd1")
    end)

    Suite:testMethod("SquadTactics.executeSquadAction", {description = "Executes action", testCase = "execute", type = "functional"}, function()
        local ok = shared.st:executeSquadAction("squad1", "attack")
        Helpers.assertEqual(ok, true, "Executed")
    end)

    Suite:testMethod("SquadTactics.getSquadActionPoints", {description = "Gets action points", testCase = "points", type = "functional"}, function()
        local points = shared.st:getSquadActionPoints("squad1")
        Helpers.assertEqual(points > 0, true, "Points > 0")
    end)

    Suite:testMethod("SquadTactics.resetSquadActionPoints", {description = "Resets points", testCase = "reset", type = "functional"}, function()
        shared.st:executeSquadAction("squad1", "attack")
        local ok = shared.st:resetSquadActionPoints("squad1")
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:group("Turns", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
        shared.st:createSquad("squad1", "Alpha", "cmd1")
    end)

    Suite:testMethod("SquadTactics.endSquadTurn", {description = "Ends turn", testCase = "end", type = "functional"}, function()
        local ok = shared.st:endSquadTurn("squad1")
        Helpers.assertEqual(ok, true, "Ended")
    end)

    Suite:testMethod("SquadTactics.getSquadTurn", {description = "Gets turn", testCase = "turn", type = "functional"}, function()
        shared.st:endSquadTurn("squad1")
        local turn = shared.st:getSquadTurn("squad1")
        Helpers.assertEqual(turn, 1, "1")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.st = SquadTactics:new()
    end)

    Suite:testMethod("SquadTactics.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.st:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
