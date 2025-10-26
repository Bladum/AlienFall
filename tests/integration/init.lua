-- tests/integration/init.lua
-- Integration test suite loader

local integration = {}

-- Load all integration tests
integration.gameplay = require("tests.integration.gameplay_integration_test")
integration.manual_gameplay = require("tests.integration.manual_gameplay_test")
integration.all_systems_init = require("tests.integration.test_all_systems_init")
integration.base = require("tests.integration.test_base_integration")
integration.battlescape_basescape = require("tests.integration.test_battlescape_basescape_integration")
integration.battlescape_workflow = require("tests.integration.test_battlescape_workflow")
integration.combat = require("tests.integration.test_combat_integration")
integration.cross_system = require("tests.integration.test_cross_system_integration")
integration.geoscape_economy = require("tests.integration.test_geoscape_economy_integration")
integration.mapblock = require("tests.integration.test_mapblock_integration")
integration.phase2 = require("tests.integration.test_phase2")

-- Run all integration tests
function integration:runAll()
    print("\n" .. string.rep("═", 80))
    print("INTEGRATION TESTS SUITE - 11 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0
    local tests = {
        "gameplay", "manual_gameplay", "all_systems_init", "base",
        "battlescape_basescape", "battlescape_workflow", "combat",
        "cross_system", "geoscape_economy", "mapblock", "phase2"
    }

    for _, name in ipairs(tests) do
        if integration[name] and integration[name].runAll then
            local ok, err = pcall(function() integration[name]:runAll() end)
            if ok then
                passed = passed + 1
            else
                failed = failed + 1
                print("[ERROR] " .. name .. ": " .. tostring(err))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("INTEGRATION TEST SUMMARY")
    print(string.rep("═", 80))
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    print("Total: " .. (passed + failed))
    print(string.rep("═", 80) .. "\n")
end

return integration
