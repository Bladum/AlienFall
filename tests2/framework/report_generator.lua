-- ─────────────────────────────────────────────────────────────────────────
-- REPORT GENERATOR FOR TESTS2
-- Generates comprehensive test reports from HierarchicalSuite results
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Create detailed test reports with statistics and coverage analysis
-- Usage:
--   local reporter = require("tests2.framework.report_generator")
--   reporter:generateReport(suite, coverage, options)
-- ─────────────────────────────────────────────────────────────────────────

local ReportGenerator = {}

-- ─────────────────────────────────────────────────────────────────────────
-- CONSTANTS
-- ─────────────────────────────────────────────────────────────────────────

local SEPARATOR_MAJOR = string.rep("=", 80)
local SEPARATOR_MINOR = string.rep("-", 80)
local SEPARATOR_DOTS = string.rep(".", 80)

local STATUS_PASS = "[PASS]"
local STATUS_FAIL = "[FAIL]"
local STATUS_SKIP = "[SKIP]"
local STATUS_PENDING = "[PENDING]"

-- ─────────────────────────────────────────────────────────────────────────
-- UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Format duration in seconds to readable format
---@param seconds number - duration in seconds
---@return string - formatted duration
local function formatDuration(seconds)
    if seconds < 0.001 then
        return string.format("%.3fms", seconds * 1000)
    elseif seconds < 1 then
        return string.format("%.1fms", seconds * 1000)
    else
        return string.format("%.2fs", seconds)
    end
end

---Format percentage with visual bar
---@param percentage number - percentage (0-100)
---@param width number - bar width
---@return string - formatted bar
local function formatBar(percentage, width)
    width = width or 20
    local filled = math.floor(percentage / 100 * width)
    local bar = string.rep("█", filled) .. string.rep("░", width - filled)
    return string.format("[%s] %6.1f%%", bar, percentage)
end

---Format number with padding
---@param num number - number to format
---@param width number - minimum width
---@return string - padded number
local function formatNum(num, width)
    width = width or 5
    return string.format("%" .. width .. "d", num)
end

-- ─────────────────────────────────────────────────────────────────────────
-- REPORT SECTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Generate header section
---@param title string - report title
---@param subtitle string - optional subtitle
---@return string - formatted header
function ReportGenerator:formatHeader(title, subtitle)
    local lines = {}

    table.insert(lines, "")
    table.insert(lines, SEPARATOR_MAJOR)
    table.insert(lines, title)

    if subtitle then
        table.insert(lines, subtitle)
    end

    table.insert(lines, SEPARATOR_MAJOR)
    table.insert(lines, "")

    return table.concat(lines, "\n")
end

---Generate summary statistics
---@param passed number - tests passed
---@param failed number - tests failed
---@param skipped number - tests skipped
---@param duration number - total duration
---@return string - formatted summary
function ReportGenerator:formatSummary(passed, failed, skipped, duration)
    local total = passed + failed + skipped
    local passRate = total > 0 and (passed / total * 100) or 0

    local lines = {}
    table.insert(lines, "TEST SUMMARY")
    table.insert(lines, SEPARATOR_MINOR)

    table.insert(lines, string.format(
        "  Total:   %s | Passed: %s | Failed: %s | Skipped: %s",
        formatNum(total, 5),
        formatNum(passed, 5),
        formatNum(failed, 5),
        formatNum(skipped, 5)
    ))

    table.insert(lines, string.format(
        "  Pass Rate: %s",
        formatBar(passRate, 30)
    ))

    table.insert(lines, string.format(
        "  Duration: %s",
        formatDuration(duration)
    ))

    table.insert(lines, "")

    return table.concat(lines, "\n")
end

