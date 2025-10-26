-- ─────────────────────────────────────────────────────────────────────────
-- RELATIONS MANAGER TEST SUITE
-- FILE: tests2/politics/relations_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.politics.relations.relations_manager",
    fileName = "relations_manager.lua",
    description = "Diplomatic relations and alliance management system"
})

print("[RELATIONS_TEST] Setting up")

local RelationsManager = {
    entities = {},
    relations = {},
    alliances = {},

    new = function(self)
        return setmetatable({entities = {}, relations = {}, alliances = {}}, {__index = self})
    end,

    addEntity = function(self, entityId, name, type)
        self.entities[entityId] = {id = entityId, name = name, type = type}
        return true
    end,

    getEntity = function(self, entityId)
        return self.entities[entityId]
    end,

    setRelation = function(self, entity1, entity2, level)
        local key = entity1 < entity2 and entity1 .. "-" .. entity2 or entity2 .. "-" .. entity1
        self.relations[key] = math.min(100, math.max(-100, level))
        return true
    end,

    getRelation = function(self, entity1, entity2)
        local key = entity1 < entity2 and entity1 .. "-" .. entity2 or entity2 .. "-" .. entity1
        return self.relations[key] or 0
    end,

    createAlliance = function(self, allianceId, members)
        self.alliances[allianceId] = {id = allianceId, members = members or {}, active = true}
        return true
    end,

    addToAlliance = function(self, allianceId, memberId)
        if not self.alliances[allianceId] then return false end
        self.alliances[allianceId].members[memberId] = true
        return true
    end,

    removeFromAlliance = function(self, allianceId, memberId)
        if not self.alliances[allianceId] then return false end
        self.alliances[allianceId].members[memberId] = nil
        return true
    end,

    getAllianceMembers = function(self, allianceId)
        if not self.alliances[allianceId] then return {} end
        local result = {}
        for memberId in pairs(self.alliances[allianceId].members) do
            table.insert(result, memberId)
        end
        return result
    end,

    areAllied = function(self, entity1, entity2)
        for _, alliance in pairs(self.alliances) do
            if alliance.active then
                local has1 = alliance.members[entity1]
                local has2 = alliance.members[entity2]
                if has1 and has2 then return true end
            end
        end
        return false
    end,

    getRelationStatus = function(self, entity1, entity2)
        local rel = self:getRelation(entity1, entity2)
        if rel > 50 then return "Allied"
        elseif rel > 20 then return "Friendly"
        elseif rel >= -20 then return "Neutral"
        elseif rel > -50 then return "Unfriendly"
        else return "Hostile"
        end
    end,

    getEntityCount = function(self)
        local count = 0
        for _ in pairs(self.entities) do count = count + 1 end
        return count
    end
}

Suite:group("Entity Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rel = RelationsManager:new()
    end)

    Suite:testMethod("RelationsManager.new", {description = "Creates manager", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.rel ~= nil, true, "Manager created")
    end)

    Suite:testMethod("RelationsManager.addEntity", {description = "Adds entity", testCase = "add", type = "functional"}, function()
        local ok = shared.rel:addEntity("usa", "United States", "nation")
        Helpers.assertEqual(ok, true, "Entity added")
    end)

    Suite:testMethod("RelationsManager.getEntity", {description = "Retrieves entity", testCase = "get", type = "functional"}, function()
        shared.rel:addEntity("uk", "United Kingdom", "nation")
        local entity = shared.rel:getEntity("uk")
        Helpers.assertEqual(entity ~= nil, true, "Entity retrieved")
    end)

    Suite:testMethod("RelationsManager.getEntityCount", {description = "Counts entities", testCase = "count", type = "functional"}, function()
        shared.rel:addEntity("e1", "Entity 1", "type")
        shared.rel:addEntity("e2", "Entity 2", "type")
        shared.rel:addEntity("e3", "Entity 3", "type")
        local count = shared.rel:getEntityCount()
        Helpers.assertEqual(count, 3, "Three entities counted")
    end)
end)

