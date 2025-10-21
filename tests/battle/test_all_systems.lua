-- test_all_systems.lua
-- Comprehensive test suite for all battle systems
-- Run from project root: lovec engine/systems/battle/tests

-- Add path for requires
package.path = package.path .. ";../engine/?.lua;../engine/?/init.lua"

-- Load all modules
local HexMath = require("battlescape.battle.utils.hex_math")
local Debug = require("battlescape.battle.utils.debug")
local HexSystem = require("battlescape.battle.systems.hex_system")
local MovementSystem = require("battlescape.battle.systems.movement_system")
local VisionSystem = require("battlescape.battle.systems.vision_system")
local UnitEntity = require("battlescape.battle.entities.unit_entity")

print("=" ..string.rep("=", 60))
print("COMPREHENSIVE BATTLE SYSTEM TEST SUITE")
print("=" .. string.rep("=", 60))

local testsRun = 0
local testsPassed = 0
local testsFailed = 0

local function test(name, fn)
    testsRun = testsRun + 1
    io.write(string.format("[%d] Testing %s... ", testsRun, name))
    local success, err = pcall(fn)
    if success then
        print("✓ PASS")
        testsPassed = testsPassed + 1
    else
        print("✗ FAIL: " .. tostring(err))
        testsFailed = testsFailed + 1
    end
end

-- ========================================
-- HEX SYSTEM TESTS
-- ========================================
print("\n[HexSystem] Testing hex grid management...")

test("HexSystem creation", function()
    local hexSys = HexSystem.new(20, 20, 24)
    assert(hexSys.width == 20, "Width should be 20")
    assert(hexSys.height == 20, "Height should be 20")
    assert(hexSys.hexSize == 24, "Hex size should be 24")
end)

test("HexSystem tile access", function()
    local hexSys = HexSystem.new(10, 10)
    local q, r = HexMath.offsetToAxial(5, 5)
    local tile = HexSystem.getTile(hexSys, q, r)
    assert(tile ~= nil, "Should find tile")
    assert(tile.q == q, "Tile q should match")
    assert(tile.r == r, "Tile r should match")
end)

test("HexSystem bounds checking", function()
    local hexSys = HexSystem.new(10, 10)
    assert(HexSystem.isValidHex(hexSys, 0, 0), "Origin should be valid")
    local q, r = HexMath.offsetToAxial(9, 9)
    assert(HexSystem.isValidHex(hexSys, q, r), "Edge should be valid")
    assert(not HexSystem.isValidHex(hexSys, -100, -100), "Far negative should be invalid")
end)

