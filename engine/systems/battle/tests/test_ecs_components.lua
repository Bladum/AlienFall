-- test_ecs_components.lua
-- Test file for ECS component system
-- Run from project root: lovec engine/systems/battle/tests

-- Add path for requires
package.path = package.path .. ";../?.lua;../../?.lua;../../../?.lua"

-- Load components
local Transform = require("systems.battle.components.transform")
local Movement = require("systems.battle.components.movement")
local Vision = require("systems.battle.components.vision")
local Health = require("systems.battle.components.health")
local TeamComponent = require("systems.battle.components.team")

-- Load utilities
local HexMath = require("systems.battle.utils.hex_math")

print("[Test] Loading ECS Components Test Suite")
print("========================================")

-- Test Transform component
print("\n[Transform] Testing transform component...")
local transform = Transform.new(5, 10, 2)
assert(transform.x == 5, "Transform X should be 5")
assert(transform.y == 10, "Transform Y should be 10")
assert(transform.facing == 2, "Transform facing should be 2")
print("[Transform] ✓ Transform component works")

-- Test Movement component
print("\n[Movement] Testing movement component...")
local movement = Movement.new(10, 2, 1)
assert(movement.maxAP == 10, "Max AP should be 10")
assert(movement.currentAP == 10, "Current AP should be 10")
assert(Movement.canAfford(movement, 5) == true, "Should afford 5 AP")
assert(Movement.spendAP(movement, 5) == true, "Should spend 5 AP")
assert(movement.currentAP == 5, "Current AP should be 5 after spending")
assert(Movement.canAfford(movement, 10) == false, "Should not afford 10 AP")
Movement.resetAP(movement)
assert(movement.currentAP == 10, "AP should reset to 10")
print("[Movement] ✓ Movement component works")

-- Test Vision component
print("\n[Vision] Testing vision component...")
local vision = Vision.new(8, 120)
assert(vision.range == 8, "Vision range should be 8")
assert(vision.arc == 120, "Vision arc should be 120")
Vision.markTileVisible(vision, 3, 4)
assert(Vision.canSeeTile(vision, 3, 4) == true, "Should see tile 3,4")
assert(Vision.canSeeTile(vision, 5, 6) == false, "Should not see tile 5,6")
Vision.markUnitVisible(vision, "unit123")
assert(Vision.canSeeUnit(vision, "unit123") == true, "Should see unit123")
Vision.clear(vision)
assert(Vision.canSeeTile(vision, 3, 4) == false, "Should not see tile after clear")
print("[Vision] ✓ Vision component works")

-- Test Health component
print("\n[Health] Testing health component...")
local health = Health.new(100, 10)
assert(health.maxHP == 100, "Max HP should be 100")
assert(health.currentHP == 100, "Current HP should be 100")
assert(health.armor == 10, "Armor should be 10")
local damage = Health.takeDamage(health, 25, "kinetic")
assert(damage == 15, "Actual damage should be 15 (25-10 armor)")
assert(health.currentHP == 85, "HP should be 85 after damage")
assert(Health.isAlive(health) == true, "Should be alive")
local healed = Health.heal(health, 20)
assert(healed == 15, "Should heal 15 HP (capped at max)")
assert(health.currentHP == 100, "HP should be back to 100")
print("[Health] ✓ Health component works")

-- Test Team component
print("\n[Team] Testing team component...")
local team1 = TeamComponent.new(1, "Player")
local team2 = TeamComponent.new(2, "Enemy")
assert(team1.teamId == 1, "Team 1 ID should be 1")
assert(team1.isPlayer == true, "Team 1 should be player")
assert(team2.isAI == true, "Team 2 should be AI")
assert(TeamComponent.areHostile(team1, team2) == true, "Teams should be hostile")
assert(TeamComponent.areAllies(team1, team1) == true, "Team should be allied with itself")
print("[Team] ✓ Team component works")

-- Test HexMath utilities
print("\n[HexMath] Testing hex math utilities...")

-- Test coordinate conversion
print("  Testing coordinate conversions...")
local q, r = HexMath.offsetToAxial(5, 10)
local col, row = HexMath.axialToOffset(q, r)
assert(col == 5 and row == 10, "Round-trip conversion should match")
print("  ✓ Coordinate conversion works")

-- Test neighbors
print("  Testing neighbor calculation...")
local neighbors = HexMath.getNeighbors(0, 0)
assert(#neighbors == 6, "Should have 6 neighbors")
local nq, nr = HexMath.neighbor(0, 0, 0)  -- East
assert(nq == 1 and nr == 0, "East neighbor should be (1, 0)")
print("  ✓ Neighbor calculation works")

-- Test distance
print("  Testing distance calculation...")
local dist = HexMath.distance(0, 0, 3, 0)
assert(dist == 3, "Distance should be 3")
dist = HexMath.distance(0, 0, 0, 0)
assert(dist == 0, "Distance to self should be 0")
print("  ✓ Distance calculation works")

-- Test direction
print("  Testing direction calculation...")
local dir = HexMath.getDirection(0, 0, 1, 0)
assert(dir == 0, "Direction to (1,0) should be 0 (East)")
dir = HexMath.getDirection(0, 0, 0, -1)
assert(dir == 2, "Direction to (0,-1) should be 2 (NW)")
print("  ✓ Direction calculation works")

-- Test front arc
print("  Testing front arc detection...")
local inArc = HexMath.isInFrontArc(0, 0, 0, 1, 0)  -- Facing East, target East
assert(inArc == true, "Target directly ahead should be in arc")
print("  ✓ Front arc detection works")

-- Test hex line
print("  Testing hex line (LOS)...")
local line = HexMath.hexLine(0, 0, 3, 0)
assert(#line == 4, "Line should have 4 hexes (including start and end)")
assert(line[1].q == 0 and line[1].r == 0, "First hex should be start")
assert(line[#line].q == 3 and line[#line].r == 0, "Last hex should be end")
print("  ✓ Hex line works")

-- Test range
print("  Testing hexes in range...")
local hexesInRange = HexMath.hexesInRange(0, 0, 2)
assert(#hexesInRange > 0, "Should find hexes in range")
print("  ✓ Range calculation works")

print("\n[HexMath] ✓ All hex math tests passed")

print("\n========================================")
print("[Test] ✅ ALL TESTS PASSED")
print("========================================")
print("\nECS Component System is ready to use!")
print("Next steps:")
print("  1. Create systems (HexSystem, MovementSystem, VisionSystem)")
print("  2. Create entity definitions (UnitEntity)")
print("  3. Integrate with existing battlescape.lua")
