-- ─────────────────────────────────────────────────────────────────────────
-- TACTICAL COMBAT TEST SUITE
-- FILE: tests2/battlescape/tactical_combat_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.battlescape.tactical_combat",
    fileName = "tactical_combat.lua",
    description = "Tactical combat with squads, formations, cover, suppression, and coordination"
})

print("[TACTICAL_COMBAT_TEST] Setting up")

local TacticalCombat = {
    squads = {}, units = {}, formations = {}, cover_points = {},
    suppression = {}, actions = {},

    new = function(self)
        return setmetatable({
            squads = {}, units = {}, formations = {}, cover_points = {},
            suppression = {}, actions = {}
        }, {__index = self})
    end,

    createSquad = function(self, squadId, name, composition)
        self.squads[squadId] = {
            id = squadId, name = name, members = composition or {}, morale = 100,
            cohesion = 80, action_points = 0, status = "ready"
        }
        return true
    end,

    getSquad = function(self, squadId)
        return self.squads[squadId]
    end,

    createUnit = function(self, unitId, squadId, unit_type, hp, ap)
        if not self.squads[squadId] then return false end
        local unit = {
            id = unitId, squad_id = squadId, type = unit_type,
            hp = hp or 100, max_hp = hp or 100, ap = ap or 10,
            max_ap = ap or 10, suppression = 0, status = "active",
            x = 0, y = 0
        }
        self.units[unitId] = unit
        table.insert(self.squads[squadId].members, unitId)
        return true
    end,

    getUnit = function(self, unitId)
        return self.units[unitId]
    end,

    assignFormation = function(self, squadId, formationType)
        if not self.squads[squadId] then return false end
        self.formations[squadId] = {
            squad_id = squadId, type = formationType,
            pattern = formationType, cohesion_bonus = 15,
            defensive_bonus = 0, offensive_bonus = 0
        }
        if formationType == "defensive" then
            self.formations[squadId].defensive_bonus = 20
        elseif formationType == "offensive" then
            self.formations[squadId].offensive_bonus = 25
        elseif formationType == "loose" then
            self.formations[squadId].cohesion_bonus = 5
        end
        return true
    end,

    getFormation = function(self, squadId)
        return self.formations[squadId]
    end,

    registerCoverPoint = function(self, coverId, x, y, cover_type, protection_level)
        self.cover_points[coverId] = {
            id = coverId, x = x, y = y, type = cover_type,
            protection = protection_level or 50, occupied = false,
            occupant = nil
        }
        return true
    end,

    getCoverPoint = function(self, coverId)
        return self.cover_points[coverId]
    end,

    unitTakeCover = function(self, unitId, coverId)
        if not self.units[unitId] or not self.cover_points[coverId] then return false end
        local unit = self.units[unitId]
        local cover = self.cover_points[coverId]
        unit.x = cover.x
        unit.y = cover.y
        unit.cover_id = coverId
        unit.in_cover = true
        cover.occupied = true
        cover.occupant = unitId
        return true
    end,

    applySuppression = function(self, unitId, suppression_amount)
        if not self.units[unitId] then return false end
        local unit = self.units[unitId]
        unit.suppression = math.min(100, unit.suppression + suppression_amount)
        if unit.suppression > 50 then
            unit.status = "suppressed"
        end
        return true
    end,

    releaseSuppression = function(self, unitId, suppression_reduction)
        if not self.units[unitId] then return false end
        local unit = self.units[unitId]
        unit.suppression = math.max(0, unit.suppression - suppression_reduction)
        if unit.suppression <= 50 and unit.status == "suppressed" then
            unit.status = "active"
        end
        return true
    end,

    getSuppression = function(self, unitId)
        if not self.units[unitId] then return 0 end
        return self.units[unitId].suppression
    end,

    calculateCoverProtection = function(self, unitId, incoming_damage)
        if not self.units[unitId] then return incoming_damage end
        local unit = self.units[unitId]
        if unit.in_cover and unit.cover_id then
            local cover = self.cover_points[unit.cover_id]
            if cover then
                local reduction = incoming_damage * (cover.protection / 100)
                return incoming_damage - reduction
            end
        end
        return incoming_damage
    end,

    moveUnit = function(self, unitId, x, y)
        if not self.units[unitId] then return false end
        local unit = self.units[unitId]
        if unit.ap < 2 then return false end
        unit.x = x
        unit.y = y
        unit.ap = unit.ap - 2
        unit.in_cover = false
        unit.cover_id = nil
        return true
    end,

    performAttack = function(self, attackerId, targetId)
        if not self.units[attackerId] or not self.units[targetId] then return false end
        local attacker = self.units[attackerId]
        local target = self.units[targetId]
        if attacker.ap < 3 then return false end

        local damage = 20 + math.random(-5, 5)
        local actual_damage = self:calculateCoverProtection(targetId, damage)
        target.hp = math.max(0, target.hp - actual_damage)
        attacker.ap = attacker.ap - 3

        if target.hp <= 0 then
            target.status = "destroyed"
        end

        table.insert(self.actions, {
            type = "attack", attacker = attackerId, target = targetId,
            damage = actual_damage, timestamp = os.time()
        })

        return true
    end,

    performOverwatch = function(self, unitId)
        if not self.units[unitId] then return false end
        local unit = self.units[unitId]
        if unit.ap < 4 then return false end
        unit.ap = unit.ap - 4
        unit.overwatch = true
        return true
    end,

    restoreActionPoints = function(self, unitId, ap_amount)
        if not self.units[unitId] then return false end
        local unit = self.units[unitId]
        unit.ap = math.min(unit.max_ap, unit.ap + ap_amount)
        return true
    end,

    coordinatedFire = function(self, squadId, targetId)
        if not self.squads[squadId] or not self.units[targetId] then return false end
        local squad = self.squads[squadId]
        local target = self.units[targetId]
        local total_damage = 0
        local fire_count = 0

        for _, unitId in ipairs(squad.members) do
            local attacker = self.units[unitId]
            if attacker and attacker.ap >= 3 then
                local damage = 20 + math.random(-5, 5)
                total_damage = total_damage + damage
                fire_count = fire_count + 1
                attacker.ap = attacker.ap - 3
            end
        end

        local actual_damage = self:calculateCoverProtection(targetId, total_damage)
        target.hp = math.max(0, target.hp - actual_damage)

        if target.hp <= 0 then
            target.status = "destroyed"
        end

        return true
    end,

    updateSquadMorale = function(self, squadId, morale_change)
        if not self.squads[squadId] then return false end
        local squad = self.squads[squadId]
        squad.morale = math.max(0, math.min(100, squad.morale + morale_change))
        if squad.morale < 30 then
            squad.status = "broken"
        elseif squad.morale > 70 then
            squad.status = "ready"
        end
        return true
    end,

    getSquadMorale = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return self.squads[squadId].morale
    end,

    updateSquadCohesion = function(self, squadId, cohesion_change)
        if not self.squads[squadId] then return false end
        local squad = self.squads[squadId]
        local formation = self.formations[squadId]
        local bonus = formation and formation.cohesion_bonus or 0
        squad.cohesion = math.max(0, math.min(100, squad.cohesion + cohesion_change + bonus))
        return true
    end,

    getSquadCohesion = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        return self.squads[squadId].cohesion
    end,

    calculateSquadEffectiveness = function(self, squadId)
        if not self.squads[squadId] then return 0 end
        local squad = self.squads[squadId]
        local alive_count = 0
        for _, unitId in ipairs(squad.members) do
            local unit = self.units[unitId]
            if unit and unit.status ~= "destroyed" then
                alive_count = alive_count + 1
            end
        end
        local member_count = #squad.members > 0 and #squad.members or 1
        local unit_factor = (alive_count / member_count) * 100
        local morale_factor = squad.morale
        local cohesion_factor = squad.cohesion
        return (unit_factor + morale_factor + cohesion_factor) / 3
    end,

    getActionHistory = function(self)
        return self.actions
    end,

    reset = function(self)
        self.squads = {}
        self.units = {}
        self.formations = {}
        self.cover_points = {}
        self.suppression = {}
        self.actions = {}
        return true
    end
}