test("HexSystem neighbor validation", function()
    local hexSys = HexSystem.new(10, 10)
    local neighbors = HexSystem.getValidNeighbors(hexSys, 5, 5)
    assert(#neighbors <= 6, "Should have at most 6 neighbors")
    assert(#neighbors > 0, "Should have at least 1 neighbor")
end)

test("HexSystem unit management", function()
    local hexSys = HexSystem.new(10, 10)
    local unit = UnitEntity.new({q = 5, r = 5})
    HexSystem.addUnit(hexSys, "test1", unit)
    assert(hexSys.units["test1"] ~= nil, "Should find added unit")
    local foundUnit = HexSystem.getUnitAt(hexSys, 5, 5)
    assert(foundUnit == unit, "Should find unit at position")
    HexSystem.removeUnit(hexSys, "test1")
    assert(hexSys.units["test1"] == nil, "Should remove unit")
end)

-- ========================================
-- MOVEMENT SYSTEM TESTS
-- ========================================
print("\n[MovementSystem] Testing movement logic...")

test("MovementSystem cost calculation", function()
    local hexSys = HexSystem.new(10, 10)
    local cost = MovementSystem.getMovementCost(hexSys, 0, 0, 1, 0)
    assert(cost == 2, "Movement cost should be 2 AP")
end)

test("MovementSystem rotation cost", function()
    local cost = MovementSystem.getRotationCost(0, 3)  -- East to West
    assert(cost == 3, "180° rotation should cost 3 AP")
    cost = MovementSystem.getRotationCost(0, 1)  -- East to NE
    assert(cost == 1, "60° rotation should cost 1 AP")
end)

test("MovementSystem unit movement", function()
    local hexSys = HexSystem.new(10, 10)
    local unit = UnitEntity.new({q = 5, r = 5, maxAP = 10})
    HexSystem.addUnit(hexSys, "test", unit)
    
    -- Try valid move
    local success = MovementSystem.tryMove(unit, hexSys, 6, 5)
    assert(success, "Valid move should succeed")
    assert(unit.transform.q == 6, "Unit should move to new Q")
    assert(unit.movement.currentAP == 8, "Should spend 2 AP")
end)

test("MovementSystem blocked move", function()
    local hexSys = HexSystem.new(10, 10)
    local unit1 = UnitEntity.new({q = 5, r = 5, maxAP = 10})
    local unit2 = UnitEntity.new({q = 6, r = 5, maxAP = 10})
    HexSystem.addUnit(hexSys, "test1", unit1)
    HexSystem.addUnit(hexSys, "test2", unit2)
    
    -- Try to move into occupied hex
    local success = MovementSystem.tryMove(unit1, hexSys, 6, 5)
    assert(not success, "Move to occupied hex should fail")
    assert(unit1.transform.q == 5, "Unit should not move")
end)

test("MovementSystem pathfinding", function()
    local hexSys = HexSystem.new(10, 10)
    local path = MovementSystem.findPath(hexSys, 0, 0, 3, 0)
    assert(path ~= nil, "Should find path")
    assert(#path == 4, "Path should have 4 hexes (including start)")
    assert(path[1].q == 0 and path[1].r == 0, "First hex should be start")
    assert(path[#path].q == 3 and path[#path].r == 0, "Last hex should be end")
end)

test("MovementSystem AP reset", function()
    local unit1 = UnitEntity.new({maxAP = 10})
    local unit2 = UnitEntity.new({maxAP = 12})
    unit1.movement.currentAP = 3
    unit2.movement.currentAP = 5
    
    MovementSystem.resetAllAP({unit1, unit2})
    assert(unit1.movement.currentAP == 10, "Unit1 AP should reset")
    assert(unit2.movement.currentAP == 12, "Unit2 AP should reset")
end)

-- ========================================
-- VISION SYSTEM TESTS
-- ========================================
print("\n[VisionSystem] Testing vision and LOS...")

test("VisionSystem LOS clear", function()
    local hexSys = HexSystem.new(20, 20)
    local hasLOS = VisionSystem.hasLineOfSight(hexSys, 5, 5, 8, 5)
    assert(hasLOS, "Should have clear LOS")
end)

test("VisionSystem LOS blocked", function()
    local hexSys = HexSystem.new(20, 20)
    -- Block middle hex
    local tile = HexSystem.getTile(hexSys, 6, 5)
    if tile then
        tile.blocking = true
    end
    local hasLOS = VisionSystem.hasLineOfSight(hexSys, 5, 5, 8, 5)
    assert(not hasLOS, "LOS should be blocked")
end)

test("VisionSystem unit vision update", function()
    local hexSys = HexSystem.new(20, 20)
    local unit = UnitEntity.new({q = 10, r = 10, facing = 0, visionRange = 5})
    
    VisionSystem.updateUnitVision(unit, hexSys)
    assert(next(unit.vision.visibleTiles) ~= nil, "Should have visible tiles")
end)

test("VisionSystem unit detection", function()
    local hexSys = HexSystem.new(20, 20)
    local unit1 = UnitEntity.new({id = "unit1", q = 10, r = 10, facing = 0, visionRange = 5})
    local unit2 = UnitEntity.new({id = "unit2", q = 12, r = 10})
    
    HexSystem.addUnit(hexSys, "unit1", unit1)
    HexSystem.addUnit(hexSys, "unit2", unit2)
    
    VisionSystem.updateUnitVision(unit1, hexSys)
    
    -- Check if unit1 can see unit2
    assert(unit1.vision:canSeeUnit("unit2"), "Unit1 should see unit2 in front")
end)

test("VisionSystem team visibility", function()
    local hexSys = HexSystem.new(20, 20)
    local unit1 = UnitEntity.new({q = 10, r = 10, facing = 0, visionRange = 5})
    local unit2 = UnitEntity.new({q = 10, r = 12, facing = 2, visionRange = 5})
    
    VisionSystem.updateTeamVision({unit1, unit2}, hexSys)
    
    local visibleTiles = VisionSystem.getTeamVisibleTiles({unit1, unit2})
    assert(next(visibleTiles) ~= nil, "Team should have visible tiles")
end)

-- ========================================
-- UNIT ENTITY TESTS
-- ========================================
print("\n[UnitEntity] Testing unit entity composition...")

test("UnitEntity creation", function()
    local unit = UnitEntity.new({
        name = "Test Soldier",
        q = 5, r = 10,
        teamId = 1,
        maxHP = 100,
        maxAP = 10
    })
    assert(unit.name == "Test Soldier", "Name should match")
    assert(unit.transform.q == 5, "Position Q should match")
    assert(unit.health.maxHP == 100, "HP should match")
    assert(unit.team.teamId == 1, "Team should match")
end)

test("UnitEntity all components present", function()
    local unit = UnitEntity.new()
    assert(unit.transform ~= nil, "Should have transform")
    assert(unit.movement ~= nil, "Should have movement")
    assert(unit.vision ~= nil, "Should have vision")
    assert(unit.health ~= nil, "Should have health")
    assert(unit.team ~= nil, "Should have team")
end)

test("UnitEntity active check", function()
    local unit = UnitEntity.new({maxHP = 100})
    assert(UnitEntity.isActive(unit), "New unit should be active")
    unit.health.currentHP = 0
    unit.health.isDead = true
    assert(not UnitEntity.isActive(unit), "Dead unit should not be active")
end)

test("UnitEntity serialization", function()
    local unit = UnitEntity.new({
        id = "test123",
        name = "Soldier",
        q = 5, r = 10,
        maxHP = 100
    })
    local data = UnitEntity.serialize(unit)
    assert(data.id == "test123", "Should preserve ID")
    assert(data.q == 5, "Should preserve position")
    
    local restored = UnitEntity.deserialize(data)
    assert(restored.name == "Soldier", "Should restore name")
    assert(restored.transform.q == 5, "Should restore position")
end)

-- ========================================
-- INTEGRATION TESTS
-- ========================================
print("\n[Integration] Testing system interactions...")

test("Full turn simulation", function()
    -- Create hex grid
    local hexSys = HexSystem.new(20, 20)
    
    -- Create units
    local unit1 = UnitEntity.new({id = "unit1", q = 5, r = 5, facing = 0, teamId = 1, maxAP = 10})
    local unit2 = UnitEntity.new({id = "unit2", q = 10, r = 10, facing = 3, teamId = 2, maxAP = 10})
    
    HexSystem.addUnit(hexSys, "unit1", unit1)
    HexSystem.addUnit(hexSys, "unit2", unit2)
    
    -- Update vision
    VisionSystem.updateTeamVision({unit1}, hexSys)
    VisionSystem.updateTeamVision({unit2}, hexSys)
    
    -- Move unit1
    local moved = MovementSystem.tryMove(unit1, hexSys, 6, 5)
    assert(moved, "Unit1 should move")
    assert(unit1.movement.currentAP == 8, "Should spend AP")
    
    -- Update vision after move
    VisionSystem.updateUnitVision(unit1, hexSys)
    
    -- Reset for new turn
    MovementSystem.resetAllAP({unit1, unit2})
    assert(unit1.movement.currentAP == 10, "AP should reset")
end)

test("Combat visibility", function()
    local hexSys = HexSystem.new(20, 20)
    local attacker = UnitEntity.new({id = "att", q = 10, r = 10, facing = 0, visionRange = 8})
    local target = UnitEntity.new({id = "tgt", q = 13, r = 10, teamId = 2})
    
    HexSystem.addUnit(hexSys, "att", attacker)
    HexSystem.addUnit(hexSys, "tgt", target)
    
    VisionSystem.updateUnitVision(attacker, hexSys)
    
    local canSee = attacker.vision:canSeeUnit("tgt")
    assert(canSee, "Attacker should see target in front")
end)

-- ========================================
-- RESULTS
-- ========================================
print("\n" .. string.rep("=", 60))
print("TEST RESULTS")
print(string.rep("=", 60))
print(string.format("Total Tests:  %d", testsRun))
print(string.format("Passed:       %d ✓", testsPassed))
print(string.format("Failed:       %d ✗", testsFailed))
print(string.format("Success Rate: %.1f%%", (testsPassed / testsRun) * 100))
print(string.rep("=", 60))

if testsFailed == 0 then
    print("\n🎉 ALL TESTS PASSED! 🎉")
    print("\nSystems ready for integration:")
    print("  ✓ HexSystem - Grid management")
    print("  ✓ MovementSystem - AP-based movement")
    print("  ✓ VisionSystem - LOS and FOW")
    print("  ✓ UnitEntity - Component composition")
    print("\nNext: Integrate with battlescape.lua")
else
    print("\n⚠️  SOME TESTS FAILED - Review errors above")
end

























