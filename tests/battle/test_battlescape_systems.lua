--[[
    Battlescape System Test Suite
    
    Tests tactical battle systems
    Tests: Unit management, pathfinding, LOS, action system
]]

local TestFramework = require("tests.widgets.widget_test_framework")

local BattlescapeTests = {}

--[[
    Test Unit System
]]
function BattlescapeTests.testUnitSystem()
    print("\n-===========================================================¬")
    print("¦         TESTING UNIT SYSTEM                              ¦")
    print("L===========================================================-")
    
    local Unit = require("battlescape.combat.unit")
    
    TestFramework.runTest("Unit - Create unit", function()
        TestFramework.assertNotNil(Unit, "Unit system not loaded")
        TestFramework.assertNotNil(Unit.new, "Unit.new missing")
    end)
    
    TestFramework.runTest("Unit - Unit properties", function()
        local unit = Unit.new("soldier", 1, 10, 10)
        TestFramework.assertNotNil(unit, "Failed to create unit")
        TestFramework.assertEqual(unit.name, "Soldier", "Unit name incorrect")
        TestFramework.assertEqual(unit.team, 1, "Unit team incorrect")
    end)
end

--[[
    Test Team System
]]
function BattlescapeTests.testTeamSystem()
    print("\n-===========================================================¬")
    print("¦         TESTING TEAM SYSTEM                              ¦")
    print("L===========================================================-")
    
    local Team = require("shared.team")
    
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
    print("\n-===========================================================¬")
    print("¦         TESTING PATHFINDING SYSTEM                       ¦")
    print("L===========================================================-")
    
    local Pathfinding = require("shared.pathfinding")
    
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
        -- Check start and end points
        if path and #path > 0 then
            TestFramework.assertEqual(path[1].x, 1, "Path start X incorrect")
            TestFramework.assertEqual(path[1].y, 1, "Path start Y incorrect")
            TestFramework.assertEqual(path[#path].x, 5, "Path end X incorrect")
            TestFramework.assertEqual(path[#path].y, 5, "Path end Y incorrect")
        end
    end)
    
    TestFramework.runTest("Pathfinding - Blocked path", function()
        -- Create grid with obstacle
        local grid = {}
        for y = 1, 10 do
            grid[y] = {}
            for x = 1, 10 do
                grid[y][x] = 0  -- walkable
            end
        end
        -- Add obstacle
        grid[3][3] = 1  -- blocked
        
        local path = Pathfinding.findPath(grid, 1, 1, 5, 5)
        TestFramework.assertNotNil(path, "Failed to find path around obstacle")
    end)
    
    TestFramework.runTest("Pathfinding - No path available", function()
        -- Create grid completely blocked
        local grid = {}
        for y = 1, 10 do
            grid[y] = {}
            for x = 1, 10 do
                grid[y][x] = 1  -- blocked
            end
        end
        
        local path = Pathfinding.findPath(grid, 1, 1, 5, 5)
        TestFramework.assertNil(path, "Should not find path in blocked grid")
    end)
end

--[[
    Test LOS System
]]
function BattlescapeTests.testLOS()
    print("\n-===========================================================¬")
    print("¦         TESTING LINE-OF-SIGHT SYSTEM                     ¦")
    print("L===========================================================-")
    
    local LOS = require("battlescape.combat.los_optimized")
    
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
    
    TestFramework.runTest("LOS - Blocked by obstacle", function()
        -- Create grid with obstacle
        local grid = {}
        for y = 1, 10 do
            grid[y] = {}
            for x = 1, 10 do
                grid[y][x] = {blocksLOS = false}
            end
        end
        grid[3][3] = {blocksLOS = true}  -- obstacle
        
        local hasLOS = LOS.hasLineOfSight(grid, 1, 1, 5, 5)
        TestFramework.assert(not hasLOS, "Should not have LOS through obstacle")
    end)
    
    TestFramework.runTest("LOS - Same position", function()
        local grid = {{ {blocksLOS = false} }}
        local hasLOS = LOS.hasLineOfSight(grid, 1, 1, 1, 1)
        TestFramework.assert(hasLOS, "Should have LOS to same position")
    end)
end

--[[
    Test Battlefield System
]]
function BattlescapeTests.testBattlefield()
    print("\n-===========================================================¬")
    print("¦         TESTING BATTLEFIELD SYSTEM                       ¦")
    print("L===========================================================-")
    
    local Battlefield = require("battlescape.logic.battlefield")
    
    TestFramework.runTest("Battlefield - Create battlefield", function()
        TestFramework.assertNotNil(Battlefield, "Battlefield system not loaded")
        TestFramework.assertNotNil(Battlefield.new, "Battlefield.new missing")
    end)
    
    TestFramework.runTest("Battlefield - Initialize with size", function()
        local battlefield = Battlefield.new(20, 20)
        TestFramework.assertNotNil(battlefield, "Failed to create battlefield")
        TestFramework.assertEqual(battlefield.width, 20, "Battlefield width incorrect")
        TestFramework.assertEqual(battlefield.height, 20, "Battlefield height incorrect")
    end)
    
    TestFramework.runTest("Battlefield - Coordinate validation", function()
        local battlefield = Battlefield.new(10, 10)
        TestFramework.assert(battlefield:isValidCoordinate(5, 5), "Valid coordinate rejected")
        TestFramework.assert(not battlefield:isValidCoordinate(15, 5), "Invalid X coordinate accepted")
        TestFramework.assert(not battlefield:isValidCoordinate(5, 15), "Invalid Y coordinate accepted")
        TestFramework.assert(not battlefield:isValidCoordinate(0, 5), "Zero X coordinate accepted")
        TestFramework.assert(not battlefield:isValidCoordinate(5, 0), "Zero Y coordinate accepted")
    end)
end

--[[
    Test Coordinate Conversion
]]
function BattlescapeTests.testCoordinateConversion()
    print("\n-===========================================================¬")
    print("¦         TESTING COORDINATE CONVERSION                    ¦")
    print("L===========================================================-")
    
    -- Test pixel to grid conversion
    TestFramework.runTest("Coordinate - Pixel to grid", function()
        local gridX, gridY = math.floor(120 / 24) + 1, math.floor(72 / 24) + 1
        TestFramework.assertEqual(gridX, 6, "Pixel to grid X conversion failed")
        TestFramework.assertEqual(gridY, 4, "Pixel to grid Y conversion failed")
    end)
    
    TestFramework.runTest("Coordinate - Grid to pixel", function()
        local pixelX, pixelY = (5 - 1) * 24, (3 - 1) * 24
        TestFramework.assertEqual(pixelX, 96, "Grid to pixel X conversion failed")
        TestFramework.assertEqual(pixelY, 48, "Grid to pixel Y conversion failed")
    end)
end

--[[
    Test Action System
]]
function BattlescapeTests.testActionSystem()
    print("\n-===========================================================¬")
    print("¦         TESTING ACTION SYSTEM                            ¦")
    print("L===========================================================-")
    
    local ActionSystem = require("battlescape.combat.action_system")
    local Unit = require("battlescape.combat.unit")
    
    TestFramework.runTest("Action System - Create system", function()
        TestFramework.assertNotNil(ActionSystem, "Action System not loaded")
        TestFramework.assertNotNil(ActionSystem.new, "ActionSystem.new missing")
    end)
    
    TestFramework.runTest("Action System - Initialize", function()
        local actionSystem = ActionSystem.new()
        TestFramework.assertNotNil(actionSystem, "Failed to create action system")
    end)
    
    TestFramework.runTest("Action System - Reset unit", function()
        local actionSystem = ActionSystem.new()
        local unit = Unit.new("TestUnit", 1, 1, 1)
        actionSystem:resetUnit(unit)
        TestFramework.assertNotNil(unit.actionPointsLeft, "AP not set")
        TestFramework.assertEqual(unit.actionPointsLeft, ActionSystem.AP_PER_TURN, "AP not reset correctly")
        TestFramework.assertNotNil(unit.movementPoints, "MP not set")
        TestFramework.assertEqual(unit.hasActed, false, "hasActed not reset")
    end)
    
    TestFramework.runTest("Action System - Spend AP", function()
        local actionSystem = ActionSystem.new()
        local unit = Unit.new("TestUnit", 1, 1, 1)
        actionSystem:resetUnit(unit)
        
        local success = actionSystem:spendAP(unit, 2)
        TestFramework.assert(success, "Failed to spend AP")
        TestFramework.assertNotNil(unit.actionPointsLeft, "AP not set after spending")
        TestFramework.assertEqual(unit.actionPointsLeft, ActionSystem.AP_PER_TURN - 2, "AP not spent correctly")
    end)
    
    TestFramework.runTest("Action System - Cannot spend more AP than available", function()
        local actionSystem = ActionSystem.new()
        local unit = Unit.new("TestUnit", 1, 1, 1)
        actionSystem:resetUnit(unit)
        TestFramework.assertNotNil(unit.actionPointsLeft, "AP not set")
        local initialAP = unit.actionPointsLeft
        
        local success = actionSystem:spendAP(unit, ActionSystem.AP_PER_TURN + 1)
        TestFramework.assert(not success, "Should not be able to spend more AP than available")
        TestFramework.assertEqual(unit.actionPointsLeft, initialAP, "AP should not change when spending fails")
    end)
    
    TestFramework.runTest("Action System - Spend MP", function()
        local actionSystem = ActionSystem.new()
        local unit = Unit.new("TestUnit", 1, 1, 1)
        actionSystem:resetUnit(unit)
        TestFramework.assertNotNil(unit.movementPoints, "MP not set")
        local initialMP = unit.movementPoints
        
        local success = actionSystem:spendMP(unit, 2)
        TestFramework.assert(success, "Failed to spend MP")
        TestFramework.assertNotNil(unit.movementPoints, "MP not set after spending")
        TestFramework.assertEqual(unit.movementPoints, initialMP - 2, "MP not spent correctly")
    end)
    
    TestFramework.runTest("Action System - Cannot spend more MP than available", function()
        local actionSystem = ActionSystem.new()
        local unit = Unit.new("TestUnit", 1, 1, 1)
        actionSystem:resetUnit(unit)
        TestFramework.assertNotNil(unit.movementPoints, "MP not set")
        local initialMP = unit.movementPoints
        
        local success = actionSystem:spendMP(unit, initialMP + 1)
        TestFramework.assert(not success, "Should not be able to spend more MP than available")
        TestFramework.assertEqual(unit.movementPoints, initialMP, "MP should not change when spending fails")
    end)
    
    TestFramework.runTest("Action System - Can spend AP check", function()
        local actionSystem = ActionSystem.new()
        local unit = Unit.new("TestUnit", 1, 1, 1)
        actionSystem:resetUnit(unit)
        
        TestFramework.assert(actionSystem:canSpendAP(unit, 2), "Should be able to spend 2 AP")
        TestFramework.assert(not actionSystem:canSpendAP(unit, ActionSystem.AP_PER_TURN + 1), "Should not be able to spend more AP than available")
    end)
    
    TestFramework.runTest("Action System - Can spend MP check", function()
        local actionSystem = ActionSystem.new()
        local unit = Unit.new("TestUnit", 1, 1, 1)
        actionSystem:resetUnit(unit)
        TestFramework.assertNotNil(unit.movementPoints, "MP not set")
        local initialMP = unit.movementPoints
        
        TestFramework.assert(actionSystem:canSpendMP(unit, 2), "Should be able to spend 2 MP")
        TestFramework.assert(not actionSystem:canSpendMP(unit, initialMP + 1), "Should not be able to spend more MP than available")
    end)
end

--[[
    Test Battle Tile System
]]
function BattlescapeTests.testBattleTile()
    print("\n-===========================================================¬")
    print("¦         TESTING BATTLE TILE SYSTEM                       ¦")
    print("L===========================================================-")
    
    local BattleTile = require("battlescape.combat.battle_tile")
    
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
    print("-===========================================================¬")
    print("¦         BATTLESCAPE SYSTEM TEST SUITE                    ¦")
    print("L===========================================================-")
    
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






















