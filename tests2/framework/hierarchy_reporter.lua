-- ─────────────────────────────────────────────────────────────────────────
-- HIERARCHY REPORTER
-- Generates comprehensive reports across all 3 levels:
-- LEVEL 1: Module - Shows which functions are tested
-- LEVEL 2: File - Shows pass/fail statistics
-- LEVEL 3: Method - Shows test case coverage
-- ─────────────────────────────────────────────────────────────────────────

local HierarchyReporter = {}
HierarchyReporter.__index = HierarchyReporter

-- ─────────────────────────────────────────────────────────────────────────
-- CONSTRUCTOR
-- ─────────────────────────────────────────────────────────────────────────

---Create new hierarchy reporter
---@param coverage table Coverage data from CoverageCalculator
function HierarchyReporter:new(coverage)
    local self = setmetatable({}, HierarchyReporter)
    self.coverage = coverage
    return self
end

-- ─────────────────────────────────────────────────────────────────────────
-- FORMATTING HELPERS
-- ─────────────────────────────────────────────────────────────────────────

---Get status icon/symbol
local function getStatusIcon(status)
    if status == "excellent" or status == "passing" or status == "fully_tested" then
        return "[PASS]"
    elseif status == "good" or status == "mostly_passing" or status == "partially_tested" then
        return "[PART]"
    elseif status == "partial" or status == "poorly_tested" then
        return "[WARN]"
    else
        return "[FAIL]"
    end
end

---Get status color (console)
local function getStatusColor(status)
    if status == "excellent" or status == "passing" or status == "fully_tested" then
        return "[PASS]"  -- Green would be nice but we use text
    elseif status == "poor" or status == "failing" or status == "not_tested" then
        return "[FAIL]"  -- Red
    else
        return "[PART]"  -- Yellow/Orange
    end
end

---Format percentage
local function formatPercent(percent)
    return string.format("%.1f%%", percent)
end

---Format bar chart
local function formatBar(percent, width)
    width = width or 20
    local filled = math.floor(percent / 100 * width)
    local bar = string.rep("█", filled) .. string.rep("░", width - filled)
    return string.format("[%s] %s", bar, formatPercent(percent))
end

-- ─────────────────────────────────────────────────────────────────────────
-- LEVEL 1: MODULE REPORT
-- ─────────────────────────────────────────────────────────────────────────

---Generate module coverage report
function HierarchyReporter:reportModules()
    print("\n" .. string.rep("═", 80))
    print("MODULE COVERAGE REPORT (LEVEL 1)")
    print(string.rep("═", 80))

    local modules = self.coverage:getAllModulesCoverage()

    if #modules == 0 then
        print("No modules found")
        return
    end

    print("\n" .. string.format("%-40s | %s | %s", "MODULE", "COVERAGE", "STATUS"))
    print(string.rep("-", 80))

    for _, item in ipairs(modules) do
        local cov = item.coverage
        local icon = getStatusIcon(cov.status)
        local bar = formatBar(cov.percentage, 15)

        print(string.format(
            "%-40s | %s | %s %s",
            item.module:sub(1, 40),
            bar,
            icon,
            cov.status:upper()
        ))

        -- Show untested functions
        if cov.untested > 0 then
            print(string.format("  [WARN] Missing: %d/%d functions", cov.untested, cov.total))
        end
    end

    print(string.rep("═", 80))
end

-- ─────────────────────────────────────────────────────────────────────────
-- LEVEL 2: FILE REPORT
-- ─────────────────────────────────────────────────────────────────────────

---Generate file test results report
function HierarchyReporter:reportFiles()
    print("\n" .. string.rep("═", 80))
    print("FILE TEST RESULTS REPORT (LEVEL 2)")
    print(string.rep("═", 80))

    local files = {}
    for filePath, _ in pairs(self.coverage.files) do
        table.insert(files, filePath)
    end

    if #files == 0 then
        print("No test files found")
        return
    end

    table.sort(files)

    print("\n" .. string.format(
        "%-40s | %s | %s | RESULT",
        "TEST FILE", "TESTS", "DURATION"
    ))
    print(string.rep("-", 80))

    for _, filePath in ipairs(files) do
        local fileCov = self.coverage:getFileCoverage(filePath)
        local icon = getStatusIcon(fileCov.status)

        print(string.format(
            "%-40s | %3d/%3d | %6.3fs | %s",
            filePath:sub(1, 40),
            fileCov.passed,
            fileCov.total,
            fileCov.duration,
            icon
        ))

        -- Show failures
        if fileCov.failed > 0 then
            print(string.format("  [FAIL] Failed: %d tests", fileCov.failed))
        end
    end

    print(string.rep("═", 80))
end

-- ─────────────────────────────────────────────────────────────────────────
-- LEVEL 3: METHOD REPORT
-- ─────────────────────────────────────────────────────────────────────────

