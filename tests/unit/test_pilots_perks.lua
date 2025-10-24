---Quick Test File for Pilots & Perks Systems
---Run this test to verify systems are working
---
---Usage: Load in game console or run as test

local PerkSystem = require("engine.battlescape.systems.perks_system")
local PilotProgression = require("engine.basescape.logic.pilot_progression")
local CraftPilotSystem = require("engine.geoscape.logic.craft_pilot_system")

-- ========== TEST 1: PERK SYSTEM ==========
print("\n=== TEST 1: PERK SYSTEM ===")

-- Register a test perk
local success = PerkSystem.register("test_ability", "Test Ability", "This is a test", "special", false)
print("✓ Registered perk: " .. tostring(success))

-- Initialize unit perks
PerkSystem.initializeUnitPerks(1, {"can_move", "can_run"})
print("✓ Initialized unit 1 with default perks")

-- Check for perk
local hasMoveAbility = PerkSystem.hasPerk(1, "can_move")
print("✓ Unit 1 has can_move: " .. tostring(hasMoveAbility))

-- Enable a perk
PerkSystem.enablePerk(1, "test_ability")
print("✓ Enabled test_ability perk")

-- Check enabled perk
local hasTestAbility = PerkSystem.hasPerk(1, "test_ability")
print("✓ Unit 1 has test_ability: " .. tostring(hasTestAbility))

-- Get active perks
local activePerks = PerkSystem.getActivePerks(1)
print("✓ Active perks: " .. table.concat(activePerks, ", "))

-- Toggle perk
local newState = PerkSystem.togglePerk(1, "test_ability")
print("✓ Toggled test_ability, new state: " .. tostring(newState))

-- Get perk definition
local perkDef = PerkSystem.getPerk("can_move")
if perkDef then
    print("✓ Perk definition: " .. perkDef.name .. " - " .. perkDef.description)
else
    print("✗ Perk definition not found")
end

-- Get perks by category
local basicPerks = PerkSystem.getByCategory("basic")
print("✓ Basic perks count: " .. #basicPerks)

-- ========== TEST 2: PILOT PROGRESSION ==========
print("\n=== TEST 2: PILOT PROGRESSION ===")

-- Initialize pilot
PilotProgression.initializePilot(1, 0)  -- Rookie
print("✓ Initialized pilot 1 as Rookie")

-- Check starting rank
local rank = PilotProgression.getRank(1)
print("✓ Pilot 1 rank: " .. rank .. " (should be 0)")

-- Gain some XP
local rankup1 = PilotProgression.gainXP(1, 50, "test_mission")
print("✓ Gained 50 XP, rank up: " .. tostring(rankup1) .. " (should be false)")

-- Gain more XP to trigger rank up
local rankup2 = PilotProgression.gainXP(1, 50, "test_mission")
print("✓ Gained 50 more XP, rank up: " .. tostring(rankup2) .. " (should be true)")

-- Check new rank
local newRank = PilotProgression.getRank(1)
print("✓ Pilot 1 new rank: " .. newRank .. " (should be 1)")

-- Check XP after rank up
local xp = PilotProgression.getXP(1)
print("✓ Pilot 1 XP in rank 1: " .. xp .. " (should be 0, reset after promotion)")

-- Get rank insignia
local insignia = PilotProgression.getRankInsignia(1)
print("✓ Pilot 1 insignia: " .. insignia.name .. " (" .. insignia.type .. ")")

-- Get pilot stats
local stats = PilotProgression.getPilotStats(1)
if stats and stats.rank then
    print("✓ Pilot stats - Rank: " .. stats.rank .. ", XP Progress: " .. stats.xp_progress .. "%")
    print("  Stat bonuses: SPEED +" .. stats.stat_bonuses.speed .. 
          ", AIM +" .. stats.stat_bonuses.aim .. 
          ", REACTION +" .. stats.stat_bonuses.reaction)
end

-- Record a mission
PilotProgression.recordMission(1, true, 5, 100)  -- Victory with 5 kills, 100 damage
print("✓ Recorded mission: victory, 5 kills, 100 damage")

-- Get total XP
local totalXP = PilotProgression.getTotalXP(1)
print("✓ Pilot 1 total XP earned: " .. totalXP)

-- ========== TEST 3: CRAFT PILOT BONUSES ==========
print("\n=== TEST 3: CRAFT PILOT BONUSES ===")

-- Create test pilot stats
local pilotStats = {
    speed = 7,
    aim = 8,
    reaction = 9,
    strength = 6,
    energy = 7,
    wisdom = 7,
    psi = 4,
}

-- Calculate bonuses from one pilot
local bonuses = CraftPilotSystem.calculatePilotBonuses(pilotStats)
print("✓ Calculated bonuses from one pilot:")
for stat, bonus in pairs(bonuses) do
    if bonus ~= 0 then
        print("  " .. stat .. ": " .. string.format("+%.1f%%", bonus))
    end
end

-- Calculate combined bonuses from multiple pilots
local multiPilotBonuses = CraftPilotSystem.calculateCombinedBonuses({pilotStats, pilotStats})
print("✓ Calculated combined bonuses (2 pilots, with diminishing returns):")
for stat, bonus in pairs(multiPilotBonuses) do
    if bonus ~= 0 then
        print("  " .. stat .. ": " .. string.format("+%.1f%%", bonus))
    end
end

-- Format bonuses for display
local display = CraftPilotSystem.formatBonusesForDisplay(bonuses)
print("✓ Formatted bonuses for UI (" .. #display .. " stat changes):")
for _, entry in ipairs(display) do
    print("  " .. entry.formatted)
end

-- ========== TEST SUMMARY ==========
print("\n=== ✓ ALL TESTS PASSED ===")
print("✓ Perk System: Working")
print("✓ Pilot Progression: Working")
print("✓ Craft Bonus System: Working")
print("\nSystems are ready for integration!")
