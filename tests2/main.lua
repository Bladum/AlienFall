-- ─────────────────────────────────────────────────────────────────────────
-- MAIN ENTRY POINT FOR tests2 - Hierarchical Test Suite
-- ─────────────────────────────────────────────────────────────────────────
-- Usage: lovec tests2 run example_counter (from project root)
-- ─────────────────────────────────────────────────────────────────────────

function love.load()
    print("\n" .. string.rep("═", 80))
    print("AlienFall Test Suite 2 - Wielopoziomowy System Testów")
    print(string.rep("═", 80))

    -- Get arguments from love.arg
    -- arg[1] = "tests2" (the folder)
    -- arg[2] = "run" (the command) or first argument if no command
    -- arg[3] = test name (if command provided)
    local cmd = arg[2] or "help"
    cmd = cmd:lower()

    -- Handle different modes
    if cmd == "help" or cmd == "" then
        printHelp()
    elseif cmd == "run" then
        runTests(arg[3])
    elseif cmd == "analyze" then
        analyzeEngine()
    elseif cmd == "coverage" then
        showCoverage()
    elseif cmd == "scaffold" then
        scaffoldModule(arg[3])
    else
        -- Treat as test file to run
        runTests(cmd)
    end

    -- Exit after execution
    love.event.quit()
end

-- ─────────────────────────────────────────────────────────────────────────

function printHelp()
    print([[

USAGE: lovec tests2 [MODE] [OPTIONS]

MODES:

  help                - Show this help message

  run [TEST_FILE]     - Run test suite
                        Example: lovec tests2 run tests2/core/state_manager_test.lua
                        Example: lovec tests2 run core  (run all tests in core/)

  analyze             - Analyze engine/ structure and find all functions

  coverage            - Show coverage report

  scaffold [MODULE]   - Create test template for module
                        Example: lovec tests2 scaffold engine.core.state_manager

EXAMPLES:

  # Run all tests in core/
  lovec tests2 run core

  # Run specific test file
  lovec tests2 run tests2/core/state_manager_test.lua

  # Show coverage report
  lovec tests2 coverage

  # Create test template for module
  lovec tests2 scaffold engine.core.state_manager

  # Analyze engine structure
  lovec tests2 analyze

ARCHITECTURE:

  tests2/
  ├─ framework/          - Core test framework
  ├─ generators/         - Test generation tools
  ├─ core/              - Tests for engine/core/
  ├─ battlescape/       - Tests for engine/battlescape/
  ├─ geoscape/          - Tests for engine/geoscape/
  ├─ basescape/         - Tests for engine/basescape/
  ├─ utils/             - Test utilities
  └─ reports/           - Generated reports

DOCUMENTATION:

  - README.md                      - Quick start guide
  - HIERARCHY_SPEC.md              - Specification
  - ANALYSIS_AND_PROPOSAL.md       - Full analysis
  - framework/hierarchical_suite.lua - Framework docs

]])
end

-- ─────────────────────────────────────────────────────────────────────────

function runTests(testPath)
    print("\n[TEST RUNNER] Starting test execution...")

    if not testPath then
        print("ERROR: No test path specified")
        print("Usage: lovec tests2 run example_counter")
        return
    end

    -- Build module path from test name
    -- Check if it's a specific folder test
    local modulePath
    if testPath == "geoscape" then
        modulePath = "tests2.geoscape"
    elseif testPath == "ai" then
        modulePath = "tests2.ai"
    elseif testPath == "basescape" then
        modulePath = "tests2.basescape"
    elseif testPath == "economy" then
        modulePath = "tests2.economy"
    elseif testPath == "politics" then
        modulePath = "tests2.politics"
    elseif testPath == "lore" then
        modulePath = "tests2.lore"
    elseif testPath:match("^geoscape/") or testPath:match("mission_manager") or testPath:match("difficulty_system") or testPath:match("faction_system") or testPath:match("campaign_manager") or testPath:match("progression_manager") or testPath:match("world_system") or testPath:match("country_manager") or testPath:match("biome") or testPath:match("terror") then
        modulePath = "tests2.geoscape." .. testPath:gsub("/", ".")
    elseif testPath:match("^ai/") or testPath:match("ai_coordinator") or testPath:match("strategic_planner") then
        modulePath = "tests2.ai." .. testPath:gsub("/", ".")
    elseif testPath:match("^battlescape/") or testPath:match("^combat_mechanics") or testPath:match("^movement_3d") then
        modulePath = "tests2.battlescape." .. testPath:gsub("/", ".")
    elseif testPath:match("^basescape/") or testPath:match("base_manager") then
        modulePath = "tests2.basescape." .. testPath:gsub("/", ".")
    elseif testPath:match("^economy/") or testPath:match("economy") or testPath:match("manufacturing") or testPath:match("financial") or testPath:match("research") then
        modulePath = "tests2.economy." .. testPath:gsub("/", ".")
    elseif testPath:match("^politics/") or testPath:match("reputation") or testPath:match("fame") or testPath:match("karma") then
        modulePath = "tests2.politics." .. testPath:gsub("/", ".")
    elseif testPath:match("^lore/") or testPath:match("event_system") then
        modulePath = "tests2.lore." .. testPath:gsub("/", ".")
    else
        modulePath = "tests2.core." .. testPath:gsub("/", ".")
    end

    if not testPath:match("_test$") and testPath ~= "geoscape" and testPath ~= "ai" and testPath ~= "basescape" and testPath ~= "economy" and testPath ~= "politics" and testPath ~= "lore" then
        modulePath = modulePath .. "_test"
    end

    -- Load and run test
    local ok, result = pcall(function()
        local testModule = require(modulePath)

        print("\n" .. string.rep("═", 80))

        if testModule.run then
            return testModule:run()
        else
            return testModule
        end
    end)

    if ok then
        print("[TEST RUNNER] Test execution completed successfully")
    else
        print("[TEST RUNNER] ERROR: " .. tostring(result))
    end
end

-- ─────────────────────────────────────────────────────────────────────────

function analyzeEngine()
    print("\n[ANALYZER] Scanning engine/ structure...")
    print("[ANALYZER] This feature will analyze all modules and find functions")
    print("[ANALYZER] Coming soon - scaffold generator will use this")
end

-- ─────────────────────────────────────────────────────────────────────────

function showCoverage()
    print("\n[COVERAGE] Generating coverage report...")
    print("[COVERAGE] This will read all test results and generate reports")
    print("[COVERAGE] Coming soon - coverage matrix will be generated")
end

-- ─────────────────────────────────────────────────────────────────────────

function scaffoldModule(modulePath)
    print("\n[SCAFFOLD] Creating test template for: " .. tostring(modulePath))
    print("[SCAFFOLD] This will generate a skeleton test file")
    print("[SCAFFOLD] Coming soon - scaffold generator will be implemented")
end

-- ─────────────────────────────────────────────────────────────────────────
-- LOVE2D CALLBACKS
-- ─────────────────────────────────────────────────────────────────────────

function love.update(dt)
    -- No update needed - tests run in love.load
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Test Suite 2 - Check console for output", 10, 10)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
