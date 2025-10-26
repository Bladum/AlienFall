-- tests2/framework/init.lua
-- Test framework components

local framework = {}

-- Framework modules
framework.hierarchical_suite = require("tests2.framework.hierarchical_suite")
framework.coverage = require("tests2.framework.coverage_calculator")
framework.reporter = require("tests2.framework.hierarchy_reporter")

function framework:runAll()
    print("\n" .. string.rep("═", 80))
    print("FRAMEWORK TESTS - Test Framework")
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
    print("FRAMEWORK TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return framework
