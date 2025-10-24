-- Test Framework: Report Generator
-- Generates test reports in multiple formats

local ReportGenerator = {}

---Generate text report
local function generateTextReport(results)
    local report = {}

    table.insert(report, "\n" .. string.rep("=", 70))
    table.insert(report, "TEST EXECUTION REPORT")
    table.insert(report, string.rep("=", 70))

    table.insert(report, "\nSUMMARY:")
    table.insert(report, string.format("  Total Passed:  %d", results.totalPassed))
    table.insert(report, string.format("  Total Failed:  %d", results.totalFailed))
    table.insert(report, string.format("  Total Skipped: %d", results.totalSkipped))
    table.insert(report, string.format("  Duration:      %.2f seconds", results.duration))

    if results.totalFailed > 0 then
        table.insert(report, "\nFAILED TESTS:")
        for _, suiteResult in ipairs(results.suites) do
            if suiteResult.failed > 0 then
                table.insert(report, "\n  Suite: " .. suiteResult.name)
                if suiteResult.errors then
                    for _, error in ipairs(suiteResult.errors) do
                        table.insert(report, "    - " .. error.test)
                        for line in error.error:gmatch("[^\n]+") do
                            table.insert(report, "      " .. line)
                        end
                    end
                end
            end
        end
    end

    table.insert(report, "\nDETAILS:")
    for _, suiteResult in ipairs(results.suites) do
        local total = suiteResult.passed + suiteResult.failed + suiteResult.skipped
        local percentage = 0
        if total > 0 then
            percentage = (suiteResult.passed / total) * 100
        end
        table.insert(report, string.format("  %s: %d/%d passed (%.1f%%)",
            suiteResult.name, suiteResult.passed, total, percentage))
    end

    table.insert(report, "\n" .. string.rep("=", 70) .. "\n")

    return table.concat(report, "\n")
end

---Generate JSON report
local function generateJsonReport(results)
    -- Simple JSON encoder
    local function jsonEncode(value)
        local t = type(value)

        if t == "nil" then
            return "null"
        elseif t == "boolean" then
            return value and "true" or "false"
        elseif t == "number" then
            return tostring(value)
        elseif t == "string" then
            -- Escape special characters
            return '"' .. value:gsub('\\', '\\\\')
                                :gsub('"', '\\"')
                                :gsub('\n', '\\n')
                                :gsub('\r', '\\r')
                                :gsub('\t', '\\t') .. '"'
        elseif t == "table" then
            -- Check if it's an array
            local isArray = true
            local maxIndex = 0
            for k in pairs(value) do
                if type(k) ~= "number" then
                    isArray = false
                    break
                end
                if k > maxIndex then
                    maxIndex = k
                end
            end

            if isArray then
                -- Array format
                local items = {}
                for i = 1, maxIndex do
                    table.insert(items, jsonEncode(value[i]))
                end
                return "[" .. table.concat(items, ",") .. "]"
            else
                -- Object format
                local items = {}
                for k, v in pairs(value) do
                    table.insert(items, jsonEncode(k) .. ":" .. jsonEncode(v))
                end
                return "{" .. table.concat(items, ",") .. "}"
            end
        else
            return '""'
        end
    end

    local data = {
        summary = {
            totalPassed = results.totalPassed,
            totalFailed = results.totalFailed,
            totalSkipped = results.totalSkipped,
            duration = results.duration
        },
        suites = results.suites
    }

    return jsonEncode(data)
end

