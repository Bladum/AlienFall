# 🎓 Refactoring & Technical Debt Best Practices

**Domain:** Code Quality & Maintainability  
**Focus:** Refactoring strategies, technical debt management, code review, incremental improvements  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers identifying technical debt, planning refactoring work, executing safe refactoring, and maintaining code quality.

## Identifying Technical Debt

### ✅ DO: Document Technical Debt

```lua
-- TODO comments that track debt
function renderBattleUI()
    -- TODO: [DEBT] Refactor UI rendering to use widget system instead of direct draws
    -- Estimated effort: 2-3 days
    -- Impact: Better code organization, easier maintenance
    -- Dependencies: Widget system needs to support all UI elements
    love.graphics.print("Unit Health: " .. unit.health, 100, 100)
    love.graphics.print("Ammo: " .. unit.ammo, 100, 120)
end

-- Create DEBT tracking file
local debtLog = {
    {
        id = "DEBT-001",
        area = "UI Rendering",
        description = "Direct graphics calls instead of widget system",
        estimated_effort_days = 3,
        priority = "HIGH",
        date_identified = os.date("%Y-%m-%d")
    }
}
```

---

### ✅ DO: Measure Code Quality Metrics

```lua
function analyzeCodeQuality(filePath)
    local content = love.filesystem.read(filePath)
    local metrics = {
        lines_of_code = 0,
        functions = 0,
        global_vars = 0,
        long_functions = 0,
        cyclomatic_complexity = 0
    }
    
    -- Count lines
    for line in content:gmatch("[^\n]+") do
        metrics.lines_of_code = metrics.lines_of_code + 1
    end
    
    -- Count functions
    for _ in content:gmatch("function ") do
        metrics.functions = metrics.functions + 1
    end
    
    -- Count globals (bad sign)
    for _ in content:gmatch("^[A-Z_]+%s*=") do
        metrics.global_vars = metrics.global_vars + 1
    end
    
    -- Identify long functions
    for func in content:gmatch("function%s+([%w_:]+)%b()%s*\n(.-)\nend") do
        local lines = select(2, func:gsub("\n", ""))
        if lines > 50 then
            metrics.long_functions = metrics.long_functions + 1
        end
    end
    
    return metrics
end
```

---

## Planning Refactoring

### ✅ DO: Create Refactoring Task Document

```markdown
# TASK-DEBT-001: Refactor Battlescape UI to Widget System

## Overview
Refactor all direct love.graphics calls in battlescape UI to use the widget system.

## Current State
- ~500 lines of direct graphics rendering
- Hard to maintain and extend
- Difficult to unit test
- No separation of concerns

## Target State
- All UI elements use widget system
- Consistent styling through themes
- Testable components
- Clear separation of UI logic and rendering

## Implementation Plan
1. Week 1: Create missing widget types
2. Week 2: Refactor 50% of UI
3. Week 3: Complete UI refactoring
4. Week 4: Testing and polish

## Success Criteria
- All battlescape UI uses widgets
- No visual regressions
- Code passes code review
- Performance metrics unchanged
```

---

## Safe Refactoring Practices

### ✅ DO: Refactor With Tests

```lua
-- Before refactoring: write tests for current behavior
function testDamageCalculation()
    local unit = createMockUnit()
    unit.defense = 10
    
    local damage = calculateDamage({power = 50}, unit)
    
    assert(damage == 40, "Expected 40 damage, got " .. damage)
    print("[TEST PASS] Damage calculation correct")
end

-- Run tests to establish baseline
testDamageCalculation()

-- Now refactor with confidence
function calculateDamageRefactored(weapon, target)
    local baseDamage = weapon.power
    local reducedDamage = baseDamage - (target.defense * 0.2)
    return math.max(0, reducedDamage)
end

-- Tests still pass after refactoring
testDamageCalculation()
```

---

### ✅ DO: Refactor in Small Steps

