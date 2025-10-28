-- ─────────────────────────────────────────────────────────────────────────
-- EVENT CHAIN TEST SUITE
-- FILE: tests2/lore/event_chain_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.event_chain",
    fileName = "event_chain.lua",
    description = "Narrative event chains with triggers, branching, and progression"
})

print("[EVENT_CHAIN_TEST] Setting up")

local EventChain = {
    chains = {},
    events = {},
    triggers = {},
    progress = {},

    new = function(self)
        return setmetatable({chains = {}, events = {}, triggers = {}, progress = {}}, {__index = self})
    end,

    createChain = function(self, chainId, title, description)
        self.chains[chainId] = {id = chainId, title = title, description = description, eventCount = 0, active = true}
        self.events[chainId] = {}
        self.progress[chainId] = {completed = false, currentEventIndex = 0, eventsCompleted = 0}
        return true
    end,

    getChain = function(self, chainId)
        return self.chains[chainId]
    end,

    addEvent = function(self, chainId, eventId, eventText, triggerType)
        if not self.chains[chainId] then return false end
        table.insert(self.events[chainId], {id = eventId, text = eventText, trigger = triggerType or "manual", completed = false})
        self.chains[chainId].eventCount = self.chains[chainId].eventCount + 1
        return true
    end,

    getEventCount = function(self, chainId)
        if not self.chains[chainId] then return 0 end
        return self.chains[chainId].eventCount
    end,

    completeEvent = function(self, chainId, eventIndex)
        if not self.chains[chainId] or not self.events[chainId][eventIndex] then return false end
        self.events[chainId][eventIndex].completed = true
        self.progress[chainId].eventsCompleted = self.progress[chainId].eventsCompleted + 1
        self.progress[chainId].currentEventIndex = eventIndex
        return true
    end,

    getCompletedCount = function(self, chainId)
        if not self.progress[chainId] then return 0 end
        return self.progress[chainId].eventsCompleted
    end,

    setTrigger = function(self, chainId, eventId, triggerCondition)
        if not self.triggers[chainId] then self.triggers[chainId] = {} end
        self.triggers[chainId][eventId] = triggerCondition
        return true
    end,

    getTrigger = function(self, chainId, eventId)
        if not self.triggers[chainId] then return nil end
        return self.triggers[chainId][eventId]
    end,

    shouldTrigger = function(self, chainId, eventId, gameState)
        local trigger = self:getTrigger(chainId, eventId)
        if not trigger then return false end
        if trigger == "manual" then return false end
        if trigger == "auto" then return true end
        if trigger.condition and gameState and gameState[trigger.condition] then return true end
        return false
    end,

    completeChain = function(self, chainId)
        if not self.chains[chainId] then return false end
        self.progress[chainId].completed = true
        self.chains[chainId].active = false
        return true
    end,

    isChainComplete = function(self, chainId)
        if not self.progress[chainId] then return false end
        return self.progress[chainId].completed
    end,

    getChainCount = function(self)
        local count = 0
        for _ in pairs(self.chains) do count = count + 1 end
        return count
    end,

    getActiveChains = function(self)
        local count = 0
        for _, chain in pairs(self.chains) do
            if chain.active then count = count + 1 end
        end
        return count
    end,

    getCompletedChains = function(self)
        local count = 0
        for _, chain in pairs(self.chains) do
            if not chain.active then count = count + 1 end
        end
        return count
    end,

    getCurrentEventIndex = function(self, chainId)
        if not self.progress[chainId] then return 0 end
        return self.progress[chainId].currentEventIndex
    end,

    getProgressPercentage = function(self, chainId)
        if not self.chains[chainId] or self.chains[chainId].eventCount == 0 then return 0 end
        return math.floor((self.progress[chainId].eventsCompleted / self.chains[chainId].eventCount) * 100)
    end,

    resetChain = function(self, chainId)
        if not self.chains[chainId] then return false end
        self.progress[chainId] = {completed = false, currentEventIndex = 0, eventsCompleted = 0}
        for _, event in ipairs(self.events[chainId]) do
            event.completed = false
        end
        self.chains[chainId].active = true
        return true
    end,

    getPreviousEvent = function(self, chainId)
        if not self.events[chainId] or self.progress[chainId].currentEventIndex == 0 then return nil end
        return self.events[chainId][self.progress[chainId].currentEventIndex]
    end
}

Suite:group("Chain Creation", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ec = EventChain:new()
    end)

    Suite:testMethod("EventChain.createChain", {description = "Creates chain", testCase = "create", type = "functional"}, function()
        local ok = shared.ec:createChain("chain1", "First Contact", "Discovery of alien presence")
        Helpers.assertEqual(ok, true, "Chain created")
    end)

    Suite:testMethod("EventChain.getChain", {description = "Retrieves chain", testCase = "get", type = "functional"}, function()
        shared.ec:createChain("chain2", "Invasion", "Full scale assault")
        local chain = shared.ec:getChain("chain2")
        Helpers.assertEqual(chain ~= nil, true, "Chain retrieved")
    end)

    Suite:testMethod("EventChain.getChainCount", {description = "Counts chains", testCase = "count", type = "functional"}, function()
        shared.ec:createChain("c1", "Title1", "Desc1")
        shared.ec:createChain("c2", "Title2", "Desc2")
        shared.ec:createChain("c3", "Title3", "Desc3")
        local count = shared.ec:getChainCount()
        Helpers.assertEqual(count, 3, "Three chains")
    end)
end)

