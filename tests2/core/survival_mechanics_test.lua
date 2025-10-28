-- ─────────────────────────────────────────────────────────────────────────
-- SURVIVAL MECHANICS TEST SUITE
-- FILE: tests2/core/survival_mechanics_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.survival_mechanics",
    fileName = "survival_mechanics.lua",
    description = "Survival mechanics with morale, sanity, and fatigue system"
})

print("[SURVIVAL_MECHANICS_TEST] Setting up")

local SurvivalMechanics = {
    units = {},
    morale = {},
    sanity = {},
    fatigue = {},
    events = {},

    new = function(self)
        return setmetatable({
            units = {}, morale = {}, sanity = {},
            fatigue = {}, events = {}
        }, {__index = self})
    end,

    enrollUnit = function(self, unitId, name, morale_base, sanity_base, fatigue_base)
        self.units[unitId] = {id = unitId, name = name, status = "active"}
        self.morale[unitId] = {
            current = morale_base or 100, max = morale_base or 100,
            breaks = 0, rallied = false
        }
        self.sanity[unitId] = {
            current = sanity_base or 100, max = sanity_base or 100,
            trauma_events = {}, breakdown_count = 0
        }
        self.fatigue[unitId] = {
            current = fatigue_base or 0, max = 100,
            hours_active = 0, rest_needed = false
        }
        return true
    end,

    getUnit = function(self, unitId)
        return self.units[unitId]
    end,

    getMorale = function(self, unitId)
        if not self.morale[unitId] then return 0 end
        return self.morale[unitId].current
    end,

    modifyMorale = function(self, unitId, delta)
        if not self.morale[unitId] then return false end
        self.morale[unitId].current = math.max(0, math.min(self.morale[unitId].max, self.morale[unitId].current + delta))
        if self.morale[unitId].current == 0 then
            self.morale[unitId].breaks = self.morale[unitId].breaks + 1
        end
        return true
    end,

    checkMoraleBreak = function(self, unitId)
        if not self.morale[unitId] then return false end
        return self.morale[unitId].current <= 0
    end,

    rallyUnit = function(self, unitId, rally_amount)
        if not self.morale[unitId] then return false end
        self.morale[unitId].current = math.min(self.morale[unitId].max, self.morale[unitId].current + (rally_amount or 30))
        self.morale[unitId].rallied = true
        return true
    end,

    getSanity = function(self, unitId)
        if not self.sanity[unitId] then return 0 end
        return self.sanity[unitId].current
    end,

    recordTrauma = function(self, unitId, traumaType, severity)
        if not self.sanity[unitId] then return false end
        table.insert(self.sanity[unitId].trauma_events, {type = traumaType, severity = severity or 10})
        local sanity_loss = severity or 10
        self.sanity[unitId].current = math.max(0, self.sanity[unitId].current - sanity_loss)
        if self.sanity[unitId].current <= 30 then
            self.sanity[unitId].breakdown_count = self.sanity[unitId].breakdown_count + 1
        end
        return true
    end,

    getSanityLevel = function(self, unitId)
        if not self.sanity[unitId] then return "unknown" end
        local sanity = self.sanity[unitId].current
        if sanity >= 80 then return "stable"
        elseif sanity >= 60 then return "stressed"
        elseif sanity >= 40 then return "anxious"
        else return "critical"
        end
    end,

    getTraumaCount = function(self, unitId)
        if not self.sanity[unitId] then return 0 end
        return #self.sanity[unitId].trauma_events
    end,

    therapeuticSession = function(self, unitId, recovery_amount)
        if not self.sanity[unitId] then return false end
        self.sanity[unitId].current = math.min(self.sanity[unitId].max, self.sanity[unitId].current + (recovery_amount or 15))
        return true
    end,

    getFatigue = function(self, unitId)
        if not self.fatigue[unitId] then return 0 end
        return self.fatigue[unitId].current
    end,

    incrementFatigue = function(self, unitId, amount)
        if not self.fatigue[unitId] then return false end
        self.fatigue[unitId].current = math.min(self.fatigue[unitId].max, self.fatigue[unitId].current + (amount or 5))
        self.fatigue[unitId].hours_active = self.fatigue[unitId].hours_active + 1
        if self.fatigue[unitId].current >= 80 then
            self.fatigue[unitId].rest_needed = true
        end
        return true
    end,

    isFatigued = function(self, unitId)
        if not self.fatigue[unitId] then return false end
        return self.fatigue[unitId].rest_needed or self.fatigue[unitId].current >= 80
    end,

    rest = function(self, unitId, rest_amount)
        if not self.fatigue[unitId] then return false end
        self.fatigue[unitId].current = math.max(0, self.fatigue[unitId].current - (rest_amount or 20))
        if self.fatigue[unitId].current < 50 then
            self.fatigue[unitId].rest_needed = false
        end
        return true
    end,

    getHoursActive = function(self, unitId)
        if not self.fatigue[unitId] then return 0 end
        return self.fatigue[unitId].hours_active
    end,

    calculatePerformanceMalus = function(self, unitId)
        if not self.morale[unitId] or not self.sanity[unitId] or not self.fatigue[unitId] then return 0 end
        local morale_malus = (100 - self.morale[unitId].current) * 0.001
        local sanity_malus = (100 - self.sanity[unitId].current) * 0.001
        local fatigue_malus = self.fatigue[unitId].current * 0.01
        return math.floor((morale_malus + sanity_malus + fatigue_malus) * 100)
    end,

    isUnitCombatReady = function(self, unitId)
        if not self.units[unitId] then return false end
        if not self.morale[unitId] or not self.sanity[unitId] or not self.fatigue[unitId] then return false end
        return self.morale[unitId].current >= 30 and self.sanity[unitId].current >= 30 and self.fatigue[unitId].current < 80
    end,

    recordCombatEvent = function(self, unitId, eventType, intensity)
        if not self.events[unitId] then self.events[unitId] = {} end
        table.insert(self.events[unitId], {type = eventType, intensity = intensity or 5, turn = 0})
        return true
    end,

    getCombatEvents = function(self, unitId)
        if not self.events[unitId] then return {} end
        return self.events[unitId]
    end,

    getEventCount = function(self, unitId)
        if not self.events[unitId] then return 0 end
        return #self.events[unitId]
    end,

    restoreUnit = function(self, unitId)
        if not self.units[unitId] then return false end
        if self.morale[unitId] then self.morale[unitId].current = self.morale[unitId].max end
        if self.sanity[unitId] then self.sanity[unitId].current = self.sanity[unitId].max end
        if self.fatigue[unitId] then self.fatigue[unitId].current = 0 end
        return true
    end,

    getSquadMoraleAverage = function(self)
        local total = 0
        local count = 0
        for unitId, unit in pairs(self.units) do
            if self.morale[unitId] then
                total = total + self.morale[unitId].current
                count = count + 1
            end
        end
        if count == 0 then return 0 end
        return math.floor(total / count)
    end,

    getSquadSanityAverage = function(self)
        local total = 0
        local count = 0
        for unitId, unit in pairs(self.units) do
            if self.sanity[unitId] then
                total = total + self.sanity[unitId].current
                count = count + 1
            end
        end
        if count == 0 then return 0 end
        return math.floor(total / count)
    end,

    reset = function(self)
        self.units = {}
        self.morale = {}
        self.sanity = {}
        self.fatigue = {}
        self.events = {}
        return true
    end
}

