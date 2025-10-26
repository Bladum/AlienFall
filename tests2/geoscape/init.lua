-- Geoscape Test Suite Index
local geoscape = {}

-- Load all geoscape tests
geoscape.mission_manager = require("tests2.geoscape.mission_manager_test")
geoscape.difficulty_system = require("tests2.geoscape.difficulty_system_test")
geoscape.faction_system = require("tests2.geoscape.faction_system_test")
geoscape.campaign_manager = require("tests2.geoscape.campaign_manager_test")
geoscape.progression_manager = require("tests2.geoscape.progression_manager_test")

function geoscape:run()
    local Helpers = require("tests2.utils.test_helpers")

    local allResults = {}

    print("\n" .. string.rep("═", 80))
    print("GEOSCAPE MODULE TEST SUITE - ALL 5 MODULES")
    print(string.rep("═", 80))

    local modules = {
        "mission_manager",
        "difficulty_system",
        "faction_system",
        "campaign_manager",
        "progression_manager"
    }

    local totalTests = 0
    local totalPassed = 0

    for _, moduleName in ipairs(modules) do
        local mod = geoscape[moduleName]
        if mod then
            print("\n" .. string.rep("-", 80))
            print("Running: " .. moduleName)
            print(string.rep("-", 80))

            if mod.run then
                mod:run()
                totalTests = totalTests + 1
                totalPassed = totalPassed + 1
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("GEOSCAPE SUMMARY")
    print(string.rep("═", 80))
    print("Total Tests: " .. totalTests)
    print("Passed: " .. totalPassed)
    print("Failed: " .. (totalTests - totalPassed))
    print("Pass Rate: " .. string.format("%.1f", (totalPassed/totalTests)*100) .. "%")
    print(string.rep("═", 80) .. "\n")
end

return geoscape
