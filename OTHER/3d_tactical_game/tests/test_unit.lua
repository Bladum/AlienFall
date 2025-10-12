--- Test suite for Unit class
--- Tests unit creation, movement, health, actions, and state

local Unit = require("classes.Unit")
local Constants = require("config.constants")

local TestUnit = {}

function TestUnit.testUnitCreation()
    print("Testing Unit creation...")
    
    local unit = Unit.new(5, 10, Constants.TEAM.PLAYER)
    
    assert(unit.gridX == 5, "Unit X position incorrect")
    assert(unit.gridY == 10, "Unit Y position incorrect")
    assert(unit.teamId == Constants.TEAM.PLAYER, "Team ID incorrect")
    assert(unit:isAlive(), "New unit should be alive")
    assert(unit.health > 0, "New unit should have health")
    
    print("  ✓ Unit creation successful")
end

function TestUnit.testHealthSystem()
    print("Testing health system...")
    
    local unit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    local initialHealth = unit.maxHealth
    
    -- Take damage
    unit:takeDamage(20)
    assert(unit.health == initialHealth - 20, "Unit should lose 20 health")
    assert(unit:isAlive(), "Unit should still be alive")
    
    -- Heal
    unit:heal(10)
    assert(unit.health == initialHealth - 10, "Unit should heal 10 health")
    
    -- Cannot heal above max
    unit:heal(100)
    assert(unit.health == initialHealth, "Unit should not exceed max health")
    
    print("  ✓ Health system works correctly")
end

function TestUnit.testDeath()
    print("Testing unit death...")
    
    local unit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    
    -- Kill unit
    unit:takeDamage(unit.maxHealth)
    assert(unit.health == 0, "Dead unit should have 0 health")
    assert(not unit:isAlive(), "Unit should be dead")
    
    -- Cannot heal dead unit
    unit:heal(50)
    assert(unit.health == 0, "Dead unit should stay at 0 health")
    
    print("  ✓ Death system works correctly")
end

function TestUnit.testPosition()
    print("Testing position system...")
    
    local unit = Unit.new(5, 10, Constants.TEAM.PLAYER)
    
    local pos = unit:getPosition()
    assert(pos.x == 5, "Position X incorrect")
    assert(pos.z == 10, "Position Z incorrect")
    assert(pos.y >= 0, "Position Y should be non-negative")
    
    print("  ✓ Position tracking works correctly")
end

function TestUnit.testActionPoints()
    print("Testing action points...")
    
    local unit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    
    if unit.actionPoints then
        local maxAP = unit.maxActionPoints
        
        -- Spend action points
        unit:spendActionPoints(2)
        assert(unit.actionPoints == maxAP - 2, "Should spend 2 action points")
        
        -- Cannot spend more than available
        local before = unit.actionPoints
        unit:spendActionPoints(100)
        assert(unit.actionPoints >= 0, "Action points should not go negative")
        
        -- Restore action points
        unit:restoreActionPoints()
        assert(unit.actionPoints == maxAP, "Should restore to max")
        
        print("  ✓ Action points system works correctly")
    else
        print("  ⚠ Action points not implemented, skipping test")
    end
end

function TestUnit.testTeamAssignment()
    print("Testing team assignment...")
    
    local playerUnit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    local enemyUnit = Unit.new(2, 2, Constants.TEAM.ENEMY)
    local allyUnit = Unit.new(3, 3, Constants.TEAM.ALLY)
    
    assert(playerUnit.teamId == Constants.TEAM.PLAYER, "Player team ID incorrect")
    assert(enemyUnit.teamId == Constants.TEAM.ENEMY, "Enemy team ID incorrect")
    assert(allyUnit.teamId == Constants.TEAM.ALLY, "Ally team ID incorrect")
    
    print("  ✓ Team assignment works correctly")
end

function TestUnit.testUpdate()
    print("Testing unit update...")
    
    local unit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    
    -- Update should not crash
    unit:update(0.016)
    unit:update(1.0)
    unit:update(0.001)
    
    assert(unit:isAlive(), "Unit should still be alive after updates")
    
    print("  ✓ Unit update works correctly")
end

function TestUnit.testLOSRange()
    print("Testing LOS range...")
    
    local unit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    
    assert(unit.losRange, "Unit should have LOS range defined")
    assert(unit.losRange > 0, "LOS range should be positive")
    
    print("  ✓ LOS range is properly initialized")
end

function TestUnit.testMovementSpeed()
    print("Testing movement speed...")
    
    local unit = Unit.new(1, 1, Constants.TEAM.PLAYER)
    
    if unit.moveSpeed then
        assert(unit.moveSpeed > 0, "Move speed should be positive")
        print("  ✓ Movement speed is properly initialized")
    else
        print("  ⚠ Movement speed not implemented, skipping test")
    end
end

function TestUnit.runAll()
    print("\n=== Running Unit Tests ===")
    
    TestUnit.testUnitCreation()
    TestUnit.testHealthSystem()
    TestUnit.testDeath()
    TestUnit.testPosition()
    TestUnit.testActionPoints()
    TestUnit.testTeamAssignment()
    TestUnit.testUpdate()
    TestUnit.testLOSRange()
    TestUnit.testMovementSpeed()
    
    print("=== All Unit Tests Passed ✓ ===\n")
end

return TestUnit
