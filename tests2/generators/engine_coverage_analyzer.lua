-- ─────────────────────────────────────────────────────────────────────────
-- ENGINE COVERAGE ANALYZER
-- Skanuje engine/ i generuje raport test coverage
-- ─────────────────────────────────────────────────────────────────────────

local EngineAnalyzer = {}

--- Scan engine folder i zbierz wszystkie moduły
function EngineAnalyzer:scanEngine()
    local enginePath = "engine"
    local modules = {}

    -- Główne poddirectories
    local subdirs = {
        "core", "battlescape", "geoscape", "basescape",
        "ai", "analytics", "accessibility", "gui",
        "content", "economy", "interception", "localization",
        "lore", "mods", "politics", "tutorial", "utils"
    }

    for _, subdir in ipairs(subdirs) do
        local fullPath = enginePath .. "/" .. subdir

        -- Load moduły z poddirectory
        local ok, moduleList = pcall(function()
            return self:scanDirectory(fullPath)
        end)

        if ok then
            for moduleName, moduleInfo in pairs(moduleList) do
                modules[subdir .. "." .. moduleName] = moduleInfo
            end
        end
    end

    return modules
end

--- Skanuj pojedynczy directory i zbierz module info
function EngineAnalyzer:scanDirectory(dirPath)
    local modules = {}

    -- Try to load main module files
    local mainFiles = {
        dirPath .. ".lua",
        dirPath .. "/init.lua"
    }

    for _, filePath in ipairs(mainFiles) do
        local ok, content = pcall(function()
            -- Read file from Love2D filesystem
            if love.filesystem.getInfo(filePath) then
                return love.filesystem.read(filePath)
            end
        end)

        if ok and content then
            local moduleName = dirPath:gsub("/", "_")
            modules[moduleName] = {
                path = filePath,
                functions = self:extractFunctions(content),
                classes = self:extractClasses(content)
            }
            break
        end
    end

    return modules
end

--- Extract function signatures z content
function EngineAnalyzer:extractFunctions(content)
    local functions = {}

    -- Pattern: function name(...) or local function name(...)
    local pattern = "function%s+([%w_%.]+)%s*%("

    for funcName in content:gmatch(pattern) do
        table.insert(functions, {
            name = funcName,
            tested = false,
            testCases = 0
        })
    end

    return functions
end

--- Extract class definitions (tables with methods)
function EngineAnalyzer:extractClasses(content)
    local classes = {}

    -- Pattern: local ClassName = {} or ClassName = {}
    local pattern = "local%s+([%w_]+)%s*=%s*%{%}"

    for className in content:gmatch(pattern) do
        table.insert(classes, {
            name = className,
            methods = {},
            tested = false
        })
    end

    return classes
end

--- Generate coverage report
function EngineAnalyzer:generateReport(modules)
    print("\n" .. string.rep("═", 80))
    print("ENGINE COVERAGE ANALYSIS REPORT")
    print(string.rep("═", 80))

    local totalModules = 0
    local testedModules = 0
    local totalFunctions = 0
    local testedFunctions = 0

    -- Group by category
    local categories = {}

    for modulePath, moduleInfo in pairs(modules) do
        local category = modulePath:match("^([^.]+)")

        if not categories[category] then
            categories[category] = {
                modules = 0,
                functions = 0,
                tested = 0
            }
        end

        categories[category].modules = categories[category].modules + 1

        local funcCount = #moduleInfo.functions
        categories[category].functions = categories[category].functions + funcCount

        totalModules = totalModules + 1
        totalFunctions = totalFunctions + funcCount
    end

    -- Print by category
    for category, stats in pairs(categories) do
        print(string.format("\n[%s]", category:upper()))
        print(string.format("  Modules: %d", stats.modules))
        print(string.format("  Functions: %d", stats.functions))
        print(string.format("  Coverage: %.1f%% (0/%d)", 0, stats.functions))
    end

    print("\n" .. string.rep("─", 80))
    print(string.format("TOTAL: %d modules, %d functions", totalModules, totalFunctions))
    print(string.format("COVERAGE: %.1f%% (0/%d functions tested)", 0, totalFunctions))
    print(string.rep("═", 80) .. "\n")

    return {
        totalModules = totalModules,
        totalFunctions = totalFunctions,
        categories = categories
    }
end

return EngineAnalyzer
