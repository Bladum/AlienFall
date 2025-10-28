-- Comprehensive Code Quality Assurance System
-- Automated code analysis, metrics, and quality checking

local QASystem = {}

-- QA Configuration
QASystem.config = {
    check_globals = true,
    check_performance = true,
    check_style = true,
    check_coverage = true,
    check_complexity = true,
    check_documentation = true,
    strict_mode = false,
}

-- QA Registry
QASystem.registry = {
    checks = {},
    modules = {},
    issues = {},
    metrics = {},
    reports = {},
}

-- Quality Metrics
QASystem.metrics = {
    total_files = 0,
    total_functions = 0,
    total_lines = 0,
    average_function_length = 0,
    cyclomatic_complexity = 0,
    code_duplication = 0,
    test_coverage = 0,
    documentation_coverage = 0,
}

-- Issue severity levels
QASystem.severity = {
    CRITICAL = 1,
    HIGH = 2,
    MEDIUM = 3,
    LOW = 4,
    INFO = 5,
}

---
-- Initialize QA system
---
function QASystem.init()
    print("\n" .. string.rep("=", 70))
    print("CODE QUALITY ASSURANCE SYSTEM")
    print(string.rep("=", 70) .. "\n")

    print(string.format("✓ Check globals: %s", QASystem.config.check_globals and "ON" or "OFF"))
    print(string.format("✓ Check performance: %s", QASystem.config.check_performance and "ON" or "OFF"))
    print(string.format("✓ Check style: %s", QASystem.config.check_style and "ON" or "OFF"))
    print(string.format("✓ Check coverage: %s", QASystem.config.check_coverage and "ON" or "OFF"))
    print(string.format("✓ Check complexity: %s", QASystem.config.check_complexity and "ON" or "OFF"))
    print(string.format("✓ Check documentation: %s", QASystem.config.check_documentation and "ON" or "OFF"))
    print(string.format("✓ Strict mode: %s", QASystem.config.strict_mode and "ON" or "OFF"))

    print("\n" .. string.rep("-", 70) .. "\n")
end

---
-- Add quality check
---
function QASystem.registerCheck(name, category, check_func)
    local check = {
        name = name,
        category = category,
        func = check_func,
        enabled = true,
    }

    table.insert(QASystem.registry.checks, check)
end

---
-- Register module for analysis
---
function QASystem.registerModule(filepath)
    local module = {
        filepath = filepath,
        issues = {},
        metrics = {},
    }

    QASystem.registry.modules[filepath] = module
end

---
-- Check for global variables
---
function QASystem.checkGlobals(code)
    local issues = {}

    -- Look for global assignments (basic check)
    for line in code:gmatch("[^\n]+") do
        -- Detect potential global variables (not in local scope)
        if line:match("^[A-Za-z_][A-Za-z0-9_]*%s*=") and
           not line:match("^%s*local%s+") and
           not line:match("^%s*function%s+") then
            table.insert(issues, {
                type = "global_variable",
                severity = QASystem.severity.MEDIUM,
                message = "Potential global variable detected",
                line = line:match("^([A-Za-z_][A-Za-z0-9_]*)"),
            })
        end
    end

    return issues
end

---
-- Check code style
---
function QASystem.checkStyle(code)
    local issues = {}
    local line_num = 0

    for line in code:gmatch("[^\n]+") do
        line_num = line_num + 1

        -- Check for trailing whitespace
        if line:match("%s+$") then
            table.insert(issues, {
                type = "trailing_whitespace",
                severity = QASystem.severity.LOW,
                message = "Trailing whitespace",
                line = line_num,
            })
        end

        -- Check for inconsistent indentation
        if line:match("^\t") then
            table.insert(issues, {
                type = "tab_indentation",
                severity = QASystem.severity.LOW,
                message = "Tab character used for indentation (use spaces)",
                line = line_num,
            })
        end

        -- Check for mixed line endings
        if line:match("\r\n$") or line:match("\r$") then
            table.insert(issues, {
                type = "line_ending",
                severity = QASystem.severity.LOW,
                message = "Non-Unix line ending",
                line = line_num,
            })
        end
    end

    return issues
end