```lua
-- Instead of rewriting entire file, refactor in small increments

-- Step 1: Extract helper function
-- BEFORE:
function processUnitBad(unit)
    if unit.health > 0 then
        if unit.faction == "player" then
            unit.ap = unit.ap + 2
        end
    end
end

-- AFTER: Extract logic to function
function isAlivePlayerUnit(unit)
    return unit.health > 0 and unit.faction == "player"
end

function processUnitGood(unit)
    if isAlivePlayerUnit(unit) then
        unit.ap = unit.ap + 2
    end
end

-- Now easier to test and understand
```

---

### ✅ DO: Use Feature Flags During Refactoring

```lua
-- Feature flag for new implementation
FEATURES = {
    use_new_ui_system = false,  -- Can toggle
    use_optimized_pathfinding = false
}

function renderUI()
    if FEATURES.use_new_ui_system then
        renderUIWithWidgets()
    else
        renderUILegacy()
    end
end

-- Gradually enable for testing
function testNewUI()
    FEATURES.use_new_ui_system = true
    -- Test new system
    runTests()
    -- Can easily rollback if issues
    FEATURES.use_new_ui_system = false
end
```

---

## Practical Implementation

### ✅ DO: Create Refactoring Checklist

```lua
local refactoringChecklist = {
    planning = {
        "Identify areas needing refactoring",
        "Document current behavior",
        "Write comprehensive tests",
        "Estimate effort",
        "Plan in small increments"
    },
    execution = {
        "Extract one function at a time",
        "Run tests after each change",
        "Use feature flags for large changes",
        "Update documentation",
        "Commit after each small change"
    },
    validation = {
        "All tests pass",
        "Performance unchanged",
        "No visual regressions",
        "Code review approved",
        "Revert plan ready"
    }
}
```

---

### ✅ DO: Document Why Code Exists

```lua
-- Instead of just seeing confusing code
function calculateDamage(weapon, armor)
    local base = weapon.power
    local reduced = base * (1 - armor.value / 100)
    return math.max(1, reduced)
end

-- Document the reasoning
function calculateDamage(weapon, armor)
    -- Damage formula: base - (base * armor_percentage)
    -- Example: 50 damage vs 20% armor = 50 - 10 = 40
    -- Minimum 1 damage to prevent stalling gameplay
    
    local base = weapon.power
    local reduced = base * (1 - armor.value / 100)
    return math.max(1, reduced)
end
```

---

### ❌ DON'T: Refactor Without Tests

```lua
-- BAD: Refactor blind
function refactorWithoutTestsBad()
    -- Make big changes without verifying behavior
    -- Hope nothing breaks
    completelyRewriteFunction()
end

-- GOOD: Refactor with safety net
function refactorWithTestsGood()
    -- Write tests first
    testCurrentBehavior()
    
    -- Refactor incrementally
    refactorOneSmallPart()
    testAgain()
    
    -- Only continue if tests pass
    refactorNextPart()
    testAgain()
end
```

---

### ❌ DON'T: Mix Refactoring With Features

```lua
-- BAD: Same PR adds features and refactors
function pullRequestBad()
    -- Refactor UI system
    refactorUIWidgets()
    
    -- Add new feature
    addNewFeature()
    
    -- Hard to review, hard to revert
end

-- GOOD: Separate concerns
function pullRequestGood()
    -- First PR: Just refactor
    refactorUIWidgets()
    -- Code review on refactoring
    -- Tests verify behavior unchanged
    
    -- Second PR: New feature uses refactored code
    addNewFeature()
    -- Review focuses on feature
end
```

---

## Common Patterns & Checklist

- [x] Identify and document technical debt
- [x] Measure code quality metrics
- [x] Plan refactoring tasks
- [x] Write tests before refactoring
- [x] Refactor in small increments
- [x] Use feature flags during refactoring
- [x] Update documentation
- [x] Review changes carefully
- [x] Maintain performance
- [x] Keep refactoring separate from features

---

## References

- Code Smells: https://refactoring.guru/refactoring/smells
- Technical Debt: https://martinfowler.com/bliki/TechnicalDebt.html
- Refactoring Patterns: https://refactoring.guru/

