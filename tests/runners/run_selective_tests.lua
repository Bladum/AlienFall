-- Selective Test Runner
-- Run specific test categories or individual tests

-- Set up paths
package.path = package.path .. ";../../?.lua;../../engine/?.lua;../../engine/?/init.lua"

-- Test registry
local TestRegistry = {
    categories = {
        core = {
            name = "Core Systems",
            tests = {
                {"State Manager", "tests.unit.test_state_manager"},
                {"Audio System", "tests.unit.test_audio_system"},
                {"Data Loader", "tests.unit.test_data_loader"},
                {"Spatial Hash", "tests.unit.test_spatial_hash"},
                {"Save System", "tests.unit.test_save_system"},
                {"Mod Manager", "tests.unit.test_mod_manager"}
            }
        },
        basescape = {
            name = "Base Management",
            tests = {
                {"Facility System", "tests.unit.test_facility_system"},
                {"Base Integration", "tests.integration.test_base_integration"}
            }
        },
        geoscape = {
            name = "Geoscape & World",
            tests = {
                {"World System", "tests.unit.test_world_system"}
            }
        },
        combat = {
            name = "Combat Systems",
            tests = {
                {"Pathfinding", "tests.unit.test_pathfinding"},
                {"Hex Math", "tests.unit.test_hex_math"},
                {"Movement System", "tests.unit.test_movement_system"},
                {"Accuracy System", "tests.unit.test_accuracy_system"},
                {"Combat Integration", "tests.integration.test_combat_integration"},
                {"Battlescape Workflow", "tests.integration.test_battlescape_workflow"}
            }
        },
        economy = {
            name = "Economy & Research",
            tests = {
                {"Research System", "tests.unit.test_research_system"}
            }
        },
        politics = {
            name = "Politics & Diplomacy",
            tests = {
                {"Karma System", "tests.unit.test_karma_system"}
            }
        },
        widgets = {
            name = "UI Widgets",
            tests = {
                {"BaseWidget", "tests.widgets.test_base_widget"},
                {"Button Widget", "tests.widgets.test_button"}
            }
        },
        maps = {
            name = "Map Generation",
            tests = {
                {"Map Generation", "tests.unit.test_map_generation"}
            }
        },
        tutorial = {
            name = "Tutorial System",
            tests = {
                {"Tutorial System", "tests.unit.test_tutorial_system"}
            }
        },
        ai = {
            name = "AI Systems",
            tests = {
                {"AI Tactical Decision", "tests.unit.test_ai_tactical_decision"}
            }
        },
        performance = {
            name = "Performance Benchmarks",
            tests = {
                {"Game Performance", "tests.performance.test_game_performance"}
            }
        }
    }
}

-- Test results tracking
local results = {
    total = 0,
    passed = 0,
    failed = 0,
    errors = {}
}

-- Mock love.graphics for headless testing
if not love or not love.graphics then
    love = love or {}
    love.graphics = love.graphics or {}
    love.graphics.print = function() end
    love.graphics.setColor = function() end
    love.graphics.rectangle = function() end
    love.graphics.circle = function() end
    love.graphics.line = function() end
    love.graphics.draw = function() end
    love.graphics.newImage = function() return {} end
    love.graphics.newQuad = function() return {} end
    love.graphics.push = function() end
    love.graphics.pop = function() end
    love.graphics.translate = function() end
    love.graphics.scale = function() end
    love.graphics.rotate = function() end
end

-- Helper to run a test module
local function runTest(name, modulePath)
    print("\n" .. string.rep("-", 60))
    print("Running: " .. name)
    print(string.rep("-", 60))
    
    local success, testModule = pcall(require, modulePath)
    
    if not success then
        print("✗ Failed to load test module: " .. name)
        print("  Error: " .. tostring(testModule))
        results.failed = results.failed + 1
        table.insert(results.errors, {name = name, error = testModule})
        return false
    end
    
    if type(testModule.runAll) ~= "function" then
        print("✗ Test module " .. name .. " has no runAll() function")
        results.failed = results.failed + 1
        return false
    end
    
    local testSuccess, testError = pcall(testModule.runAll)
    
    if testSuccess then
        print("✓ " .. name .. " completed successfully")
        results.passed = results.passed + 1
        return true
    else
        print("✗ " .. name .. " failed")
        print("  Error: " .. tostring(testError))
        results.failed = results.failed + 1
        table.insert(results.errors, {name = name, error = testError})
        return false
    end