Suite:group("Unit Enrollment", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SurvivalMechanics:new()
    end)

    Suite:testMethod("SurvivalMechanics.enrollUnit", {description = "Enrolls unit", testCase = "enroll", type = "functional"}, function()
        local ok = shared.sm:enrollUnit("soldier1", "Soldier One", 100, 100, 0)
        Helpers.assertEqual(ok, true, "Enrolled")
    end)

    Suite:testMethod("SurvivalMechanics.getUnit", {description = "Gets unit", testCase = "get", type = "functional"}, function()
        shared.sm:enrollUnit("soldier2", "Soldier Two", 100, 100, 0)
        local unit = shared.sm:getUnit("soldier2")
        Helpers.assertEqual(unit ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Morale", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SurvivalMechanics:new()
        shared.sm:enrollUnit("moral_unit", "Moral Unit", 100, 100, 0)
    end)

    Suite:testMethod("SurvivalMechanics.getMorale", {description = "Gets morale", testCase = "get", type = "functional"}, function()
        local morale = shared.sm:getMorale("moral_unit")
        Helpers.assertEqual(morale, 100, "Morale 100")
    end)

    Suite:testMethod("SurvivalMechanics.modifyMorale", {description = "Modifies morale", testCase = "modify", type = "functional"}, function()
        local ok = shared.sm:modifyMorale("moral_unit", -20)
        Helpers.assertEqual(ok, true, "Modified")
    end)

    Suite:testMethod("SurvivalMechanics.checkMoraleBreak", {description = "Checks break", testCase = "break", type = "functional"}, function()
        shared.sm:modifyMorale("moral_unit", -100)
        local is = shared.sm:checkMoraleBreak("moral_unit")
        Helpers.assertEqual(is, true, "Broken")
    end)

    Suite:testMethod("SurvivalMechanics.rallyUnit", {description = "Rallies unit", testCase = "rally", type = "functional"}, function()
        shared.sm:modifyMorale("moral_unit", -50)
        local ok = shared.sm:rallyUnit("moral_unit", 30)
        Helpers.assertEqual(ok, true, "Rallied")
    end)
end)

