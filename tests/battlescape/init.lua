-- tests/battlescape/init.lua
-- Battlescape test suite loader

local battlescape = {}

-- Load all battlescape tests
battlescape.map_generation = require("tests.battlescape.test_map_generation")
battlescape.map_editor = require("tests.battlescape.test_map_editor")
battlescape.mission_integration = require("tests.battlescape.test_mission_integration")
battlescape.pilot_system = require("tests.battlescape.test_pilot_system")
battlescape.tileset = require("tests.battlescape.test_tileset_system")

-- Run all battlescape tests
function battlescape:runAll()
    print("\n" .. string.rep("═", 80))
    print("BATTLESCAPE TESTS SUITE - 5 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0
    local tests = {
        "map_generation", "map_editor", "mission_integration",
        "pilot_system", "tileset"
    }

    for _, name in ipairs(tests) do
        if battlescape[name] and battlescape[name].runAll then
            local ok, err = pcall(function() battlescape[name]:runAll() end)
            if ok then
                passed = passed + 1
            else
                failed = failed + 1
                print("[ERROR] " .. name .. ": " .. tostring(err))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("BATTLESCAPE TEST SUMMARY")
    print(string.rep("═", 80))
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    print("Total: " .. (passed + failed))
    print(string.rep("═", 80) .. "\n")
end

return battlescape
