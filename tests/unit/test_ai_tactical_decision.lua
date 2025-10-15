---Test Suite for AI Tactical Decision System
---
---Tests AI decision-making logic, behavior modes, target selection, and action
---evaluation for enemy units in tactical combat.
---
---Test Coverage:
---  - AI initialization and state management (4 tests)
---  - Behavior mode switching and configuration (4 tests)
---  - Target selection and prioritization (4 tests)
---  - Action evaluation and scoring (4 tests)
---  - Threat assessment and decision making (3 tests)
---
---Dependencies:
---  - ai.tactical.decision_system
---  - mock.units (for AI unit data)
---  - mock.battlescape (for battlefield state)
---
---@module tests.unit.test_ai_tactical_decision
---@author AlienFall Development Team
---@date 2025-10-15

-- Setup package path
package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local AIDecisionSystem = require("ai.tactical.decision_system")
local MockUnits = require("mock.units")
local MockBattlescape = require("mock.battlescape")

local TestAITacticalDecision = {}
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

-- Helper: Assert table has key
local function assertHasKey(table, key, message)
    assert(table[key] ~= nil, message or string.format("Expected table to have key '%s'", key))
end

---Test AI system initialization
function TestAITacticalDecision.testAIInitialization()
    print("[TEST] AI system initialization...")

    -- Test that AI system is available
    assertNotNil(AIDecisionSystem, "AIDecisionSystem should be available")

    -- Test initialization functions exist
    assert(type(AIDecisionSystem.initializeUnit) == "function", "initializeUnit should be a function")
    assert(type(AIDecisionSystem.removeUnit) == "function", "removeUnit should be a function")
    assert(type(AIDecisionSystem.setBehavior) == "function", "setBehavior should be a function")
    assert(type(AIDecisionSystem.getBehavior) == "function", "getBehavior should be a function")

    print("✓ AI system initialization working correctly")
end

---Test AI unit initialization and state management
function TestAITacticalDecision.testAIUnitInitialization()
    print("[TEST] AI unit initialization...")

    -- Initialize a unit
    local unitId = "test_unit_001"
    AIDecisionSystem.initializeUnit(unitId)

    -- Check behavior is set
    local behavior = AIDecisionSystem.getBehavior(unitId)
    assertNotNil(behavior, "Unit should have a behavior")
    assertEquals(behavior, "AGGRESSIVE", "Default behavior should be AGGRESSIVE")

    -- Change behavior
    AIDecisionSystem.setBehavior(unitId, "DEFENSIVE")
    local newBehavior = AIDecisionSystem.getBehavior(unitId)
    assertEquals(newBehavior, "DEFENSIVE", "Behavior should change to DEFENSIVE")

    -- Remove unit
    AIDecisionSystem.removeUnit(unitId)
    local removedBehavior = AIDecisionSystem.getBehavior(unitId)
    assertEquals(removedBehavior, "AGGRESSIVE", "Removed unit should reset to default behavior")

    print("✓ AI unit initialization working correctly")
end

---Test behavior mode configuration
function TestAITacticalDecision.testBehaviorConfiguration()
    print("[TEST] Behavior configuration...")

    -- Test that behavior configurations exist
    local unitId = "test_unit_002"
    AIDecisionSystem.initializeUnit(unitId, "DEFENSIVE")

    local behavior = AIDecisionSystem.getBehavior(unitId)
    assertEquals(behavior, "DEFENSIVE", "Unit should be initialized with DEFENSIVE behavior")

    -- Test all behavior modes
    local behaviors = {"AGGRESSIVE", "DEFENSIVE", "SUPPORT", "FLANKING", "SUPPRESSIVE", "RETREAT"}
    for _, behaviorMode in ipairs(behaviors) do
        AIDecisionSystem.setBehavior(unitId, behaviorMode)
        local currentBehavior = AIDecisionSystem.getBehavior(unitId)
        assertEquals(currentBehavior, behaviorMode, "Behavior should be set to " .. behaviorMode)
    end

    print("✓ Behavior configuration working correctly")
end

---Test behavior switching logic
function TestAITacticalDecision.testBehaviorSwitching()
    print("[TEST] Behavior switching...")

    local unitId = "test_unit_003"
    AIDecisionSystem.initializeUnit(unitId, "AGGRESSIVE")

    -- Test behavior switch function exists
    assert(type(AIDecisionSystem.checkBehaviorSwitch) == "function", "checkBehaviorSwitch should be a function")

    -- Test low HP triggers retreat
    local unitData = {hp = 10, maxHP = 100} -- 10% HP
    local newBehavior = AIDecisionSystem.checkBehaviorSwitch(unitId, unitData)
    assertEquals(newBehavior, "RETREAT", "Low HP should trigger RETREAT behavior")

    -- Test recovery from retreat
    unitData = {hp = 80, maxHP = 100} -- 80% HP
    AIDecisionSystem.setBehavior(unitId, "RETREAT") -- Set to retreat first
    newBehavior = AIDecisionSystem.checkBehaviorSwitch(unitId, unitData)
    assertEquals(newBehavior, "DEFENSIVE", "High HP should switch from RETREAT to DEFENSIVE")

    print("✓ Behavior switching working correctly")