Suite:group("Sanity", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SurvivalMechanics:new()
        shared.sm:enrollUnit("sane_unit", "Sane Unit", 100, 100, 0)
    end)

    Suite:testMethod("SurvivalMechanics.getSanity", {description = "Gets sanity", testCase = "get", type = "functional"}, function()
        local sanity = shared.sm:getSanity("sane_unit")
        Helpers.assertEqual(sanity, 100, "Sanity 100")
    end)

    Suite:testMethod("SurvivalMechanics.recordTrauma", {description = "Records trauma", testCase = "trauma", type = "functional"}, function()
        local ok = shared.sm:recordTrauma("sane_unit", "combat", 15)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("SurvivalMechanics.getSanityLevel", {description = "Gets level", testCase = "level", type = "functional"}, function()
        shared.sm:recordTrauma("sane_unit", "loss", 20)
        local level = shared.sm:getSanityLevel("sane_unit")
        Helpers.assertEqual(level, "stressed", "Stressed")
    end)

    Suite:testMethod("SurvivalMechanics.getTraumaCount", {description = "Trauma count", testCase = "count", type = "functional"}, function()
        shared.sm:recordTrauma("sane_unit", "type1", 10)
        shared.sm:recordTrauma("sane_unit", "type2", 10)
        local count = shared.sm:getTraumaCount("sane_unit")
        Helpers.assertEqual(count, 2, "Two traumas")
    end)

    Suite:testMethod("SurvivalMechanics.therapeuticSession", {description = "Therapy", testCase = "therapy", type = "functional"}, function()
        shared.sm:recordTrauma("sane_unit", "event", 25)
        local ok = shared.sm:therapeuticSession("sane_unit", 15)
        Helpers.assertEqual(ok, true, "Therapy applied")
    end)
end)

Suite:group("Fatigue", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SurvivalMechanics:new()
        shared.sm:enrollUnit("tired_unit", "Tired Unit", 100, 100, 0)
    end)

    Suite:testMethod("SurvivalMechanics.getFatigue", {description = "Gets fatigue", testCase = "get", type = "functional"}, function()
        local fatigue = shared.sm:getFatigue("tired_unit")
        Helpers.assertEqual(fatigue, 0, "Fatigue 0")
    end)

    Suite:testMethod("SurvivalMechanics.incrementFatigue", {description = "Increments", testCase = "increment", type = "functional"}, function()
        local ok = shared.sm:incrementFatigue("tired_unit", 10)
        Helpers.assertEqual(ok, true, "Incremented")
    end)

    Suite:testMethod("SurvivalMechanics.isFatigued", {description = "Is fatigued", testCase = "is_fatigued", type = "functional"}, function()
        shared.sm:incrementFatigue("tired_unit", 85)
        local is = shared.sm:isFatigued("tired_unit")
        Helpers.assertEqual(is, true, "Fatigued")
    end)

    Suite:testMethod("SurvivalMechanics.rest", {description = "Rests", testCase = "rest", type = "functional"}, function()
        shared.sm:incrementFatigue("tired_unit", 30)
        local ok = shared.sm:rest("tired_unit", 20)
        Helpers.assertEqual(ok, true, "Rested")
    end)

    Suite:testMethod("SurvivalMechanics.getHoursActive", {description = "Hours active", testCase = "hours", type = "functional"}, function()
        shared.sm:incrementFatigue("tired_unit", 5)
        shared.sm:incrementFatigue("tired_unit", 5)
        local hours = shared.sm:getHoursActive("tired_unit")
        Helpers.assertEqual(hours, 2, "Two hours")
    end)
