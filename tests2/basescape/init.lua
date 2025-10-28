-- Basescape Test Suite Index
local basescape = {}

-- Load all basescape tests
basescape.base_architecture = require("tests2.basescape.base_architecture_test")
basescape.base_constructor = require("tests2.basescape.base_constructor_test")
basescape.base_defense = require("tests2.basescape.base_defense_test")
basescape.base_manager = require("tests2.basescape.base_manager_test")
basescape.building_management = require("tests2.basescape.building_management_test")
basescape.craft_inventory = require("tests2.basescape.craft_inventory_test")
basescape.craft_management = require("tests2.basescape.craft_management_test")
basescape.crew_management = require("tests2.basescape.crew_management_test")
basescape.facility_system = require("tests2.basescape.facility_system_test")
basescape.failover_recovery = require("tests2.basescape.failover_recovery_test")
basescape.karma_reputation = require("tests2.basescape.karma_reputation_test")
basescape.lab_research = require("tests2.basescape.lab_research_test")
basescape.pilots_perks = require("tests2.basescape.pilots_perks_test")
basescape.storage_hierarchy = require("tests2.basescape.storage_hierarchy_test")
basescape.vehicle_management = require("tests2.basescape.vehicle_management_test")
basescape.volumetric_storage = require("tests2.basescape.volumetric_storage_test")

function basescape:run()
    local Helpers = require("tests2.utils.test_helpers")

    local allResults = {}

    print("\n" .. string.rep("═", 80))
    print("BASESCAPE MODULE TEST SUITE - ALL MODULES")
    print(string.rep("═", 80))

    local modules = {
        "base_architecture",
        "base_constructor",
        "base_defense",
        "base_manager",
        "building_management",
        "craft_inventory",
        "craft_management",
        "crew_management",
        "facility_system",
        "failover_recovery",
        "karma_reputation",
        "lab_research",
        "pilots_perks",
        "storage_hierarchy",
        "vehicle_management",
        "volumetric_storage"
    }

    local totalTests = 0
    local totalPassed = 0

    for _, moduleName in ipairs(modules) do
        local mod = basescape[moduleName]
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
    print("BASESCAPE SUMMARY")
    print(string.rep("═", 80))
    print("Total Tests: " .. totalTests)
    print("Passed: " .. totalPassed)
    print("Failed: " .. (totalTests - totalPassed))
    print("Pass Rate: " .. string.format("%.1f", (totalPassed/totalTests)*100) .. "%")
    print(string.rep("═", 80) .. "\n")
end

return basescape
