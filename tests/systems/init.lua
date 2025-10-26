-- tests/systems/init.lua
-- Systems test suite loader

local systems = {}

-- Load all systems tests
systems.mod = require("tests.systems.test_mod_system")
systems.performance = require("tests.systems.test_performance")
systems.phase2 = require("tests.systems.test_phase2")

-- Run all systems tests
function systems:runAll()
    print("\n" .. string.rep("═", 80))
    print("SYSTEMS TESTS SUITE - 3 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0
    local tests = {
        "mod", "performance", "phase2"
    }

    for _, name in ipairs(tests) do
        if systems[name] and systems[name].runAll then
            local ok, err = pcall(function() systems[name]:runAll() end)
            if ok then
                passed = passed + 1
            else
                failed = failed + 1
                print("[ERROR] " .. name .. ": " .. tostring(err))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("SYSTEMS TEST SUMMARY")
    print(string.rep("═", 80))
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    print("Total: " .. (passed + failed))
    print(string.rep("═", 80) .. "\n")
end

return systems
