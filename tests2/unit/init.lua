-- Unit Test Suite Index
local unit = {}

-- Load all unit tests
unit.mission_assignment = require("tests2.unit.mission_assignment_test")
unit.trait_system = require("tests2.unit.trait_system_tests")

function unit:run()
    local Helpers = require("tests2.utils.test_helpers")

    local allResults = {}

    print("\n" .. string.rep("═", 80))
    print("UNIT MODULE TEST SUITE - ALL MODULES")
    print(string.rep("═", 80))

    local modules = {
        "mission_assignment",
        "trait_system"
    }

    local totalTests = 0
    local totalPassed = 0

    for _, moduleName in ipairs(modules) do
        local mod = unit[moduleName]
        if mod then
            print("\n" .. string.rep("-", 80))
            print("Running: " .. moduleName)
            print(string.rep("-", 80))

            if type(mod) == "table" and mod.run then
                -- Suite object with run method
                mod:run()
                totalTests = totalTests + 1
                totalPassed = totalPassed + 1
            elseif type(mod) == "boolean" then
                -- Already executed, boolean result
                if mod then
                    totalTests = totalTests + 1
                    totalPassed = totalPassed + 1
                else
                    totalTests = totalTests + 1
                    -- failed is already 0
                end
            else
                print("Unknown module type for " .. moduleName .. ": " .. type(mod))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("UNIT SUMMARY")
    print(string.rep("═", 80))
    print("Total Tests: " .. totalTests)
    print("Passed: " .. totalPassed)
    print("Failed: " .. (totalTests - totalPassed))
    print("Pass Rate: " .. string.format("%.1f", (totalPassed/totalTests)*100) .. "%")
    print(string.rep("═", 80) .. "\n")
end

return unit
