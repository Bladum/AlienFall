---
-- Unit Pilot System Test
--
-- Tests for pilot class creation, perks initialization, and craft integration.
-- Verifies that pilots load correctly from TOML with perks system.
--
-- @module test_pilot_system
-- @author AlienFall Development Team

local TestFramework = require("tests.test_framework")
local Unit = require("battlescape.combat.unit")
local DataLoader = require("core.data.data_loader")

local PilotSystemTests = {}

---Initialize test suite
function PilotSystemTests.initialize()
    print("\n-=======================================================-")
    print("         PILOT SYSTEM TESTS                             ")
    print("L=======================================================-")
end

---Test pilot class loading from TOML
function PilotSystemTests.testPilotClassLoading()
    print("\n-=-=-=- Pilot Class Loading -=-=-=-")

    TestFramework.runTest("PILOT class definition loaded", function()
        local pilotClass = DataLoader.unitClasses.get("pilot")
        TestFramework.assertNotNil(pilotClass, "PILOT class not found in DataLoader")
        if pilotClass then
            TestFramework.assertEqual(pilotClass.name, "Pilot", "PILOT name mismatch")
            TestFramework.assertEqual(pilotClass.baseStats.speed, 8, "PILOT speed should be 8")
            TestFramework.assertEqual(pilotClass.baseStats.reaction, 8, "PILOT reaction should be 8")
            print("[✓] PILOT class loaded with correct stats")
        end
    end)

    TestFramework.runTest("Pilot class variants loaded", function()
        local fpClass = DataLoader.unitClasses.get("fighter_pilot")
        local bpClass = DataLoader.unitClasses.get("bomber_pilot")
        local hpClass = DataLoader.unitClasses.get("helicopter_pilot")

        TestFramework.assertNotNil(fpClass, "FIGHTER_PILOT class not found")
        TestFramework.assertNotNil(bpClass, "BOMBER_PILOT class not found")
        TestFramework.assertNotNil(hpClass, "HELICOPTER_PILOT class not found")
        print("[✓] All pilot class variants loaded successfully")
    end)
end

---Test pilot unit creation
function PilotSystemTests.testPilotUnitCreation()
    print("\n-=-=-=- Pilot Unit Creation -=-=-=-")

    TestFramework.runTest("Create pilot units with correct stats", function()
        local pilot = Unit.new("pilot", "player", 5, 5)
        local fpilot = Unit.new("fighter_pilot", "player", 10, 10)
        local bpilot = Unit.new("bomber_pilot", "player", 15, 15)

        TestFramework.assertNotNil(pilot, "Failed to create pilot unit")
        TestFramework.assertNotNil(fpilot, "Failed to create fighter pilot unit")
        TestFramework.assertNotNil(bpilot, "Failed to create bomber pilot unit")

        if pilot and pilot.stats then
            TestFramework.assertEqual(pilot.stats.speed, 8, "Pilot speed incorrect")
            print("[✓] Pilot unit created (Speed: 8)")
        end

        if fpilot and fpilot.stats then
            TestFramework.assertEqual(fpilot.stats.speed, 9, "Fighter pilot speed incorrect")
            print("[✓] Fighter pilot created (Speed: 9)")
        end

        if bpilot and bpilot.health then
            TestFramework.assertEqual(bpilot.health, 60, "Bomber pilot health incorrect")
            print("[✓] Bomber pilot created (HP: 60)")
        end
    end)
end

---Test perk initialization for pilots
function PilotSystemTests.testPilotPerkInitialization()
    print("\n-=-=-=- Pilot Perk Initialization -=-=-=-")

    TestFramework.runTest("Pilot units have perks initialized", function()
        local pilot = Unit.new("pilot", "player", 5, 5)
        local fpilot = Unit.new("fighter_pilot", "player", 10, 10)

        TestFramework.assertNotNil(pilot, "Pilot unit not created")
        TestFramework.assertNotNil(fpilot, "Fighter pilot unit not created")

        if pilot and pilot.perks then
            TestFramework.assert(type(pilot.perks) == "table", "Pilot perks should be table")
            TestFramework.assert(pilot.perks["can_move"], "Pilot missing can_move perk")
            TestFramework.assert(pilot.perks["skilled_pilot"], "Pilot missing skilled_pilot perk")
            print("[✓] Pilot has expected perks (can_move, skilled_pilot)")
        end

        if fpilot and fpilot.perks then
            TestFramework.assert(fpilot.perks["skilled_pilot"], "Fighter pilot missing skilled_pilot perk")
            print("[✓] Fighter pilot has skilled_pilot perk")
        end
    end)
end

---Run all pilot system tests
function PilotSystemTests.runAll()
    PilotSystemTests.initialize()
    PilotSystemTests.testPilotClassLoading()
    PilotSystemTests.testPilotUnitCreation()
    PilotSystemTests.testPilotPerkInitialization()
    PilotSystemTests.testPerkSystemIntegration()

    print("\n-=======================================================-")
    print("         PILOT SYSTEM TESTS COMPLETE                    ")
    print("L=======================================================-\n")
end

-- Auto-run if executed directly
if arg and arg[0]:match("test_pilot_system") then
    PilotSystemTests.runAll()
end

return PilotSystemTests