---Generate module coverage report (LEVEL 1)
---@param coverage table - coverage data
---@return string - formatted coverage report
function ReportGenerator:formatModuleCoverage(coverage)
    if not coverage or not coverage.testedMethods then
        return ""
    end

    local lines = {}
    table.insert(lines, "")
    table.insert(lines, "MODULE COVERAGE (LEVEL 1)")
    table.insert(lines, SEPARATOR_MINOR)

    local testedCount = 0
    for _ in pairs(coverage.testedMethods) do
        testedCount = testedCount + 1
    end

    local untestedCount = coverage.untestedMethods and #coverage.untestedMethods or 0
    local totalMethods = testedCount + untestedCount
    local coveragePercent = totalMethods > 0 and (testedCount / totalMethods * 100) or 0

    table.insert(lines, string.format(
        "  Coverage: %s (%d/%d methods)",
        formatBar(coveragePercent, 30),
        testedCount,
        totalMethods
    ))

    -- List tested methods
    if testedCount > 0 then
        table.insert(lines, "")
        table.insert(lines, "  Tested Methods:")
        for methodName, tests in pairs(coverage.testedMethods) do
            local passedCount = 0
            for _, test in ipairs(tests) do
                if test.status == "passed" then
                    passedCount = passedCount + 1
                end
            end
            local status = passedCount == #tests and "✓" or "◐"
            table.insert(lines, string.format(
                "    %s %s (%d/%d tests)",
                status,
                methodName,
                passedCount,
                #tests
            ))
        end
    end

    -- List untested methods
    if untestedCount > 0 then
        table.insert(lines, "")
        table.insert(lines, "  Untested Methods:")
        for _, methodName in ipairs(coverage.untestedMethods or {}) do
            table.insert(lines, string.format("    ✗ %s", methodName))
        end
    end

    table.insert(lines, "")

    return table.concat(lines, "\n")
end

