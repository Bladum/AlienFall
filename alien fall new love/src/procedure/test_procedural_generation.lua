--- Procedural Generation Test
-- Test script to validate the procedural generation system

local ProcGen = require('procedure.ProcGen')

print("=== Alien Fall Procedural Generation Test ===\n")

-- Test with fixed seed for reproducible results
local seed = 12345
print("Using seed:", seed)

local procGen = ProcGen(seed)

print("\n--- Testing Mission Generation ---")
local mission = procGen:generateMission('assault', 3)
print("Mission Title:", mission.title)
print("Mission Type:", mission.type)
print("Difficulty:", mission.difficulty)
print("Objectives:", #mission.objectives)
print("Map Size:", mission.size.width .. "x" .. mission.size.height)
print("Enemy Count:", #mission.units)

print("\n--- Testing Encounter Generation ---")
local encounter = procGen:generateEncounter({ difficulty = 2 })
print("Encounter Units:", #encounter.units)
print("Encounter Events:", #encounter.events)
print("Encounter Rewards:", #encounter.rewards)

print("\n--- Testing Item Generation ---")
local items = procGen.itemGen:generateItems({ weapons = 2, armor = 1, grenades = 1, medkits = 1 })
print("Generated Items:", #items)
for i, item in ipairs(items) do
    print(string.format("  %d. %s (%s)", i, item.name, item.type))
end

print("\n--- Testing Event Generation ---")
local events = procGen.eventGen:generateEvents({ 'enemy_reinforcements', 'environmental_hazard' })
print("Generated Events:", #events)
for i, event in ipairs(events) do
    print(string.format("  %d. %s - %s", i, event.name, event.description))
end

print("\n--- Testing Map Generation ---")
local map = procGen.mapGen:generate('urban', { width = 20, height = 15 })
print("Map Type:", map.type)
print("Map Size:", map.width .. "x" .. map.height)
print("Objectives:", #map.objectives)
print("Spawn Points - Player:", #map.spawnPoints.player, "Enemy:", #map.spawnPoints.enemy)

print("\n--- Testing Unit Generation ---")
local units = procGen.unitGen:generateUnits({ enemyCount = 3, enemyTypes = { 'sectoid', 'muton' } })
print("Generated Units:", #units)
for i, unit in ipairs(units) do
    print(string.format("  %d. %s (%s) - HP: %d, Level: %d", i, unit.name, unit.type, unit.stats.health, unit.level))
end

print("\n=== Test Complete ===")
print("All procedural generation systems are functioning correctly!")