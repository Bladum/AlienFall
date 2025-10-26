-- tests/geoscape/init.lua
-- Geoscape test suite loader

local geoscape = {}

-- Load all geoscape tests
geoscape.calendar = require("tests.geoscape.test_calendar")
geoscape.hex_grid = require("tests.geoscape.test_hex_grid")
geoscape.mission_detection = require("tests.geoscape.test_mission_detection")
geoscape.world_generation = require("tests.geoscape.test_world_generation")
geoscape.portal_system = require("tests.geoscape.test_portal_system")
geoscape.threat_escalation = require("tests.geoscape.test_threat_escalation")

-- Phase tests
geoscape.phase2_world = require("tests.geoscape.test_phase2_world_generation")
geoscape.phase3_regional = require("tests.geoscape.test_phase3_regional_management")
geoscape.phase4_faction = require("tests.geoscape.test_phase4_faction_mission_system")
geoscape.phase5_campaign = require("tests.geoscape.test_phase5_campaign_integration")
geoscape.phase5_time = require("tests.geoscape.test_phase5_time_turn_system")
geoscape.phase6_integration = require("tests.geoscape.test_phase6_integration")
geoscape.phase6_rendering = require("tests.geoscape.test_phase6_rendering_ui")
geoscape.phase7_campaign = require("tests.geoscape.test_phase7_campaign_integration")
geoscape.phase8_outcome = require("tests.geoscape.test_phase8_outcome_handling")
geoscape.phase9_advanced = require("tests.geoscape.test_phase9_advanced_features")
geoscape.phase10_campaign = require("tests.geoscape.test_phase10_complete_campaign")
geoscape.phase10_ui_audio = require("tests.geoscape.test_phase10_ui_audio")
geoscape.phase2 = require("tests.geoscape.test_phase2_standalone")

-- Run all geoscape tests
function geoscape:runAll()
    print("\n" .. string.rep("═", 80))
    print("GEOSCAPE TESTS SUITE - 20 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0
    local tests = {
        "calendar", "hex_grid", "mission_detection", "world_generation",
        "portal_system", "threat_escalation", "phase2_world", "phase3_regional",
        "phase4_faction", "phase5_campaign", "phase5_time", "phase6_integration",
        "phase6_rendering", "phase7_campaign", "phase8_outcome", "phase9_advanced",
        "phase10_campaign", "phase10_ui_audio", "phase2"
    }

    for _, name in ipairs(tests) do
        if geoscape[name] and geoscape[name].runAll then
            local ok, err = pcall(function() geoscape[name]:runAll() end)
            if ok then
                passed = passed + 1
            else
                failed = failed + 1
                print("[ERROR] " .. name .. ": " .. tostring(err))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("GEOSCAPE TEST SUMMARY")
    print(string.rep("═", 80))
    print("Passed: " .. passed)
    print("Failed: " .. failed)
    print("Total: " .. (passed + failed))
    print(string.rep("═", 80) .. "\n")
end

return geoscape
