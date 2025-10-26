-- ─────────────────────────────────────────────────────────────────────────
-- HIERARCHICAL TEST SUITE
-- Framework dla wielopoziomowych testów (Moduł → Plik → Metoda)
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Provides structured test hierarchy with coverage tracking
-- Usage:
--   local suite = HierarchicalSuite:new({
--     modulePath = "engine.core.state_manager",
--     description = "State management system tests"
--   })
--
--   suite:group("Init", function()
--     suite:testMethod("StateManager:new", {...}, function()
--       assert(true)
--     end)
--   end)
--
--   suite:run()
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = {}
HierarchicalSuite.__index = HierarchicalSuite

-- ─────────────────────────────────────────────────────────────────────────
-- CONSTRUCTORS
-- ─────────────────────────────────────────────────────────────────────────

---Create new hierarchical test suite
---@param config table {modulePath, description, fileName}
function HierarchicalSuite:new(config)
    config = config or {}

    local self = setmetatable({}, HierarchicalSuite)

    -- IDENTYFIKACJA (POZIOM 1: MODUŁ)
    self.modulePath = config.modulePath or "unknown.module"
    self.fileName = config.fileName or "unknown_test.lua"
    self.description = config.description or ""

    -- STRUKTURA TESTÓW
    self.groups = {}           -- Grupy testów (organizacja)
    self.currentGroup = nil    -- Aktualnie budowana grupa
    self.tests = {}            -- Wszystkie testy (płasko)
    self.methodMap = {}        -- Mapa: funkcja -> testy

    -- LIFECYCLE HOOKS
    self.beforeAllFn = nil
    self.afterAllFn = nil
    self.beforeEachFn = nil
    self.afterEachFn = nil

    -- RESULTS (POZIOM 2: PLIK)
    self.results = {
        passed = 0,
        failed = 0,
        skipped = 0,
        duration = 0,
        errors = {},
        methodResults = {}  -- Rezultaty per metoda
    }

    -- COVERAGE TRACKING (POZIOM 3: METODA)
    self.coverage = {
        testedMethods = {},     -- Metody które mają testy
        untestedMethods = {},   -- Metody bez testów
        methodCases = {}        -- Test cases per metoda
    }

    return self
end

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP & TEST ORGANIZATION
-- ─────────────────────────────────────────────────────────────────────────

---Define group of tests (for organization/documentation)
---@param groupName string - nazwa grupy testów
---@param fn function - funkcja definiująca testy w grupie
function HierarchicalSuite:group(groupName, fn)
    print(string.format("[HierarchicalSuite] Creating group: %s", groupName))

    local groupId = #self.groups + 1
    local group = {
        id = groupId,
        name = groupName,
        tests = {},
        coverage = 0,
        -- Per-group lifecycle hooks
        beforeEachFn = nil,
        afterEachFn = nil
    }

    table.insert(self.groups, group)

    -- Ustaw bieżącą grupę
    local prevGroup = self.currentGroup
    local prevBeforeEachFn = self.beforeEachFn
    local prevAfterEachFn = self.afterEachFn

    self.currentGroup = group
    -- Reset suite-level hooks for group scope
    self.beforeEachFn = nil
    self.afterEachFn = nil

    -- Wykonaj function definiującą testy
    fn()

    -- Store group-level hooks
    group.beforeEachFn = self.beforeEachFn
    group.afterEachFn = self.afterEachFn

    -- Restore previous context
    self.currentGroup = prevGroup
    self.beforeEachFn = prevBeforeEachFn
    self.afterEachFn = prevAfterEachFn
end

