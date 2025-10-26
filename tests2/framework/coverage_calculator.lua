-- ─────────────────────────────────────────────────────────────────────────
-- COVERAGE CALCULATOR
-- Calculates test coverage across 3 levels:
-- LEVEL 1: Module - % of functions tested
-- LEVEL 2: File - % of tests passed
-- LEVEL 3: Method - % of test cases per function
-- ─────────────────────────────────────────────────────────────────────────

local CoverageCalculator = {}
CoverageCalculator.__index = CoverageCalculator

-- ─────────────────────────────────────────────────────────────────────────
-- CONSTRUCTOR
-- ─────────────────────────────────────────────────────────────────────────

---Create new coverage calculator
function CoverageCalculator:new()
    local self = setmetatable({}, CoverageCalculator)

    self.modules = {}  -- {module_path -> {coverage_data}}
    self.files = {}    -- {file_path -> {coverage_data}}
    self.methods = {}  -- {module:method -> {coverage_data}}

    return self
end

-- ─────────────────────────────────────────────────────────────────────────
-- LEVEL 1: MODULE COVERAGE
-- ─────────────────────────────────────────────────────────────────────────

---Register module for tracking
---@param modulePath string - "engine.core.state_manager"
---@param totalFunctions number - total functions in module
function CoverageCalculator:registerModule(modulePath, totalFunctions)
    self.modules[modulePath] = {
        path = modulePath,
        totalFunctions = totalFunctions or 0,
        testedFunctions = 0,
        functions = {},
        status = "unknown"
    }
end

---Mark function as tested
---@param modulePath string - module path
---@param functionName string - function name
function CoverageCalculator:markFunctionTested(modulePath, functionName)
    if not self.modules[modulePath] then
        self:registerModule(modulePath, 0)
    end

    local module = self.modules[modulePath]
    if not module.functions[functionName] then
        module.functions[functionName] = {tested = false}
    end
    module.functions[functionName].tested = true
    module.testedFunctions = self:_countTestedFunctions(module)
end

---Get module coverage percentage
---@param modulePath string - module path
---@return table - {percentage, total, tested, status}
function CoverageCalculator:getModuleCoverage(modulePath)
    local module = self.modules[modulePath]
    if not module then
        return {percentage = 0, total = 0, tested = 0, status = "not_found"}
    end

    local percentage = module.totalFunctions > 0
        and (module.testedFunctions / module.totalFunctions * 100)
        or 0

    -- Determine status
    local status = "poor"
    if percentage >= 80 then status = "excellent"
    elseif percentage >= 60 then status = "good"
    elseif percentage >= 40 then status = "partial"
    end

    return {
        percentage = percentage,
        total = module.totalFunctions,
        tested = module.testedFunctions,
        untested = module.totalFunctions - module.testedFunctions,
        status = status
    }
end

---Get all modules sorted by coverage
---@return table - array of {modulePath, coverage}
function CoverageCalculator:getAllModulesCoverage()
    local results = {}

    for modulePath, module in pairs(self.modules) do
        local coverage = self:getModuleCoverage(modulePath)
        table.insert(results, {
            module = modulePath,
            coverage = coverage
        })
    end

    -- Sort by percentage descending
    table.sort(results, function(a, b)
        return a.coverage.percentage > b.coverage.percentage
    end)

    return results
end

-- ─────────────────────────────────────────────────────────────────────────
-- LEVEL 2: FILE COVERAGE
-- ─────────────────────────────────────────────────────────────────────────

---Register test file
---@param filePath string - "tests2/core/state_manager_test.lua"
---@param modulePath string - "engine.core.state_manager" (what module it tests)
function CoverageCalculator:registerFile(filePath, modulePath)
    self.files[filePath] = {
        path = filePath,
        modulePath = modulePath,
        totalTests = 0,
        passedTests = 0,
        failedTests = 0,
        skippedTests = 0,
        duration = 0
    }
end

---Update file test results
---@param filePath string - test file path
---@param passed number - passed test count
---@param failed number - failed test count
---@param skipped number - skipped test count
---@param duration number - execution duration
function CoverageCalculator:updateFileResults(filePath, passed, failed, skipped, duration)
    if not self.files[filePath] then
        self:registerFile(filePath, "")
    end

    local file = self.files[filePath]
    file.passedTests = passed
    file.failedTests = failed
    file.skippedTests = skipped
    file.totalTests = passed + failed + skipped
    file.duration = duration
end