---Generate method coverage report for specific module
---@param modulePath string - module to report on
function HierarchyReporter:reportMethodsForModule(modulePath)
    print("\n" .. string.rep("═", 80))
    print(string.format("METHOD COVERAGE FOR: %s (LEVEL 3)", modulePath))
    print(string.rep("═", 80))

    local methods = self.coverage:getModuleMethodsCoverage(modulePath)

    if #methods == 0 then
        print("No method coverage data found for this module")
        return
    end

    print("\n" .. string.format("%-35s | %s | TEST CASES", "METHOD", "COVERAGE"))
    print(string.rep("-", 80))

    for _, item in ipairs(methods) do
        local cov = item.coverage
        local icon = getStatusIcon(cov.status)
        local bar = formatBar(cov.coverage, 15)

        print(string.format(
            "%-35s | %s | %s",
            item.method:sub(1, 35),
            bar,
            icon
        ))

        -- Show test cases
        for testCase, result in pairs(cov.testCases) do
            local testIcon = result.passed and "[PASS]" or "[FAIL]"
            print(string.format("  %s %s", testIcon, testCase))
        end
    end

    print(string.rep("═", 80))
end

-- ─────────────────────────────────────────────────────────────────────────
-- COMPREHENSIVE REPORTS
-- ─────────────────────────────────────────────────────────────────────────

---Generate comprehensive hierarchical report
function HierarchyReporter:reportHierarchy()
    local projectCov = self.coverage:getProjectCoverage()

    print("\n\n")
    print(string.rep("╔", 80))
    print("║ HIERARCHICAL TEST COVERAGE REPORT")
    print("║ " .. os.date("%Y-%m-%d %H:%M:%S"))
    print(string.rep("╚", 80))

    -- PROJECT LEVEL SUMMARY
    print("\n" .. string.rep("┌", 80))
    print(string.format("PROJECT SUMMARY: %.1f%% Coverage", projectCov.percentage))
    print(string.format("Modules: %d/%d | Functions: %d/%d tested",
        projectCov.modules_tested,
        projectCov.modules_total,
        projectCov.functions_tested,
        projectCov.functions_total
    ))
    print(string.rep("└", 80))

    -- LEVEL 1: MODULES
    self:reportModules()

    -- LEVEL 2: FILES
    self:reportFiles()

    -- LEVEL 3: METHODS (for each module with coverage)
    print("\n" .. string.rep("═", 80))
    print("DETAILED METHOD COVERAGE (LEVEL 3)")
    print(string.rep("═", 80))

    local modules = self.coverage:getAllModulesCoverage()
    for _, item in ipairs(modules) do
        if item.coverage.percentage > 0 then
            self:reportMethodsForModule(item.module)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEXT OUTPUT
-- ─────────────────────────────────────────────────────────────────────────

---Generate simple text report
function HierarchyReporter:toText()
    local lines = {}

    table.insert(lines, "HIERARCHICAL TEST COVERAGE REPORT")
    table.insert(lines, "=" .. string.rep("=", 79))

    -- Project overview
    local projectCov = self.coverage:getProjectCoverage()
    table.insert(lines, "")
    table.insert(lines, string.format("Project Coverage: %.1f%%", projectCov.percentage))
    table.insert(lines, string.format("Modules Tested: %d/%d", projectCov.modules_tested, projectCov.modules_total))
    table.insert(lines, string.format("Functions Tested: %d/%d", projectCov.functions_tested, projectCov.functions_total))

    -- Modules
    table.insert(lines, "")
    table.insert(lines, "MODULES:")
    table.insert(lines, "-" .. string.rep("-", 79))
    local modules = self.coverage:getAllModulesCoverage()
    for _, item in ipairs(modules) do
        local cov = item.coverage
        table.insert(lines, string.format("  %s - %.1f%% (%d/%d)",
            item.module,
            cov.percentage,
            cov.tested,
            cov.total
        ))
    end

    return table.concat(lines, "\n")
end

-- ─────────────────────────────────────────────────────────────────────────
-- JSON OUTPUT
-- ─────────────────────────────────────────────────────────────────────────

---Generate JSON report
function HierarchyReporter:toJSON()
    local projectCov = self.coverage:getProjectCoverage()

    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        project = projectCov,
        modules = {},
        files = {},
        methods = {}
    }

    -- Modules
    local modules = self.coverage:getAllModulesCoverage()
    for _, item in ipairs(modules) do
        report.modules[item.module] = item.coverage
    end

    -- Files
    for filePath, _ in pairs(self.coverage.files) do
        report.files[filePath] = self.coverage:getFileCoverage(filePath)
    end

    -- Methods
    for key, method in pairs(self.coverage.methods) do
        report.methods[key] = {
            module = method.module,
            method = method.method,
            coverage = self.coverage:getMethodCoverage(method.module, method.method)
        }
    end

    return report
end

return HierarchyReporter
