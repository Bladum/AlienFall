---Test Suite for Tutorial System
---
---Tests tutorial progression, hints, completion tracking, and state management.
---
---Test Coverage:
---  - Tutorial initialization and management (3 tests)
---  - Tutorial progression and steps (4 tests)
---  - Hint system (2 tests)
---  - Completion tracking (2 tests)
---
---Dependencies:
---  - tutorial.tutorial_manager
---
---@module tests.unit.test_tutorial_system
---@author AlienFall Development Team
---@date 2025-10-15

-- Setup package path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local TutorialManager = require("tutorial.tutorial_manager")

local TestTutorialSystem = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper: Run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper: Assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

-- Helper: Assert not nil
local function assertNotNil(value, message)
    assert(value ~= nil, message or "Expected value to not be nil")
end

-- Helper: Assert equals
local function assertEquals(actual, expected, message)
    if actual ~= expected then
        error(message or string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
    end
end

---Test TutorialManager initialization
function TestTutorialSystem.testTutorialManagerInitialization()
    print("[TEST] TutorialManager initialization...")

    -- Test initialization
    local manager = TutorialManager.initialize()
    assertNotNil(manager, "TutorialManager should initialize successfully")

    -- Test singleton pattern
    local manager2 = TutorialManager.initialize()
    assert(manager == manager2, "TutorialManager should return same instance (singleton)")

    -- Test getInstance
    local instance = TutorialManager.getInstance()
    assertNotNil(instance, "getInstance should return valid instance")

    print("✓ TutorialManager initialized successfully")
end

---Test tutorial availability
function TestTutorialSystem.testTutorialAvailability()
    print("[TEST] Tutorial availability...")

    -- Get available tutorials
    local tutorials = TutorialManager.getAvailableTutorials()
    assertNotNil(tutorials, "Should return tutorial list")
    assert(type(tutorials) == "table", "Tutorials should be a table")
    assert(#tutorials > 0, "Should have at least one tutorial")

    -- Test tutorial definitions
    for _, tutorialId in ipairs(tutorials) do
        local definition = TutorialManager.getTutorialDefinition(tutorialId)
        assertNotNil(definition, "Tutorial definition should exist for " .. tutorialId)
        if definition then
            assertEquals(definition.id, tutorialId, "Definition ID should match")
            assert(definition.steps, "Tutorial should have steps")
            if definition.steps then
                assert(#definition.steps > 0, "Tutorial should have at least one step")
            end
        end
    end

    print("✓ Tutorial availability working correctly")
end

---Test starting tutorials
function TestTutorialSystem.testStartingTutorials()
    print("[TEST] Starting tutorials...")

    -- Start a valid tutorial
    local success = TutorialManager.startTutorial("basic_movement")
    assert(success, "Should successfully start basic_movement tutorial")

    -- Check current tutorial
    local currentStep = TutorialManager.getCurrentStep()
    assertNotNil(currentStep, "Should have current step after starting tutorial")
    if currentStep then
        assertNotNil(currentStep.title, "Step should have title")
        assertEquals(currentStep.title, "Select a Unit", "Should start with first step")
    end

    -- Try to start already active tutorial (should fail)
    local success2 = TutorialManager.startTutorial("combat_basics")
    assert(not success2, "Should not start tutorial when one is already active")

    print("✓ Tutorial starting working correctly")
end

---Test tutorial progression
function TestTutorialSystem.testTutorialProgression()
    print("[TEST] Tutorial progression...")

    -- Start tutorial
    TutorialManager.startTutorial("basic_movement")

    -- Check initial step
    local step1 = TutorialManager.getCurrentStep()
    assertNotNil(step1, "Should have step 1")
    if step1 then
        assertNotNil(step1.title, "Step 1 should have title")
        assertEquals(step1.title, "Select a Unit", "Should be first step")
    end

    -- Advance to next step
    local hasNext = TutorialManager.nextStep()
    assert(hasNext, "Should have next step")

    local step2 = TutorialManager.getCurrentStep()
    assertNotNil(step2, "Should have step 2")
    if step2 then
        assertNotNil(step2.title, "Step 2 should have title")
        assertEquals(step2.title, "Move the Unit", "Should be second step")
    end

    -- Advance to final step
    local hasNext2 = TutorialManager.nextStep()
    assert(hasNext2, "Should have next step")

    local step3 = TutorialManager.getCurrentStep()
    assertNotNil(step3, "Should have step 3")
    if step3 then
        assertNotNil(step3.title, "Step 3 should have title")
        assertEquals(step3.title, "End Turn", "Should be final step")
    end

    -- Advance past final step (should complete tutorial)
    local hasNext3 = TutorialManager.nextStep()
    assert(not hasNext3, "Should not have next step after completion")

    -- Check tutorial is completed
    local isCompleted = TutorialManager.isTutorialCompleted("basic_movement")
    assert(isCompleted, "Tutorial should be marked as completed")

    print("✓ Tutorial progression working correctly")
end

---Test hint system
function TestTutorialSystem.testHintSystem()
    print("[TEST] Hint system...")

    -- Start tutorial
    TutorialManager.startTutorial("combat_basics")

    -- Check hint not shown initially
    local hintShown = TutorialManager.wasHintShown()
    assert(not hintShown, "Hint should not be shown initially")

    -- Show hint
    local hint = TutorialManager.showHint()
    assertNotNil(hint, "Should return hint text")
    assert(type(hint) == "string", "Hint should be a string")

    -- Check hint is now shown
    local hintShown2 = TutorialManager.wasHintShown()
    assert(hintShown2, "Hint should be marked as shown")

    -- Show hint again (should still work)
    local hint2 = TutorialManager.showHint()
    assertEquals(hint, hint2, "Should return same hint text")

    print("✓ Hint system working correctly")
end

---Test tutorial completion tracking
function TestTutorialSystem.testCompletionTracking()
    print("[TEST] Completion tracking...")

    -- Start and complete a tutorial
    TutorialManager.startTutorial("combat_basics")
    TutorialManager.nextStep() -- Step 1 -> 2
    TutorialManager.nextStep() -- Step 2 -> complete

    -- Check completion
    local isCompleted = TutorialManager.isTutorialCompleted("combat_basics")
    assert(isCompleted, "Tutorial should be completed")

    -- Check progress stats
    local stats = TutorialManager.getProgressStats()
    assertNotNil(stats, "Should return progress stats")
    assert(stats.total > 0, "Should have total tutorials")
    assert(stats.completed >= 1, "Should have at least one completed")

    -- Try to restart completed tutorial (should fail)
    local success = TutorialManager.startTutorial("combat_basics")
    assert(not success, "Should not restart completed tutorial")

    print("✓ Completion tracking working correctly")
end

---Test tutorial state management
function TestTutorialSystem.testTutorialStateManagement()
    print("[TEST] Tutorial state management...")

    -- Start tutorial
    TutorialManager.startTutorial("basic_movement")

    -- Check no current tutorial after completion
    TutorialManager.completeTutorial()
    local currentStep = TutorialManager.getCurrentStep()
    assert(currentStep == nil, "Should have no current step after completion")

    -- Check hint state resets
    local hintShown = TutorialManager.wasHintShown()
    assert(not hintShown, "Hint state should reset after completion")

    print("✓ Tutorial state management working correctly")
end

---Run all tutorial tests
function TestTutorialSystem.runAll()
    print("=== Tutorial System Test Suite ===")
    print("Testing tutorial progression, hints, and completion tracking...")
    print()

    -- Run all tests
    runTest("TutorialManager Initialization", TestTutorialSystem.testTutorialManagerInitialization)
    runTest("Tutorial Availability", TestTutorialSystem.testTutorialAvailability)
    runTest("Starting Tutorials", TestTutorialSystem.testStartingTutorials)
    runTest("Tutorial Progression", TestTutorialSystem.testTutorialProgression)
    runTest("Hint System", TestTutorialSystem.testHintSystem)
    runTest("Completion Tracking", TestTutorialSystem.testCompletionTracking)
    runTest("Tutorial State Management", TestTutorialSystem.testTutorialStateManagement)

    print()
    print(string.format("=== Results: %d passed, %d failed ===", testsPassed, testsFailed))

    if testsFailed > 0 then
        print("Failed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  - %s: %s", failure.name, failure.error))
        end
        return false
    end

    return true
end

-- Export for external usage
return TestTutorialSystem