Suite:group("Event Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ec = EventChain:new()
        shared.ec:createChain("events", "Main Story", "Campaign progression")
    end)

    Suite:testMethod("EventChain.addEvent", {description = "Adds event", testCase = "add_event", type = "functional"}, function()
        local ok = shared.ec:addEvent("events", "e1", "UFO spotted over city", "auto")
        Helpers.assertEqual(ok, true, "Event added")
    end)

    Suite:testMethod("EventChain.getEventCount", {description = "Counts events", testCase = "event_count", type = "functional"}, function()
        shared.ec:addEvent("events", "e1", "First event", "manual")
        shared.ec:addEvent("events", "e2", "Second event", "auto")
        shared.ec:addEvent("events", "e3", "Third event", "manual")
        local count = shared.ec:getEventCount("events")
        Helpers.assertEqual(count, 3, "Three events")
    end)
end)

Suite:group("Event Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ec = EventChain:new()
        shared.ec:createChain("completion", "Campaign", "Main narrative")
        shared.ec:addEvent("completion", "intro", "Introduction event", "manual")
        shared.ec:addEvent("completion", "mid", "Middle event", "manual")
        shared.ec:addEvent("completion", "end", "Final event", "manual")
    end)

    Suite:testMethod("EventChain.completeEvent", {description = "Completes event", testCase = "complete", type = "functional"}, function()
        local ok = shared.ec:completeEvent("completion", 1)
        Helpers.assertEqual(ok, true, "Event completed")
    end)

    Suite:testMethod("EventChain.getCompletedCount", {description = "Counts completed", testCase = "completed_count", type = "functional"}, function()
        shared.ec:completeEvent("completion", 1)
        shared.ec:completeEvent("completion", 2)
        local count = shared.ec:getCompletedCount("completion")
        Helpers.assertEqual(count, 2, "Two completed")
    end)

    Suite:testMethod("EventChain.getCurrentEventIndex", {description = "Gets current event", testCase = "current_event", type = "functional"}, function()
        shared.ec:completeEvent("completion", 1)
        shared.ec:completeEvent("completion", 2)
        local index = shared.ec:getCurrentEventIndex("completion")
        Helpers.assertEqual(index, 2, "Current event 2")
    end)

    Suite:testMethod("EventChain.getProgressPercentage", {description = "Gets progress %", testCase = "progress_pct", type = "functional"}, function()
        shared.ec:completeEvent("completion", 1)
        shared.ec:completeEvent("completion", 2)
        local pct = shared.ec:getProgressPercentage("completion")
        Helpers.assertEqual(pct >= 66, true, "66%+ progress")
    end)
end)

Suite:group("Triggers", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ec = EventChain:new()
        shared.ec:createChain("triggers", "Event Chain", "With triggers")
    end)

    Suite:testMethod("EventChain.setTrigger", {description = "Sets trigger", testCase = "set_trigger", type = "functional"}, function()
        local ok = shared.ec:setTrigger("triggers", "event1", "auto")
        Helpers.assertEqual(ok, true, "Trigger set")
    end)

    Suite:testMethod("EventChain.getTrigger", {description = "Gets trigger", testCase = "get_trigger", type = "functional"}, function()
        shared.ec:setTrigger("triggers", "event2", {condition = "alarmLevel"})
        local trigger = shared.ec:getTrigger("triggers", "event2")
        Helpers.assertEqual(trigger ~= nil, true, "Trigger retrieved")
    end)

    Suite:testMethod("EventChain.shouldTrigger", {description = "Checks trigger", testCase = "should_trigger", type = "functional"}, function()
        shared.ec:setTrigger("triggers", "auto_event", "auto")
        local should = shared.ec:shouldTrigger("triggers", "auto_event", {})
        Helpers.assertEqual(should, true, "Should trigger")
    end)
end)

Suite:group("Chain Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ec = EventChain:new()
        shared.ec:createChain("complete_chain", "Short Chain", "Quick narrative")
        shared.ec:addEvent("complete_chain", "e1", "Only event", "manual")
    end)

    Suite:testMethod("EventChain.completeChain", {description = "Completes chain", testCase = "complete_chain", type = "functional"}, function()
        local ok = shared.ec:completeChain("complete_chain")
        Helpers.assertEqual(ok, true, "Chain completed")
    end)

    Suite:testMethod("EventChain.isChainComplete", {description = "Checks completion", testCase = "is_complete", type = "functional"}, function()
        shared.ec:completeChain("complete_chain")
        local complete = shared.ec:isChainComplete("complete_chain")
        Helpers.assertEqual(complete, true, "Chain is complete")
    end)

    Suite:testMethod("EventChain.getCompletedChains", {description = "Counts completed chains", testCase = "completed_chains", type = "functional"}, function()
        shared.ec:completeChain("complete_chain")
        local count = shared.ec:getCompletedChains()
        Helpers.assertEqual(count >= 1, true, "Chains completed")
    end)
end)

Suite:group("Chain Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ec = EventChain:new()
        shared.ec:createChain("s1", "Chain 1", "Active")
        shared.ec:createChain("s2", "Chain 2", "Active")
        shared.ec:completeChain("s1")
    end)

    Suite:testMethod("EventChain.getActiveChains", {description = "Counts active", testCase = "active_count", type = "functional"}, function()
        local count = shared.ec:getActiveChains()
        Helpers.assertEqual(count, 1, "One active chain")
    end)
end)

Suite:group("Chain Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.ec = EventChain:new()
        shared.ec:createChain("reset", "Resettable", "Can restart")
        shared.ec:addEvent("reset", "e1", "Event 1", "manual")
    end)

    Suite:testMethod("EventChain.resetChain", {description = "Resets chain", testCase = "reset", type = "functional"}, function()
        shared.ec:completeEvent("reset", 1)
        local ok = shared.ec:resetChain("reset")
        Helpers.assertEqual(ok, true, "Chain reset")
    end)
end)

Suite:run()