---Define test for specific method/function
---@param methodName string - nazwa metody (np "StateManager:new")
---@param config table|function - {description, testCase, type, functionPath, ...}
---@param testFn function|nil - funkcja testu
function HierarchicalSuite:testMethod(methodName, config, testFn)
    -- Handle both testMethod(name, function) and testMethod(name, config, function)
    if type(config) == "function" then
        testFn = config
        config = {description = "Test"}
    else
        config = config or {}
    end

    local test = {
        -- POZIOM 3: METODA
        methodName = methodName,          -- Która metoda: "StateManager:new"
        testCase = config.testCase or "default",  -- Jaki case: "happy_path", "error", "edge"
        description = config.description or "",

        -- METADATA
        type = config.type or "functional",  -- functional, validation, error_handling, edge_case
        functionPath = config.functionPath,

        -- GRUPA
        group = self.currentGroup and self.currentGroup.name or "Ungrouped",

        -- FUNKCJA TESTU
        fn = testFn,

        -- TRACKING
        status = "pending",
        duration = 0,
        error = nil
    }

    table.insert(self.tests, test)

    -- Add to method map
    if not self.methodMap[methodName] then
        self.methodMap[methodName] = {}
    end
    table.insert(self.methodMap[methodName], test)

    -- Add to current group
    if self.currentGroup then
        table.insert(self.currentGroup.tests, test)
    end
end

---Define test with options
---@param name string - nazwa testu
---@param options table - {skip, tag, timeout, ...}
---@param fn function - funkcja testu
function HierarchicalSuite:test(name, options, fn)
    if type(options) == "function" then
        fn = options
        options = {}
    end

    options = options or {}

    if options.skip then
        -- Skip test
        return
    end

    self:testMethod(name, options, fn)
end

---Skip test
function HierarchicalSuite:skip(name, fn)
    -- Do nothing - just skip
end

-- ─────────────────────────────────────────────────────────────────────────
-- LIFECYCLE HOOKS
-- ─────────────────────────────────────────────────────────────────────────

---Run code before all tests (module level)
function HierarchicalSuite:before(fn)
    self.beforeAllFn = fn
end

---Run code after all tests (module level)
function HierarchicalSuite:after(fn)
    self.afterAllFn = fn
end

---Run code before each test
function HierarchicalSuite:beforeEach(fn)
    self.beforeEachFn = fn
end

---Run code after each test
function HierarchicalSuite:afterEach(fn)
    self.afterEachFn = fn
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST EXECUTION & RESULTS
-- ─────────────────────────────────────────────────────────────────────────

---Run all tests in suite
---@return boolean - true if all passed
function HierarchicalSuite:run()
    print("\n" .. string.rep("=", 70))
    print("HIERARCHICAL TEST SUITE")
    print("=" .. string.rep("=", 69))
    print(string.format("MODULE: %s", self.modulePath))
    print(string.format("FILE: %s", self.fileName))
    if self.description ~= "" then
        print(string.format("DESC: %s", self.description))
    end
    print(string.rep("=", 70))

    local startTime = os.clock()

    -- BEFORE ALL HOOK (Module setup)
    if self.beforeAllFn then
        print("\n[MODULE SETUP]")
        local ok, err = pcall(self.beforeAllFn)
        if not ok then
            print("[FAIL] Module setup failed: " .. tostring(err))
            return false
        end
    end

    -- Run tests grouped
    local currentGroup = nil
    local currentGroupObj = nil

    for _, test in ipairs(self.tests) do
        -- Print group header when changed
        if test.group ~= currentGroup then
            currentGroup = test.group
            print(string.format("\n[%s]", currentGroup))

            -- Find group object
            for _, grp in ipairs(self.groups) do
                if grp.name == currentGroup then
                    currentGroupObj = grp
                    break
                end
            end
        end

        -- BEFORE EACH (use group-level hook if available)
        local beforeEachFn = currentGroupObj and currentGroupObj.beforeEachFn or self.beforeEachFn
        if beforeEachFn then
            local ok, err = pcall(beforeEachFn)
            if not ok then
                print(string.format("  [FAIL] %s (setup failed)", test.description))
                test.status = "failed"
                test.error = "Setup failed: " .. tostring(err)
                self.results.failed = self.results.failed + 1
                goto continue
            end
        end

        -- RUN TEST
        local testStart = os.clock()
        local ok, err = pcall(test.fn)
        test.duration = os.clock() - testStart

        if ok then
            print(string.format("  [PASS] %s (%.3fs)", test.description, test.duration))
            test.status = "passed"
            self.results.passed = self.results.passed + 1

            -- Track tested methods
            if not self.coverage.testedMethods[test.methodName] then
                self.coverage.testedMethods[test.methodName] = {}
            end
            table.insert(self.coverage.testedMethods[test.methodName], test)
        else
            print(string.format("  [FAIL] %s (FAILED)", test.description))
            print(string.format("    Error: %s", tostring(err)))
            test.status = "failed"
            test.error = tostring(err)
            self.results.failed = self.results.failed + 1
            table.insert(self.results.errors, {
                test = test.description,
                method = test.methodName,
                error = tostring(err)
            })
        end

        -- AFTER EACH (use group-level hook if available)
        local afterEachFn = currentGroupObj and currentGroupObj.afterEachFn or self.afterEachFn
        if afterEachFn then
            local ok2, err2 = pcall(afterEachFn)
            if not ok2 then
                print(string.format("    Teardown error: %s", tostring(err2)))
                if ok then
                    self.results.failed = self.results.failed + 1
                    self.results.passed = self.results.passed - 1
                    test.status = "failed"
                    test.error = "Teardown failed: " .. tostring(err2)
                end
            end
        end

        ::continue::
    end

    -- AFTER ALL HOOK (Module cleanup)
    if self.afterAllFn then
        print("\n[MODULE CLEANUP]")
        local ok, err = pcall(self.afterAllFn)
        if not ok then
            print("[FAIL] Module cleanup failed: " .. tostring(err))
        end
    end

    self.results.duration = os.clock() - startTime

    -- PRINT SUMMARY (POZIOM PLIKU)
    self:printSummary()

    -- PRINT COVERAGE (POZIOM METODY)
    self:printCoverage()

    return self.results.failed == 0
