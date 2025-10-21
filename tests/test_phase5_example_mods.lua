-- Test Suite for Phase 5 Step 5: Example Mods
-- Verifies that both example mods load correctly and contain valid content

print("===============================================================================")
print("PHASE 5 STEP 5: EXAMPLE MODS TEST SUITE")
print("Testing comprehensive example mods for modding capabilities")
print("===============================================================================\n")

local tests_passed = 0
local tests_failed = 0

-- Test utilities
local function assert_equals(actual, expected, message)
    if actual == expected then
        print("✓ " .. message)
        tests_passed = tests_passed + 1
        return true
    else
        print("✗ " .. message .. " (expected: " .. tostring(expected) .. ", got: " .. tostring(actual) .. ")")
        tests_failed = tests_failed + 1
        return false
    end
end

local function assert_not_nil(value, message)
    if value ~= nil then
        print("✓ " .. message)
        tests_passed = tests_passed + 1
        return true
    else
        print("✗ " .. message .. " (value is nil)")
        tests_failed = tests_failed + 1
        return false
    end
end

local function assert_table(value, message)
    if type(value) == "table" then
        print("✓ " .. message)
        tests_passed = tests_passed + 1
        return true
    else
        print("✗ " .. message .. " (not a table)")
        tests_failed = tests_failed + 1
        return false
    end
end

local function assert_true(value, message)
    if value == true then
        print("✓ " .. message)
        tests_passed = tests_passed + 1
        return true
    else
        print("✗ " .. message .. " (not true)")
        tests_failed = tests_failed + 1
        return false
    end
end

-- ============================================================================
-- COMPLETE MOD TESTS
-- ============================================================================

print("\n[COMPLETE MOD TESTS]")
print("Testing: mods/examples/complete/init.lua\n")

-- Load complete mod
local CompleteMod = require("mods.examples.complete.init")

-- Test mod initialization
assert_not_nil(CompleteMod, "Complete mod loaded successfully")
assert_equals(CompleteMod.name, "Complete Example Mod", "Complete mod has correct name")
assert_equals(CompleteMod.version, "1.0.0", "Complete mod has correct version")
assert_equals(CompleteMod.id, "example_complete", "Complete mod has correct id")

