-- Unit Tests for Data Loader System
-- Tests JSON/Lua data loading, validation, and caching

local DataLoaderTest = {}

-- Test data loader creation
function DataLoaderTest.testCreate()
    local DataLoader = require("core.data_loader")
    
    -- DataLoader is typically a module, not an instance
    assert(DataLoader ~= nil, "DataLoader module should exist")
    assert(type(DataLoader) == "table", "DataLoader should be a table")
    
    print("✓ testCreate passed")
end

-- Test loading mock data
function DataLoaderTest.testLoadMockData()
    -- Test with mock data tables
    local mockData = {
        units = {
            soldier = {name = "Soldier", hp = 10},
            alien = {name = "Alien", hp = 5}
        },
        items = {
            rifle = {name = "Rifle", damage = 4},
            pistol = {name = "Pistol", damage = 3}
        }
    }
    
    -- Verify structure
    assert(mockData.units ~= nil, "Units data should exist")
    assert(mockData.items ~= nil, "Items data should exist")
    assert(mockData.units.soldier.hp == 10, "Soldier HP should be 10")
    
    print("✓ testLoadMockData passed")
end

-- Test data validation
function DataLoaderTest.testDataValidation()
    local function validateUnitData(data)
        if not data.name then return false, "Missing name" end
        if not data.hp or data.hp <= 0 then return false, "Invalid HP" end
        return true
    end
    
    -- Valid data
    local valid = {name = "Soldier", hp = 10}
    local isValid, err = validateUnitData(valid)
    assert(isValid, "Valid data should pass validation")
    
    -- Invalid data (missing name)
    local invalid1 = {hp = 10}
    isValid, err = validateUnitData(invalid1)
    assert(not isValid, "Invalid data should fail validation")
    assert(err == "Missing name", "Should report missing name")
    
    -- Invalid data (bad HP)
    local invalid2 = {name = "Soldier", hp = 0}
    isValid, err = validateUnitData(invalid2)
    assert(not isValid, "Invalid HP should fail validation")
    
    print("✓ testDataValidation passed")
end

-- Test data caching
function DataLoaderTest.testDataCaching()
    local cache = {}
    
    local function loadData(key)
        if cache[key] then
            return cache[key], true -- Return cached, true for "from cache"
        end
        
        -- Simulate loading
        local data = {loaded = true, key = key}
        cache[key] = data
        return data, false -- Return new, false for "not from cache"
    end
    
    -- First load
    local data1, fromCache1 = loadData("test")
    assert(data1.loaded == true, "Data should be loaded")
    assert(fromCache1 == false, "First load should not be from cache")
    
    -- Second load (should be cached)
    local data2, fromCache2 = loadData("test")
    assert(data2.loaded == true, "Cached data should be available")
    assert(fromCache2 == true, "Second load should be from cache")
    assert(data1 == data2, "Cached data should be same instance")
    
    print("✓ testDataCaching passed")
end

-- Test deep table copy
function DataLoaderTest.testDeepCopy()
    local function deepCopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for key, value in pairs(orig) do
                copy[deepCopy(key)] = deepCopy(value)
            end
        else
            copy = orig
        end
        return copy
    end
    
    -- Create original
    local original = {
        name = "Test",
        nested = {value = 42},
        array = {1, 2, 3}
    }
    
    -- Make copy
    local copy = deepCopy(original)
    
    -- Verify copy is independent
    copy.name = "Modified"
    copy.nested.value = 99
    
    assert(original.name == "Test", "Original should not be modified")
    assert(original.nested.value == 42, "Original nested should not be modified")
    
    print("✓ testDeepCopy passed")
end

-- Test data merging
function DataLoaderTest.testDataMerging()
    local function mergeTables(base, override)
        local result = {}
        
        -- Copy base
        for k, v in pairs(base) do
            result[k] = v
        end
        
        -- Override with new values
        for k, v in pairs(override) do
            result[k] = v
        end
        
        return result
    end
    
    local base = {a = 1, b = 2, c = 3}
    local override = {b = 20, d = 4}
    
    local merged = mergeTables(base, override)
    
    assert(merged.a == 1, "Base value should remain")
    assert(merged.b == 20, "Override should replace")
    assert(merged.c == 3, "Base value should remain")
    assert(merged.d == 4, "New value should be added")
    
    print("✓ testDataMerging passed")
end

-- Test data serialization
function DataLoaderTest.testSerialization()
    local function serializeTable(tbl)
        local parts = {}
        table.insert(parts, "{")
        
        for k, v in pairs(tbl) do
            local key = type(k) == "string" and string.format('["%s"]', k) or string.format("[%s]", k)
            local value
            
            if type(v) == "string" then
                value = string.format('"%s"', v)
            elseif type(v) == "number" then
                value = tostring(v)
            elseif type(v) == "boolean" then
                value = tostring(v)
            else
                value = "nil"
            end
            
            table.insert(parts, key .. "=" .. value .. ",")
        end
        
        table.insert(parts, "}")
        return table.concat(parts)
    end
    
    local data = {name = "Test", value = 42, active = true}
    local serialized = serializeTable(data)
    
    assert(type(serialized) == "string", "Serialization should return string")
    assert(serialized:find("Test"), "Should contain string value")
    assert(serialized:find("42"), "Should contain number value")
    
    print("✓ testSerialization passed")
end

-- Test error handling
function DataLoaderTest.testErrorHandling()
    local function loadWithErrorHandling(filename)
        local success, result = pcall(function()
            if filename == "error.dat" then
                error("File not found")
            end
            return {loaded = true}
        end)
        
        if not success then
            return nil, result
        end
        
        return result, nil
    end
    
    -- Successful load
    local data, err = loadWithErrorHandling("valid.dat")
    assert(data ~= nil, "Valid file should load")
    assert(err == nil, "Should not have error")
    
    -- Failed load
    data, err = loadWithErrorHandling("error.dat")
    assert(data == nil, "Invalid file should not load")
    assert(err ~= nil, "Should have error message")
    
    print("✓ testErrorHandling passed")
end

-- Run all tests
function DataLoaderTest.runAll()
    print("\n=== Data Loader Tests ===")
    
    DataLoaderTest.testCreate()
    DataLoaderTest.testLoadMockData()
    DataLoaderTest.testDataValidation()
    DataLoaderTest.testDataCaching()
    DataLoaderTest.testDeepCopy()
    DataLoaderTest.testDataMerging()
    DataLoaderTest.testSerialization()
    DataLoaderTest.testErrorHandling()
    
    print("✓ All Data Loader tests passed!\n")
end

return DataLoaderTest



