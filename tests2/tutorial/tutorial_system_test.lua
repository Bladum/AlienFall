---================================================================================
---PHASE 3K: Tutorial System Tests
---================================================================================
---
---Comprehensive test suite for tutorial system including:
---
---  1. Tutorial Manager Core (4 tests)
---     - Manager initialization and singleton pattern
---     - Tutorial availability and definitions
---     - Starting and stopping tutorials
---
---  2. Tutorial Progression (4 tests)
---     - Step advancement through tutorials
---     - Completion tracking
---     - Step metadata and objectives
---
---  3. Hint System (3 tests)
---     - Hint retrieval and display
---     - Hint state management
---     - Contextual hints
---
---  4. State Persistence (2 tests)
---     - Tutorial progress saving
---     - State restoration
---
---  5. Integration Tests (1 test)
---     - Complete tutorial lifecycle
---
---@module tests2.tutorial.tutorial_system_test

package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")

---@class MockTutorialStep
---Individual tutorial step with instructions and validation.
---@field id string Unique step identifier
---@field title string Step title
---@field description string Instructions for player
---@field objective string Goal to complete step
---@field hint string Helper text
local MockTutorialStep = {}

function MockTutorialStep:new(id, title, description, objective)
    local instance = {
        id = id,
        title = title,
        description = description,
        objective = objective,
        hint = "Try " .. title,
        completed = false
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockTutorialStep:complete()
    self.completed = true
end

function MockTutorialStep:isCompleted()
    return self.completed
end

---@class MockTutorial
---Complete tutorial with multiple steps and metadata.
---@field id string Tutorial identifier
---@field name string Display name
---@field description string Tutorial description
---@field steps table[] Array of tutorial steps
---@field completed boolean Whether tutorial is done
local MockTutorial = {}

function MockTutorial:new(id, name, description)
    local instance = {
        id = id,
        name = name,
        description = description,
        steps = {},
        completed = false
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockTutorial:addStep(step)
    table.insert(self.steps, step)
end

function MockTutorial:getStepCount()
    return #self.steps
end

function MockTutorial:getSteps()
    return self.steps
end

function MockTutorial:complete()
    self.completed = true
end

function MockTutorial:isCompleted()
    return self.completed
end

---@class MockTutorialManager
---Manages tutorial state, progression, and interactions.
---@field tutorials table Map of tutorial ID to tutorial
---@field activeTutorial table|nil Currently active tutorial
---@field currentStepIndex number Current step in active tutorial
---@field completedTutorials table Set of completed tutorial IDs
---@field hintShown table Map of step ID to hint shown status
local MockTutorialManager = {}

function MockTutorialManager:new()
    local instance = {
        tutorials = {},
        activeTutorial = nil,
        currentStepIndex = 0,
        completedTutorials = {},
        hintShown = {}
    }
    setmetatable(instance, {__index = self})

    -- Register default tutorials
    instance:registerDefaultTutorials()

    return instance
end

function MockTutorialManager:registerDefaultTutorials()
    -- Basic Movement Tutorial
    local basicMove = MockTutorial:new("basic_movement", "Basic Movement", "Learn unit movement")
    basicMove:addStep(MockTutorialStep:new("move_1", "Select a Unit", "Click on a unit to select it"))
    basicMove:addStep(MockTutorialStep:new("move_2", "Move the Unit", "Click destination to move"))
    basicMove:addStep(MockTutorialStep:new("move_3", "End Turn", "Click End Turn button"))
    self.tutorials["basic_movement"] = basicMove

    -- Combat Basics Tutorial
    local combat = MockTutorial:new("combat_basics", "Combat Basics", "Learn combat mechanics")
    combat:addStep(MockTutorialStep:new("combat_1", "Target Enemy", "Select an enemy to attack"))
    combat:addStep(MockTutorialStep:new("combat_2", "Fire Weapon", "Choose a weapon and fire"))
    combat:addStep(MockTutorialStep:new("combat_3", "Check Results", "Review combat results"))
    self.tutorials["combat_basics"] = combat

    -- Geoscape Basics Tutorial
    local geoscape = MockTutorial:new("geoscape_basics", "Geoscape Basics", "Learn world management")
    geoscape:addStep(MockTutorialStep:new("geo_1", "View World Map", "Examine the global map"))
    geoscape:addStep(MockTutorialStep:new("geo_2", "Launch Interceptor", "Send a craft to intercept UFO"))
    geoscape:addStep(MockTutorialStep:new("geo_3", "Manage Base", "Build facilities in your base"))
    self.tutorials["geoscape_basics"] = geoscape
end

function MockTutorialManager:registerTutorial(tutorial)
    self.tutorials[tutorial.id] = tutorial
    return true
end

function MockTutorialManager:startTutorial(tutorialId)
    if self.activeTutorial then
        return false  -- Already have active tutorial
    end

    if not self.tutorials[tutorialId] then
        return false  -- Tutorial not found
    end

    self.activeTutorial = self.tutorials[tutorialId]
    self.currentStepIndex = 1
    self.hintShown[tutorialId] = false

    return true
end

function MockTutorialManager:stopTutorial()
    if not self.activeTutorial then
        return false
    end

    self.activeTutorial = nil
    self.currentStepIndex = 0
    return true
end

function MockTutorialManager:getActiveTutorial()
    return self.activeTutorial
end

function MockTutorialManager:getCurrentStep()
    if not self.activeTutorial or self.currentStepIndex < 1 then
        return nil
    end

    return self.activeTutorial.steps[self.currentStepIndex]
end

function MockTutorialManager:nextStep()
    if not self.activeTutorial then
        return false
    end

    self.currentStepIndex = self.currentStepIndex + 1

    if self.currentStepIndex > #self.activeTutorial.steps then
        -- Tutorial complete
        self.activeTutorial:complete()
        self.completedTutorials[self.activeTutorial.id] = true
        self:stopTutorial()
        return false
    end

    return true
end

function MockTutorialManager:previousStep()
    if not self.activeTutorial or self.currentStepIndex <= 1 then
        return false
    end

    self.currentStepIndex = self.currentStepIndex - 1
    return true
end

function MockTutorialManager:showHint()
    if not self.activeTutorial then
        return nil
    end

    local step = self:getCurrentStep()
    if not step then
        return nil
    end

    self.hintShown[self.activeTutorial.id] = true
    return step.hint
end

function MockTutorialManager:wasHintShown()
    if not self.activeTutorial then
        return false
    end

    return self.hintShown[self.activeTutorial.id] or false
end

function MockTutorialManager:isTutorialCompleted(tutorialId)
    return self.completedTutorials[tutorialId] or false
end

function MockTutorialManager:getAvailableTutorials()
    local result = {}
    for id in pairs(self.tutorials) do
        table.insert(result, id)
    end
    return result
end

function MockTutorialManager:getTutorialDefinition(tutorialId)
    return self.tutorials[tutorialId]
end

function MockTutorialManager:getCompletionProgress()
    local completed = 0
    for _ in pairs(self.completedTutorials) do
        completed = completed + 1
    end

    local total = 0
    for _ in pairs(self.tutorials) do
        total = total + 1
    end

    return completed, total
end

function MockTutorialManager:serializeState()
    return {
        completedTutorials = self.completedTutorials,
        hintShown = self.hintShown
    }
end

function MockTutorialManager:deserializeState(state)
    if state.completedTutorials then
        self.completedTutorials = state.completedTutorials
    end
    if state.hintShown then
        self.hintShown = state.hintShown
    end
end

---================================================================================
---TEST SUITE
---================================================================================

local Suite = HierarchicalSuite:new({
    module = "engine.tutorial.system",
    file = "tutorial_system_test.lua",
    description = "Tutorial system - Progression, hints, state management"
})

---TUTORIAL MANAGER CORE TESTS
Suite:group("Tutorial Manager Core", function()

    Suite:testMethod("MockTutorialManager:new", {
        description = "Initializes tutorial manager",
        testCase = "initialization",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()

        if not manager then error("Manager should initialize") end
        if not manager.tutorials then error("Tutorials table missing") end
        if #manager:getAvailableTutorials() < 3 then error("Should have 3+ default tutorials") end
    end)

    Suite:testMethod("MockTutorialManager:getAvailableTutorials", {
        description = "Lists all available tutorials",
        testCase = "tutorial_listing",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()

        local tutorials = manager:getAvailableTutorials()
        if #tutorials < 3 then error("Should have 3+ tutorials") end

        local hasBasicMove = false
        for _, id in ipairs(tutorials) do
            if id == "basic_movement" then
                hasBasicMove = true
            end
        end

        if not hasBasicMove then error("Should have basic_movement tutorial") end
    end)

    Suite:testMethod("MockTutorialManager:getTutorialDefinition", {
        description = "Retrieves tutorial metadata",
        testCase = "tutorial_metadata",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()

        local tutorial = manager:getTutorialDefinition("basic_movement")
        if not tutorial then error("Tutorial should be found") end
        if tutorial.name ~= "Basic Movement" then error("Name should match") end
        if tutorial:getStepCount() < 3 then error("Should have 3+ steps") end
    end)

    Suite:testMethod("MockTutorialManager:startTutorial", {
        description = "Starts tutorial progression",
        testCase = "tutorial_start",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()

        local success = manager:startTutorial("basic_movement")
        if not success then error("Should start tutorial") end

        if not manager:getActiveTutorial() then error("Tutorial should be active") end

        -- Try starting another (should fail)
        local success2 = manager:startTutorial("combat_basics")
        if success2 then error("Should not allow multiple active tutorials") end
    end)
end)

---TUTORIAL PROGRESSION TESTS
Suite:group("Tutorial Progression", function()

    Suite:testMethod("MockTutorialManager:getCurrentStep", {
        description = "Gets current step information",
        testCase = "current_step",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()
        manager:startTutorial("basic_movement")

        local step = manager:getCurrentStep()
        if not step then error("Should have current step") end
        if step.title ~= "Select a Unit" then error("First step should be selection") end
    end)

    Suite:testMethod("MockTutorialManager:nextStep", {
        description = "Advances to next tutorial step",
        testCase = "step_advancement",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()
        manager:startTutorial("basic_movement")

        local step1 = manager:getCurrentStep()
        if step1.title ~= "Select a Unit" then error("First step incorrect") end

        local hasNext = manager:nextStep()
        if not hasNext then error("Should have next step") end

        local step2 = manager:getCurrentStep()
        if step2.title ~= "Move the Unit" then error("Second step incorrect") end
    end)

    Suite:testMethod("MockTutorialManager:previousStep", {
        description = "Goes back to previous step",
        testCase = "step_backtrack",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()
        manager:startTutorial("basic_movement")

        manager:nextStep()
        local step2 = manager:getCurrentStep()
        if step2.title ~= "Move the Unit" then error("Should be on step 2") end

        local hasPrev = manager:previousStep()
        if not hasPrev then error("Should have previous step") end

        local step1 = manager:getCurrentStep()
        if step1.title ~= "Select a Unit" then error("Should be back on step 1") end
    end)

    Suite:testMethod("MockTutorialManager:isTutorialCompleted", {
        description = "Tracks tutorial completion",
        testCase = "completion_tracking",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()
        manager:startTutorial("basic_movement")

        if manager:isTutorialCompleted("basic_movement") then error("Should not be complete yet") end

        -- Complete all steps
        manager:nextStep()
        manager:nextStep()

        if manager:isTutorialCompleted("basic_movement") then error("Should not be complete yet (need to finish)") end

        manager:nextStep()  -- This should complete it

        if not manager:isTutorialCompleted("basic_movement") then error("Should be marked complete") end
    end)
end)

---HINT SYSTEM TESTS
Suite:group("Hint System", function()

    Suite:testMethod("MockTutorialManager:showHint", {
        description = "Provides contextual hint",
        testCase = "hint_display",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()
        manager:startTutorial("basic_movement")

        local hint = manager:showHint()
        if not hint then error("Should return hint") end
        if type(hint) ~= "string" then error("Hint should be string") end
    end)

    Suite:testMethod("MockTutorialManager:wasHintShown", {
        description = "Tracks hint display state",
        testCase = "hint_tracking",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()
        manager:startTutorial("basic_movement")

        if manager:wasHintShown() then error("Hint should not be shown initially") end

        manager:showHint()

        if not manager:wasHintShown() then error("Hint should be marked as shown") end
    end)

    Suite:testMethod("Tutorial Step Hints", {
        description = "Provides hints for each step",
        testCase = "step_hints",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()
        manager:startTutorial("combat_basics")

        local step1 = manager:getCurrentStep()
        if not step1.hint then error("Step should have hint") end

        manager:nextStep()
        local step2 = manager:getCurrentStep()
        if not step2.hint then error("All steps should have hints") end
    end)
end)

---STATE PERSISTENCE TESTS
Suite:group("State Persistence", function()

    Suite:testMethod("MockTutorialManager:serializeState", {
        description = "Serializes tutorial progress",
        testCase = "state_saving",
        type = "functional"
    }, function()
        local manager = MockTutorialManager:new()
        manager:startTutorial("basic_movement")
        manager:nextStep()
        manager:nextStep()
        manager:nextStep()  -- Complete it

        local state = manager:serializeState()

        if not state then error("Should serialize state") end
        if not state.completedTutorials then error("Should save completed tutorials") end
        if not state.completedTutorials["basic_movement"] then error("Basic movement should be completed") end
    end)

    Suite:testMethod("MockTutorialManager:deserializeState", {
        description = "Restores tutorial progress",
        testCase = "state_restoration",
        type = "functional"
    }, function()
        local manager1 = MockTutorialManager:new()
        manager1:startTutorial("basic_movement")
        manager1:nextStep()
        manager1:nextStep()
        manager1:nextStep()

        local state = manager1:serializeState()

        -- Create new manager and restore
        local manager2 = MockTutorialManager:new()
        manager2:deserializeState(state)

        if not manager2:isTutorialCompleted("basic_movement") then error("Should restore completion state") end
    end)
end)

---INTEGRATION TESTS
Suite:group("Integration", function()

    Suite:testMethod("Complete Tutorial Lifecycle", {
        description = "Simulates full tutorial progression",
        testCase = "full_lifecycle",
        type = "integration"
    }, function()
        local manager = MockTutorialManager:new()

        -- Get available tutorials
        local tutorials = manager:getAvailableTutorials()
        if #tutorials < 3 then error("Should have tutorials") end

        -- Start first tutorial
        local started = manager:startTutorial("basic_movement")
        if not started then error("Should start tutorial") end

        -- Progress through all steps
        local stepCount = 0
        while manager:getActiveTutorial() do
            local step = manager:getCurrentStep()
            if step then
                stepCount = stepCount + 1

                -- Show hint on first step
                if stepCount == 1 then
                    local hint = manager:showHint()
                    if not hint then error("Should provide hint") end
                end
            end

            if not manager:nextStep() then
                break
            end
        end

        -- Verify completion
        if not manager:isTutorialCompleted("basic_movement") then error("Tutorial should be complete") end
        if manager:getActiveTutorial() then error("Tutorial should be inactive") end

        -- Verify we progressed through steps
        if stepCount < 3 then error("Should progress through all steps") end
    end)
end)

---PERFORMANCE BENCHMARKS
Suite:group("Performance", function()

    Suite:testMethod("Scaling - Multiple Tutorials", {
        description = "Manages many tutorials efficiently",
        testCase = "tutorial_scaling",
        type = "performance"
    }, function()
        local manager = MockTutorialManager:new()
        local startTime = os.clock()

        -- Register many tutorials
        for i = 1, 20 do
            local tutorial = MockTutorial:new("tutorial_" .. i, "Tutorial " .. i, "Description " .. i)
            for j = 1, 5 do
                tutorial:addStep(MockTutorialStep:new("step_" .. j, "Step " .. j, "Description"))
            end
            manager:registerTutorial(tutorial)
        end

        -- Start and complete tutorials
        for i = 1, 10 do
            manager:startTutorial("tutorial_" .. i)
            while manager:getActiveTutorial() do
                if not manager:nextStep() then break end
            end
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 20 tutorials + 10 completions: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)

    Suite:testMethod("Scaling - Step Progression", {
        description = "Progresses through steps efficiently",
        testCase = "progression_scaling",
        type = "performance"
    }, function()
        local manager = MockTutorialManager:new()
        local startTime = os.clock()

        -- Create tutorial with many steps
        local tutorial = MockTutorial:new("long_tutorial", "Long Tutorial", "Many steps")
        for i = 1, 100 do
            tutorial:addStep(MockTutorialStep:new("s_" .. i, "Step " .. i, "Description"))
        end

        manager:registerTutorial(tutorial)
        manager:startTutorial("long_tutorial")

        -- Progress through all steps
        for _ = 1, 100 do
            if not manager:nextStep() then break end
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 100-step tutorial progression: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)
end)

---================================================================================
---RUN TESTS
---================================================================================

Suite:run()

-- Close the Love2D window after tests complete
love.event.quit()