-- Test weapons
print("\n[Weapons]")
assert_not_nil(CompleteMod.content.weapons, "Weapons table exists")
assert_equals(#CompleteMod.content.weapons, 3, "Complete mod has 3 weapons")

local plasma_rifle = CompleteMod.content.weapons[1]
assert_not_nil(plasma_rifle, "Plasma Rifle exists")
assert_equals(plasma_rifle.id, "example_plasma_rifle", "Plasma Rifle has correct ID")
assert_equals(plasma_rifle.damage, 85, "Plasma Rifle has correct damage (85)")
assert_equals(plasma_rifle.accuracy, 75, "Plasma Rifle has correct accuracy (75)")
assert_equals(plasma_rifle.range, 30, "Plasma Rifle has correct range (30)")

local plasma_pistol = CompleteMod.content.weapons[2]
assert_not_nil(plasma_pistol, "Plasma Pistol exists")
assert_equals(plasma_pistol.id, "example_plasma_pistol", "Plasma Pistol has correct ID")
assert_equals(plasma_pistol.damage, 55, "Plasma Pistol has lower damage (55)")

local plasma_launcher = CompleteMod.content.weapons[3]
assert_not_nil(plasma_launcher, "Plasma Launcher exists")
assert_equals(plasma_launcher.id, "example_plasma_launcher", "Plasma Launcher has correct ID")
assert_equals(plasma_launcher.damage, 110, "Plasma Launcher has highest damage (110)")

-- Test armor
print("\n[Armor]")
assert_not_nil(CompleteMod.content.armor, "Armor table exists")
assert_equals(#CompleteMod.content.armor, 2, "Complete mod has 2 armor items")

local plasma_armor = CompleteMod.content.armor[1]
assert_not_nil(plasma_armor, "Plasma Combat Armor exists")
assert_equals(plasma_armor.id, "example_plasma_armor", "Plasma Armor has correct ID")
assert_equals(plasma_armor.armor_class, 18, "Plasma Armor has correct armor class (18)")

-- Test units
print("\n[Units]")
assert_not_nil(CompleteMod.content.units, "Units table exists")
assert_equals(#CompleteMod.content.units, 4, "Complete mod has 4 units")

local advanced_soldier = CompleteMod.content.units[1]
assert_not_nil(advanced_soldier, "Advanced Soldier exists")
assert_equals(advanced_soldier.id, "example_advanced_soldier", "Advanced Soldier has correct ID")
assert_equals(advanced_soldier.base_health, 35, "Advanced Soldier has correct health (35)")
assert_not_nil(advanced_soldier.base_stats, "Advanced Soldier has stat table")
assert_equals(advanced_soldier.base_stats.strength, 8, "Advanced Soldier strength is 8")

-- Test facilities
print("\n[Facilities]")
assert_not_nil(CompleteMod.content.facilities, "Facilities table exists")
assert_equals(#CompleteMod.content.facilities, 3, "Complete mod has 3 facilities")

local plasma_lab = CompleteMod.content.facilities[1]
assert_not_nil(plasma_lab, "Plasma Research Lab exists")
assert_equals(plasma_lab.id, "example_plasma_lab", "Plasma Lab has correct ID")
assert_equals(plasma_lab.grid_width, 2, "Plasma Lab width is 2")
assert_equals(plasma_lab.grid_height, 2, "Plasma Lab height is 2")
assert_equals(plasma_lab.build_cost, 3500, "Plasma Lab cost is 3500")

-- Test technologies
print("\n[Technologies]")
assert_not_nil(CompleteMod.content.technologies, "Technologies table exists")
assert_equals(#CompleteMod.content.technologies, 2, "Complete mod has 2 technologies")

local plasma_tech = CompleteMod.content.technologies[1]
assert_not_nil(plasma_tech, "Plasma Weapons tech exists")
assert_equals(plasma_tech.id, "example_plasma_tech", "Plasma Tech has correct ID")
assert_equals(plasma_tech.technology_tier, 3, "Plasma Tech is tier 3")
assert_equals(plasma_tech.research_cost, 1500, "Plasma Tech costs 1500")

-- Test missions
print("\n[Missions]")
assert_not_nil(CompleteMod.content.missions, "Missions table exists")
assert_equals(#CompleteMod.content.missions, 1, "Complete mod has 1 mission")

local mission = CompleteMod.content.missions[1]
assert_not_nil(mission, "Mission exists")
assert_equals(mission.id, "example_mission_alien_facility", "Mission has correct ID")

-- Test validation
print("\n[Validation]")
assert_true(CompleteMod:validate(), "Complete mod validation passes")

-- Test statistics
print("\n[Statistics]")
local stats = CompleteMod:getStatistics()
assert_not_nil(stats, "Statistics available")
assert_equals(stats.weapons, 3, "Statistics show 3 weapons")
assert_equals(stats.armor, 2, "Statistics show 2 armor")
assert_equals(stats.units, 4, "Statistics show 4 units")
assert_equals(stats.facilities, 3, "Statistics show 3 facilities")
assert_equals(stats.technologies, 2, "Statistics show 2 technologies")
assert_equals(stats.missions, 1, "Statistics show 1 mission")

-- ============================================================================
-- MINIMAL MOD TESTS
-- ============================================================================

print("\n[MINIMAL MOD TESTS]")
print("Testing: mods/examples/minimal/init.lua\n")

-- Load minimal mod
local MinimalMod = require("mods.examples.minimal.init")

-- Test mod initialization
assert_not_nil(MinimalMod, "Minimal mod loaded successfully")
assert_equals(MinimalMod.name, "Minimal Example Mod", "Minimal mod has correct name")
assert_equals(MinimalMod.version, "1.0.0", "Minimal mod has correct version")
assert_equals(MinimalMod.id, "example_minimal", "Minimal mod has correct id")

-- Test weapon
print("\n[Weapon]")
assert_not_nil(MinimalMod.content.weapon, "Weapon exists")
assert_equals(MinimalMod.content.weapon.id, "minimal_laser_rifle", "Weapon has correct ID")
assert_equals(MinimalMod.content.weapon.damage, 65, "Weapon has correct damage (65)")

-- Test unit class
print("\n[Unit Class]")
assert_not_nil(MinimalMod.content.unit_class, "Unit class exists")
assert_equals(MinimalMod.content.unit_class.id, "minimal_scout", "Unit class has correct ID")
assert_equals(MinimalMod.content.unit_class.base_health, 30, "Unit class has correct health (30)")

-- Test validation
print("\n[Validation]")
assert_true(MinimalMod:validate(), "Minimal mod validation passes")

-- ============================================================================
-- INTEGRATION TESTS
-- ============================================================================

print("\n[INTEGRATION TESTS]")
print("Testing interaction between mods\n")

-- Test content isolation
print("[Content Isolation]")
assert_not_nil(CompleteMod.content.weapons[1], "Complete mod weapons isolated")
assert_not_nil(MinimalMod.content.weapon, "Minimal mod weapon isolated")

-- Verify IDs don't conflict
local complete_ids = {}
for _, weapon in ipairs(CompleteMod.content.weapons) do
    assert_not_nil(weapon.id, "Complete mod weapon has ID: " .. (weapon.id or "nil"))
    complete_ids[weapon.id] = true
end

local minimal_id = MinimalMod.content.weapon.id
if complete_ids[minimal_id] then
    print("✗ ID conflict: " .. minimal_id)
    tests_failed = tests_failed + 1
else
    print("✓ No ID conflicts between mods")
    tests_passed = tests_passed + 1
end

-- ============================================================================
-- TEST SUMMARY
-- ============================================================================

print("\n" .. string.rep("=", 79))
print("TEST SUMMARY")
print(string.rep("=", 79))

local total_tests = tests_passed + tests_failed
local pass_rate = (total_tests > 0) and (tests_passed / total_tests * 100) or 0

print("\nTests Passed: " .. tests_passed .. " ✓")
print("Tests Failed: " .. tests_failed)
print("Total Tests:  " .. total_tests)
print("Pass Rate:    " .. string.format("%.1f%%", pass_rate))

print("\n" .. string.rep("=", 79))

if tests_failed == 0 then
    print("ALL TESTS PASSED ✓")
    print("Both example mods are functioning correctly!")
    print("✓ Complete Mod: 3 weapons, 2 armor, 4 units, 3 facilities, 2 tech, 1 mission")
    print("✓ Minimal Mod: 1 weapon, 1 unit class")
else
    print("SOME TESTS FAILED")
    print("Please review the failures above")
end

print(string.rep("=", 79) .. "\n")

return {
    total = total_tests,
    passed = tests_passed,
    failed = tests_failed,
    pass_rate = pass_rate
}
