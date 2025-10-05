--- Test suite for Save Service
--
-- Tests the SaveService functionality for save/load operations and data persistence.
--
-- @module test.engine.test_save

local test_framework = require "test.framework.test_framework"
local SaveService = require "engine.save"

local test_save = {}

--- Helper function to load Lua mock data
local function load_lua_mock(filename)
    local path = "test/mock/engine/" .. filename
    return dofile(path)
end

--- Run all Save Service tests
function test_save.run()
    test_framework.run_suite("Save Service", {
        test_initialization = test_save.test_initialization,
        test_serialization = test_save.test_serialization,
        test_save_and_load = test_save.test_save_and_load,
        test_list_slots = test_save.test_list_slots,
        test_error_handling = test_save.test_error_handling,
        test_telemetry_integration = test_save.test_telemetry_integration
    })
end

--- Test SaveService initialization
function test_save.test_initialization()
    local save = SaveService.new()

    test_framework.assert_not_nil(save)
    test_framework.assert_nil(save.telemetry)
    test_framework.assert_equal(save.mountPoint, "saves")

    -- Test with custom options
    local saveWithOpts = SaveService.new({
        telemetry = {recordEvent = function() end},
        mountPoint = "custom_saves"
    })
    test_framework.assert_not_nil(saveWithOpts.telemetry)
    test_framework.assert_equal(saveWithOpts.mountPoint, "custom_saves")
end

--- Test data serialization
function test_save.test_serialization()
    -- Test serialization directly (accessing private function via debug)
    local serialize = debug.getupvalue(SaveService.new().save, 1) -- Get the serialize function

    -- Test primitive types
    test_framework.assert_equal(serialize(42), "42")
    test_framework.assert_equal(serialize(true), "true")
    test_framework.assert_equal(serialize(false), "false")
    test_framework.assert_equal(serialize("hello"), '"hello"')
    test_framework.assert_equal(serialize("hello\nworld"), '"hello\\nworld"')

    -- Test table serialization
    local simpleTable = {a = 1, b = "test"}
    local serialized = serialize(simpleTable)
    test_framework.assert_true(serialized:find("a = 1") ~= nil)
    test_framework.assert_true(serialized:find('b = "test"') ~= nil)

    -- Test nested table
    local nestedTable = {data = {x = 10, y = 20}, name = "point"}
    local nestedSerialized = serialize(nestedTable)
    test_framework.assert_true(nestedSerialized:find("data = {") ~= nil)
    test_framework.assert_true(nestedSerialized:find("x = 10") ~= nil)

    -- Test array-like table
    local arrayTable = {10, 20, 30}
    local arraySerialized = serialize(arrayTable)
    test_framework.assert_true(arraySerialized:find("[1] = 10") ~= nil)
    test_framework.assert_true(arraySerialized:find("[2] = 20") ~= nil)
    test_framework.assert_true(arraySerialized:find("[3] = 30") ~= nil)
end

