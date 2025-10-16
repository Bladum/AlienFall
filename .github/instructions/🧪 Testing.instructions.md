# 🧪 Testing Best Practices for AlienFall

**Domain**: Quality Assurance & Testing  
**Focus**: Unit tests, integration tests, TDD, Love2D testing  
**Version**: 1.0  
**Last Updated**: October 16, 2025

---

## Table of Contents

1. [Testing Fundamentals](#testing-fundamentals)
2. [Unit Testing Patterns](#unit-testing-patterns)
3. [Integration Testing](#integration-testing)
4. [Mocking & Fixtures](#mocking--fixtures)
5. [TDD Workflow](#tdd-workflow)
6. [Love2D-Specific Testing](#love2d-specific-testing)
7. [Performance Testing](#performance-testing)
8. [Test Coverage & Metrics](#test-coverage--metrics)
9. [Continuous Integration](#continuous-integration)
10. [Test Organization](#test-organization)
11. [Debugging Failed Tests](#debugging-failed-tests)
12. [Best Practices Summary](#best-practices-summary)

---

## Testing Fundamentals

### ✅ DO: Follow AAA Pattern

Arrange → Act → Assert

**AAA Pattern:**

```lua
function test_takeDamage_reducesHealth()
    -- ARRANGE
    local unit = Unit:new("Soldier")
    unit.health = 100
    
    -- ACT
    unit:takeDamage(25)
    
    -- ASSERT
    assert(unit.health == 75, "Health should be 75 after 25 damage")
end
```

### ✅ DO: Test One Thing Per Test

Single responsibility for tests.

**Good Test Design:**

```lua
-- ✓ GOOD: Tests one behavior
function test_takeDamage_reducesHealth()
    local unit = Unit:new("Soldier")
    unit.health = 100
    unit:takeDamage(25)
    assert(unit.health == 75)
end

-- ✓ GOOD: Tests another behavior
function test_takeDamage_cannotReduceBelowZero()
    local unit = Unit:new("Soldier")
    unit.health = 10
    unit:takeDamage(25)
    assert(unit.health == 0)  -- Clamped
end

-- ✗ BAD: Tests multiple behaviors
function test_takeDamage()
    local unit = Unit:new("Soldier")
    unit.health = 100
    unit:takeDamage(25)
    assert(unit.health == 75)
    assert(not unit.isAlive)  -- Also testing alive status
    unit:takeDamage(100)
    assert(unit.health == 0)  -- And health clamping
end
```

### ✅ DO: Use Descriptive Test Names

Test name = Test documentation

**Naming Conventions:**

```lua
-- GOOD: Clear what's being tested
test_unit_takeDamage_reducesHealth()
test_unit_takeDamage_cannotGoBelowZero()
test_unit_takeDamage_triggersDeathEvent()

test_weapon_calculateDamage_appliesArmor()
test_weapon_calculateDamage_appliesCritical()
test_weapon_calculateDamage_withNegativeDamageReturnsZero()

-- BAD: Unclear
test_unit1()
test_damage()
test_thing()

Format: test_[module]_[function]_[specific_behavior]
```

---

## Unit Testing Patterns

### ✅ DO: Create Focused Unit Tests

Test isolated functions without dependencies.

**Unit Test Example:**

```lua
-- Test pure function
local function test_calculateDistance()
    local distance = calculateDistance(0, 0, 3, 4)
    assert(distance == 5, "3-4-5 triangle should have distance 5")
end

local function test_calculateDistance_zero()
    local distance = calculateDistance(5, 5, 5, 5)
    assert(distance == 0, "Same point should have distance 0")
end

-- Math function tested independently
-- No game state, no dependencies
-- Fast, deterministic
```

### ✅ DO: Test Edge Cases

Boundary conditions reveal bugs.

**Edge Case Testing:**

```lua
function test_clampValue_edgeCases()
    -- Below minimum
    assert(clampValue(-10, 0, 100) == 0)
    
    -- At minimum
    assert(clampValue(0, 0, 100) == 0)
    
    -- Between min/max
    assert(clampValue(50, 0, 100) == 50)
    
    -- At maximum
    assert(clampValue(100, 0, 100) == 100)
    
    -- Above maximum
    assert(clampValue(150, 0, 100) == 100)
    
    -- Min = Max (edge case)
    assert(clampValue(50, 10, 10) == 10)
end
```

### ✅ DO: Test Error Cases

What happens when inputs are invalid?

**Error Testing:**

```lua
function test_unit_takeDamage_requiresNumber()
    local unit = Unit:new("Soldier")
    
    -- Should handle gracefully
    local success, error = pcall(function()
        unit:takeDamage("not a number")
    end)
    
    assert(not success, "Should error on non-number input")
    assert(string.find(error, "number"), "Error should mention type")
end

function test_unit_takeDamage_requiresPositive()
    local unit = Unit:new("Soldier")
    
    local success, error = pcall(function()
        unit:takeDamage(-10)
    end)
    
    assert(not success, "Should error on negative damage")
end
```

---

## Integration Testing

### ✅ DO: Test Component Interactions

Integration tests verify systems work together.

**Integration Test:**

```lua
function test_combat_unitDies_triggersEvent()
    -- Setup
    local unit = Unit:new("Soldier")
    unit.health = 10
    
    local eventTriggered = false
    EventBus:subscribe("unitDied", function(deadUnit)
        eventTriggered = true
    end)
    
    -- Act: Unit takes lethal damage
    unit:takeDamage(20)
    
    -- Assert: Event was triggered
    assert(eventTriggered, "Death event should be triggered")
    assert(not unit.isAlive, "Unit should be marked dead")
end
```

### ✅ DO: Test System Workflows

Full workflows reveal integration problems.

**Workflow Testing:**

```lua
function test_mission_fullFlow()
    -- Setup mission
    local mission = Mission:new("TestMission")
    mission:addUnit(Unit:new("Soldier1"))
    mission:addUnit(Unit:new("Soldier2"))
    
    mission:addEnemy(Alien:new("Sectoid"))
    mission:addEnemy(Alien:new("Floater"))
    
    -- Start mission
    mission:start()
    assert(mission.state == "active")
    
    -- First turn
    mission.currentUnit:attack(mission.enemies[1])
    mission:endTurn()
    
    -- Verify state changed
    assert(mission.turn == 2)
    assert(mission.currentUnit ~= nil)
end
```

---

## Mocking & Fixtures

### ✅ DO: Create Mock Objects

Isolate units under test.

**Mock Pattern:**

```lua
-- Real Weapon class
local Weapon = {}
function Weapon:new(name, damage)
    return { name = name, damage = damage }
end

-- Mock weapon for testing (simpler)
local MockWeapon = {
    name = "MockWeapon",
    damage = 10
}

function test_unit_attack_withMock()
    -- Use mock instead of real weapon
    local unit = Unit:new("Soldier")
    local mockWeapon = MockWeapon
    
    unit.weapon = mockWeapon
    local damage = unit:calculateDamage()
    
    assert(damage == mockWeapon.damage)
end
```

### ✅ DO: Create Test Fixtures

Reusable test data.

**Fixture Pattern:**

```lua
-- Fixture: Common test data
local TestFixtures = {}

function TestFixtures.createSoldier()
    local soldier = Unit:new("Soldier")
    soldier.health = 100
    soldier.weapon = { damage = 20 }
    return soldier
end

function TestFixtures.createAlien()
    local alien = Alien:new("Sectoid")
    alien.health = 30
    alien.weapon = { damage = 15 }
    return alien
end

function TestFixtures.createMission()
    local mission = Mission:new("TestMission")
    mission:addUnit(TestFixtures.createSoldier())
    mission:addEnemy(TestFixtures.createAlien())
    return mission
end

-- Usage in tests
function test_combat_scenario()
    local mission = TestFixtures.createMission()
    -- Test mission behavior
end
```

---

## TDD Workflow

### ✅ DO: Follow Red-Green-Refactor

Test-Driven Development cycle.

**TDD Cycle:**

```
1. RED: Write failing test
   function test_unit_hasName()
       local unit = Unit:new("Soldier")
       assert(unit.name == "Soldier")
   end
   → Fails (Unit class doesn't exist)

2. GREEN: Write minimal code to pass
   local Unit = {}
   function Unit:new(name)
       return { name = name }
   end
   → Test passes

3. REFACTOR: Improve code
   local Unit = {}
   function Unit:new(name)
       assert(name, "Unit must have a name")
       return setmetatable(
           { name = name, health = 100 },
           { __index = Unit }
       )
   end
   → Tests still pass, code better
```

### ✅ DO: Write Tests Before Code

Specifications drive implementation.

**TDD Benefits:**

```
Before implementation:
✓ Understand requirements (write test → realize what's needed)
✓ Design API (test shows how users will call it)
✓ Catch edge cases early (tests define behavior)
✓ Documentation (tests are usage examples)

Code Quality:
✓ Testable code (designed for testing)
✓ Fewer bugs (tested before release)
✓ Refactoring safe (tests catch regressions)
✓ Maintenance easier (tests explain intent)
```

---

## Love2D-Specific Testing

### ✅ DO: Test Love2D Callbacks

Verify game callbacks work.

**Love2D Testing:**

```lua
function test_love_load_initializesGame()
    -- Mock Love2D environment
    local loveMock = {
        graphics = {
            newImage = function() return {} end,
            setMode = function() end
        },
        audio = {
            newSource = function() return {} end
        }
    }
    
    _G.love = loveMock
    
    -- Call original load
    local main = require("main")
    love.load()
    
    -- Verify initialization
    assert(_G.GameState ~= nil)
    assert(_G.EventBus ~= nil)
end

function test_love_update_updatesGameState()
    local dt = 0.016  -- 60 FPS
    
    love.update(dt)
    
    -- Verify state changed
    assert(_G.GameState.currentTime > 0)
end
```

### ✅ DO: Test Without Graphics

Headless testing for logic.

**Headless Testing:**

```lua
-- Test that doesn't need graphics
function test_battle_logic_independent()
    -- Can run without Love2D graphics context
    local mission = Mission:new("Test")
    mission:addUnit(Unit:new("Soldier"))
    mission:addEnemy(Alien:new("Sectoid"))
    
    mission:start()
    mission.units[1]:attack(mission.enemies[1])
    
    assert(mission.enemies[1].health < 100)
    
    -- No graphics needed for logic test
end
```

---

## Performance Testing

### ✅ DO: Measure Performance

Identify bottlenecks.

**Performance Test:**

```lua
function test_pathfinding_performance()
    local start = love.timer.getTime()
    
    -- Run 1000 pathfinding queries
    for i = 1, 1000 do
        local path = findPath(
            { x = 0, y = 0 },
            { x = 50, y = 50 }
        )
    end
    
    local elapsed = love.timer.getTime() - start
    local avgTime = elapsed / 1000
    
    print("Average pathfinding: " .. avgTime .. "ms")
    assert(avgTime < 0.01, "Pathfinding should be <10ms")
end
```

### ✅ DO: Test Under Load

Real-world conditions.

**Load Testing:**

```lua
function test_battle_with_many_units()
    local mission = Mission:new("LargeScale")
    
    -- Add 50 units
    for i = 1, 50 do
        mission:addUnit(Unit:new("Soldier" .. i))
    end
    
    -- Add 50 enemies
    for i = 1, 50 do
        mission:addEnemy(Alien:new("Alien" .. i))
    end
    
    local start = love.timer.getTime()
    mission:start()
    
    -- Run 10 turns
    for turn = 1, 10 do
        mission:endTurn()
    end
    
    local elapsed = love.timer.getTime() - start
    print("100 units, 10 turns: " .. elapsed .. "s")
    
    assert(elapsed < 5, "Should complete in <5 seconds")
end
```

---

## Test Coverage & Metrics

### ✅ DO: Measure Code Coverage

Track what's tested.

**Coverage Tracking:**

```
Ideal Coverage:
- Critical paths (combat, core logic): 90%+
- Important features: 70-80%
- Nice-to-have features: 50%+
- Rarely used code: 30%+

Coverage Report:
Unit.lua: 92% (115/125 lines)
Combat.lua: 87% (156/179 lines)
UI.lua: 45% (89/198 lines)

Focus testing on critical, low-coverage areas
```

### ✅ DO: Track Test Metrics

Monitor test suite health.

**Test Metrics:**

```
Metrics to track:
- Test count (growing over time)
- Pass rate (should be 100%)
- Average test time (watch for slowness)
- Coverage % (should stay high)
- Failure frequency (spike = regression)

Dashboard:
Tests: 245 total, 245 passing (100%)
Coverage: 82% overall
Avg time: 0.5s per test
Latest: All passing ✓
```

---

## Continuous Integration

### ✅ DO: Automate Test Runs

Tests run on every commit.

**CI Pipeline:**

```
Commit pushed → CI Server
  ├─ Lint code (style checks)
  ├─ Run all tests
  │  ├─ Unit tests (< 1 min)
  │  ├─ Integration tests (< 2 min)
  │  └─ Performance tests (< 1 min)
  ├─ Generate coverage report
  ├─ Build release (if tests pass)
  └─ Notify developer (pass/fail)

Total time: <5 minutes
Automatic feedback
```

### ✅ DO: Fail on Failed Tests

Never merge broken code.

**CI Rules:**

```
Merge requirements:
✓ All tests passing
✓ Coverage not decreased
✓ No lint warnings
✓ Performance acceptable

If any fail:
✗ Merge blocked
✗ Developer notified
✗ Must fix before retry

Ensures main branch always works
```

---

## Test Organization

### ✅ DO: Organize Tests Logically

Mirror source structure.

**Test Organization:**

```
Source Structure:
engine/
├── core/
│   ├── state_manager.lua
│   ├── event_bus.lua
│   └── entity.lua
├── combat/
│   ├── damage_calculator.lua
│   └── turn_system.lua

Test Structure (mirrored):
tests/
├── unit/
│   ├── core/
│   │   ├── state_manager_test.lua
│   │   ├── event_bus_test.lua
│   │   └── entity_test.lua
│   ├── combat/
│   │   ├── damage_calculator_test.lua
│   │   └── turn_system_test.lua
├── integration/
│   ├── combat_flow_test.lua
│   └── mission_test.lua
└── fixtures/
    ├── units.lua
    ├── weapons.lua
    └── missions.lua

Mirroring structure aids navigation
```

---

## Debugging Failed Tests

### ✅ DO: Use Print Debugging

Add context to failures.

**Debug Output:**

```lua
function test_combat_damage()
    local attacker = Unit:new("Attacker")
    local defender = Unit:new("Defender")
    
    print("[TEST] Attacker health: " .. attacker.health)
    print("[TEST] Defender health before: " .. defender.health)
    
    local damage = calculateDamage(attacker, defender)
    print("[TEST] Calculated damage: " .. damage)
    
    defender:takeDamage(damage)
    print("[TEST] Defender health after: " .. defender.health)
    
    assert(defender.health == 75, "Expected 75 health")
end
```

### ✅ DO: Check Test Environment

Verify setup is correct.

**Debugging Checklist:**

```
When test fails:

□ Check test setup (fixtures initialized?)
□ Print actual values (what's really there?)
□ Check mocks (are they behaving as expected?)
□ Run test in isolation (passes alone?)
□ Check test order (depends on another test?)
□ Check global state (is something persisting?)
□ Check random seeds (any randomness involved?)
□ Check timing (is test too fast/slow?)
```

---

## Best Practices Summary

### ✅ DO

- ✓ Write tests BEFORE code (TDD)
- ✓ Test one thing per test
- ✓ Use descriptive test names
- ✓ Keep tests simple and fast
- ✓ Mock external dependencies
- ✓ Run tests on every commit (CI)
- ✓ Maintain >80% coverage
- ✓ Test edge cases and errors
- ✓ Review test code like production code
- ✓ Update tests when requirements change

### ❌ DON'T

- ✗ Write tests after code (if at all)
- ✗ Test multiple behaviors in one test
- ✗ Use cryptic variable names
- ✗ Leave test database dirty (cleanup)
- ✗ Mock the code being tested
- ✗ Skip tests to go faster
- ✗ Delete tests because they're inconvenient
- ✗ Test only the happy path
- ✗ Leave failing tests unfixed
- ✗ Let test suite become slow

---

**Version**: 1.0  
**Last Updated**: October 16, 2025  
**Status**: Active Best Practice Guide

*See also: tests/README.md for test execution instructions*
