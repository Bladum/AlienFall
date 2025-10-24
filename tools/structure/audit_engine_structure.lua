#!/usr/bin/env lua
-- audit_engine_structure.lua
-- Analyzes current engine folder structure and generates audit report
-- Usage: lovec tools/structure/audit_engine_structure.lua

-- ============================================================================
-- Utility Functions
-- ============================================================================

local function getFileSize(path)
    local f = love.filesystem.newFile(path)
    if not f then return 0 end
    local size = f:getSize()
    return size or 0
end

local function countLines(path)
    local count = 0
    local content = love.filesystem.read(path)
    if not content then return 0 end
    for _ in content:gmatch("\n") do
        count = count + 1
    end
    return count + 1  -- Add 1 for first line
end

local function readFile(path)
    local content = love.filesystem.read(path)
    return content or ""
end

local function isLuaFile(name)
    return name:match("%.lua$") ~= nil
end

local function listDirectory(path)
    local items = love.filesystem.getDirectoryItems(path)
    return items or {}
end

-- ============================================================================
-- Analysis Functions
-- ============================================================================

local Auditor = {}

function Auditor.extractModuleName(filePath)
    local content = readFile(filePath)
    
    -- Try to find return statement with module table
    local match = content:match("return%s*{[^}]*name%s*=%s*['\"]([^'\"]+)['\"]")
    if match then return match end
    
    -- Try M.name or local M
    match = content:match("local%s+[a-zA-Z_][a-zA-Z0-9_]*%s*=%s*{}")
    
    -- Fallback to filename
    local fileName = filePath:match("([^/\\]+)%.lua$")
    return fileName or "unknown"
end

function Auditor.extractFunctions(filePath)
    local content = readFile(filePath)
    local functions = {}
    
    -- Find function definitions
    for name in content:gmatch("function%s+([a-zA-Z_][a-zA-Z0-9_:.]*)%s*%(") do
        table.insert(functions, name)
    end
    
    -- Find local function definitions
    for name in content:gmatch("local%s+function%s+([a-zA-Z_][a-zA-Z0-9_]*)%s*%(") do
        table.insert(functions, "local:" .. name)
    end
    
    return functions
end

function Auditor.extractDependencies(filePath)
    local content = readFile(filePath)
    local deps = {}
    
    -- Find require statements
    for path in content:gmatch('require%s*%(?["\']([^"\']+)["\']%)?') do
        table.insert(deps, path)
    end
    
    return deps
end

function Auditor.analyzeLuaFile(filePath, relPath)
    return {
        path = filePath,
        relPath = relPath,
        module = Auditor.extractModuleName(filePath),
        size = getFileSize(filePath),
        lines = countLines(filePath),
        functions = Auditor.extractFunctions(filePath),
        dependencies = Auditor.extractDependencies(filePath),
    }
end

function Auditor.scanFolder(folderPath, prefix)
    prefix = prefix or ""
    local items = listDirectory(folderPath)
    local files = {}
    local folders = {}
    
    for _, item in ipairs(items) do
        local fullPath = folderPath .. "/" .. item
        local relPath = prefix .. item
        
        -- Check if it's a directory by trying to list it
        local subitems = love.filesystem.getDirectoryItems(fullPath)
        if subitems then
            table.insert(folders, relPath)
            -- Recursively scan
            local subFiles, subFolders = Auditor.scanFolder(fullPath, relPath .. "/")
            for _, f in ipairs(subFiles) do
                table.insert(files, f)
            end
            for _, f in ipairs(subFolders) do
                table.insert(folders, f)
            end
        elseif isLuaFile(item) then
            table.insert(files, Auditor.analyzeLuaFile(fullPath, relPath))
        end
    end
    
    return files, folders
end

-- ============================================================================
-- Report Generation
-- ============================================================================

local ReportGenerator = {}

function ReportGenerator.generateReport(enginePath)
    print("[Auditor] Scanning engine structure...")
    local files, folders = Auditor.scanFolder(enginePath)
    
    -- Analyze by folder
    local byFolder = {}
    for _, file in ipairs(files) do
        local folder = file.relPath:match("^([^/]+)") or "root"
        if not byFolder[folder] then
            byFolder[folder] = {name = folder, files = {}, totalLines = 0, totalSize = 0}
        end
        table.insert(byFolder[folder].files, file)
        byFolder[folder].totalLines = byFolder[folder].totalLines + file.lines
        byFolder[folder].totalSize = byFolder[folder].totalSize + file.size
    end
    
    -- Create report
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        summary = {
            totalFiles = #files,
            totalFolders = #folders,
            totalLines = 0,
            totalSize = 0,
        },
        byFolder = {},
        files = files,
        folders = folders,
    }
    
    -- Calculate totals
    for _, file in ipairs(files) do
        report.summary.totalLines = report.summary.totalLines + file.lines
        report.summary.totalSize = report.summary.totalSize + file.size
    end
    
    -- Sort folders and add to report
    local folderList = {}
    for folderName, data in pairs(byFolder) do
        table.insert(folderList, data)
    end
    table.sort(folderList, function(a, b) return a.name < b.name end)
    report.byFolder = folderList
    
    return report
