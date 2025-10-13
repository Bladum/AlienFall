# Task: Add Comprehensive Testing Suite

**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Add test coverage to most files in the engine, keeping test files separated. Run tests using Love2D framework, not standalone Lua application.

---

## Purpose

Ensure code reliability, catch regressions early, and make refactoring safer. Tests should be runnable via Love2D to have access to all Love2D APIs and match the actual runtime environment.

---

## Requirements

### Functional Requirements
- [ ] Test files for all core systems
- [ ] Test files for battle systems
- [ ] Test files for widgets
- [ ] Test files for utilities
- [ ] Tests run via Love2D, not standalone Lua
- [ ] Tests are organized by module
- [ ] Test runner provides clear output

### Technical Requirements
- [ ] Use Love2D test framework or create custom
- [ ] Mock Love2D APIs where needed
- [ ] Tests should be fast (<5 seconds per file)
- [ ] Tests should be isolated (no dependencies between tests)
- [ ] Use assertions with clear error messages

### Acceptance Criteria
- [ ] At least 70% of engine files have tests
- [ ] All tests pass
- [ ] Tests can be run individually or as suite
- [ ] Test output is clear and actionable
- [ ] Tests catch at least 3 existing bugs

---

## Plan

### Step 1: Create Test Framework
**Description:** Set up Love2D test infrastructure  
**Files to create:**
- `engine/tests/framework/init.lua` - Test framework loader
- `engine/tests/framework/assertions.lua` - Assertion helpers
- `engine/tests/framework/mocks.lua` - Mock Love2D APIs
- `engine/tests/framework/runner.lua` - Test runner
- `engine/tests/test_all.lua` - Run all tests

**Estimated time:** 6 hours

### Step 2: Test Core Systems
**Description:** Add tests for systems/  
**Files to create:**
- `engine/tests/systems/test_state_manager.lua`
- `engine/tests/systems/test_action_system.lua`
- `engine/tests/systems/test_pathfinding.lua`
- `engine/tests/systems/test_spatial_hash.lua`
- `engine/tests/systems/test_team.lua`
- `engine/tests/systems/test_unit.lua`
- `engine/tests/systems/test_mod_manager.lua`
- `engine/tests/systems/test_data_loader.lua`

**Estimated time:** 12 hours

### Step 3: Test Battle Systems
**Description:** Add tests for battle/  
**Files to create:**
- `engine/tests/battle/test_battlefield.lua`
- `engine/tests/battle/test_grid_map.lua`
- `engine/tests/battle/test_map_generator.lua`
- `engine/tests/battle/test_map_block.lua`
- `engine/tests/battle/test_mapblock_system.lua`
- `engine/tests/battle/test_camera.lua`
- `engine/tests/battle/test_fire_system.lua`
- `engine/tests/battle/test_smoke_system.lua`
- `engine/tests/battle/test_turn_manager.lua`
- `engine/tests/battle/test_unit_selection.lua`
- `engine/tests/battle/test_animation_system.lua`

**Estimated time:** 15 hours

### Step 4: Test Widgets
**Description:** Add tests for widgets/  
**Files to create:**
- `engine/tests/widgets/test_base.lua`
- `engine/tests/widgets/test_button.lua`
- `engine/tests/widgets/test_label.lua`
- `engine/tests/widgets/test_panel.lua`
- `engine/tests/widgets/test_textinput.lua`
- `engine/tests/widgets/test_listbox.lua`
- `engine/tests/widgets/test_checkbox.lua`
- `engine/tests/widgets/test_radiobutton.lua`
- `engine/tests/widgets/test_imagebutton.lua`

**Estimated time:** 10 hours

### Step 5: Test Utilities
**Description:** Add tests for utils/  
**Files to create:**
- `engine/tests/utils/test_scaling.lua`
- `engine/tests/utils/test_viewport.lua`
- `engine/tests/utils/test_verify_assets.lua`

**Estimated time:** 4 hours

### Step 6: Integration Tests
**Description:** Add end-to-end tests  
**Files to create:**
- `engine/tests/integration/test_game_flow.lua`
- `engine/tests/integration/test_battle_flow.lua`
- `engine/tests/integration/test_state_transitions.lua`

**Estimated time:** 8 hours

### Step 7: Create Test Runner UI
**Description:** Create visual test runner in Love2D  
**Files to create:**
- `engine/modules/test_runner.lua` - Visual test runner
- Add test runner to main menu