---
-- Check for documentation
---
function QASystem.checkDocumentation(code)
    local issues = {}
    local functions = {}
    local documented = 0

    -- Find all functions
    for func_name in code:gmatch("function%s+([A-Za-z_][A-Za-z0-9_.:]*)") do
        table.insert(functions, func_name)
    end

    -- Check for documentation comments
    local documented_count = 0
    for doc_comment in code:gmatch("%-%-%-\n[^}]+function") do
        documented_count = documented_count + 1
    end

    if documented_count < #functions then
        table.insert(issues, {
            type = "missing_documentation",
            severity = QASystem.severity.MEDIUM,
            message = string.format("Missing documentation for %d of %d functions",
                #functions - documented_count, #functions),
            functions = functions,
        })
    end

    return issues, functions
end

---
-- Check code complexity
---
function QASystem.checkComplexity(code)
    local issues = {}

    -- Count cyclomatic complexity (basic check)
    local complexity = 1
    for _ in code:gmatch("if%s+") do
        complexity = complexity + 1
    end
    for _ in code:gmatch("for%s+") do
        complexity = complexity + 1
    end
    for _ in code:gmatch("while%s+") do
        complexity = complexity + 1
    end
    for _ in code:gmatch("elseif%s+") do
        complexity = complexity + 1
    end

    if complexity > 10 then
        table.insert(issues, {
            type = "high_complexity",
            severity = QASystem.severity.MEDIUM,
            message = string.format("High cyclomatic complexity: %d (threshold: 10)", complexity),
            complexity = complexity,
        })
    end

    return issues, complexity
end

---
-- Check for performance issues
---
function QASystem.checkPerformance(code)
    local issues = {}

    -- Check for inefficient patterns
    if code:match("table%.insert.*table%.insert.*table%.insert") then
        table.insert(issues, {
            type = "inefficient_table_operations",
            severity = QASystem.severity.LOW,
            message = "Multiple sequential table.insert calls - consider batch operation",
        })
    end

    -- Check for string concatenation in loops
    if code:match("for.-do.-%.%.") then
        table.insert(issues, {
            type = "string_concat_in_loop",
            severity = QASystem.severity.MEDIUM,
            message = "String concatenation in loop - use table and concat()",
        })
    end

    return issues
end

---
-- Analyze module
---
function QASystem.analyzeModule(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return nil, "Cannot open file: " .. filepath
    end

    local code = file:read("*all")
    file:close()

    local module = QASystem.registry.modules[filepath] or {
        filepath = filepath,
        issues = {},
        metrics = {},
    }

    -- Run checks
    if QASystem.config.check_globals then
        local issues = QASystem.checkGlobals(code)
        for _, issue in ipairs(issues) do
            table.insert(module.issues, issue)
        end
    end

    if QASystem.config.check_style then
        local issues = QASystem.checkStyle(code)
        for _, issue in ipairs(issues) do
            table.insert(module.issues, issue)
        end
    end

    if QASystem.config.check_documentation then
        local issues, functions = QASystem.checkDocumentation(code)
        if #issues > 0 then
            for _, issue in ipairs(issues) do
                table.insert(module.issues, issue)
            end
        end
        module.metrics.functions = functions
        module.metrics.function_count = #functions
    end

    if QASystem.config.check_complexity then
        local issues, complexity = QASystem.checkComplexity(code)
        for _, issue in ipairs(issues) do
            table.insert(module.issues, issue)
        end
        module.metrics.complexity = complexity
    end

    if QASystem.config.check_performance then
        local issues = QASystem.checkPerformance(code)
        for _, issue in ipairs(issues) do
            table.insert(module.issues, issue)
        end
    end

    -- Calculate metrics
    local line_count = select(2, code:gsub("\n", "\n")) + 1
    module.metrics.lines = line_count
    module.metrics.size = #code

    QASystem.registry.modules[filepath] = module

    return module
end

---
-- Run all quality checks
---
function QASystem.runAll(filepaths)
    print("Analyzing code quality...\n")

    local analyzed = 0
    local total_issues = 0

    for _, filepath in ipairs(filepaths) do
        local module, err = QASystem.analyzeModule(filepath)

        if module then
            analyzed = analyzed + 1
            total_issues = total_issues + #module.issues

            if #module.issues > 0 then
                print(string.format("  %s: %d issues", filepath, #module.issues))
            else
                print(string.format("  %s: OK", filepath))
            end
        else
            print(string.format("  %s: ERROR - %s", filepath, err))
        end
    end

    print(string.format("\nAnalyzed %d files, found %d issues\n", analyzed, total_issues))
end

---
-- Generate QA report
---
function QASystem.generateReport()
    print("\n" .. string.rep("=", 70))
    print("CODE QUALITY REPORT")
    print(string.rep("=", 70) .. "\n")

    local total_issues = 0
    local critical = 0
    local high = 0
    local medium = 0
    local low = 0
    local info = 0

    -- Count issues by severity
    for _, module in pairs(QASystem.registry.modules) do
        for _, issue in ipairs(module.issues) do
            total_issues = total_issues + 1
            if issue.severity == QASystem.severity.CRITICAL then
                critical = critical + 1
            elseif issue.severity == QASystem.severity.HIGH then
                high = high + 1
            elseif issue.severity == QASystem.severity.MEDIUM then
                medium = medium + 1
            elseif issue.severity == QASystem.severity.LOW then
                low = low + 1
            else
                info = info + 1
            end
        end
    end

    print("ISSUE SUMMARY")
    print(string.rep("-", 70))
    print(string.format("Total Issues: %d", total_issues))
    print(string.format("  🔴 Critical: %d", critical))
    print(string.format("  🟠 High: %d", high))
    print(string.format("  🟡 Medium: %d", medium))
    print(string.format("  🔵 Low: %d", low))
    print(string.format("  ⚪ Info: %d", info))

    print("\nMODULE ANALYSIS")
    print(string.rep("-", 70))

    for filepath, module in pairs(QASystem.registry.modules) do
        if #module.issues > 0 or module.metrics.lines then
            print(string.format("%s", filepath))
            print(string.format("  Lines: %d | Functions: %d | Complexity: %s | Issues: %d",
                module.metrics.lines or "?",
                module.metrics.function_count or "?",
                tostring(module.metrics.complexity) or "?",
                #module.issues))

            -- Show critical issues
            for _, issue in ipairs(module.issues) do
                if issue.severity == QASystem.severity.CRITICAL then
                    print(string.format("    🔴 [CRITICAL] %s", issue.message))
                end
            end
        end
    end

    print("\n" .. string.rep("=", 70) .. "\n")

    return {
        total = total_issues,
        critical = critical,
        high = high,
        medium = medium,
        low = low,
        info = info,
    }
end

---
-- Get module report
---
function QASystem.getModuleReport(filepath)
    return QASystem.registry.modules[filepath]
end

---
-- Get all issues
---
function QASystem.getAllIssues()
    local issues = {}

    for _, module in pairs(QASystem.registry.modules) do
        for _, issue in ipairs(module.issues) do
            table.insert(issues, {
                module = module.filepath,
                issue = issue,
            })
        end
    end

    return issues
end

---
-- Get issues by severity
---
function QASystem.getIssuesBySeverity(severity)
    local issues = {}

    for _, module in pairs(QASystem.registry.modules) do
        for _, issue in ipairs(module.issues) do
            if issue.severity == severity then
                table.insert(issues, {
                    module = module.filepath,
                    issue = issue,
                })
            end
        end
    end

    return issues
end

---
-- Get quality score (0-100)
---
function QASystem.getQualityScore()
    local total_issues = 0
    local critical_weight = 10
    local high_weight = 5
    local medium_weight = 2
    local low_weight = 1

    local weighted_score = 0

    for _, module in pairs(QASystem.registry.modules) do
        for _, issue in ipairs(module.issues) do
            if issue.severity == QASystem.severity.CRITICAL then
                weighted_score = weighted_score + critical_weight
            elseif issue.severity == QASystem.severity.HIGH then
                weighted_score = weighted_score + high_weight
            elseif issue.severity == QASystem.severity.MEDIUM then
                weighted_score = weighted_score + medium_weight
            elseif issue.severity == QASystem.severity.LOW then
                weighted_score = weighted_score + low_weight
            end
        end
    end

    -- Score is 100 minus issues
    local score = math.max(0, 100 - weighted_score)
    return score
end

return QASystem