end

function ReportGenerator.generateMarkdown(report)
    local md = {}
    
    table.insert(md, "# Engine Folder Structure Audit Report")
    table.insert(md, "")
    table.insert(md, "**Generated:** " .. report.timestamp)
    table.insert(md, "")
    
    -- Summary
    table.insert(md, "## Summary Statistics")
    table.insert(md, "")
    table.insert(md, "| Metric | Value |")
    table.insert(md, "|--------|-------|")
    table.insert(md, "| Total Files | " .. report.summary.totalFiles .. " |")
    table.insert(md, "| Total Folders | " .. report.summary.totalFolders .. " |")
    table.insert(md, "| Total Lines of Code | " .. report.summary.totalLines .. " |")
    table.insert(md, "| Total Size | " .. math.floor(report.summary.totalSize / 1024) .. " KB |")
    table.insert(md, "")
    
    -- By Folder
    table.insert(md, "## Folder Analysis")
    table.insert(md, "")
    for _, folderData in ipairs(report.byFolder) do
        table.insert(md, "### " .. folderData.name .. "/")
        table.insert(md, "")
        table.insert(md, "**Statistics:**")
        table.insert(md, "- Files: " .. #folderData.files)
        table.insert(md, "- Lines: " .. folderData.totalLines)
        table.insert(md, "- Size: " .. math.floor(folderData.totalSize / 1024) .. " KB")
        table.insert(md, "")
        
        table.insert(md, "**Files:**")
        for _, file in ipairs(folderData.files) do
            local name = file.relPath:match("([^/]+)$")
            table.insert(md, "- `" .. name .. "` (" .. file.lines .. " lines, " .. math.floor(file.size / 1024) .. " KB)")
        end
        table.insert(md, "")
    end
    
    -- Largest files
    table.insert(md, "## Largest Files")
    table.insert(md, "")
    local sorted = {}
    for _, file in ipairs(report.files) do
        table.insert(sorted, file)
    end
    table.sort(sorted, function(a, b) return a.lines > b.lines end)
    
    for i = 1, math.min(10, #sorted) do
        local file = sorted[i]
        table.insert(md, (i) .. ". `" .. file.relPath .. "` - " .. file.lines .. " lines")
    end
    table.insert(md, "")
    
    -- Potential issues
    table.insert(md, "## Potential Organization Issues")
    table.insert(md, "")
    
    -- Large files
    table.insert(md, "### Large Files (> 500 lines)")
    local largeCount = 0
    for _, file in ipairs(sorted) do
        if file.lines > 500 then
            table.insert(md, "- `" .. file.relPath .. "` - " .. file.lines .. " lines (consider splitting)")
            largeCount = largeCount + 1
        end
    end
    if largeCount == 0 then
        table.insert(md, "- None found ✓")
    end
    table.insert(md, "")
    
    -- Files with many dependencies
    table.insert(md, "### Files with Many Dependencies (> 10)")
    local depSorted = {}
    for _, file in ipairs(report.files) do
        if #file.dependencies > 0 then
            table.insert(depSorted, file)
        end
    end
    table.sort(depSorted, function(a, b) return #a.dependencies > #b.dependencies end)
    
    local depCount = 0
    for i = 1, math.min(10, #depSorted) do
        local file = depSorted[i]
        if #file.dependencies > 10 then
            table.insert(md, "- `" .. file.relPath .. "` - " .. #file.dependencies .. " dependencies")
            depCount = depCount + 1
        end
    end
    if depCount == 0 then
        table.insert(md, "- None found ✓")
    end
    table.insert(md, "")
    
    -- Empty folders (with no Lua files)
    table.insert(md, "### Folders with Few Files (< 2 Lua files)")
    for _, folderData in ipairs(report.byFolder) do
        if #folderData.files < 2 then
            table.insert(md, "- `" .. folderData.name .. "/` - " .. #folderData.files .. " files (consider consolidating)")
        end
    end
    table.insert(md, "")
    
    return table.concat(md, "\n")
end

-- ============================================================================
-- Main
-- ============================================================================

-- In Love2D, arg is usually: [0]=script, [1]=engine_path, etc.
-- But we'll just hardcode engine for now since we control the call
local enginePath = "engine"

print("[Auditor] Starting engine structure analysis...")
print("[Auditor] Engine path: " .. enginePath)
print("")

local report = ReportGenerator.generateReport(enginePath)
local markdown = ReportGenerator.generateMarkdown(report)

-- Save report
local reportPath = "temp/engine_structure_audit.md"
local success = love.filesystem.write(reportPath, markdown)
if success then
    print("[Auditor] Report saved to: " .. reportPath)
else
    print("[ERROR] Could not save report to: " .. reportPath)
end

print("")
print(markdown)
print("")
print("[Auditor] Audit complete!")

-- Exit cleanly
love.event.quit()
