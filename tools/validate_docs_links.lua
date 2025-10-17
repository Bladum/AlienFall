--- Docs Links Validator
--- Validates that all documentation cross-references point to existing files
--- and provides a comprehensive audit report.
---
--- Usage:
---   lua tools/validate_docs_links.lua
---
--- Output:
---   Creates: validate_docs_links_report.txt
---   Console: Summary statistics and any errors

local function findFiles(directory, pattern)
    local files = {}
    local handle = io.popen('dir "' .. directory .. '" /s /b')
    if handle then
        for file in handle:lines() do
            if file:match(pattern) then
                table.insert(files, file)
            end
        end
        handle:close()
    end
    return files
end

local function readFile(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

local function fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function normalizePath(path)
    -- Convert Windows backslashes to forward slashes for consistency
    return path:gsub("\\", "/")
end

local function getProjectRoot()
    -- Find project root by looking for common marker files
    local current = debug.getinfo(1).source:sub(2)  -- Remove @
    current = current:gsub("\\", "/")
    current = current:gsub("/[^/]+$", "")  -- Remove file
    
    -- Go up until we find .github or mods or engine
    while current ~= "" and current ~= "/" do
        if fileExists(current .. "/.github") or 
           fileExists(current .. "/engine") or
           fileExists(current .. "/mods") then
            return current
        end
        current = current:gsub("/[^/]+$", "")
    end
    
    return nil
end

local function validateLinks()
    local projectRoot = getProjectRoot()
    if not projectRoot then
        print("ERROR: Could not find project root")
        return false
    end
    
    print("Starting documentation link validation...")
    print("Project root: " .. projectRoot)
    print()
    
    local report = {}
    table.insert(report, "Documentation Links Validation Report")
    table.insert(report, "=====================================")
    table.insert(report, "Generated: " .. os.date())
    table.insert(report, "Project Root: " .. projectRoot)
    table.insert(report, "")
    
    -- Find all markdown files in docs/
    local docsPath = projectRoot .. "/docs"
    local mdFiles = findFiles(docsPath, "%.md$")
    
    table.insert(report, "Scanning " .. #mdFiles .. " documentation files...")
    table.insert(report, "")
    
    local stats = {
        total_files = #mdFiles,
        total_links = 0,
        valid_links = 0,
        broken_links = 0,
        vague_links = 0,
        errors = {}
    }
    
    -- Scan each markdown file
    for _, mdFile in ipairs(mdFiles) do
        local content = readFile(mdFile)
        if content then
            -- Find all implementation links: > **Implementation**: `path/to/file.lua`
            for link in content:gmatch("> %*%*Implementation%*%*: `([^`]+)`") do
                stats.total_links = stats.total_links + 1
                
                -- Try to resolve the link
                local fullPath = projectRoot .. "/" .. link
                fullPath = fullPath:gsub("\\", "/")
                fullPath = fullPath:gsub("/+", "/")
                
                if fileExists(fullPath) then
                    stats.valid_links = stats.valid_links + 1
                elseif link:match("/%*") or link:match("%*/$") then
                    -- Vague links like "engine/*" or "*/main.lua"
                    stats.vague_links = stats.vague_links + 1
                    table.insert(stats.errors, {
                        type = "VAGUE",
                        file = mdFile,
                        link = link,
                        message = "Vague link pattern (contains wildcards)"
                    })
                else
                    stats.broken_links = stats.broken_links + 1
                    table.insert(stats.errors, {
                        type = "BROKEN",
                        file = mdFile,
                        link = link,
                        message = "File not found: " .. fullPath
                    })
                end
            end
        end
    end
    
    -- Generate statistics section
    table.insert(report, "")
    table.insert(report, "STATISTICS")
    table.insert(report, "==========")
    table.insert(report, "Total documentation files: " .. stats.total_files)
    table.insert(report, "Total implementation links: " .. stats.total_links)
    table.insert(report, "Valid links: " .. stats.valid_links)
    table.insert(report, "Broken links: " .. stats.broken_links)
    table.insert(report, "Vague links: " .. stats.vague_links)
    table.insert(report, "")
    
    if stats.total_links > 0 then
        local validPercent = (stats.valid_links / stats.total_links) * 100
        table.insert(report, "Link validity: " .. string.format("%.1f%%", validPercent))
    end
    
    -- Generate errors section
    if #stats.errors > 0 then
        table.insert(report, "")
        table.insert(report, "ISSUES FOUND")
        table.insert(report, "============")
        
        -- Group errors by type
        local byType = {}
        for _, error in ipairs(stats.errors) do
            if not byType[error.type] then
                byType[error.type] = {}
            end
            table.insert(byType[error.type], error)
        end
        
        for errorType, errors in pairs(byType) do
            table.insert(report, "")
            table.insert(report, errorType .. " LINKS (" .. #errors .. ")")
            table.insert(report, string.rep("-", 30))
            
            for _, error in ipairs(errors) do
                local relFile = error.file:sub(#projectRoot + 2)
                table.insert(report, "File: " .. relFile)
                table.insert(report, "Link: " .. error.link)
                table.insert(report, "Issue: " .. error.message)
                table.insert(report, "")
            end
        end
    else
        table.insert(report, "")
        table.insert(report, "✓ All links are valid!")
    end
    
    -- Write report file
    local reportPath = projectRoot .. "/validate_docs_links_report.txt"
    local reportFile = io.open(reportPath, "w")
    if reportFile then
        reportFile:write(table.concat(report, "\n"))
        reportFile:close()
        print("✓ Report written to: " .. reportPath)
    end
    
    -- Print summary to console
    print("")
    print("VALIDATION SUMMARY")
    print("==================")
    print("Total links: " .. stats.total_links)
    print("Valid: " .. stats.valid_links)
    print("Broken: " .. stats.broken_links)
    print("Vague: " .. stats.vague_links)
    
    if stats.broken_links == 0 then
        print("✓ All links are valid!")
        return true
    else
        print("✗ " .. stats.broken_links .. " broken links found")
        return false
    end
end

-- Run validation
validateLinks()
