-- UI Test Runner
-- Runs YAML-based UI tests and generates reports

package.path = package.path .. ";../../?.lua;../../engine/?.lua;../../engine/?/init.lua"

local UITestFramework = require("engine.gui.ui_test_framework")

local UITestRunner = {}

function UITestRunner.loadYAMLFile(filepath)
    local file = io.open(filepath, "r")
    if not file then
        error("Cannot open file: " .. filepath)
    end
    local content = file:read("*all")
    file:close()
    return content
end

function UITestRunner.registerGameElements()
    -- Main Menu Elements
    UITestFramework.registerElement("new_game_button", "#new_game", {
        type = "button",
        value = "New Game",
    })

    UITestFramework.registerElement("load_game_button", "#load_game", {
        type = "button",
        value = "Load Game",
    })

    UITestFramework.registerElement("settings_button", "#settings", {
        type = "button",
        value = "Settings",
    })

    -- Battlescape Elements
    UITestFramework.registerElement("unit_slot_1", ".unit_slot", {
        type = "button",
        value = "Unit 1",
    })

    UITestFramework.registerElement("action_move", "#action_move", {
        type = "button",
        value = "Move",
    })

    UITestFramework.registerElement("action_shoot", "#action_shoot", {
        type = "button",
        value = "Shoot",
    })

    UITestFramework.registerElement("weapon_selector", "#weapon_selector", {
        type = "dropdown",
        value = "auto_shot",
    })

    UITestFramework.registerElement("end_turn_button", "#end_turn", {
        type = "button",
        value = "End Turn",
    })

    -- Geoscape Elements
    UITestFramework.registerElement("region_north_america", "#region_north_america", {
        type = "button",
    })

    UITestFramework.registerElement("finance_button", "#finance", {
        type = "button",
    })

    UITestFramework.registerElement("research_button", "#research", {
        type = "button",
    })

    -- Basescape Elements
    UITestFramework.registerElement("construction_button", "#construction", {
        type = "button",
    })

    UITestFramework.registerElement("personnel_tab", "#personnel", {
        type = "button",
    })

    UITestFramework.registerElement("inventory_button", "#inventory", {
        type = "button",
    })

    UITestFramework.registerElement("craft_tab", "#craft", {
        type = "button",
    })
end

function UITestRunner.runTestSuite(yaml_file)
    print("\n" .. string.rep("=", 70))
    print("LOADING UI TEST SUITE: " .. yaml_file)
    print(string.rep("=", 70) .. "\n")

    local yaml_content = UITestRunner.loadYAMLFile(yaml_file)
    UITestFramework.loadTestsFromYAML(yaml_content)

    print(string.format("Loaded %d tests from %s\n",
        UITestFramework.registry.total_tests, yaml_file))

    -- Run each test
    local results = {}
    for _, test in ipairs(UITestFramework.registry.test_suites) do
        local result = UITestFramework.runTest(test, "ui_screen")
        table.insert(results, result)
    end

    return results
end

function UITestRunner.runAllTests()
    print("\n" .. string.rep("=", 70))
    print("RUNNING ALL UI TESTS")
    print(string.rep("=", 70) .. "\n")

    UITestFramework.init()
    UITestRunner.registerGameElements()

    local test_files = {
        "tests/ui/menu_tests.yaml",
        "tests/ui/battlescape_tests.yaml",
        "tests/ui/geoscape_tests.yaml",
        "tests/ui/basescape_tests.yaml",
    }

    for _, file in ipairs(test_files) do
        local ok, err = pcall(function()
            UITestRunner.runTestSuite(file)
        end)

        if not ok then
            print(string.format("⚠ Error loading %s: %s\n", file, err))
        end
    end

    UITestFramework.generateReport()
end

function love.load()
    UITestRunner.runAllTests()

    -- Exit with appropriate code
    local results = UITestFramework.registry
    if results.failed > 0 then
        print("\n❌ UI TESTS FAILED")
        love.event.quit(1)
    else
        print("\n✅ ALL UI TESTS PASSED")
        love.event.quit(0)
    end
end

return UITestRunner