end

-- Run tests in a category
local function runCategory(categoryKey)
    local category = TestRegistry.categories[categoryKey]
    
    if not category then
        print("Error: Unknown category '" .. categoryKey .. "'")
        return false
    end
    
    print("\n" .. string.rep("=", 60))
    print(category.name)
    print(string.rep("=", 60))
    
    for _, test in ipairs(category.tests) do
        results.total = results.total + 1
        runTest(test[1], test[2])
    end
    
    return true
end

-- Run all tests
local function runAll()
    for categoryKey, category in pairs(TestRegistry.categories) do
        runCategory(categoryKey)
    end
end

-- Print summary
local function printSummary()
    print("\n" .. string.rep("=", 60))
    print("TEST SUMMARY")
    print(string.rep("=", 60))
    print(string.format("Total Tests: %d", results.total))
    print(string.format("Passed:      %d (%.1f%%)", results.passed, 
          results.total > 0 and (results.passed / results.total * 100) or 0))
    print(string.format("Failed:      %d (%.1f%%)", results.failed,
          results.total > 0 and (results.failed / results.total * 100) or 0))
    
    if #results.errors > 0 then
        print("\n" .. string.rep("=", 60))
        print("ERROR DETAILS")
        print(string.rep("=", 60))
        for i, err in ipairs(results.errors) do
            print(string.format("\n%d. %s", i, err.name))
            print("   " .. tostring(err.error))
        end
    end
    
    print("\n" .. string.rep("=", 60))
    
    if results.failed == 0 then
        print("✓ ALL TESTS PASSED!")
    else
        print("✗ SOME TESTS FAILED")
    end
    
    print(string.rep("=", 60) .. "\n")
end

-- Print usage information
local function printUsage()
    print("\n" .. string.rep("=", 60))
    print("SELECTIVE TEST RUNNER - USAGE")
    print(string.rep("=", 60))
    print("\nRun specific test categories or all tests.\n")
    print("Usage:")
    print("  lovec tests/runners/run_selective_tests.lua [category]\n")
    print("Categories:")
    for key, category in pairs(TestRegistry.categories) do
        print(string.format("  %s - %s (%d tests)", key, category.name, #category.tests))
    end
    print("  all       - Run all tests (default)\n")
    print("Examples:")
    print("  lovec tests/runners/run_selective_tests.lua core")
    print("  lovec tests/runners/run_selective_tests.lua combat")
    print("  lovec tests/runners/run_selective_tests.lua all")
    print(string.rep("=", 60) .. "\n")
end

-- Main execution
local function main(args)
    print("\n" .. string.rep("=", 60))
    print("XCOM SIMPLE - SELECTIVE TEST RUNNER")
    print(string.rep("=", 60) .. "\n")
    
    -- Get category from arguments
    local category = args and args[1] or "all"
    
    if category == "help" or category == "--help" or category == "-h" then
        printUsage()
        return 0
    end
    
    -- Run tests
    if category == "all" then
        print("Running ALL tests...")
        runAll()
    else
        if not TestRegistry.categories[category] then
            print("Error: Unknown category '" .. category .. "'")
            printUsage()
            return 1
        end
        print("Running category: " .. TestRegistry.categories[category].name)
        runCategory(category)
    end
    
    -- Print summary
    printSummary()
    
    -- Return exit code
    return results.failed == 0 and 0 or 1
end

-- Run if executed as script
if not love then
    -- Command-line mode
    local exitCode = main(arg)
    os.exit(exitCode)
else
    -- Love2D mode
    local exitCode = main(arg)
    if love.event then
        love.timer.sleep(2)
        love.event.quit(exitCode)
    end
end

-- Export for use as module
return {
    runCategory = runCategory,
    runAll = runAll,
    printUsage = printUsage,
    registry = TestRegistry
}
