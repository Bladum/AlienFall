--- Test Runner for Alien Fall
--
-- Runs all test suites and reports results.
-- Execute with: love . --test
--
-- @module test_runner

local test_framework = require "test.framework.test_framework"

local test_runner = {}

--- Discover and load all test files
function test_runner.discover_tests()
    print("DEBUG: discover_tests called")
    local test_files = {}

    -- Use explicit list of existing test files
    test_files = {
        "test.test_api_validation",
        "test.test_data_loading",
        "test.test_data_registry",
        "test.test_mod_structure",
        "test.test_service_registry",
        "test.test_test_utilities",
        "test.test_toml_loader",
        "test.test_unit_system",
        "test.test_battlescape_integration",
        "test.engine.test_logger",
        "test.engine.test_asset_cache",
        "test.engine.test_asset_cache_expansion",
        "test.engine.test_rng",
        "test.engine.test_save",
        "test.engine.test_telemetry",
        "test.engine.test_turn_manager",
        "test.engine.test_schema_validator",
        "test.engine.test_data_catalog",
        "test.pedia.test_pedia_entry",
        "test.pedia.test_pedia_category",
        "test.pedia.test_pedia_manager",
        "test.organization.test_fame_system",
        "test.organization.test_karma_system",
        "test.organization.test_score_system",
        "test.geoscape.test_universe",
        "test.geoscape.test_world",
        "test.geoscape.test_province",
        "test.geoscape.test_country",
        "test.geoscape.test_region",
        "test.geoscape.test_portal",
        "test.geoscape.test_biome",
        "test.geoscape.test_world_generator",
        "test.geoscape.test_phase3_systems",
        "test.basescape.test_base_manager",
        "test.basescape.test_capacity_manager",
        "test.basescape.test_facility",
        "test.basescape.test_monthly_report",
        "test.basescape.test_service_manager",
        "test.crafts.test_craft",
        "test.crafts.test_craft_manager",
        "test.crafts.test_craft_service",
        "test.economy.test_manufacturing_entry",
        "test.economy.test_manufacturing_manager",
        "test.economy.test_manufacturing_project",
        "test.economy.test_manufacturing_service",
        "test.economy.test_market_manager",
        "test.economy.test_research_entry",
        "test.economy.test_research_project",
        "test.economy.test_research_service",
        "test.economy.test_supplier_service",
        "test.economy.test_transfer_order",
        "test.units.test_equipment_system",
        "test.integration.test_data_loader_integration",
        "test.integration.test_phase2_integration"
    }
    
    return test_files
end

--- Run specific test modules
-- @param module_names table: Array of module names to run (e.g., {"test.test_toml_loader"})
-- @return boolean: true if all tests passed
function test_runner.run_specific(modules)
    test_framework.reset()

    print(string.rep("=", 60))
    print("RUNNING SPECIFIC TEST MODULES")
    print(string.rep("=", 60))
    print("Modules: " .. table.concat(modules, ", "))
    print()

    local total_passed = 0
    local total_failed = 0

    for _, module_name in ipairs(modules) do
        print(string.rep("-", 40))
        print("Running: " .. module_name)
        print(string.rep("-", 40))

        local success, module = pcall(require, module_name)
        if success and module.run then
            module.run()
            print(string.format("PASS %s completed", module_name))
        elseif success and type(module) == "function" then
            module()
            print(string.format("PASS %s completed", module_name))
        else
            print(string.format("FAIL Failed to load test file: %s (%s)", module_name, tostring(module)))
            total_failed = total_failed + 1
        end
    end

    test_framework.print_summary()
    return test_framework.results.failed == 0
end

--- Run all tests
function test_runner.run_all()
    test_framework.reset()

    print(string.rep("=", 60))
    print("RUNNING ALL ALIEN FALL TESTS")
    print(string.rep("=", 60))

    local test_files = test_runner.discover_tests()

    for _, test_file in ipairs(test_files) do
        print(string.rep("-", 40))
        print("Loading: " .. test_file)
        print(string.rep("-", 40))

        local success, module = pcall(require, test_file)
        if success and module.run then
            module.run()
        elseif success and type(module) == "function" then
            -- If the module returns a function, call it
            module()
        else
            if success then
                print(string.format("FAIL Test file loaded but no run function: %s", test_file))
            else
                print(string.format("FAIL Failed to load test file: %s (%s)", test_file, tostring(module)))
            end
        end
    end

    test_framework.print_summary()

    -- Return success/failure for CI/CD
    return test_framework.results.failed == 0
end

--- Run tests from command line
function test_runner.run_from_command_line()
    -- Parse command line arguments for specific modules
    local args = {}
    if arg then
        for i = 1, #arg do
            table.insert(args, arg[i])
        end
    end

    local success
    if #args > 0 then
        -- Run specific modules
        local modules = {}
        for _, module_arg in ipairs(args) do
            -- Convert file names to module names if needed
            if module_arg:match("^test_.*%.lua$") then
                -- Convert test_toml_loader.lua to test.test_toml_loader
                local module_name = "test." .. module_arg:gsub("%.lua$", "")
                table.insert(modules, module_name)
            elseif module_arg:match("^test%.") then
                -- Already a module name like test.test_toml_loader
                table.insert(modules, module_arg)
            else
                -- Assume it's a module name and add test. prefix
                table.insert(modules, "test." .. module_arg)
            end
        end
        success = test_runner.run_specific(modules)
    else
        -- Run all tests
        success = test_runner.run_all()
    end

    -- Exit with appropriate code for CI/CD
    if success then
        os.exit(0)
    else
        os.exit(1)
    end
end

return test_runner