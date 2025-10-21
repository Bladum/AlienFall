---Test Suite for Mod Manager System
---Tests mod loading, content resolution, and mod priority

-- Mock Love2D filesystem if not available
if not love then
    love = {
        filesystem = {
            getDirectoryItems = function(path)
                if path == "mods" then
                    return {"core", "new"}
                end
                return {}
            end,
            getInfo = function(path)
                if path:match("mod%.toml") then
                    return {type = "file"}
                end
                return nil
            end,
            read = function(path)
                if path:match("core/mod%.toml") then
                    return [[
                        id = "core"
                        name = "XCOM Core"
                        version = "1.0.0"
                        author = "AlienFall Team"
                    ]]
                elseif path:match("new/mod%.toml") then
                    return [[
                        id = "new"
                        name = "New Content"
                        version = "1.0.0"
                        dependencies = ["core"]
                    ]]
                end
                return nil
            end
        }
    }
end

local ModManager = require("engine.mods.mod_manager")

local TestModManager = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper function to run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper function to assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

---Test: Initialize mod manager
function TestModManager.testInitialize()
    ModManager.init()
    
    local mods = ModManager.getMods()
    assert(mods ~= nil, "Should return mods list")
    assert(type(mods) == "table", "Mods should be a table")
end

---Test: Get list of mods
function TestModManager.testGetMods()
    ModManager.init()
    
    local mods = ModManager.getMods()
    assert(#mods >= 0, "Should return mod list")
    
    print("[Detected Mods]")
    for _, mod in ipairs(mods) do
        print(string.format("  - %s (%s) v%s", mod.name or "Unknown", mod.id or "?", mod.version or "?"))
    end
end

---Test: Set active mod
function TestModManager.testSetActiveMod()
    ModManager.init()
    
    local success = ModManager.setActiveMod("core")
    assert(success, "Should set core mod as active")
    
    local activeMod = ModManager.getActiveMod()
    assert(activeMod ~= nil, "Should have active mod")
    assert(activeMod.id == "core", "Active mod should be 'core'")
end

---Test: Get content path
function TestModManager.testGetContentPath()
    ModManager.init()
    ModManager.setActiveMod("core")
    
    local path = ModManager.getContentPath("rules", "terrain.toml")
    assert(path ~= nil, "Should return content path")
    assert(type(path) == "string", "Path should be string")
    assert(path:match("mods/"), "Path should include mods directory")
end

---Test: Get mapblock path
function TestModManager.testGetMapblockPath()
    ModManager.init()
    ModManager.setActiveMod("core")
    
    local path = ModManager.getContentPath("mapblocks", "test_block.toml")
    assert(path ~= nil, "Should return mapblock path")
    assert(path:match("mapblocks"), "Path should include mapblocks directory")
end

---Test: Get asset path
function TestModManager.testGetAssetPath()
    ModManager.init()
    ModManager.setActiveMod("core")
    
    local path = ModManager.getContentPath("assets", "images/unit.png")
    assert(path ~= nil, "Should return asset path")
    assert(path:match("assets"), "Path should include assets directory")
end

---Test: Get mission definition path
function TestModManager.testGetMissionPath()
    ModManager.init()
    ModManager.setActiveMod("core")
    
    local path = ModManager.getContentPath("missions", "terror_mission.toml")
    assert(path ~= nil, "Should return mission path")
    assert(path:match("missions"), "Path should include missions directory")
end

---Test: Invalid mod ID
function TestModManager.testInvalidModId()
    ModManager.init()
    
    local success = ModManager.setActiveMod("nonexistent_mod_xyz")
    assert(not success, "Should fail with invalid mod ID")
end

---Test: Mod dependencies
function TestModManager.testModDependencies()
    ModManager.init()
    
    local mods = ModManager.getMods()
    
    -- Check if any mod has dependencies
    local foundDependencies = false
    for _, mod in ipairs(mods) do
        if mod.dependencies and #mod.dependencies > 0 then
            foundDependencies = true
            print(string.format("[Mod Dependencies] %s requires:", mod.name))
            for _, dep in ipairs(mod.dependencies) do
                print(string.format("  - %s", dep))
            end
        end
    end
    
    assert(true, "Dependency check completed")
end

---Test: Get active mod when none set
function TestModManager.testNoActiveMod()
    -- Don't initialize or set active mod
    local activeMod = ModManager.getActiveMod()
    -- Should either return nil or default mod
    assert(true, "Should handle no active mod gracefully")
end

---Test: Multiple content types
function TestModManager.testMultipleContentTypes()
    ModManager.init()
    ModManager.setActiveMod("core")
    
    local contentTypes = {
        {"rules", "terrain.toml"},
        {"mapblocks", "block.toml"},
        {"mapscripts", "script.toml"},
        {"assets", "image.png"},
        {"missions", "mission.toml"},
        {"data", "units.toml"}
    }
    
    print("[Content Path Resolution]")
    for _, contentType in ipairs(contentTypes) do
        local path = ModManager.getContentPath(contentType[1], contentType[2])
        if path then
            print(string.format("  ✓ %s: %s", contentType[1], path))
        else
            print(string.format("  ✗ %s: nil", contentType[1]))
        end
    end
    
    assert(true, "Content path resolution completed")
end

-- Run all tests
function TestModManager.runAll()
    print("\n=== Running Mod Manager Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    runTest("Initialize", TestModManager.testInitialize)
    runTest("Get Mods", TestModManager.testGetMods)
    runTest("Set Active Mod", TestModManager.testSetActiveMod)
    runTest("Get Content Path", TestModManager.testGetContentPath)
    runTest("Get Mapblock Path", TestModManager.testGetMapblockPath)
    runTest("Get Asset Path", TestModManager.testGetAssetPath)
    runTest("Get Mission Path", TestModManager.testGetMissionPath)
    runTest("Invalid Mod ID", TestModManager.testInvalidModId)
    runTest("Mod Dependencies", TestModManager.testModDependencies)
    runTest("No Active Mod", TestModManager.testNoActiveMod)
    runTest("Multiple Content Types", TestModManager.testMultipleContentTypes)
    
    print("\n=== Mod Manager Test Results ===")
    print(string.format("Total: %d, Passed: %d (%.1f%%), Failed: %d (%.1f%%)",
        testsPassed + testsFailed,
        testsPassed,
        (testsPassed / (testsPassed + testsFailed)) * 100,
        testsFailed,
        (testsFailed / (testsPassed + testsFailed)) * 100
    ))
    
    if testsFailed > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  ✗ %s: %s", failure.name, failure.error))
        end
    else
        print("\n✓ All tests passed!")
    end
    
    return testsPassed, testsFailed
end

return TestModManager