--- Test save and load operations
function test_save.test_save_and_load()
    -- Mock Love2D filesystem API
    local mockFilesystem = {
        files = {},
        directories = {},
        createDirectory = function(dir)
            mockFilesystem.directories[dir] = true
        end,
        getInfo = function(path, type)
            if type == "directory" and mockFilesystem.directories[path] then
                return {type = "directory"}
            elseif type == "file" and mockFilesystem.files[path] then
                return {type = "file"}
            end
            return nil
        end,
        write = function(filename, content)
            mockFilesystem.files[filename] = content
            return true
        end,
        load = function(filename)
            local content = mockFilesystem.files[filename]
            if not content then return nil, "file not found" end
            return loadstring(content)
        end,
        getDirectoryItems = function(dir)
            local items = {}
            for filename in pairs(mockFilesystem.files) do
                if filename:find("^" .. dir .. "/") then
                    local item = filename:gsub("^" .. dir .. "/", "")
                    table.insert(items, item)
                end
            end
            return items
        end
    }

    -- Replace love.filesystem with mock
    local originalLove = love
    love = {filesystem = mockFilesystem}

    local save = SaveService.new({mountPoint = "test_saves"})

    -- Test save operation
    local testData = load_lua_mock("save_test_data.lua")

    local success, err = save:save("slot1", testData)
    test_framework.assert_true(success)
    test_framework.assert_nil(err)

    -- Test load operation
    local loadedData, loadErr = save:load("slot1")
    test_framework.assert_not_nil(loadedData)
    test_framework.assert_nil(loadErr)
    test_framework.assert_equal(loadedData.player.name, "Alice")
    test_framework.assert_equal(loadedData.player.level, 5)
    test_framework.assert_equal(#loadedData.inventory, 3)
    test_framework.assert_equal(loadedData.score, 12345)

    -- Test loading non-existent save
    local missingData, missingErr = save:load("nonexistent")
    test_framework.assert_nil(missingData)
    test_framework.assert_equal(missingErr, "no_save")

    -- Restore original love
    love = originalLove
end

--- Test listing save slots
function test_save.test_list_slots()
    -- Mock Love2D filesystem API
    local mockFilesystem = {
        files = load_lua_mock("save_slots_files.lua"),
        directories = {["saves"] = true},
        createDirectory = function() end,
        getInfo = function(path, type)
            if type == "directory" and mockFilesystem.directories[path] then
                return {type = "directory"}
            end
            return nil
        end,
        getDirectoryItems = function(dir)
            local items = {}
            for filename in pairs(mockFilesystem.files) do
                if filename:find("^" .. dir .. "/") then
                    local item = filename:gsub("^" .. dir .. "/", "")
                    table.insert(items, item)
                end
            end
            return items
        end
    }

    -- Replace love.filesystem with mock
    local originalLove = love
    love = {filesystem = mockFilesystem}

    local save = SaveService.new()

    -- Test listing slots
    local slots = save:listSlots()
    test_framework.assert_equal(#slots, 3)
    test_framework.assert_equal(slots[1], "slot1")
    test_framework.assert_equal(slots[2], "slot2")
    test_framework.assert_equal(slots[3], "slot3")

    -- Test empty directory
    mockFilesystem.files = {}
    local emptySlots = save:listSlots()
    test_framework.assert_equal(#emptySlots, 0)

    -- Restore original love
    love = originalLove
end

--- Test error handling
function test_save.test_error_handling()
    local save = SaveService.new()

    -- Test invalid slot name
    local success1 = pcall(function() save:save("", {}) end)
    test_framework.assert_false(success1)

    local success2 = pcall(function() save:save(nil, {}) end)
    test_framework.assert_false(success2)

    -- Test invalid data type
    local success3 = pcall(function() save:save("test", "not a table") end)
    test_framework.assert_false(success3)

    local success4 = pcall(function() save:save("test", 42) end)
    test_framework.assert_false(success4)

    -- Test invalid load slot
    local success5 = pcall(function() save:load("") end)
    test_framework.assert_false(success5)

    local success6 = pcall(function() save:load(nil) end)
    test_framework.assert_false(success6)
end

--- Test telemetry integration
function test_save.test_telemetry_integration()
    local events = {}
    local mockTelemetry = {
        recordEvent = function(self, event)
            table.insert(events, event)
        end
    }

    -- Mock Love2D filesystem API
    local mockFilesystem = {
        files = {},
        directories = {},
        createDirectory = function(dir)
            mockFilesystem.directories[dir] = true
        end,
        getInfo = function(path, type)
            if type == "directory" and mockFilesystem.directories[path] then
                return {type = "directory"}
            end
            return nil
        end,
        write = function(filename, content)
            mockFilesystem.files[filename] = content
            return true
        end
    }

    -- Replace love.filesystem with mock
    local originalLove = love
    love = {filesystem = mockFilesystem}

    local save = SaveService.new({telemetry = mockTelemetry})

    -- Test successful save records telemetry
    local testData = load_lua_mock("telemetry_test_data.lua")
    save:save("telemetry_test", testData)
    test_framework.assert_equal(#events, 1)
    test_framework.assert_equal(events[1].type, "save")
    test_framework.assert_equal(events[1].slot, "telemetry_test")
    test_framework.assert_true(events[1].ok)
    test_framework.assert_nil(events[1].error)

    -- Restore original love
    love = originalLove
end

return test_save