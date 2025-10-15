--- Test suite for Team class
--- Tests team creation, unit management, and team operations

local Team = require("classes.Team")
local Unit = require("classes.Unit")
local Constants = require("config.constants")

local TestTeam = {}

function TestTeam.testTeamCreation()
    print("Testing Team creation...")
    
    local team = Team.new(Constants.TEAM.PLAYER, "Test Team")
    
    assert(team.id == Constants.TEAM.PLAYER, "Team ID incorrect")
    assert(team.name == "Test Team", "Team name incorrect")
    assert(team:getUnitCount() == 0, "New team should have no units")
    
    print("  ✓ Team creation successful")
end

function TestTeam.testAddUnit()
    print("Testing add unit...")
    
    local team = Team.new(Constants.TEAM.PLAYER, "Test Team")
    local unit1 = Unit.new(1, 1, Constants.TEAM.PLAYER)
    local unit2 = Unit.new(2, 2, Constants.TEAM.PLAYER)
    
    team:addUnit(unit1)
    assert(team:getUnitCount() == 1, "Should have 1 unit")
    
    team:addUnit(unit2)
    assert(team:getUnitCount() == 2, "Should have 2 units")
    
    print("  ✓ Add unit works correctly")
end

function TestTeam.testRemoveUnit()
    print("Testing remove unit...")
    
    local team = Team.new(Constants.TEAM.PLAYER, "Test Team")
    local unit1 = Unit.new(1, 1, Constants.TEAM.PLAYER)
    local unit2 = Unit.new(2, 2, Constants.TEAM.PLAYER)
    
    team:addUnit(unit1)
    team:addUnit(unit2)
    assert(team:getUnitCount() == 2, "Should have 2 units")
    
    team:removeUnit(unit1)
    assert(team:getUnitCount() == 1, "Should have 1 unit after removal")
    
    team:removeUnit(unit2)
    assert(team:getUnitCount() == 0, "Should have 0 units after removing all")
    
    print("  ✓ Remove unit works correctly")
end

function TestTeam.testGetUnits()
    print("Testing get units...")
    
    local team = Team.new(Constants.TEAM.PLAYER, "Test Team")
    local unit1 = Unit.new(1, 1, Constants.TEAM.PLAYER)
    local unit2 = Unit.new(2, 2, Constants.TEAM.PLAYER)
    
    team:addUnit(unit1)
    team:addUnit(unit2)
    
    local units = team:getUnits()
    assert(#units == 2, "Should return 2 units")
    assert(units[1] == unit1 or units[2] == unit1, "Should contain unit1")
    assert(units[1] == unit2 or units[2] == unit2, "Should contain unit2")
    
    print("  ✓ Get units works correctly")
end

function TestTeam.testGetAliveUnits()
    print("Testing get alive units...")
    
    local team = Team.new(Constants.TEAM.PLAYER, "Test Team")
    local unit1 = Unit.new(1, 1, Constants.TEAM.PLAYER)
    local unit2 = Unit.new(2, 2, Constants.TEAM.PLAYER)
    local unit3 = Unit.new(3, 3, Constants.TEAM.PLAYER)
    
    team:addUnit(unit1)
    team:addUnit(unit2)
    team:addUnit(unit3)
    
    -- Kill unit2
    unit2:takeDamage(unit2.maxHealth)
    
    local aliveUnits = team:getAliveUnits()
    assert(#aliveUnits == 2, "Should have 2 alive units")
    
    for _, unit in ipairs(aliveUnits) do
        assert(unit:isAlive(), "All returned units should be alive")
    end
    
    print("  ✓ Get alive units works correctly")
end

function TestTeam.testTeamColor()
    print("Testing team color...")
    
    local team = Team.new(Constants.TEAM.PLAYER, "Test Team")
    
    assert(team.color, "Team should have a color")
    assert(#team.color == 4, "Color should have RGBA components")
    
    for i = 1, 4 do
        assert(team.color[i] >= 0 and team.color[i] <= 1, 
               "Color component should be between 0 and 1")
    end
    
    print("  ✓ Team color is properly initialized")
end

function TestTeam.testTeamUpdate()
    print("Testing team update...")
    
    local team = Team.new(Constants.TEAM.PLAYER, "Test Team")
    local unit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    team:addUnit(unit)
    
    -- Update should not crash
    team:update(0.016)
    team:update(1.0)
    
    assert(unit:isAlive(), "Unit should still be alive after updates")
    
    print("  ✓ Team update works correctly")
end

function TestTeam.testMultipleTeams()
    print("Testing multiple teams...")
    
    local playerTeam = Team.new(Constants.TEAM.PLAYER, "Players")
    local enemyTeam = Team.new(Constants.TEAM.ENEMY, "Enemies")
    
    local playerUnit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    local enemyUnit = Unit.new(10, 10, Constants.TEAM.ENEMY)
    
    playerTeam:addUnit(playerUnit)
    enemyTeam:addUnit(enemyUnit)
    
    assert(playerTeam:getUnitCount() == 1, "Player team should have 1 unit")
    assert(enemyTeam:getUnitCount() == 1, "Enemy team should have 1 unit")
    assert(playerTeam.id ~= enemyTeam.id, "Teams should have different IDs")
    
    print("  ✓ Multiple teams work correctly")
end

function TestTeam.testEmptyTeam()
    print("Testing empty team...")
    
    local team = Team.new(Constants.TEAM.NEUTRAL, "Empty")
    
    assert(team:getUnitCount() == 0, "Empty team should have 0 units")
    assert(#team:getUnits() == 0, "getUnits should return empty table")
    assert(#team:getAliveUnits() == 0, "getAliveUnits should return empty table")
    
    team:update(0.016)  -- Should not crash
    
    print("  ✓ Empty team works correctly")
end

function TestTeam.runAll()
    print("\n=== Running Team Tests ===")
    
    TestTeam.testTeamCreation()
    TestTeam.testAddUnit()
    TestTeam.testRemoveUnit()
    TestTeam.testGetUnits()
    TestTeam.testGetAliveUnits()
    TestTeam.testTeamColor()
    TestTeam.testTeamUpdate()
    TestTeam.testMultipleTeams()
    TestTeam.testEmptyTeam()
    
    print("=== All Team Tests Passed ✓ ===\n")
end

return TestTeam






















