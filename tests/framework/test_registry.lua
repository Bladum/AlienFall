-- Test Framework: Test Registry
-- Discovers and manages all tests in hierarchical structure

local TestRegistry = {}

-- Global registry storage
local registry = {}
local moduleIndex = {}
local fileIndex = {}

---Register a test suite
function TestRegistry.register(modulePath, testSuite)
    -- Parse module path: "tests.unit.battlescape.combat.test_damage"
    local parts = {}
    for part in modulePath:gmatch("[^.]+") do
        table.insert(parts, part)
    end

    -- Skip "tests" prefix
    if parts[1] == "tests" then
        table.remove(parts, 1)
    end

    local category = parts[1]    -- "unit", "integration", etc.
    local module = parts[2]      -- "battlescape", "geoscape", etc.
    local file = parts[#parts]   -- filename

    -- Create nested structure
    if not registry[category] then
        registry[category] = {}
    end
    if not registry[category][module] then
        registry[category][module] = {}
    end
    if not registry[category][module][file] then
        registry[category][module][file] = {}
    end

    -- Store suite
    table.insert(registry[category][module][file], testSuite)

    -- Update indexes
    moduleIndex[module] = true
    fileIndex[file] = true
end

---Get all registered tests
function TestRegistry.getAll()
    return registry
end

---Get tests by category
function TestRegistry.getByCategory(category)
    return registry[category] or {}
end

---Get tests by module
function TestRegistry.getByModule(module)
    local result = {}
    for category, moduleData in pairs(registry) do
        if moduleData[module] then
            result[module] = moduleData[module]
        end
    end
    return result
end

---Get tests by file
function TestRegistry.getByFile(file)
    local result = {}
    for category, moduleData in pairs(registry) do
        for module, fileData in pairs(moduleData) do
            if fileData[file] then
                result[file] = fileData[file]
            end
        end
    end
    return result
end

---Discover all test files in a directory
function TestRegistry.discoverTests(directory)
    local testFiles = {}

    -- Recursive directory scanning
    local function scanDir(dir, path)
        path = path or ""

        local success, result = pcall(love.filesystem.getDirectoryItems, dir)
        if not success then
            return
        end

        for _, item in ipairs(result) do
            local fullPath = dir .. "/" .. item
            local info = love.filesystem.getInfo(fullPath)

            if info then
                if info.type == "directory" then
                    -- Recursively scan subdirectories
                    local newPath = path
                    if path ~= "" then
                        newPath = path .. "." .. item
                    else
                        newPath = item
                    end
                    scanDir(fullPath, newPath)
                elseif item:match("^test_.*%.lua$") then
                    -- Found test file
                    local modulePath = path .. "." .. item:sub(1, -5)
                    table.insert(testFiles, modulePath)
                end
            end
        end
    end

    scanDir(directory)
    return testFiles
end

---Unregister all tests
function TestRegistry.clear()
    registry = {}
    moduleIndex = {}
    fileIndex = {}
end

---Get all modules
function TestRegistry.getModules()
    local modules = {}
    for module in pairs(moduleIndex) do
        table.insert(modules, module)
    end
    table.sort(modules)
    return modules
end

---Get all files
function TestRegistry.getFiles()
    local files = {}
    for file in pairs(fileIndex) do
        table.insert(files, file)
    end
    table.sort(files)
    return files
end

---Count all tests
function TestRegistry.count()
    local total = 0
    for _, categoryData in pairs(registry) do
        for _, moduleData in pairs(categoryData) do
            for _, fileData in pairs(moduleData) do
                for _, suites in pairs(fileData) do
                    if type(suites) == "table" then
                        for _, suite in pairs(suites) do
                            if suite.tests then
                                total = total + #suite.tests
                            end
                        end
                    end
                end
            end
        end
    end
    return total
end

---Get registry structure for display
function TestRegistry.getStructure()
    local structure = {}

    for category, moduleData in pairs(registry) do
        if not structure[category] then
            structure[category] = {}
        end

        for module, fileData in pairs(moduleData) do
            if not structure[category][module] then
                structure[category][module] = {}
            end

            for file, suites in pairs(fileData) do
                local testCount = 0
                if type(suites) == "table" then
                    for _, suite in pairs(suites) do
                        if suite.tests then
                            testCount = testCount + #suite.tests
                        end
                    end
                end

                structure[category][module][file] = testCount
            end
        end
    end

    return structure
end

---Print registry structure
function TestRegistry.printStructure()
    print("\n" .. string.rep("=", 60))
    print("Test Registry Structure")
    print(string.rep("=", 60))

    local structure = TestRegistry.getStructure()
    local totalTests = 0

    for category, moduleData in pairs(structure) do
        print("\n[" .. category:upper() .. "]")

        for module, fileData in pairs(moduleData) do
            print("  " .. module)

            for file, count in pairs(fileData) do
                print("    " .. file .. ": " .. count .. " tests")
                totalTests = totalTests + count
            end
        end
    end

    print("\n" .. string.rep("-", 60))
    print("Total Tests: " .. totalTests)
    print(string.rep("-", 60) .. "\n")
end

return TestRegistry
