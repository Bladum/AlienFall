-- tests2/core/init.lua
-- Core engine systems test suite

local core = {}

-- Core system tests
core.accessibility = require("tests2.core.accessibility_test")
core.achievement = require("tests2.core.achievement_system_test")
core.artifact = require("tests2.core.artifact_system_test")
core.audio = require("tests2.core.audio_system_test")
core.colorblind = require("tests2.core.colorblind_mode_test")
core.data_loader = require("tests2.core.data_loader_test")
core.difficulty = require("tests2.core.difficulty_test")
core.events = require("tests2.core.dynamic_events_test")
core.engine_coverage = require("tests2.core.engine_coverage_analysis_test")
core.example = require("tests2.core.example_counter_test")
core.fame = require("tests2.core.fame_reputation_test")
core.localization = require("tests2.core.localization_test")
core.mod_system = require("tests2.core.mod_system_test")
core.notification = require("tests2.core.notification_system_test")
core.pathfinding = require("tests2.core.pathfinding_test")
core.pilot_skills = require("tests2.core.pilot_skills_test")
core.population = require("tests2.core.population_dynamics_test")
core.qa = require("tests2.core.qa_system_test")
core.research = require("tests2.core.research_tech_test")
core.resource = require("tests2.core.resource_management_test")
core.save = require("tests2.core.save_system_test")
core.skill = require("tests2.core.skill_progression_test")
core.spatial = require("tests2.core.spatial_hash_test")
core.state = require("tests2.core.state_manager_test")
core.survival = require("tests2.core.survival_mechanics_test")
core.system_integration = require("tests2.core.system_integration_test")
core.talent = require("tests2.core.talent_tree_test")
core.tech = require("tests2.core.tech_tree_test")
core.turn = require("tests2.core.turn_manager_test")
core.tutorial = require("tests2.core.tutorial_test")
core.unit_progression = require("tests2.core.unit_progression_test")

function core:runAll()
    print("\n" .. string.rep("═", 80))
    print("CORE SYSTEMS TESTS - 31 Test Files")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0

    for name, test in pairs(self) do
        if type(test) == "table" and test.run then
            local ok, err = pcall(function() test:run() end)
            if ok then passed = passed + 1
            else failed = failed + 1; print("[ERROR] " .. name .. ": " .. tostring(err)) end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("CORE TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return core