end

---Print test summary (File level)
function HierarchicalSuite:printSummary()
    print("\n" .. string.rep("-", 70))
    print("TEST SUMMARY (FILE LEVEL)")
    print(string.rep("-", 70))

    local total = self.results.passed + self.results.failed + self.results.skipped
    local passRate = total > 0 and (self.results.passed / total * 100) or 0

    print(string.format("Total Tests: %d", total))
    print(string.format("[PASS] Passed: %d", self.results.passed))
    print(string.format("[FAIL] Failed: %d", self.results.failed))
    print(string.format("[SKIP] Skipped: %d", self.results.skipped))
    print(string.format("Pass Rate: %.1f%%", passRate))
    print(string.format("Duration: %.3fs", self.results.duration))

    if #self.results.errors > 0 then
        print("\n[FAILURES]:")
        for _, err in ipairs(self.results.errors) do
            print(string.format("  - %s (%s)", err.test, err.method))
        end
    end

    print(string.rep("-", 70) .. "\n")
end

---Print coverage report (Method level)
function HierarchicalSuite:printCoverage()
    print("COVERAGE REPORT (METHOD LEVEL)")
    print(string.rep("-", 70))

    print("\n[PASS] TESTED METHODS:")
    for methodName, tests in pairs(self.coverage.testedMethods) do
        print(string.format("  - %s (%d tests)", methodName, #tests))
        for _, test in ipairs(tests) do
            local status = test.status == "passed" and "[PASS]" or "[FAIL]"
            print(string.format("    %s %s [%s]", status, test.description, test.testCase))
        end
    end

    if #self.coverage.untestedMethods > 0 then
        print("\n[NOT TESTED] METHODS:")
        for _, methodName in ipairs(self.coverage.untestedMethods) do
            print(string.format("  - %s", methodName))
        end
    end

    print(string.rep("-", 70) .. "\n")
end

-- ─────────────────────────────────────────────────────────────────────────
-- GETTERS
-- ─────────────────────────────────────────────────────────────────────────

---Get test results
function HierarchicalSuite:getResults()
    return self.results
end

---Get coverage data
function HierarchicalSuite:getCoverage()
    return self.coverage
end

---Get all tests
function HierarchicalSuite:getTests()
    return self.tests
end

---Get tests for specific method
function HierarchicalSuite:getMethodTests(methodName)
    return self.methodMap[methodName] or {}
end

return HierarchicalSuite