end

---Test threat evaluation
function TestAITacticalDecision.testThreatEvaluation()
    print("[TEST] Threat evaluation...")

    -- Test threat evaluation function exists
    assert(type(AIDecisionSystem.evaluateThreat) == "function", "evaluateThreat should be a function")

    -- Test threat calculation with different enemy types
    local closeEnemy = {hp = 50, maxHP = 100, damage = 20, distance = 5, morale = 50}
    local farEnemy = {hp = 50, maxHP = 100, damage = 20, distance = 15, morale = 50}
    local weakEnemy = {hp = 10, maxHP = 100, damage = 20, distance = 5, morale = 50}

    local closeThreat = AIDecisionSystem.evaluateThreat(closeEnemy)
    local farThreat = AIDecisionSystem.evaluateThreat(farEnemy)
    local weakThreat = AIDecisionSystem.evaluateThreat(weakEnemy)

    -- Closer enemies should be more threatening
    assert(closeThreat > farThreat, "Closer enemy should be more threatening")

    -- All threats should be numbers
    assert(type(closeThreat) == "number", "Threat should be a number")
    assert(type(farThreat) == "number", "Threat should be a number")
    assert(type(weakThreat) == "number", "Threat should be a number")

    print("✓ Threat evaluation working correctly")
end

---Test target selection
function TestAITacticalDecision.testTargetSelection()
    print("[TEST] Target selection...")

    -- Test target selection function exists
    assert(type(AIDecisionSystem.selectTarget) == "function", "selectTarget should be a function")

    local unitId = "test_unit_004"
    AIDecisionSystem.initializeUnit(unitId, "AGGRESSIVE")

    -- Create mock enemies
    local enemies = {
        {id = "enemy1", distance = 5, hp = 50, maxHP = 100},
        {id = "enemy2", distance = 10, hp = 50, maxHP = 100},
        {id = "enemy3", distance = 3, hp = 50, maxHP = 100}
    }

    -- Test CLOSEST priority (using AGGRESSIVE behavior which has CLOSEST priority)
    local target = AIDecisionSystem.selectTarget(unitId, enemies, "AGGRESSIVE")
    assertNotNil(target, "Should select a target")
    if target then
        assertEquals(target.id, "enemy3", "Should select closest enemy (distance 3)")
    end

    -- Test target is in enemies list
    local found = false
    if target then
        for _, enemy in ipairs(enemies) do
            if enemy.id == target.id then
                found = true
                break
            end
        end
    end
    assert(found, "Selected target should be in enemies list")

    print("✓ Target selection working correctly")
end

