#!/usr/bin/env lua
---
--- QA System Runner
--- Command-line interface for running quality assurance checks
---

-- Find the workspace root
local function findWorkspaceRoot()
    local cwd = os.getenv("PWD") or os.getcwd()

    -- Check if we're in the tools/qa_system directory
    if cwd:find("tools[/\\]qa_system") then
        -- Go up to workspace root
        return cwd:gsub("tools[/\\]qa_system.*", ""):gsub("/$", "")
    end

    return cwd
end

local workspaceRoot = findWorkspaceRoot()
print("[QARunner] Workspace root: " .. workspaceRoot)

-- Add tools directory to Lua path
package.path = workspaceRoot .. "/tools/?.lua;" ..
               workspaceRoot .. "/tools/?/?.lua;" ..
               package.path

-- Load QA Engine
local QAEngine = require("qa_system.qa_engine")

-- Parse command-line arguments
local scanDir = arg[1] or "engine"
local outputFormat = arg[2] or "text"

if scanDir == "help" then
    print([[
QA System - Code Quality Analysis Tool

Usage:
  lua qa_runner.lua [directory] [format]

Arguments:
  directory   Directory to scan (default: engine)
  format      Output format: text, json, html (default: text)

Examples:
  lua qa_runner.lua engine text
  lua qa_runner.lua engine json
  lua qa_runner.lua engine html

Reports:
  The report identifies issues in code style, documentation, complexity,
  performance, and security, helping maintain code quality standards.
]])
    os.exit(0)
end

-- Ensure path is absolute
if not scanDir:match("^[A-Za-z]:") and not scanDir:match("^/") then
    scanDir = workspaceRoot .. "/" .. scanDir
end

print("[QARunner] Scanning directory: " .. scanDir)
print("[QARunner] Output format: " .. outputFormat)
print("")

-- Run analysis
local report = QAEngine.run(scanDir)

-- Output based on format
if outputFormat == "json" then
    -- Simple JSON output
    print(require("json").encode({
        files_scanned = QAEngine.fileCount,
        issues_found = #QAEngine.issues,
        issues = QAEngine.issues
    }))
elseif outputFormat == "html" then
    -- HTML report
    local html = [[
<!DOCTYPE html>
<html>
<head>
    <title>AlienFall QA Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .summary { background: #f0f0f0; padding: 15px; border-radius: 5px; }
        .critical { color: #d00; font-weight: bold; }
        .high { color: #f80; }
        .medium { color: #08f; }
        .low { color: #080; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #333; color: white; }
        tr:nth-child(even) { background: #f9f9f9; }
    </style>
</head>
<body>
    <h1>AlienFall Code Quality Report</h1>
    <div class="summary">
        <p>Files Scanned: <strong>]] .. QAEngine.fileCount .. [[</strong></p>
        <p>Issues Found: <strong>]] .. #QAEngine.issues .. [[</strong></p>
    </div>
    <h2>Issues</h2>
    <table>
        <tr>
            <th>File</th>
            <th>Line</th>
            <th>Severity</th>
            <th>Category</th>
            <th>Message</th>
        </tr>
]]
    for _, issue in ipairs(QAEngine.issues) do
        html = html .. string.format([[
        <tr>
            <td>%s</td>
            <td>%d</td>
            <td><span class="%s">%s</span></td>
            <td>%s</td>
            <td>%s</td>
        </tr>
]], issue.file, issue.line, issue.severity, issue.severity:upper(), issue.category, issue.message)
    end

    html = html .. [[
    </table>
</body>
</html>
]]
    print(html)
else
    -- Text report (already printed by QAEngine)
    -- Report is already printed above
end

print("\n[QARunner] Analysis complete")
os.exit(0)
