-- ─────────────────────────────────────────────────────────────────────────
-- MAIN ENTRY POINT FOR tests2 - Hierarchical Test Suite
-- ─────────────────────────────────────────────────────────────────────────
-- Usage: lovec tests2 run_smoke (from project root)
-- ─────────────────────────────────────────────────────────────────────────

-- Test phase definitions (module names for each phase)
local TEST_PHASES = {
    run_smoke = {
        "tests2.smoke.core_systems_smoke_test",
        "tests2.smoke.gameplay_loop_smoke_test",
        "tests2.smoke.asset_loading_smoke_test",
        "tests2.smoke.persistence_smoke_test",
        "tests2.smoke.ui_smoke_test"
    },
    run_regression = {
        "tests2.regression.core_regression_test",
        "tests2.regression.gameplay_regression_test",
        "tests2.regression.combat_regression_test",
        "tests2.regression.ui_regression_test",
        "tests2.regression.economy_regression_test",
        "tests2.regression.performance_regression_test"
    },
    run_api_contract = {
        "tests2.api_contract.engine_api_contract_test",
        "tests2.api_contract.geoscape_api_contract_test",
        "tests2.api_contract.battlescape_api_contract_test",
        "tests2.api_contract.basescape_api_contract_test",
        "tests2.api_contract.system_api_contract_test",
        "tests2.api_contract.persistence_api_contract_test"
    },
    run_compliance = {
        "tests2.by_type.compliance.game_rules_compliance_test",
        "tests2.by_type.compliance.configuration_constraints_test",
        "tests2.by_type.compliance.business_logic_compliance_test",
        "tests2.by_type.compliance.data_integrity_compliance_test",
        "tests2.by_type.compliance.balance_verification_test",
        "tests2.by_type.compliance.constraint_validation_test"
    },
    run_security = {
        "tests2.by_type.security.input_validation_security_test",
        "tests2.by_type.security.access_control_security_test",
        "tests2.by_type.security.data_protection_security_test",
        "tests2.by_type.security.injection_prevention_security_test",
        "tests2.by_type.security.authentication_security_test",
        "tests2.by_type.security.integrity_verification_security_test"
    },
    run_property = {
        "tests2.by_type.property.boundary_conditions_test",
        "tests2.by_type.property.edge_cases_test",
        "tests2.by_type.property.data_mutations_test",
        "tests2.by_type.property.state_invariants_test",
        "tests2.by_type.property.recovery_scenarios_test",
        "tests2.by_type.property.stress_conditions_test",
        "tests2.by_type.property.combinatorial_test"
    }
}

-- Phase descriptions
local PHASE_DESCRIPTIONS = {
    run_smoke = "SMOKE TESTS (Quick Validation)",
    run_regression = "REGRESSION TESTS (Bug Prevention)",
    run_api_contract = "API CONTRACT TESTS (Interface Verification)",
    run_compliance = "COMPLIANCE TESTS (Game Rules & Constraints)",
    run_security = "SECURITY TESTS (Protection & Access Control)",
    run_property = "PROPERTY-BASED TESTS (Edge Cases & Stress)"
}

function love.load()
    -- Add parent directory to Lua path for requires to work
    package.path = package.path .. ";./?;./?/init.lua"

    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - Test Runner Dispatcher")
    print(string.rep("═", 80))

    -- Get runner name from arguments
    local runnerName = arg[2] or "help"
    runnerName = runnerName:lower()

    print("[DISPATCHER] Loading runner: " .. runnerName)

    -- Handle different runners
    if runnerName == "help" or runnerName == "" then
        printHelp()
    elseif TEST_PHASES[runnerName] then
        runTestPhase(runnerName, TEST_PHASES[runnerName], PHASE_DESCRIPTIONS[runnerName])
    else
        print("[ERROR] Unknown runner: " .. runnerName)
        printHelp()
    end

    -- Exit after execution
    love.event.quit()
end

-- ─────────────────────────────────────────────────────────────────────────

function printHelp()
    print([[

USAGE: lovec tests2 [RUNNER]

RUNNERS:

  run_smoke            - Phase 1: Smoke Tests (22 tests, <500ms)
  run_regression       - Phase 2: Regression Tests (38 tests, <2s)
  run_api_contract     - Phase 3: API Contract Tests (45 tests, <3s)
  run_compliance       - Phase 4: Compliance Tests (44 tests, <5s)
  run_security         - Phase 5: Security Tests (44 tests, <5s)
  run_property         - Phase 6: Property-Based Tests (55 tests, <8s)

EXAMPLES:

  lovec tests2 run_smoke
  lovec tests2 run_regression
  lovec tests2 run_security

TOTAL TESTS: 244 (across all 6 phases)

]])
end

-- ─────────────────────────────────────────────────────────────────────────

function runTestPhase(phaseName, testModules, phaseDescription)
    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - " .. phaseDescription)
    print(string.rep("═", 80) .. "\n")

    print("[RUNNER] Loading " .. phaseName .. " test suite...")

    local totalTests = 0
    local passedTests = 0
    local failedTests = 0

    print("[RUNNER] Found " .. #testModules .. " test modules\n")

    for _, testModulePath in ipairs(testModules) do
        print("[RUNNER] Loading: " .. testModulePath)

        local testModule
        local moduleOk, moduleErr = pcall(function()
            -- Try standard require first
            testModule = require(testModulePath)
        end)

        if not moduleOk then
            -- Try alternative path for by_type modules (use by-type with hyphen)
            if string.find(testModulePath, "by_type", 1, true) then
                local altPath = string.gsub(testModulePath, "by_type", "by-type")
                print("[DEBUG] Trying alternative path: " .. altPath)
                moduleOk, moduleErr = pcall(function()
                    testModule = require(altPath)
                end)
            end
        end

        if not moduleOk then
            print("[WARNING] Could not load " .. testModulePath .. ": " .. tostring(moduleErr))
        elseif testModule and testModule.run then
            local runOk, runResult = pcall(function()
                testModule:run()
                return testModule:getResults()
            end)

            if runOk and runResult and type(runResult) == "table" then
                totalTests = totalTests + (runResult.passed or 0) + (runResult.failed or 0) + (runResult.skipped or 0)
                passedTests = passedTests + (runResult.passed or 0)
                failedTests = failedTests + (runResult.failed or 0)
            elseif not runOk then
                print("[ERROR] Test module execution failed: " .. tostring(runResult))
            end
        end
    end

    print("\n" .. string.rep("─", 80))
    print(string.format("TEST SUMMARY for %s", phaseName:upper()))
    print(string.rep("─", 80))
    print(string.format("Total:  %d", totalTests))
    print(string.format("Passed: %d", passedTests))
    print(string.format("Failed: %d", failedTests))
    print(string.rep("─", 80) .. "\n")
end

-- ─────────────────────────────────────────────────────────────────────────
-- LOVE2D CALLBACKS
-- ─────────────────────────────────────────────────────────────────────────

function love.update(dt)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Test Suite 2 - Check console for output", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