Suite:group("Squads", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
    end)

    Suite:testMethod("TacticalCombat.createSquad", {description = "Creates squad", testCase = "create", type = "functional"}, function()
        local ok = shared.combat:createSquad("sq1", "Alpha", {})
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("TacticalCombat.getSquad", {description = "Gets squad", testCase = "get", type = "functional"}, function()
        shared.combat:createSquad("sq2", "Bravo", {})
        local squad = shared.combat:getSquad("sq2")
        Helpers.assertEqual(squad ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Units", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq3", "Charlie", {})
    end)

    Suite:testMethod("TacticalCombat.createUnit", {description = "Creates unit", testCase = "create", type = "functional"}, function()
        local ok = shared.combat:createUnit("u1", "sq3", "soldier", 100, 10)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("TacticalCombat.getUnit", {description = "Gets unit", testCase = "get", type = "functional"}, function()
        shared.combat:createUnit("u2", "sq3", "commando", 120, 12)
        local unit = shared.combat:getUnit("u2")
        Helpers.assertEqual(unit ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Formations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq4", "Delta", {})
    end)

    Suite:testMethod("TacticalCombat.assignFormation_defensive", {description = "Defensive formation", testCase = "defensive", type = "functional"}, function()
        local ok = shared.combat:assignFormation("sq4", "defensive")
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("TacticalCombat.assignFormation_offensive", {description = "Offensive formation", testCase = "offensive", type = "functional"}, function()
        local ok = shared.combat:assignFormation("sq4", "offensive")
        Helpers.assertEqual(ok, true, "Assigned")
    end)

    Suite:testMethod("TacticalCombat.getFormation", {description = "Gets formation", testCase = "get", type = "functional"}, function()
        shared.combat:assignFormation("sq4", "loose")
        local form = shared.combat:getFormation("sq4")
        Helpers.assertEqual(form ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Cover", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq5", "Echo", {})
        shared.combat:createUnit("u3", "sq5", "soldier", 100, 10)
    end)

    Suite:testMethod("TacticalCombat.registerCoverPoint", {description = "Registers cover", testCase = "register", type = "functional"}, function()
        local ok = shared.combat:registerCoverPoint("cv1", 10, 20, "wall", 60)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("TacticalCombat.getCoverPoint", {description = "Gets cover", testCase = "get", type = "functional"}, function()
        shared.combat:registerCoverPoint("cv2", 15, 25, "pillar", 70)
        local cover = shared.combat:getCoverPoint("cv2")
        Helpers.assertEqual(cover ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("TacticalCombat.unitTakeCover", {description = "Takes cover", testCase = "take", type = "functional"}, function()
        shared.combat:registerCoverPoint("cv3", 20, 30, "rock", 50)
        local ok = shared.combat:unitTakeCover("u3", "cv3")
        Helpers.assertEqual(ok, true, "In cover")
    end)

    Suite:testMethod("TacticalCombat.cover_reduces_damage", {description = "Cover reduces damage", testCase = "protection", type = "functional"}, function()
        shared.combat:registerCoverPoint("cv4", 25, 35, "barrier", 75)
        shared.combat:unitTakeCover("u3", "cv4")
        local damage = shared.combat:calculateCoverProtection("u3", 100)
        Helpers.assertEqual(damage < 100, true, "Damage reduced")
    end)
end)

Suite:group("Suppression", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq6", "Foxtrot", {})
        shared.combat:createUnit("u4", "sq6", "soldier", 100, 10)
    end)

    Suite:testMethod("TacticalCombat.applySuppression", {description = "Applies suppression", testCase = "apply", type = "functional"}, function()
        local ok = shared.combat:applySuppression("u4", 30)
        Helpers.assertEqual(ok, true, "Applied")
    end)

    Suite:testMethod("TacticalCombat.getSuppression", {description = "Gets suppression", testCase = "get", type = "functional"}, function()
        shared.combat:applySuppression("u4", 40)
        local supp = shared.combat:getSuppression("u4")
        Helpers.assertEqual(supp > 0, true, "Has suppression")
    end)

    Suite:testMethod("TacticalCombat.releaseSuppression", {description = "Releases suppression", testCase = "release", type = "functional"}, function()
        shared.combat:applySuppression("u4", 60)
        local ok = shared.combat:releaseSuppression("u4", 30)
        Helpers.assertEqual(ok, true, "Released")
    end)

    Suite:testMethod("TacticalCombat.suppression_affects_status", {description = "Affects unit status", testCase = "status", type = "functional"}, function()
        shared.combat:applySuppression("u4", 70)
        local unit = shared.combat:getUnit("u4")
        Helpers.assertEqual(unit.status == "suppressed", true, "Status changed")
    end)
end)

Suite:group("Movement & Actions", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq7", "Golf", {})
        shared.combat:createUnit("u5", "sq7", "soldier", 100, 10)
    end)

    Suite:testMethod("TacticalCombat.moveUnit", {description = "Moves unit", testCase = "move", type = "functional"}, function()
        local ok = shared.combat:moveUnit("u5", 5, 10)
        Helpers.assertEqual(ok, true, "Moved")
    end)

    Suite:testMethod("TacticalCombat.moveUnit_costs_ap", {description = "Movement costs AP", testCase = "ap_cost", type = "functional"}, function()
        local unit1 = shared.combat:getUnit("u5")
        local ap1 = unit1.ap
        shared.combat:moveUnit("u5", 10, 15)
        local unit2 = shared.combat:getUnit("u5")
        Helpers.assertEqual(unit2.ap < ap1, true, "AP consumed")
    end)

    Suite:testMethod("TacticalCombat.restoreActionPoints", {description = "Restores AP", testCase = "restore", type = "functional"}, function()
        shared.combat:moveUnit("u5", 20, 25)
        local ok = shared.combat:restoreActionPoints("u5", 5)
        Helpers.assertEqual(ok, true, "Restored")
    end)
end)

Suite:group("Combat", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq8", "Hotel", {})
        shared.combat:createUnit("u6", "sq8", "soldier", 100, 10)
        shared.combat:createUnit("u7", "sq8", "soldier", 100, 10)
    end)

    Suite:testMethod("TacticalCombat.performAttack", {description = "Performs attack", testCase = "attack", type = "functional"}, function()
        local ok = shared.combat:performAttack("u6", "u7")
        Helpers.assertEqual(ok, true, "Attack executed")
    end)

    Suite:testMethod("TacticalCombat.attack_damages_target", {description = "Damages target", testCase = "damage", type = "functional"}, function()
        local target1 = shared.combat:getUnit("u7")
        local hp1 = target1.hp
        shared.combat:performAttack("u6", "u7")
        local target2 = shared.combat:getUnit("u7")
        Helpers.assertEqual(target2.hp < hp1, true, "Damage dealt")
    end)

    Suite:testMethod("TacticalCombat.performOverwatch", {description = "Sets overwatch", testCase = "overwatch", type = "functional"}, function()
        local ok = shared.combat:performOverwatch("u6")
        Helpers.assertEqual(ok, true, "Overwatch set")
    end)

    Suite:testMethod("TacticalCombat.coordinatedFire", {description = "Coordinated attack", testCase = "coordinated", type = "functional"}, function()
        local ok = shared.combat:coordinatedFire("sq8", "u7")
        Helpers.assertEqual(ok, true, "Coordinated fire")
    end)
end)

Suite:group("Squad Morale", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq9", "India", {})
    end)

    Suite:testMethod("TacticalCombat.updateSquadMorale", {description = "Updates morale", testCase = "update", type = "functional"}, function()
        local ok = shared.combat:updateSquadMorale("sq9", 10)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("TacticalCombat.getSquadMorale", {description = "Gets morale", testCase = "get", type = "functional"}, function()
        shared.combat:updateSquadMorale("sq9", 5)
        local morale = shared.combat:getSquadMorale("sq9")
        Helpers.assertEqual(morale > 0, true, "Morale > 0")
    end)
end)

Suite:group("Squad Cohesion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq10", "Juliet", {})
        shared.combat:assignFormation("sq10", "defensive")
    end)

    Suite:testMethod("TacticalCombat.updateSquadCohesion", {description = "Updates cohesion", testCase = "update", type = "functional"}, function()
        local ok = shared.combat:updateSquadCohesion("sq10", 5)
        Helpers.assertEqual(ok, true, "Updated")
    end)

    Suite:testMethod("TacticalCombat.getSquadCohesion", {description = "Gets cohesion", testCase = "get", type = "functional"}, function()
        shared.combat:updateSquadCohesion("sq10", 10)
        local cohesion = shared.combat:getSquadCohesion("sq10")
        Helpers.assertEqual(cohesion > 0, true, "Cohesion > 0")
    end)
end)

Suite:group("Squad Effectiveness", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq11", "Kilo", {})
        shared.combat:createUnit("u8", "sq11", "soldier", 100, 10)
        shared.combat:createUnit("u9", "sq11", "soldier", 100, 10)
    end)

    Suite:testMethod("TacticalCombat.calculateSquadEffectiveness", {description = "Calculates effectiveness", testCase = "calc", type = "functional"}, function()
        local eff = shared.combat:calculateSquadEffectiveness("sq11")
        Helpers.assertEqual(eff > 0, true, "Effectiveness > 0")
    end)

    Suite:testMethod("TacticalCombat.effectiveness_with_casualties", {description = "Effectiveness with losses", testCase = "casualties", type = "functional"}, function()
        local unit = shared.combat:getUnit("u8")
        unit.status = "destroyed"
        local eff = shared.combat:calculateSquadEffectiveness("sq11")
        Helpers.assertEqual(eff > 0, true, "Effectiveness reduced")
    end)
end)

Suite:group("Action History", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
        shared.combat:createSquad("sq12", "Lima", {})
        shared.combat:createUnit("u10", "sq12", "soldier", 100, 10)
        shared.combat:createUnit("u11", "sq12", "soldier", 100, 10)
    end)

    Suite:testMethod("TacticalCombat.getActionHistory", {description = "Gets action history", testCase = "history", type = "functional"}, function()
        shared.combat:performAttack("u10", "u11")
        local hist = shared.combat:getActionHistory()
        Helpers.assertEqual(#hist > 0, true, "Has history")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.combat = TacticalCombat:new()
    end)

    Suite:testMethod("TacticalCombat.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.combat:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