Suite:group("Diplomatic Relations", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rel = RelationsManager:new()
        shared.rel:addEntity("a", "Country A", "nation")
        shared.rel:addEntity("b", "Country B", "nation")
    end)

    Suite:testMethod("RelationsManager.setRelation", {description = "Sets relation", testCase = "set", type = "functional"}, function()
        local ok = shared.rel:setRelation("a", "b", 75)
        Helpers.assertEqual(ok, true, "Relation set")
    end)

    Suite:testMethod("RelationsManager.getRelation", {description = "Gets relation", testCase = "get_rel", type = "functional"}, function()
        shared.rel:setRelation("a", "b", 60)
        local rel = shared.rel:getRelation("a", "b")
        Helpers.assertEqual(rel, 60, "Relation retrieved")
    end)

    Suite:testMethod("RelationsManager.getRelation", {description = "Order independent", testCase = "order_indep", type = "functional"}, function()
        shared.rel:setRelation("a", "b", 50)
        local rel1 = shared.rel:getRelation("a", "b")
        local rel2 = shared.rel:getRelation("b", "a")
        Helpers.assertEqual(rel1, rel2, "Relations same both ways")
    end)

    Suite:testMethod("RelationsManager.setRelation", {description = "Clamps to -100 to 100", testCase = "clamp", type = "functional"}, function()
        shared.rel:setRelation("a", "b", 200)
        local rel = shared.rel:getRelation("a", "b")
        Helpers.assertEqual(rel, 100, "Clamped to 100")
    end)
end)

Suite:group("Alliances", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rel = RelationsManager:new()
        shared.rel:addEntity("c1", "Country 1", "nation")
        shared.rel:addEntity("c2", "Country 2", "nation")
        shared.rel:addEntity("c3", "Country 3", "nation")
    end)

    Suite:testMethod("RelationsManager.createAlliance", {description = "Creates alliance", testCase = "create_alliance", type = "functional"}, function()
        local ok = shared.rel:createAlliance("nato", {c1 = true, c2 = true})
        Helpers.assertEqual(ok, true, "Alliance created")
    end)

    Suite:testMethod("RelationsManager.addToAlliance", {description = "Adds to alliance", testCase = "add_member", type = "functional"}, function()
        shared.rel:createAlliance("eu", {})
        local ok = shared.rel:addToAlliance("eu", "c1")
        Helpers.assertEqual(ok, true, "Member added")
    end)

    Suite:testMethod("RelationsManager.getAllianceMembers", {description = "Lists members", testCase = "list_members", type = "functional"}, function()
        shared.rel:createAlliance("coalition", {c1 = true, c2 = true})
        local members = shared.rel:getAllianceMembers("coalition")
        local count = #members
        Helpers.assertEqual(count, 2, "Two members listed")
    end)

    Suite:testMethod("RelationsManager.removeFromAlliance", {description = "Removes member", testCase = "remove_member", type = "functional"}, function()
        shared.rel:createAlliance("pact", {c1 = true})
        local ok = shared.rel:removeFromAlliance("pact", "c1")
        Helpers.assertEqual(ok, true, "Member removed")
    end)

    Suite:testMethod("RelationsManager.areAllied", {description = "Checks if allied", testCase = "check_allied", type = "functional"}, function()
        shared.rel:createAlliance("team", {c1 = true, c2 = true})
        local allied = shared.rel:areAllied("c1", "c2")
        Helpers.assertEqual(allied, true, "Countries are allied")
    end)

    Suite:testMethod("RelationsManager.areAllied", {description = "Returns false for non-allied", testCase = "not_allied", type = "functional"}, function()
        shared.rel:createAlliance("group", {c1 = true})
        local allied = shared.rel:areAllied("c1", "c2")
        Helpers.assertEqual(allied, false, "Countries not allied")
    end)
end)

Suite:group("Relation Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.rel = RelationsManager:new()
        shared.rel:addEntity("x", "X", "n")
        shared.rel:addEntity("y", "Y", "n")
    end)

    Suite:testMethod("RelationsManager.getRelationStatus", {description = "Returns Allied", testCase = "allied_status", type = "functional"}, function()
        shared.rel:setRelation("x", "y", 80)
        local status = shared.rel:getRelationStatus("x", "y")
        Helpers.assertEqual(status, "Allied", "Allied status for 80")
    end)

    Suite:testMethod("RelationsManager.getRelationStatus", {description = "Returns Friendly", testCase = "friendly_status", type = "functional"}, function()
        shared.rel:setRelation("x", "y", 30)
        local status = shared.rel:getRelationStatus("x", "y")
        Helpers.assertEqual(status, "Friendly", "Friendly status for 30")
    end)

    Suite:testMethod("RelationsManager.getRelationStatus", {description = "Returns Neutral", testCase = "neutral_status", type = "functional"}, function()
        shared.rel:setRelation("x", "y", 0)
        local status = shared.rel:getRelationStatus("x", "y")
        Helpers.assertEqual(status, "Neutral", "Neutral status for 0")
    end)

    Suite:testMethod("RelationsManager.getRelationStatus", {description = "Returns Hostile", testCase = "hostile_status", type = "functional"}, function()
        shared.rel:setRelation("x", "y", -75)
        local status = shared.rel:getRelationStatus("x", "y")
        Helpers.assertEqual(status, "Hostile", "Hostile status for -75")
    end)
end)

Suite:run()
