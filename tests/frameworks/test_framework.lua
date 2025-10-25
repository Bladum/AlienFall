-- Enhanced Hierarchical Test Framework
-- Provides test discovery, organization, and advanced reporting

local TestFramework = {}

-- Framework configuration
TestFramework.config = {
    verbose = true,
    strict_mode = false,
    coverage_enabled = os.getenv("TEST_COVERAGE") == "1",
    output_format = "console",
    max_parallel_tests = 4,
}

-- Test registry
TestFramework.registry = {
    suites = {},
    total_tests = 0,
    total_passed = 0,
    total_failed = 0,
    total_skipped = 0,
    execution_time = 0,
}

-- Test hierarchy structure
TestFramework.hierarchy = {
    unit = {},
    integration = {},
    system = {},
    performance = {},
    acceptance = {},
}

-- Coverage tracking
TestFramework.coverage = {
    modules_tested = {},
    functions_covered = {},
    lines_covered = {},
    branches_covered = {},
}

-- Test statistics
TestFramework.stats = {
    by_category = {},
    by_module = {},
    by_severity = {},
    slowest_tests = {},
    most_failures = {},
}

---
-- Initialize test framework
---
function TestFramework.init()
    print("\n" .. string.rep("=", 70))
    print("TEST FRAMEWORK INITIALIZATION")
    print(string.rep("=", 70) .. "\n")

    print(string.format("✓ Verbose mode: %s", TestFramework.config.verbose and "ON" or "OFF"))
    print(string.format("✓ Strict mode: %s", TestFramework.config.strict_mode and "ON" or "OFF"))
    print(string.format("✓ Coverage tracking: %s", TestFramework.config.coverage_enabled and "ENABLED" or "DISABLED"))
    print(string.format("✓ Output format: %s", TestFramework.config.output_format))
    print(string.format("✓ Max parallel tests: %d", TestFramework.config.max_parallel_tests))

    print("\n" .. string.rep("-", 70) .. "\n")
end

---
-- Register a test suite
---
function TestFramework.registerSuite(name, category, tests)
    assert(name, "Suite name required")
    assert(category, "Category required")
    assert(type(tests) == "table", "Tests must be a table")

    local suite = {
        name = name,
        category = category,
        tests = tests,
        results = {},
        status = "pending",
        start_time = 0,
        end_time = 0,
        duration = 0,
    }

    TestFramework.registry.suites[name] = suite
    TestFramework.hierarchy[category] = TestFramework.hierarchy[category] or {}
    table.insert(TestFramework.hierarchy[category], suite)

    return suite
end

---
-- Register individual test
---
function TestFramework.registerTest(suite_name, test_name, test_func, options)
    options = options or {}

    local suite = TestFramework.registry.suites[suite_name]
    if not suite then
        error("Suite not found: " .. suite_name)
    end

    local test = {
        name = test_name,
        func = test_func,
        skip = options.skip or false,
        timeout = options.timeout or 5000,
        severity = options.severity or "normal",
        tags = options.tags or {},
        setup = options.setup or function() end,
        teardown = options.teardown or function() end,
    }

    table.insert(suite.tests, test)
    TestFramework.registry.total_tests = TestFramework.registry.total_tests + 1

    return test
end