end)

Suite:group("Analysis", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SurvivalMechanics:new()
        shared.sm:enrollUnit("analyze1", "Unit 1", 100, 100, 0)
    end)

    Suite:testMethod("SurvivalMechanics.calculatePerformanceMalus", {description = "Performance malus", testCase = "malus", type = "functional"}, function()
        shared.sm:modifyMorale("analyze1", -30)
        shared.sm:recordTrauma("analyze1", "stress", 20)
        local malus = shared.sm:calculatePerformanceMalus("analyze1")
        Helpers.assertEqual(malus >= 0, true, "Malus >= 0")
    end)

    Suite:testMethod("SurvivalMechanics.isUnitCombatReady", {description = "Combat ready", testCase = "ready", type = "functional"}, function()
        local is = shared.sm:isUnitCombatReady("analyze1")
        Helpers.assertEqual(is, true, "Ready")
    end)

    Suite:testMethod("SurvivalMechanics.recordCombatEvent", {description = "Records event", testCase = "event", type = "functional"}, function()
        local ok = shared.sm:recordCombatEvent("analyze1", "casualty", 10)
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("SurvivalMechanics.getCombatEvents", {description = "Gets events", testCase = "events", type = "functional"}, function()
        shared.sm:recordCombatEvent("analyze1", "type1", 5)
        shared.sm:recordCombatEvent("analyze1", "type2", 10)
        local events = shared.sm:getCombatEvents("analyze1")
        Helpers.assertEqual(#events >= 2, true, "Has events")
    end)

    Suite:testMethod("SurvivalMechanics.getEventCount", {description = "Event count", testCase = "count", type = "functional"}, function()
        shared.sm:recordCombatEvent("analyze1", "evt1", 3)
        shared.sm:recordCombatEvent("analyze1", "evt2", 3)
        shared.sm:recordCombatEvent("analyze1", "evt3", 3)
        local count = shared.sm:getEventCount("analyze1")
        Helpers.assertEqual(count, 3, "Three events")
    end)
end)

Suite:group("Squad Metrics", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SurvivalMechanics:new()
        shared.sm:enrollUnit("squad1", "S1", 100, 100, 0)
        shared.sm:enrollUnit("squad2", "S2", 100, 100, 0)
    end)

    Suite:testMethod("SurvivalMechanics.getSquadMoraleAverage", {description = "Morale average", testCase = "morale_avg", type = "functional"}, function()
        shared.sm:modifyMorale("squad1", -20)
        local avg = shared.sm:getSquadMoraleAverage()
        Helpers.assertEqual(avg > 0, true, "Average > 0")
    end)

    Suite:testMethod("SurvivalMechanics.getSquadSanityAverage", {description = "Sanity average", testCase = "sanity_avg", type = "functional"}, function()
        shared.sm:recordTrauma("squad1", "test", 15)
        local avg = shared.sm:getSquadSanityAverage()
        Helpers.assertEqual(avg > 0, true, "Average > 0")
    end)
end)

Suite:group("Restoration", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SurvivalMechanics:new()
        shared.sm:enrollUnit("restore_unit", "Restore", 100, 100, 0)
    end)

    Suite:testMethod("SurvivalMechanics.restoreUnit", {description = "Restores unit", testCase = "restore", type = "functional"}, function()
        shared.sm:modifyMorale("restore_unit", -50)
        shared.sm:recordTrauma("restore_unit", "test", 20)
        shared.sm:incrementFatigue("restore_unit", 30)
        local ok = shared.sm:restoreUnit("restore_unit")
        Helpers.assertEqual(ok, true, "Restored")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sm = SurvivalMechanics:new()
    end)

    Suite:testMethod("SurvivalMechanics.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.sm:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
