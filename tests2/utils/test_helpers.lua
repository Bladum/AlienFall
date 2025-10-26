-- ─────────────────────────────────────────────────────────────────────────
-- TEST HELPERS
-- Utility functions for testing in Love2D environment
-- ─────────────────────────────────────────────────────────────────────────

local Helpers = {}

-- ─────────────────────────────────────────────────────────────────────────
-- FILE OPERATIONS
-- ─────────────────────────────────────────────────────────────────────────

---Check if file exists
function Helpers.fileExists(path)
    if not love then
        -- Fallback for non-Love2D environment
        local file = io.open(path, "r")
        if file then
            file:close()
            return true
        end
        return false
    end

    return love.filesystem.getInfo(path) ~= nil
end

---Read file contents
function Helpers.readFile(path)
    if love and love.filesystem then
        if love.filesystem.getInfo(path) then
            return love.filesystem.read(path)
        end
    else
        local file = io.open(path, "r")
        if file then
            local content = file:read("*a")
            file:close()
            return content
        end
    end
    return nil
end

---Write to file
function Helpers.writeFile(path, content)
    if love and love.filesystem then
        return love.filesystem.write(path, content)
    else
        local file = io.open(path, "w")
        if file then
            file:write(content)
            file:close()
            return true
        end
    end
    return false
end

---Delete file
function Helpers.deleteFile(path)
    if love and love.filesystem then
        return love.filesystem.remove(path)
    else
        return os.remove(path) == 0
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEMPORARY FILES (per copilot-instructions.md: use temp/ dir)
-- ─────────────────────────────────────────────────────────────────────────

---Get temp directory path
function Helpers.getTempDir()
    return "temp"
end

---Create temp file with unique name
function Helpers.createTempFile(prefix, extension)
    prefix = prefix or "test"
    extension = extension or ".tmp"

    local tempDir = Helpers.getTempDir()

    -- Ensure temp dir exists
    if not Helpers.fileExists(tempDir) then
        if love and love.filesystem then
            love.filesystem.createDirectory(tempDir)
        else
            os.execute("mkdir " .. tempDir)
        end
    end

    -- Generate unique filename
    local timestamp = os.time()
    local random = math.floor(math.random() * 10000)
    local filename = string.format("%s_%d_%d%s", prefix, timestamp, random, extension)

    return tempDir .. "/" .. filename
end

---Clean up temp file
function Helpers.cleanupTempFile(path)
    if Helpers.fileExists(path) then
        Helpers.deleteFile(path)
        return true
    end
    return false
end

-- ─────────────────────────────────────────────────────────────────────────
-- DATA STRUCTURES
-- ─────────────────────────────────────────────────────────────────────────

---Deep copy a table
function Helpers.deepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end

    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Helpers.deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

---Merge two tables
function Helpers.merge(t1, t2)
    local result = Helpers.deepCopy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

---Check if table contains value
function Helpers.tableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

---Get table size
function Helpers.tableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- ─────────────────────────────────────────────────────────────────────────
-- ASSERTIONS
-- ─────────────────────────────────────────────────────────────────────────

---Assert equals (simple)
function Helpers.assertEqual(actual, expected, message)
    if actual ~= expected then
        error(message or string.format("Expected %s, got %s",
            tostring(expected), tostring(actual)))
    end
end

---Assert true
function Helpers.assertTrue(condition, message)
    if not condition then
        error(message or "Expected true, got false")
    end
end

---Assert false
function Helpers.assertFalse(condition, message)
    if condition then
        error(message or "Expected false, got true")
    end
end

---Assert not nil
function Helpers.assertNotNil(value, message)
    if value == nil then
        error(message or "Expected non-nil value, got nil")
    end
end

---Assert throws
function Helpers.assertThrows(fn, expectedError, message)
    local ok, err = pcall(fn)
    if ok then
        error(message or "Expected function to throw error")
    end
    if expectedError and not string.find(tostring(err), expectedError, 1, true) then
        error(string.format("Expected error containing '%s', got '%s'",
            expectedError, tostring(err)))
    end
end

---Assert does not throw
function Helpers.assertNoThrow(fn, message)
    local ok, err = pcall(fn)
    if not ok then
        error(message or string.format("Expected no error, got: %s", tostring(err)))
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- MOCKING & SPYING
-- ─────────────────────────────────────────────────────────────────────────

---Create a mock function that tracks calls
function Helpers.mockFunction(returnValue)
    local mock = {
        called = false,
        callCount = 0,
        calls = {},
        returnValue = returnValue
    }

    local function fn(...)
        mock.called = true
        mock.callCount = mock.callCount + 1
        table.insert(mock.calls, {...})
        return mock.returnValue
    end

    mock.fn = fn
    return mock
end

---Create spy wrapper around real function
function Helpers.spy(fn)
    local spy = {
        original = fn,
        callCount = 0,
        calls = {},
        returnValues = {}
    }

    local function wrapper(...)
        spy.callCount = spy.callCount + 1
        local args = {...}
        table.insert(spy.calls, args)

        local result = {fn(...)}
        table.insert(spy.returnValues, result)
        return fn(...)
    end

    spy.fn = wrapper
    return spy
end

-- ─────────────────────────────────────────────────────────────────────────
-- TIMING & PERFORMANCE
-- ─────────────────────────────────────────────────────────────────────────

---Measure execution time
function Helpers.measureTime(fn, iterations)
    iterations = iterations or 1

    local startTime = os.clock()
    for _ = 1, iterations do
        fn()
    end
    local duration = os.clock() - startTime

    return {
        total = duration,
        average = duration / iterations,
        iterations = iterations
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- LOVE2D SPECIFIC
-- ─────────────────────────────────────────────────────────────────────────

---Create mock Love2D environment for testing
function Helpers.mockLoveEnvironment()
    if love then return end

    _G.love = {
        graphics = {
            print = function() end,
            setColor = function() end,
        },
        filesystem = {
            getInfo = function(path)
                local file = io.open(path, "r")
                if file then
                    file:close()
                    return {size = 0}
                end
                return nil
            end,
            read = function(path)
                return Helpers.readFile(path)
            end,
            write = function(path, content)
                return Helpers.writeFile(path, content)
            end,
            remove = function(path)
                return os.remove(path)
            end,
            createDirectory = function(path)
                os.execute("mkdir " .. path)
            end
        }
    }
end

---Create mock game state
function Helpers.mockGameState()
    return {
        phase = "geoscape",
        turn = 1,
        year = 2024,
        money = 1000,
        units = {},
        basesCount = 0,
        mapSize = {width = 100, height = 100}
    }
end

-- ─────────────────────────────────────────────────────────────────────────
-- PRINTING & DEBUGGING
-- ─────────────────────────────────────────────────────────────────────────

---Print debug message with prefix
function Helpers.debug(prefix, message)
    print(string.format("[%s] %s", prefix, tostring(message)))
end

---Print table contents
function Helpers.printTable(tbl, indent)
    indent = indent or ""
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            print(indent .. k .. ":")
            Helpers.printTable(v, indent .. "  ")
        else
            print(indent .. k .. " = " .. tostring(v))
        end
    end
end

---Format value for display
function Helpers.formatValue(v)
    if v == nil then return "nil"
    elseif type(v) == "boolean" then return tostring(v)
    elseif type(v) == "number" then return tostring(v)
    elseif type(v) == "string" then return '"' .. v .. '"'
    elseif type(v) == "table" then
        local count = 0
        for _ in pairs(v) do count = count + 1 end
        return "{table: " .. count .. " items}"
    else return "[" .. type(v) .. "]"
    end
end

return Helpers