---
-- Run a single test
---
function TestFramework.runTest(test, suite_name)
    local start_time = os.clock()
    local result = {
        name = test.name,
        suite = suite_name,
        status = "pending",
        error = nil,
        duration = 0,
        assertions = 0,
        passed_assertions = 0,
    }

    -- Skip test if marked
    if test.skip then
        result.status = "skipped"
        TestFramework.registry.total_skipped = TestFramework.registry.total_skipped + 1
        if TestFramework.config.verbose then
            print(string.format("  ⊘ %s (skipped)", test.name))
        end
        return result
    end

    -- Run setup
    local setup_ok, setup_err = pcall(test.setup)
    if not setup_ok then
        result.status = "failed"
        result.error = "Setup failed: " .. tostring(setup_err)
        TestFramework.registry.total_failed = TestFramework.registry.total_failed + 1
        if TestFramework.config.verbose then
            print(string.format("  ✗ %s (setup failed)", test.name))
        end
        return result
    end

    -- Run test
    local test_ok, test_err = pcall(test.func)
    if test_ok then
        result.status = "passed"
        TestFramework.registry.total_passed = TestFramework.registry.total_passed + 1
        if TestFramework.config.verbose then
            print(string.format("  ✓ %s", test.name))
        end
    else
        result.status = "failed"
        result.error = tostring(test_err)
        TestFramework.registry.total_failed = TestFramework.registry.total_failed + 1
        if TestFramework.config.verbose then
            print(string.format("  ✗ %s", test.name))
            if result.error then
                print(string.format("    Error: %s", result.error))
            end
        end
    end

    -- Run teardown
    local teardown_ok, teardown_err = pcall(test.teardown)
    if not teardown_ok then
        result.status = "failed"
        result.error = "Teardown failed: " .. tostring(teardown_err)
        if result.status == "passed" then
            TestFramework.registry.total_failed = TestFramework.registry.total_failed + 1
            TestFramework.registry.total_passed = TestFramework.registry.total_passed - 1
        end
    end

    result.duration = os.clock() - start_time

    -- Track slowest tests
    table.insert(TestFramework.stats.slowest_tests, {
        name = suite_name .. "::" .. test.name,
        duration = result.duration,
    })

    return result
end

---
-- Run a test suite
---
function TestFramework.runSuite(suite_name)
    local suite = TestFramework.registry.suites[suite_name]
    if not suite then
        error("Suite not found: " .. suite_name)
    end

    suite.start_time = os.clock()
    print(string.format("\nRunning suite: %s (%s)", suite.name, suite.category))
    print(string.rep("-", 70))

    for _, test in ipairs(suite.tests) do
        local result = TestFramework.runTest(test, suite_name)
        table.insert(suite.results, result)
    end

    suite.end_time = os.clock()
    suite.duration = suite.end_time - suite.start_time
    suite.status = "complete"

    -- Calculate pass rate
    local passed = 0
    local total = 0
    for _, result in ipairs(suite.results) do
        if result.status ~= "skipped" then
            total = total + 1
            if result.status == "passed" then
                passed = passed + 1
            end
        end
    end

    local pass_rate = total > 0 and (passed / total * 100) or 0
    print(string.format("\nSuite result: %d/%d passed (%.1f%%) in %.3fs",
        passed, total, pass_rate, suite.duration))

    return suite
end

---
-- Run all tests by category
---
function TestFramework.runCategory(category)
    print("\n" .. string.rep("=", 70))
    print(string.format("RUNNING CATEGORY: %s", string.upper(category)))
    print(string.rep("=", 70))

    local suites = TestFramework.hierarchy[category] or {}
    local results = {}

    for _, suite in ipairs(suites) do
        TestFramework.runSuite(suite.name)
        table.insert(results, suite)
    end

    return results
end

---
-- Run all tests
---
function TestFramework.runAll()
    local start_time = os.clock()

    print("\n" .. string.rep("=", 70))
    print("RUNNING ALL TESTS")
    print(string.rep("=", 70))

    for category, suites in pairs(TestFramework.hierarchy) do
        if #suites > 0 then
            TestFramework.runCategory(category)
        end
    end

    TestFramework.registry.execution_time = os.clock() - start_time
end

