--[[
    Battlescape System Test Suite
    
    Tests tactical battle systems
    Tests: Unit management, pathfinding, LOS, action system
]]

local TestFramework = require("widgets.tests.widget_test_framework")

local BattlescapeTests = {}

--[[
    Test Unit System
]]
function BattlescapeTests.testUnitSystem()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING UNIT SYSTEM                              ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local Unit = require("systems.unit")
    
    TestFramework.runTest("Unit - Create unit", function()
        TestFramework.assertNotNil(Unit, "Unit system not loaded")
        TestFramework.assertNotNil(Unit.new, "Unit.new missing")
    end)
    
    TestFramework.runTest("Unit - Unit properties", function()
        local unit = Unit.new("Soldier", 1, 10, 10)
        TestFramework.assertNotNil(unit, "Failed to create unit")
        TestFramework.assertEqual(unit.name, "Soldier", "Unit name incorrect")
        TestFramework.assertEqual(unit.team, 1, "Unit team incorrect")
    end)
end

--[[
    Test Team System
]]
function BattlescapeTests.testTeamSystem()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING TEAM SYSTEM                              ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local Team = require("systems.team")
    
    TestFramework.runTest("Team - Create team", function()
        TestFramework.assertNotNil(Team, "Team system not loaded")
        TestFramework.assertNotNil(Team.new, "Team.new missing")
    end)
    
    TestFramework.runTest("Team - Team properties", function()
        local team = Team.new(1, "Player")
        TestFramework.assertNotNil(team, "Failed to create team")
        TestFramework.assertEqual(team.id, 1, "Team id incorrect")
        TestFramework.assertEqual(team.name, "Player", "Team name incorrect")
    end)
end

--[[
    Test Pathfinding System
]]
function BattlescapeTests.testPathfinding()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING PATHFINDING SYSTEM                       ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local Pathfinding = require("systems.pathfinding")
    
    TestFramework.runTest("Pathfinding - System loaded", function()
        TestFramework.assertNotNil(Pathfinding, "Pathfinding system not loaded")
        TestFramework.assertNotNil(Pathfinding.findPath, "Pathfinding.findPath missing")
    end)
    
    TestFramework.runTest("Pathfinding - Find simple path", function()
        -- Create simple 10x10 grid
        local grid = {}
        for y = 1, 10 do
            grid[y] = {}
            for x = 1, 10 do
                grid[y][x] = 0  -- walkable
            end
        end
        
        local path = Pathfinding.findPath(grid, 1, 1, 5, 5)
        TestFramework.assertNotNil(path, "Failed to find path")
        TestFramework.assert(#path > 0, "Path is empty")
    end)
end

--[[
    Test LOS System
]]
function BattlescapeTests.testLOS()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING LINE-OF-SIGHT SYSTEM                     ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local LOS = require("systems.los_optimized")
    
    TestFramework.runTest("LOS - System loaded", function()
        TestFramework.assertNotNil(LOS, "LOS system not loaded")
        TestFramework.assertNotNil(LOS.hasLineOfSight, "LOS.hasLineOfSight missing")
    end)
    
    TestFramework.runTest("LOS - Direct line of sight", function()
        -- Create simple 10x10 grid with no obstacles
        local grid = {}
        for y = 1, 10 do
            grid[y] = {}
            for x = 1, 10 do
                grid[y][x] = {blocksLOS = false}
            end
        end
        
        local hasLOS = LOS.hasLineOfSight(grid, 1, 1, 5, 5)
        TestFramework.assert(hasLOS, "Failed to detect direct LOS")
    end)
end

--[[
    Test Action System
]]
function BattlescapeTests.testActionSystem()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING ACTION SYSTEM                            ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local ActionSystem = require("systems.action_system")
    
    TestFramework.runTest("ActionSystem - System loaded", function()
        TestFramework.assertNotNil(ActionSystem, "ActionSystem not loaded")
    end)
    
    TestFramework.runTest("ActionSystem - Has action types", function()
        TestFramework.assertNotNil(ActionSystem.ACTION_TYPES, "ACTION_TYPES missing")
    end)
end

--[[
    Test Battle Tile System
]]
function BattlescapeTests.testBattleTile()
    print("\n╔═══════════════════════════════════════════════════════════╗")
    print("║         TESTING BATTLE TILE SYSTEM                       ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    local BattleTile = require("systems.battle_tile")
    
    TestFramework.runTest("BattleTile - Create tile", function()
        TestFramework.assertNotNil(BattleTile, "BattleTile system not loaded")
        TestFramework.assertNotNil(BattleTile.new, "BattleTile.new missing")
    end)
    
    TestFramework.runTest("BattleTile - Tile properties", function()
        local tile = BattleTile.new(1, 1, "floor")
        TestFramework.assertNotNil(tile, "Failed to create tile")
        TestFramework.assertEqual(tile.x, 1, "Tile x incorrect")
        TestFramework.assertEqual(tile.y, 1, "Tile y incorrect")
    end)
end

--[[
    Run all battlescape tests
]]
function BattlescapeTests.runAll()
    print("\n\n")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║         BATTLESCAPE SYSTEM TEST SUITE                    ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    
    TestFramework.reset()
    
    local success1, err1 = pcall(BattlescapeTests.testUnitSystem)
    if not success1 then
        print("\n[ERROR] Unit system tests failed:")
        print(err1)
    end
    
    local success2, err2 = pcall(BattlescapeTests.testTeamSystem)
    if not success2 then
        print("\n[ERROR] Team system tests failed:")
        print(err2)
    end
    
    local success3, err3 = pcall(BattlescapeTests.testPathfinding)
    if not success3 then
        print("\n[ERROR] Pathfinding tests failed:")
        print(err3)
    end
    
    local success4, err4 = pcall(BattlescapeTests.testLOS)
    if not success4 then
        print("\n[ERROR] LOS tests failed:")
        print(err4)
    end
    
    local success5, err5 = pcall(BattlescapeTests.testActionSystem)
    if not success5 then
        print("\n[ERROR] Action system tests failed:")
        print(err5)
    end
    
    local success6, err6 = pcall(BattlescapeTests.testBattleTile)
    if not success6 then
        print("\n[ERROR] Battle tile tests failed:")
        print(err6)
    end
    
    TestFramework.printSummary()
    
    return TestFramework.results
end

return BattlescapeTests
