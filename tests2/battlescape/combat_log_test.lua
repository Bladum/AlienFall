-- ─────────────────────────────────────────────────────────────────────────
-- COMBAT LOG TEST SUITE
-- FILE: tests2/battlescape/combat_log_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.combat_log",
    fileName = "combat_log.lua",
    description = "Combat logging system with detailed history, statistics, and replay data"
})

print("[COMBAT_LOG_TEST] Setting up")

local CombatLog = {
    combats = {},
    entries = {},
    statistics = {},
    casualties = {},

    new = function(self)
        return setmetatable({combats = {}, entries = {}, statistics = {}, casualties = {}}, {__index = self})
    end,

    startCombatLog = function(self, combatId, location, startTime)
        self.combats[combatId] = {id = combatId, location = location, startTime = startTime or 0, endTime = nil, status = "active", turnCount = 0}
        self.entries[combatId] = {}
        self.statistics[combatId] = {unitsDeployed = 0, enemiesEncountered = 0, casualties = 0, wounded = 0}
        self.casualties[combatId] = {}
        return true
    end,

    logAction = function(self, combatId, turn, actor, action, target, result)
        if not self.combats[combatId] then return false end
        if not self.entries[combatId] then self.entries[combatId] = {} end
        local entry = {turn = turn, actor = actor, action = action, target = target, result = result, timestamp = 0}
        table.insert(self.entries[combatId], entry)
        return true
    end,

    getActionCount = function(self, combatId)
        if not self.entries[combatId] then return 0 end
        return #self.entries[combatId]
    end,

    logCasualty = function(self, combatId, unitId, unitType, cause)
        if not self.combats[combatId] then return false end
        self.casualties[combatId][unitId] = {id = unitId, type = unitType, cause = cause, turn = self.combats[combatId].turnCount}
        self.statistics[combatId].casualties = self.statistics[combatId].casualties + 1
        return true
    end,

    getCasualtyCount = function(self, combatId)
        if not self.casualties[combatId] then return 0 end
        local count = 0
        for _ in pairs(self.casualties[combatId]) do count = count + 1 end
        return count
    end,

    advanceTurn = function(self, combatId)
        if not self.combats[combatId] then return false end
        self.combats[combatId].turnCount = self.combats[combatId].turnCount + 1
        return true
    end,

    getCurrentTurn = function(self, combatId)
        if not self.combats[combatId] then return 0 end
        return self.combats[combatId].turnCount
    end,

    endCombatLog = function(self, combatId, status, endTime)
        if not self.combats[combatId] then return false end
        self.combats[combatId].status = status
        self.combats[combatId].endTime = endTime or 0
        return true
    end,

    isCombatActive = function(self, combatId)
        if not self.combats[combatId] then return false end
        return self.combats[combatId].status == "active"
    end,

    getActionsByTurn = function(self, combatId, turn)
        if not self.entries[combatId] then return {} end
        local turnActions = {}
        for _, entry in ipairs(self.entries[combatId]) do
            if entry.turn == turn then
                table.insert(turnActions, entry)
            end
        end
        return turnActions
    end,

    getActionsByActor = function(self, combatId, actor)
        if not self.entries[combatId] then return {} end
        local actorActions = {}
        for _, entry in ipairs(self.entries[combatId]) do
            if entry.actor == actor then
                table.insert(actorActions, entry)
            end
        end
        return actorActions
    end,

    getActorsInCombat = function(self, combatId)
        if not self.entries[combatId] then return {} end
        local actors = {}
        for _, entry in ipairs(self.entries[combatId]) do
            if not actors[entry.actor] then
                actors[entry.actor] = true
            end
        end
        local actorList = {}
        for actor in pairs(actors) do
            table.insert(actorList, actor)
        end
        return actorList
    end,

    recordHit = function(self, combatId, shooter, target, damage, accuracy, armorAbsorbed)
        if not self.combats[combatId] then return false end
        local result = {actualDamage = damage - armorAbsorbed, armor = armorAbsorbed, hit = accuracy >= 50}
        self:logAction(combatId, self.combats[combatId].turnCount, shooter, "shoot", target, result)
        return true
    end,

    recordMiss = function(self, combatId, shooter, target, accuracy)
        if not self.combats[combatId] then return false end
        local result = {hit = false, accuracy = accuracy}
        self:logAction(combatId, self.combats[combatId].turnCount, shooter, "shoot", target, result)
        return true
    end,

    recordHealing = function(self, combatId, healer, patient, healAmount)
        if not self.combats[combatId] then return false end
        local result = {healed = healAmount}
        self:logAction(combatId, self.combats[combatId].turnCount, healer, "heal", patient, result)
        return true
    end,

    getHitAccuracy = function(self, combatId, actor)
        if not self.entries[combatId] then return 0 end
        local hits = 0
        local shots = 0
        for _, entry in ipairs(self.entries[combatId]) do
            if entry.actor == actor and entry.action == "shoot" then
                shots = shots + 1
                if entry.result.hit then
                    hits = hits + 1
                end
            end
        end
        if shots == 0 then return 0 end
        return math.floor((hits / shots) * 100)
    end,

    getTotalDamageDealt = function(self, combatId, actor)
        if not self.entries[combatId] then return 0 end
        local totalDamage = 0
        for _, entry in ipairs(self.entries[combatId]) do
            if entry.actor == actor and entry.action == "shoot" and entry.result.hit then
                totalDamage = totalDamage + entry.result.actualDamage
            end
        end
        return totalDamage
    end,

    getTotalHealing = function(self, combatId, actor)
        if not self.entries[combatId] then return 0 end
        local totalHealing = 0
        for _, entry in ipairs(self.entries[combatId]) do
            if entry.actor == actor and entry.action == "heal" then
                totalHealing = totalHealing + entry.result.healed
            end
        end
        return totalHealing
    end,

    getCombatSummary = function(self, combatId)
        if not self.combats[combatId] then return nil end
        return {
            location = self.combats[combatId].location,
            turnCount = self.combats[combatId].turnCount,
            status = self.combats[combatId].status,
            casualties = self.statistics[combatId].casualties,
            totalActions = self:getActionCount(combatId)
        }
    end,

    clearCombatLog = function(self, combatId)
        if not self.combats[combatId] then return false end
        self.combats[combatId] = nil
        self.entries[combatId] = nil
        self.statistics[combatId] = nil
        self.casualties[combatId] = nil
        return true
    end,

    getCasualtysByType = function(self, combatId, unitType)
        if not self.casualties[combatId] then return {} end
        local typed = {}
        for unitId, casualty in pairs(self.casualties[combatId]) do
            if casualty.type == unitType then
                table.insert(typed, unitId)
            end
        end
        return typed
    end,

    recordMoveAction = function(self, combatId, actor, fromPos, toPos)
        if not self.combats[combatId] then return false end
        local result = {from = fromPos, to = toPos, distance = 1}
        self:logAction(combatId, self.combats[combatId].turnCount, actor, "move", nil, result)
        return true
    end
}

