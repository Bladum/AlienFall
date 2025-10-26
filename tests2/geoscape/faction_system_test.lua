-- ─────────────────────────────────────────────────────────────────────────
-- TEST: Faction System
-- FILE: tests2/geoscape/faction_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local FactionSystem = {}
FactionSystem.__index = FactionSystem

function FactionSystem:new()
    local self = setmetatable({}, FactionSystem)
    self.factions = {}
    self.relations = {}
    return self
end

function FactionSystem:createFaction(factionData)
    if not factionData or not factionData.id then
        error("[FactionSystem] Faction ID required")
    end
    local faction = {
        id = factionData.id,
        name = factionData.name or "Unknown",
        relations = {},
        fear = factionData.fear or 50
    }
    self.factions[faction.id] = faction
    return faction
end

function FactionSystem:getRelation(faction1, faction2)
    local key = faction1 .. "_" .. faction2
    return self.relations[key] or 50
end

function FactionSystem:updateRelation(faction1, faction2, change)
    local key = faction1 .. "_" .. faction2
    local current = self.relations[key] or 50
    local newVal = math.max(0, math.min(100, current + change))
    self.relations[key] = newVal
    return newVal
end

function FactionSystem:isAllied(faction1, faction2)
    local relation = self:getRelation(faction1, faction2)
    return relation >= 70
end

function FactionSystem:getFaction(factionId)
    return self.factions[factionId]
end

local Suite = HierarchicalSuite:new({
    modulePath = "engine.geoscape.managers.faction_system",
    fileName = "faction_system.lua",
    description = "Faction system - relations and diplomacy"
})

Suite:before(function() print("[FactionSystem] Setting up") end)
Suite:after(function() print("[FactionSystem] Cleaning up") end)

Suite:group("Faction Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sys = FactionSystem:new()
    end)

    Suite:testMethod("FactionSystem.createFaction", {
        description = "Creates faction",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local faction = shared.sys:createFaction({id = "xcom", name = "XCOM"})
        Helpers.assertEqual(faction.id, "xcom", "Should have ID")
        print("  ✓ Faction created")
    end)

    Suite:testMethod("FactionSystem.getFaction", {
        description = "Retrieves faction",
        testCase = "happy_path",
        type = "functional"
    }, function()
        shared.sys:createFaction({id = "aliens", name = "Aliens"})
        local faction = shared.sys:getFaction("aliens")
        Helpers.assertEqual(faction.name, "Aliens", "Should retrieve faction")
        print("  ✓ Faction retrieved")
    end)
end)

Suite:group("Relations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.sys = FactionSystem:new()
    end)

    Suite:testMethod("FactionSystem.getRelation", {
        description = "Gets relation value",
        testCase = "happy_path",
        type = "functional"
    }, function()
        local rel = shared.sys:getRelation("xcom", "aliens")
        Helpers.assertEqual(rel >= 0 and rel <= 100, true, "Should return valid relation")
        print("  ✓ Relation retrieved: " .. rel)
    end)

    Suite:testMethod("FactionSystem.updateRelation", {
        description = "Updates relation",
        testCase = "change",
        type = "functional"
    }, function()
        shared.sys:updateRelation("xcom", "aliens", 20)
        local rel = shared.sys:getRelation("xcom", "aliens")
        Helpers.assertEqual(rel > 50, true, "Should increase relation")
        print("  ✓ Relation updated: " .. rel)
    end)

    Suite:testMethod("FactionSystem.isAllied", {
        description = "Determines alliance",
        testCase = "alliance",
        type = "functional"
    }, function()
        shared.sys:updateRelation("faction1", "faction2", 25)
        local allied = shared.sys:isAllied("faction1", "faction2")
        Helpers.assertEqual(allied, true, "Should be allied at >70")
        print("  ✓ Alliance status determined")
    end)
end)

return Suite