---Generate HTML report
local function generateHtmlReport(results)
    local html = {}

    table.insert(html, "<!DOCTYPE html>")
    table.insert(html, "<html>")
    table.insert(html, "<head>")
    table.insert(html, "  <title>Test Report</title>")
    table.insert(html, "  <style>")
    table.insert(html, "    body { font-family: Arial, sans-serif; margin: 20px; }")
    table.insert(html, "    h1 { color: #333; }")
    table.insert(html, "    .summary { background: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px; }")
    table.insert(html, "    .passed { color: green; }")
    table.insert(html, "    .failed { color: red; }")
    table.insert(html, "    .skipped { color: orange; }")
    table.insert(html, "    table { width: 100%; border-collapse: collapse; margin-top: 20px; }")
    table.insert(html, "    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }")
    table.insert(html, "    th { background-color: #4CAF50; color: white; }")
    table.insert(html, "    tr:nth-child(even) { background-color: #f9f9f9; }")
    table.insert(html, "    .error { background-color: #ffebee; padding: 10px; margin: 5px 0; border-left: 4px solid #f44336; }")
    table.insert(html, "  </style>")
    table.insert(html, "</head>")
    table.insert(html, "<body>")

    table.insert(html, "  <h1>Test Execution Report</h1>")

    -- Summary
    table.insert(html, '  <div class="summary">')
    table.insert(html, "    <h2>Summary</h2>")
    table.insert(html, '    <p><span class="passed">✓ Passed: ' .. results.totalPassed .. '</span></p>')
    table.insert(html, '    <p><span class="failed">✗ Failed: ' .. results.totalFailed .. '</span></p>')
    table.insert(html, '    <p><span class="skipped">⊗ Skipped: ' .. results.totalSkipped .. '</span></p>')
    table.insert(html, '    <p>Duration: ' .. string.format("%.2f", results.duration) .. ' seconds</p>')
    table.insert(html, "  </div>")

    -- Test results table
    table.insert(html, "  <h2>Test Results</h2>")
    table.insert(html, "  <table>")
    table.insert(html, "    <tr><th>Suite</th><th>Passed</th><th>Failed</th><th>Skipped</th><th>Total</th><th>Success Rate</th></tr>")

    for _, suiteResult in ipairs(results.suites) do
        local total = suiteResult.passed + suiteResult.failed + suiteResult.skipped
        local percentage = 0
        if total > 0 then
            percentage = (suiteResult.passed / total) * 100
        end

        local passedClass = suiteResult.failed > 0 and "failed" or "passed"

        table.insert(html, "    <tr>")
        table.insert(html, "      <td>" .. suiteResult.name .. "</td>")
        table.insert(html, "      <td>" .. suiteResult.passed .. "</td>")
        table.insert(html, "      <td>" .. suiteResult.failed .. "</td>")
        table.insert(html, "      <td>" .. suiteResult.skipped .. "</td>")
        table.insert(html, "      <td>" .. total .. "</td>")
        table.insert(html, '      <td class="' .. passedClass .. '">' .. string.format("%.1f%%", percentage) .. "</td>")
        table.insert(html, "    </tr>")
    end

    table.insert(html, "  </table>")

    -- Failed tests details
    if results.totalFailed > 0 then
        table.insert(html, "  <h2>Failed Test Details</h2>")
        for _, suiteResult in ipairs(results.suites) do
            if suiteResult.failed > 0 and suiteResult.errors then
                table.insert(html, "  <h3>" .. suiteResult.name .. "</h3>")
                for _, error in ipairs(suiteResult.errors) do
                    table.insert(html, '  <div class="error">')
                    table.insert(html, "    <strong>" .. error.test .. "</strong>")
                    table.insert(html, "    <pre>" .. error.error .. "</pre>")
                    table.insert(html, "  </div>")
                end
            end
        end
    end

    table.insert(html, "</body>")
    table.insert(html, "</html>")

    return table.concat(html, "\n")
end

---Generate report in specified format
function ReportGenerator.generateReport(results, format)
    format = format or "text"

    local report

    if format == "json" then
        report = generateJsonReport(results)
    elseif format == "html" then
        report = generateHtmlReport(results)
    else
        report = generateTextReport(results)
    end

    print(report)

    return report
end

---Write report to file
function ReportGenerator.writeReport(results, format, filename)
    format = format or "text"
    filename = filename or ("tests/reports/report." .. format)

    local report = ReportGenerator.generateReport(results, format)

    -- Create directory if needed
    local dir = filename:match("^(.*/)")
    if dir then
        love.filesystem.createDirectory(dir)
    end

    -- Write file
    local success = love.filesystem.write(filename, report)

    if success then
        print("[Report] Written to: " .. filename)
    else
        print("[Error] Failed to write report to: " .. filename)
    end

    return success
end

return ReportGenerator
