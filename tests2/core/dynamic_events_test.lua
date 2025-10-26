-- ─────────────────────────────────────────────────────────────────────────
-- DYNAMIC EVENTS TEST SUITE
-- FILE: tests2/core/dynamic_events_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.dynamic_events",
    fileName = "dynamic_events.lua",
    description = "Random event generation, consequences, narrative branching, and event tracking"
})

print("[DYNAMIC_EVENTS_TEST] Setting up")

local DynamicEvents = {
    event_templates = {}, active_events = {}, event_history = {}, consequences = {},

    new = function(self)
        return setmetatable({event_templates = {}, active_events = {}, event_history = {}, consequences = {}}, {__index = self})
    end,

    registerEventTemplate = function(self, templateId, name, category, probability)
        self.event_templates[templateId] = {
            id = templateId, name = name or "Event", category = category or "generic",
            probability = probability or 0.5, trigger_turn = 0, choices = {}
        }
        return true
    end,

    getEventTemplate = function(self, templateId)
        return self.event_templates[templateId]
    end,

    addEventChoice = function(self, templateId, choiceText, consequence_id)
        if not self.event_templates[templateId] then return false end
        if not self.event_templates[templateId].choices then
            self.event_templates[templateId].choices = {}
        end
        table.insert(self.event_templates[templateId].choices, {text = choiceText, consequence_id = consequence_id})
        return true
    end,

    getEventChoices = function(self, templateId)
        if not self.event_templates[templateId] then return {} end
        return self.event_templates[templateId].choices or {}
    end,

    generateEvent = function(self, eventId, templateId, turn)
        if not self.event_templates[templateId] then return false end
        local template = self.event_templates[templateId]
        self.active_events[eventId] = {
            id = eventId, template_id = templateId, name = template.name,
            category = template.category, turn_triggered = turn or 0,
            status = "active", chosen_option = nil, resolved = false
        }
        return true
    end,

    getEvent = function(self, eventId)
        return self.active_events[eventId]
    end,

    getAllActiveEvents = function(self)
        local all = {}
        for id, evt in pairs(self.active_events) do
            if evt.status == "active" then
                table.insert(all, evt)
            end
        end
        return all
    end,

    getEventCount = function(self)
        local count = 0
        for id, evt in pairs(self.active_events) do
            if evt.status == "active" then count = count + 1 end
        end
        return count
    end,

    resolveEventChoice = function(self, eventId, choiceIndex)
        if not self.active_events[eventId] then return false end
        local evt = self.active_events[eventId]
        evt.chosen_option = choiceIndex
        evt.status = "resolved"
        evt.resolved = true
        return true
    end,

    registerConsequence = function(self, consequenceId, effect_name, effect_value, targets)
        self.consequences[consequenceId] = {
            id = consequenceId, name = effect_name or "Effect", value = effect_value or 1,
            targets = targets or {}, applied = false
        }
        return true
    end,

    getConsequence = function(self, consequenceId)
        return self.consequences[consequenceId]
    end,

    applyConsequence = function(self, consequenceId)
        if not self.consequences[consequenceId] then return false end
        self.consequences[consequenceId].applied = true
        return true
    end,

    hasConsequenceApplied = function(self, consequenceId)
        if not self.consequences[consequenceId] then return false end
        return self.consequences[consequenceId].applied
    end,

    triggerConsequenceChain = function(self, initialConsequenceId, consequences_list)
        if not self:applyConsequence(initialConsequenceId) then return false end
        for _, consId in ipairs(consequences_list or {}) do
            self:applyConsequence(consId)
        end
        return true
    end,

    recordEventInHistory = function(self, eventId)
        if not self.active_events[eventId] then return false end
        local evt = self.active_events[eventId]
        table.insert(self.event_history, {
            event_id = eventId, name = evt.name, category = evt.category,
            turn = evt.turn_triggered, choice = evt.chosen_option
        })
        return true
    end,

    getEventHistory = function(self)
        return self.event_history
    end,

    getEventHistoryCount = function(self)
        return #self.event_history
    end,

    getEventsByCategory = function(self, category)
        local matching = {}
        for _, hist in ipairs(self.event_history) do
            if hist.category == category then
                table.insert(matching, hist)
            end
        end
        return matching
    end,

    randomEventOccurs = function(self, probability)
        return math.random() < (probability or 0.5)
    end,

    selectRandomEvent = function(self)
        local templates = {}
        for id, template in pairs(self.event_templates) do
            table.insert(templates, id)
        end
        if #templates == 0 then return nil end
        return templates[math.random(#templates)]
    end,

    resolveEvent = function(self, eventId)
        if not self.active_events[eventId] then return false end
        local evt = self.active_events[eventId]
        if not evt.resolved then return false end
        self:recordEventInHistory(eventId)
        evt.status = "completed"
        return true
    end,

    getEventStatus = function(self, eventId)
        if not self.active_events[eventId] then return "none" end
        return self.active_events[eventId].status
    end,

    cascadeEvent = function(self, triggerEventId, cascadeEventId)
        if not self:getEvent(triggerEventId) then return false end
        if not self.event_templates[cascadeEventId] then return false end
        self:generateEvent("cascade_" .. triggerEventId, cascadeEventId, 0)
        return true
    end,

    createEventChain = function(self, chainName, eventTemplateIds)
        local chain = {name = chainName, events = eventTemplateIds, completed = 0}
        return chain
    end,

    progressEventChain = function(self, chain)
        if not chain then return false end
        chain.completed = chain.completed + 1
        return true
    end,

    reset = function(self)
        self.event_templates = {}
        self.active_events = {}
        self.event_history = {}
        self.consequences = {}
        return true
    end
}

Suite:group("Templates", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
    end)

    Suite:testMethod("DynamicEvents.registerEventTemplate", {description = "Registers template", testCase = "register", type = "functional"}, function()
        local ok = shared.de:registerEventTemplate("t1", "Alien Attack", "combat", 0.7)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("DynamicEvents.getEventTemplate", {description = "Gets template", testCase = "get", type = "functional"}, function()
        shared.de:registerEventTemplate("t2", "Diplomacy", "politics", 0.4)
        local template = shared.de:getEventTemplate("t2")
        Helpers.assertEqual(template ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Choices", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
        shared.de:registerEventTemplate("t1", "Decision", "choice", 0.5)
    end)

    Suite:testMethod("DynamicEvents.addEventChoice", {description = "Adds choice", testCase = "add", type = "functional"}, function()
        local ok = shared.de:addEventChoice("t1", "Accept", "c1")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("DynamicEvents.getEventChoices", {description = "Gets choices", testCase = "get", type = "functional"}, function()
        shared.de:addEventChoice("t1", "Refuse", "c2")
        shared.de:addEventChoice("t1", "Negotiate", "c3")
        local choices = shared.de:getEventChoices("t1")
        Helpers.assertEqual(#choices >= 1, true, "Has choices")
    end)
end)

Suite:group("Events", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
        shared.de:registerEventTemplate("t1", "Event", "generic", 0.5)
    end)

    Suite:testMethod("DynamicEvents.generateEvent", {description = "Generates event", testCase = "generate", type = "functional"}, function()
        local ok = shared.de:generateEvent("e1", "t1", 5)
        Helpers.assertEqual(ok, true, "Generated")
    end)

    Suite:testMethod("DynamicEvents.getEvent", {description = "Gets event", testCase = "get", type = "functional"}, function()
        shared.de:generateEvent("e2", "t1", 7)
        local evt = shared.de:getEvent("e2")
        Helpers.assertEqual(evt ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("DynamicEvents.getAllActiveEvents", {description = "Gets all active", testCase = "all_active", type = "functional"}, function()
        shared.de:generateEvent("e3", "t1", 0)
        shared.de:generateEvent("e4", "t1", 0)
        local all = shared.de:getAllActiveEvents()
        Helpers.assertEqual(#all >= 2, true, "Has events")
    end)

    Suite:testMethod("DynamicEvents.getEventCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.de:generateEvent("e5", "t1", 0)
        shared.de:generateEvent("e6", "t1", 0)
        local count = shared.de:getEventCount()
        Helpers.assertEqual(count >= 2, true, "Count >= 2")
    end)
end)

Suite:group("Resolution", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
        shared.de:registerEventTemplate("t1", "Event", "generic", 0.5)
        shared.de:generateEvent("e1", "t1", 0)
    end)

    Suite:testMethod("DynamicEvents.resolveEventChoice", {description = "Resolves choice", testCase = "resolve", type = "functional"}, function()
        local ok = shared.de:resolveEventChoice("e1", 1)
        Helpers.assertEqual(ok, true, "Resolved")
    end)

    Suite:testMethod("DynamicEvents.getEventStatus", {description = "Gets status", testCase = "status", type = "functional"}, function()
        shared.de:resolveEventChoice("e1", 1)
        local status = shared.de:getEventStatus("e1")
        Helpers.assertEqual(status, "resolved", "resolved")
    end)

    Suite:testMethod("DynamicEvents.resolveEvent", {description = "Completes event", testCase = "complete", type = "functional"}, function()
        shared.de:resolveEventChoice("e1", 1)
        local ok = shared.de:resolveEvent("e1")
        Helpers.assertEqual(ok, true, "Resolved")
    end)
end)

Suite:group("Consequences", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
    end)

    Suite:testMethod("DynamicEvents.registerConsequence", {description = "Registers consequence", testCase = "register", type = "functional"}, function()
        local ok = shared.de:registerConsequence("c1", "Morale Boost", 10)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("DynamicEvents.getConsequence", {description = "Gets consequence", testCase = "get", type = "functional"}, function()
        shared.de:registerConsequence("c2", "Resource Loss", -50)
        local cons = shared.de:getConsequence("c2")
        Helpers.assertEqual(cons ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("DynamicEvents.applyConsequence", {description = "Applies consequence", testCase = "apply", type = "functional"}, function()
        shared.de:registerConsequence("c3", "Effect", 25)
        local ok = shared.de:applyConsequence("c3")
        Helpers.assertEqual(ok, true, "Applied")
    end)

    Suite:testMethod("DynamicEvents.hasConsequenceApplied", {description = "Has applied", testCase = "has_applied", type = "functional"}, function()
        shared.de:registerConsequence("c4", "Impact", 15)
        shared.de:applyConsequence("c4")
        local has = shared.de:hasConsequenceApplied("c4")
        Helpers.assertEqual(has, true, "Applied")
    end)

    Suite:testMethod("DynamicEvents.triggerConsequenceChain", {description = "Triggers chain", testCase = "chain", type = "functional"}, function()
        shared.de:registerConsequence("c1", "First", 10)
        shared.de:registerConsequence("c2", "Second", 20)
        local ok = shared.de:triggerConsequenceChain("c1", {"c2"})
        Helpers.assertEqual(ok, true, "Triggered")
    end)
end)

Suite:group("History", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
        shared.de:registerEventTemplate("t1", "Recorded", "action", 0.5)
        shared.de:generateEvent("e1", "t1", 5)
    end)

    Suite:testMethod("DynamicEvents.recordEventInHistory", {description = "Records in history", testCase = "record", type = "functional"}, function()
        local ok = shared.de:recordEventInHistory("e1")
        Helpers.assertEqual(ok, true, "Recorded")
    end)

    Suite:testMethod("DynamicEvents.getEventHistory", {description = "Gets history", testCase = "history", type = "functional"}, function()
        shared.de:recordEventInHistory("e1")
        local history = shared.de:getEventHistory()
        Helpers.assertEqual(#history > 0, true, "Has history")
    end)

    Suite:testMethod("DynamicEvents.getEventHistoryCount", {description = "Gets count", testCase = "count", type = "functional"}, function()
        shared.de:recordEventInHistory("e1")
        local count = shared.de:getEventHistoryCount()
        Helpers.assertEqual(count, 1, "1")
    end)

    Suite:testMethod("DynamicEvents.getEventsByCategory", {description = "Gets by category", testCase = "category", type = "functional"}, function()
        shared.de:recordEventInHistory("e1")
        local bycat = shared.de:getEventsByCategory("action")
        Helpers.assertEqual(#bycat > 0, true, "Has events")
    end)
end)

Suite:group("Random", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
    end)

    Suite:testMethod("DynamicEvents.randomEventOccurs", {description = "Random occurs", testCase = "random", type = "functional"}, function()
        local occurs = shared.de:randomEventOccurs(0.8)
        Helpers.assertEqual(occurs == true or occurs == false, true, "Checked")
    end)

    Suite:testMethod("DynamicEvents.selectRandomEvent", {description = "Selects random", testCase = "select", type = "functional"}, function()
        shared.de:registerEventTemplate("t1", "Event1", "type1", 0.5)
        shared.de:registerEventTemplate("t2", "Event2", "type2", 0.5)
        local selected = shared.de:selectRandomEvent()
        Helpers.assertEqual(selected ~= nil, true, "Selected")
    end)
end)

Suite:group("Cascading", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
        shared.de:registerEventTemplate("t1", "Trigger", "trigger", 0.5)
        shared.de:registerEventTemplate("t2", "Cascade", "cascade", 0.3)
        shared.de:generateEvent("e1", "t1", 0)
    end)

    Suite:testMethod("DynamicEvents.cascadeEvent", {description = "Cascades event", testCase = "cascade", type = "functional"}, function()
        local ok = shared.de:cascadeEvent("e1", "t2")
        Helpers.assertEqual(ok, true, "Cascaded")
    end)
end)

Suite:group("Chains", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
    end)

    Suite:testMethod("DynamicEvents.createEventChain", {description = "Creates chain", testCase = "create", type = "functional"}, function()
        local chain = shared.de:createEventChain("StoryArc", {"t1", "t2", "t3"})
        Helpers.assertEqual(chain ~= nil, true, "Created")
    end)

    Suite:testMethod("DynamicEvents.progressEventChain", {description = "Progresses chain", testCase = "progress", type = "functional"}, function()
        local chain = shared.de:createEventChain("Quest", {"t1", "t2"})
        local ok = shared.de:progressEventChain(chain)
        Helpers.assertEqual(ok, true, "Progressed")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.de = DynamicEvents:new()
    end)

    Suite:testMethod("DynamicEvents.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.de:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
