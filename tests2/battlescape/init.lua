-- Battlescape Test Suite Index
local battlescape = {}

-- Load all battlescape tests
battlescape.accuracy_system = require("tests2.battlescape.accuracy_system_test")
battlescape.ai_tactical_decision = require("tests2.battlescape.ai_tactical_decision_test")
battlescape.combat_log = require("tests2.battlescape.combat_log_test")
battlescape.combat_mechanics = require("tests2.battlescape.combat_mechanics_test")
battlescape.combat_resolver = require("tests2.battlescape.combat_resolver_test")
battlescape.combat_simulator = require("tests2.battlescape.combat_simulator_test")
battlescape.craft_manager = require("tests2.battlescape.craft_manager_test")
battlescape.deployment_system = require("tests2.battlescape.deployment_system_test")
battlescape.ecs_components = require("tests2.battlescape.ecs_components_test")
battlescape.edge_case_handling = require("tests2.battlescape.edge_case_handling_test")
battlescape.environmental_effects = require("tests2.battlescape.environmental_effects_test")
battlescape.interception_battle = require("tests2.battlescape.interception_battle_test")
battlescape.los_fow_system = require("tests2.battlescape.los_fow_system_test")
battlescape.map_generator = require("tests2.battlescape.map_generator_test")
battlescape.mission_briefing = require("tests2.battlescape.mission_briefing_test")
battlescape.movement_system = require("tests2.battlescape.movement_system_test")
battlescape.pathfinding_movement = require("tests2.battlescape.pathfinding_movement_test")
battlescape.procedural_generation = require("tests2.battlescape.procedural_generation_test")
battlescape.squad_formation = require("tests2.battlescape.squad_formation_test")
battlescape.squad_manager = require("tests2.battlescape.squad_manager_test")
battlescape.squad_tactics = require("tests2.battlescape.squad_tactics_test")
battlescape.tactical_combat = require("tests2.battlescape.tactical_combat_test")
battlescape.tactical_objectives = require("tests2.battlescape.tactical_objectives_test")
battlescape.unit_progression = require("tests2.battlescape.unit_progression_test")
battlescape.warrior_skills = require("tests2.battlescape.warrior_skills_test")
battlescape.weapon_balancing = require("tests2.battlescape.weapon_balancing_test")
battlescape.weapon_system = require("tests2.battlescape.weapon_system_test")

function battlescape:run()
    local Helpers = require("tests2.utils.test_helpers")

    local allResults = {}

    print("\n" .. string.rep("═", 80))
    print("BATTLESCAPE MODULE TEST SUITE - ALL MODULES")
    print(string.rep("═", 80))

    local modules = {
        "accuracy_system",
        "ai_tactical_decision",
        "combat_log",
        "combat_mechanics",
        "combat_resolver",
        "combat_simulator",
        "craft_manager",
        "deployment_system",
        "ecs_components",
        "edge_case_handling",
        "environmental_effects",
        "interception_battle",
        "los_fow_system",
        "map_generator",
        "mission_briefing",
        "movement_system",
        "pathfinding_movement",
        "procedural_generation",
        "squad_formation",
        "squad_manager",
        "squad_tactics",
        "tactical_combat",
        "tactical_objectives",
        "unit_progression",
        "warrior_skills",
        "weapon_balancing",
        "weapon_system"
    }

    local totalTests = 0
    local totalPassed = 0

    for _, moduleName in ipairs(modules) do
        local mod = battlescape[moduleName]
        if mod then
            print("\n" .. string.rep("-", 80))
            print("Running: " .. moduleName)
            print(string.rep("-", 80))

            if type(mod) == "table" and mod.run then
                -- Suite object with run method
                mod:run()
                totalTests = totalTests + 1
                totalPassed = totalPassed + 1
            elseif type(mod) == "boolean" then
                -- Already executed, boolean result
                if mod then
                    totalTests = totalTests + 1
                    totalPassed = totalPassed + 1
                else
                    totalTests = totalTests + 1
                    -- failed is already 0
                end
            else
                print("Unknown module type for " .. moduleName .. ": " .. type(mod))
            end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("BATTLESCAPE SUMMARY")
    print(string.rep("═", 80))
    print("Total Tests: " .. totalTests)
    print("Passed: " .. totalPassed)
    print("Failed: " .. (totalTests - totalPassed))
    print("Pass Rate: " .. string.format("%.1f", (totalPassed/totalTests)*100) .. "%")
    print(string.rep("═", 80) .. "\n")
end

return battlescape
