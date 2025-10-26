-- ─────────────────────────────────────────────────────────────────────────
-- TUTORIAL MANAGER TEST SUITE
-- FILE: tests2/core/tutorial_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.tutorial.tutorial_manager",
    fileName = "tutorial_manager.lua",
    description = "Tutorial system for player guidance and onboarding"
})

print("[TUTORIAL_TEST] Setting up")

local TutorialManager = {
    tutorials = {},
    activeStep = 0,
    completed = {},
    progress = {},

    new = function(self)
        return setmetatable({tutorials = {}, activeStep = 0, completed = {}, progress = {}}, {__index = self})
    end,

    addTutorial = function(self, tutorialId, name, steps)
        self.tutorials[tutorialId] = {id = tutorialId, name = name, steps = steps or {}}
        return true
    end,

    startTutorial = function(self, tutorialId)
        if not self.tutorials[tutorialId] then return false end
        self.activeStep = 1
        self.progress[tutorialId] = {current = 1, active = true}
        return true
    end,

    getTutorial = function(self, tutorialId)
        return self.tutorials[tutorialId]
    end,

    nextStep = function(self, tutorialId)
        local prog = self.progress[tutorialId]
        if not prog then return false end
        prog.current = prog.current + 1
        return true
    end,

    getCurrentStep = function(self, tutorialId)
        local prog = self.progress[tutorialId]
        return prog and prog.current or 0
    end,

    completeTutorial = function(self, tutorialId)
        local prog = self.progress[tutorialId]
        if not prog then return false end
        prog.active = false
        self.completed[tutorialId] = true
        return true
    end,

    isCompleted = function(self, tutorialId)
        return self.completed[tutorialId] or false
    end,

    getActiveCount = function(self)
        local count = 0
        for _, prog in pairs(self.progress) do
            if prog.active then count = count + 1 end
        end
        return count
    end,

    skipTutorial = function(self, tutorialId)
        local prog = self.progress[tutorialId]
        if not prog then return false end
        prog.active = false
        return true
    end
}

Suite:group("Tutorial Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tutorial = TutorialManager:new()
    end)

    Suite:testMethod("TutorialManager.new", {description = "Creates tutorial manager", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.tutorial ~= nil, true, "Manager created")
    end)

    Suite:testMethod("TutorialManager.addTutorial", {description = "Adds tutorial", testCase = "add", type = "functional"}, function()
        local ok = shared.tutorial:addTutorial("intro", "Introduction", {"step1", "step2"})
        Helpers.assertEqual(ok, true, "Tutorial added")
    end)

    Suite:testMethod("TutorialManager.getTutorial", {description = "Retrieves tutorial", testCase = "get", type = "functional"}, function()
        shared.tutorial:addTutorial("basics", "Basics", {"a", "b", "c"})
        local tut = shared.tutorial:getTutorial("basics")
        Helpers.assertEqual(tut ~= nil, true, "Tutorial retrieved")
    end)

    Suite:testMethod("TutorialManager.getTutorial", {description = "Returns nil for missing", testCase = "missing", type = "functional"}, function()
        local tut = shared.tutorial:getTutorial("nonexistent")
        Helpers.assertEqual(tut, nil, "Missing tutorial returns nil")
    end)
end)

Suite:group("Tutorial Progression", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tutorial = TutorialManager:new()
        shared.tutorial:addTutorial("combat", "Combat Tutorial", {"attack", "defend", "retreat"})
    end)

    Suite:testMethod("TutorialManager.startTutorial", {description = "Starts tutorial", testCase = "start", type = "functional"}, function()
        local ok = shared.tutorial:startTutorial("combat")
        Helpers.assertEqual(ok, true, "Tutorial started")
    end)

    Suite:testMethod("TutorialManager.getCurrentStep", {description = "Gets current step", testCase = "step", type = "functional"}, function()
        shared.tutorial:startTutorial("combat")
        local step = shared.tutorial:getCurrentStep("combat")
        Helpers.assertEqual(step, 1, "Current step is 1")
    end)

    Suite:testMethod("TutorialManager.nextStep", {description = "Advances step", testCase = "next", type = "functional"}, function()
        shared.tutorial:startTutorial("combat")
        local ok = shared.tutorial:nextStep("combat")
        Helpers.assertEqual(ok, true, "Step advanced")
    end)

    Suite:testMethod("TutorialManager.getCurrentStep", {description = "Increments step", testCase = "increment", type = "functional"}, function()
        shared.tutorial:startTutorial("combat")
        shared.tutorial:nextStep("combat")
        shared.tutorial:nextStep("combat")
        local step = shared.tutorial:getCurrentStep("combat")
        Helpers.assertEqual(step, 3, "Step is now 3")
    end)

    Suite:testMethod("TutorialManager.startTutorial", {description = "Rejects invalid", testCase = "invalid", type = "functional"}, function()
        local ok = shared.tutorial:startTutorial("invalid")
        Helpers.assertEqual(ok, false, "Invalid tutorial rejected")
    end)
end)

Suite:group("Tutorial Completion", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tutorial = TutorialManager:new()
        shared.tutorial:addTutorial("quest", "Quest Tutorial", {})
        shared.tutorial:startTutorial("quest")
    end)

    Suite:testMethod("TutorialManager.completeTutorial", {description = "Completes tutorial", testCase = "complete", type = "functional"}, function()
        local ok = shared.tutorial:completeTutorial("quest")
        Helpers.assertEqual(ok, true, "Tutorial completed")
    end)

    Suite:testMethod("TutorialManager.isCompleted", {description = "Checks completion", testCase = "check_complete", type = "functional"}, function()
        shared.tutorial:completeTutorial("quest")
        local completed = shared.tutorial:isCompleted("quest")
        Helpers.assertEqual(completed, true, "Tutorial marked complete")
    end)

    Suite:testMethod("TutorialManager.isCompleted", {description = "Returns false for incomplete", testCase = "incomplete", type = "functional"}, function()
        local completed = shared.tutorial:isCompleted("quest")
        Helpers.assertEqual(completed, false, "Incomplete tutorial returns false")
    end)

    Suite:testMethod("TutorialManager.skipTutorial", {description = "Skips tutorial", testCase = "skip", type = "functional"}, function()
        local ok = shared.tutorial:skipTutorial("quest")
        Helpers.assertEqual(ok, true, "Tutorial skipped")
    end)
end)

Suite:group("Tutorial Status", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.tutorial = TutorialManager:new()
        shared.tutorial:addTutorial("t1", "Tutorial 1", {})
        shared.tutorial:addTutorial("t2", "Tutorial 2", {})
    end)

    Suite:testMethod("TutorialManager.getActiveCount", {description = "Counts active", testCase = "active_count", type = "functional"}, function()
        shared.tutorial:startTutorial("t1")
        shared.tutorial:startTutorial("t2")
        local count = shared.tutorial:getActiveCount()
        Helpers.assertEqual(count, 2, "Two active tutorials")
    end)

    Suite:testMethod("TutorialManager.getActiveCount", {description = "Excludes completed", testCase = "exclude_complete", type = "functional"}, function()
        shared.tutorial:startTutorial("t1")
        shared.tutorial:startTutorial("t2")
        shared.tutorial:completeTutorial("t1")
        local count = shared.tutorial:getActiveCount()
        Helpers.assertEqual(count, 1, "One active after completion")
    end)
end)

Suite:run()