---Get file coverage
---@param filePath string - test file path
---@return table - {passRate, total, passed, failed, status}
function CoverageCalculator:getFileCoverage(filePath)
    local file = self.files[filePath]
    if not file then
        return {passRate = 0, total = 0, passed = 0, failed = 0, status = "not_found"}
    end

    local passRate = file.totalTests > 0
        and (file.passedTests / file.totalTests * 100)
        or 0

    local status = "failing"
    if passRate == 100 then status = "passing"
    elseif passRate >= 80 then status = "mostly_passing"
    elseif passRate >= 50 then status = "partial"
    end

    return {
        passRate = passRate,
        total = file.totalTests,
        passed = file.passedTests,
        failed = file.failedTests,
        skipped = file.skippedTests,
        duration = file.duration,
        status = status
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- LEVEL 3: METHOD COVERAGE
-- ─────────────────────────────────────────────────────────────────────────

---Register method test case
---@param modulePath string - module path
---@param methodName string - "StateManager:new"
---@param testCase string - "happy_path", "error", "edge_case"
---@param passed boolean - did test pass
function CoverageCalculator:registerMethodTest(modulePath, methodName, testCase, passed)
    local key = modulePath .. ":" .. methodName

    if not self.methods[key] then
        self.methods[key] = {
            module = modulePath,
            method = methodName,
            testCases = {},
            totalTests = 0,
            passedTests = 0
        }
    end

    local method = self.methods[key]
    method.testCases[testCase] = {
        name = testCase,
        passed = passed,
        status = passed and "pass" or "fail"
    }
    method.totalTests = self:_countMethodTests(method)
    method.passedTests = self:_countPassedMethodTests(method)
end

---Get method coverage
---@param modulePath string - module path
---@param methodName string - method name
---@return table - {coverage, total, passed, testCases}
function CoverageCalculator:getMethodCoverage(modulePath, methodName)
    local key = modulePath .. ":" .. methodName
    local method = self.methods[key]

    if not method then
        return {coverage = 0, total = 0, passed = 0, testCases = {}, status = "not_tested"}
    end

    local coverage = method.totalTests > 0
        and (method.passedTests / method.totalTests * 100)
        or 0

    local status = "not_tested"
    if method.totalTests == 0 then status = "not_tested"
    elseif coverage == 100 then status = "fully_tested"
    elseif coverage >= 50 then status = "partially_tested"
    else status = "poorly_tested"
    end

    return {
        coverage = coverage,
        total = method.totalTests,
        passed = method.passedTests,
        testCases = method.testCases,
        status = status
    }
end

---Get all methods for a module
---@param modulePath string - module path
---@return table - array of method coverage data
function CoverageCalculator:getModuleMethodsCoverage(modulePath)
    local results = {}

    for key, method in pairs(self.methods) do
        if method.module == modulePath then
            local coverage = self:getMethodCoverage(modulePath, method.method)
            table.insert(results, {
                method = method.method,
                coverage = coverage
            })
        end
    end

    -- Sort by coverage descending
    table.sort(results, function(a, b)
        return a.coverage.coverage > b.coverage.coverage
    end)

    return results
end

-- ─────────────────────────────────────────────────────────────────────────
-- UTILITIES
-- ─────────────────────────────────────────────────────────────────────────

---Count tested functions in module
local function _countTestedFunctions(self, module)
    local count = 0
    for _, func in pairs(module.functions) do
        if func.tested then count = count + 1 end
    end
    return count
end
CoverageCalculator._countTestedFunctions = _countTestedFunctions

---Count test cases for method
local function _countMethodTests(self, method)
    local count = 0
    for _ in pairs(method.testCases) do count = count + 1 end
    return count
end
CoverageCalculator._countMethodTests = _countMethodTests

---Count passed test cases for method
local function _countPassedMethodTests(self, method)
    local count = 0
    for _, testCase in pairs(method.testCases) do
        if testCase.passed then count = count + 1 end
    end
    return count
end
CoverageCalculator._countPassedMethodTests = _countPassedMethodTests

-- ─────────────────────────────────────────────────────────────────────────
-- REPORTING
-- ─────────────────────────────────────────────────────────────────────────

---Get overall project coverage
---@return table - {percentage, modules_total, modules_tested, status}
function CoverageCalculator:getProjectCoverage()
    local moduleCoverages = self:getAllModulesCoverage()

    local totalModules = #moduleCoverages
    local testedModules = 0
    local totalFunctions = 0
    local testedFunctions = 0

    for _, item in ipairs(moduleCoverages) do
        local cov = item.coverage
        totalFunctions = totalFunctions + cov.total
        testedFunctions = testedFunctions + cov.tested
        if cov.percentage > 0 then
            testedModules = testedModules + 1
        end
    end

    local percentage = totalFunctions > 0
        and (testedFunctions / totalFunctions * 100)
        or 0

    return {
        percentage = percentage,
        modules_total = totalModules,
        modules_tested = testedModules,
        functions_total = totalFunctions,
        functions_tested = testedFunctions,
        status = percentage >= 70 and "good" or "needs_work"
    }
end

---Export coverage as JSON
function CoverageCalculator:toJSON()
    local data = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        project = {coverage = self:getProjectCoverage()},
        modules = {},
        files = {},
        methods = {}
    }

    -- Modules
    for modulePath, module in pairs(self.modules) do
        data.modules[modulePath] = self:getModuleCoverage(modulePath)
    end

    -- Files
    for filePath, _ in pairs(self.files) do
        data.files[filePath] = self:getFileCoverage(filePath)
    end

    -- Methods
    for key, _ in pairs(self.methods) do
        data.methods[key] = self.methods[key]
    end

    return data
end

return CoverageCalculator