---
-- Generate test report
---
function TestFramework.generateReport()
    print("\n" .. string.rep("=", 70))
    print("TEST REPORT")
    print(string.rep("=", 70) .. "\n")

    print(string.format("Total Tests: %d", TestFramework.registry.total_tests))
    print(string.format("  ✓ Passed: %d (%.1f%%)",
        TestFramework.registry.total_passed,
        (TestFramework.registry.total_passed / TestFramework.registry.total_tests * 100)))
    print(string.format("  ✗ Failed: %d (%.1f%%)",
        TestFramework.registry.total_failed,
        (TestFramework.registry.total_failed / TestFramework.registry.total_tests * 100)))
    print(string.format("  ⊘ Skipped: %d (%.1f%%)",
        TestFramework.registry.total_skipped,
        (TestFramework.registry.total_skipped / TestFramework.registry.total_tests * 100)))

    print(string.format("\nExecution Time: %.3f seconds", TestFramework.registry.execution_time))

    -- Show slowest tests
    print("\n" .. string.rep("-", 70))
    print("SLOWEST TESTS (Top 10)")
    print(string.rep("-", 70))

    table.sort(TestFramework.stats.slowest_tests, function(a, b)
        return a.duration > b.duration
    end)

    for i = 1, math.min(10, #TestFramework.stats.slowest_tests) do
        local test = TestFramework.stats.slowest_tests[i]
        print(string.format("%2d. %.3fs - %s", i, test.duration, test.name))
    end

    -- Category breakdown
    print("\n" .. string.rep("-", 70))
    print("RESULTS BY CATEGORY")
    print(string.rep("-", 70))

    for category, suites in pairs(TestFramework.hierarchy) do
        if #suites > 0 then
            local total = 0
            local passed = 0

            for _, suite in ipairs(suites) do
                for _, result in ipairs(suite.results) do
                    if result.status ~= "skipped" then
                        total = total + 1
                        if result.status == "passed" then
                            passed = passed + 1
                        end
                    end
                end
            end

            if total > 0 then
                print(string.format("  %s: %d/%d passed (%.1f%%)",
                    category, passed, total, passed / total * 100))
            end
        end
    end

    print("\n" .. string.rep("=", 70) .. "\n")

    return {
        total = TestFramework.registry.total_tests,
        passed = TestFramework.registry.total_passed,
        failed = TestFramework.registry.total_failed,
        skipped = TestFramework.registry.total_skipped,
        duration = TestFramework.registry.execution_time,
    }
end

---
-- Assert helpers for tests
---
function TestFramework.assert(condition, message)
    if not condition then
        error("Assertion failed: " .. (message or "condition is false"))
    end
end

function TestFramework.assertEqual(actual, expected, message)
    if actual ~= expected then
        error(string.format("AssertionError: %s\n  Expected: %s\n  Actual: %s",
            message or "", tostring(expected), tostring(actual)))
    end
end

function TestFramework.assertNotNil(value, message)
    if value == nil then
        error("AssertionError: " .. (message or "value is nil"))
    end
end

function TestFramework.assertType(value, expected_type, message)
    if type(value) ~= expected_type then
        error(string.format("AssertionError: %s\n  Expected type: %s\n  Actual type: %s",
            message or "", expected_type, type(value)))
    end
end

---
-- Get test results
---
function TestFramework.getResults()
    return {
        suites = TestFramework.registry.suites,
        total_tests = TestFramework.registry.total_tests,
        passed = TestFramework.registry.total_passed,
        failed = TestFramework.registry.total_failed,
        skipped = TestFramework.registry.total_skipped,
        duration = TestFramework.registry.execution_time,
    }
end

---
-- Get suite results
---
function TestFramework.getSuiteResults(suite_name)
    local suite = TestFramework.registry.suites[suite_name]
    if not suite then
        return nil
    end

    return {
        name = suite.name,
        category = suite.category,
        results = suite.results,
        status = suite.status,
        duration = suite.duration,
    }
end

---
-- Get failed tests
---
function TestFramework.getFailedTests()
    local failed = {}

    for suite_name, suite in pairs(TestFramework.registry.suites) do
        for _, result in ipairs(suite.results) do
            if result.status == "failed" then
                table.insert(failed, {
                    suite = suite_name,
                    test = result.name,
                    error = result.error,
                })
            end
        end
    end

    return failed
end

---
-- Reset framework
---
function TestFramework.reset()
    TestFramework.registry.suites = {}
    TestFramework.registry.total_tests = 0
    TestFramework.registry.total_passed = 0
    TestFramework.registry.total_failed = 0
    TestFramework.registry.total_skipped = 0
    TestFramework.registry.execution_time = 0
    TestFramework.hierarchy = {
        unit = {},
        integration = {},
        system = {},
        performance = {},
        acceptance = {},
    }
end

return TestFramework
