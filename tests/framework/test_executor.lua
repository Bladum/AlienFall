-- Test Framework: Test Executor
-- Executes tests with multiple execution modes

local TestRegistry = require("tests.framework.test_registry")
local ReportGenerator = require("tests.framework.report_generator")

local TestExecutor = {}

---Execute tests with specified filters
function TestExecutor.execute(options)
    options = options or {}

    local mode = options.mode or "all"                    -- all, module, file, specific
    local module = options.module                         -- for module/file modes
    local file = options.file                             -- for file/specific modes
    local testName = options.testName                     -- for specific mode
    local tag = options.tag                               -- for tag filtering
    local coverage = options.coverage or false
    local outputFormat = options.outputFormat or "text"   -- text, json, html

    print("\n" .. string.rep("=", 70))
    print("TEST EXECUTOR")
    print(string.rep("=", 70))
    print("Mode: " .. mode)
    if module then print("Module: " .. module) end
    if file then print("File: " .. file) end
    if testName then print("Test: " .. testName) end
    if tag then print("Tag: " .. tag) end
    print("Coverage: " .. (coverage and "enabled" or "disabled"))
    print(string.rep("=", 70) .. "\n")

    local suites = {}
    local registry = TestRegistry.getAll()

    -- Collect suites based on mode
    if mode == "all" then
        -- Collect all suites
        for category, moduleData in pairs(registry) do
            for mod, fileData in pairs(moduleData) do
                for filename, suiteList in pairs(fileData) do
                    for _, suite in pairs(suiteList) do
                        table.insert(suites, suite)
                    end
                end
            end
        end
    elseif mode == "module" then
        -- Collect suites for specific module
        for category, moduleData in pairs(registry) do
            if moduleData[module] then
                for filename, suiteList in pairs(moduleData[module]) do
                    for _, suite in pairs(suiteList) do
                        table.insert(suites, suite)
                    end
                end
            end
        end
    elseif mode == "file" then
        -- Collect suites for specific file
        for category, moduleData in pairs(registry) do
            for mod, fileData in pairs(moduleData) do
                if fileData[file] then
                    for _, suite in pairs(fileData[file]) do
                        table.insert(suites, suite)
                    end
                end
            end
        end
    elseif mode == "specific" then
        -- Collect specific test (search all suites)
        for category, moduleData in pairs(registry) do
            for mod, fileData in pairs(moduleData) do
                for filename, suiteList in pairs(fileData) do
                    for _, suite in pairs(suiteList) do
                        -- Check if suite has this test
                        for _, test in pairs(suite.tests or {}) do
                            if test.name == testName then
                                table.insert(suites, suite)
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    if #suites == 0 then
        print("✗ No tests found matching criteria")
        return false
    end

    print("Found " .. #suites .. " test suite(s)\n")

    -- Run suites
    local results = {
        suites = {},
        totalPassed = 0,
        totalFailed = 0,
        totalSkipped = 0,
        duration = 0
    }

    local startTime = os.clock()

    for _, suite in ipairs(suites) do
        local suiteResult = {
            name = suite.name,
            passed = 0,
            failed = 0,
            skipped = 0
        }

        -- Run the suite (may filter by tag or test name)
        local suiteSuccess = suite:run(tag)

        local suiteResults = suite:getResults()
        suiteResult.passed = suiteResults.passed
        suiteResult.failed = suiteResults.failed
        suiteResult.skipped = suiteResults.skipped
        suiteResult.errors = suiteResults.errors

        table.insert(results.suites, suiteResult)

        results.totalPassed = results.totalPassed + suiteResults.passed
        results.totalFailed = results.totalFailed + suiteResults.failed
        results.totalSkipped = results.totalSkipped + suiteResults.skipped
    end

    results.duration = os.clock() - startTime

    -- Generate report
    ReportGenerator.generateReport(results, outputFormat)

    -- Print summary
    print("\n" .. string.rep("=", 70))
    print("EXECUTION COMPLETE")
    print(string.rep("=", 70))
    print(string.format("Total: %d passed, %d failed, %d skipped",
        results.totalPassed, results.totalFailed, results.totalSkipped))
    print(string.format("Duration: %.2f seconds", results.duration))
    print(string.rep("=", 70) .. "\n")

    return results.totalFailed == 0
end

---Execute all tests
function TestExecutor.executeAll(options)
    options = options or {}
    options.mode = "all"
    return TestExecutor.execute(options)
end

---Execute module tests
function TestExecutor.executeModule(moduleName, options)
    options = options or {}
    options.mode = "module"
    options.module = moduleName
    return TestExecutor.execute(options)
end

---Execute file tests
function TestExecutor.executeFile(fileName, options)
    options = options or {}
    options.mode = "file"
    options.file = fileName
    return TestExecutor.execute(options)
end

---Execute specific test
function TestExecutor.executeTest(testName, options)
    options = options or {}
    options.mode = "specific"
    options.testName = testName
    return TestExecutor.execute(options)
end

---Execute tests by tag
function TestExecutor.executeByTag(tagName, options)
    options = options or {}
    options.tag = tagName
    return TestExecutor.execute(options)
end

return TestExecutor
