#!/usr/bin/env lua
---
--- Wiki/Engine Alignment Audit Script
--- Checks which wiki-documented systems have actual engine implementations
--- Generates report showing status of each system
---

local function countLuaFiles(directory)
    local count = 0
    local handle = io.popen('dir /B /S "' .. directory .. '\\*.lua" 2>nul | find /c /v ""')
    if handle then
        local result = handle:read("*a")
        handle:close()
        count = tonumber(result) or 0
    end
    return count
end

local function getFileSize(filepath)
    local handle = io.open(filepath, "r")
    if not handle then return 0 end
    handle:seek("end")
    local size = handle:seek("cur")
    handle:close()
    return size
end

local function countLines(filepath)
    local count = 0
    local handle = io.open(filepath, "r")
    if not handle then return 0 end
    for _ in handle:lines() do
        count = count + 1
    end
    handle:close()
    return count
end

local function directoryExists(path)
    local handle = io.open(path, "r")
    if handle then
        handle:close()
        return true
    end
    return false
end

-- Wiki Systems to check
local systems = {
    -- Core Systems
    { wiki_name = "Overview", wiki_file = "wiki/systems/Overview.md", engine_paths = {"engine/main.lua", "engine/core/"}, priority = "CORE" },
    { wiki_name = "Geoscape", wiki_file = "wiki/systems/Geoscape.md", engine_paths = {"engine/geoscape/"}, priority = "CRITICAL" },
    { wiki_name = "Basescape", wiki_file = "wiki/systems/Basescape.md", engine_paths = {"engine/basescape/"}, priority = "CRITICAL" },
    { wiki_name = "Battlescape", wiki_file = "wiki/systems/Battlescape.md", engine_paths = {"engine/battlescape/"}, priority = "CRITICAL" },
    { wiki_name = "Interception", wiki_file = "wiki/systems/Crafts.md", engine_paths = {"engine/interception/"}, priority = "HIGH" },
    { wiki_name = "Units", wiki_file = "wiki/systems/Units.md", engine_paths = {"engine/battlescape/entities/", "engine/basescape/"}, priority = "CRITICAL" },
    { wiki_name = "Economy", wiki_file = "wiki/systems/Economy.md", engine_paths = {"engine/economy/"}, priority = "HIGH" },
    { wiki_name = "Gui", wiki_file = "wiki/systems/Gui.md", engine_paths = {"engine/ui/", "engine/widgets/"}, priority = "CORE" },
    { wiki_name = "Items", wiki_file = "wiki/systems/Items.md", engine_paths = {"engine/battlescape/", "engine/basescape/"}, priority = "HIGH" },
    { wiki_name = "Lore", wiki_file = "wiki/systems/Lore.md", engine_paths = {"engine/lore/"}, priority = "MEDIUM" },
    { wiki_name = "Politics", wiki_file = "wiki/systems/Politics.md", engine_paths = {"engine/politics/"}, priority = "MEDIUM" },
    { wiki_name = "Finance", wiki_file = "wiki/systems/Finance.md", engine_paths = {"engine/economy/"}, priority = "HIGH" },
    { wiki_name = "AI Systems", wiki_file = "wiki/systems/AI Systems.md", engine_paths = {"engine/ai/"}, priority = "HIGH" },
    { wiki_name = "Analytics", wiki_file = "wiki/systems/Analytics.md", engine_paths = {"engine/analytics/"}, priority = "LOW" },
    { wiki_name = "Assets", wiki_file = "wiki/systems/Assets.md", engine_paths = {"engine/assets/"}, priority = "CORE" },
    { wiki_name = "3D", wiki_file = "wiki/systems/3D.md", engine_paths = {"engine/battlescape/rendering/"}, priority = "MEDIUM" },
    { wiki_name = "Integration", wiki_file = "wiki/systems/Integration.md", engine_paths = {"engine/core/", "engine/scenes/"}, priority = "CORE" },
}

print("=" .. string.rep("=", 78))
print("WIKI/ENGINE ALIGNMENT AUDIT")
print("=" .. string.rep("=", 78))
print("")

local results = {}
local totalLuaFiles = 0
local implementedSystems = 0
local partialSystems = 0
local stubSystems = 0
local missingSystems = 0

for _, system in ipairs(systems) do
    local hasFiles = false
    local fileCount = 0
    local lineCount = 0
    local status = "MISSING"
    
    for _, path in ipairs(system.engine_paths) do
        if directoryExists(path) then
            hasFiles = true
            fileCount = countLuaFiles(path)
            -- Count lines in first file for size indication
            if fileCount > 0 then
                status = fileCount >= 3 and "IMPLEMENTED" or "PARTIAL"
            end
        end
    end
    
    if hasFiles then
        implementedSystems = implementedSystems + 1
    else
        missingSystems = missingSystems + 1
        status = "MISSING"
    end
    
    totalLuaFiles = totalLuaFiles + fileCount
    
    table.insert(results, {
        name = system.wiki_name,
        priority = system.priority,
        paths = system.engine_paths,
        status = status,
        files = fileCount
    })
end

-- Print by priority
local priorities = {"CORE", "CRITICAL", "HIGH", "MEDIUM", "LOW"}

for _, priority in ipairs(priorities) do
    print(string.format("\n%s PRIORITY SYSTEMS:", priority))
    print(string.rep("-", 80))
    
    for _, result in ipairs(results) do
        if result.priority == priority then
            local statusColor = result.status == "IMPLEMENTED" and "✅" or 
                               result.status == "PARTIAL" and "⚠️ " or "❌"
            print(string.format("  %s [%s] %-20s | %3d files | %s", 
                statusColor, result.status, result.name, result.files, 
                table.concat(result.paths, ", ")))
        end
    end
end

print("\n" .. string.rep("=", 80))
print("SUMMARY")
print(string.rep("=", 80))
print(string.format("Total Lua Files:         %3d", totalLuaFiles))
print(string.format("Wiki Systems Mapped:     %3d", #systems))
print(string.format("Implemented Systems:     %3d ✅", implementedSystems))
print(string.format("Missing Systems:         %3d ❌", missingSystems))
print(string.format("Alignment Percentage:    %.1f%%", (implementedSystems / #systems) * 100))
print("")



