-- ─────────────────────────────────────────────────────────────────────────
-- ENGINE COVERAGE ANALYSIS
-- FILE: tests2/core/engine_coverage_analysis_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Analyzes test coverage for engine/ folder
-- Identifies which modules and functions need tests
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- ENGINE MODULES TO ANALYZE
-- ─────────────────────────────────────────────────────────────────────────

local EngineModules = {
    -- Core systems
    {
        name = "StateManager",
        path = "engine/core/state/state_manager.lua",
        functions = {
            "register", "switch", "update", "draw",
            "getStateNames", "countStates"
        },
        status = "PARTIAL_COVERAGE" -- We just created tests
    },

    -- Important game systems
    {
        name = "TurnManager",
        path = "engine/core/turn/turn_manager.lua",
        functions = {"newTurn", "execute", "reset", "getCurrentTurn"},
        status = "NO_COVERAGE"
    },

    {
        name = "UnitSystem",
        path = "engine/battlescape/unit_system.lua",
        functions = {"create", "move", "attack", "getUnit"},
        status = "NO_COVERAGE"
    },

    {
        name = "MapGenerator",
        path = "engine/battlescape/map_generator.lua",
        functions = {"generate", "validate", "getTile"},
        status = "NO_COVERAGE"
    },

    {
        name = "BaseManager",
        path = "engine/basescape/base_manager.lua",
        functions = {"createBase", "buildFacility", "research"},
        status = "NO_COVERAGE"
    },

    {
        name = "Economy",
        path = "engine/economy/economy.lua",
        functions = {"addFunds", "spendFunds", "getBalance"},
        status = "NO_COVERAGE"
    },

    {
        name = "AIManager",
        path = "engine/ai/ai_manager.lua",
        functions = {"decide", "evaluate", "execute"},
        status = "NO_COVERAGE"
    }
}

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "engine.coverage.analysis",
    fileName = "engine_coverage_analysis.lua",
    description = "Engine module coverage analysis and gap identification"
})

Suite:before(function()
    print("[EngineAnalysis] Starting coverage analysis for engine/")
end)

Suite:after(function()
    print("[EngineAnalysis] Analysis complete")
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: COVERAGE STATUS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Coverage Status", function()
    Suite:testMethod("EngineModules.analysis", {
        description = "Reports coverage status for all modules",
        testCase = "summary",
        type = "informational"
    }, function()
        print("\n" .. string.rep("─", 70))
        print("ENGINE MODULE COVERAGE SUMMARY")
        print(string.rep("─", 70))

        local total = #EngineModules
        local covered = 0
        local partial = 0

        for _, module in ipairs(EngineModules) do
            if module.status == "FULL_COVERAGE" then
                covered = covered + 1
                print(string.format("✓ %-20s [FULL] %d functions", module.name, #module.functions))
            elseif module.status == "PARTIAL_COVERAGE" then
                partial = partial + 1
                print(string.format("◐ %-20s [PARTIAL] %d functions", module.name, #module.functions))
            else
                print(string.format("✗ %-20s [NONE] %d functions", module.name, #module.functions))
            end
        end

        print(string.rep("─", 70))
        print(string.format("Total: %d modules | Covered: %d | Partial: %d | Missing: %d",
            total, covered, partial, total - covered - partial))
        print(string.format("Coverage: %.1f%% functions have tests\n", (covered * 100) / total))

        assert(total > 0, "Should have modules to analyze")
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: CRITICAL MODULES (Priority 1)
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Critical Modules (Priority 1)", function()
    Suite:testMethod("StateManager", {
        description = "State management system - PARTIAL (needs more coverage)",
        testCase = "priority_check",
        type = "informational"
    }, function()
        print("\n[StateManager] Status: PARTIAL_COVERAGE")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("TurnManager", {
        description = "Turn system - NO_COVERAGE (needs first tests)",
        testCase = "priority_check",
        type = "informational"
    }, function()
        print("\n[TurnManager] Status: NO_COVERAGE")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: GAME SYSTEMS (Priority 2)
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Game Systems (Priority 2)", function()
    Suite:testMethod("Battlescape Systems", {
        description = "Unit system and map generation - NO_COVERAGE",
        testCase = "module_check",
        type = "informational"
    }, function()
        print("\n[Battlescape] Coverage Status:")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("Basescape Systems", {
        description = "Base management - NO_COVERAGE",
        testCase = "module_check",
        type = "informational"
    }, function()
        print("\n[Basescape] Coverage Status:")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: SUPPORT SYSTEMS (Priority 3)
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Support Systems (Priority 3)", function()
    Suite:testMethod("Economy System", {
        description = "Financial management - NO_COVERAGE",
        testCase = "module_check",
        type = "informational"
    }, function()
        print("\n[Economy] Coverage Status:")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("AI System", {
        description = "AI decision making - NO_COVERAGE",
        testCase = "module_check",
        type = "informational"
    }, function()
        print("\n[AI] Coverage Status:")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: ACTION PLAN
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Action Plan", function()
    Suite:testMethod("Recommended Test Order", {
        description = "Prioritized list of modules to test next",
        testCase = "roadmap",
        type = "informational"
    }, function()
        print("\n" .. string.rep("═", 70))
        print("RECOMMENDED TEST EXPANSION ORDER")
        print(string.rep("═", 70))

        print("\n1. TurnManager (engine/core/turn/turn_manager.lua)")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this

        print("\n2. UnitSystem (engine/battlescape/unit_system.lua)")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this

        print("\n3. MapGenerator (engine/battlescape/map_generator.lua)")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this

        print("\n4. BaseManager (engine/basescape/base_manager.lua)")
        -- Removed manual print - framework handles this
        -- Removed manual print - framework handles this

        print("\n" .. string.rep("═", 70))
    end)

    Suite:testMethod("How to Create New Tests", {
        description = "Template for adding new test files",
        testCase = "template",
        type = "informational"
    }, function()
        print("\nNEW TEST FILE TEMPLATE:")
        print("─" .. string.rep("─", 68))
        print("1. Copy example_counter_test.lua structure")
        print("2. Update module path: engine.core.turn.turn_manager")
        print("3. Create mock version of module")
        print("4. Add test groups (Registration, Execution, State, etc)")
        print("5. Add test methods with happy_path, edge_case, error_handling")
        print("6. Run: lovec tests2 run turn_manager")
        print("─" .. string.rep("─", 68))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
