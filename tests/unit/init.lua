-- tests/unit/init.lua
-- Unit test suite loader

local unit = {}

-- Load all unit tests
unit.accuracy = require("tests.unit.test_accuracy_system")
unit.ai_tactical = require("tests.unit.test_ai_tactical_decision")
unit.analytics = require("tests.unit.test_analytics_units")
unit.audio = require("tests.unit.test_audio_system")
unit.basescape_facility = require("tests.unit.test_basescape_facility_system")
unit.country = require("tests.unit.test_country_manager")
unit.data_loader = require("tests.unit.test_data_loader")
unit.deployment = require("tests.unit.test_deployment_system")
unit.facility = require("tests.unit.test_facility_system")
unit.fs = require("tests.unit.test_fs")
unit.fs2 = require("tests.unit.test_fs2")
unit.geoscape_units = require("tests.unit.test_geoscape_units")
unit.hex_math = require("tests.unit.test_hex_math")
unit.karma = require("tests.unit.test_karma_system")
unit.main = require("tests.unit.test_main")
unit.mapblock_conf = require("tests.unit.test_mapblock_conf")
unit.map_generation = require("tests.unit.test_map_generation")
unit.mod_manager = require("tests.unit.test_mod_manager")
unit.movement = require("tests.unit.test_movement_system")
unit.pathfinding = require("tests.unit.test_pathfinding")
unit.pilots_perks = require("tests.unit.test_pilots_perks")
unit.relations = require("tests.unit.test_relations_units")
unit.research = require("tests.unit.test_research_system")
unit.runner = require("tests.unit.test_runner")
unit.save = require("tests.unit.test_save_system")
unit.spatial_hash = require("tests.unit.test_spatial_hash")
unit.state_manager = require("tests.unit.test_state_manager")
unit.tutorial = require("tests.unit.test_tutorial_system")
unit.world = require("tests.unit.test_world_system")

-- Run all unit tests
function unit:runAll()
    print("\n" .. string.rep("═", 80))
    print("UNIT TESTS SUITE - 31 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0
    local tests = {
        "accuracy", "ai_tactical", "analytics", "audio",
        "basescape_facility", "country", "data_loader", "deployment",
        "facility", "fs", "fs2", "geoscape_units", "hex_math", "karma",
        "main", "mapblock_conf", "map_generation", "mod_manager",
        "movement", "pathfinding", "pilots_perks", "relations",
        "research", "runner", "save", "spatial_hash", "state_manager",
        "tutorial", "world"
    }

    for _, name in ipairs(tests) do
        if unit[name] and unit[name].runAll then
            local ok, err = pcall(function() unit[name]:runAll() end)
            if ok then
                passed = passed + 1
            else
                failed = failed + 1
                print("[ERROR] " .. name .. ": " .. tostring(err))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("UNIT TEST SUMMARY")
    print(string.rep("═", 80))
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    print("Total: " .. (passed + failed))
    print(string.rep("═", 80) .. "\n")
end

return unit