---Test action evaluation
function TestAITacticalDecision.testActionEvaluation()
    print("[TEST] Action evaluation...")

    -- Test action evaluation function exists
    assert(type(AIDecisionSystem.evaluateOptions) == "function", "evaluateOptions should be a function")

    local unitId = "test_unit_005"
    AIDecisionSystem.initializeUnit(unitId, "AGGRESSIVE")

    -- Mock unit data
    local unitData = {
        hp = 80, maxHP = 100, ap = 10,
        position = {x = 5, y = 5}
    }

    -- Mock enemies and allies
    local visibleEnemies = {
        {id = "enemy1", distance = 5, hp = 50, maxHP = 100}
    }
    local visibleAllies = {
        {id = "ally1", distance = 3, hp = 60, maxHP = 100}
    }

    -- Evaluate options
    local actions = AIDecisionSystem.evaluateOptions(unitId, unitData, visibleEnemies, visibleAllies)
    assertNotNil(actions, "Should return actions table")
    assert(type(actions) == "table", "Actions should be a table")

    -- Should have at least one action
    assert(#actions > 0, "Should have at least one action")

    -- Check action structure
    local firstAction = actions[1]
    assertHasKey(firstAction, "actionType", "Action should have actionType")
    assertHasKey(firstAction, "score", "Action should have score")

    print("✓ Action evaluation working correctly")
end

---Test best action selection
function TestAITacticalDecision.testBestActionSelection()
    print("[TEST] Best action selection...")

    -- Test best action selection function exists
    assert(type(AIDecisionSystem.selectBestAction) == "function", "selectBestAction should be a function")

    -- Test with actions (sort them first like evaluateOptions does)
    local actions = {
        {actionType = "SHOOT", score = 50, target = "enemy1"},
        {actionType = "MOVE", score = 80, target = nil},
        {actionType = "OVERWATCH", score = 30, target = nil}
    }
    
    -- Sort actions by score descending (highest first)
    table.sort(actions, function(a, b) return a.score > b.score end)
    
    local bestAction = AIDecisionSystem.selectBestAction(actions)
    assertNotNil(bestAction, "Should select best action")
    if bestAction then
        assertEquals(bestAction.actionType, "MOVE", "Should select highest scoring action (MOVE)")
        assertEquals(bestAction.score, 80, "Should select action with highest score")
    end

    -- Test with empty actions
    local emptyActions = {}
    local noAction = AIDecisionSystem.selectBestAction(emptyActions)
    assert(noAction == nil, "Empty actions should return nil")

    print("✓ Best action selection working correctly")
end

---Test retreat behavior at low HP
function TestAITacticalDecision.testRetreatBehavior()
    print("[TEST] Retreat behavior...")

    local unitId = "test_unit_006"
    AIDecisionSystem.initializeUnit(unitId, "AGGRESSIVE")

    -- Mock unit data with low HP
    local unitData = {
        hp = 15, maxHP = 100, ap = 10, -- 15% HP
        position = {x = 5, y = 5}
    }

    local visibleEnemies = {
        {id = "enemy1", distance = 5, hp = 50, maxHP = 100}
    }
    local visibleAllies = {}

    -- Evaluate options - should include retreat
    local actions = AIDecisionSystem.evaluateOptions(unitId, unitData, visibleEnemies, visibleAllies)

    -- Check if retreat action is present
    local hasRetreat = false
    for _, action in ipairs(actions) do
        if action.actionType == "RETREAT" then
            hasRetreat = true
            break
        end
    end

    assert(hasRetreat, "Low HP should trigger retreat action")

    print("✓ Retreat behavior working correctly")
end

---Test AI state management
function TestAITacticalDecision.testAIStateManagement()
    print("[TEST] AI state management...")

    -- Test getAllAIStates function exists
    assert(type(AIDecisionSystem.getAllAIStates) == "function", "getAllAIStates should be a function")

    -- Initialize multiple units
    AIDecisionSystem.initializeUnit("unit1", "AGGRESSIVE")
    AIDecisionSystem.initializeUnit("unit2", "DEFENSIVE")
    AIDecisionSystem.initializeUnit("unit3", "SUPPORT")

    -- Get all states
    local allStates = AIDecisionSystem.getAllAIStates()
    assertNotNil(allStates, "Should return AI states")
    assert(type(allStates) == "table", "AI states should be a table")

    -- Check that our units are in the states
    assertHasKey(allStates, "unit1", "unit1 should be in AI states")
    assertHasKey(allStates, "unit2", "unit2 should be in AI states")
    assertHasKey(allStates, "unit3", "unit3 should be in AI states")

    -- Check behaviors
    assertEquals(allStates.unit1.behavior, "AGGRESSIVE", "unit1 should have AGGRESSIVE behavior")
    assertEquals(allStates.unit2.behavior, "DEFENSIVE", "unit2 should have DEFENSIVE behavior")
    assertEquals(allStates.unit3.behavior, "SUPPORT", "unit3 should have SUPPORT behavior")

    print("✓ AI state management working correctly")
end

---Test decision visualization
function TestAITacticalDecision.testDecisionVisualization()
    print("[TEST] Decision visualization...")

    -- Test visualization function exists
    assert(type(AIDecisionSystem.visualizeDecision) == "function", "visualizeDecision should be a function")

    local unitId = "test_unit_007"
    AIDecisionSystem.initializeUnit(unitId, "AGGRESSIVE")

    -- Mock actions
    local actions = {
        {actionType = "SHOOT", score = 70, target = "enemy1"},
        {actionType = "MOVE", score = 50, target = nil}
    }

    -- Get visualization
    local visualization = AIDecisionSystem.visualizeDecision(unitId, actions)
    assertNotNil(visualization, "Should return visualization data")
    assert(type(visualization) == "table", "Visualization should be a table")

    -- Check visualization structure
    assertEquals(visualization.unitId, unitId, "Visualization should include unit ID")
    assertEquals(visualization.behavior, "AGGRESSIVE", "Visualization should include behavior")
    assertEquals(visualization.actionCount, 2, "Visualization should include action count")
    assertNotNil(visualization.bestAction, "Visualization should include best action")

    print("✓ Decision visualization working correctly")
end

---Run all AI tactical decision tests
function TestAITacticalDecision.runAll()
    print("=== AI Tactical Decision System Test Suite ===")
    print("Testing AI decision-making, behavior modes, and combat logic...")
    print()

    -- Run all tests
    runTest("AI System Initialization", TestAITacticalDecision.testAIInitialization)
    runTest("AI Unit Initialization", TestAITacticalDecision.testAIUnitInitialization)
    runTest("Behavior Configuration", TestAITacticalDecision.testBehaviorConfiguration)
    runTest("Behavior Switching", TestAITacticalDecision.testBehaviorSwitching)
    runTest("Threat Evaluation", TestAITacticalDecision.testThreatEvaluation)
    runTest("Target Selection", TestAITacticalDecision.testTargetSelection)
    runTest("Action Evaluation", TestAITacticalDecision.testActionEvaluation)
    runTest("Best Action Selection", TestAITacticalDecision.testBestActionSelection)
    runTest("Retreat Behavior", TestAITacticalDecision.testRetreatBehavior)
    runTest("AI State Management", TestAITacticalDecision.testAIStateManagement)
    runTest("Decision Visualization", TestAITacticalDecision.testDecisionVisualization)

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
return TestAITacticalDecision