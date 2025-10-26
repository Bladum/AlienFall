-- tests2/performance/init.lua
-- Performance test suite

local performance = {}

-- Performance tests
performance.benchmarks = require("tests2.performance.performance_benchmarks_test")
performance.phase2 = require("tests2.performance.phase2_optimization_test")

function performance:runAll()
    print("\n" .. string.rep("═", 80))
    print("PERFORMANCE TESTS - 2 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0

    for name, test in pairs(self) do
        if type(test) == "table" and test.run then
            local ok, err = pcall(function() test:run() end)
            if ok then passed = passed + 1
            else failed = failed + 1; print("[ERROR] " .. name .. ": " .. tostring(err)) end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("PERFORMANCE TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return performance