**Estimated time:** 6 hours

### Step 8: Documentation
**Description:** Document testing approach  
**Files to create/modify:**
- `wiki/TESTING.md` - Update with new approach
- `engine/tests/README.md` - How to write and run tests
- `wiki/DEVELOPMENT.md` - Add testing workflow

**Estimated time:** 3 hours

---

## Implementation Details

### Architecture

**Test Framework Structure:**
```lua
-- engine/tests/framework/init.lua
local TestFramework = {
    tests = {},
    currentSuite = nil
}

function TestFramework.describe(name, fn)
    -- Group tests
end

function TestFramework.it(name, fn)
    -- Individual test
end

function TestFramework.expect(value)
    -- Assertion API
    return {
        toBe = function(expected) end,
        toEqual = function(expected) end,
        toBeNil = function() end,
        toThrow = function() end
    }
end

return TestFramework
```

**Example Test File:**
```lua
-- engine/tests/systems/test_pathfinding.lua
local test = require("tests.framework")
local pathfinding = require("systems.pathfinding")

test.describe("Pathfinding System", function()
    test.it("should find shortest path", function()
        local grid = createMockGrid(10, 10)
        local path = pathfinding.findPath(grid, {x=1, y=1}, {x=5, y=5})
        
        test.expect(path).toNotBeNil()
        test.expect(#path).toBeGreaterThan(0)
    end)
    
    test.it("should return nil for blocked path", function()
        local grid = createBlockedGrid(10, 10)
        local path = pathfinding.findPath(grid, {x=1, y=1}, {x=5, y=5})
        
        test.expect(path).toBeNil()
    end)
end)
```

### Key Components
- **Test Framework:** Custom framework compatible with Love2D
- **Mocks:** Mock Love2D APIs for isolated testing
- **Test Runner:** Visual runner in Love2D showing pass/fail
- **Assertions:** Clear assertion library
- **Test Organization:** Mirror engine/ structure in tests/

### Dependencies
- Love2D 12.0+
- No external Lua testing libraries (too hard to integrate with Love2D)

---

## Testing Strategy

### Unit Tests
- Test each function in isolation
- Mock external dependencies
- Test edge cases and error conditions
- Test typical usage scenarios

### Integration Tests
- Test interaction between systems
- Test full game workflows
- Test state transitions
- Test UI interactions

### Manual Testing Steps
1. Run test suite via Love2D: `lovec "engine" --test`
2. Verify all tests pass
3. Run individual test files
4. Check test coverage report (if implemented)
5. Verify tests catch known bugs

### Expected Results
- All tests pass
- Clear pass/fail output
- Tests run in <30 seconds total
- Failed tests show helpful error messages

---

## How to Run/Debug

### Running Tests
```bash
# Run all tests
lovec "engine" --test

# Run specific test file (to implement)
lovec "engine" --test systems/test_pathfinding.lua
```

### Using Test Runner UI
1. Launch game
2. Select "Run Tests" from menu
3. View results in visual test runner
4. Click on failed test for details

### Debugging
- Add `print()` statements in tests
- Use `test.only()` to run single test
- Use `test.skip()` to skip tests
- Check Love2D console for errors

---

## Documentation Updates

### Files to Update
- [x] `wiki/TESTING.md` - Complete testing guide
- [x] `engine/tests/README.md` - How to write tests
- [x] `wiki/DEVELOPMENT.md` - Add testing to workflow
- [x] `wiki/API.md` - Document test framework API

---

## Notes

- Tests should not modify game state permanently
- Use setup/teardown for test isolation
- Mock file I/O to avoid side effects
- Tests should be deterministic (no random failures)
- Focus on testing public APIs, not internals

---

## Blockers

None - can start immediately.

---

## Review Checklist

- [ ] Test framework implemented
- [ ] Tests for core systems complete
- [ ] Tests for battle systems complete
- [ ] Tests for widgets complete
- [ ] All tests pass
- [ ] Test runner UI working
- [ ] Documentation complete
- [ ] Tests catch real bugs
- [ ] Tests run quickly
- [ ] Code coverage >70%

---

## Post-Completion

### What Worked Well
- To be filled after completion

### What Could Be Improved
- To be filled after completion

### Lessons Learned
- To be filled after completion
