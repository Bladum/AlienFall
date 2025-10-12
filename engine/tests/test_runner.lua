-- Comprehensive Test Runner
-- Run all test suites from menu
-- Usage: Click "Run Tests" button in main menu

local PerformanceTests = require("tests.test_performance")
local WidgetTests = require("widgets.tests.test_all_widgets")
local ModSystemTests = require("tests.test_mod_system")
local BattlescapeTests = require("tests.test_battlescape_systems")

local TestRunner = {}

function TestRunner.runAllTests()
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         STARTING COMPREHENSIVE TEST SUITE                ║")
    print("║         Testing: Widgets, Mod System, Battlescape        ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    -- Run Widget Tests
    print("\n[1/4] Running Widget Tests...")
    local success1, err1 = pcall(function()
        WidgetTests.runAll()
    end)
    
    if not success1 then
        print("\n[ERROR] Widget test suite failed:")
        print(err1)
        print(debug.traceback())
    end
    
    -- Run Mod System Tests
    print("\n[2/4] Running Mod System Tests...")
    local success2, err2 = pcall(function()
        ModSystemTests.runAll()
    end)
    
    if not success2 then
        print("\n[ERROR] Mod system test suite failed:")
        print(err2)
        print(debug.traceback())
    end
    
    -- Run Battlescape Tests
    print("\n[3/4] Running Battlescape Tests...")
    local success3, err3 = pcall(function()
        BattlescapeTests.runAll()
    end)
    
    if not success3 then
        print("\n[ERROR] Battlescape test suite failed:")
        print(err3)
        print(debug.traceback())
    end
    
    -- Run Performance Tests
    print("\n[4/4] Running Performance Tests...")
    local success4, err4 = pcall(function()
        PerformanceTests.runAll()
    end)
    
    if not success4 then
        print("\n[ERROR] Performance test suite failed:")
        print(err4)
        print(debug.traceback())
    end
    
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         ALL TEST SUITES COMPLETE                         ║")
    print("╚═══════════════════════════════════════════════════════════╝")
end

-- Run only widget tests
function TestRunner.runWidgetTests()
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         STARTING WIDGET TEST SUITE                       ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local success, err = pcall(function()
        WidgetTests.runAll()
    end)
    
    if not success then
        print("\n[ERROR] Widget test suite failed:")
        print(err)
        print(debug.traceback())
    end
    
    print("\n\n")
end

-- Run only mod system tests
function TestRunner.runModSystemTests()
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         STARTING MOD SYSTEM TEST SUITE                   ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local success, err = pcall(function()
        ModSystemTests.runAll()
    end)
    
    if not success then
        print("\n[ERROR] Mod system test suite failed:")
        print(err)
        print(debug.traceback())
    end
    
    print("\n\n")
end

-- Run only battlescape tests
function TestRunner.runBattlescapeTests()
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         STARTING BATTLESCAPE TEST SUITE                  ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local success, err = pcall(function()
        BattlescapeTests.runAll()
    end)
    
    if not success then
        print("\n[ERROR] Battlescape test suite failed:")
        print(err)
        print(debug.traceback())
    end
    
    print("\n\n")
end

-- Run only performance tests
function TestRunner.runPerformanceTests()
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         STARTING PERFORMANCE TEST SUITE                  ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local success, err = pcall(function()
        PerformanceTests.runAll()
    end)
    
    if not success then
        print("\n[ERROR] Performance test suite failed:")
        print(err)
        print(debug.traceback())
    end
    
    print("\n\n")
end

return TestRunner