---Generate test results by group
---@param tests table - array of test objects
---@param maxItems number - max items to show
---@return string - formatted results
function ReportGenerator:formatTestResults(tests, maxItems)
    maxItems = maxItems or 50

    local lines = {}
    table.insert(lines, "")
    table.insert(lines, "TEST RESULTS (LEVEL 2)")
    table.insert(lines, SEPARATOR_MINOR)

    -- Group by group name
    local groups = {}
    for _, test in ipairs(tests) do
        local groupName = test.group or "Ungrouped"
        if not groups[groupName] then
            groups[groupName] = {}
        end
        table.insert(groups[groupName], test)
    end

    local itemCount = 0
    for groupName, groupTests in pairs(groups) do
        table.insert(lines, string.format("  %s", groupName))

        for _, test in ipairs(groupTests) do
            if itemCount >= maxItems then
                table.insert(lines, string.format("    ... and %d more tests", #tests - itemCount))
                break
            end

            local status = test.status == "passed" and STATUS_PASS or STATUS_FAIL
            local statusChar = test.status == "passed" and "✓" or "✗"
            local duration = test.duration and formatDuration(test.duration) or "?.???s"

            table.insert(lines, string.format(
                "    %s %s %s (%s)",
                statusChar,
                test.description or "unnamed test",
                test.testCase and "[" .. test.testCase .. "]" or "",
                duration
            ))

            if test.error then
                local errorLines = {}
                for line in test.error:gmatch("[^\n]+") do
                    table.insert(errorLines, "      " .. line)
                end
                for _, errLine in ipairs(errorLines) do
                    table.insert(lines, errLine)
                end
            end

            itemCount = itemCount + 1
        end
    end

    table.insert(lines, "")

    return table.concat(lines, "\n")
end

---Generate error summary
---@param errors table - array of error objects
---@return string - formatted errors
function ReportGenerator:formatErrors(errors)
    if not errors or #errors == 0 then
        return ""
    end

    local lines = {}
    table.insert(lines, "")
    table.insert(lines, "FAILURES SUMMARY")
    table.insert(lines, SEPARATOR_MINOR)

    for i, err in ipairs(errors) do
        table.insert(lines, string.format("  %d. %s (%s)", i, err.test, err.method))
        if err.error then
            local errorLines = {}
            for line in err.error:gmatch("[^\n]+") do
                table.insert(errorLines, "     " .. line)
            end
            for _, errLine in ipairs(errorLines) do
                table.insert(lines, errLine)
            end
        end
        table.insert(lines, "")
    end

    return table.concat(lines, "\n")
end

---Generate performance metrics
---@param tests table - array of test objects
---@return string - formatted metrics
function ReportGenerator:formatPerformance(tests)
    local lines = {}
    table.insert(lines, "")
    table.insert(lines, "PERFORMANCE METRICS")
    table.insert(lines, SEPARATOR_MINOR)

    -- Sort by duration
    local sorted = {}
    for _, test in ipairs(tests) do
        table.insert(sorted, test)
    end

    table.sort(sorted, function(a, b)
        return (a.duration or 0) > (b.duration or 0)
    end)

    table.insert(lines, "  Slowest Tests:")
    for i = 1, math.min(10, #sorted) do
        local test = sorted[i]
        table.insert(lines, string.format(
            "    %d. %s - %s",
            i,
            test.description or "unnamed",
            formatDuration(test.duration or 0)
        ))
    end

    local totalDuration = 0
    for _, test in ipairs(tests) do
        totalDuration = totalDuration + (test.duration or 0)
    end

    table.insert(lines, "")
    table.insert(lines, string.format(
        "  Average Test Duration: %s",
        formatDuration(#tests > 0 and (totalDuration / #tests) or 0)
    ))

    table.insert(lines, "")

    return table.concat(lines, "\n")
end

---Generate complete report
---@param suite table - HierarchicalSuite instance
---@param coverage table - coverage data (optional)
---@param options table - report options {showAll, showPerformance, format}
---@return string - complete formatted report
function ReportGenerator:generateReport(suite, coverage, options)
    options = options or {}

    local report = {}

    -- Header
    table.insert(report, self:formatHeader(
        "TEST REPORT",
        suite.description and "Module: " .. suite.description or nil
    ))

    -- Summary
    local results = suite:getResults()
    table.insert(report, self:formatSummary(
        results.passed,
        results.failed,
        results.skipped,
        results.duration
    ))

    -- Coverage (if available)
    if coverage then
        table.insert(report, self:formatModuleCoverage(coverage))
    end

    -- Test Results
    if options.showAll then
        table.insert(report, self:formatTestResults(suite:getTests()))
    else
        table.insert(report, self:formatTestResults(suite:getTests(), 20))
    end

    -- Errors
    if results.errors and #results.errors > 0 then
        table.insert(report, self:formatErrors(results.errors))
    end

    -- Performance
    if options.showPerformance then
        table.insert(report, self:formatPerformance(suite:getTests()))
    end

    -- Footer
    table.insert(report, SEPARATOR_MAJOR)
    table.insert(report, "")

    return table.concat(report, "\n")
end

-- ─────────────────────────────────────────────────────────────────────────
-- FILE EXPORT
-- ─────────────────────────────────────────────────────────────────────────

---Export report to file
---@param suite table - HierarchicalSuite instance
---@param filepath string - where to save report
---@param options table - report options
---@return boolean - success
function ReportGenerator:exportReport(suite, filepath, options)
    local report = self:generateReport(suite, nil, options or {})

    local file = io.open(filepath, "w")
    if not file then
        print("[ERROR] Could not open file: " .. filepath)
        return false
    end

    file:write(report)
    file:close()

    print("[REPORT] Saved to: " .. filepath)
    return true
end

---Export report as JSON
---@param suite table - HierarchicalSuite instance
---@param filepath string - where to save report
---@return boolean - success
function ReportGenerator:exportJSON(suite, filepath)
    local results = suite:getResults()
    local tests = suite:getTests()

    -- Build JSON structure
    local json = {
        summary = {
            passed = results.passed,
            failed = results.failed,
            skipped = results.skipped,
            total = results.passed + results.failed + results.skipped,
            passRate = (results.passed / (results.passed + results.failed + results.skipped) * 100),
            duration = results.duration,
        },
        tests = {}
    }

    for _, test in ipairs(tests) do
        table.insert(json.tests, {
            description = test.description,
            methodName = test.methodName,
            testCase = test.testCase,
            group = test.group,
            status = test.status,
            duration = test.duration,
            error = test.error,
        })
    end

    -- Convert to JSON string (simple)
    local function tableToJSON(t, indent)
        indent = indent or 0
        local spaces = string.rep("  ", indent)
        local nextSpaces = string.rep("  ", indent + 1)

        local lines = {}
        lines[1] = "{"

        local first = true
        for k, v in pairs(t) do
            if not first then table.insert(lines, ",") end
            first = false

            if type(v) == "table" then
                table.insert(lines, string.format('%s"%s": %s', nextSpaces, k, tableToJSON(v, indent + 1)))
            elseif type(v) == "string" then
                table.insert(lines, string.format('%s"%s": "%s"', nextSpaces, k, v))
            elseif type(v) == "number" then
                table.insert(lines, string.format('%s"%s": %s', nextSpaces, k, tostring(v)))
            elseif type(v) == "boolean" then
                table.insert(lines, string.format('%s"%s": %s', nextSpaces, k, v and "true" or "false"))
            end
        end

        table.insert(lines, spaces .. "}")
        return table.concat(lines, "\n")
    end

    local jsonStr = tableToJSON(json)

    local file = io.open(filepath, "w")
    if not file then
        print("[ERROR] Could not open file: " .. filepath)
        return false
    end

    file:write(jsonStr)
    file:close()

    print("[REPORT] JSON saved to: " .. filepath)
    return true
end

return ReportGenerator