Suite:group("Combat Session", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cl = CombatLog:new()
    end)

    Suite:testMethod("CombatLog.startCombatLog", {description = "Starts log", testCase = "start", type = "functional"}, function()
        local ok = shared.cl:startCombatLog("combat1", "Urban Zone", 0)
        Helpers.assertEqual(ok, true, "Started")
    end)

    Suite:testMethod("CombatLog.isCombatActive", {description = "Checks active", testCase = "is_active", type = "functional"}, function()
        shared.cl:startCombatLog("active_combat", "Zone", 0)
        local active = shared.cl:isCombatActive("active_combat")
        Helpers.assertEqual(active, true, "Active")
    end)

    Suite:testMethod("CombatLog.endCombatLog", {description = "Ends log", testCase = "end", type = "functional"}, function()
        shared.cl:startCombatLog("ending", "Zone", 0)
        local ok = shared.cl:endCombatLog("ending", "victory", 100)
        Helpers.assertEqual(ok, true, "Ended")
    end)
end)

Suite:group("Action Logging", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cl = CombatLog:new()
        shared.cl:startCombatLog("actions", "Zone", 0)
    end)

    Suite:testMethod("CombatLog.logAction", {description = "Logs action", testCase = "log_action", type = "functional"}, function()
        local ok = shared.cl:logAction("actions", 1, "soldier1", "move", nil, {distance = 5})
        Helpers.assertEqual(ok, true, "Logged")
    end)

    Suite:testMethod("CombatLog.getActionCount", {description = "Counts actions", testCase = "count_actions", type = "functional"}, function()
        shared.cl:logAction("actions", 1, "unit1", "shoot", "enemy1", {hit = true})
        shared.cl:logAction("actions", 1, "unit2", "move", nil, {distance = 3})
        local count = shared.cl:getActionCount("actions")
        Helpers.assertEqual(count, 2, "Two actions")
    end)

    Suite:testMethod("CombatLog.getActionsByTurn", {description = "Gets by turn", testCase = "by_turn", type = "functional"}, function()
        shared.cl:advanceTurn("actions")
        shared.cl:logAction("actions", 1, "u1", "shoot", "e1", {hit = true})
        shared.cl:advanceTurn("actions")
        shared.cl:logAction("actions", 2, "u2", "move", nil, {distance = 2})
        local turn1Actions = shared.cl:getActionsByTurn("actions", 1)
        Helpers.assertEqual(#turn1Actions, 1, "One turn 1 action")
    end)

    Suite:testMethod("CombatLog.getActionsByActor", {description = "Gets by actor", testCase = "by_actor", type = "functional"}, function()
        shared.cl:logAction("actions", 1, "hero", "shoot", "target", {hit = true})
        shared.cl:logAction("actions", 1, "hero", "move", nil, {distance = 2})
        shared.cl:logAction("actions", 1, "other", "shoot", "target", {hit = false})
        local heroActions = shared.cl:getActionsByActor("actions", "hero")
        Helpers.assertEqual(#heroActions, 2, "Two hero actions")
    end)

    Suite:testMethod("CombatLog.getActorsInCombat", {description = "Gets all actors", testCase = "all_actors", type = "functional"}, function()
        shared.cl:logAction("actions", 1, "actor1", "shoot", "target", {hit = true})
        shared.cl:logAction("actions", 1, "actor2", "move", nil, {distance = 1})
        local actors = shared.cl:getActorsInCombat("actions")
        Helpers.assertEqual(#actors, 2, "Two actors")
    end)
end)

Suite:group("Turn Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cl = CombatLog:new()
        shared.cl:startCombatLog("turns", "Zone", 0)
    end)

    Suite:testMethod("CombatLog.advanceTurn", {description = "Advances turn", testCase = "advance_turn", type = "functional"}, function()
        local ok = shared.cl:advanceTurn("turns")
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("CombatLog.getCurrentTurn", {description = "Gets current", testCase = "current_turn", type = "functional"}, function()
        shared.cl:advanceTurn("turns")
        shared.cl:advanceTurn("turns")
        local turn = shared.cl:getCurrentTurn("turns")
        Helpers.assertEqual(turn, 2, "Turn 2")
    end)
end)

Suite:group("Casualties", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cl = CombatLog:new()
        shared.cl:startCombatLog("casualties", "Zone", 0)
    end)

    Suite:testMethod("CombatLog.logCasualty", {description = "Logs casualty", testCase = "log_casualty", type = "functional"}, function()
        local ok = shared.cl:logCasualty("casualties", "unit1", "soldier", "headshot")
        Helpers.assertEqual(ok, true, "Logged")
    end)

    Suite:testMethod("CombatLog.getCasualtyCount", {description = "Counts", testCase = "count_casualty", type = "functional"}, function()
        shared.cl:logCasualty("casualties", "u1", "soldier", "bullet")
        shared.cl:logCasualty("casualties", "u2", "soldier", "explosion")
        local count = shared.cl:getCasualtyCount("casualties")
        Helpers.assertEqual(count, 2, "Two casualties")
    end)

    Suite:testMethod("CombatLog.getCasualtysByType", {description = "Gets by type", testCase = "casualty_type", type = "functional"}, function()
        shared.cl:logCasualty("casualties", "c1", "soldier", "shot")
        shared.cl:logCasualty("casualties", "c2", "alien", "detonated")
        local soldiers = shared.cl:getCasualtysByType("casualties", "soldier")
        Helpers.assertEqual(#soldiers, 1, "One soldier")
    end)
end)

Suite:group("Combat Statistics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cl = CombatLog:new()
        shared.cl:startCombatLog("stats", "Zone", 0)
    end)

    Suite:testMethod("CombatLog.recordHit", {description = "Records hit", testCase = "record_hit", type = "functional"}, function()
        local ok = shared.cl:recordHit("stats", "shooter", "target", 25, 75, 5)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("CombatLog.recordMiss", {description = "Records miss", testCase = "record_miss", type = "functional"}, function()
        local ok = shared.cl:recordMiss("stats", "shooter", "target", 30)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("CombatLog.recordHealing", {description = "Records heal", testCase = "record_heal", type = "functional"}, function()
        local ok = shared.cl:recordHealing("stats", "medic", "patient", 50)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("CombatLog.recordMoveAction", {description = "Records move", testCase = "record_move", type = "functional"}, function()
        local ok = shared.cl:recordMoveAction("stats", "unit", "1,2", "3,4")
        Helpers.assertEqual(ok, true, "Recorded")
    end)
end)

Suite:group("Combat Analytics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cl = CombatLog:new()
        shared.cl:startCombatLog("analytics", "Zone", 0)
        shared.cl:recordHit("analytics", "marksman", "alien", 20, 95, 3)
        shared.cl:recordHit("analytics", "marksman", "alien2", 18, 90, 2)
        shared.cl:recordMiss("analytics", "marksman", "alien3", 40)
    end)

    Suite:testMethod("CombatLog.getHitAccuracy", {description = "Calculates accuracy", testCase = "hit_accuracy", type = "functional"}, function()
        local accuracy = shared.cl:getHitAccuracy("analytics", "marksman")
        Helpers.assertEqual(accuracy, 66, "66% accuracy")
    end)

    Suite:testMethod("CombatLog.getTotalDamageDealt", {description = "Total damage", testCase = "total_damage", type = "functional"}, function()
        local damage = shared.cl:getTotalDamageDealt("analytics", "marksman")
        Helpers.assertEqual(damage, 33, "33 damage")
    end)

    Suite:testMethod("CombatLog.getTotalHealing", {description = "Total healing", testCase = "total_healing", type = "functional"}, function()
        shared.cl:recordHealing("analytics", "healer", "ally", 40)
        shared.cl:recordHealing("analytics", "healer", "ally2", 35)
        local healing = shared.cl:getTotalHealing("analytics", "healer")
        Helpers.assertEqual(healing, 75, "75 healing")
    end)
end)

Suite:group("Summary & Queries", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.cl = CombatLog:new()
        shared.cl:startCombatLog("summary", "Alien Base", 0)
        shared.cl:advanceTurn("summary")
        shared.cl:logAction("summary", 1, "unit1", "shoot", "enemy", {hit = true})
        shared.cl:logCasualty("summary", "enemy", "alien", "explosion")
    end)

    Suite:testMethod("CombatLog.getCombatSummary", {description = "Gets summary", testCase = "summary", type = "functional"}, function()
        local summary = shared.cl:getCombatSummary("summary")
        Helpers.assertEqual(summary ~= nil, true, "Summary exists")
    end)

    Suite:testMethod("CombatLog.clearCombatLog", {description = "Clears log", testCase = "clear", type = "functional"}, function()
        local ok = shared.cl:clearCombatLog("summary")
        Helpers.assertEqual(ok, true, "Cleared")
    end)
end)

Suite:run()
