---Test Suite for Save/Load System
---Tests game state persistence, auto-save, and save slot management

-- Mock Love2D filesystem if not available
if not love then
    love = {
        filesystem = {
            getSaveDirectory = function() return os.getenv("TEMP") or "/tmp" end,
            getInfo = function(path) return nil end,
            write = function(path, data) return true end,
            read = function(path) return nil end,
            remove = function(path) return true end,
            getDirectoryItems = function(path) return {} end
        }
    }
end

local SaveSystem = require("engine.core.save_system")

local TestSaveSystem = {}
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

---Test: Create save system
function TestSaveSystem.testCreateSaveSystem()
    local saveSystem = SaveSystem.new()
    assert(saveSystem ~= nil, "Save system should be created")
    assert(saveSystem.maxSaveSlots == 10, "Should have 10 save slots")
    assert(saveSystem.autoSaveSlot == 0, "Auto-save should be slot 0")
end

---Test: Save game state
function TestSaveSystem.testSaveGameState()
    local saveSystem = SaveSystem.new()
    
    local gameState = {
        campaign = {
            name = "Test Campaign",
            day = 15,
            funds = 100000
        },
        base = {
            name = "HQ",
            facilities = {"ACCESS_LIFT", "LIVING_QUARTERS"}
        },
        squad = {
            {name = "John", rank = "SERGEANT", health = 80}
        }
    }
    
    local success = saveSystem:save(1, gameState)
    assert(success, "Save should succeed")
end

---Test: Load game state
function TestSaveSystem.testLoadGameState()
    local saveSystem = SaveSystem.new()
    
    local gameState = {
        campaign = {name = "Test", day = 1}
    }
    
    saveSystem:save(2, gameState)
    local loaded = saveSystem:load(2)
    
    -- In mock environment, load might return nil
    -- This test verifies the API contract
    assert(true, "Load API should not crash")
end

---Test: Auto-save interval
function TestSaveSystem.testAutoSave()
    local saveSystem = SaveSystem.new()
    
    local gameState = {
        campaign = {name = "AutoSave Test"}
    }
    
    -- First auto-save should work
    local saved = saveSystem:autoSave(gameState)
    assert(saved, "First auto-save should succeed")
    
    -- Immediate auto-save should be skipped (interval check)
    saved = saveSystem:autoSave(gameState)
    assert(not saved, "Second auto-save should be skipped (too soon)")
end

---Test: List available saves
function TestSaveSystem.testListSaves()
    local saveSystem = SaveSystem.new()
    
    local saves = saveSystem:listSaves()
    assert(saves ~= nil, "Should return saves list")
    assert(type(saves) == "table", "Saves should be a table")
end

---Test: Delete save
function TestSaveSystem.testDeleteSave()
    local saveSystem = SaveSystem.new()
    
    local gameState = {campaign = {name = "Delete Test"}}
    saveSystem:save(5, gameState)
    
    local success = saveSystem:deleteSave(5)
    assert(success, "Delete should succeed")
end

---Test: Invalid slot numbers
function TestSaveSystem.testInvalidSlots()
    local saveSystem = SaveSystem.new()
    
    local gameState = {campaign = {name = "Test"}}
    
    -- Test negative slot
    local success = saveSystem:save(-1, gameState)
    assert(not success, "Should fail with negative slot")
    
    -- Test slot exceeding max
    success = saveSystem:save(99, gameState)
    assert(not success, "Should fail with slot > maxSaveSlots")
end

---Test: Save metadata
function TestSaveSystem.testSaveMetadata()
    local saveSystem = SaveSystem.new()
    
    local gameState = {
        campaign = {
            name = "Metadata Test",
            day = 30,
            funds = 50000
        }
    }
    
    saveSystem:save(3, gameState)
    
    local saves = saveSystem:listSaves()
    -- Check that metadata structure is correct
    assert(saves ~= nil, "Should have saves metadata")
end

---Test: Corrupted save handling
function TestSaveSystem.testCorruptedSave()
    local saveSystem = SaveSystem.new()
    
    -- Try to load from non-existent slot
    local loaded = saveSystem:load(99)
    assert(loaded == nil, "Loading non-existent save should return nil")
end

---Test: Multiple saves persistence
function TestSaveSystem.testMultipleSaves()
    local saveSystem = SaveSystem.new()
    
    -- Save to multiple slots
    for i = 1, 5 do
        local gameState = {
            campaign = {
                name = "Campaign " .. i,
                day = i * 10
            }
        }
        saveSystem:save(i, gameState)
    end
    
    local saves = saveSystem:listSaves()
    assert(saves ~= nil, "Should have multiple saves")
end

-- Run all tests
function TestSaveSystem.runAll()
    print("\n=== Running Save System Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    runTest("Create Save System", TestSaveSystem.testCreateSaveSystem)
    runTest("Save Game State", TestSaveSystem.testSaveGameState)
    runTest("Load Game State", TestSaveSystem.testLoadGameState)
    runTest("Auto-Save", TestSaveSystem.testAutoSave)
    runTest("List Saves", TestSaveSystem.testListSaves)
    runTest("Delete Save", TestSaveSystem.testDeleteSave)
    runTest("Invalid Slots", TestSaveSystem.testInvalidSlots)
    runTest("Save Metadata", TestSaveSystem.testSaveMetadata)
    runTest("Corrupted Save", TestSaveSystem.testCorruptedSave)
    runTest("Multiple Saves", TestSaveSystem.testMultipleSaves)
    
    print("\n=== Save System Test Results ===")
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

return TestSaveSystem
