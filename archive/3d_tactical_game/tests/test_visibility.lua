--- Test suite for VisibilitySystem
--- Tests LOS calculation, team visibility, and fog of war

local VisibilitySystem = require("systems.VisibilitySystem")
local Tile = require("classes.Tile")
local Unit = require("classes.Unit")
local Team = require("classes.Team")
local Constants = require("config.constants")

local TestVisibility = {}

-- Helper function to create a test map
local function createTestMap(width, height, wallPositions)
    local map = {}
    wallPositions = wallPositions or {}
    
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            local isWall = false
            for _, wallPos in ipairs(wallPositions) do
                if wallPos.x == x and wallPos.y == y then
                    isWall = true
                    break
                end
            end
            
            local terrainType = isWall and Constants.TERRAIN.WALL or Constants.TERRAIN.FLOOR
            map[y][x] = Tile.new(x, y, terrainType)
        end
    end
    
    return map
end

function TestVisibility.testLOSClearPath()
    print("Testing LOS with clear path...")
    
    local map = createTestMap(10, 10, {})
    
    -- No obstacles between (1,1) and (5,5)
    local hasLOS, tiles = VisibilitySystem.calculateLOS(map, 1, 1, 5, 5)
    
    assert(hasLOS == true, "Clear path should have LOS")
    assert(tiles and #tiles > 0, "Should return tiles along path")
    
    print("  ✓ LOS clear path works")
end

function TestVisibility.testLOSBlocked()
    print("Testing LOS blocked by wall...")
    
    -- Create map with wall at (3,3)
    local map = createTestMap(10, 10, {{x=3, y=3}})
    
    -- Wall blocks LOS from (1,1) to (5,5)
    local hasLOS = VisibilitySystem.calculateLOS(map, 1, 1, 5, 5)
    
    assert(hasLOS == false, "Wall should block LOS")
    
    print("  ✓ LOS blocked by wall works")
end

function TestVisibility.testLOSHorizontal()
    print("Testing LOS horizontal...")
    
    local map = createTestMap(10, 10, {})
    
    local hasLOS = VisibilitySystem.calculateLOS(map, 1, 5, 10, 5)
    
    assert(hasLOS == true, "Horizontal LOS should work")
    
    print("  ✓ LOS horizontal works")
end

function TestVisibility.testLOSVertical()
    print("Testing LOS vertical...")
    
    local map = createTestMap(10, 10, {})
    
    local hasLOS = VisibilitySystem.calculateLOS(map, 5, 1, 5, 10)
    
    assert(hasLOS == true, "Vertical LOS should work")
    
    print("  ✓ LOS vertical works")
end

function TestVisibility.testLOSSamePoint()
    print("Testing LOS to same point...")
    
    local map = createTestMap(10, 10, {})
    
    local hasLOS = VisibilitySystem.calculateLOS(map, 5, 5, 5, 5)
    
    assert(hasLOS == true, "Same point should have LOS")
    
    print("  ✓ LOS to same point works")
end

function TestVisibility.testUnitVisibility()
    print("Testing unit visibility...")
    
    local map = createTestMap(20, 20, {})
    local unit = Unit.new(10, 10, Constants.TEAM.PLAYER)
    
    local visibleCount = VisibilitySystem.calculateUnitVisibility(unit, map, 20, 20)
    
    assert(visibleCount > 0, "Unit should see at least some tiles")
    
    -- Check that unit's own tile is visible
    local unitTile = map[unit.gridY][unit.gridX]
    assert(unitTile:getVisibility(unit.teamId) == Constants.VISIBILITY.VISIBLE,
           "Unit should see its own tile")
    
    print("  ✓ Unit visibility calculation works")
end

function TestVisibility.testTeamVisibility()
    print("Testing team visibility...")
    
    local map = createTestMap(30, 30, {})
    local team = Team.new(Constants.TEAM.PLAYER, "Test Team")
    
    local unit1 = Unit.new(5, 5, Constants.TEAM.PLAYER)
    local unit2 = Unit.new(25, 25, Constants.TEAM.PLAYER)
    
    team:addUnit(unit1)
    team:addUnit(unit2)
    
    local visibleCount = VisibilitySystem.calculateTeamVisibility(team, map, 30, 30)
    
    assert(visibleCount > 0, "Team should see tiles")
    
    print("  ✓ Team visibility calculation works")
end

function TestVisibility.testVisibilityStates()
    print("Testing visibility states...")
    
    local map = createTestMap(20, 20, {})
    local unit = Unit.new(10, 10, Constants.TEAM.PLAYER)
    
    -- Calculate visibility
    VisibilitySystem.calculateUnitVisibility(unit, map, 20, 20)
    
    -- Tiles near unit should be VISIBLE
    local nearTile = map[10][11]
    assert(nearTile:getVisibility(Constants.TEAM.PLAYER) == Constants.VISIBILITY.VISIBLE,
           "Near tile should be VISIBLE")
    
    -- Tiles far from unit should be HIDDEN
    local farTile = map[1][1]
    assert(farTile:getVisibility(Constants.TEAM.PLAYER) == Constants.VISIBILITY.HIDDEN,
           "Far tile should be HIDDEN")
    
    print("  ✓ Visibility states work correctly")
end

function TestVisibility.testBrightness()
    print("Testing brightness calculation...")
    
    local tile = Tile.new(5, 5, Constants.TERRAIN.FLOOR)
    
    tile:setVisibility(Constants.TEAM.PLAYER, Constants.VISIBILITY.HIDDEN)
    local hiddenBrightness = VisibilitySystem.getBrightness(tile, Constants.TEAM.PLAYER)
    assert(hiddenBrightness == 0.0, "Hidden tile should have 0 brightness")
    
    tile:setVisibility(Constants.TEAM.PLAYER, Constants.VISIBILITY.EXPLORED)
    local exploredBrightness = VisibilitySystem.getBrightness(tile, Constants.TEAM.PLAYER)
    assert(exploredBrightness > 0 and exploredBrightness < 1, 
           "Explored tile should have dim brightness")
    
    tile:setVisibility(Constants.TEAM.PLAYER, Constants.VISIBILITY.VISIBLE)
    local visibleBrightness = VisibilitySystem.getBrightness(tile, Constants.TEAM.PLAYER)
    assert(visibleBrightness == 1.0, "Visible tile should have full brightness")
    
    print("  ✓ Brightness calculation works")
end

function TestVisibility.testIsVisibleToTeam()
    print("Testing isVisibleToTeam...")
    
    local map = createTestMap(10, 10, {})
    local tile = map[5][5]
    
    tile:setVisibility(Constants.TEAM.PLAYER, Constants.VISIBILITY.VISIBLE)
    
    assert(VisibilitySystem.isVisibleToTeam(map, 5, 5, Constants.TEAM.PLAYER),
           "Tile should be visible to player team")
    assert(not VisibilitySystem.isVisibleToTeam(map, 5, 5, Constants.TEAM.ENEMY),
           "Tile should not be visible to enemy team")
    
    print("  ✓ isVisibleToTeam works correctly")
end

function TestVisibility.testCanSeeUnit()
    print("Testing canSeeUnit...")
    
    local map = createTestMap(20, 20, {})
    
    local observer = Unit.new(5, 5, Constants.TEAM.PLAYER)
    local target = Unit.new(8, 8, Constants.TEAM.ENEMY)
    
    -- Target is close and no obstacles
    local canSee = VisibilitySystem.canSeeUnit(observer, target, map)
    assert(canSee == true, "Observer should see nearby target")
    
    -- Target very far away (out of range)
    local farTarget = Unit.new(50, 50, Constants.TEAM.ENEMY)
    canSee = VisibilitySystem.canSeeUnit(observer, farTarget, map)
    assert(canSee == false, "Observer should not see far target")
    
    print("  ✓ canSeeUnit works correctly")
end

function TestVisibility.testUpdateAllTeams()
    print("Testing updateAllTeams...")
    
    local map = createTestMap(20, 20, {})
    local teams = {}
    
    teams[Constants.TEAM.PLAYER] = Team.new(Constants.TEAM.PLAYER, "Players")
    teams[Constants.TEAM.ENEMY] = Team.new(Constants.TEAM.ENEMY, "Enemies")
    
    teams[Constants.TEAM.PLAYER]:addUnit(Unit.new(5, 5, Constants.TEAM.PLAYER))
    teams[Constants.TEAM.ENEMY]:addUnit(Unit.new(15, 15, Constants.TEAM.ENEMY))
    
    -- Should not crash
    VisibilitySystem.updateAllTeams(teams, map, 20, 20, true)
    
    print("  ✓ updateAllTeams works correctly")
end

function TestVisibility.testLOSRange()
    print("Testing LOS range limits...")
    
    local map = createTestMap(50, 50, {})
    local unit = Unit.new(25, 25, Constants.TEAM.PLAYER)
    
    VisibilitySystem.calculateUnitVisibility(unit, map, 50, 50)
    
    -- Tile right at unit position should be visible
    assert(map[25][25]:getVisibility(Constants.TEAM.PLAYER) == Constants.VISIBILITY.VISIBLE,
           "Unit's tile should be visible")
    
    -- Tile far beyond LOS range should not be visible
    local farTile = map[1][1]
    assert(farTile:getVisibility(Constants.TEAM.PLAYER) == Constants.VISIBILITY.HIDDEN,
           "Far tile should be hidden")
    
    print("  ✓ LOS range limits work correctly")
end

function TestVisibility.runAll()
    print("\n=== Running Visibility System Tests ===")
    
    TestVisibility.testLOSClearPath()
    TestVisibility.testLOSBlocked()
    TestVisibility.testLOSHorizontal()
    TestVisibility.testLOSVertical()
    TestVisibility.testLOSSamePoint()
    TestVisibility.testUnitVisibility()
    TestVisibility.testTeamVisibility()
    TestVisibility.testVisibilityStates()
    TestVisibility.testBrightness()
    TestVisibility.testIsVisibleToTeam()
    TestVisibility.testCanSeeUnit()
    TestVisibility.testUpdateAllTeams()
    TestVisibility.testLOSRange()
    
    print("=== All Visibility System Tests Passed ✓ ===\n")
end

return TestVisibility






















