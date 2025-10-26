-- tests/battle/init.lua
-- Battle system test suite loader

local battle = {}

-- Load all battle tests
battle.all_systems = require("tests.battle.test_all_systems")
battle.battlescape_systems = require("tests.battle.test_battlescape_systems")
battle.battle_systems = require("tests.battle.test_battle_systems")
battle.ecs_components = require("tests.battle.test_ecs_components")
battle.fow = require("tests.battle.test_fow_standalone")
battle.los_fow = require("tests.battle.test_los_fow")
battle.mapblock_integration = require("tests.battle.test_mapblock_integration")
battle.range_accuracy = require("tests.battle.test_range_accuracy")

-- Run all battle tests
function battle:runAll()
    print("\n" .. string.rep("═", 80))
    print("BATTLE TESTS SUITE - 8 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0
    local tests = {
        "all_systems", "battlescape_systems", "battle_systems",
        "ecs_components", "fow", "los_fow", "mapblock_integration", "range_accuracy"
    }

    for _, name in ipairs(tests) do
        if battle[name] and battle[name].runAll then
            local ok, err = pcall(function() battle[name]:runAll() end)
            if ok then
                passed = passed + 1
            else
                failed = failed + 1
                print("[ERROR] " .. name .. ": " .. tostring(err))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("BATTLE TEST SUMMARY")
    print(string.rep("═", 80))
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    print("Total: " .. (passed + failed))
    print(string.rep("═", 80) .. "\n")
end

return battle
