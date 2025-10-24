---
--- QA (Quality Assurance) System
--- Automated code and documentation quality checking
---
--- Scans Lua files and verifies:
--- - Code style compliance
--- - Documentation completeness
--- - Code complexity metrics
--- - Performance anti-patterns
--- - Security issues
---
--- Generates detailed reports with actionable recommendations
---

local QAEngine = {}

-- ========== CONFIGURATION ==========

QAEngine.config = {
    -- File scanning
    scan_engine_dir = true,
    scan_mods_dir = false,
    scan_tests_dir = false,
    max_files = 300,

    -- Severity levels
    severity = {
        critical = 4,
        high = 3,
        medium = 2,
        low = 1,
        info = 0
    },

    -- Quality thresholds
    max_cyclomatic_complexity = 10,
    max_cognitive_complexity = 15,
    max_function_length = 100,
    max_nesting_depth = 4,
    max_parameter_count = 5,
    max_line_length = 120,
}

QAEngine.issues = {}
QAEngine.metrics = {}
QAEngine.fileCount = 0

-- ========== UTILITY FUNCTIONS ==========

local function logIssue(file, line, severity, category, message)
    table.insert(QAEngine.issues, {
        file = file,
        line = line or 1,
        severity = severity,
        category = category,
        message = message
    })
end

local function countLines(content)
    local count = 0
    for _ in content:gmatch("\n") do
        count = count + 1
    end
    return count + 1
end

local function analyzeCyclomaticComplexity(content)
    local complexity = 1  -- Start at 1 for the function itself

    -- Count decision points
    complexity = complexity + (select(2, content:gsub("if%s", "")))
    complexity = complexity + (select(2, content:gsub("else%s", "")))
    complexity = complexity + (select(2, content:gsub("elseif%s", "")))
    complexity = complexity + (select(2, content:gsub("for%s", "")))
    complexity = complexity + (select(2, content:gsub("while%s", "")))
    complexity = complexity + (select(2, content:gsub("repeat%s", "")))
    complexity = complexity + (select(2, content:gsub("and%s", "")))
    complexity = complexity + (select(2, content:gsub("or%s", "")))

    return complexity
end

