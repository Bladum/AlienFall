-- Test Framework: TestSuite Base Class
-- Provides structure for organizing and running tests

local Assertions = require("tests.framework.assertions")

local TestSuite = {}
TestSuite.__index = TestSuite

---Create a new test suite
function TestSuite:new(name)
    local self = setmetatable({}, TestSuite)

    self.name = name or "Unnamed Suite"
    self.tests = {}
    self.groups = {}
    self.beforeAllFn = nil
    self.afterAllFn = nil
    self.beforeEachFn = nil
    self.afterEachFn = nil
    self.results = {
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = {}
    }

    return self
end

---Define a test case
function TestSuite:test(name, optionsOrFn, fnIfTable)
    local fn
    local options = {}

    -- Handle both signatures: test(name, fn) and test(name, options, fn)
    if type(optionsOrFn) == "function" then
        fn = optionsOrFn
    else
        options = optionsOrFn or {}
        fn = fnIfTable
    end

    if not fn then
        error("Test function required for test: " .. name)
    end

    table.insert(self.tests, {
        name = name,
        fn = fn,
        skip = options.skip or false,
        tag = options.tag,
        timeout = options.timeout or 30
    })
end

---Skip a test (alias for test with skip option)
function TestSuite:skip(name, fn)
    self:test(name, {skip = true}, fn)
end

---Run code before all tests in this suite
function TestSuite:before(fn)
    self.beforeAllFn = fn
end

---Run code after all tests in this suite
function TestSuite:after(fn)
    self.afterAllFn = fn
end

---Run code before each test
function TestSuite:beforeEach(fn)
    self.beforeEachFn = fn
end

---Run code after each test
function TestSuite:afterEach(fn)
    self.afterEachFn = fn
end

---Group tests together (for organization/documentation)
function TestSuite:describe(groupName, fn)
    local startCount = #self.tests
    fn()
    local endCount = #self.tests

    -- Mark tests added within this group
    for i = startCount + 1, endCount do
        self.tests[i].group = groupName
    end
end

---Execute all tests in this suite
function TestSuite:run(filterTag)
    print("\n" .. string.rep("=", 60))
    print("Test Suite: " .. self.name)
    print(string.rep("=", 60))

    Assertions.resetStats()

    -- Run global setup
    if self.beforeAllFn then
        local ok, err = pcall(self.beforeAllFn)
        if not ok then
            print("✗ SUITE SETUP FAILED: " .. tostring(err))
            return false
        end
    end

    local testCount = 0
    local currentGroup = nil

    -- Run each test
    for _, test in ipairs(self.tests) do
        -- Filter by tag if provided
        if filterTag and test.tag ~= filterTag then
            goto skip_test
        end

        testCount = testCount + 1

        -- Print group header if changed
        if test.group and test.group ~= currentGroup then
            currentGroup = test.group
            print("\n  " .. currentGroup .. ":")
        end

        -- Handle skipped tests
        if test.skip then
            print("  ⊗ " .. test.name .. " (skipped)")
            self.results.skipped = self.results.skipped + 1
            goto skip_test
        end

        -- Run setup for this test
        if self.beforeEachFn then
            local ok, err = pcall(self.beforeEachFn)
            if not ok then
                print("  ✗ " .. test.name .. " (setup failed)")
                print("    Error: " .. tostring(err))
                self.results.failed = self.results.failed + 1
                table.insert(self.results.errors, {
                    test = test.name,
                    error = "Setup failed: " .. tostring(err)
                })
                goto skip_test
            end
        end

        -- Run the test
        local startTime = os.clock()
        local ok, err = pcall(test.fn)
        local duration = os.clock() - startTime

        if ok then
            print("  ✓ " .. test.name .. string.format(" (%.3fs)", duration))
            self.results.passed = self.results.passed + 1
        else
            print("  ✗ " .. test.name .. " (FAILED)")
            print("    Error: " .. tostring(err))
            self.results.failed = self.results.failed + 1
            table.insert(self.results.errors, {
                test = test.name,
                error = tostring(err)
            })
        end

        -- Run teardown for this test
        if self.afterEachFn then
            local ok2, err2 = pcall(self.afterEachFn)
            if not ok2 then
                print("    Teardown Error: " .. tostring(err2))
                if ok then
                    self.results.failed = self.results.failed + 1
                    self.results.passed = self.results.passed - 1
                    table.insert(self.results.errors, {
                        test = test.name,
                        error = "Teardown failed: " .. tostring(err2)
                    })
                end
            end
        end

        ::skip_test::
    end

    -- Run global teardown
    if self.afterAllFn then
        local ok, err = pcall(self.afterAllFn)
        if not ok then
            print("✗ SUITE TEARDOWN FAILED: " .. tostring(err))
            return false
        end
    end

    -- Print summary
    print("\n" .. string.rep("-", 60))
    print(string.format("Summary: %d passed, %d failed, %d skipped",
        self.results.passed, self.results.failed, self.results.skipped))

    local stats = Assertions.getStats()
    print(string.format("Assertions: %d total, %d failures", stats.total, stats.failures))
    print(string.rep("-", 60) .. "\n")

    return self.results.failed == 0
end

---Get test results
function TestSuite:getResults()
    return self.results
end

---Create a global test case class for simpler usage
_G.TestCase = TestSuite

return TestSuite
