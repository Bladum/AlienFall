-- tests/performance/init.lua
-- Performance test suite loader

local performance = {}

-- Load all performance tests
performance.game = require("tests.performance.test_game_performance")
performance.base = require("tests.performance.test_performance")

-- Run all performance tests
function performance:runAll()
    print("\n" .. string.rep("═", 80))
    print("PERFORMANCE TESTS SUITE - 2 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0
    local tests = {
        "game", "base"
    }

    for _, name in ipairs(tests) do
        if performance[name] and performance[name].runAll then
            local ok, err = pcall(function() performance[name]:runAll() end)
            if ok then
                passed = passed + 1
            else
                failed = failed + 1
                print("[ERROR] " .. name .. ": " .. tostring(err))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("PERFORMANCE TEST SUMMARY")
    print(string.rep("═", 80))
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    print("Total: " .. (passed + failed))
    print(string.rep("═", 80) .. "\n")
end

return performance