local function analyzeLineLength(lines)
    local longLines = {}
    for i, line in ipairs(lines) do
        if #line > QAEngine.config.max_line_length then
            table.insert(longLines, {line = i, length = #line})
        end
    end
    return longLines
end

local function analyzeNestingDepth(content)
    local maxDepth = 0
    local currentDepth = 0
    local depthByLine = {}
    local lineNum = 1

    for line in content:gmatch("[^\n]+") do
        -- Count opening braces/keywords
        for _ in line:gmatch("[{]") do currentDepth = currentDepth + 1 end
        for _ in line:gmatch("do%s") do currentDepth = currentDepth + 1 end
        for _ in line:gmatch("then%s") do currentDepth = currentDepth + 1 end

        depthByLine[lineNum] = currentDepth
        if currentDepth > maxDepth then maxDepth = currentDepth end

        -- Count closing braces/keywords
        for _ in line:gmatch("[}]") do currentDepth = math.max(0, currentDepth - 1) end
        for _ in line:gmatch("end%s") do currentDepth = math.max(0, currentDepth - 1) end

        lineNum = lineNum + 1
    end

    return maxDepth, depthByLine
end

-- ========== STYLE CHECKS ==========

function QAEngine.checkNamingConvention(file, content)
    -- Check for globals (PascalCase or ALL_CAPS without local/self)
    for line in content:gmatch("[^\n]+") do
        -- Skip comments
        if not line:match("^%s*%-%-") then
            -- Check for assignment to uppercase variables (possible globals)
            if line:match("^%s*[A-Z][A-Za-z0-9]*%s*=") and not line:match("^%s*local") then
                if not line:match("self%.") then
                    local var = line:match("^%s*([A-Z][A-Za-z0-9]*)")
                    logIssue(file, 1, "high", "style", "Global variable detected: " .. var)
                end
            end
        end
    end
end

function QAEngine.checkIndentation(file, content)
    local lines = {}
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local indent_size = nil
    for i, line in ipairs(lines) do
        if #line > 0 and line:match("^%s") then
            local spaces = line:match("^(%s+)")
            if spaces then
                local len = #spaces
                if len > 0 and len < 10 then  -- Sanity check
                    if indent_size == nil and len > 0 then
                        -- Detect indent size from first indented line
                        if len % 4 == 0 then
                            indent_size = 4
                        elseif len % 2 == 0 then
                            indent_size = 2
                        end
                    elseif indent_size and len % indent_size ~= 0 and len % 2 ~= 0 then
                        -- Indentation not multiple of detected size
                        logIssue(file, i, "low", "style", "Inconsistent indentation")
                        break
                    end
                end
            end
        end
    end
end

function QAEngine.checkTrailingWhitespace(file, content)
    local count = 0
    local lineNum = 1
    for line in content:gmatch("[^\n]+") do
        if line:match("%s+$") then
            count = count + 1
            if count <= 3 then  -- Only report first few
                logIssue(file, lineNum, "low", "style", "Trailing whitespace detected")
            end
        end
        lineNum = lineNum + 1
    end
    if count > 3 then
        logIssue(file, 1, "low", "style", "Trailing whitespace found in " .. count .. " lines")
    end
end

-- ========== DOCUMENTATION CHECKS ==========

function QAEngine.checkModuleDocstring(file, content)
    local lines = content:gmatch("[^\n]+")
    local firstLine = lines()

    if not firstLine or not firstLine:match("^%-%-%-") then
        logIssue(file, 1, "medium", "documentation", "Module missing docstring header")
    end
end

function QAEngine.checkFunctionDocumentation(file, content)
    local undocFunctions = {}
    local funcCount = 0

    for funcName in content:gmatch("function%s+([a-zA-Z_][a-zA-Z0-9_:]*)") do
        funcCount = funcCount + 1
        -- Very simple check: if no doc before function, it's missing
        if not content:match("%-%-%-.*" .. funcName) then
            table.insert(undocFunctions, funcName)
        end
    end

    if #undocFunctions > 0 and #undocFunctions <= 5 then
        for _, fname in ipairs(undocFunctions) do
            logIssue(file, 1, "medium", "documentation", "Function '" .. fname .. "' may lack documentation")
        end
    elseif #undocFunctions > 5 then
        logIssue(file, 1, "high", "documentation", #undocFunctions .. " functions appear undocumented")
    end
end

-- ========== COMPLEXITY CHECKS ==========

function QAEngine.checkFunctionComplexity(file, content)
    -- Extract functions
    for funcBody in content:gmatch("function%s+[^(]+%(.-%)%s*(.-)%s*end") do
        local complexity = analyzeCyclomaticComplexity(funcBody)
        if complexity > QAEngine.config.max_cyclomatic_complexity then
            logIssue(file, 1, "medium", "complexity",
                string.format("High cyclomatic complexity: %d (max: %d)",
                    complexity, QAEngine.config.max_cyclomatic_complexity))
        end
    end
end

function QAEngine.checkFunctionLength(file, content)
    local lineNum = 1
    for line in content:gmatch("[^\n]+") do
        if line:match("^%s*function%s+") then
            local funcStart = lineNum
            local depth = 0
            local funcEnd = lineNum

            -- Find end of function
            for i = lineNum, lineNum + 500 do
                -- This is simplified; real implementation would be more robust
                if line:match("end%s*$") then
                    funcEnd = i
                    break
                end
            end

            local funcLength = funcEnd - funcStart
            if funcLength > QAEngine.config.max_function_length then
                logIssue(file, funcStart, "medium", "complexity",
                    string.format("Function too long: %d lines (max: %d)",
                        funcLength, QAEngine.config.max_function_length))
            end
        end
        lineNum = lineNum + 1
    end
end

-- ========== PERFORMANCE CHECKS ==========

function QAEngine.checkNestedLoops(file, content)
    local nested = content:match("for%s+.-%s+do%s*.-for%s+.-%s+do")
    if nested then
        logIssue(file, 1, "high", "performance", "Nested loops detected (potential O(n²) operation)")
    end
end

function QAEngine.checkStringConcatenation(file, content)
    local concat = content:match("%.%s*%.%s*%.%s*")  -- .. operator in loop
    if concat then
        logIssue(file, 1, "medium", "performance", "String concatenation in loop detected (use table.concat)")
    end
end

-- ========== SECURITY CHECKS ==========

function QAEngine.checkHardcodedSecrets(file, content)
    if content:match("password%s*=%s*['\"]") or
       content:match("apikey%s*=%s*['\"]") or
       content:match("secret%s*=%s*['\"]") then
        logIssue(file, 1, "critical", "security", "Possible hardcoded secret detected")
    end
end

function QAEngine.checkEval(file, content)
    if content:match("loadstring") or content:match("assert%(load") then
        logIssue(file, 1, "high", "security", "Eval-like operation detected (loadstring/load)")
    end
end

-- ========== ANALYSIS ==========

function QAEngine.analyzeFile(filepath)
    local file = io.open(filepath, "r")
    if not file then
        print("[QA] WARNING: Could not open file: " .. filepath)
        return nil
    end

    local content = file:read("*a")
    file:close()

    local lines = {}
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    -- Run all checks
    QAEngine.checkNamingConvention(filepath, content)
    QAEngine.checkIndentation(filepath, content)
    QAEngine.checkTrailingWhitespace(filepath, content)
    QAEngine.checkModuleDocstring(filepath, content)
    QAEngine.checkFunctionDocumentation(filepath, content)
    QAEngine.checkFunctionComplexity(filepath, content)
    QAEngine.checkFunctionLength(filepath, content)
    QAEngine.checkNestedLoops(filepath, content)
    QAEngine.checkStringConcatenation(filepath, content)
    QAEngine.checkHardcodedSecrets(filepath, content)
    QAEngine.checkEval(filepath, content)

    return {
        filepath = filepath,
        lines = #lines,
        functions = select(2, content:gsub("function%s", "")) + 1,
        size = #content
    }
end

function QAEngine.scanDirectory(dirPath, pattern)
    local files = {}

    -- Use os.execute to find Lua files
    local findCmd = 'dir /s /b "' .. dirPath .. '\\*.lua" 2>nul'
    local pipe = io.popen(findCmd)
    if pipe then
        for line in pipe:lines() do
            if #files < QAEngine.config.max_files then
                table.insert(files, line)
            end
        end
        pipe:close()
    end

    return files
end

-- ========== REPORTING ==========

function QAEngine.generateReport()
    local report = {}

    table.insert(report, "\n")
    table.insert(report, string.rep("=", 60))
    table.insert(report, "ALIENFALL QA REPORT")
    table.insert(report, string.rep("=", 60))
    table.insert(report, "")

    -- Summary
    local criticalCount = 0
    local highCount = 0
    local mediumCount = 0
    local lowCount = 0

    for _, issue in ipairs(QAEngine.issues) do
        if issue.severity == "critical" then criticalCount = criticalCount + 1
        elseif issue.severity == "high" then highCount = highCount + 1
        elseif issue.severity == "medium" then mediumCount = mediumCount + 1
        elseif issue.severity == "low" then lowCount = lowCount + 1
        end
    end

    table.insert(report, "SUMMARY")
    table.insert(report, string.format("  Files Scanned: %d", QAEngine.fileCount))
    table.insert(report, string.format("  Issues Found: %d", #QAEngine.issues))
    table.insert(report, string.format("    🔴 Critical: %d", criticalCount))
    table.insert(report, string.format("    ⚠️  High: %d", highCount))
    table.insert(report, string.format("    📋 Medium: %d", mediumCount))
    table.insert(report, string.format("    ℹ️  Low: %d", lowCount))
    table.insert(report, "")

    -- Grade calculation
    local grade = "A"
    if criticalCount > 0 then grade = "F"
    elseif highCount > 5 then grade = "D"
    elseif highCount > 0 then grade = "C"
    elseif mediumCount > 10 then grade = "B-"
    elseif mediumCount > 5 then grade = "B"
    elseif mediumCount > 0 then grade = "B+"
    elseif lowCount > 10 then grade = "A-"
    end

    table.insert(report, "CODE GRADE: " .. grade)
    table.insert(report, "")

    -- Issues by category
    local categories = {}
    for _, issue in ipairs(QAEngine.issues) do
        if not categories[issue.category] then
            categories[issue.category] = {}
        end
        table.insert(categories[issue.category], issue)
    end

    table.insert(report, "ISSUES BY CATEGORY:")
    for category, issues in pairs(categories) do
        table.insert(report, string.format("  %s: %d issues", category, #issues))
    end
    table.insert(report, "")

    -- Top files with issues
    local fileIssues = {}
    for _, issue in ipairs(QAEngine.issues) do
        if not fileIssues[issue.file] then
            fileIssues[issue.file] = 0
        end
        fileIssues[issue.file] = fileIssues[issue.file] + 1
    end

    local topFiles = {}
    for file, count in pairs(fileIssues) do
        table.insert(topFiles, {file = file, count = count})
    end
    table.sort(topFiles, function(a, b) return a.count > b.count end)

    if #topFiles > 0 then
        table.insert(report, "TOP FILES WITH ISSUES:")
        for i = 1, math.min(10, #topFiles) do
            table.insert(report, string.format("  %d. %s (%d issues)", i, topFiles[i].file, topFiles[i].count))
        end
        table.insert(report, "")
    end

    -- Detailed issues
    table.insert(report, "DETAILED ISSUES:")
    for i, issue in ipairs(QAEngine.issues) do
        if i <= 50 then  -- Limit to first 50
            table.insert(report, string.format("[%s] %s:%d - %s: %s",
                issue.severity:upper(), issue.file, issue.line, issue.category, issue.message))
        end
    end

    if #QAEngine.issues > 50 then
        table.insert(report, string.format("... and %d more issues", #QAEngine.issues - 50))
    end

    table.insert(report, "")
    table.insert(report, string.rep("=", 60))

    return table.concat(report, "\n")
end

-- ========== MAIN ==========

function QAEngine.run(engineDir)
    engineDir = engineDir or "engine"

    print("[QA] Starting quality analysis of: " .. engineDir)

    -- Clear previous results
    QAEngine.issues = {}
    QAEngine.fileCount = 0

    -- Scan files
    local files = QAEngine.scanDirectory(engineDir)

    print("[QA] Found " .. #files .. " files to analyze")

    for _, filepath in ipairs(files) do
        QAEngine.analyzeFile(filepath)
        QAEngine.fileCount = QAEngine.fileCount + 1
    end

    print("[QA] Analysis complete. Found " .. #QAEngine.issues .. " issues")

    -- Generate and print report
    local report = QAEngine.generateReport()
    print(report)

    return report
end

return QAEngine
